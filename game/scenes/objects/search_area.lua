
-- Module/class for platfomer hero

-- Use this as a template to build an in-game mob

-- Define module
local M = {}
local composer = require( "composer" )

local MAX_MOVEMENT_DELAY = 20 * 100
local MIN_MOVEMENT_DELAY = 10 * 100
local ANIMATION_DELAY = 0

function M.new( object )	
	if not object then error( "ERROR: Expected display visual" ) end
	local search_area = object:getVisual() 
	search_area.alpha = 0.01 -- the minimal alpha for tap/touch events to register
	search_area.timer_ID = nil -- the variable location for our timer object

	local function getMobSprite(player)
		local location = object.map
		local mob_layer = location:getObjectLayer('Mob')
		local mob_obj = mob_layer:getObject(player:getUsername())
		return mob_obj:getVisual()
	end

	local function unfreezeMobSprite()
		local mob_sprite = getMobSprite(main_player)
	    mob_sprite:setStationary(false)
	end

	function search_area.search(event)
		if main_player:canPerform('search') then
			local mob_sprite = getMobSprite(main_player)
			local time_delay = math.random(MIN_MOVEMENT_DELAY, MAX_MOVEMENT_DELAY)
			mob_sprite:move(search_area.x, search_area.y, time_delay)
			mob_sprite:setStationary(true)

			local result = main_player:perform('search')
		else
			-- make error sound
		end
	end

	function search_area.timer(event) search_area.search(event) end

	function search_area.touch(event)
		local mob_sprite = getMobSprite(main_player)

	    if ( event.phase == "began" ) then
	        display.getCurrentStage():setFocus( event.target )  --'event.target' is the touched object
	        search_area.timer_ID = timer.performWithDelay(300, search_area, 0)
	    elseif (event.phase == "moved") then
	    	timer.cancel(search_area.timer_ID)
	    	timer.performWithDelay(MAX_MOVEMENT_DELAY + ANIMATION_DELAY, unfreezeMobSprite, 1)
	    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
	        display.getCurrentStage():setFocus( nil )  --setting focus to 'nil' removes the focus
	        timer.cancel(search_area.timer_ID)
	    	timer.performWithDelay(MAX_MOVEMENT_DELAY + ANIMATION_DELAY, unfreezeMobSprite, 1)
	    end
		return true
	end

	function search_area.tap(event)
		local mob_sprite = getMobSprite(main_player)
	    if ( event.numTaps == 2 ) then 
	    	search_area.search(event) 
	    	timer.performWithDelay(MAX_MOVEMENT_DELAY + ANIMATION_DELAY, unfreezeMobSprite, 1)
	    end
	end

	local player_stage = main_player:getStage()
	local search_area_is_same_stage_as_player = object.name == player_stage

	if search_area_is_same_stage_as_player and main_player:isMobType('human') then
		search_area:addEventListener("touch", search_area.touch)
		search_area:addEventListener("tap", search_area.tap)		
	end

	return search_area
end

return M
