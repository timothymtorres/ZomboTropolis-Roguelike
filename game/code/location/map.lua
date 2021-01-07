local class = require('code.libs.middleclass')
local Tiles = require('code.location.tile.tiles')
local TerminalNetwork = require('code.location.terminal_network')
local berry = require( 'code.libs.berry' ) -- we should really having to use berry to load shit into our map
local Zombie = require('code.player.zombie.zombie')
local Human = require('code.player.human.human')
local clothing = require('code.player.clothing')
local names = require('code.player.names.names')
-- local suburb = require('suburb')

local Map = class('Map')

-- we sure we ONLY CREATE map once and make it a global and pass it around from file to file
local filename = "graphics/map/world.json"
world = berry:new( filename, "graphics/map" )

local tile_offset = world.background_tile_offset -- this is how many tiles surround the world in all directions (background)
local world_width = world.dim.width
local layer = world:getLayer("Location ID")
local tileset_gid = world.tilesets["Tile ID"].firstgid

function Map:initialize(name, size, z_levels)
  self.name = name
  self.humans = 0
  self.zombies = 0
  self.dead = 0
  self.z_levels = z_levels or 1
  self.size = size

  size = size or 1
  z_levels = z_levels or 1

  self.terminal_network = TerminalNetwork:new(size, z_levels)

  -- we need to import the z_level from the Tiled map data in the future
  for z=1, z_levels do
    self[z] = {}
    for y=1, size do
      self[z][y] = {}
      for x=1, size do
        local tile_pos = x + ((y - 1) * world_width)
        local tile_gid = layer.data[tile_pos] + 1  -- need to add a + 1 to count from 1 instead of zero
        local tile_not_exist = tile_gid == 1
        local tile_id

        if tile_not_exist then
          tile_id = 1  -- default to first id (which is land right now)
        else
          tile_id = tile_gid - tileset_gid
        end

  --print(tile_layer.data.data[tile_pos], tileset_gid, tile_id)

        self[z][y][x] = Tiles[tile_id]:new(self.name, x, y, z)
      end
    end
  end

  -- we can do better than these hacks?  Shouldn't have to load
  -- the map from berry!  Or at least not initialize it?!
  world.isVisible = false
  --world:removeSelf()
  --world = nil
end

function Map:getInside(x, y, z)
  z = z or 1
  return self[z][y][x].inside_players or false
end

function Map:getOutside(x, y, z)
  z = z or 1
  return self[z][y][x].outside_players
end

function Map:getTile(x, y, z)
  z = z or 1
  return self[z][y][x]
end

function Map:isBuilding(x, y, z)
  z = z or 1
  return self[z][y][x].inside_players and true or false
end

function Map:get3x3(x, y, z)
  z = z or 1
  local list = {}
  list[#list+1] = self[z][y][x]
  list[#list+1] = self[z][y][x+1]
  list[#list+1] = self[z][y][x-1]
  list[#list+1] = self[z][y+1] and self[z][y+1][x] or nil
  list[#list+1] = self[z][y+1] and self[z][y+1][x+1] or nil
  list[#list+1] = self[z][y+1] and self[z][y+1][x-1] or nil
  list[#list+1] = self[z][y-1] and self[z][y-1][x] or nil
  list[#list+1] = self[z][y-1] and self[z][y-1][x+1] or nil
  list[#list+1] = self[z][y-1] and self[z][y-1][x-1] or nil
  return list
end

function Map:spawnPlayer(mob_type, username, cosmetics)
  local player

  -- we need to be careful that we don't select a position that a
  -- player shouldn't spawn on (ie. water) but for now don't worry
  local z, y, x = 1, math.random(1, self.size), math.random(1, self.size)

  -- also need to make a special function to spawn humans into unruined
  -- buildings and zombies into corpses
  -- for human = findUnruinedBuilding(no zeds outside)
  -- for zombie = findAvailableCorpse(must be fully eaten) (if not available spawn somewhere outside)

  if mob_type == 'zombie' then
    username = username or names:generateRandom('zombie')
    cosmetics = cosmetics or clothing:generateRandom(mob_type)
    player = Zombie:new(self, x, y, z, username, cosmetics)
  elseif mob_type == 'human' or mob_type == 'male' or mob_type == 'female' then
    local choices = {'male', 'female'}
    local gender

    if mob_type == 'human' then -- select random sex
      gender = choices[math.random(1, 2)]
    else
      gender = mob_type
    end

    username = username or names:generateRandom(gender)
    cosmetics = cosmetics or clothing:generateRandom('human')
    player =  Human:new(self, z, y, z, username, cosmetics)
  --elseif mob_type == 'corpse'  ???
  end

  self[z][y][x]:insert(player,'inside')  -- remove 'inside' argument later (for testing purposes)

  return player
end

return Map
