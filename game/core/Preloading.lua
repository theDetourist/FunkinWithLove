local assets = { }
assets.filecount = 0

assets.images = { }
assets.images.filecount = 0

assets.sounds = { }
assets.sounds.filecount = 0

assets.songs = { }
assets.songs.filecount = 0

assets.fonts = { }
assets.fonts.filecount = 0

assets.xmls = { }
assets.xmls.filecount = 0

assets.inis = { }
assets.inis.filecount = 0

assets.charts = { }
assets.charts.filecount = 0

curr_width, curr_height = love.graphics.getDimensions()

-- necessary to count clove shit
function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	
	return count
end

local function lastIndexOf(str,char)
	for i=str:len(),1,-1 do if str:sub(i,i)==char then return i end end
	return str:len()+1
end

local function getExtension(filename)
	return filename:sub((lastIndexOf(filename,".") or filename:len()) +1)
end

local function removeExtension(filename)
	return filename:sub(1,lastIndexOf(filename,".")-1)
end

-- —————————————————————————————————————  ASSET   LOADING  ————————————————————————————————————— --

-- IMAGES

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

local img_path = 'data/images/'

clove.importAll(img_path, true, assets.images)
assets.images.filecount = tablelength(assets.images) - 1

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- SOUNDS

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

local snd_path = 'data/sounds/'

clove.importAll(snd_path, true, assets.sounds)
assets.sounds.filecount = tablelength(assets.sounds)

local sng_path = 'data/songs/'

clove.importAll(sng_path, true, assets.songs)
assets.songs.filecount = tablelength(assets.songs)  - 1

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- FONTS

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

local fnt_path = 'data/fonts/'

clove.importAll(fnt_path, true, assets.fonts, nil, nil,
	function (size)
		-- 4k 240fps raytrace pirated minecartf experienced
		size = ( 200 * ( curr_width / 800 ) )
		return size
	end
)
assets.fonts.filecount = tablelength(assets.fonts)  - 1

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- XMLs

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- no need to separate xmls and images in different
-- folders anymore, woop woooop

clove.importAll( img_path, true, assets.xmls, nil,
	function (filename)
		if getExtension( filename ) == 'xml' then return false
		else return true end
	end
)
assets.xmls.filecount = tablelength( assets.xmls ) - 1

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- Offset INI's

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- only import these if the image equivalent is present
clove.importAll( img_path, true, assets.inis, nil,
	function (filename)
		if getExtension( filename ) == 'ini' then
			if assets.images[ removeExtension( filename ) ] ~= nil then
				return false
			end
		else return true end
	end
)
assets.inis.filecount = tablelength( assets.inis ) - 1

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

-- CHARTS

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

local charts_path = 'data/charts/'

clove.importAll( charts_path, true, assets.charts, nil,
	function (filename)
		if getExtension( filename ) == 'json' or getExtension( filename ) == 'ini' then
			return false
		else return true end
	end
)
assets.charts.filecount = tablelength( assets.charts ) - 1
print( 'Charts : ' .. assets.charts.filecount )

-- _____________________________________   -  -  -  -  -   ————————————————————————————————————— --

assets.filecount = assets.filecount + ( assets.images.filecount + assets.sounds.filecount + assets.songs.filecount + assets.fonts.filecount + assets.xmls.filecount + assets.charts.filecount )

-- made by youngneer, violated by me
function assets.getFramesFromXML( spritesheet, anim )
	spritesheet = spritesheet or nil
	anim = anim or nil
	
	if anim ~= '' or anim ~= nil or assets ~= nil then
		local index, frames, img_width, img_height = 1, { }, assets.images[ spritesheet ]:getDimensions( )
		
		local cunt = 0
		
		if assets.xmls[ spritesheet .. '.xml' ] ~= nil then
			-- print( 'Yep, on it.' )
			
			for line in assets.xmls[ spritesheet .. '.xml' ]:lines( ) do
				-- skip lines that start in numbers, comments and the xml version shit
				-- until eof
				if index > 1 and line:match( '%a' ) and not line:match( '<!' ) and line ~= '</TextureAtlas>' then
					-- don't ask me about this pattern
					local _, animName = line:match( "name=([\"'])(.-)(%d-)%1" )
					
					if animName == anim then
						local _, frameIndex = line:match( "name=([\"']).-(%d-)%1" )
						
						frameIndex = tonumber( frameIndex ) + 1
						
						-- print( 'found something...?' )
						
						if frameIndex and frames[ frameIndex ] == nil then
							local _, x = line:match( "x=([\"'])(.-)%1" )
							local _, frameX = line:match( "frameX=([\"'])(.-)%1" )
							local _, y = line:match( "y=([\"'])(.-)%1" )
							local _, frameY = line:match( "frameY=([\"'])(.-)%1" )
							local _, width = line:match( "width=([\"'])(.-)%1" )
							local _, frameWidth = line:match( "frameWidth=([\"'])(.-)%1" )
							local _, height = line:match( "height=([\"'])(.-)%1" )
							local _, frameHeight = line:match( "frameHeight=([\"'])(.-)%1" )
							
							-- print( animName, frameIndex, x, y, frameX, frameY, width, frameWidth, height, frameHeight )
							
							frames[ frameIndex ] = love.graphics.newQuad(
								frameX ~= nil and x + frameX or x,	-- dollar store ternary operations
								frameY ~= nil and y + frameY or y,
								width,
								height,
								img_width,
								img_height
							)
							frames.W, frames.H = width or 1, height or 1
							frames.fW, frames.fH = frameWidth or 1, frameHeight or 1
						end
						
						cunt = cunt + 1
					else
						-- print( 'Not on line ' .. index .. '. Skipping.' )
					end
				end
				index = index + 1
			end
		end
		
		if cunt > 0 then
			return frames
		else
			print( 'Couldn\'t find a single instance for ' .. anim .. '.' )
		end
	else
		print( 'Anim name isn\'t valid, or empty.' )
	end
end

print( assets.filecount )
return assets