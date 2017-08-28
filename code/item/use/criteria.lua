local error_list = require('code.error.list')

local criteria = {}


--+-- ***  LOCAL FUNCTION  *** --+--
local function targetInRange(player, target) return player:getSpot() == target:getSpot() end
--+-- ***  LOCAL FUNCTION  *** --+--


--[[
--- MEDICAL
--]]

function criteria.FAK(player, target)
  assert(target:isStanding(), 'Target has been killed')
  assert(targetInRange(player, target), 'Target is out of range')
  assert(not target:isMaxHP(), 'Target has full health')
  -- must be in a lit area
  assert(target:isMobType('human'), 'Target must be a human')    
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target is out of range'
error_list[#error_list+1] = 'Target has full health'
error_list[#error_list+1] = 'Target must be a human'

function criteria.bandage(player, target)
  assert(target:isStanding(), 'Target has been killed')
  assert(targetInRange(player, target), 'Target is out of range')
  assert(not target:isMaxHP(), 'Target has full health')
  -- must be in a lit area  
  assert(target:isMobType('human'), 'Target must be a human')    
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target is out of range'
error_list[#error_list+1] = 'Target has full health'
error_list[#error_list+1] = 'Target must be a human'

function criteria.antibodies(player, target)
  assert(target:isStanding(), 'Target has been killed')
  assert(targetInRange(player, target), 'Target is out of range')
  assert(target:isMobType('human'), 'Target must be a human')    
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target is out of range'
error_list[#error_list+1] = 'Target must be a human'

function criteria.antidote(player, target)
  assert(target:isStanding(), 'Target has been killed')
  assert(targetInRange(player, target), 'Target is out of range')
  assert(target:isMobType('human'), 'Target must be a human')  
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target is out of range'
error_list[#error_list+1] = 'Target must be a human'


function criteria.syringe(player, target)
  assert(target:isStanding(), 'Target has been killed')
  assert(targetInRange(player, target), 'Target is out of range')
  assert(target:isMobType('zombie'), 'Target must be a zombie')
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target is out of range'
error_list[#error_list+1] = 'Target must be a zombie'

--[[
--- WEAPONS
--]]

function criteria.flare(player)
  assert(player:isStaged('outside'), 'Player must be outside to use flare')  
end

error_list[#error_list+1] = 'Player must be outside to use flare'

--[[
--- GADGETS
--]]

function criteria.radio(player, freq) 
  assert(freq > 0 and freq <= 1024, 'Radio frequency is out of range')  
end

error_list[#error_list+1] = 'Radio frequency is out of range'

function criteria.cellphone(player)
  -- check if phone towers functional
  -- need light?
  -- need battery
end

function criteria.sampler(player, target)
  assert(target:isStanding(), 'Target has been killed')  
  assert(target:isZombie(), 'Target must be a zombie')
  assert(targetInRange(player, target), 'Target is out of range')  
end

error_list[#error_list+1] = 'Target has been killed'
error_list[#error_list+1] = 'Target must be a zombie'
error_list[#error_list+1] = 'Target is out of range'

function criteria.GPS(player) 
  -- need light
  -- need battery
end

--+-- ***  LOCAL FUNCTION  *** --+--
local function playerInsideBuilding(player)
  local p_tile = player:getTile()
  return p_tile:isBuilding() and player:isStaged('inside')   
end
--+-- ***  LOCAL FUNCTION  *** --+--

--[[
--- EQUIPMENT
--]]

function criteria.barricade(player)
  local p_tile = player:getTile()
  assert(playerInsideBuilding(player), 'Must be inside building to barricade')
  assert(p_tile.barricade:roomForFortification(), 'There is no room available for fortifications')
  assert(p_tile.barricade:canPlayerFortify(player), 'Unable to make stronger fortification without required skills')
  assert(not p_tile.integrity:isState('ruined'), 'Unable to make fortifications in a ruined building')  
end

error_list[#error_list+1] = 'Must be inside building to barricade'
error_list[#error_list+1] = 'There is no room available for fortifications'
error_list[#error_list+1] = 'Unable to make stronger fortification without required skills'
error_list[#error_list+1] = 'Unable to make fortifications in a ruined building'

function criteria.fuel(player)
  local p_tile = player:getTile()
  assert(playerInsideBuilding(player), 'Must be inside building to refuel')
  assert(p_tile.generator:isPresent(), 'Missing nearby generator to refuel')
end

error_list[#error_list+1] = 'Must be inside building to refuel'
error_list[#error_list+1] = 'Missing nearby generator to refuel'

function criteria.generator(player)
  assert(playerInsideBuilding(player), 'Must be inside building to install generator')
end

error_list[#error_list+1] = 'Must be inside building to install generator'

function criteria.transmitter(player)
  assert(playerInsideBuilding(player), 'Must be inside building to install transmitter')
end

error_list[#error_list+1] = 'Must be inside building to install transmitter'

function criteria.terminal(player)
  assert(playerInsideBuilding(player), 'Must be inside building to install terminal')
end

error_list[#error_list+1] = 'Must be inside building to install terminal'

function criteria.toolbox(player)
  assert(playerInsideBuilding(player), 'Must be inside building to repair')
  local p_tile = player:getTile()
  local can_repair_building = p_tile.integrity:canModify(player)
  assert(can_repair_building, 'Unable to repair building in current state')
end

error_list[#error_list+1] = 'Must be inside building to repair'
error_list[#error_list+1] = 'Unable to repair building in current state'  

--[[
--- JUNK
--]]

function criteria.book(player) end  -- need light?

function criteria.newspaper(player) end  -- need light?

function criteria.bottle(player) end

--[[
--- ARMOR
--]]

function criteria.leather(player) end  -- make sure there is inventory room when unequiping armor?

function criteria.firesuit(player) end

return criteria