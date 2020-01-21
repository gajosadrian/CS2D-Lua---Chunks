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

-- local chunk_id = 0
-- local colors = {}
-- for y = 0, map_ysize do
--     for x = 0, map_xsize do
--         local chunk = Map:getChunkAt(x, y)
--         local color = colors[chunk.id]
--
--         if not color then
--             colors[chunk.id] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
--             color = colors[chunk.id]
--         end
--
--         local image_id = image('gfx/block.bmp', x*32+16, y*32+16, 0)
--         imagealpha(image_id, 0.5)
--         imagecolor(image_id, unpack(color))
--     end
-- end

--Draw for every chunk instead of every tile
for i = 1, #Map.chunks do
    local chunk = Map.chunks[i]
    local image_id = image('gfx/block.bmp', (chunk.x * 32) + ((chunk.width*32) / 2), (chunk.y * 32) + ((chunk.height*32) / 2), 0)
    imagescale(image_id, chunk.width, chunk.height)
    imagealpha(image_id, 0.5)
    imagecolor(image_id, math.random(0, 255), math.random(0, 255), math.random(0, 255))
end




local mob1 = {
    id = 1,
    x = 0,
    y = 0,
    name = 'Gajos',
}
local mob2 = {
    id = 2,
    x = 1,
    y = 1,
    name = 'TAE',
}
local mob3 = {
    id = 3,
    x = 1,
    y = 0,
    name = 'Kebab',
}
local mob4 = {
    id = 4,
    x = 0,
    y = 0,
    name = 'Cola',
}
local mob5 = {
    id = 5,
    x = 3,
    y = 7,
    name = 'Pepsi',
}

local chunk = Map:getChunkById(7)
chunk:addToCollection('mobs', mob1)
chunk:addToCollection('mobs', mob2)
chunk:addToCollection('mobs', mob3)
chunk:addToCollection('mobs', mob4)
chunk:addToCollection('mobs', mob5)

for _, mob in pairs(chunk.collections['mobs']) do
    print(mob.id, mob.name)
end

--Removing from collection
chunk:removeFromCollection('mobs', {name = 'Cola'})

--Expected result: 1, 2, 3, 5


addhook('movetile', 'onMovetile')
function onMovetile(id, tilex, tiley)
    local chunk = Map:getChunkAt(tilex, tiley)

    local str = 'chunk_id: '..chunk.id..'('
    for _, nchunks in pairs(chunk.neighbours) do
        str = str..nchunks.id..','
    end
    str = str..')'
    str = str..' x: '..chunk.x..' y: '..chunk.y
    str = str..' collection('
    local mobs = chunk:getFromCollection('mobs')
    for _, mob in pairs(mobs) do
        str = str..mob.id..','
    end
    str = str..')'
    hudtxt2(id, 1, str, 50, 300, 0, 0, 20)
end
