local roomy = require( 'libs.roomy' )
local inifile = require( 'libs.inifile' )
local loveframes = require( 'libs.loveframes.init' )
local anim8 = require( 'libs.anim8' )
local FrameUtils = require( 'core.FrameUtils' )

-- not to be confused with a chart editor
-- this one just aids on making animated characters
local chareditor = { }

local assets = { }

local Editor = {
	-- actual important stuff
	Spritesheet = nil,
	XML = nil,
	Animations = { },
	AnimationFrames = { },
	
	-- temporary garbage
	frameSize = { },
	currentlySelected = 1,
	fileName = '',
	modalBeingDrawn = false,	-- make sure to only draw animated sprites when no modal's active
	animationNames = { }
}

-- for later use
local animationFrame = nil
local frameFrame = nil -- lol
local animationBox = nil

function chareditor:enter(previous, ... )
	assets = select( 1, ... )
	
	--[[ -------------------------------------------------------------------------]]
	
	-- grid that aids in the positioning of the frames
	local grid = loveframes.Create( 'grid' )
    grid:SetRows( 10 )
    grid:SetColumns( 10 )
    grid:SetCellWidth( 10 )
    grid:SetCellHeight( 10 )
    grid:SetCellPadding( 12 )
	
	-- render it in the middle of the screen too
	grid:SetPos( curr_width / 2 - ( grid.cellwidth + ( grid.cellpadding * 2 ) ) * ( grid.columns / 2 ), curr_height / 2 - ( grid.cellheight + ( grid.cellpadding * 2 ) ) * ( grid.rows / 2 ) )
	
	--[[ -------------------------------------- ]] --
	-- frames
	--[[ -------------------------------------- ]] --
	
	local toolsFrame = loveframes.Create( 'frame' )
    toolsFrame:SetName( 'Tools' )
	toolsFrame:SetWidth( 200 )
	toolsFrame:SetHeight( 270 )
    toolsFrame:SetPos( curr_width - toolsFrame.width, 0 )
	toolsFrame:SetDraggable( false )
    toolsFrame:SetDockable( false )
	toolsFrame:SetScreenLocked( true )	-- just in case you decide to do a stinky with it
	toolsFrame:ShowCloseButton( false )
	toolsFrame:MakeTop( )
	
	--[[ -------------------------------------- ]] --
	-- stuff inside main screen
	--[[ -------------------------------------- ]] --
	
	local spritesheetTxt = loveframes.Create( 'text', toolsFrame )
	spritesheetTxt:SetText( 'Spritesheet' )
	spritesheetTxt.Update = function( object, dt )
		object:CenterX( )
		object:SetY( 30 )
	end
	
	local spritesheetInput = loveframes.Create( 'textinput', toolsFrame )
	spritesheetInput:SetWidth( 190 )
	spritesheetInput:CenterX( )
	spritesheetInput:SetY( spritesheetTxt:GetY( ) + ( spritesheetInput:GetHeight( ) * 2 ) )
	
	local animationsTxt = loveframes.Create( 'text', toolsFrame )
	animationsTxt:SetText( 'Animations' )
	animationsTxt:SetY( 80 )
	animationsTxt.Update = function( object, dt )
		object:CenterX( )
	end
	
	animationBox = loveframes.Create( 'multichoice', toolsFrame )
	animationBox:AddChoice( 'None' )
	animationBox:SetChoice( 'None' )
	animationBox:SetWidth( 160 )
	animationBox:SetPos( 5, 100 )
	
	local animationBtn = loveframes.Create( 'button', toolsFrame )
	animationBtn:SetWidth( 25 )
	animationBtn:SetText( '+' )  -- cute
	animationBtn:SetPos( animationBox:GetWidth( ) + 10, 100 )
	animationBtn:SetEnabled( false )
	
	local addframeBtn = loveframes.Create( 'button', toolsFrame )
	addframeBtn:SetWidth( 80 )
	addframeBtn:SetText( 'Add Frames' )
	addframeBtn:SetPos( toolsFrame:GetWidth( ) - addframeBtn:GetWidth( ) - 5, 160 )
	addframeBtn:SetEnabled( false )
	
	local frameDataTxt = loveframes.Create( 'text', toolsFrame )
	frameDataTxt:SetText( 'Frame Data' )
	frameDataTxt:SetY( 130 )
	frameDataTxt.Update = function( object, dt )
		object:CenterX( )
	end
	
	local frameCountTxt = loveframes.Create( 'text', toolsFrame )
	frameCountTxt:SetText( 'Frame Count' )
	frameCountTxt:SetPos( 5, 160 )
	frameCountTxt.Update = function( object, dt )
		if Editor.AnimationFrames[ Editor.currentlySelected ] ~= nil then
			object:SetText( 'Frame Count\n' .. table.getn( Editor.AnimationFrames[ Editor.currentlySelected ] ) )
		else
			object:SetText( 'Frame Count\n0' )
		end
	end
	
	local loadAnimBtn = loveframes.Create( 'button', toolsFrame )
	loadAnimBtn:SetWidth( 80 )
	loadAnimBtn:SetText( 'Load .ini' )
	loadAnimBtn:SetPos( 5, 220 )
	
	local saveAnimBtn = loveframes.Create( 'button', toolsFrame )
	saveAnimBtn:SetWidth( 80 )
	saveAnimBtn:SetText( 'Save .ini' )
	saveAnimBtn:SetPos( toolsFrame:GetWidth( ) - addframeBtn:GetWidth( ) - 5, 220 )
	saveAnimBtn:SetEnabled( false )
	
	--[[ -------------------------------------------------------------------------]]
	
	addframeBtn.OnClick = function( )
		if animationBox:GetChoiceIndex( ) == 1 then
			print( 'Hell nah, select an animation first. ' )
		else
			frameFrame = loveframes.Create( 'frame' )
			frameFrame:SetName( 'Add Frames' )
			frameFrame:SetHeight( 120 )
			frameFrame:CenterWithinArea( 0, 0, love.graphics.getDimensions( ) )
			frameFrame:SetDraggable( false )
			frameFrame:SetDockable( false )
			frameFrame:ShowCloseButton( true )
			frameFrame.OnClose = function( object )
				Editor.modalBeingDrawn = false
			end
			
			Editor.modalBeingDrawn = true
			
			local xmlAnimNameTxt = loveframes.Create( 'text', frameFrame )
			xmlAnimNameTxt:SetText( 'Animation Name' )
			xmlAnimNameTxt:SetY( 30 )
			xmlAnimNameTxt.Update = function( object, dt )
				object:CenterX( )
			end
			
			local xmlAnimNameInput = loveframes.Create( 'textinput', frameFrame )
			xmlAnimNameInput:SetWidth( 190 )
			xmlAnimNameInput:CenterX( )
			xmlAnimNameInput:SetY( 50 )
			
			local xmlAnimNameHint = loveframes.Create( 'tooltip', frameFrame )
			xmlAnimNameHint:SetPadding( 10 )
			xmlAnimNameHint:SetText( 'Input the "animName" in name="animName0000" on your .xml.' )
			xmlAnimNameHint:SetObject( xmlAnimNameInput )
			
			local xmlHint = loveframes.Create( 'tooltip', frameFrame )
			xmlHint:SetPadding( 10 )
			xmlHint:SetText( "Tries to load the .xml file, same name as the spritesheet." )
			
			local loadFromXMLBtn = loveframes.Create( 'button', frameFrame )
			loadFromXMLBtn:SetWidth( 100 )
			loadFromXMLBtn:SetHeight( 30 )
			loadFromXMLBtn:SetText( 'Add From XML' )
			
			-- centering shit in love2d can be a pain in the ass
			loadFromXMLBtn:SetPos( frameFrame:GetWidth( ) / 2 - loadFromXMLBtn:GetWidth( ) / 2, frameFrame:GetHeight( ) - loadFromXMLBtn:GetHeight( ) - 5 )
			
			loadFromXMLBtn.OnClick = function( )
				if xmlAnimNameInput:GetValue( ) == nil or xmlAnimNameInput:GetValue( ) == '' then
					print( 'Input something valid there, you ass.' )
				else
					if assets.xmls[ Editor.fileName .. '.xml' ] ~= nil then
						print( 'Yep, shit\'s loaded, alright.' )
						Editor.XML = assets.xmls[ Editor.fileName .. '.xml' ]
						
						Editor.AnimationFrames[ Editor.currentlySelected ] = FrameUtils.getFramesFromXML( xmlAnimNameInput:GetValue( ) )
						
						if Editor.AnimationFrames [ Editor.currentlySelected ] ~= nil then
							Editor.Animations[ Editor.currentlySelected ] = anim8.newAnimation( Editor.AnimationFrames [ Editor.currentlySelected ], 0.05 )
							print( 'Yessirrrrr: ' .. table.getn( Editor.Animations[ Editor.currentlySelected ].frames ) )
							
							xmlHint:Remove( )
							xmlAnimNameHint:Remove( )
							
							frameFrame:Remove( )
							Editor.modalBeingDrawn = false
						else
							print( 'Animation frames are still null, you good, bro?' )
						end
					end
				end
			end
			
			xmlHint:SetObject( loadFromXMLBtn )
			
			frameFrame:SetModal( true )
		end
	end
	
	animationBox.OnChoiceSelected = function( object, choice )
		Editor.currentlySelected = animationBox:GetChoiceIndex( )
		
		print( Editor.currentlySelected )
		if choice == 'None' then
			animationBtn:SetText( '+' ) --    ('- ' )
		else
			if animationBtn:GetText( ) == '+' then animationBtn:SetText( '-' ) end
		end
	end
	
	animationBtn.OnClick = function( )
		if animationBtn:GetText( ) == '+' then
			animationFrame = loveframes.Create( 'frame' )
			animationFrame:SetName( 'Add Animation' )
			animationFrame:SetHeight( 120 )
			animationFrame:CenterWithinArea( 0, 0, love.graphics.getDimensions( ) )
			animationFrame:SetDraggable( false )
			animationFrame:SetDockable( false )
			animationFrame.OnClose = function( object )
				Editor.modalBeingDrawn = false
			end
			
			Editor.modalBeingDrawn = true
			
			local animationNameTxt = loveframes.Create( 'text', animationFrame )
			animationNameTxt:SetText( 'Name' )
			animationNameTxt:CenterX( )
			animationNameTxt:SetY( 30 )
			animationNameTxt.OnUpdate = function( object, dt ) end
			
			local animationNameInput = loveframes.Create( 'textinput', animationFrame )
			animationNameInput:SetWidth( 190 )
			animationNameInput:CenterX( )
			animationNameInput:SetY( 50 )
			
			local animationConfirm = loveframes.Create( 'button', animationFrame )
			animationConfirm:SetWidth( 70 )
			animationConfirm:SetHeight( 30 )
			animationConfirm:SetText( 'Add' )
			-- centering shit in love2d can be a pain in the ass
			animationConfirm:SetPos( animationFrame:GetWidth( ) / 2 - animationConfirm:GetWidth( ) - 10, animationFrame:GetHeight( ) - animationConfirm:GetHeight( ) - 5 )
			animationConfirm.OnClick = function( )
				local input = animationNameInput:GetValue( )
				if input == nil or input == '' then
					print( 'Input something valid in the box, you fuck.' )
				elseif animationBox.choices[ input ] ~= nil then
					print( 'That animation already exists, moron. Delete it first.' )
				else
					print( 'You good.' )
					
					animationBox:AddChoice( input )
					table.insert( Editor.animationNames, input )
					
					animationFrame.OnClose( animationFrame )
					animationFrame:Remove( )
				end
			end
			
			local animationCancel = loveframes.Create( 'button', animationFrame )
			animationCancel:SetWidth( 70 )
			animationCancel:SetHeight( 30 )
			animationCancel:SetText( 'Cancel' )
			animationCancel:SetPos( animationFrame:GetWidth( ) / 2 + 10, animationFrame:GetHeight( ) - animationCancel:GetHeight( ) - 5 )
			animationCancel.OnClick = function( )
				animationFrame.OnClose( animationFrame )
				animationFrame:Remove( )
			end
			
			animationFrame:SetModal( true )
		else
			Editor.Animations[ Editor.currentlySelected ] = nil
			Editor.AnimationFrames[ Editor.currentlySelected ] = nil
			
			local val = animationBox:GetValue( )
			animationBox:SetChoice( 'None' )
			animationBox.OnChoiceSelected( animationBox, animationBox:GetChoice( ) )
			
			animationBox:RemoveChoice( val )
			Editor.animationNames[ val ] = nil
		end
	end
	
	spritesheetInput.OnEnter = function(object, text) -- when you press enter in the input to confirm your entry
	
		if text == nil or text == '' then
			if Editor.Spritesheet ~= nil then
			
				Editor.Spritesheet = nil
				Editor.XML = nil
				Editor.Animations = { }
				Editor.AnimationOffsets = { }
				Editor.AnimationFrames = { }
				Editor.FrameOffsets = { }
				
				frameWidth:SetValue( 1 )
				frameHeight:SetValue( 1 )
				
				print( 'Image named "' .. Editor.fileName .. '" was unloaded.' )
				Editor.fileName = ''
				
				animationBox:Clear()
				animationBox:AddChoice( 'None' )
				animationBox:SetChoice( 'None' )
				
				animationBtn:SetEnabled( false )
				addframeBtn:SetEnabled( false )
			end
		else
			if assets.images[text] ~= nil then
			
				print( 'Found image asset named "' .. text .. '".' )
				Editor.Spritesheet = assets.images[text]
				Editor.fileName = text
				
				animationBtn:SetEnabled( true )
				addframeBtn:SetEnabled( true )
			else
				print( 'Image asset named "' .. text .. '" not found.' )
			end
		end
	end
end

function chareditor:update( dt )
	loveframes.update( dt )
	
	if Editor.Animations[ Editor.currentlySelected ] ~= nil then
		Editor.Animations[ Editor.currentlySelected ]:update( dt )
	end
end

function chareditor:leave(next, ...)
end

function chareditor:draw()
	--[[ -------------------------------------- ]] --
	
	-- cool background
	love.graphics.push()
	love.graphics.setColor ( 1, 1, 1, 1 )
	
	love.graphics.draw( assets.images['menuDesat'], 0, 0, 0, curr_width / assets.images['menuDesat']:getWidth( ), curr_height / assets.images['menuDesat']:getHeight( ) )
	love.graphics.pop()
	
	--[[ -------------------------------------- ]] --
	
	loveframes.draw()
	
	--[[ -------------------------------------- ]] --
	
	-- draw a circle in the absolute middle of the screen for reference
	-- love.graphics.push()
	-- love.graphics.setColor(1, 0, 0)
    -- love.graphics.circle("fill", curr_width / 2, curr_height / 2, 1, 5)
	-- love.graphics.pop()
	
	love.graphics.push( )
	
	love.graphics.scale( 0.3 )
	
	if Editor.Animations[ Editor.currentlySelected ] ~= nil
	and Editor.frameSize[ Editor.currentlySelected ] ~= nil
	and not Editor.modalBeingDrawn
	then
		Editor.Animations[ Editor.currentlySelected ]:draw( Editor.Spritesheet, curr_width / 2 / 0.3 - Editor.frameSize[ Editor.currentlySelected ][ 1 ] / 2, curr_height / 2 / 0.3 - Editor.frameSize[ Editor.currentlySelected ][ 2 ] / 2 )
	end
	
	love.graphics.pop( )
	
	--[[ -------------------------------------- ]] --
	
	love.graphics.push( )
	
	love.graphics.setColor(0, 0, 0, 1)
	
	love.graphics.print( 'Loaded ' .. assets.filecount .. ' assets in total.', 5, 200)
	love.graphics.print( assets.images.filecount .. ' images.', 5, 200 + 10 * 2)
	love.graphics.print( assets.sounds.filecount .. ' sounds.', 5, 200 + 10 * 4)
	love.graphics.print( assets.songs.filecount .. ' songs.', 5, 200 + 10 * 6)
	love.graphics.print( assets.fonts.filecount .. ' fonts.', 5, 200 + 10 * 8)
	love.graphics.print( assets.xmls.filecount .. ' xmls.', 5, 200 + 10 * 10)
	love.graphics.print( assets.inis.filecount .. ' offset inis.', 5, 200 + 10 * 12)
	
	love.graphics.pop( )
	
	--[[ -------------------------------------- ]] --
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function chareditor:keypressed(key, scancode, isrepeat)

	-- ain't that convenient
	if key == 'r' then
		love.event.quit( 'restart' )
	end
	
    loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
	loveframes.keyreleased(key)
end

function love.textinput(text)
	loveframes.textinput(text)
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function clamp( val, minnum, maxnum )
	return math.min( math.max( val, minnum), maxnum )
end

return chareditor
