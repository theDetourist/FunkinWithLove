local roomy = require( 'libs.roomy' )
local Timer = require( 'libs.timer' )
local Text = require( 'libs.SYSL-Text.slog-text' )
local anim8 = require( 'libs.anim8' )
local Conductor = require( 'core.Conductor' )

-- necessary for roomy to work
local intro = { }

-- holds all assets loaded in the game as reference from main.lua
local assets = { }

-- holds all animated objects to update their animations later
-- ABSOLUTELY necessary to have them animate, if they're not in this
-- table, they'll just be a static image
local animatedSprites = { }

-- canvases for later use, not the same as what roomy does
local introShit = love.graphics.newCanvas()
local pressStart = love.graphics.newCanvas()

-- used to detect if player wants to hurry the fck up, if so, skip intro
local HURRYTHEFUCKUP = false -- he said calmly
local pressedStart = false

-- tween shit
--          started    r  g  b  a      tween
local logoData = { 0, {1, 1, 1, 0}, nil}
logoData.size = 0.5

-- ask and you'll get shot, swear to god
function getTrueCenterForDrawable( width, height )
	local ofx, ofy = width * .5, height * .5
	
	return ( ( curr_width - width ) / 2 ) + ofx, ( ( curr_height - height ) / 2 ) + ofy, ofx, ofy
end

--[[ -------------------------------------- ]] --

-- make these a table so they can hold more than one animation

-- so the way you animate these is you make a key with the name of the animation
-- like funkyGF[ 'Idle' ] and add the animation to it having a temporary variable
-- to hold the frames with getFramesFromXML, and then creating the animation
-- to the key you created like funkyGF[ 'Idle' ]
-- set the current anim to play with variable.curAnim = 'anim' like funkyGF.curAnim = 'Idle'

-- then, in love.draw or any other callback that draws stuff to the screen, use
-- variable[ variable.curAnim ]:draw( ), like funkyGF[ funkyGF.curAnim ]:draw( )

local funkyGF = { }

--[[ -------------------------------------- ]] --

-- cringy intro texts
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

function intro:enter( previous, ... )
	curr_width, curr_height = love.graphics.getDimensions()
	
	-- for debugging purposes... i think
	assets = select( 1, ... )
	
	--[[ -------------------------------------- ]] --
	
	-- holdup, did someone said something about getting freaky????
	Conductor.bpm = 155
	curSong = 'endless'
	
	-- play both because why not
	assets.songs[ curSong .. '_inst' ]:play( )
	assets.songs[ curSong .. '_voices' ]:play( )
	
	--[[ -------------------------------------- ]] --
	
	introText = Text.new('center',
	{
		color = {1, 1, 1, 1},
		shadow_color = {0.5, 0.5, 1, 0.4},
		font = assets.fonts['vcr'],
		character_sound = false,
		print_speed = 0.01,
	})
	
	introText:send(  ' ' )
	
	pressStartTxt = Text.new('center',
	{
		color = {1, 1, 1, 1},
		shadow_color = {0.5, 0.5, 1, 0.4},
		font = assets.fonts['vcr'],
		character_sound = false,
		print_speed = 0.01,
	})
	
	pressStartTxt:send( '[skip][bounce]< Press Space or Enter to Start >[/bounce]' )
	
	--[[ -------------------------------------- ]] --
	
	local animFrames = assets.getFramesFromXML( 'gfDanceTitle', 'gfDance' )
	
	funkyGF[ 'Idle' ] = anim8.newAnimation( animFrames, 0.05 )
	funkyGF.curAnim = 'Idle'
	funkyGF.frameWidth, funkyGF.frameHeight = animFrames.fW, animFrames.fH
	
	table.insert( animatedSprites, funkyGF )
end

function intro:update(dt)
	--[[ -------------------------------------- ]] --
	
	-- update library shit
	Timer.update(dt)
	
	-- update other animated stuff also
	introText:update(dt)
	pressStartTxt:update(dt)
	
	-- seems like pain, but it's necessary
	for index, anim in ipairs( animatedSprites ) do
		animatedSprites[ index ][ anim.curAnim ]:update( dt )
	end
	
	--[[ -------------------------------------- ]] --
	
	-- first, keep instrumental and voice track synced with each other
	-- based on the instrumental
	assets.songs[ curSong .. '_voices' ]:seek( assets.songs[ curSong .. '_inst' ]:tell( ) )
	
	-- then update conductor based on the instrumental as well
	Conductor.songPos = ( assets.songs[ curSong .. '_inst' ]:tell( ) + ( Conductor.offset / 1000 ) ) * 1000
	Conductor:update(dt)
	
	--[[ -------------------------------------- ]] --
	
	-- prepares canvases that will be used in a bit
	if not HURRYTHEFUCKUP then
		introShit:renderTo(
			function()
				-- damn right i'm doing that, fuck performance
				love.graphics.clear( )
				
				love.graphics.push( )
				
				love.graphics.scale( 0.1 )
				
				-- yep, take into account the scale when centering shit
				introText:draw( ( curr_width / 2 / 0.1 ) - introText.get.width / 2, ( curr_height / 2 / 0.1 ) - introText.get.height / 2 )
				
				love.graphics.pop( )
				
				if logoData[1] == 1 then
					local truex, _, offx, _ = getTrueCenterForDrawable( assets.images['logo']:getWidth( ), assets.images['logo']:getHeight( ) )
					
					love.graphics.push( )
					
					love.graphics.setColor( logoData[2] )
					love.graphics.draw( assets.images['logo'], truex, 0, 0, 0.5, 0.5, offx )
					
					love.graphics.pop( )
				end
			end
		)
	else
		pressStart:renderTo(
			function( )
				love.graphics.clear( )
				
				love.graphics.push( )
				
				-- fail safe in case player skipped the intro
				love.graphics.setColor( {1, 1, 1, 1} )
				
				-- this will also be animated so keep it like that
				love.graphics.scale( logoData.size )
				
				-- make sure to only call getTrueCenterForDrawable AFTER setting scale so
				-- it takes the current scale into account when calculating
				local truex, _, offx, _ = getTrueCenterForDrawable( assets.images['logo']:getWidth( ), assets.images['logo']:getHeight( ) )
				
				love.graphics.draw( assets.images[ 'logo' ], truex, 0, 0, logoData.size, logoData.size, offx )
				
				love.graphics.pop( )
				
				--[[ -------------------------------------- ]]
				
				love.graphics.push( )
				
				love.graphics.scale( 0.1 )
				
				pressStartTxt:draw( ( curr_width / 2 / 0.1 ) - pressStartTxt.get.width / 2, ( curr_height / 0.1 ) - pressStartTxt.get.height * 1.5 )
				
				love.graphics.pop( )
				
				--[[ -------------------------------------- ]]
				
				love.graphics.push( )
				
				love.graphics.scale( 0.3 )
				
				-- remember there's a drawable in this variable, not a string
				funkyGF[ funkyGF.curAnim ]:draw( assets.images[ 'gfDanceTitle' ], curr_width / 2 / 0.3 - funkyGF.frameWidth / 2, curr_height / 2 / 0.3 - funkyGF.frameHeight / 2 )
				
				love.graphics.pop( )
			end
		)
	end
end

function intro:leave(next, ...)
end

--[[
local sickBeatz = 0
function Conductor:beatHit( )
	sickBeatz = sickBeatz + 1
	
	-- half tempo, so 120 is treated like 60 here
	if sickBeatz % 2 == 0 then
		--assets.sounds['hitsound']:play( )
		
		if not HURRYTHEFUCKUP then
			if sickBeatz == 2 then
				introText:send( '[shake=1.5][bounce=0.5][scale=1]' .. cringyIntros[ love.math.random( #cringyIntros ) ] .. '[/scale][/bounce][/shake]', 150 * 10000 )
			elseif sickBeatz == 6 then
				introText:continue( )
			elseif sickBeatz == 8 then
				introText:send ( ' ' )
			elseif sickBeatz == 10 then
				introText:send( '[shake=1.5][bounce=0.5][scale=1]' .. 'new fnf update when?[newline][waitforinput]when it comes out' .. '[/scale][/bounce][/shake]', 150 * 10000 )
			elseif sickBeatz == 14 then
				introText:continue( )
			elseif sickBeatz == 16 then
				introText:send ( ' ' )
				logoData[1] = 1
				logoData[3] = Timer.tween( 3, logoData, { 1, {1, 1, 1, 1} }, 'in-out-sine',
					function( )
						-- let this canvas die, go to the next one
						HURRYTHEFUCKUP = true
					end
				)
			end
		else
			if logoData[3] ~= nil then
				-- if still running, stop first
				Timer.cancel(logoData[3])
				
				-- tween logo expanding
				logoData[3] = Timer.tween( 1, logoData, { size = 1 }, 'in-out-sine',
					alert( ' done ' )
				)
			end
		end
	end
end
--]]

function intro:keypressed(key)
    if key == 'kp+' then
		conductor.offset = conductor.offset + 1
	elseif key == 'kp-' then
		conductor.offset = conductor.offset - 1
	elseif key == 'space' or key == 'return' then
		if not HURRYTHEFUCKUP then HURRYTHEFUCKUP = true
		elseif HURRYTHEFUCKUP and not pressedStart then
			pressedStart = true
			pressStartTxt:send( '[skip][bounce][color=#ebc034][blink=15]< Press Space or Enter to Start >[/blink][/color][/bounce]' )
			assets.sounds[ 'confirmMenu' ]:play( )
		end
	end
end

function intro:draw()
	--love.graphics.print( 'Loaded ' .. assets.filecount .. ' assets in total.', 0, 0)
	--love.graphics.print( assets.images.filecount  .. ' images.', 0, 0 + 10 * 2)
	--love.graphics.print( assets.sounds.filecount  .. ' sounds.', 0, 0 + 10 * 4)
	--love.graphics.print( assets.songs.filecount  .. ' songs.', 0, 0 + 10 * 6)
	--love.graphics.print( assets.fonts.filecount  .. ' fonts.', 0, 0 + 10 * 8)
	
	--love.graphics.print( 'Actual pos: ' .. assets.songs['roses']:tell( 'seconds' ), 0, 0 + 10 * 10, 0, 0.1, 0.1 )
	--love.graphics.print( 'Fed pos: ' .. Conductor.songPos, 0, 0 + 10 * 12, 0, 0.1, 0.1 )
	--love.graphics.print( 'Beats: ' .. sickBeatz, 0, 0 + 10 * 14, 0, 0.1, 0.1 )
	--love.graphics.print( 'Offset: ' .. Conductor.offset, 0, 0 + 10 * 16, 0, 0.1, 0.1 )
	--love.graphics.print( 'BPM: ' .. Conductor.bpm, 0, 0 + 10 * 18, 0, 0.1, 0.1 )
	--love.graphics.print( 'FPS: ' .. love.timer.getFPS( ), 0, 0 + 10 * 20, 0, 0.1, 0.1 )
	
	if not HURRYTHEFUCKUP then
		love.graphics.draw( introShit )
	else
		love.graphics.draw( pressStart )
	end
end

return intro