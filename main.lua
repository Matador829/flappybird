-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Seed the random number generator
math.randomseed( os.time() )

-- Initialize variables
local score = 0
local died = false
local bird
local gameLoopTimer
local scoreText
local earth
local obstacleTable = {}

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the bird and obstacles.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load content
vertices = {-22,-15,20,-20,23,13,-27,26,-18,14}
bird = display.newPolygon(mainGroup, 100, 100, vertices )
bird.x = display.contentCenterX-90
bird.y = display.contentCenterY
bird.myName = "bird"

earth = display.newRect( mainGroup, display.contentCenterX, display.contentCenterY+210, 320, 30 )

sky = display.newRect( mainGroup, display.contentCenterX, display.contentCenterY-300, 320, 30 )

-----------------------------------------------------------------------------------------
--
-- FUNCTIONS
--
-----------------------------------------------------------------------------------------
local function createObstacle()

    local newObstacle = display.newRect( mainGroup, display.contentWidth, display.contentHeight/2, 100, display.contentHeight)
    table.insert( obstacleTable, newObstacle )
    newObstacle.myName = "obstacle"

    left = transition.to( newObstacle, {time=3000, x = -newObstacle.x })

end


local function fall( event )
    falling = transition.to( bird, {time=800, y=bird.y+500, transition=easing.inSine} )
    fallrot = transition.to( bird, {time=500,rotation=60, transition=easing.inSine} )
end

local function flap( event )
    if event.phase == "began" then
        bird.rotation = -20
        transition.cancel(bird) --cancel all transition
        up = transition.to( bird, {y=bird.y - 50,time=200,transition=easing.outSine, onComplete=fall})
    end
end

Runtime:addEventListener( "touch", flap)

local function gameLoop()

    -- Create new asteroid
    createObstacle()

    -- Remove asteroids which have drifted off screen
    for i = #obstacleTable, 1, -1 do
        local thisObstacle = obstacleTable[i]
        print(thisObstacle)
        if ( thisObstacle.x < -60)
        then
            display.remove( thisObstacle )
            table.remove( obstacleTable, i )
            print('Removed')
        end
    end
end

gameLoopTimer = timer.performWithDelay( 3000, gameLoop, 0 )
