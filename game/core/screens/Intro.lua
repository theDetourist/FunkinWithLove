local intro = { }
intro.active = false

local introCanvas, pressStartCanvas = love.graphics.newCanvas( ), love.graphics.newCanvas( )

local pressedStart = false
local setForTransition = false

local cringyIntros = {
	'shoutouts to tom fulp[newline][waitforinput]lmao',
	'Ludum dare[newline][waitforinput]extraordinaire',
	'cyberzone[newline][waitforinput]coming soon',
	'love to thriftman[newline][waitforinput]swag',
	'ultimate rhythm gaming[newline][waitforinput]probably',
	'dope ass game[newline][waitforinput]playstation magazine',
	'in loving memory of[newline][waitforinput]henryeyes',
	'dancin[newline][waitforinput]forever',
	'funkin[newline][waitforinput]forever',
	'ritz dx[newline][waitforinput]rest in peace lol',
	'rate five[newline][waitforinput]pls no blam',
	'rhythm gaming[newline][waitforinput]ultimate',
	'game of the year[newline][waitforinput]forever',
	'you already know[newline][waitforinput]we really out here',
	'rise and grind[newline][waitforinput]love to luis',
	'like parappa[newline][waitforinput]but cooler',
	'album of the year[newline][waitforinput]chuckie finster',
	'free gitaroo man[newline][waitforinput]with love to wandaboy',
	'better than geometry dash[newline][waitforinput]fight me robtop',
	'kiddbrute for president[newline][waitforinput]vote now',
	'play dead estate[newline][waitforinput]on newgrounds',
	'this is a god damn prototype[newline][waitforinput]we workin on it okay',
	'women are real[newline][waitforinput]this is official',
	'too over exposed[newline][waitforinput]newgrounds cant handle us',
	'Hatsune Miku[newline][waitforinput]biggest inspiration',
	'too many people[newline][waitforinput]my head hurts',
	'newgrounds[newline][waitforinput]forever',
	'refined taste in music[newline][waitforinput]if i say so myself',
	'his name isnt keith[newline][waitforinput]dumb eggy lol',
	'his name isnt evan[newline][waitforinput]silly tiktok',
	'stream chuckie finster[newline][waitforinput]on spotify',
	'never forget to[newline][waitforinput]pray to god',
	'dont play rust[newline][waitforinput]we only funkin',
	'good bye[newline][waitforinput]my penis',
	'dababy[newline][waitforinput]biggest inspiration',
	'fashionably late[newline][waitforinput]but here it is',
	'yooooooooooo[newline][waitforinput]yooooooooo',
	'pico funny[newline][waitforinput]pico funny',
	'updates each friday[newline][waitforinput]on time every time',
	'shoutouts to mason[newline][waitforinput]for da homies',
	'bonk[newline][waitforinput]get in the discord call'
}

local introTxt, startTxt

-- current beat handler for this scene
local beatHandler
local beatz = 0

-- love logo
local loveData = { false, assets.images[ 'love' ], alpha = 1 }
local stressedData = {
	false,
	Emoji = { scale = 0.15, image = assets.images[ 'Stressed_Emoji' ] },
	Hands = { scale = 0.15, alpha = 0, image = assets.images[ 'cmere' ] }
}

local logoData = { scale = 0.5 }

function intro:enter( previous, ... )
	Conductor.bpm = 155
	
	assets.songs[ 'endless_inst' ]:setLooping( true )
	assets.songs[ 'endless_inst' ]:play( )
	assets.songs[ 'endless_voices' ]:setLooping( true )
	assets.songs[ 'endless_voices' ]:play( )
	
	introTxt = Text.new('center',
	{
		color = { 1, 1, 1, 1 },
		shadow_color = { 0.5, 0.5, 1, 0.4 },
		font = assets.fonts[ 'vcr' ],
		character_sound = false,
		print_speed = 0.01,
	})
	introTxt.y = ( ( curr_height / 2 / 0.1 ) - introTxt.get.height / 2 )
	
	introTxt:send(  ' ' )
	
	startTxt = Text.new('center',
	{
		color = { 1, 1, 1, 1 },
		shadow_color = { 0.5, 0.5, 1, 0.4 },
		font = assets.fonts[ 'vcr' ],
		character_sound = false,
		print_speed = 0.01,
	})
	
	startTxt:send( '[skip][bounce]< Press Space or Enter to Start >[/bounce]' )
	
	--[[---------------------------------------------------]]--
	
	intro.active = true
	Event.hook( Conductor, { 'beatHit' } )
end

function intro:update( dt )
	
	if not intro.active then return end
	
	--[[---------------------------------------------------]]--
	
	-- make sure both the instrumental and voice track are synced
	assets.songs[ 'endless_voices' ]:seek( assets.songs[ 'endless_inst' ]:tell( ) )
	
	-- update the conductor
	Conductor.songPos = ( assets.songs[ 'endless_inst' ]:tell( ) * 1000 )
	Conductor:update( dt )
	
	--[[---------------------------------------------------]]--
	
	Timer.update( dt )
	flux.update( dt )
	
	introTxt:update( dt )
	startTxt:update( dt )
	
	--[[---------------------------------------------------]]--
	
	-- canvas sorting
	if not pressedStart then
	
		introCanvas:renderTo(
		
			function( )
			
				--[[---------------------------------------------------]]--
				
				love.graphics.clear( )
				
				love.graphics.push( )
				
				love.graphics.scale( 0.1 )
				
				introTxt:draw( ( curr_width / 2 / 0.1 ) - introTxt.get.width / 2, introTxt.y )
				
				love.graphics.pop( )
				
				--[[---------------------------------------------------]]--
				
				if loveData[ 1 ] == 1 then
				
					love.graphics.push( )
					
					love.graphics.scale( stressedData.Emoji.scale )
					
					local emoWidth, emoHeight = stressedData.Emoji.image:getDimensions( )
					
					love.graphics.draw( stressedData.Emoji.image, curr_width / 2 / stressedData.Emoji.scale - emoWidth / 2 + 20, curr_height / 2 / stressedData.Emoji.scale - emoHeight / 2 - 15 )
					
					love.graphics.pop( )
					
					--[[--------------------------------]]--
					
					love.graphics.push( )
					
					love.graphics.scale( stressedData.Hands.scale )
					
					local handWidth, handHeight = stressedData.Hands.image:getDimensions( )
					
					-- for tweening it away
					love.graphics.setColor( 1, 1, 1, stressedData.Hands.alpha )
					
					love.graphics.draw( stressedData.Hands.image, curr_width / 2 / stressedData.Hands.scale - handWidth / 2 + 20, curr_height / 2 / stressedData.Hands.scale - handHeight / 2 )
					
					love.graphics.setColor( 1, 1, 1, 1 )
					
					love.graphics.pop( )
					
					--[[--------------------------------]]--
					
					love.graphics.push( )
					
					love.graphics.scale( 0.65 )
				
					local width, height = loveData[ 2 ]:getDimensions( )
					
					love.graphics.setColor( 1, 1, 1, loveData.alpha )
					
					love.graphics.draw( loveData[ 2 ], curr_width / 2 / 0.65 - width / 2 + 15, curr_height / 2 / 0.65 - height / 2 )
					
					love.graphics.setColor( 1, 1, 1, 1 )
					
					love.graphics.pop( )
					
				end
			end
			
		)
		
	else
	
		pressStartCanvas:renderTo(
		
			function( )
			
				--[[---------------------------------------------------]]--
				
				love.graphics.clear( )
				
				love.graphics.push( )
				
				love.graphics.scale( logoData.scale )
				
				love.graphics.draw( assets.images[ 'logo' ], ( curr_width / 2 / logoData.scale ) - assets.images[ 'logo' ]:getWidth( ) / 2, 130 / logoData.scale - assets.images[ 'logo' ]:getHeight( ) / 2 )
				
				love.graphics.pop( )
				
				--[[---------------------------------------------------]]--
				
				love.graphics.push( )
				
				love.graphics.scale( 0.1 )
				
				startTxt:draw( ( curr_width / 2 / 0.1 ) - startTxt.get.width / 2, ( curr_height / 0.1 ) - startTxt.get.height * 1.5 )
				
				love.graphics.pop( )
			
			end
			
		)
	
	end
	
	--[[---------------------------------------------------]]--
end

function intro:leave( next, ... )
	intro.active = false
end

function intro:draw( )
	if not intro.active then return end
	
	if not pressedStart then
		love.graphics.draw( introCanvas )
	else
		love.graphics.draw( pressStartCanvas )
	end
	
end

--[[-------------------------------------------------------------]]--

function intro:keypressed( key, scancode, isrepeat )
	
	if not intro.active then return end
	
	if ( key == 'return' or key == 'space' or key == 'kpenter' ) and not pressedStart then
		
		pressedStart = true
		
	elseif ( key == 'return' or key == 'space' or key == 'kpenter' ) and pressedStart and not setForTransition then
		
		setForTransition = true
		startTxt:send( '[skip][bounce][color=#ebc034][blink=15]< Press Space or Enter to Start >[/blink][/color][/bounce]' )
		assets.sounds[ 'confirmMenu' ]:play( )
		
		Timer.after( 1,
			function( )
			
				roomy:enter( screens[ 'menu' ] )
				
			end
		)
	
	end
	
end

--[[-------------------------------------------------------------]]--

-- hook Conductor.beatHit

beatHandler = Event.on( 'beatHit',
	function( )
		if not intro.active then return end
		
		beatz = beatz + 1

		-- half tempo
		if beatz % 2 == 0 then
		
			if not pressedStart then
				
				if beatz == 2 then
				
					introTxt:send( '[shake=1.5][bounce=0.5][scale=1]' .. cringyIntros[ love.math.random( #cringyIntros ) ] .. '[/scale][/bounce][/shake]', 150 * 10000 )
					
				elseif beatz == 6 then
				
					introTxt:continue( )
					
				elseif beatz == 8 then
				
					introTxt:send( ' ' )
					
				elseif beatz == 10 then
					
					introTxt.y = introTxt.y - 1500
					loveData[ 1 ] = 1
					
					introTxt:send( '[shake=1.5][bounce=0.5][scale=1]' .. 'made with löve[newline][newline][newline][newline][newline][newline][newline][newline][newline][newline][newline][newline][newline][newline][waitforinput][color=#FF3030]and my suffering[/color]' .. '[/scale][/bounce][/shake]', 150 * 10000 )
					
				elseif beatz == 14 then
				
					introTxt:continue( )
					stressedData[ 1 ] = true
					Timer.tween( 0.5, loveData, { alpha = 0 }, 'in-out-quad' )
					Timer.tween( 1, stressedData.Emoji, { scale = 0.5 }, 'in-out-quad' )
					
					Timer.tween( 0.8, stressedData.Hands, { alpha = 1, scale = 0.9 }, 'in-out-quad' )
					
				elseif beatz == 16 then
					
					introTxt.y = introTxt.y + 1500
					loveData[ 1 ] = 0
					introTxt:send( ' ' )
				
				elseif beatz == 18 then
					introTxt:send( '[shake=1.5][bounce=0.5][scale=1]' .. cringyIntros[ love.math.random( #cringyIntros ) ] .. '[/scale][/bounce][/shake]', 150 * 10000 )
				
				elseif beatz == 22 then
				
					introTxt:continue( )
				
				elseif beatz == 24 then
				
					introTxt:send( ' ' )
				
				elseif beatz == 26 then
					
					introTxt:send( '[shake=1.5][bounce=0.5][scale=1]' .. 'new fnf update when?[newline][waitforinput]when it comes out' .. '[/scale][/bounce][/shake]', 150 * 10000 )
				
				elseif beatz == 30 then
					
					introTxt:continue( )
				
				elseif beatz == 32 then
				
					introTxt:send( ' ' )
				
				elseif beatz == 34 then
				
					pressedStart = true
					
				end
			else
				
				flux.to( logoData, 0.05, { scale = 0.7 } ):ease( 'cubicinout' ):after( logoData, 0.05, { scale = 0.5 } ):ease( 'cubicinout' )
				
			end
			
		end
		
	end
)

return intro