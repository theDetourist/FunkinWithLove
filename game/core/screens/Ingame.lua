utf8 = require( 'utf8' )

roomy = require('libs.roomy')
Timer = require('libs.timer')
Text = require('libs.SYSL-Text.slog-text')
anim8 = require( 'libs.anim8' )
inifile = require( 'libs.inifile' )
deep = require( 'libs.deep' )
Camera = require( 'libs.camera' )

require( 'core.Song' ).new( )

--[[ -------------------------------------- ]] --

local ingame = { }

ingame.curSong = 'endless'
ingame.Stage = nil					-- will hold the stage assets and logic later
ingame.ready = false
ingame.paused = false
ingame.setForRestart = false		-- used to stop everything and prepare for hard reset
ingame.notesHit = 0
ingame.cam = Camera( 0, 0 )
ingame.cam.focus = { }
ingame.cam.focus.x ,ingame.cam.focus.y = curr_width / 2, curr_height / 2

-- gameplay shit
ingame.score = 0
ingame.health = 100


-- UI shit
ingame.UI = { }

Fonts = { }							-- needed since clove and sysl-text don't seem to like each other very much

--[[ -------------------------------------- ]] --

assets = { }

local vocalShit = nil
local instrumentalShit = nil

--[[ -------------------------------------- ]] --

local animatedSprites = { }

local playerArrows = { }
local opponentArrows = { }

-- universal for both
local leftArrow = { }
local downArrow = { }
local upArrow = { }
local rightArrow = { }

--[[ -------------------------------------- ]] --

function ingame:enter( previous, ... )
	assets = select( 1, ... )
	Note.assets = assets
	
	ingame.curSong = select( 2, ... ) or ingame.curSong
	
	--[[ -------------------------------------- ]] --
	
	curr_width, curr_height = love.graphics.getDimensions()
	
	--[[ -------------------------------------- ]] --
	
	Song.Conductor.bpm = 155
	
	Timer.after( 1,
		function( )
			assets.songs[ ingame.curSong .. '_inst' ]:play( )
			assets.songs[ ingame.curSong .. '_voices' ]:play( )
		end
	)
	
	--[[ -------------------------------------- ]] --
	
	-- setting up player's "strum" notes
	setupStrumArrows( )
	
	print( 'Player arrows width: ' .. playerArrows.width .. '\nOpponent arrows width: ' .. opponentArrows.width )
	
	-- should be four
	-- or should it... SrPerez???!!
	print( 'How many arrows: ' .. table.getn( playerArrows ) .. '\nFor opponent: ' .. table.getn( opponentArrows ) )
	
	--[[ -------------------------------------- ]] --
	
	-- preparing UI shit

	-- unlike what is said in the documentation for sysl-text
	-- you feed the table of fonts below, and only use the name
	-- of the font instead of the whole Fonts.fontname shit
	Text.configure.font_table( 'Fonts' )
	
	Fonts = {
		vcr = assets.fonts[ 'vcr' ],
		pixel = assets.fonts[ 'pixel' ],
		alamain = assets.fonts[ 'alamain1' ],
		beatstreet = assets.fonts[ 'beatstreet' ]
	}
	
	ingame.UI[ 'SessionShit' ] = Text.new('left',
	{
		color = {1, 1, 1, 0.5},
		shadow_color = {0.3, 0.3, 1, 0.8},
		font = Fonts.beatstreet,
		character_sound = false,
		print_speed = 0.01
	})
	
	ingame.UI[ 'SessionShit' ]:send(
		'[skip][dropshadow=2][shake=1.5][bounce=0.5]Score:[font=vcr][pad=-100][scale=0.6]' .. ingame.score .. '[/scale][/pad][/font][/bounce][/shake][/dropshadow]'
	)
	
	--[[ -------------------------------------- ]] --
	
	Song.Conductor.songPos = -5000
	
	local song = Song.loadFromJSON( assets.charts[ 'endless-hard' ] )
	
	-- TODO RQ TOO: make this shit down here mimic generateSong from
	-- og game, the saving of the notes in Note.lua format is already
	-- over with... hopefully
	makeMagic( song )
	
	ingame.Stage = require( 'data/stages/fuckery' )
	
	--[[ -------------------------------------- ]] --
end

function ingame:update(dt)
	if ingame.paused then return end
	
	-- update libraries
	Timer.update( dt )
	
	ingame.Stage.onUpdate( dt )
	
	-- move camera to point to current object or coordinate
	-- in focus
	local dx, dy = ingame.cam.focus.x - ingame.cam.x, ingame.cam.focus.y - ingame.cam.y
	ingame.cam:move( dx / 2, dy / 2 )
	
	--[[ -------------------------------------- ]] --
	
	-- seems like pain, but it's necessary
	
	for index, anim in pairs( animatedSprites ) do
		animatedSprites[ index ][ anim.curAnim ]:update( dt )
	end
	
	for index, text in pairs( ingame.UI ) do
		text:update( dt )
	end
	
	--[[ -------------------------------------- ]] --
	
	-- first, keep instrumental and voice track synced with each other
	-- based on the instrumental
	assets.songs[ ingame.curSong .. '_voices' ]:seek( assets.songs[ ingame.curSong .. '_inst' ]:tell( ) )
	
	-- then update conductor based on the instrumental as well
	if assets ~= nil then
		assets.songs[ ingame.curSong .. '_voices' ]:seek( assets.songs[ ingame.curSong .. '_inst' ]:tell( ) )
		
		-- then update conductor based on the instrumental as well
		Song.Conductor.songPos = ( assets.songs[ ingame.curSong .. '_inst' ]:tell( ) * 1000 )
		Song.Conductor:update( dt )
	end
	
	-- actual game logic, GO
	for index = 1, #Song.Notes do
		if ingame.setForRestart == false then
			-- check if they're null, if they are, skip this index
			if Song.Notes[ index ] ~= nil then
				
				-- cuz we lazy in here
				local lane = Song.Notes[ index ].Lane
				local susLength
				
				-- sort the notes properly for their respective sides
				if not Song.Notes[ index ].MustHit then
					Song.Notes[ index ].x = opponentArrows[ lane ].x - opponentArrows[ lane ].width
				else
					Song.Notes[ index ].x = playerArrows[ lane - 4 ].x - playerArrows[ lane - 4 ].width
				end
				
				-- light cpu strums up when "hitting" a note
				if
					Song.Notes[ index ].y > playerArrows.y / playerArrows.scale - playerArrows[ 1 ].height / 2
				and
					not Song.Notes[ index ].MustHit
				and
					not Song.Notes[ index ].WasHit
				then
					opponentArrows[ lane ].curAnim = 'Hit'
					Song.Notes[ index ].CanBeHit = false
					Song.Notes[ index ].WasHit = true
					Song.Notes[ index ].Visible = false
				end
				
				-- actual juicy meat of hitting notes
				if Song.Notes[ index ].MustHit then
					local time = Song.Notes[ index ].Time - Song.Conductor.offset
					
					if time > ( Song.Conductor.songPos - Song.Conductor.safeFramesOffset * 2 )
					and time < ( Song.Conductor.songPos + Song.Conductor.safeFramesOffset * 0.5 )
					then
						Song.Notes[ index ].CanBeHit = true
					else
						Song.Notes[ index ].CanBeHit = false
					end
				end
				
				-- up or down, you decide
				Song.Notes[ index ].y = playerArrows.y / playerArrows.scale + 0.45 * ( Song.Conductor.songPos - Song.Notes[ index ].Time ) * 2.5
			end
		else break
		end
	end
	
	--[[ -------------------------------------- ]] --
end

function ingame:leave(next, ...)
end

function ingame:draw()
	if ingame.paused then love.graphics.print("STOP THAT SHIT", curr_width / 2 - 50, curr_height / 2) return end
	
	love.graphics.setColor( 1, 0, 0 )
	
	-- center of the screen
	love.graphics.circle( 'fill', curr_width / 2, curr_height / 2, 1, 10)
	
	love.graphics.setColor( 1, 1, 1 )
	
	-- drawing the stage
	
	deep.queue( 0,
		function( )
			ingame.Stage.onDraw( )
		end
	)
	
	--[[ -------------------------------------- ]] --
	
	-- drawing UI stuff
	
	deep.queue( 9999,
		function( )
			love.graphics.push( )
	
			love.graphics.scale( 0.05 )

			love.graphics.setFont( Fonts.vcr )
			
			love.graphics.print( 'FPS: ' .. love.timer.getFPS( ), 0, 150 + 10 / 0.05, 0, 1, 1 )
			love.graphics.print( 'Position: ' .. Song.Conductor.songPos, 0, 150 + 30 / 0.05, 0, 1, 1 )
			love.graphics.print( 'Offset: ' .. Song.Conductor.offset, 0, 150 + 50 / 0.05, 0, 1, 1 )
			love.graphics.print( 'Hit: ' .. ingame.notesHit, 0, 150 + 70 / 0.05, 0, 1, 1 )
			
			love.graphics.pop( )
		end
	)
	
	--[[ -------------------------------------- ]] --
	
	for index, anim in ipairs( opponentArrows ) do
		if opponentArrows[ index ].curAnim == 'Hit' then opponentArrows[ index ].z = 150 else opponentArrows[ index ].z = 50 end
		
		deep.queue( opponentArrows[ index ].z,
			function( )
				love.graphics.push( )

				love.graphics.scale( playerArrows.scale )
				
				opponentArrows[ index ][ anim.curAnim ]:draw(
					assets.images[ 'NOTE_assets' ],
					opponentArrows[ index ].x - anim.width - ( anim.curAnim == 'Hit' and 40 or 0 ),
					opponentArrows[ index ].y / opponentArrows.scale - anim.height / 2 - ( anim.curAnim == 'Hit' and 40 or 0 )
				)
				
				love.graphics.pop( )
			end
		)
	end
	
	for index, anim in ipairs( playerArrows ) do
		if playerArrows[ index ].curAnim == 'Hit' then playerArrows[ index ].z = 150 else playerArrows[ index ].z = 50 end
		
		deep.queue( playerArrows[ index ].z,
			function( )
				love.graphics.push( )

				love.graphics.scale( playerArrows.scale )
				
				playerArrows[ index ][ anim.curAnim ]:draw(
					assets.images[ 'NOTE_assets' ],
					playerArrows[ index ].x - anim.width - ( anim.curAnim == 'Hit' and 40 or 0 ),
					playerArrows[ index ].y / playerArrows.scale - anim.height / 2 - ( anim.curAnim == 'Hit' and 40 or 0 )
				)
				
				love.graphics.pop( )
			end
		)
	end
	
	--[[ -------------------------------------- ]] --
	-- here we go
	
	deep.queue( 100,
		function( )
			love.graphics.push( )
			
			love.graphics.scale( playerArrows.scale )
			
			for index = 1, #Song.Notes do
				if ingame.setForRestart == false then
					-- check if they're null, if they are, skip this index
					if Song.Notes[ index ] ~= nil then
						
						-- only show arrows once they're on screen
						if Song.Notes[ index ].y > 0 and not Song.Notes[ index ].WasHit then
							Song.Notes[ index ].Visible = true
							Song.Notes[ index ].Sustain.Visible = true
						else
							Song.Notes[ index ].Visible = false
							Song.Notes[ index ].Sustain.Visible = false
						end
						
						if
							Song.Notes[ index ].y - Song.Notes[ index ].SustainTime - Song.Notes[ index ].height / 4
							<
							playerArrows.y / playerArrows.scale
						and
							Song.Notes[ index ].y > 0
						then
							Song.Notes[ index ].Sustain.Visible = true
						else
							Song.Notes[ index ].Sustain.Visible = false
						end
						
						-- draw rectangle around notes player can hit for debugging purposes
						
						--[[
						if Song.Notes[ index ].MustHit and Song.Notes[ index ].CanBeHit then
							love.graphics.setColor( 0, 1, 0, 0.3 )
					
							love.graphics.rectangle( 'fill', Song.Notes[ index ].x, Song.Notes[ index ].y, Song.Notes[ index ].width, Song.Notes[ index ].height )
						
							love.graphics.setColor( 1, 1, 1, 1 )
						end
						--]]
						
						if Song.Notes[ index ].SustainTime > 0 and Song.Notes[ index ].Sustain.Visible then
							love.graphics.push( )
							
							love.graphics.scale( 1, 50 )
							
							-- WHAT A MESS, which was the bottom, where's the top???
							-- clean up, CLEAN UPPP
							
							local topX, topY, height, HAHA = 0, 0, 0, playerArrows.scale
							
							topX = Song.Notes[ index ].x * HAHA
							topY = Song.Notes[ index ].y * HAHA - Song.Notes[ index ].SustainTime * HAHA
							width = playerArrows.width * HAHA
							height = Song.Notes[ index ].SustainTime * HAHA + Song.Notes[ index ].height / 2 * HAHA
							
							-- while scale y is 50, the sustain sprite will scroll down for a long time
							-- so we "clip" it to the note arrow sprite
							love.graphics.setScissor( topX, topY, curr_width * 50, height )
							
							-- then, if note is player's and player hit it, and the sustain is still visible
							-- since they'll be invisible and can't be hit anymore if you let go while they're
							-- still going; clip it to the strumline instead
							
							-- cpu gets to clip it everytime, obviously
							if
								Song.Notes[ index ].MustHit and Song.Notes[ index ].WasHit
							or
								not Song.Notes[ index ].MustHit
							then
								love.graphics.intersectScissor( 0, 0, curr_width * 50, playerArrows.y )
							end
							
							Song.Notes[ index ].Sustain.Animation:draw(
								assets.images[ 'NOTE_assets' ],
								Song.Notes[ index ].x + Song.Notes[ index ].Sustain.width,
								( Song.Notes[ index ].y / 50 ) - Song.Notes[ index ].SustainTime / 50
							)
							
							love.graphics.setScissor( )
							
							love.graphics.pop( )
							
							-- also clip the little end piece too
							if
								Song.Notes[ index ].MustHit and Song.Notes[ index ].WasHit
							or
								not Song.Notes[ index ].MustHit
							then
								love.graphics.setScissor( 0, 0, curr_width, playerArrows.y )
							end
							
							Song.Notes[ index ].Sustain.EndAnimation:draw(
								assets.images[ 'NOTE_assets' ],
								Song.Notes[ index ].x + Song.Notes[ index ].Sustain.width,
								( Song.Notes[ index ].y  ) - Song.Notes[ index ].SustainTime - Song.Notes[ index ].height / 4
							)
							
							love.graphics.setScissor( )
						end
						
						-- only draw the notes when they're on the screen
						if Song.Notes[ index ].Visible then
							Song.Notes[ index ].Animation:draw(
								assets.images[ 'NOTE_assets' ],
								Song.Notes[ index ].x,
								Song.Notes[ index ].y
							)
						end
					end
					
					::skipthisnote::
				-- stop everything so the game doesn't crash when restarting
				else break end
			end
			
			love.graphics.pop( )
		end
	)
	
	--[[ -------------------------------------- ]] --
	
	ingame.cam:attach( )
	
	deep.execute( )
	
	ingame.cam:detach( )
end

function ingame:keypressed( key, scancode, isrepeat )
	ingame.Stage.onKeyPress( key, isrepeat )
	
	-- HERE WE GO
	if ( key == 'a' or key == 's' or key == 'kp4' or key == 'kp5' ) and not isrepeat then
	
		-- hardcoded for now, change later, fool
		local keyz = { 'a', 's', 'kp4', 'kp5' }
		
		-- default to pressed animation when not hitting a note
		if key == 'a' then
			playerArrows[ 1 ].curAnim = 'Pressed'
			playerArrows[ 1 ][ 'Pressed' ]:gotoFrame( 1 )
			playerArrows[ 1 ][ 'Pressed' ]:resume( )
		elseif key == 's' then
			playerArrows[ 2 ].curAnim = 'Pressed'
			playerArrows[ 2 ][ 'Pressed' ]:gotoFrame( 1 )
			playerArrows[ 2 ][ 'Pressed' ]:resume( )
		elseif key == 'kp4' then
			playerArrows[ 3 ].curAnim = 'Pressed'
			playerArrows[ 3 ][ 'Pressed' ]:gotoFrame( 1 )
			playerArrows[ 3 ][ 'Pressed' ]:resume( )
		elseif key == 'kp5' then
			playerArrows[ 4 ].curAnim = 'Pressed'
			playerArrows[ 4 ][ 'Pressed' ]:gotoFrame( 1 )
			playerArrows[ 4 ][ 'Pressed' ]:resume( )
		end
		
		-- god knows how many times i rewrote this fucking shit
		-- it has to work at some point, right?
		local possibleHits = { }
		local fuckThisNote = { }
		
		-- in a single loop, which lanes have already been processed
		local processedLanes = { false, false, false, false }
		
		-- self explanatory, right?
		local hasHitAlready = { false, false, false, false }
		
		-- ipairs is VERY important here, it keeps the order
		-- of the notes so we can get rid of those shitty
		-- duplicated notes inside each other
		
		-- change that to Song.lua if possible in the future so we don't have
		-- to deal with this here
		for index, note in ipairs( Song.Notes ) do
			if note ~= nil and note.MustHit and note.CanBeHit and not note.WasHit then
				-- if the note is a must hit, then the indexes from
				-- now on are 5 and above, not very useful so we do this
				local trueLane = note.Lane - 4
				
				if keyz[ trueLane ] ~= nil and keyz[ trueLane ] == key then
					-- print( math.abs( note.Time ) )
					
					for idx = index + 1, #Song.Notes do
						if math.abs( note.Time - Song.Notes[ idx ].Time ) < 10 and note.Lane == Song.Notes[ idx ].Lane then
							table.insert( fuckThisNote, idx )
							print( 'Found note ' .. Song.Notes[ idx ].Time .. ' as a duplicate of ' .. note.Time .. '.' )
						end
					end
					
					if not table.contains( fuckThisNote, index ) then
						playerArrows[ trueLane ].curAnim = 'Hit'
						goodNoteHit( Song.Notes[ index ] )
					end
				end
			end
		end
		
		if fuckThisNote ~= nil and #fuckThisNote > 0 then
			for index = 1, #fuckThisNote do
				table.remove( Song.Notes, fuckThisNote[ index ] )
				print( 'Removing note ' .. Song.Notes[ index ].Time .. '.' )
			end
		end
		
	--[[ -------------------------------------- ]] --
    elseif key == 'kp+' then
		Song.Conductor.offset = Song.Conductor.offset + 1
	elseif key == 'kp-' then
		Song.Conductor.offset = Song.Conductor.offset - 1
	elseif key == 'f8' and ingame.setForRestart == false then
		ingame.setForRestart = true
		
		FUNISINFINITE( )
		
		local usershit = inifile.parse( 'userconf.ini' )
		usershit[ 'Game' ][ 'globalOffset' ] = Song.Conductor.offset
		
		inifile.save( 'userconf.ini', usershit )
		
		love.event.quit( 'restart' )
	elseif key == 'space' then
		ingame.paused = not ingame.paused
		
		-- shut the fuck up when paused
		if ingame.paused then
			assets.songs[ ingame.curSong .. '_inst' ]:pause( )
			assets.songs[ ingame.curSong .. '_voices' ]:pause( )
		else
			assets.songs[ ingame.curSong .. '_inst' ]:play( )
			assets.songs[ ingame.curSong .. '_voices' ]:play( )
		end
	end
end

function ingame:keyreleased( key )
	if key == 'a' or 's' or 'num4' or 'num5' then
		if key == 'a' then
			playerArrows[ 1 ].curAnim = 'Idle'
			
		elseif key == 's' then
			playerArrows[ 2 ].curAnim = 'Idle'
			
		elseif key == 'kp4' then
			playerArrows[ 3 ].curAnim = 'Idle'
			
		elseif key == 'kp5' then
			playerArrows[ 4 ].curAnim = 'Idle'
			
		end
	end
end

local sickBeatz = 0
function Song.Conductor:beatHit( )
	if sickBeatz % 2 == 0 then
		-- print( 'HEY' )
	end
	sickBeatz = sickBeatz + 1
end

--[[ -------------------------------------- ]] --

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- ask and you'll get shot, swear to god
function getTrueCenterForDrawable( width, height )
	local ofx, ofy = width * .5, height * .5
	
	return ( ( curr_width - width ) / 2 ) + ofx, ( ( curr_height - height ) / 2 ) + ofy, ofx, ofy
end

--[[ -------------------------------------- ]] --

function makeMagic( shit )
	if shit ~= nil then
		local usershit = inifile.parse( 'userconf.ini' )
		
		Song.Conductor.bpm = shit.BPM
		Song.Conductor.offset = usershit[ 'Game' ][ 'globalOffset' ]
		
		usershit = nil
		
		if shit.HasVoices then vocalShit = assets.songs[ ingame.curSong .. '_vocals' ] end
		instrumentalShit = assets.songs[ ingame.curSong .. '_voices' ]
		
		-- sort by closest to start of track
		table.sort( Song.Notes,
			function( a, b ) return a.Time < b.Time end
		)
		
		for index = 1, #Song.Notes do
			Song.Notes[ index ].Time = Song.Notes[ index ].Time + Song.Conductor.offset
		end
		
		ingame.ready = true
	else
		print( 'What the fuck, do you even have a valid song to generate?' )
	end
end

-- thank god this shit is only called once
function setupStrumArrows( )
	local animFrames = { }
	local defDuration = 0.05
	
	local arrowStates =
	{
		'arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT',
		'left press', 'down press', 'up press', 'right press',
		'left confirm', 'down confirm', 'up confirm', 'right confirm'
	}
	
	local idleDirs = { }
	local pressDirs = { }
	local confirmDirs = { }
	
	-- get frames for animations
	for index = 1, #arrowStates do
		if index < 5 then
			idleDirs[ index ] = assets.getFramesFromXML( 'NOTE_assets', arrowStates[ index ] )
			
			print( 'Idles : ' .. table.getn( idleDirs ), arrowStates[ index ] )
		elseif index > 4 and index < 9 then
			pressDirs[ index - 4 ] = assets.getFramesFromXML( 'NOTE_assets', arrowStates[ index ] )
			
			print( 'Presses : ' .. table.getn( pressDirs ), arrowStates[ index ] )
		elseif index > 8 and index < 13 then
			confirmDirs[ index - 8 ] = assets.getFramesFromXML( 'NOTE_assets', arrowStates[ index ] )
			
			print( 'Hits : ' .. table.getn( confirmDirs ), arrowStates[ index ] )
		end
	end
	
	local playerLeft, oppLeft = { }, { }
	local playerDown, oppDown = { }, { }
	local playerUp, oppUp = { }, { }
	local playerRight, oppRight = { }, { }
	
	-- idles
	for index = 1, 4 do
		-- left
		if index == 1 then
			playerLeft[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			playerLeft[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			playerLeft[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			oppLeft[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			oppLeft[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			oppLeft[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			playerArrows[ index ] = playerLeft
			opponentArrows[ index ] = oppLeft
		-- down
		elseif index == 2 then
			playerDown[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			playerDown[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			playerDown[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			oppDown[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			oppDown[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			oppDown[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			playerArrows[ index ] = playerDown
			opponentArrows[ index ] = oppDown
		-- up
		elseif index == 3 then
			playerUp[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			playerUp[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			playerUp[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			oppUp[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			oppUp[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			oppUp[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			playerArrows[ index ] = playerUp
			opponentArrows[ index ] = oppUp
		-- right
		elseif index == 4 then
			playerRight[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			playerRight[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			playerRight[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			oppRight[ 'Idle' ] = anim8.newAnimation( idleDirs[ index ], defDuration )
			oppRight[ 'Pressed' ] = anim8.newAnimation( pressDirs[ index ], defDuration )
			oppRight[ 'Hit' ] = anim8.newAnimation( confirmDirs[ index ], defDuration )
			
			playerArrows[ index ] = playerRight
			opponentArrows[ index ] = oppRight
		end
		
		playerLeft.curAnim = 'Idle'
		playerLeft.x, playerLeft.y = 0, 0
		
		oppLeft.curAnim = 'Idle'
		oppLeft.x, oppLeft.y = 0, 0
		
		
		playerDown.curAnim = 'Idle'
		playerDown.x, playerDown.y = 0, 0
		
		oppDown.curAnim = 'Idle'
		oppDown.x, oppDown.y = 0, 0
		
		
		playerUp.curAnim = 'Idle'
		playerUp.x, playerUp.y = 0, 0
		
		oppUp.curAnim = 'Idle'
		oppUp.x, oppUp.y = 0, 0
		
		
		playerRight.curAnim = 'Idle'
		playerRight.x, playerRight.y = 0, 0
		
		oppRight.curAnim = 'Idle'
		oppRight.x, oppRight.y = 0, 0
		
		
		playerArrows[ index ].width, playerArrows[ index ].height = idleDirs[ index ].W, idleDirs[ index ].H
		playerArrows[ index ].frameWidth, playerArrows[ index ].frameHeight = idleDirs[ index ].fW, idleDirs[ index ].fH
		-- playerArrows[ index ][ 'Hit' ].onLoop = function( ) playerArrows[ index ][ 'Hit' ]:pause( ) end
		playerArrows[ index ].z = 50
		
		playerArrows[ index ][ 'Pressed' ].onLoop = function( ) playerArrows[ index ][ 'Pressed' ]:pause( ) end
		
		opponentArrows[ index ].width, opponentArrows[ index ].height = idleDirs[ index ].W, idleDirs[ index ].H
		opponentArrows[ index ].frameWidth, opponentArrows[ index ].frameHeight = idleDirs[ index ].fW, idleDirs[ index ].fH
		opponentArrows[ index ][ 'Hit' ].onLoop = function( ) opponentArrows[ index ].curAnim = 'Idle' end
		opponentArrows[ index ].z = 50
	end
	
	-- print( table.getn( playerArrows[ 1 ][ 'Hit' ].frames ) )
		
	-- left half side for opponent
	opponentArrows.x = curr_width / 2 - curr_width / 4 - 120
	opponentArrows.y = curr_height - 80
	opponentArrows.width = 0
	opponentArrows.spacing = 80
	opponentArrows.scale = 0.4
	
	-- right half side for player
	playerArrows.x = curr_width - curr_width / 4 - 120
	playerArrows.y = curr_height - 80
	playerArrows.width = 0
	playerArrows.spacing = 80
	playerArrows.scale = 0.4
	
	-- arrow spacing, that's it
	local lastArrow = 0
	
	for index, arrow in ipairs( opponentArrows ) do
		if index == 1 then
			arrow.x = opponentArrows.x / opponentArrows.scale + arrow.width
		else
			arrow.x = lastArrow + arrow.width
		end
		
		arrow.y = opponentArrows.y
		lastArrow = arrow.x
		
		opponentArrows.width = opponentArrows.width + arrow.width
		
		table.insert( animatedSprites, arrow )
	end
	
	lastArrow = 0
	
	for index, arrow in ipairs( playerArrows ) do
		if index == 1 then
			arrow.x = playerArrows.x / playerArrows.scale + arrow.width
		else
			arrow.x = lastArrow + arrow.width
		end
		
		arrow.y = playerArrows.y
		lastArrow = arrow.x
		
		playerArrows.width = playerArrows.width + arrow.width
		
		table.insert( animatedSprites, arrow )
	end
end

-- no bad note hit equivalent because this version has
-- ghost tapping enabled by default
function goodNoteHit( note )
	note = note or nil
	
	-- print( 'I was summoned for note ' .. note.Time )
	
	if note ~= nil then
		ingame.notesHit = ingame.notesHit + 1
		note.WasHit = true
		note.CanBeHit = false
		
		ingame.score = ingame.score + 250
		
		ingame.UI[ 'SessionShit' ]:send(
			'[skip][dropshadow=2][shake=1.5][bounce=0.5]Score:[font=vcr][pad=-100][scale=0.6]' .. ingame.score .. '[/scale][/pad][/font][/bounce][/shake][/dropshadow]'
		)
	else
		print( 'Goot note hit called for null note, the fuck?' )
	end
end

--[[
-- bad idea
function deleteNote( noteTime )
	noteTime = noteTime or nil
	
    for index = 1, #Song.Notes do
		if Song.Notes[ index ] ~= nil and Song.Notes[ index ].Time == noteTime then
			Song.Notes[ index ] = nil
			
			-- stop searching when note has been found already
			-- so this shit doesn't goof up somehow
			break
		end
	end
end
--]]

--[[
-- bad idea too
function collisionCheck( x1,y1,w1,h1, x2,y2,w2,h2 )
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
--]]

-- copped from https://developer.roblox.com/en-us/articles/Cloning-tables
function deepCopy( orig, copies )
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepCopy(orig_key, copies)] = deepCopy(orig_value, copies)
            end
            setmetatable(copy, deepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- copped from https://www.asciiart.eu/video-games/sonic-the-hedgehog
function FUNISINFINITE( )
	local lines = {
		'                             ...,?77??!~~~~!???77?<~....',
		'                        ..?7`                           `7!..',
		'                    .,=`          ..~7^`   I                  ?1.',
		'       ........  ..^            ?`  ..?7!1 .               ...??7',
		'      .        .7`        .,777.. .I.    . .!          .,7!',
		'      ..     .?         .^      .l   ?i. . .`       .,^',
		'       b    .!        .= .?7???7~.     .>r .      .=',
		'       .,.?4         , .^         1        `     4...',
		'        J   ^         ,            5       `         ?<.',
		'       .%.7;         .`     .,     .;                   .=.',
		'       .+^ .,       .%      MML     F       .,             ?,',
		'        P   ,,      J      .MMN     F        6               4.',
		'        l    d,    ,       .MMM!   .t        ..               ,,',
		'        ,    JMa..`         MMM`   .         .!                .;',
		'         r   .M#            .M#   .%  .      .~                 .,',
		'       dMMMNJ..!                 .P7!  .>    .         .         ,,',
		'       .WMMMMMm  ?^..       ..,?! ..    ..   ,  Z7`        `?^..  ,,',
		'          ?THB3       ?77?!        .Yr  .   .!   ?,              ?^C',
		'            ?,                   .,^.` .%  .^      5.',
		'              7,          .....?7     .^  ,`        ?.',
		'                `<.                 .= .`\'           1 '
	}
	
	local index = 1
	
	while index < 20 do
		if index == 10 then print( ' \t\t\t\t\t\tFun is infinite! ' ) end
		print( '\n' )
		index = index + 1
	end
	
	-- fun is infinite!
	for line in ipairs( lines ) do print( '\t\t\t' .. lines[ line ] ) end
	
	print( '\n\n\n' )
end

return ingame
