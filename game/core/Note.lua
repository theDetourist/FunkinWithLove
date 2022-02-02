Note = { }
Notes = { __index = Note }

-- time in milliseconds where the note has to hit
-- the middle of the strumline
Note.Time = 0

-- if note isn't sustained, this will always be zero
Note.SustainTime = 0

-- this will hold the sustain anim8 object, that's it
Note.Sustain = { }

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

-- arrow note itself
Note.Visible = false

-- hold note obviously
Note.Sustain.Visible = true

-- equivalent of Note.prevNote in the original code
Note.Previous = nil

Note.Animation = nil
Note.Sustain.Animation = nil
Note.Sustain.EndAnimation = nil

Note.x = 0
Note.frameWidth = 0
Note.width = 0
Note.y = 0
Note.frameHeight = 0
Note.height = 0

Note.Sustain.frameWidth = 0
Note.Sustain.width = 0
Note.Sustain.frameHeight = 0
Note.Sustain.height = 0
Note.Sustain.scale = 1

function createNote( time, lane, musthit, sustaintime, prevNote )
	time = time or 1
	lane = lane or 5
	sustaintime = sustaintime or 0
	musthit = musthit or false
	prevNote = prevNote or Note
	
	-- print( time )
	
	-- check if assets variable isn't null before doing these
	-- operations, or else, the fcking game won't even compile
	-- ...rightfully so, obviously
	local animFrames = { }
	
	if assets ~= nil then
		local direction = 'purple'  -- left arrow as default
		
		if lane == 1 or lane == 5 then
			direction = 'purple'
		elseif lane == 2 or lane == 6 then -- down arrow
			direction = 'blue'
		elseif lane == 3 or lane == 7 then -- up arrow
			direction = 'green'
		elseif lane == 4 or lane == 8 then -- right arrow
			direction = 'red'
		else
			direction = 'purple'
		end

		if sustaintime > 0 then
			animFrames = assets.getFramesFromXML( 'NOTE_assets', direction .. ' hold piece' )
			
			Note.Sustain.Animation = anim8.newAnimation( animFrames, 1 )
			
			Note.Sustain.frameWidth = animFrames.fW
			Note.Sustain.width = animFrames.W
			Note.Sustain.frameHeight = animFrames.fH
			Note.Sustain.height = animFrames.H
			Note.Sustain.AnimationName = direction .. ' hold piece'
			
			animFrames = assets.getFramesFromXML( 'NOTE_assets', direction .. ' hold end' )
			
			Note.Sustain.EndAnimation = anim8.newAnimation( animFrames, 1 )
			Note.Sustain.EndAnimation:flipV( )
			Note.Sustain.EndAnimation:flipH( )
			Note.Sustain.EndAnimationName = direction .. ' hold end'
		end
		
		animFrames = assets.getFramesFromXML( 'NOTE_assets', direction )
		
		Note.width, Note.frameWidth, Note.height, Note.frameHeight = animFrames.W, animFrames.fW, animFrames.H, animFrames.fH
		Note.Animation = anim8.newAnimation( animFrames, 1 )
	end
	
	local finalNote = { }
	finalNote.Time = time
	finalNote.SustainTime = sustaintime
	finalNote.Sustain = shallowcopy( Note.Sustain )
	finalNote.Lane = lane
	finalNote.IsSustain = false
	finalNote.CanBeHit = true
	finalNote.MustHit = musthit
	finalNote.WasHit = false
	finalNote.Visible = false
	finalNote.Previous = prevNote
	finalNote.Animation = Note.Animation
	finalNote.x = 0
	finalNote.frameWidth = Note.frameWidth
	finalNote.y = 0
	finalNote.frameHeight = Note.frameHeight
	
	return setmetatable( finalNote, Notes )
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end