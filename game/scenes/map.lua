-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
berry = require( 'code.libs.berry.berry' )
local json = require( "json" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

local width, height = display.contentWidth, display.contentHeight -- 320x480
local widget = require('widget')
local city
-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )
  local sceneGroup = self.view

  -- Load our map
  local filename = "graphics/map/city_map.json"
  city = berry.loadMap( filename, "graphics/map" )

  local visual = berry.createVisual( city )
  city:setScale(1)

  local tile_w, tile_h = city.tilewidth, city.tileheight
  local player_x, player_y = 1, 1 -- insert player coords here later

  local x = (-1 * player_y * tile_w / 2) + (player_x * tile_w  / 2) 
  local y = (player_x * tile_h / 2) - (-1 * player_y * tile_h / 2)

  city:setPosition (x, y)

  return sceneGroup
end

local lastEvent = {}
local max_scale, min_scale = 2.00, 0.25  -- only applies to zoom in/out

local function key( event )
  local phase = event.phase
  local name = event.keyName
  --if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
  if phase == "down" then
    local scale = city:getScale()

    if "up" == name and scale < max_scale then
      city:scale(0.25)
    elseif "down" == name and scale > min_scale then
      city:scale(-0.25)
    elseif "up" == name then -- zoom into city if viewing map
      local scene = composer.getSceneName('current')
      composer.removeScene(scene)      

      local options = {effect = "fade", time = 500,}   
      composer.gotoScene('scenes.room', options)      
    elseif "down" == name then -- zoom into map if viewing room
    end
  end


  lastEvent = event
end

local function movePlatform(event)
    local platformTouched = event.target
    if (event.phase == "began") then
        display.getCurrentStage():setFocus( platformTouched )

        -- here the first position is stored in x and y         
        platformTouched.startMoveX = platformTouched.x
        platformTouched.startMoveY = platformTouched.y 
    elseif (event.phase == "moved") then
        -- here the distance is calculated between the start of the movement and its current position of the drag  
        local x_pos = (event.x - event.xStart) + platformTouched.startMoveX
        local y_pos = (event.y - event.yStart) + platformTouched.startMoveY
        local left_boundry, right_boundry = platformTouched.contentWidth * 0.25, display.actualContentWidth - platformTouched.contentWidth * 1.25
        local top_boundry, bottom_boundry = platformTouched.contentHeight * 0.25, display.actualContentHeight - platformTouched.contentHeight * 1.25

        platformTouched.x = (x_pos > left_boundry and math.min(x_pos, left_boundry)) or (x_pos < right_boundry and math.max(x_pos, right_boundry)) or x_pos 
        platformTouched.y = (y_pos > top_boundry and math.min(y_pos, top_boundry)) or (y_pos < bottom_boundry and math.max(y_pos, bottom_boundry)) or y_pos 
    elseif event.phase == "ended" or event.phase == "cancelled"  then
        -- here the focus is removed from the last position
        display.getCurrentStage():setFocus( nil )
    end
    return true
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    
        Runtime:addEventListener("key", key)  
        city.world:addEventListener( "touch", movePlatform )  -- Add a "touch" listener to the object        
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
        Runtime:removeEventListener( "key", key )          
        timer.pause(room_timer)
    end  
end


-- "scene:destroy()"
function scene:destroy( event )

    city:destroy()   
    Runtime:removeEventListener( "enterFrame", enterFrame )      
    Runtime:removeEventListener( "key", key )     

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene