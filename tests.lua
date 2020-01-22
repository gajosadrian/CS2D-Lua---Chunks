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




local Mob = {}
local MOBS = {}
function Mob:new(name, x, y)
	local o = {}
    setmetatable(o, self)
    self.__index = self

	Map:initEntity('mobs', o, x, y)

    o.name = name
	o.image_id = image('gfx/block.bmp', x * 32 + 16, y * 32 + 16, 1)
    -- imagescale(o.image_id, 0.7, 0.7)

    MOBS[#MOBS + 1] = o

	return o
end

function Mob:getX()
    return object(self.image_id, 'tilex')
end

function Mob:getY()
    return object(self.image_id, 'tiley')
end

function Mob:setPos(x, y, time)
    local new_x, new_y = x * 32 + 16, y * 32 + 16

    if not time then
    	imagepos(self.image_id, new_x, new_y, 0)
    else
        tween_move(self.image_id, time, new_x, new_y)
    end
end

function Mob:onMovetile(x, y)
	Map:updateEntity(self, x, y)
end

addhook('second', 'onSecond')
function onSecond()
    for i = 1, #MOBS do
        local mob = MOBS[i]
        local x, y = mob:getX(), mob:getY()

        x = x + 1
		-- if (i == 2) then
		-- 	y = y + 1
		-- end

        mob:onMovetile(x, y)
        mob:setPos(x, y, 1000)
    end
end

local mob1 = Mob:new('Gaios', 6, 6)
local mob2 = Mob:new('TAE', 4, 8)


addhook('ms100', 'onMs100')
function onMs100()
    for _, id in pairs(player(0, 'tableliving')) do
        local tilex, tiley = player(id, 'tilex'), player(id, 'tiley')
	    local chunk = Map:getChunkAt(tilex, tiley)

	    local str = 'chunk_id: '..chunk.id..'('
	    for _, nchunks in pairs(chunk.neighbours) do
	        str = str..nchunks.id..','
	    end
	    str = str..')'
	    str = str..' x: '..chunk.x..' y: '..chunk.y
	    local str2 = 'collection('
	    local mobs = chunk:getFromCollection('mobs', nil, true)
	    for _, mob in pairs(mobs) do
	        str2 = str2..mob.name..','
	    end
	    str2 = str2..')'
        hudtxt2(id, 1, str, 50, 300, 0, 0, 20)
	    hudtxt2(id, 2, str2, 50, 330, 0, 0, 20)
	end
end
