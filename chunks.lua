local Map = {
    _VERSION = 1.0,
    START_DATE = '2020-01-20',
    RELEASE_DATE = '',
    LAST_DATE = '',
    USGN = {
        ['Gaios'] = 'http://unrealsoftware.de/profile.php?userid=18271',
        ['TrialAndError'] = 'http://unrealsoftware.de/profile.php?userid=129440'
    }
}

local map_xsize = map('xsize')
local map_ysize = map('ysize')

--[[ CHUNK CODE ]]
local Chunk = {}
function Chunk:new(id, x, y, width, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.id = id
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.neighbours = {}

    o.data = {}

    return o
end

function Chunk:addData(key, data)
    self.data[key] = data
end

function Chunk:removeData(key)
    self.data[key] = nil
end

function Chunk:addNeighbour(id)
    table.insert(self.neighbours, id)
    return self
end

--[[ MAP CHUNKS CODE ]]

function Map:new(width, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.width = math.ceil(width)
    o.height = math.ceil(height)

    o.CHUNK_COLS = math.ceil(map_xsize / width)
    o.CHUNK_ROWS = math.ceil(map_ysize / height)

    o.chunks = {}
    o.tiles = {}

    o:generateChunks()

    return o
end

function Map:getNeighbourChunk(chunk, x_offset, y_offset)
    if (chunk.x == 0 and x_offset == -1) then return false end
    if (chunk.x == ((self.CHUNK_COLS - 1) * self.width) and x_offset == 1) then return false end

    local chunk_id = chunk.id + (self.CHUNK_COLS * y_offset) + x_offset
    return self:getChunkById(chunk_id)
end

function Map:getChunkById(chunk_id)
    return self.chunks[chunk_id]
end

function Map:getChunkIdAt(x, y)
    return self.tiles[x][y]
end

function Map:getChunkAt(x, y)
    local chunk_id = self:getChunkIdAt(x, y)
    return self.chunks[chunk_id]
end

function Map:generateChunks()
    -- Generate the chunks
    local chunk_id = 0
    for y = 0, map_ysize, self.height do
        for x = 0, map_xsize, self.width do
            chunk_id = chunk_id + 1
            self.chunks[chunk_id] = Chunk:new(chunk_id, x, y, self.width, self.height)
            self:mapChunkIdToTiles(chunk_id, x, y, self.width, self.height)
        end
    end

    -- Add the chunks neighbours
    for _, chunk in pairs(self.chunks) do
        for y_offset = -1, 1 do
            for x_offset = -1, 1 do
                local neighbour_chunk = self:getNeighbourChunk(chunk, x_offset, y_offset)
                -- Don't add the chunk itself as its neighbour
                if neighbour_chunk and chunk.id ~= neighbour_chunk.id then
                    chunk:addNeighbour(neighbour_chunk)
                end
            end
        end
    end
end

-- Mapping chunk ids to tiles
function Map:mapChunkIdToTiles(chunk_id, x1, y1, x2, y2)
    for tx = x1, x1 + x2 do
        if not self.tiles[tx] then self.tiles[tx] = {} end
        for ty = y1, y1 + y2 do
            self.tiles[tx][ty] = chunk_id
        end
    end
end

function Map:addData(chunk_id, key, data)
    self:getChunkById(chunk_id):addData(key, data)
end

function Map:removeData(chunk_id, key)
    self:getChunkById(chunk_id):removeData(key)
end

return Map
