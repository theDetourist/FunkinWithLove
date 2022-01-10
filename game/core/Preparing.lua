local utf8 = require( "utf8" )

local inifile = require( 'libs.inifile' )

-- make missing directories
dirs = {
	"metadata"
}

for i, idx in ipairs(dirs) do
	love.filesystem.createDirectory( dirs[i] )
end

if inifile == nil then
	print( 'INIFile not loaded for some reason, fix that.' )
elseif love.filesystem.getInfo( 'userconf.ini' ) == nil or inifile.parse( 'userconf.ini' ) == { } then
	local usershit = { }
	usershit.Personal = { }
	usershit.Game = { }
	
	-- player name so they feel good about themselves
	usershit.Personal.name = 'Detoria'
	usershit.Personal.favDifficulty = 'hard'
	usershit.Personal.favBoyfriend = 'bf_default'
	usershit.Personal.favGirlfriend = 'gf_default'
	
	usershit.Game.globalOffset = 60
	
	inifile.save( 'userconf.ini', usershit )
	local test = inifile.parse( 'userconf.ini' )
	print( 'There, fixed ur shit for u ' .. test[ 'Personal' ][ 'name' ] .. '.' )
	test = nil
	usershit = nil
end

-- define useful functions and callbacks for later use