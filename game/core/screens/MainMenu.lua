local mainmenu = { }

mainmenu.setForTransition = false

-- this will hold the anim8 objects for later
local menuOptions = { }
menuOptions.StoryMode = { }
menuOptions.FreeplayMode = { }
menuOptions.Options = { }

menuOptions.curSelected = 1

local poop

-- gotta turn this into a global or something now that Event from knife is here
local animatedSprites = { }

--[[--------------------------------------------------------------]]--

-- because it's not that simple to just overlap sounds in this fcking engine
local sound_fxs = { }
sound_fxs.remove = { }

function mainmenu:enter( previous, ... )
	
	--[[----------------------------------------------------]]--
	if menuOptions.StoryMode[ 'Selected' ] == nil then
		local animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'story mode white' )
		menuOptions.StoryMode[ 'Selected' ] = anim8.newAnimation( animFrames, 0.05 )
		
		menuOptions.StoryMode[ 'Selected' ].W, menuOptions.StoryMode[ 'Selected' ].H = animFrames.W, animFrames.H
		
		animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'story mode basic' )
		menuOptions.StoryMode[ 'Idle' ] = anim8.newAnimation( animFrames, 0.02 )
		
		menuOptions.StoryMode[ 'Idle' ].W, menuOptions.StoryMode[ 'Idle' ].H = animFrames.W, animFrames.H
		
		menuOptions.StoryMode.curAnim = 'Selected'
		table.insert( animatedSprites, menuOptions.StoryMode )
	end
	
	--[[----------------------------------------------------]]--
	if menuOptions.FreeplayMode[ 'Selected' ] == nil then
		animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'freeplay white' )
		menuOptions.FreeplayMode[ 'Selected' ] = anim8.newAnimation( animFrames, 0.05 )
		
		menuOptions.FreeplayMode[ 'Selected' ].W, menuOptions.FreeplayMode[ 'Selected' ].H = animFrames.W, animFrames.H
		
		animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'freeplay basic' )
		menuOptions.FreeplayMode[ 'Idle' ] = anim8.newAnimation( animFrames, 0.02 )
		
		menuOptions.FreeplayMode[ 'Idle' ].W, menuOptions.FreeplayMode[ 'Idle' ].H = animFrames.W, animFrames.H
		
		menuOptions.FreeplayMode.curAnim = 'Idle'
		table.insert( animatedSprites, menuOptions.FreeplayMode )
	end
	
	--[[----------------------------------------------------]]--
	if menuOptions.Options[ 'Selected' ] == nil then
		animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'options white' )
		menuOptions.Options[ 'Selected' ] = anim8.newAnimation( animFrames, 0.05 )
		
		menuOptions.Options[ 'Selected' ].W, menuOptions.Options[ 'Selected' ].H = animFrames.W, animFrames.H
		
		animFrames = assets.getFramesFromXML( 'FNF_main_menu_assets', 'options basic' )
		menuOptions.Options[ 'Idle' ] = anim8.newAnimation( animFrames, 0.02 )
		
		menuOptions.Options[ 'Idle' ].W, menuOptions.Options[ 'Idle' ].H = animFrames.W, animFrames.H
		
		menuOptions.Options.curAnim = 'Idle'
		table.insert( animatedSprites, menuOptions.Options )
	end
	
	menuOptions.StoryMode.alpha = 1
	menuOptions.FreeplayMode.alpha = 1
	menuOptions.Options.alpha = 1
	
	--[[----------------------------------------------------]]--
	
	mainmenu.active = true
	mainmenu.setForTransition = false
	menuOptions.curSelected = 1
	
	if poop ~= nil then poop:stop( ) end
end

function mainmenu:update( dt )

	if not mainmenu.active then return end
	
	Timer.update( dt )
	flux.update( dt )
	
	for index, anim in pairs( animatedSprites ) do
		animatedSprites[ index ][ anim.curAnim ]:update( dt )
		
		if index == menuOptions.curSelected then
			anim.curAnim = 'Selected'
		else
			anim.curAnim = 'Idle'
		end
	end
	
	--[[----------------------------------------------------]]--
	
	-- delete sfxs that are done playing by looping back to front
	for index = 1, #sound_fxs do
		if not sound_fxs[ index ]:isPlaying( ) then
			table.insert( sound_fxs.remove, sound_fxs[ index ] )
		end
	end
	
	for index = 1, #sound_fxs.remove do
		sound_fxs.remove[ index ] = nil
	end
end

function mainmenu:leave( next, ... )
	mainmenu.active = false
end

function mainmenu:draw( )
	
	if not mainmenu.active then return end
	
	-- menu background
	love.graphics.draw( assets.images[ 'menuBG' ], ( curr_width / 2 ), ( curr_height / 2 ), 0, 1, 1, assets.images[ 'menuBG' ]:getWidth( ) / 2, assets.images[ 'menuBG' ]:getHeight( ) / 2 )
	
	love.graphics.push( )
	
	love.graphics.scale( 0.5 )
	
	for index, anim in pairs( animatedSprites ) do
		
		if index == 1 then
			love.graphics.setColor( 1, 1, 1, animatedSprites[ index ].alpha )
			
			animatedSprites[ index ][ anim.curAnim ]:draw(
				assets.images[ 'FNF_main_menu_assets' ],
				( curr_width / 2 / 0.5 ) - anim[ anim.curAnim ].W / 2,
				( curr_height / 2 / 0.5 ) - anim[ anim.curAnim ].H / 2 - 200
			)
			
			love.graphics.setColor( 1, 1, 1, 1 )
		elseif index == 2 then
			love.graphics.setColor( 1, 1, 1, animatedSprites[ index ].alpha )
			
			animatedSprites[ index ][ anim.curAnim ]:draw(
				assets.images[ 'FNF_main_menu_assets' ],
				( curr_width / 2 / 0.5 ) - anim[ anim.curAnim ].W / 2,
				( curr_height / 2 / 0.5 ) - anim[ anim.curAnim ].H / 2
			)
			
			love.graphics.setColor( 1, 1, 1, 1 )
		elseif index == 3 then
			love.graphics.setColor( 1, 1, 1, animatedSprites[ index ].alpha )
			
			animatedSprites[ index ][ anim.curAnim ]:draw(
				assets.images[ 'FNF_main_menu_assets' ],
				( curr_width / 2 / 0.5 ) - anim[ anim.curAnim ].W / 2,
				( curr_height / 2 / 0.5 ) - anim[ anim.curAnim ].H / 2 + 200
			)
			
			love.graphics.setColor( 1, 1, 1, 1 )
		end
		
	end
	
	love.graphics.pop( )
	
	--love.graphics.setColor( 1, 0, 0 )
	
	-- center of the screen
	--love.graphics.circle( 'fill', curr_width / 2, curr_height / 2, 10, 10 )
	
	love.graphics.setColor( 1, 1, 1, 1 )
	
	--[[----------------------------------------------------]]--
	
	love.graphics.push( )
	
	love.graphics.scale( 0.08 )
	
	love.graphics.setFont( assets.fonts[ 'vcr' ] )
	
	-- information about the engine
	outlinedText( 'Funkin\' ( 0.1b BETA ) with Löve2D ( 11.4 )', 5 / 0.08, curr_height / 0.08 - love.graphics.getFont( ):getHeight( ) - 5 )
	
	love.graphics.pop( )
end

function mainmenu:keypressed( key, scancode, isrepeat )
	
	if not mainmenu.active or mainmenu.setForTransition then return end
	
	if key == 'up' or key == 'down' then
		menuOptions.curSelected = clamp( menuOptions.curSelected + ( key == 'up' and -1 or 1 ), 1, 3 )
		print( menuOptions.curSelected )
		
		local sfx = assets.sounds[ 'scrollMenu' ]:clone( )
		sfx:play( )
		
		-- so we can delete these from memory once they're done
		table.insert( sound_fxs, sfx )
	elseif key == 'return' or key == 'kpenter' then
		mainmenu.setForTransition = true
		
		poop = flux.to( animatedSprites[ menuOptions.curSelected ], 0.07, { alpha = 0 } )
		:ease( 'cubicinout' )
		:after( animatedSprites[ menuOptions.curSelected ], 0.07, { alpha = 1 } )
		:ease( 'cubicinout' )
		:cycle( true )
		
		assets.sounds[ 'confirmMenu' ]:play( )
		
		Timer.after( 1.5,
			function( )
			
				if menuOptions.curSelected == 1 then
					print( 'Story mode selected.' )
					
					roomy:enter( screens[ 'ingame' ] )
					
				elseif menuOptions.curSelected == 2 then
					print( 'Freeplay selected.' )
					
					roomy:enter( screens[ 'freeplay' ] )
				else
					print( 'Options selected.' )
					
					roomy:enter( screens[ 'settings' ] )
				end
			
			end
		)
	end
	
end

return mainmenu