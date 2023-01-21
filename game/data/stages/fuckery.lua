-- check if required files are actually loaded before doing anything
-- remember, when you var = table, you're creating a reference to the
-- table, not actually cloning it into a new variable
if assets == nil or assets.images == nil or assets.xmls == nil then return print( 'Asset table is null, but we\'ll get \'em next time.' ) end
if assets.images[ 'manor' ] == nil or assets.xmls[ 'manor.xml' ] == nil then return print( 'Images used couldn\'t be found, get that checked out.' ) end
if assets.sounds[ 'thunder_1' ] == nil or assets.sounds[ 'thunder_2' ] == nil then return print( 'The only sounds you\'ll be hearing, is the sounds your mom will make once I get there, get that ass banned.' ) end

--[[ ----------------------------------------------------------------- ]]--

-- truly random shit
math.randomseed( os.time() )

Manor = { }
Manor.AnimatedSprites = { }
Manor.Name = 'Manor'
Manor.Zoom = 1.5
Manor.LightningTime = math.random( 5, 12 )			-- Timer library deals in seconds btw

-- let us "build" the stage here
if assets.images[ 'manor' ] ~= nil and assets.xmls[ 'manor.xml' ] ~= nil then

	local animFrames = assets.getFramesFromXML( 'manor', 'halloweem bg' )
	Manor.width, Manor.height = animFrames.W, animFrames.H
	
	Manor.AnimatedSprites[ 'Idle' ] = anim8.newAnimation( animFrames, 1 )
	
	animFrames = assets.getFramesFromXML( 'manor', 'halloweem bg lightning strike' )
	
	Manor.AnimatedSprites[ 'Lightning' ] = anim8.newAnimation( animFrames, 0.05, function( ) Manor.curAnim = 'Idle' end )
	
	Timer.after( Manor.LightningTime,
		function( )
			Manor.LightningStrike( )
		end
	)
	
	-- default to idle animation
	Manor.curAnim = 'Idle'
	
else return print( 'What the fuck, can\'t find the image or the xml of the sprite.' ) end

function Manor.onUpdate( dt )
	-- since there is a lightning animation for the stage
	Manor.AnimatedSprites[ Manor.curAnim ]:update( dt )
end

--[[ ----------------------------------------------------------------- ]]--

function Manor.LightningStrike( )
	Manor.curAnim = 'Lightning'
	
	assets.sounds[ 'thunder_' .. math.random( 1, 2 ) ]:play( )
	
	-- randomize the timer again for the next call
	Manor.LightningTime = math.random( 5, 12 )
	
	Timer.after( Manor.LightningTime,
		function( )
			Manor.LightningStrike( )
		end
	)
end

function Manor.onKeyPress( key, isrepeat )
	if key == 'l' then
		Manor.curAnim = 'Lightning'
	elseif key == 'i' then
		Manor.curAnim = 'Idle'
	end
end

-- remember, stages are drawn on the z-index 0, so
-- keep that in mind when drawing stuff
function Manor.onDraw( )
	love.graphics.push( )
	
	love.graphics.scale( curr_width / Manor.width * Manor.Zoom, curr_height / Manor.height * Manor.Zoom )
	
	Manor.AnimatedSprites[ Manor.curAnim ]:draw( assets.images[ 'manor' ], -150, 0 )
	
	love.graphics.pop( )
end

return Manor
