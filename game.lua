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

local blue = "457B9D"
local red = "E63946"
local green = "b7eec7"

local were

local sizeX, sizeY = 7, 7
local map = {}
local cubeSize = q.fullw/sizeX

for i=1, sizeX, 1 do
  map[i] = {}
end--создание подмассивов(без него ошибка)

local masCode = {}
local elements = {}
local pos
local show
local index = 1
local line = 11
local pause = 1000
local speed = 800
local level = 1

local height, width = 64, .8
local shape_enemy = {
  0, height*1.4,
  -height*width, 0,
  height*width, 0
}
height, width = nil, nil
-- blueButton.cmd = { up = "U",down="D",right="R",left="L",pick="P"}
--   redButton.cmd = { For = "*1", While="I"}
--   greenButton.cmd = { Plus = "*1", Minus="I"}
local function clearMap()
  for x=1, sizeX do
    for y=1, sizeY do
      map[x][y].block=false
      map[x][y].exit=false
      map[x][y].fill={1}
      map[x][y].alpha=.2
    end
  end
end

local maps={
  {block={{x=1,y=2},{x=2,y=1},{x=4,y=5}},exit={{x=2,y=3}},playerZerPose={x=4,y=7}},
  {block={{x=2,y=2},{x=3,y= 3}},exit={{x=2,y=3}},playerZerPose={x=4,y=7}},
}

local function block(x,y)
  map[x][y].fill={type="image",filename="boch.png"}
  map[x][y].alpha=1
  map[x][y].block=true
  -- map[x][y].rotation = math.random(0,4) * 90
end

local function fillMap(level)
  clearMap()
  local blocks = maps[level].block
  for i=1, #blocks do
    block(blocks[i].x, blocks[i].y)
  end
end

local stop = true
local steps = 0
local playerZerPose = {x=4,y=7}
local function restart()
  steps = 0
  stop=true
  show.alpha=0
  player.x = cubeSize*(playerZerPose.x-.5)
  player.y = cubeSize*(playerZerPose.y-.5)
  player.mapx, player.mapy = 4, 7
end

local task = {{step=6,cmd=5}}
local function checkWin()
  local pop = display.newGroup( )
  uiGroup:insert( pop )

  local back = display.newRect( pop, q.cx, q.cy, q.fullw, q.fullh )
  back.fill={0}
  back.alpha=0
  transition.to(back,{alpha=.28,time=400})

  local infoPop = display.newGroup( )
  pop:insert( infoPop )

  infoPop.x=-q.cx
  infoPop.y=q.cy
  transition.to( infoPop, {x=q.cx,time=500,transition=easing.outCubic})

  local xp = display.newImageRect( pop, "xp.png", 500, 100 )
  xp.anchorX=0
  xp.anchorY=0

  local red, green = q.CL"ce4d4d", q.CL"5fd34f"
  local infoback = display.newImageRect( infoPop, "complete.png", 271*2.5, 256*2.5 )

  local stepLabel = display.newText( infoPop, "Кол-во шагов:", -infoback.width/2+35, -120, native.newFont("r_b.ttf"),47)
  stepLabel.anchorX=0

  local cmdLabel = display.newText( infoPop, "Кол-во команд:", -infoback.width/2+35, -45, native.newFont("r_b.ttf"),47)
  cmdLabel.anchorX=0

  local stepRight = display.newText( infoPop, steps.."/"..task[1].step, infoback.width/2-65, -120, native.newFont("r_b.ttf"),47)
  stepRight.anchorX=1

  local cmdRight = display.newText( infoPop, #elements.."/"..task[1].cmd, infoback.width/2-65, -45, native.newFont("r_b.ttf"),47)
  cmdRight.anchorX=1

  local color = steps>task[1].step and red or green
  stepRight:setFillColor( unpack(color) )
  stepLabel:setFillColor( unpack(color) )

  local color = #elements>task[1].cmd and red or green
  cmdLabel:setFillColor( unpack(color) )
  cmdRight:setFillColor( unpack(color) )

  local restartButt = display.newRect( infoPop, 0, 115, 160, 160 )
  restartButt.alpha=.01
  restartButt:addEventListener( "tap", function() restart() display.remove(pop) end )
  -- restartButt.fill={.5}
end

local function Do()
  if elements[index]==nil or stop==true then restart() return end 
  
  transition.to(show, {y=pos+50*index-20,time=150,transition=easing.outCubic })
  -- local cmd = code:sub(index,index)
  print(player.mapx,player.mapy,sizeY,player.mapy==sizeY)
  local cmd = elements[index].cmd
  if cmd=="U" then
    if player.mapy==1 or map[player.mapx][player.mapy-1].block==true then restart() return end
    steps = steps + 1
    player.mapy = player.mapy - 1
    transition.to( player, {y=player.y-cubeSize,time=speed} )
    timer.performWithDelay( pause, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="D" then
    if player.mapy==sizeY or map[player.mapx][player.mapy+1].block==true then restart() return end
    steps = steps + 1
    player.mapy = player.mapy + 1
    transition.to( player, {y=player.y+cubeSize,time=speed} )
    timer.performWithDelay( pause, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="L" then
    if player.mapx==1 or map[player.mapx-1][player.mapy].block==true then restart() return end
    steps = steps + 1
    player.mapx = player.mapx-1
    transition.to( player, {x=player.x-cubeSize,time=speed} )
    timer.performWithDelay( pause, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="R" then
    if player.mapx==sizeX or map[player.mapx+1][player.mapy].block==true then restart() return end
    steps = steps + 1
    player.mapx = player.mapx+1
    transition.to( player, {x=player.x+cubeSize,time=speed} )
    timer.performWithDelay( pause, function() Do(index+1) end )
    index = index + 1
  elseif cmd=="*" then
    elements[index].nowCycle=elements[index].cycle
    index = index + 1
    Do()
  elseif cmd=="#" then
    print("###")
    local startPoint = 0
    local fall = 1
    for i=index-1, 1, -1 do
      print(i, elements[i].cmd)
      if elements[i].cmd=="#" then
        fall = fall + 1
      elseif elements[i].cmd=="*" then
        fall = fall - 1
        if fall==0 then
          print("found")
          startPoint=i break
        end
      end
    end
    print(startPoint)
    if startPoint==0 then return end
    print(elements[startPoint].nowCycle,elements[startPoint].cycle)
    elements[startPoint].nowCycle = elements[startPoint].nowCycle - 1
    if elements[startPoint].nowCycle>0 then
      index = startPoint + 1
    else
      index = index + 1
    end   
    Do()

    -- if code:sub(index+3,index+3)~="0" then
    --   local numFor = code:sub(index+1,index+1)
    --   local num = code:find("#"..numFor)
    --   code = code:sub(1, index+2)..(tonumber(code:sub(index+3,index+3))-1)..code:sub(index+4, -1)
    --   index = num+2
    --   Do()
    -- else
    --   index = index + 1
    --   Do()
    -- end
  else
    index = index + 1
    Do()
  end
  -- local 
  -- timer.performWithDelay( speed, function() end )
  if map[player.mapx][player.mapy].exit == true then checkWin() restart() end
end

local deb = display.newText("1", 50,20,native.newFont("qv.ttf" ),50)
deb.alpha=0
deb.anchorX=0
deb.anchorY=0

local function updateDeb()
  local TXT = ""
  for i=1, line do
    if elements[i]~=nil then
      TXT = TXT..i..". "..elements[i].label.text.." #"..elements[i].num.."\n"
      -- print("#"..i, elements[i].label.text)
    else
      TXT = TXT..i..". ".."\n"
      -- print("#"..i.."clear")
    end
  end
  deb.text=TXT
  -- deb.alpha=0
end
local function allDown()
  local index = 1
  local log = {}
  for i=1, line do
    local text = "{"
    for i=1, line do
      text = text .. tostring( elements[i]) ..", "
    end
    -- print(text.."}")
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
  for i=1, line do
    if elements[i]~=nil then 
      elements[i].num = i
    end
  end
  updateDeb()
end


local wait = false
local function moveElement(event)
  if wait then print("waaaait")return end

  local phase = event.phase
  display.currentStage:setFocus( event.target )
  -- local IN = false
  if phase ~="moved" then updateDeb() end
  if ( "began" == phase ) then
    codeGroup:insert( event.target )
    display.remove(event.target.pop)
    event.target.pop=nil

    event.target.started = true
    event.target.mouseX = event.x
    event.target.mouseY = event.y
    event.target.oldposX = event.target.x
    event.target.oldposY = event.target.y

    print("num",event.target.num,event.target.cmd)
    -- if event.target.enable==true then --ЕСЛИ УЖЕ ВСТАВЛЕН
      -- print("delete",event.target.num,event.target.cmd)
    if event.target.num~=nil then
      elements[event.target.num] = nil
      -- allDown()
      updateDeb()
    end
    print("=======")
    for i=1, line do
      if elements[i]~=nil then
        print("#"..i, elements[i].label.text)
      else
        print("#"..i.."clear")
      end
    end
    
  elseif ( "moved" == phase ) then
    if event.target.started~=true then return end
    if event.target.mouseX and event.target.oldposX then
      event.target.x = event.target.oldposX+(event.x-event.target.mouseX)
      event.target.y = event.target.oldposY+(event.y-event.target.mouseY)
    else
      display.currentStage:setFocus( nil )
    end
  elseif ( "ended" == phase or "cancelled" == phase ) then
    display.currentStage:setFocus( nil )
    if event.target.pop~=nil or event.target.started~=true then return end

    if event.target.y<(pos) then
      display.remove(event.target)

    else
      -- wait = true
      -- timer.performWithDelay( 1000, function() wait=false end )
      event.target.started = false
      event.target.x=170
      event.target.anchorX=0
      event.target.xScale=.5
      event.target.yScale=.5

      -- if IN==false then
        local a = q.round((event.target.y-pos)/51)
        a = (a<1) and 1 or a
        if elements[a]==nil then 
          elements[a] = event.target
          print("clear add")
        else
          print("move add")
          for i=line, a, -1 do
            if elements[i]~=nil then
              transition.to(elements[i],{y=pos+50*(i+1)-20})
              elements[i].num = elements[i].num + 1
              local b = elements[i]
              elements[i+1]=b
              elements[i]=nil
            end  
          end
          elements[a] = event.target
        end
        event.target.num=a

        event.target.y = pos-20 + 50 * a

        if event.target.cycle and event.target.enable~=true then
          print("create end")

          local elem = display.newGroup()
          codeGroup:insert(elem)
          elem.x = event.target.x
          elem.y = pos+110*12+80
          elem.cmd = "#"
          elem.num = 12
          elem.xScale=.5
          elem.yScale=.5
          elem.enable = true

          local rect = display.newRect(elem, 0, 0, 500*.8, 80)
          rect.fill = q.CL(red) 
          
          local text = display.newText(elem, "END", 0, -5, native.newFont( "qv.ttf" ), 72)
          elem.label=text
          elem:addEventListener( "touch", moveElement)
          elements[line]=elem
        end
        event.target.enable = true
      -- else

      -- end
      
    end
    allDown()
    updateDeb()
    -- print("=======")
    
  end
  return true
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

  for i=1, sizeY, 1 do
    for j=1, sizeX, 1 do
      map[i][j] = display.newRect( mainGroup, cubeSize*(i-1), cubeSize*(j-1), cubeSize-5, cubeSize-5 )
      map[i][j].alpha=.2
      map[i][j].anchorX=0
      map[i][j].anchorY=0
      -- map[i][j].clear=true
      map[i][j].tx=i
      map[i][j].ty=j
      -- map[i][j].freeConnect={}
      -- for k=1, 4 do
      --   map[i][j].freeConnect[k]=false
      -- end
      print(i,j)
    end
  end-- создание карты

  -- map[4][3]:setFillColor( 0,1,0 )
  
  -- map[4][3].fill={type="image",filename="exit.png"}
  -- map[4][3].alpha=1
  -- map[4][3].exit=true

  -- -- map[4][6]:setFillColor( 1,0,0 )
  -- for i=1, 20 do
  --   local a,b = math.random( 1,7 ),math.random( 1,7 )
  --   if map[a][b].block~=true and map[a][b].exit~=true and not (a==4 and b==7) then
  --   block(a,b)
  --   end
  -- end



  local backCode = display.newRect( codeGroup, 0, q.fullh, q.fullw, q.fullh*.4 )
  backCode.anchorX=0
  backCode.anchorY=1
  backCode.alpha=.8
  backCode.fill={1}

  pos = backCode.y-backCode.height

  local back = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh )
  back:setFillColor( .2, .5, .3 )

  show = display.newPolygon( codeGroup, 320, pos+30, shape_enemy )
  show.alpha=0
  show.fill=q.CL(red)
  show.rotation = 90
  show.xScale=.5
  show.yScale=.5
  -- back.anchorX=0
  -- back.anchorY=0

  player = display.newImageRect( mainGroup, "robot1.png", 150, 100 )
  player.x, player.y = q.cx, cubeSize*(sizeY-0.5)
  player.mapx, player.mapy = 4, 7
  -- player:setFillColor( 1, 0 ,0)


  local blueButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+150, 100, 100 )
  blueButton.anchorX=1
  blueButton.type=1
  blueButton.fill=q.CL(blue)
  blueButton.colors=q.CL(blue)
  blueButton.color=q.CL(blue)

  blueButton.color[1]=blueButton.color[1]*1.4
  blueButton.color[2]=blueButton.color[2]*1.4
  blueButton.color[3]=blueButton.color[3]*1.4

  local redButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+300, 100, 100 )
  redButton.anchorX=1
  redButton.type=2
  redButton.fill=q.CL(red)
  redButton.colors=q.CL(red)
  redButton.color=q.CL(red)

  redButton.color[1]=redButton.color[1]*1.4
  redButton.color[2]=redButton.color[2]*1.4
  redButton.color[3]=redButton.color[3]*1.4
  -- redButton.fill={1,.3,.3}

  local greenButton = display.newRect(codeGroup, q.fullw, backCode.y-backCode.height+450, 100, 100 )
  greenButton.anchorX=1
  greenButton.type=3
  greenButton.fill=q.CL(green)
  greenButton.colors=q.CL(green)
  greenButton.color=q.CL(green)

  greenButton.color[1]=greenButton.color[1]*0.9
  greenButton.color[2]=greenButton.color[2]*0.9
  greenButton.color[3]=greenButton.color[3]*0.9

  local playButton = display.newPolygon(codeGroup, q.fullw-150, pos-50, shape_enemy)
  playButton.rotation=-90
  playButton.xScale=.8
  playButton.yScale=.8
  playButton:setFillColor( .2 )
  -- playButton.anchorX=1
  playButton:addEventListener( "tap", function() clearMap() if stop==true then steps=0 stop=false show.alpha=1 index=1 Do() end end )

  local stopButton = display.newRect(codeGroup, q.fullw-250,  pos-50, 75,75)
  stopButton:setFillColor( .2 )
  -- playButton.anchorX=1
  stopButton:addEventListener( "tap", function() if stop==false then stop=true restart() end end )

  

  for i=1, line do
    local text = display.newText( codeGroup, i, 35, pos-25 + 50 * i, "qv.ttf", 35 )
    text.fill={0,.2,.2}
  end


  blueButton.cmd = { up = "U",down="D",right="R",left="L",pick="P"}
  redButton.cmd = { For = "*", While="I"}
  greenButton.cmd = { Plus = "*1", Minus="I"}

  local function listGen(event)
    local pop = display.newGroup()
    pop.alpha=0
    transition.to(pop,{alpha=.9,time=100})
    codeGroup:insert( pop )
    
    local backClose = display.newRect(pop, q.cx, q.cy, q.fullw, q.fullh)
    backClose.alpha=.01
    backClose:addEventListener( "tap", function()  display.remove(pop) end )

    local backList = display.newRect( pop, q.fullw-130, q.fullh-30, 500, 600 )
    backList.fill=event.target.colors
    backList.anchorY=1
    backList.anchorX=1

    local x, y = backList.x-(backList.width*.5), backList.y-backList.height
    local i=0
    -- local blue = unpack{event.target.colors}
    -- blue[1]=blue[1]*1.4
    -- blue[2]=blue[2]*1.4
    -- blue[3]=blue[3]*1.4
    if event.target.type==1 or event.target.type==3 then
      for k, v in pairs(event.target.cmd) do
        local elem = display.newGroup()
        elem.x = x
        elem.y = y+110*i+80
        elem.cmd = v
        pop:insert( elem )

        local rect = display.newRect(elem, 0, 0, backList.width*.8, 80)
        rect.fill = event.target.color 
        
        local text = display.newText(elem, (k):upper(), 0, -5, native.newFont( "qv.ttf" ), 72)
        i = i + 1
        elem.label=text
        elem.pop = pop
        elem:addEventListener( "touch", moveElement)
      end
    else
      local elem = display.newGroup()
      elem.x = x
      elem.y = y+110*i+80
      elem.cmd = "*"
      elem.cycle=1
      elem.nowCycle=1
      pop:insert( elem )

      local rect = display.newRect(elem, 0, 0, backList.width*.8, 80)
      rect.fill = event.target.color 

      local numRect = display.newRect(elem, 120, 0, 100, 60)
      numRect.alpha=.3

      elem.cycle=1
      local numLabel = display.newText(elem, ("1"):upper(), 120, -5, native.newFont( "qv.ttf" ), 52)
      numRect:addEventListener( "tap", 
        function()

          local popNum = display.newGroup()
          -- popNum.alpha=0
          -- transition.to(popNum,{alpha=.9,time=100})
          elem:insert( popNum )
          
          -- local backClose = display.newRect(popNum, q.cx, 0, q.fullw*1.4, q.fullh*1.4)
          -- backClose.alpha=.01

          local back = display.newRect( popNum, rect.width*.5+50, 0, 380, 320 )
          back.anchorX=0
          back:addEventListener( "tap", function() 
            numLabel.text = elem.cycle
            elem.nowCycle =  elem.cycle+1-1
            display.remove(popNum) 
          end )

          local n = tostring(elem.cycle)
          local TxT = (elem.cycle>10) and ((n):sub(1,1).." "..(n):sub(2,2)) or ("0 " .. n)
          local editLabel = display.newText( popNum, TxT, back.x+back.width*.5, back.y-20, native.newFont( "qv.ttf" ), 252 )
          editLabel:setFillColor( 0 )

          local updateText = function()
            if elem.cycle<10 then
              editLabel.text = "0 "..tostring(elem.cycle)
            else
              editLabel.text = (tostring(elem.cycle)):sub(1,1).." "..(tostring(elem.cycle)):sub(2,2)
            end
          end
          local addLeft = display.newRect( popNum, back.x+90, -250, 80, 80 )
          addLeft:addEventListener( "tap", 
            function() 
              elem.cycle=elem.cycle+10
              if elem.cycle>100 then 
                elem.cycle = elem.cycle%10
              end
              
              updateText()
            end )
          local addRight = display.newRect( popNum, back.x+290, -250, 80, 80 )
          addRight:addEventListener( "tap", 
            function() 
              elem.cycle=elem.cycle+1
              if elem.cycle%10==0 then
                elem.cycle = elem.cycle - 10
              end
              updateText()
            end )

          local downLeft = display.newRect( popNum, back.x+90, 250, 80, 80 )
          downLeft:addEventListener( "tap", 
            function() 
              elem.cycle=elem.cycle-10
              if elem.cycle<0 then
                elem.cycle = elem.cycle + 100
              end
              updateText()
            end )
          local downRight = display.newRect( popNum, back.x+290, 250, 80, 80 )
          downRight:addEventListener( "tap", 
            function() 
              elem.cycle=elem.cycle-1
              if elem.cycle%10==9 then
                elem.cycle = elem.cycle + 10
              end
              updateText()
            end )

        end )

      local text = display.newText(elem, ("FOR"):upper(), -60, -5, native.newFont( "qv.ttf" ), 72)
      i = i + 1
      elem.label=text
      elem.pop = pop
      elem:addEventListener( "touch", moveElement)
    end
    -- blue[1]=blue[1]/1.4
    -- blue[2]=blue[2]/1.4
    -- blue[3]=blue[3]/1.4
  end

  blueButton:addEventListener( "tap", listGen )
  greenButton:addEventListener( "tap", listGen )
  redButton:addEventListener( "tap", listGen )
  -- Do()

end


function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    fillMap(1)
    -- checkWin()     
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
