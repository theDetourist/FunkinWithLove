local freeplay = { }

freeplay.active = false
freeplay.songs = { }
freeplay.songs.list = { }
freeplay.curSelected = 1
freeplay.setForTransition = false

--[[--------------------------------------------------------------]]--

freeplay.cam = Camera( 0, 0 )
freeplay.cam.focus = { }

--[[--------------------------------------------------------------]]--

-- because it's not that simple to just overlap sounds in this fcking engine
local sound_fxs = { }
sound_fxs.remove = { }

function freeplay:enter( previous, ... )
	
	local charts = love.filesystem.getDirectoryItems( 'data/charts/' )
	
	for index, dir in ipairs( charts ) do
		local dirShit = love.filesystem.getInfo( 'data/charts/' .. dir )
		
		if dirShit.type == 'directory' and assets.charts[ dir .. '.ini' ] then
			if not table.contains( freeplay.songs, assets.charts[ dir .. '.ini' ] ) then table.insert( freeplay.songs, assets.charts[ dir .. '.ini' ] ) end
		end
	end
	
	if table.getn( freeplay.songs ) > 0 then
		for index = 1, #freeplay.songs do
			local ini
			
			ini = inifile.parse( freeplay.songs[ index ] )
			
			freeplay.songs.list[ index ] = { }
			freeplay.songs.list[ index ].icon = ini[ 'Metadata' ][ 'Icon' ]
			freeplay.songs.list[ index ].name = ini[ 'Metadata' ][ 'Name' ]
			freeplay.songs.list[ index ].alpha = 1
			freeplay.songs.list[ index ].tween = nil
		end
	end
	
	freeplay.setForTransition = false
	freeplay.curSelected = 1
	
	for index = 1, #freeplay.songs.list do
		if freeplay.songs.list[ index ].tween ~= nil then freeplay.songs.list[ index ].tween:stop( ) end
	end
	
	freeplay.cam.focus.x, freeplay.cam.focus.y = curr_width / 2, curr_height / 2
	freeplay.active = true
end

function freeplay:update( dt )
	if not freeplay.active then return end
	
	flux.update( dt )
	Timer.update( dt )
	
	local dx, dy = freeplay.cam.focus.x - freeplay.cam.x, freeplay.cam.focus.y - freeplay.cam.y
	
	freeplay.cam:move( dx / 12, dy / 12 )
	
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
	
	--[[----------------------------------------------------]]--
end

function freeplay:leave( next, ... )
	freeplay.active = false
end

function freeplay:draw( )
	if not freeplay.active then return end
	
	--[[----------------------------------------------------]]--
	
	local camx, camy = freeplay.cam:position( )
	
	-- menu background
	love.graphics.draw(
		assets.images[ 'menuDesat' ],
		curr_width / 2,
		-- like the parallax thingy going on here?
		clamp( curr_height / 2 - ( camy / 16 ), 0, assets.images[ 'menuDesat' ]:getHeight( ) ),
		0,
		1,
		1,
		assets.images[ 'menuDesat' ]:getWidth( ) / 2,
		assets.images[ 'menuDesat' ]:getHeight( ) / 2
	)
	
	--[[----------------------------------------------------]]--
	
	freeplay.cam:attach( )
	
	love.graphics.setFont( assets.fonts[ 'MOGAMBO!' ] )
	
	local r, g, b, a = love.graphics.getColor( )
	
	if table.getn( freeplay.songs ) == 0 then
		
		love.graphics.push( )
	
		love.graphics.scale( 0.15 )
	
		outlinedText(
			'No songs found.',
			curr_width / 2 / 0.15 - love.graphics.getFont( ):getWidth( 'No songs found.' ) / 2,
			curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) / 2,
			{ 0, 0, 0, 1 },
			{ 1, 1, 1, 1 },
			20
		)
		
		love.graphics.pop( )
		
	else
		
		for index = 1, #freeplay.songs.list do
			love.graphics.setColor( 1, 1, 1, freeplay.songs.list[ index ].alpha )
			
			love.graphics.push( )
	
			love.graphics.scale( 0.15 )
		
			if index == 1 then
				freeplay.songs.list[ index ].y = curr_height / 2 / 0.15 - love.graphics.getFont( ):getHeight( ) / 2
			else
				freeplay.songs.list[ index ].y = freeplay.songs.list[ index - 1 ].y + 80 / 0.15
			end
			
			love.graphics.pop( )
			
			--[[----------------------------------------------------]]--
			
			love.graphics.push( )
			
			love.graphics.scale( 0.5 )
			
			local icon = love.graphics.newQuad(
				0,
				0,
				assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ]:getWidth( ) / 2,
				assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ]:getHeight( ),
				assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ]:getDimensions( )
			)
			
			local width = assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ]:getWidth( ) / 2 / 2
			
			-- make not selected icons black
			if freeplay.curSelected == index then
				love.graphics.setColor( 1, 1, 1, freeplay.songs.list[ index ].alpha )
			else
				love.graphics.setColor( 0, 0, 0, freeplay.songs.list[ index ].alpha )
			end
			
			love.graphics.draw(
				assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ],
				icon,
				curr_width / 2 / 0.5 - love.graphics.getFont( ):getWidth( freeplay.songs.list[ index ].name ) * 0.15 - width / 0.5,
				freeplay.songs.list[ index ].y * 0.15 / 0.5 - assets.images[ 'icon-' .. freeplay.songs.list[ index ].icon ]:getHeight( ) / 2 * 0.3
			)
			
			love.graphics.pop( )
			
			--[[----------------------------------------------------]]--
			
			love.graphics.push( )
			
			love.graphics.scale( 0.15 )
			
			-- song name
			outlinedText(
				freeplay.songs.list[ index ].name,
				curr_width / 2 / 0.15 - love.graphics.getFont( ):getWidth( freeplay.songs.list[ index ].name ) / 2,
				freeplay.songs.list[ index ].y,
				{ 0, 0, 0, freeplay.songs.list[ index ].alpha },
				{ 1, 1, 1, freeplay.songs.list[ index ].alpha },
				20
			)
			
			love.graphics.pop( )
		end
		
	end
	
	love.graphics.setColor( r, g, b, a )
	
	freeplay.cam:detach( )
	
	--[[----------------------------------------------------]]--
	
	love.graphics.push( )
	
	love.graphics.scale( 0.08 )
	
	love.graphics.setFont( assets.fonts[ 'vcr' ] )
	
	-- information about the engine
	outlinedText( 'Funkin\' ( 0.1b BETA ) with Löve2D ( 11.4 )', 5 / 0.08, curr_height / 0.08 - love.graphics.getFont( ):getHeight( ) - 5 )
	
	love.graphics.pop( )
end

function freeplay:keypressed( key, scancode, isrepeat )
	-- prevent input if player has selected a song
	if not freeplay.active or freeplay.setForTransition then return end
	
	if key == 'up' or key == 'down' then
			
		if table.getn( freeplay.songs.list ) > 0 then
			freeplay.curSelected = clamp( freeplay.curSelected + ( key == 'up' and -1 or 1 ), 1, table.getn( freeplay.songs.list ) )
		
			print( freeplay.curSelected )
			
			freeplay.cam.focus.y = freeplay.songs.list[ freeplay.curSelected ].y * .15
			
			local sfx = assets.sounds[ 'scrollMenu' ]:clone( )
			sfx:play( )
			
			-- so we can delete these from memory once they're done
			table.insert( sound_fxs, sfx )
		end
	elseif key == 'return' or key == 'kpenter' then
		if table.getn( freeplay.songs.list ) > 0 then
			local filepath, chart, diff = freeplay.songs[ freeplay.curSelected ]:getFilename( ), '', ''
			
			chart = filepath:sub( lastIndexOf( filepath, '/' ) + 1, lastIndexOf( filepath, '.' ) - 1 )
			
			print( chart )
			
			for index = 1, 3 do
				-- while difficulty selection isn't implemented, select by the hardest
				-- chart the engine can find
				if index == 1 then
					diff = 'data/charts/' .. chart .. '/' .. chart .. '-hard.json'
					if love.filesystem.getInfo( diff ) ~= nil then
						chart = chart .. '-hard'
						break
					end
				elseif index == 2 then
					diff = 'data/charts/' .. chart .. '/' .. chart .. '.json'
					if love.filesystem.getInfo( diff ) ~= nil then
						break
					end
				elseif index == 3 then
					diff = 'data/charts/' .. chart .. '/' .. chart .. '-easy.json'
					if love.filesystem.getInfo( diff ) ~= nil then
						chart = chart .. '-easy'
						break
					end
				end
			end
			
			if love.filesystem.getInfo( diff ) ~= nil then
				freeplay.setForTransition = true
				
				freeplay.songs.list[ freeplay.curSelected ].tween = flux.to( freeplay.songs.list[ freeplay.curSelected ], 0.07, { alpha = 0 } )
				:ease( 'cubicinout' )
				:after( freeplay.songs.list[ freeplay.curSelected ], 0.07, { alpha = 1 } )
				:ease( 'cubicinout' )
				:cycle( true )
				
				assets.sounds[ 'confirmMenu' ]:play( )
				
				Timer.after( 1.5,
					function( )
						roomy:enter( screens[ 'ingame' ], chart )
					end
				)
			else
				-- empty song list response
				local sfx = assets.sounds[ 'cancelMenu' ]:clone( )
				sfx:play( )
				
				-- so we can delete these from memory once they're done
				table.insert( sound_fxs, sfx )
				
				print( 'No difficulties found for chart ' .. chart .. '.' )
			end
		else
			-- empty song list response
			local sfx = assets.sounds[ 'cancelMenu' ]:clone( )
			sfx:play( )
			
			-- so we can delete these from memory once they're done
			table.insert( sound_fxs, sfx )
		end
	elseif key == 'escape' then
		freeplay.setForTransition = true
		
		assets.sounds[ 'cancelMenu' ]:play( )
		
		Timer.after( 1.5,
			function( )
				roomy:enter( screens[ 'menu' ] )
			end
		)
	end
end

return freeplay