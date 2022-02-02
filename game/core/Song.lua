require( 'core.Note' )

Song = { }

--[[ ------------------------------------------------------------------------------------- ]] --

Song.ID = nil
Song.Name = nil
Song.Sections = { }
Song.Notes = { }
Song.BPM = 120
Song.HasVoices = true
Song.ScrollSpeed = 2
Song.Player = 'bf_default'
Song.Opponent = 'mommy_default'
Song.Girlfriend = 'gf_default'
Song.Stage = 'Manor'

--[[ ------------------------------------------------------------------------------------- ]] --

-- so songs will be required to have a .ini
-- that will be used to save offsets and to
-- override hardcoded information from the charts
-- themselves

Song.Metadata = { }

Song.Metadata.Name = Song.Name
Song.Metadata.ScrollSpeed = Song.ScrollSpeed
Song.Metadata.Player = Song.Player
Song.Metadata.Opponent = Song.Opponent
Song.Metadata.Girlfriend = Song.Girlfriend
Song.Metadata.Stage = Song.Stage
Song.Metadata.Offset = 0
Song.Metadata.Icon = nil

--[[ ------------------------------------------------------------------------------------- ]] --

-- rest is mostly based on Psych Engine's take on chart loading

function Song.new( )
	local self = { }
	return setmetatable(
		self,
		{ __index = Song }
	)
end

-- json > name of the file, clove prolly took care of loading it already
function Song.loadFromJSON( songshit, song )
	songshit = songshit or nil
	
	if songshit == nil then
		print( 'Chart not found, what the fuck.' )
	else
		local shit, _ = songshit:read( )
		local jSongData = json.decode( shit )
		
		Song.loadSongMetadata( song )
		
		-- index all variables in json to proper ones when returning
		return validateThisShit( jSongData )
	end
end

-- to freeplay or whatever
function Song.loadSongMetadata( songshit )
	songshit = songshit or nil
	
	if songshit == nil then
		print( 'Metadata file not found, shit.' )
	else
		local metadata = inifile.parse( 'data/charts/' .. songshit .. '/' .. songshit .. '.ini' )
		
		if metadata == nil then return print( 'File not found, dude...' ) end
		
		Song.Metadata.Name = metadata[ 'Metadata' ][ 'Name' ]
		Song.Metadata.ScrollSpeed = metadata[ 'Metadata' ][ 'ScrollSpeed' ]
		Song.Metadata.Player = metadata[ 'Metadata' ][ 'Player' ]
		Song.Metadata.Opponent = metadata[ 'Metadata' ][ 'Opponent' ]
		Song.Metadata.Girlfriend = metadata[ 'Metadata' ][ 'Girlfriend' ]
		Song.Metadata.Stage = metadata[ 'Metadata' ][ 'Stage' ]
		Song.Metadata.Offset = metadata[ 'Metadata' ][ 'Offset' ]
		
		-- taking care of the icon that shows up in freeplay and ingame
		Song.Metadata.Icon = metadata[ 'Metadata' ][ 'Icon' ]
	end
end

function LovifyCharacter( dickhead, character )
	-- decides where to look and what to do when dickhead isn't known
	character = character or 'absent'
	
	local lovifiedCharacter
	
	-- expected values = transformed to new format
	local gfVersions = {
		[ 'gf' ] = 'gf_default',
		[ 'gf-car' ] = 'gf_highspeed',
		[ 'gf-christmas' ] = 'gf_xmas',
		[ 'gf-pixel' ] = 'gf_pixelized'
	}
	
	local bfVersions = {
		[ 'bf' ] = 'bf_default',
		[ 'bf-car' ] = 'bf_highspeed',
		[ 'bf-christmas' ] = 'bf_xmas',
		[ 'bf-pixel' ] =  'bf_pixelized'
	}
	
	local theOpponents = {
		[ 'dad' ] = 'dad_default',
		[ 'spooky' ] = 'spooky_default',
		[ 'pico' ] = 'pico_default',
		[ 'mom' ] = 'mommy_default',
		[ 'mom-car' ] = 'mommy_highspeed',
		[ 'parents-christmas' ] = 'parents_xmas',
		[ 'monster-christmas' ] = 'monster_xmas',
		[ 'monster' ] = 'monster_default',
		[ 'senpai' ] = 'senpai_default',
		[ 'senpai-angry' ] = 'senpai_madmad',
		[ 'spirit' ] = 'spirit_default'
	}
	
	if character == 'player1' then
		if bfVersions[ dickhead ] ~= nil then
			lovifiedCharacter = bfVersions[ dickhead ]
		else
			lovifiedCharacter = 'absent'
		end
	elseif character == 'gf' then
		if gfVersions[ dickhead ] ~= nil then
			lovifiedCharacter = gfVersions[ dickhead ]
		else
			lovifiedCharacter = 'absent'
		end
	elseif character == 'player2' then
		if theOpponents[ dickhead ] ~= nil then
			lovifiedCharacter = theOpponents[ dickhead ]
		else
			lovifiedCharacter = 'absent'
		end
	else
		-- which would be 'absent', as in, don't show or process them
		lovifiedCharacter = 'absent'
	end
	
	print( character, lovifiedCharacter )
	return lovifiedCharacter
end

function validateThisShit( trash )
	Song.ID = trash[ 'song' ][ 'song' ]
	
	--[[ ------------------------------------------------------------------------------------- ]] --
	
	-- messy as FUCK but bear with me, this is what we're doing right now:
	
	-- main var, "song":, "notes":, first section inside notes "sectionNotes":,
	-- first kinda note (view Note.lua) type inside first "sectionNotes": then at last,
	-- the value at the Y axis where the note is meant to be drawn
	
	-- sustain length can also be read in milliseconds if convenient
	
	-- so, to create a note properly, we'd do
	
	--[[
	
	
		createNote(
			trash[ 'song' ][ 'notes' ][ 1 ][ 'sectionNotes' ][ 1 ][ 1 ],  		-- again, actual time
			trash[ 'song' ][ 'notes' ][ 1 ][ 'sectionNotes' ][ 1 ][ 2 ],		-- lane, should take mustHitSection into account
			trash[ 'song' ][ 'notes' ][ 1 ][ 'sectionNotes' ][ 1 ][ 3 ]			-- sustain length
		)
	
	
	-- ]]
	
	-- print( trash[ 'song' ][ 'notes' ][ 1 ][ 'mustHitSection' ] )
	
	--[[ ------------------------------------------------------------------------------------- ]] --
	
	-- don't overcomplicate it, fuck the order of the notes inside
	-- the table, they'll be drawn according to their strum time anyway
	
	for idx, section in pairs( trash[ 'song' ][ 'notes' ] ) do
		-- we're @: trash[ 'song' ][ 'notes' ][ idx ] < - -
		
		local isBoyfriendsTime = { }
		isBoyfriendsTime[ idx ] = section[ 'mustHitSection' ]
		
		for index, note in pairs( section[ 'sectionNotes' ] ) do
			-- now we're @: trash[ 'song' ][ 'notes' ][ idx ][ 'sectionNotes' ][ index ] < - -
			
			-- do some proper checking to fix opponent's notes
			-- going to boyfriends side
			
			-- yessir, no need to process if boyfriend ain't the
			-- focus, since 1-8 is still valid when drawing
			
			local playerInFocus, trunote = 0, note[ 2 ] + 1
			
			if isBoyfriendsTime[ idx ] then
				playerInFocus = 4
			end
			
			if trunote >= 5 then
				-- lane is higher than 4, swap sides
				playerInFocus = ( playerInFocus == 4 and 0 or 4 )
				trunote = trunote - 4
			end
			
			-- so if player == 4 + 1/2/3/4 for example == 5/6/7/8
			trunote = playerInFocus + trunote
			
			table.insert( Song.Notes,
				createNote(
					math.abs( note[ 1 ] ),
					trunote,
					( trunote >= 5 and true or false ),		-- must hit now describes whether note is player's or not
					note[ 3 ],
					( index > 1 and Song.Notes[ index - 1 ] or Song.Notes[ index ] )
				)
			)
		end
	end
	
	--[[ ------------------------------------------------------------------------------------- ]] --
	
	Song.BPM = trash[ 'song' ][ 'bpm' ]
	Song.HasVoices = trash[ 'song' ][ 'needsVoices' ]
	Song.ScrollSpeed = trash[ 'song' ][ 'speed' ]
	Song.Player = LovifyCharacter( trash[ 'song' ][ 'player1' ], 'player1' ) -- to convert it to the new format
	Song.Opponent = LovifyCharacter( trash[ 'song' ][ 'player2' ], 'player2' )
	
	-- checking for the many versions of the same variable girlfriend can have
	
	-- new version, new normal on Psych Engine and Kade Engine at least
	if trash[ 'song' ][ 'gfVersion' ] == nil then
		-- old deprecated version, there might be a few charts out there with this still in them
		-- so gotta check anyway
		if trash[ 'song' ][ 'player3' ] == nil then
			-- if neither of them are valid, might be because the creator didn't wanted girlfriend
			-- in the mix at all and we got them covered with an Absent version of Girlfriend
			-- where she just won't show up, nor be processed at all, saving memory later
			
			Song.Girlfriend = 'absent'
		else
			Song.Girlfriend = LovifyCharacter( trash[ 'song' ][ 'player3' ], 'gf' )
		end
	else
		Song.Girlfriend = LovifyCharacter( trash[ 'song' ][ 'gfVersion' ], 'gf' )
	end
	
	-- don't change stages yet until the method is properly implemented
	-- Song.Stage = 'Manor'
	
	return Song
end

-- for convenience and debugging, nothing more
function DeepPrint (e)
    -- if e is a table, we should iterate over its elements
    if type(e) == "table" then
        for k,v in pairs(e) do -- for every element in the table
            print(k)
            DeepPrint(v)       -- recursively repeat the same procedure
        end
    else -- if not, we can just print it
        print(e)
    end
end

function clamp( val, minnum, maxnum )
	return math.min( math.max( val, minnum), maxnum )
end

--[[ ------------------------------------------------------------------------------------- ]] --

-- copped from http://lua-users.org/wiki/StringTrim
function trim( s )
   return ( s:gsub( "^%s*(.-)%s*$", "%1" ) )
end

return Song