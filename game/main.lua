ver = 'Funkin\' ( 0.1b BETA ) with Löve2D ( 11.4 )'

utf8 = require( 'utf8' )
loveframes = require( 'libs.loveframes.init' )
clove = require( 'libs.clove' ) -- thank lord from the heavens for this library... and Neer too
roomy = require( 'libs.roomy' ).new( )
anim8 = require( 'libs.anim8' )
Timer = require( 'libs.timer')
Text = require( 'libs.SYSL-Text.slog-text' )
anim8 = require( 'libs.anim8' )
flux = require( 'libs.flux' )
inifile = require( 'libs.inifile' )
deep = require( 'libs.deep' )
Camera = require( 'libs.camera' )
Event = require( 'libs.knife.event' )
json = require( 'libs.json' )

Conductor = require( 'core.Conductor' )

-- first of all, prepare folders and shit
require( 'core.Preparing' )

assets = { }

function outlinedText( text, x, y )
	text = text or 'PLACEHOLDER'
	x = x or 0
	y = y or 0
	
	r, g, b, a = love.graphics.getColor( )
	
	love.graphics.setColor( 0, 0, 0, 1 )
	
	love.graphics.print( text, x, y - 17 ) -- top
	love.graphics.print( text, x - 17, y ) -- left
	love.graphics.print( text, x, y + 17 ) -- bottom
	love.graphics.print( text, x + 17, y ) -- right
	
	-- main text
	
	love.graphics.setColor( 1, 1, 1, 1 )
	
	love.graphics.print( text, x, y )
	
	love.graphics.setColor( r, g, b, a )
end

-- getting freaky on a friday night, yeh
function love.load()
	-- loading assets
	assets = require( 'core.Preloading' )
	
	print( 'File count: ' .. assets.filecount )
	print( 'Image count: ' .. assets.images.filecount )
	print( 'Chart count: ' .. assets.charts.filecount )
	
	-- keep track of window's dimensions for later use
	curr_width, curr_height = love.graphics.getDimensions()
	
	screens = {
		[ 'intro' ] = require( 'core.screens.Intro' ),
		[ 'chareditor' ] = require( 'core.screens.CharEditor' ),
		[ 'menu' ] = require( 'core.screens.MainMenu' ),
		[ 'settings' ] = require( 'core.screens.Settings' ),
		[ 'freeplay' ] = require( 'core.screens.Freeplay' ),
		[ 'ingame' ] = require( 'core.screens.Ingame' )
	}
	
	roomy:hook( )
	roomy:enter( screens[ 'ingame' ], assets )
end