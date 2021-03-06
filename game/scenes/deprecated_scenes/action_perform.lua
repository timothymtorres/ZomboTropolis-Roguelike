-----------------------------------------------------------------------------------------
--
-- action_perform.lua
--
-----------------------------------------------------------------------------------------


local composer = require( "composer" )
local scene = composer.newScene()
local widget = require('widget')

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

-- local forward references should go here
local cancel_button = require('scenes.action.button.cancel_button')
local perform_button = require('scenes.action.button.perform_button')
local target_picker_wheel = require('scenes.action.button.target_picker_wheel')

-- 52 is default tabbar height
local width, height = display.contentWidth, display.contentHeight - 52 --320, 428

local top_container_w, top_container_h = math.floor(width*0.875 + 0.5), math.floor(height*0.35 + 0.5)
local bottom_container_w, bottom_container_h = math.floor(width*0.925 + 0.5), math.floor(height*0.518 + 0.5)

-- might want to consider doing a list of actions that do NOT require a bottom container/wheel
local bottom_container_list = {'attack', 'gesture', 'acid', 'drag_prey', 'syringe'}  -- armor
for _,action in ipairs(bottom_container_list) do bottom_container_list[action] = true end  -- put our actions as booleans

local divider = 15
local action_text
local listener = {}

local wheel, targets, weapons
local action_params = {}
local item, inv_id

local function getActionText(action)
  local str = action
  if wheel then
    local selections = wheel:getValues()  -- {selections[i].value, selections[i].index} [1]=targets, [2]=weapons
    local target_name = selections[1].value  
    str = str..' -> '..target_name..' ('..targets[selections[1].index]:getStat('hp')..'hp)'   
    
    local weapon = selections[2]
    if weapon then 
      local weapon_name = selections[2].value      
      str = str..' -> '..weapon_name 
      --[[-- OLD CODE --------------------
      local selections = wheel:getValues()  -- {selections[i].value, selections[i].index} [1]=targets, [2]=weapons
      local weapon, target = weapons[selections[2].index].weapon, targets[selections[1].index]
      local weapon_name, target_name = selections[2].value, selections[1].value
      local condition = (not weapon:isOrganic() and '{'..weapon:getCondition()..'}') or ''   
      str = 'Attack '..target_name..' ('..targets[selections[1].index]:getStat('hp')..'hp) using '..weapon_name..'?\n'..'['..weapon:getDice(main_player)..']   ('..weapon:getToHit(main_player, target)..'% to-hit)   '..condition 
      --]]-- OLD CODE --------------------
    end
  end
  return str
end

local performButtonEvent = function(event_button)
  if ('ended' == event_button.phase) then
    print('Perform button was pressed and released')    
    if active_timer then timer.cancel(active_timer) end  
    
    -- params = {inv_id, target}           This has to be the order for ITEM actions
    -- params = {target, weapon, inv_id}   This has to be the order for ATTACK action (inv_id is the last arg because it's optional)
    
    if item then action_params[#action_params + 1] = inv_id end -- used when an item action is underway (the item is SELECTED for use)  
    
    if wheel then 
      local selections = wheel:getValues()       
      action_params[#action_params + 1] = targets[selections[1].index] --target
      
      local weapon = weapons and weapons[selections[2].index].weapon
      local inv_id = weapons and weapons[selections[2].index].inventory_ID -- used when the attack action is underway and weapon item(s) is present  (the item is WAITING for selection) 
      --inv_id is local scope in this line of code due to potential issues with it overwriting inv_id for scene:create causing an item action (it's an attack action) 
      if weapon then 
        action_params[#action_params + 1] = weapon 
        action_params[#action_params + 1] = inv_id
      end
    end  
    
    main_player:takeAction(unpack(action_params))
    composer.hideOverlay('fade', 400)       
    composer.gotoScene('scenes.action')
  end
end

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )
   local sceneGroup = self.view
   --local parent = event.parent
   local params = event.params
   local action = event.params.id
   
   inv_id = event.params.inv_id
   if inv_id then -- dealing with an item action
     item = main_player.inventory:lookup(event.params.inv_id)
   end
   
   action_params[#action_params + 1] = action   
   
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    
    -------------------------------
    -------------------------------
    -- T O P   C O N T A I N E R --
    -------------------------------
    -------------------------------
    
    local bar_h = 30        
    local top_container = display.newContainer( top_container_w, top_container_h + bar_h)  
    top_container:translate( width*0.5, height*0.5 + bar_h*0.5 - bottom_container_h*0.5) -- center the container
    top_container_h = top_container_h - bar_h*0.5  -- center the container along the y-axis?!?

    local background = display.newRect(0, 0, top_container_w, top_container_h)
    background:setFillColor(0.1, 0.1, 0.1, 0.70)
    top_container:insert(background)
    
    local top_background_bar = display.newRect(0, -1*(top_container_h/2 + bar_h*0.5), top_container_w, bar_h) 
    top_background_bar:setFillColor(0.2, 0.2, 0.8, 0.70)
    top_container:insert(top_background_bar)
    
    local action_cost = display.newText{
      text = 'Perform Action For: '..params.cost..' AP', 
      x = 0,
      y = -1*(top_container_h/2 + bar_h*0.375), 
      font = native.systemFont, 
      fontSize = 14,
    }
    action_cost:setFillColor(1, 0, 0, 1)
    top_container:insert(action_cost)
    
    --------------------
    -- PERFORM BUTTON --
    --------------------
    perform_button.top, perform_button.left = top_container_h/7, -1*(perform_button.width + divider)   
    perform_button.onEvent = performButtonEvent
    perform_button = widget.newButton(perform_button)
    top_container:insert(perform_button) 

    -------------------
    -- CANCEL BUTTON --
    -------------------
    cancel_button.top, cancel_button.left = top_container_h/7, divider    
    cancel_button = widget.newButton(cancel_button) 
    top_container:insert(cancel_button) 

    -------------------------------------
    -------------------------------------
    -- B O T T O M   C O N T A I N E R --
    -------------------------------------
    -------------------------------------

    local bottom_container = bottom_container_list[action] and display.newContainer(bottom_container_w, bottom_container_h)
    
    if bottom_container then
      bottom_container:translate( width*0.5, height - (top_container_h)) -- center the container   
      
      -----------------------------------------------------------------------------------------------------------
      -- These functions are so that the wheel values update the action text in real time while it is spinning --
      ---------- Possibly change or remove these later when the sprites are added and wheel is removed ----------
      -----------------------------------------------------------------------------------------------------------    
      
      local function redoActionText()
          action_text:removeSelf()
          action_text = nil
          
          action_text = display.newText{
            text = getActionText(action),
            width = top_container_w - 10, 
            x = 5,
            y = -40,
            font = native.systemFont,
            fontSize = 18,
            align = 'center',
          }
          action_text:setFillColor(1, 1, 1, 1)
          top_container:insert(action_text)      
      end
      
      function listener:timer( event )
        -- this prevents multiple timers from running by stopping the previous active timer if present
        if active_timer and (tostring(active_timer) ~= tostring(event.source)) then 
          timer.cancel(active_timer) 
        end
        
        active_timer = event.source  -- active_timer needs to be a global!
        redoActionText()        
      end  
      
      local function wheelTouchListner( event )
          if event.phase == "began" then
              print( "You touched the object!")
              timer.performWithDelay(500, listener, 20)
          end
      end

      local wheel_hitbox = display.newRect(0, 0, 320, 222 )  
      wheel_hitbox.isVisible, wheel_hitbox.isHitTestable = false, true
      wheel_hitbox:addEventListener( "touch", wheelTouchListner )   
      
      -------------------
      -- WHEEL  PICKER --
      -------------------    
      
      targets = main_player:getTargets(action)  -- the only action that should have an effect on this func is 'gesture', the rest should be safely ignored as an arg
      if action == 'attack' then weapons = main_player:getWeapons() end  -- only attack actions use weapons
      wheel = target_picker_wheel(targets, weapons) 
      wheel.top = -1*(bottom_container_h*0.5)
      wheel.left = -1*(bottom_container_w*0.5)-15  -- not sure what the -15 is for?
      wheel = widget.newPickerWheel(wheel)
      
      bottom_container:insert(wheel)
      bottom_container:insert(wheel_hitbox) -- it's not visible
    end
    
    -- Action text needs to have the wheel setup before it can get the text (since the wheel selection returns the target/item/etc. strings)
    action_text = display.newText{
      text = getActionText(action),
      width = top_container_w - 10, 
      x = 5,
      y = -40,
      font = native.systemFont,
      fontSize = 18,
      align = 'center',
    }
    action_text:setFillColor(1, 1, 1, 1)
    top_container:insert(action_text)    
   
    sceneGroup:insert(top_container)
    if bottom_container then sceneGroup:insert(bottom_container) end
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene