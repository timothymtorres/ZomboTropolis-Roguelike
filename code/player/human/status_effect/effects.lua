local Entangle = require('code.player.status_effect.entangle')
local Infection = require('code.player.human.status_effect.infection')
local Immunity = require('code.player.human.status_effect.immunity')
local Track = require('code.player.human.status_effect.track')

local effect = {Entangle, Infection, Immunity, Track}

for _, Class in ipairs(effect) do
  local class_name = string.lower(Class.name)
  effect[class_name] = Class
end

return effect