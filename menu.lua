--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )

local scene = composer.newScene()

local backGroup, mainGroup, uiGroup, codeGroup, cmdGroup

local q = require"base"
local player

local masCode = {}
local elements = {}
local pos
local code = "DDDUUU"
local index = 1
local line = 11
local function Do()
  if index==#code+1 then return end
  local cmd = code:sub(index,index)
  if cmd=="U" then
    transition.to( player, {y=player.y-100,time=200} )
    timer.performWithDelay( 500, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="D" then
    transition.to( player, {y=player.y+100,time=200} )
    timer.performWithDelay( 500, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="L" then
    transition.to( player, {x=player.x-100,time=200} )
    timer.performWithDelay( 500, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="R" then
    transition.to( player, {x=player.x+100,time=200} )
    timer.performWithDelay( 500, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="*" then
    if code:sub(index+3,index+3)~="0" then
      local numFor = code:sub(index+1,index+1)
      local num = code:find("#"..numFor)
      code = code:sub(1, index+2)..(tonumber(code:sub(index+3,index+3))-1)..code:sub(index+4, -1)
      index = num+2
      Do()
    else
      index = index + 1
      Do()
    end
  else
    index = index + 1
    Do()
  end
end

local function allDown()
  local index = 1
  local log = {}
  for i=1, line do
    local text = "{"
    for i=1, line do
      text = text .. tostring( elements[i]) ..", "
    end
    print(text.."}")
    if elements[i]==nil then
      local nullPose = i

      local nowPose = 1
      for j=nullPose+1, line do
        nowPose=j
        if elements[j]~=nil then break end 
        if line == j then return end
      end
      print(nullPose)
      transition.to(elements[nowPose],{y=pos+50*nullPose-20})
      elements[nowPose].num = nullPose
      -- log[#log+1] = {i,ind}
      local a = elements[nowPose]
      elements[nullPose] = a
      elements[nowPose]=nil
    end
  end 
end

local function moveElement(event)

end

function scene:create( event )
  local sceneGroup = self.view

  backGroup = display.newGroup()
  sceneGroup:insert(backGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  codeGroup = display.newGroup()
  sceneGroup:insert(codeGroup)

  cmdGroup = display.newGroup()
  codeGroup:insert(cmdGroup)

  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  player = display.newRect( mainGroup, q.cx, q.cy, 30, 30 )
  player:setFillColor( 1, 0 ,0)

  local backCode = display.newRect( codeGroup, 0, q.fullh, q.fullw, q.fullh*.4 )
  backCode.anchorX=0
  backCode.anchorY=1
  backCode.alpha=.8
  backCode.fill={1}

  local blue = "457B9D"
  local blueButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+150, 100, 100 )
  blueButton.anchorX=1
  -- blueButton.fill={.3,.3,1}
  blueButton.fill=q.CL(blue)

  local red = "E63946"
  local redButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+300, 100, 100 )
  redButton.anchorX=1
  redButton.fill=q.CL(red)
  -- redButton.fill={1,.3,.3}

  local green = "b7ffc7"
  local greenButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+450, 100, 100 )
  greenButton.anchorX=1
  greenButton.fill=q.CL(green)
  -- greenButton.fill={1,.3,.3}
  
  pos = backCode.y-backCode.height

  for i=1, line do
    local text = display.newText( codeGroup, i, 35, pos-25 + 50 * i, "qv.ttf", 35 )
    text.fill={0,.2,.2}
  end


  local cmdB = { up = "U",down="D",right="R",left="L",pick="P"}

  blueButton:addEventListener( "tap", 
    function()
      local pop = display.newGroup()
      pop.alpha=0
      transition.to(pop,{alpha=.9,time=100})
      codeGroup:insert( pop )
      
      local backClose = display.newRect(pop, q.cx, q.cy, q.fullw, q.fullh)
      backClose.alpha=.01
      backClose:addEventListener( "tap", function() display.remove(pop) end )

      local backList = display.newRect( pop, q.fullw-130, q.fullh-30, 500, 600 )
      backList.fill=q.CL(blue)
      backList.anchorY=1
      backList.anchorX=1

      local x, y = backList.x-(backList.width*.5), backList.y-backList.height
      local i=0
      local blue = q.CL(blue)
      blue[1]=blue[1]*1.4
      blue[2]=blue[2]*1.4
      blue[3]=blue[3]*1.4
      for k, v in pairs(cmdB) do
        print("ji")
        local elem = display.newGroup()
        elem.x = x
        elem.y = y+110*i+80
        elem.cmd = v
        pop:insert( elem )

        local rect = display.newRect(elem, 0, 0, backList.width*.8, 80)
        rect.fill = blue 
        
        local text = display.newText(elem, (k):upper(), 0, -5, native.newFont( "qv.ttf" ), 72)
        i = i + 1

        elem:addEventListener( "touch", 
          function(event) 
            local phase = event.phase
            display.currentStage:setFocus( elem )
            local IN = false
            if ( "began" == phase ) then
              codeGroup:insert( elem )
              display.remove(pop)

              elem.mouseX = event.x
              elem.mouseY = event.y
              elem.oldposX = elem.x
              elem.oldposY = elem.y

              if elem.enable==true then
                print("delete",elem.num,elem.cmd)
                elements[elem.num] = nil
              end
              
            elseif ( "moved" == phase ) then
              if elem.mouseX and elem.oldposX then
                elem.x = elem.oldposX+(event.x-elem.mouseX)
                elem.y = elem.oldposY+(event.y-elem.mouseY)
              else
                display.currentStage:setFocus( nil )
              end
            elseif ( "ended" == phase or "cancelled" == phase ) then
              display.currentStage:setFocus( nil )

              if elem.y<(backCode.y-backCode.height) then
                display.remove(elem)
              else
                elem.x=170
                elem.anchorX=0
                elem.xScale=.5
                elem.yScale=.5

                if IN==false then
                -- print(569/11)
                  local a = q.round((elem.y-pos)/51)
                  elements[a] = elem
                  elem.num=a
                  -- print(a)
                  elem.y = pos-20 + 50 * a

                  elem.enable = true
                  -- transition.to()
                  allDown()

                else

                end

              end
            -- end 
            -- )
          end
          return true
        end 
        )
      end
    end
  )

  Do()
end


function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then

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
