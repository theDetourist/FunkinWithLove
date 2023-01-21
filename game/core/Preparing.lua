local utf8 = require( "utf8" )

local inifile = require( 'libs.inifile' )

-- make missing directories
dirs = {
	"metadata"
}

for i, idx in ipairs(dirs) do
	love.filesystem.createDirectory( dirs[i] )
end

function lastIndexOf( str, char )
	for i=str:len(),1,-1 do if str:sub(i,i)==char then return i end end
	return str:len()+1
end

if inifile == nil then
	print( 'INIFile not loaded for some reason, fix that.' )
elseif love.filesystem.getInfo( 'userconf.ini' ) == nil or inifile.parse( 'userconf.ini' ) == { } then
	local usershit = { }
	usershit.Personal = { }
	usershit.Game = { }
	usershit.Keys = { }
	
	-- player name so they feel good about themselves
	usershit.Personal.name = 'Detoria'
	usershit.Personal.favDifficulty = 'hard'
	usershit.Personal.favBoyfriend = 'bf_default'
	usershit.Personal.favGirlfriend = 'gf_default'
	
	usershit.Game.globalOffset = 60
	usershit.Game.scrollSpeed = 1
	usershit.Game.downScroll = false
	
	usershit.Keys.leftArrow = 'left'
	usershit.Keys.upArrow = 'up'
	usershit.Keys.downArrow = 'down'
	usershit.Keys.rightArrow = 'right'
	
	inifile.save( 'userconf.ini', usershit )
	local test = inifile.parse( 'userconf.ini' )
	print( 'There, fixed ur shit for u ' .. test[ 'Personal' ][ 'name' ] .. '.' )
	test = nil
	usershit = nil
end

-- define useful functions and callbacks for later use