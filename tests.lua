local Chunks = assert(loadfile('sys/lua/chunks/chunks.lua'))()
local map_xsize = map('xsize')
local map_ysize = map('ysize')
local function hudtxt2(player,id,text,x,y,align,valign,size)
	parse('hudtxt2 '..player..' '..id..' "'..text..'" '..x..' '..y..' '..(align or 0)..' '..(valign or 0)..' '..(size or 13))
end

-- TESTS


Map = Chunks:new(5, 5)

-- print(Map.width, Map.height, Map.CHUNK_COLS, Map.CHUNK_ROWS, #Map.chunks)
-- for _, chunk in pairs(Map.chunks) do
--     print(_, chunk, chunk.id, chunk.x, chunk.y)
-- end

local chunk_id = 0
local colors = {}
for y = 0, map_ysize do
    for x = 0, map_xsize do
        local chunk = Map:getChunkAt(x, y)
        local color = colors[chunk.id]

        if not color then
            colors[chunk.id] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
            color = colors[chunk.id]
        end

        local image_id = image('gfx/block.bmp', x*32+16, y*32+16, 0)
        imagealpha(image_id, 0.5)
        imagecolor(image_id, unpack(color))
    end
end

addhook('movetile', 'onMovetile')
function onMovetile(id, tilex, tiley)
    local chunk = Map:getChunkAt(tilex, tiley)

    local str = 'chunk_id: '..chunk.id..'('
    for _, nchunks in pairs(chunk.neighbours) do
        str = str..nchunks.id..','
    end
    str = str..') '
    str = str..'x: '..chunk.x..' y: '..chunk.y
    hudtxt2(id, 1, str, 50, 300, 0, 0, 20)
end
