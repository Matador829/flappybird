
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()

-- Initialize variables
local bird
local gameLoopTimer
local score = 0
local scoreText
local earth
local obsWidth = 50
local obsHeight = 500
local obsList = {}
local dead = false
local loser

-- Set up display groups
local backGroup -- Display group for the background image
local mainGroup  -- Display group for the bird and obstacles.
local uiGroup  -- Display group for UI objects like the score




-----------------------------------------------------------------------------------------
--
-- FUNCTIONS
--
-----------------------------------------------------------------------------------------
local function createObstacle()

    height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

    local obstacleTop = display.newRect( mainGroup, display.contentWidth+obsWidth, height+350, obsWidth, obsHeight)
    elements:insert(obstacleTop)
    obstacleTop.myName = "obsTop"
    obstacleTop.scoreAdded = false
    physics.addBody( obstacleTop, "static")

    local obstacleBottom = display.newRect( mainGroup, display.contentWidth+obsWidth, height-350, obsWidth, obsHeight)
    elements:insert(obstacleBottom)
    obstacleBottom.myName = "obsBot"
    physics.addBody( obstacleBottom, "static")

    left = transition.to( obstacleTop, {time=4000, x = -obstacleTop.x })
    left = transition.to( obstacleBottom, {time=4000, x = -obstacleBottom.x })

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

local function increaseScore()
  for i = elements.numChildren, 1, -1 do
      if ( elements[i].x <= display.contentCenterX-90) and (elements[i].scoreAdded == false)
      then
          -- Increase score
          score = score + 1
          scoreText.text = "Score: " .. score
          elements[i].scoreAdded = true
      end
  end
end

Runtime:addEventListener( "touch", flap)

local function gameLoop()

    -- Create new obstacle
    if (dead ~= true)
    then
      timer.performWithDelay( 1000, createObstacle(), 0 )
      increaseScore()
      --createObstacle()
      --increaseScore()
    end
    -- Remove obstacles which have drifted off screen
    for i = elements.numChildren, 1, -1 do
        --local thisObstacle = obsList[i]
        --print(obsList[i])
        if ( elements[i].x < -obsWidth )
        then
            --display.remove( thisObstacle )
            --table.remove( obsList, i )
            elements:remove(elements[i])
        end
    end
end

local function endGame()
    display.remove( loser )
    composer.setVariable( "finalScore", score )
		composer.removeScene( "highscores" )
		composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

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
            loser = display.newText("LOSER", display.contentCenterX, display.contentCenterY, native.systemFont, 44 )
            loser:setFillColor( 1, 0, 1 )
            timer.performWithDelay( 2000, endGame )
        end
    end
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the bird
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

  elements = display.newGroup()
  elements.anchorChildren = true
  elements.anchorX = 0
  elements.anchorY = 1
  elements.x = 0
  elements.y = 0
  sceneGroup:insert(elements)

  -- Load content
  vertices = {-22/2,-15/2,20/2,-20/2,23/2,13/2,-27/2,26/2,-18/2,14/2}
  bird = display.newPolygon(mainGroup, 100, 100, vertices )
  bird.x = display.contentCenterX-90
  bird.y = display.contentCenterY
  physics.addBody( bird, "dynamic", {isSensor=true } )
  bird.myName = "bird"


  earth = display.newRect( mainGroup, display.contentCenterX, display.contentHeight+30, 320, 30)
  physics.addBody( earth, "static")
  earth.myName = "earth"

  scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX, 10, native.systemFont, 15)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
    physics.pause()
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
