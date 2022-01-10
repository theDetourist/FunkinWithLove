local utf8 = require( "utf8" )

-- hopefully not a mistake
local roomy = require('libs.roomy').new()

-- first of all, prepare folders and shit
require('core.Preparing')

local assets = nil

-- getting freaky on a friday night, yeh
function love.load()
	-- loading assets
	assets = require( 'core.Preloading' )
	
	-- keep track of window's dimensions for later use
	curr_width, curr_height = love.graphics.getDimensions()
	
	screens = {
		['intro'] = require('core.screens.Intro'),
		['chareditor'] = require('core.screens.CharEditor'),
		['menu'] = require('core.screens.MainMenu'),
		['settings'] = require('core.screens.Settings'),
		['freeplay'] = require('core.screens.Freeplay'),
		['ingame'] = require('core.screens.Ingame')
	}
	
	roomy:hook()
	roomy:enter( screens[ 'ingame' ], assets )
end