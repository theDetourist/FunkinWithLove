local settings = { }

-- prevent input when in other screens
settings.active = false
settings.usershit = { }
settings.inputScreen = nil
settings.replacingKey = { false, false, false, false }			-- should only be true for one, obviously

local downscrollCheckmark = { }

local shit
local piss

function settings:enter( previous, ... )

	settings.usershit = inifile.parse( 'userconf.ini' )
	
	--[[--------------------------------------------------------]]--
	
	local mainPanel = loveframes.Create( 'panel' )
	
	mainPanel:SetSize( 400, 400 )
	mainPanel:Center( )
	
	--[[--------------------------------------------------------]]--
	
	local personalTxt = loveframes.Create( 'text', mainPanel )
	
	personalTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	personalTxt:SetText( 'Personal' )
	personalTxt:CenterX( )
	personalTxt:SetY( 5 )
	
	local personalPanel = loveframes.Create( 'panel', mainPanel )
	
	personalPanel:SetSize( 350, 150 )
	personalPanel:CenterX( )
	personalPanel:SetY( 30 )
	
	local personalTxt = loveframes.Create( 'text', personalPanel )
	
	personalTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	personalTxt:SetText( 'Your Name' )
	personalTxt:CenterX( )
	personalTxt:SetY( 7 )
	
	local nameInput = loveframes.Create( 'textinput', personalPanel )
	
	nameInput:SetWidth( 200 )
	nameInput:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	nameInput:CenterX( )
	nameInput:SetY( 30 )
	nameInput:SetText( settings.usershit[ 'Personal' ][ 'name' ] )
	nameInput.OnEnter = function( object, text )
		settings.usershit[ 'Personal' ][ 'name' ] = text or settings.usershit[ 'Personal' ][ 'name' ]
	end
	
	local overrideBF = loveframes.Create( 'multichoice', personalPanel )
    overrideBF:SetPos( 5, personalPanel:GetHeight( ) - overrideBF:GetHeight( ) - 5 )
	overrideBF:SetWidth( 130 )
	
	overrideBF:AddChoice( 'None' )
    overrideBF:AddChoice( 'bf_default' )
	overrideBF:AddChoice( 'bf_highspeed' )
	overrideBF:AddChoice( 'bf_xmas' )
	overrideBF:AddChoice( 'bf_pixelized' )
	
	overrideBF:SetChoice( ( settings.usershit[ 'Personal' ][ 'favBoyfriend' ] == 'none' and 'None' or settings.usershit[ 'Personal' ][ 'favBoyfriend' ] ) )
	overrideBF.OnChoiceSelected = function( object, choice )
		settings.usershit[ 'Personal' ][ 'favBoyfriend' ] = choice or 'none'
	end
	
	local overrideBFTxt = loveframes.Create( 'text', personalPanel )
	
	overrideBFTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	overrideBFTxt:SetText( 'Override BF' )
	overrideBFTxt:SetPos( overrideBF:GetWidth( ) / 2 - overrideBFTxt:GetWidth( ) / 2 + 5, personalPanel:GetHeight( ) - overrideBF:GetHeight( ) - overrideBFTxt:GetHeight( ) - 10 )
	
	local overrideGF = loveframes.Create( 'multichoice', personalPanel )
    overrideGF:SetPos( personalPanel:GetWidth( ) - overrideBF:GetWidth( ) - 5, personalPanel:GetHeight( ) - overrideGF:GetHeight( ) - 5 )
	overrideGF:SetWidth( 130 )
	overrideGF.Update = function( object, dt )
		-- yep, that's how you check to see if multichoice is open
		if object.haslist then
			shit = true
		else
			shit = false
		end
	end
	
	overrideGF:AddChoice( 'None' )
    overrideGF:AddChoice( 'gf_default' )
	overrideGF:AddChoice( 'gf_highspeed' )
	overrideGF:AddChoice( 'gf_xmas' )
	overrideGF:AddChoice( 'gf_pixelized' )
	
	overrideGF:SetChoice( ( settings.usershit[ 'Personal' ][ 'favGirlfriend' ] == 'none' and 'None' or settings.usershit[ 'Personal' ][ 'favGirlfriend' ] ) )
	overrideGF.OnChoiceSelected = function( object, choice )
		settings.usershit[ 'Personal' ][ 'favGirlfriend' ] = choice or 'none'
	end
	
	local overrideGFTxt = loveframes.Create( 'text', personalPanel )
	
	overrideGFTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	overrideGFTxt:SetText( 'Override GF' )
	overrideGFTxt:SetPos( personalPanel:GetWidth( ) - overrideBF:GetWidth( ) - 5 + overrideGF:GetWidth( ) / 2 - overrideGFTxt:GetWidth( ) / 2, personalPanel:GetHeight( ) - overrideGF:GetHeight( ) - overrideGFTxt:GetHeight( ) - 10 )
	
	--[[--------------------------------------------------------]]--
	
	local gameTxt = loveframes.Create( 'text', mainPanel )
	
	gameTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	gameTxt:SetText( 'Game' )
	gameTxt:CenterX( )
	gameTxt:SetY( 180 + 10 )
	
	local gamePanel = loveframes.Create( 'panel', mainPanel )
	
	gamePanel:SetSize( 350, 150 )
	gamePanel:CenterX( )
	gamePanel:SetY( mainPanel:GetHeight( ) - gamePanel:GetHeight( ) - 30 )
	
	local globalOffset = loveframes.Create( 'numberbox', gamePanel )
    globalOffset:SetX( 5 )
    globalOffset:SetSize( 70, 25 )
	globalOffset:SetValue( settings.usershit[ 'Game' ][ 'globalOffset' ] )
	globalOffset:SetMinMax( -1000, 1000 )
	globalOffset.OnValueChanged = function( object, value )
		settings.usershit[ 'Game' ][ 'globalOffset' ] = value or 0
	end
	
	local offsetTxt = loveframes.Create( 'text', gamePanel )
	
	offsetTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	offsetTxt:SetText( 'Offset' )
	offsetTxt:SetPos( overrideBF:GetWidth( ) / 2 - offsetTxt:GetWidth( ) / 2 + 5, 5 )
	
	globalOffset:SetPos( overrideBF:GetWidth( ) / 2 - globalOffset:GetWidth( ) / 2 + 5, offsetTxt:GetHeight( ) + 10 )
	
	local scrollSpeedTxt = loveframes.Create( 'text', gamePanel )
	
	scrollSpeedTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	scrollSpeedTxt:SetText( 'Scroll Spd.' )
	scrollSpeedTxt:SetY( 5 )
	scrollSpeedTxt:CenterX( )
	
	local scrollSpeed = loveframes.Create( 'numberbox', gamePanel )
    scrollSpeed:SetY( scrollSpeedTxt:GetHeight( ) + 10 )
    scrollSpeed:SetSize( 60, 25 )
	scrollSpeed:CenterX( )
	scrollSpeed:SetIncreaseAmount( 0.1 )
	scrollSpeed:SetDecreaseAmount( 0.1 )
	scrollSpeed:SetMinMax( 1, 10 )
	scrollSpeed:SetDecimals( 2 )
	scrollSpeed:SetValue( settings.usershit[ 'Game' ][ 'scrollSpeed' ] )
	scrollSpeed.OnValueChanged = function( object, value )
		settings.usershit[ 'Game' ][ 'scrollSpeed' ] = value or 0
	end
	
	local downscrollTxt = loveframes.Create( 'text', gamePanel )
	
	downscrollTxt:SetFont( love.graphics.newFont( 'data/fonts/vcr.ttf', 16, 'light' ) )
	downscrollTxt:SetText( 'Downscroll' )
	downscrollTxt:SetPos( personalPanel:GetWidth( ) - overrideBF:GetWidth( ) - 5 + overrideGF:GetWidth( ) / 2 - downscrollTxt:GetWidth( ) / 2, 5 )
	
	--[[--------------------------------------------------------]]--
	
	local animFrames = { }
	
	animFrames = assets.getFramesFromXML( 'checkboxanim', 'checkbox' )
	
	downscrollCheckmark[ 'Unchecked' ] = anim8.newAnimation( animFrames, 1 )
	downscrollCheckmark[ 'Unchecked' ].W, downscrollCheckmark[ 'Unchecked' ].H = animFrames.W, animFrames.H
	
	animFrames = assets.getFramesFromXML( 'checkboxanim', 'checkbox anim' )
	
	downscrollCheckmark[ 'Checking' ] = anim8.newAnimation( animFrames, 0.05 )
	downscrollCheckmark[ 'Checking' ].W, downscrollCheckmark[ 'Checking' ].H = animFrames.W, animFrames.H
	downscrollCheckmark[ 'Checking' ].onLoop = function( ) downscrollCheckmark.curAnim = 'Checked' end
	
	animFrames = assets.getFramesFromXML( 'checkboxanim', 'checkbox finish' )
	
	downscrollCheckmark[ 'Checked' ] = anim8.newAnimation( animFrames, 1 )
	downscrollCheckmark[ 'Checked' ].W, downscrollCheckmark[ 'Checked' ].H = animFrames.W, animFrames.H
	
	animFrames = assets.getFramesFromXML( 'checkboxanim', 'checkbox anim reverse' )
	
	downscrollCheckmark[ 'Unchecking' ] = anim8.newAnimation( animFrames, 0.05 )
	downscrollCheckmark[ 'Unchecking' ].W, downscrollCheckmark[ 'Unchecking' ].H = animFrames.W, animFrames.H
	downscrollCheckmark[ 'Unchecking' ].onLoop = function( ) downscrollCheckmark.curAnim = 'Unchecked' end
	
	downscrollCheckmark.ticked = false
	downscrollCheckmark.curAnim = ( settings.usershit[ 'Game' ][ 'downScroll' ] and 'Checked' or 'Unchecked' )
	downscrollCheckmark.active = ( settings.usershit[ 'Game' ][ 'downScroll' ] and true or false )
	downscrollCheckmark.visible = true
	
	--[[--------------------------------------------------------]]--
	
	local inputBtn = loveframes.Create( 'button', gamePanel )
    inputBtn:SetSize( 200, 50 )
    inputBtn:SetText( 'Change Input' )
    inputBtn:CenterX( )
	inputBtn:SetY( gamePanel:GetHeight( ) - inputBtn:GetHeight( ) - 5 )
	
	local animFrames = { }
	noteSprites = { }
	
	animFrames = assets.getFramesFromXML( 'NOTE_assets', 'purple' )
	noteSprites.left = anim8.newAnimation( animFrames, 1 )
	noteSprites.left.W, noteSprites.left.H = animFrames.W, animFrames.H
	noteSprites.left.visible = true
	
	animFrames = assets.getFramesFromXML( 'NOTE_assets', 'blue' )
	noteSprites.down = anim8.newAnimation( animFrames, 1 )
	noteSprites.down.W, noteSprites.down.H = animFrames.W, animFrames.H
	noteSprites.down.visible = true
	
	animFrames = assets.getFramesFromXML( 'NOTE_assets', 'green' )
	noteSprites.up = anim8.newAnimation( animFrames, 1 )
	noteSprites.up.W, noteSprites.up.H = animFrames.W, animFrames.H
	noteSprites.up.visible = true
	
	animFrames = assets.getFramesFromXML( 'NOTE_assets', 'red' )
	noteSprites.right = anim8.newAnimation( animFrames, 1 )
	noteSprites.right.W, noteSprites.right.H = animFrames.W, animFrames.H
	noteSprites.right.visible = true
	
	-- update visibility of arrows whenever you click them
	Timer.every( 0.2,
		function( )
			if settings.replacingKey[ 1 ] then noteSprites.left.visible = not noteSprites.left.visible end
			if settings.replacingKey[ 2 ] then noteSprites.down.visible = not noteSprites.down.visible end
			if settings.replacingKey[ 3 ] then noteSprites.up.visible = not noteSprites.up.visible end
			if settings.replacingKey[ 4 ] then noteSprites.right.visible = not noteSprites.right.visible end
		end
	)
	
    inputBtn.OnClick = function( object, x, y )
	
        settings.inputScreen = loveframes.Create( 'frame' )
		settings.inputScreen:SetName( 'Change Input' )
		settings.inputScreen:SetSize( 300, 400 )
		settings.inputScreen:CenterWithinArea( 0, 0, love.graphics.getDimensions( ) )
		settings.inputScreen:SetDraggable( false )
		settings.inputScreen:SetDockable( false )
		settings.inputScreen:ShowCloseButton( true )
		settings.inputScreen.OnClose = function( object )
			settings.inputScreen = nil
		end
		
		-- add stuff inside modal and only THEN set it as a modal window
		-- why? they don't show up otherwise or some shit, don't quite remember
		
		local resetExit = loveframes.Create( 'button', settings.inputScreen )
		resetExit:SetSize( 200, 40 )
		resetExit:SetText( 'Reset and Exit' )
		resetExit:CenterX( )
		resetExit:SetY( settings.inputScreen:GetHeight( ) - resetExit:GetHeight( ) - 5 )
		resetExit.OnClick = function( )
			print( 'Reset and exit.' )
			
			settings.usershit[ 'Keys' ][ 'leftArrow' ] = 'left'
			settings.usershit[ 'Keys' ][ 'downArrow' ] = 'down'
			settings.usershit[ 'Keys' ][ 'upArrow' ] = 'up'
			settings.usershit[ 'Keys' ][ 'rightArrow' ] = 'right'
			
			settings.inputScreen:Remove( )
			settings.inputScreen = nil
		end
		
		local saveExit = loveframes.Create( 'button', settings.inputScreen )
		saveExit:SetSize( 200, 40 )
		saveExit:SetText( 'Save and Exit' )
		saveExit:CenterX( )
		saveExit:SetY( settings.inputScreen:GetHeight( ) - resetExit:GetHeight( ) - 5 - saveExit:GetHeight( ) - 5 )
		saveExit.OnClick = function( )
			print( 'Save and exit.' )
			
			settings.inputScreen:Remove( )
			settings.inputScreen = nil
		end
		
		--[[--------------------------------------------------------]]--
		
		settings.inputScreen:SetModal( true )
    end
	
	--[[--------------------------------------------------------]]--
	
	piss = Text.new('center',
	{
		color = { 0.3, 0.3, 0.3, 1 },
		shadow_color = { 0.1, 0.1, 0.1, 0.4 },
		font = assets.fonts[ 'vcr' ],
		character_sound = false,
		print_speed = 0.01,
	})
	
	piss:send( '< Press any button to replace, ESC to abort >' )
	
	settings.active = true
end

function settings:update( dt )
	if not settings.active then return end
	
	Timer.update( dt )
	loveframes.update( dt )
	piss:update( dt )
	
	downscrollCheckmark[ downscrollCheckmark.curAnim ]:update( dt )
	downscrollCheckmark.visible = not shit
end

function settings:leave( next, ... )
	settings.active = false
end

function settings:draw( )
	if not settings.active then return end
	
	-- menu background
	love.graphics.draw( assets.images[ 'menuBGBlue' ], ( curr_width / 2 ), ( curr_height / 2 ), 0, 1, 1, assets.images[ 'menuBGBlue' ]:getWidth( ) / 2, assets.images[ 'menuBGBlue' ]:getHeight( ) / 2 )
	
	loveframes.draw()
	
	--[[--------------------------------------------------------]]--
	
	if downscrollCheckmark.visible and settings.inputScreen == nil then
		love.graphics.push( )
		
		love.graphics.scale( 0.2 )
		
		-- general offsetting
		local anim = downscrollCheckmark.curAnim
		
		if
			anim == 'Checking' then love.graphics.translate( -37, -25 )
		elseif
			anim == 'Unchecking' then love.graphics.translate( -27, -30 )
		elseif
			anim == 'Checked' then love.graphics.translate( 0, -15 )
		end
		
		downscrollCheckmark[ downscrollCheckmark.curAnim ]:draw(
			assets.images[ 'checkboxanim' ],
			490 / 0.2,
			347 / 0.2
		)
		
		love.graphics.pop( )
	end
	
	if settings.inputScreen ~= nil then
		love.graphics.push( )
		
		love.graphics.scale( 0.5 )
		
		if noteSprites.up.visible then
			noteSprites.up:draw(
				assets.images[ 'NOTE_assets' ],
				curr_width / 2 / 0.5 - noteSprites.up.W / 2,
				curr_height / 2 / 0.5 - noteSprites.up.H / 2 - noteSprites.up.H * 1.5
			)
		end
		
		if noteSprites.left.visible then
			noteSprites.left:draw(
				assets.images[ 'NOTE_assets' ],
				curr_width / 2 / 0.5 - noteSprites.left.W / 2 - noteSprites.left.W,
				curr_height / 2 / 0.5 - noteSprites.left.H / 2 - noteSprites.left.H * 1.7 + noteSprites.left.H
			)
		end
		
		if noteSprites.right.visible then
			noteSprites.right:draw(
				assets.images[ 'NOTE_assets' ],
				curr_width / 2 / 0.5 + noteSprites.right.W / 2,
				curr_height / 2 / 0.5 - noteSprites.right.H / 2 - noteSprites.right.H * 1.7 + noteSprites.right.H
			)
		end
		
		if noteSprites.down.visible then
			noteSprites.down:draw(
				assets.images[ 'NOTE_assets' ],
				curr_width / 2 / 0.5 - noteSprites.down.W / 2,
				curr_height / 2 / 0.5 - noteSprites.down.H / 2 - noteSprites.up.H * 1.5 + noteSprites.up.H * 1.5
			)
		end
		
		love.graphics.pop( )
		
		love.graphics.setFont( assets.fonts[ 'Dapa' ] )
		
		love.graphics.push( )
		
		love.graphics.scale( 0.15 )
		
		-- up arrow key
		if noteSprites.up.visible then
			outlinedText(
				settings.usershit[ 'Keys' ][ 'upArrow' ],
				curr_width / 2 / 0.15 - love.graphics.getFont( ):getWidth( settings.usershit[ 'Keys' ][ 'upArrow' ] ) / 2,
				curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) * 2 - love.graphics.getFont( ):getHeight( ) * 1.7,
				{ 0.85, 0.85, 0.85, 1 },
				{ 0, 0, 0, 1 },
				20
			)
		end
		
		-- left arrow key
		if noteSprites.left.visible then
			outlinedText(
				settings.usershit[ 'Keys' ][ 'leftArrow' ],
				curr_width / 2 / 0.15 - noteSprites.left.W / 2 / 0.15 - love.graphics.getFont( ):getWidth( settings.usershit[ 'Keys' ][ 'leftArrow' ] ) / 2,
				curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) * 2,
				{ 0.85, 0.85, 0.85, 1 },
				{ 0, 0, 0, 1 },
				20
			)
		end
		
		-- down arrow key
		if noteSprites.down.visible then
			outlinedText(
				settings.usershit[ 'Keys' ][ 'downArrow' ],
				curr_width / 2 / 0.15 - love.graphics.getFont( ):getWidth( settings.usershit[ 'Keys' ][ 'downArrow' ] ) / 2,
				curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) / 2,
				{ 0.85, 0.85, 0.85, 1 },
				{ 0, 0, 0, 1 },
				20
			)
		end
		
		-- right arrow key
		if noteSprites.right.visible then
			outlinedText(
				settings.usershit[ 'Keys' ][ 'rightArrow' ],
				curr_width / 2 / 0.15 + noteSprites.right.W / 2 / 0.15 - love.graphics.getFont( ):getWidth( settings.usershit[ 'Keys' ][ 'rightArrow' ] ) / 2,
				curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) * 2,
				{ 0.85, 0.85, 0.85, 1 },
				{ 0, 0, 0, 1 },
				20
			)
		end
		
		love.graphics.pop( )
		
		--[[--------------------------------------------------------]]--
		
		if table.contains( settings.replacingKey, true ) then
			love.graphics.push( )
		
			love.graphics.scale( 0.055 )
			
			piss:draw( curr_width / 2 / 0.055 - piss.get.width / 2, curr_height / 2 / 0.055 + piss.get.height / 2 / 0.08 )
			
			love.graphics.pop( )
		end
	end
	
	--[[--------------------------------------------------------]]--
	
	love.graphics.push( )
	
	love.graphics.scale( 0.08 )
	
	love.graphics.setFont( assets.fonts[ 'vcr' ] )
	
	-- information about the engine
	outlinedText( 'Funkin\' ( 0.1b BETA ) with Löve2D ( 11.4 )', 5 / 0.08, curr_height / 0.08 - love.graphics.getFont( ):getHeight( ) - 5 )
	
	love.graphics.pop( )
end

function settings:mousepressed( x, y, button )
	if not settings.active then return end
	
    loveframes.mousepressed( x, y, button )
	
	-- downscroll checkmark click test
	
	if downscrollCheckmark.visible
	and settings.inputScreen == nil
	and x >= 490 and x <= 490 + downscrollCheckmark[ downscrollCheckmark.curAnim ].W * 0.2
	and y >= 347 and y <= 347 + downscrollCheckmark[ downscrollCheckmark.curAnim ].H * 0.2 then
		print( 'Checkbox was clicked' )
		
		downscrollCheckmark.active = not downscrollCheckmark.active
		downscrollCheckmark.curAnim = ( downscrollCheckmark.active and 'Checking' or 'Unchecking' )
		
		-- make sure animations play from the first frame so they don't look weird
		downscrollCheckmark[ downscrollCheckmark.curAnim ]:gotoFrame( 1 )
		
		settings.usershit[ 'Game' ][ 'downScroll' ] = downscrollCheckmark.active 
	end
	
	-- replace key for arrow click test
	
	if settings.inputScreen ~= nil then
		-- left arrow
		if
			x >= curr_width / 2 - noteSprites.left.W / 2 * 0.5 - noteSprites.left.W * 0.5
		and
			x <= curr_width / 2 - noteSprites.left.W / 2 * 0.5 - noteSprites.left.W * 0.5 + noteSprites.left.W * 0.5
		and
			y >= curr_height / 2 - noteSprites.left.H * 0.5 * 1.7 + noteSprites.left.H / 2 * 0.5
		and
			y <= curr_height / 2 - noteSprites.left.H * 0.5 * 1.7 + noteSprites.left.H / 2 * 0.5 + noteSprites.left.H * 0.5
		then
			settings.replacingKey[ 1 ] = not settings.replacingKey[ 1 ]
			
			-- make sure visibility comes back when clicking again
			if not settings.replacingKey[ 1 ] then noteSprites.left.visible = true end
			
			for index = 1, #settings.replacingKey do
				if index ~= 1 then settings.replacingKey[ index ] = false end
			end
		
		-- down arrow
		elseif
			x >= curr_width / 2 - noteSprites.down.W / 2 * 0.5
		and
			x <= curr_width / 2 - noteSprites.down.W / 2 * 0.5 + noteSprites.down.W * 0.5
		and
			y >= curr_height / 2 - noteSprites.down.H / 2 * 0.5 - noteSprites.up.H * 1.5 + noteSprites.up.H * 1.5
		and
			y <= curr_height / 2 - noteSprites.down.H / 2 * 0.5 - noteSprites.up.H * 1.5 + noteSprites.up.H * 1.5 + noteSprites.down.H * 0.5
		then
			settings.replacingKey[ 2 ] = not settings.replacingKey[ 2 ]
			
			if not settings.replacingKey[ 2 ] then noteSprites.down.visible = true end
			
			-- reset all other keys as a fail safe
			for index = 1, #settings.replacingKey do
				if index ~= 2 then settings.replacingKey[ index ] = false end
			end
		
		-- up arrow
		elseif
			x >= curr_width / 2 - noteSprites.up.W / 2 * 0.5
		and
			x <= curr_width / 2 - noteSprites.up.W / 2 * 0.5 + noteSprites.up.W * 0.5
		and
			y >= curr_height / 2 - noteSprites.up.H / 2 * 0.5 - noteSprites.up.H * 1.5 * 0.5
		and
			y <= curr_height / 2 - noteSprites.up.H / 2 * 0.5 - noteSprites.up.H * 1.5 * 0.5 + noteSprites.up.H * 0.5
		then
			settings.replacingKey[ 3 ] = not settings.replacingKey[ 3 ]
			
			if not settings.replacingKey[ 3 ] then noteSprites.up.visible = true end
			
			for index = 1, #settings.replacingKey do
				if index ~= 3 then settings.replacingKey[ index ] = false end
			end
		
		-- right arrow
		elseif
			x >= curr_width / 2 + noteSprites.right.W / 2 * 0.5
		and
			x <= curr_width / 2 + noteSprites.right.W / 2 * 0.5 + noteSprites.right.W * 0.5
		and
			y >= curr_height / 2 - noteSprites.right.H * 0.5 * 1.7 + noteSprites.right.H / 2 * 0.5
		and
			y <= curr_height / 2 - noteSprites.right.H * 0.5 * 1.7 + noteSprites.right.H / 2 * 0.5 + noteSprites.right.H * 0.5
		then
			settings.replacingKey[ 4 ] = not settings.replacingKey[ 4 ]
			
			if not settings.replacingKey[ 4 ] then noteSprites.right.visible = true end
			
			for index = 1, #settings.replacingKey do
				if index ~= 4 then settings.replacingKey[ index ] = false end
			end
		end
	end
end

function settings:mousereleased( x, y, button )
	if not settings.active then return end
	
    loveframes.mousereleased( x, y, button )
end

function settings:keypressed( key, scancode, isrepeat )
	
	if not settings.active then return end
	
	-- cancel key replacement
	if key == 'escape' and table.contains( settings.replacingKey, true ) then
	
		for index = 1, #settings.replacingKey do
			settings.replacingKey[ index ] = false
		end
		
		noteSprites.left.visible = true
		noteSprites.down.visible = true
		noteSprites.up.visible = true
		noteSprites.right.visible = true
	elseif key == 'escape' and not table.contains( settings.replacingKey, true ) then
		
		assets.sounds[ 'cancelMenu' ]:play( )
		
		Timer.after( 1,
			function( )
				-- had to redo what preparing or else the shit can't save properly
				local usershit = { }
				usershit.Personal = { }
				usershit.Game = { }
				usershit.Keys = { }
				
				usershit.Personal.name = settings.usershit[ 'Personal' ][ 'name' ]
				usershit.Personal.favDifficulty = settings.usershit[ 'Personal' ][ 'favDifficulty' ]
				usershit.Personal.favBoyfriend = settings.usershit[ 'Personal' ][ 'favBoyfriend' ]
				usershit.Personal.favGirlfriend = settings.usershit[ 'Personal' ][ 'favGirlfriend' ]
				
				usershit.Game.globalOffset = settings.usershit[ 'Game' ][ 'globalOffset' ]
				usershit.Game.scrollSpeed = settings.usershit[ 'Game' ][ 'scrollSpeed' ]
				usershit.Game.downScroll = settings.usershit[ 'Game' ][ 'downScroll' ]
				
				usershit.Keys.leftArrow = settings.usershit[ 'Keys' ][ 'leftArrow' ]
				usershit.Keys.upArrow = settings.usershit[ 'Keys' ][ 'upArrow' ]
				usershit.Keys.downArrow = settings.usershit[ 'Keys' ][ 'downArrow' ]
				usershit.Keys.rightArrow = settings.usershit[ 'Keys' ][ 'rightArrow' ]
				
				inifile.save( 'userconf.ini', usershit )
				
				-- recreate it, because it's easier
				screens[ 'menu' ] = { }
				screens[ 'menu' ] = require( 'core.screens.MainMenu' )
				
				roomy:enter( screens[ 'menu' ] )
			end
		)
		
	end
	
	-- check if key is an alphanumeric character (only A-z, and 0-9) and if there's any keys
	-- being replaced
	if key:gsub( '%W', '' ) and table.contains( settings.replacingKey, true ) then
		
		local poop
		
		for index = 1, #settings.replacingKey do
			if settings.replacingKey[ index ] then
				if index == 1 then poop = 'left' break
				elseif index == 2 then poop = 'down' break
				elseif index == 3 then poop = 'up' break
				elseif index == 4 then poop = 'right' break
				else poop = 'left' break end
			end
		end
		
		settings.usershit[ 'Keys' ][ poop .. 'Arrow' ] = key
		
		print( settings.usershit[ 'Keys' ][ poop .. 'Arrow' ] )
		
		-- turn this shit into a function, seriously
		for index = 1, #settings.replacingKey do
			settings.replacingKey[ index ] = false
		end
		
		noteSprites.left.visible = true
		noteSprites.down.visible = true
		noteSprites.up.visible = true
		noteSprites.right.visible = true
	end
	
	loveframes.keypressed( key, isrepeat )
end

function settings:keyreleased( key )
	if not settings.active then return end
	
    loveframes.keyreleased( key )
end

function settings:textinput( text )
	if not settings.active then return end
	
    loveframes.textinput( text )
end

return settings