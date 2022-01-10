local anim8 = require( 'libs.anim8' )

Note = { }
Notes = { __index = Note }

Note.assets = { }

-- time in milliseconds where the note has to hit
-- the middle of the strumline
Note.Time = 0

-- time in milliseconds that the sustain ends in the song
-- if note isn't sustained, this will always be zero
Note.SustainTime = 0

Note.IsSustain = false

-- self explanatory i guess
-- but 1-4 is cpu's, 5-8 is player's
Note.Lane = 0

-- still coming towards the strumline
Note.CanBeHit = true

-- note is boyfriend's or not
Note.MustHit = true

-- self explanatory
Note.WasHit = false

Note.Visible = false

-- equivalent of Note.prevNote in the original code
Note.Previous = nil

-- notes usually only have one animation that defines it
-- visually, like being an average arrow note, a hold
-- or a trail end
Note.Animation = nil

Note.x = 0
Note.frameWidth = 0
Note.width = 0
Note.y = 0
Note.frameHeight = 0
Note.height = 0

function createNote( time, lane, musthit, sustaintime, prevNote )
	time = time or 1
	sustaintime = sustaintime or 0
	lane = lane or 5 -- default to left arrow for player in must hit mode
	musthit = musthit or false
	prevNote = prevNote or Note
	
	-- print( time )
	
	-- taking into account previous note data and remember
	-- sustains are treated as a SINGLE note, not multiple
	-- like the og game, so they're different here
	--if Note.Previous.SustainTime > 0 or Note.Previous.IsSustain then
	--	Note.IsSustain = true
	--end
	
	-- check if assets variable isn't null before doing these
	-- operations, or else, the fcking game won't even compile
	-- ...rightfully so, obviously
	local animFrames = { }
	
	if Note.assets ~= nil then
		local direction = 'purple'  -- left arrow as default
		
		-- print( time, lane )
		
		if lane == 2 or lane == 6 then -- down arrow
			direction = 'blue'
		elseif lane == 3 or lane == 7 then -- up arrow
			direction = 'green'
		elseif lane == 4 or lane == 8 then -- right arrow
			direction = 'red'
		else
			direction = 'purple'
		end
			
		if not Note.IsSustain then
			-- average arrow note
			
			animFrames = Note.assets.getFramesFromXML( 'NOTE_assets', direction )
		elseif time ~= Note.Previous.SustainTime then
			-- hold sustain
			
			animFrames = Note.assets.getFramesFromXML( 'NOTE_assets', direction .. ' hold piece' )
		-- remember, Note.Previous when dealing with a sustain note
		-- should always be an average arrow note, in this case
		else
			-- end trail sprite
			
			animFrames = Note.assets.getFramesFromXML( 'NOTE_assets', direction .. ' hold end' )
		end
	end
	
	if anim8 ~= nil then
		Note.width, Note.frameWidth, Note.height, Note.frameHeight = animFrames.W, animFrames.fW, animFrames.H, animFrames.fH
		Note.Animation = anim8.newAnimation( animFrames, 1 )
	else
		print( 'anim8 is null, ANIM8 IS NULL' )
	end
	
	return setmetatable(
	{
		Time = time,
		SustainTime = sustaintime,
		Lane = lane,
		IsSustain = false,
		CanBeHit = true,
		MustHit = musthit,
		WasHit = false,
		Visible = false,
		Previous = prevNote,
		Animation = Note.Animation,
		x = 0,
		frameWidth = Note.frameWidth,
		y = 0,
		frameHeight = Note.frameHeight
	}, Notes)
end