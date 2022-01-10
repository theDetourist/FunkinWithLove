-- mostly copped from the original game because i suck
-- is also an amalgamation of conductor and musicbeatstate
conductor = { }

conductor.bpm = 120
conductor.crochet = ( (60 / conductor.bpm) * 1000 )
conductor.stepCrochet = conductor.crochet / 4
conductor.safeFrames = 5
conductor.safeFramesOffset = math.floor( ( conductor.safeFrames / 60 ) * 1000 )	-- safe frames in milliseconds
conductor.songPos = 0

conductor.lastBeat = 0
conductor.curBeat = 0
conductor.lastStep = 0
conductor.curStep = 0

conductor.offset = 0

function conductor:update(dt)
	local oldStep = conductor.curStep
	
	-- no mapped changes for bpm just yet, ain't nobody got time for that
	conductor.curStep = math.floor( conductor.songPos / conductor.stepCrochet )
	conductor.curBeat = math.floor( conductor.curStep / 4 )
	
	updateCrochets( )
	
	-- print( conductor.curStep )
	if oldStep ~= conductor.curStep and conductor.curStep > 0 then
		conductor.stepHit()
	end
end

function conductor:stepHit( )
	if conductor.curStep % 4 == 0 then
		conductor:beatHit()
	end
end

function conductor:beatHit( )
	-- gibe buissy pleez
end

function updateCrochets( )
	conductor.crochet = ( (60 / conductor.bpm) * 1000 )
	conductor.stepCrochet = conductor.crochet / 4
end

return conductor