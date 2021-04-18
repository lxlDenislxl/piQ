local composer = require( "composer" )

local scene = composer.newScene()

local backGroup, mainGroup, uiGroup

local q = require"base"

function scene:create( event )
  local sceneGroup = self.view

  backGroup = display.newGroup()
  sceneGroup:insert(backGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)


  local back = display.newImageRect( backGroup, "pack.png", q.fullw, q.fullh )
  back.x=q.cx
  back.y=q.cy

  back:addEventListener( "tap", function() composer.gotoScene("game") end )
end


function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    -- composer.gotoScene("game")  
  end
end


function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then

  end
end


function scene:destroy( event )

  local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
