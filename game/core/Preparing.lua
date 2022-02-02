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
	usershit.Keys = { }
	
	-- player name so they feel good about themselves
	usershit.Personal.name = 'Detoria'
	usershit.Personal.favDifficulty = 'hard'
	usershit.Personal.favBoyfriend = 'none'
	usershit.Personal.favGirlfriend = 'none'
	
	usershit.Game.globalOffset = 0
	usershit.Game.scrollSpeed = 2
	usershit.Game.downScroll = true
	
	usershit.Keys.leftArrow = 'left'
	usershit.Keys.downArrow = 'down'
	usershit.Keys.upArrow = 'up'
	usershit.Keys.rightArrow = 'right'
	
	inifile.save( 'userconf.ini', usershit )
	local test = inifile.parse( 'userconf.ini' )
	print( 'There, fixed ur shit for u ' .. test[ 'Personal' ][ 'name' ] .. '.' )
	test = nil
	usershit = nil
end