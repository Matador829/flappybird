-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()

-- Initialize variables
local bird
local gameLoopTimer
local scoreText
local earth
local obsWidth = 100
local obsHeight = 500
local obsList = {}
local dead = false

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the bird and obstacles.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load content
vertices = {-22,-15,20,-20,23,13,-27,26,-18,14}
bird = display.newPolygon(mainGroup, 100, 100, vertices )
bird.x = display.contentCenterX-90
bird.y = display.contentCenterY
physics.addBody( bird, "dynamic", {isSensor=true } )
bird.myName = "bird"


earth = display.newRect( mainGroup, display.contentCenterX, display.contentHeight+30, 320, 30)
physics.addBody( earth, "static")
earth.myName = "earth"


-----------------------------------------------------------------------------------------
--
-- FUNCTIONS
--
-----------------------------------------------------------------------------------------
local function createObstacle()

    height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

    local newObstacleTop = display.newRect( mainGroup, display.contentWidth+obsWidth, height+350, obsWidth, obsHeight)
    table.insert( obsList, newObstacleTop )
    newObstacleTop.myName = "obsTop"
    physics.addBody( newObstacleTop, "static")

    local newObstacleBottom = display.newRect( mainGroup, display.contentWidth+obsWidth, height-350, obsWidth, obsHeight)
    table.insert( obsList, newObstacleBottom )
    newObstacleBottom.myName = "obsBot"
    physics.addBody( newObstacleBottom, "static")

    left = transition.to( newObstacleTop, {time=3000, x = -newObstacleTop.x })
    left = transition.to( newObstacleBottom, {time=3000, x = -newObstacleBottom.x })

end

local function fall( event )
  if (dead ~= true) then
    falling = transition.to( bird, {time=800, y=bird.y+500, transition=easing.inSine} )
    fallrot = transition.to( bird, {time=500,rotation=60, transition=easing.inSine} )
  end

end

local function flap( event )
    if event.phase == "began" and (dead ~= true) then
        bird.rotation = -20
        transition.cancel(bird) --cancel all transition
        up = transition.to( bird, {y=bird.y - 50,time=200,transition=easing.outSine, onComplete=fall})
    end
end

Runtime:addEventListener( "touch", flap)

local function gameLoop()

    -- Create new obstacle
    if (dead ~= true)
    then
      createObstacle()
    end
    -- Remove obstacles which have drifted off screen
    for i = #obsList, 1, -1 do
        local thisObstacle = obsList[i]

        if ( thisObstacle.x < -obsWidth )
        then
            display.remove( thisObstacle )
            table.remove( obsList, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 3000, gameLoop, 0 )

local function onCollision( event )

    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bird" and obj2.myName == "obsTop" ) or
             ( obj1.myName == "obsTop" and obj2.myName == "bird" ) or
             ( obj1.myName == "bird" and obj2.myName == "obsBot" ) or
             ( obj1.myName == "obsBot" and obj2.myName == "bird" ) or
             ( obj1.myName == "bird" and obj2.myName == "earth" ) or
             ( obj1.myName == "earth" and obj2.myName == "bird" ))
        then
            dead = true
            display.remove( bird )
            transition.cancel()
        end
    end
end

Runtime:addEventListener( "collision", onCollision )
