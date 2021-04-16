local round = function(num, idp)
  local mult = (10^(idp or 0))
  return math.floor(num * mult + 0.5) *(1/ mult)
end

local function CL(code)
  code = code:lower()
  code = code and string.gsub( code , "#", "") or "FFFFFFFF"
  code = string.gsub( code , " ", "")
  local colors = {1,1,1,1}
  while code:len() < 8 do
    code = code .. "F"
  end
  local r = tonumber( "0X" .. string.sub( code, 1, 2 ) )
  local g = tonumber( "0X" .. string.sub( code, 3, 4 ) )
  local b = tonumber( "0X" .. string.sub( code, 5, 6 ) )
  local a = tonumber( "0X" .. string.sub( code, 7, 8 ) )
  local colors = { r/255, g/255, b/255, a/255 }
  return colors
end

local graphicsOpt={
  [0]={
    homeBack={
      type = "gradient",
      color1 = { 38/255, 8/255, 103/255 },
      color2 = { 20/255, 8/255, 55/255 },
      direction = -40
    }, 
    tex=30, w=130*.7, h=180*.7
  },
  {homeBack={.1,.5,.5},   tex=10, w=110, h=160},
  {homeBack={.21,.07,.4}, tex=30, w=130, h=180},
  {homeBack=CL("bf5c4c"), tex=5, w=120,  h=180},
  {homeBack={.1,.1,.1},   tex=0, w=150*.9,  h=170},
  {homeBack={.1,.1,.1},   tex=0, w=160,  h=220},
  {homeBack={.4},   tex=0, w=160,  h=120},
  {homeBack={type="image",filename = "img/style7/bNUM.jpg",direction=0},   tex=0, w=110,  h=160},
}


local events = {list={}}
local timers = {tags={}}



local function onTimer(tag)
  timer.performWithDelay( timers[tag].time, timers[tag].func, timers[tag].cycle, tag )
end


local function openFile(dir)
  local file = io.open( dir, "r" )
 
  local data
  if file then
    local contents = file:read( "*a" )
    io.close( file )
    data = json.decode( contents )
  end
  return data
end


local function saveFile(data,dir)
  local file = io.open( dir, "w" )
 
  if file then
    file:write( json.encode( data ) )
    io.close( file )
  end
end

local options={
  [0]=
  {
    star={color={{5,8}, true, 1}, size=12}, 
    playBack={type = "gradient", color1 = { 55/255, 0, 101/255 }, color2 = { 25/255, 21/255, 65/255 },
    direction = -math.random(-360,360)}, enemy={1,.2,.2}, tex=30, w=70, h=100
  },
  {
    star=
    {
      color={.5,{8,10},{9,10}}, 
      size=12
    }, 
    playBack={.1,.5,.5},
    enemy={.2,1,1},
    tex=50,
    w=80,
    h=120
  },
  {star={color={{7,9},true,1}, size=10},   playBack={.21,.07,.4}, enemy={1,.2,.2}, tex=15, w=100,h=150},
  {star={color={.6,{1,2},{2,3}}, size=10}, playBack=CL("bf5c4c"), enemy={1,1,1},   tex=2,  w=100,h=150},
  {star={color={{2,5},{2,5},.8}, size=20}, playBack={.1}, enemy={.5,.5,1},  tex=0,  w=140,  h=170},
  {star={color={{2,5},.8,{2,10}}, size=20}, playBack={.1}, enemy={.5,1,.5}, tex=0,  w=140,  h=170},
  {star={color={{2,5},true,true}, size=15}, playBack={.4}, enemy={1,1,1},   tex=0,  w=140,  h=170},

  {star={color={{2,5},true,true}, size=5}, playBack={.1}, enemy={.5*.8,1*.8,0},   tex=0,  w=110,  h=160},
}
local star = {
  function() 
    local star = display.newImageRect(starsGroup, "emitters/simple.png", c, c)
    return star
    end,
  function() 
    local star = display.newCircle(starsGroup, 0, 0, c )
    return star
  end,
  function()
    local star = display.newRect(starsGroup, 0, 0, c, c) star.alpha=.5
    return star
  end,
}

local fireOptions={
  {
    startColorRed=.03,
    startColorGreen=.18,
    startColorBlue=.61,
    startColorAlpha=.62,

    finishColorRed=.58,
    finishColorGreen=.31,
    finishColorBlue=.45,
    finishColorAlpha=0,
  },
  {
    maxParticles=75,
    startColorRed=1,
    startColorGreen=.3,
    startColorBlue=.0,
    startColorAlpha=1,

    finishColorRed=.58,
    finishColorGreen=.31,
    finishColorBlue=.6,
    finishColorAlpha=0,
  },
  {
    startColorRed=.2,
    startColorGreen=.5,
    startColorBlue=0,
    startColorAlpha=.62,

    finishColorRed=.58,
    finishColorGreen=.7,
    finishColorBlue=.6,
    finishColorAlpha=0,
  },
  {
    maxParticles=75,
    startColorRed=1,
    startColorGreen=.3,
    startColorBlue=.0,
    startColorAlpha=1,

    finishColorRed=.58,
    finishColorGreen=.41,
    finishColorBlue=.2,
    finishColorAlpha=0,
  },
  {
    startColorRed=.1,
    startColorGreen=.1,
    startColorBlue=.5,
    startColorAlpha=.62,

    finishColorRed=.15,
    finishColorGreen=.15,
    finishColorBlue=.5,
    finishColorAlpha=0,
  },
  {
    startColorRed=.1,
    startColorGreen=.1,
    startColorBlue=.1,
    startColorAlpha=1,

    finishColorRed=0,
    finishColorGreen=0,
    finishColorBlue=0,
    finishColorAlpha=0,
  },
}
local last = {big={fire=0,ship=0},norm={fire=0,ship=0},fake={fire=0,ship=0}}
local base = {
  cx = round(display.contentCenterX),
  cy = round(display.contentCenterY),
  fullw  = round(display.actualContentWidth),
  fullh  = round(display.actualContentHeight),

  graphicsOpt = graphicsOpt,
  options = options,

  CL = CL,
  div = function(num, hz)
    return num*(1/hz)-(num%hz)*(1/hz)
  end,
  getAngle = function(sx, sy, ax, ay)
    return (((math.atan2(sy - ay, sx - ax) *(1/ (math.pi *(1/ 180))) + 270) % 360))
  end,
  getCathetsLenght = function(hypotenuse, angle)
    angle = math.abs(angle*math.pi/180)
    local firstL = math.abs(hypotenuse*(math.sin(angle)))
    local secondL = math.abs(hypotenuse*(math.sin(90*math.pi/180-angle)))
    return firstL, secondL
  end,
  createPlayer = function(mas)
    local player, style, fire, big = unpack(mas)
    if style==nil then error("In function createPlayer, style value is nil") return end
    local opt = graphicsOpt[style]
    if player==nil then --если впервые
      player = display.newGroup()
      local pexData = EMshipfire
      if big==true or big==false then
        pexData.startParticleSize=140
        pexData.finishParticleSize=50
      else
        pexData.startParticleSize=70
        pexData.finishParticleSize=25
      end
      for k,v in pairs(fireOptions[fire]) do
        pexData[k]=v
      end
      local Prtcl_player = display.newEmitter(pexData)
      Prtcl_player.y = opt.h*0.5-15
      player:insert(Prtcl_player)
      player.fire=Prtcl_player
    end
    -- print("createPlayer")
    -- print(big and "big" or "norm")
    -- print(big and (last.big.fire.."=="..fire) or (last.norm.fire.."=="..fire)) 
    if (big==true and last.big.fire~=fire)
    or (big==false and last.fake.fire~=fire)
    or (big==nil and last.norm.fire~=fire) then
      print("New fire",big)
      if big==true then
        last.big.fire = fire
      elseif big==false then
        last.fake.fire = fire
      elseif big==nil then
        last.norm.fire = fire
      end
      
      display.remove(player.fire)
      local pexData = EMshipfire
      if big==true or big==false then
        pexData.startParticleSize=140
        pexData.finishParticleSize=50
      else
        pexData.startParticleSize=70
        pexData.finishParticleSize=25
      end
      for k,v in pairs(fireOptions[fire]) do
        pexData[k]=v
      end
      local Prtcl_player = display.newEmitter(pexData)
      Prtcl_player.y = opt.h*0.5-15
      player:insert(Prtcl_player)
      Prtcl_player:toBack()
      player.fire=Prtcl_player

    end
    -- создать корабль
    if player.ship==nil 
    or (big==true and last.big.ship~=style)
    or (big==false and last.fake.ship~=style)
    or (big==nil and last.norm.ship~=style) then
      if big==true then
        last.big.ship = style
      elseif big==false then
        last.fake.ship = style
      elseif big==nil then
        last.norm.ship = style
      end
    --   print(player.ship==nil 
    -- , (big==true and last.big.ship~=style)
    -- , (big==false and last.fake.ship~=style)
    -- , (big==nil and last.norm.ship~=style))
      display.remove(player.ship)
      local ship = display.newImageRect(player,'img/style'..tostring(style)..'/player.png',opt.w,opt.h)
      ship.y=-10
      player.fire.y = opt.h*0.5-20
      local tex = graphicsOpt[style].tex
      if tex~=0 then
        ship.fill.effect = "filter.colorChannelOffset"
        ship.fill.effect.xTexels = tex
        ship.fill.effect.yTexels = tex
      end
      ship:toFront()
      player.ship = ship
    end


    return player
  end,
  saveSettings = function(settings)
    saveFile(settings, settingsPath)
  end,
  loadSettings = function()
    local settings = openFile(settingsPath)
    if settings==nil then
      settings={volume={all=50,music=50,sfx=50},player=0,fire=1,language=1,debag=false}
      saveFile(settings, settingsPath)
    end
    return settings
  end,
  saveMoney = function(money)
    saveFile(money, moneyPath)
  end,
  loadMoney = function()
    local money = openFile(moneyPath)
    if money==nil or #money==0 then
      money={100000, {}, {}}
      -- money={0, {}, {}}
      for i=1, #options do
        money[2][i]=false
      end
      for i=1, #fireOptions do
        money[3][i]=false--true
      end
      saveFile(money, moneyPath)
    end
    money[2]= money[2]==nil and {} or money[2]
    money[3]= money[3]==nil and {} or money[3]
    if #money[2]<#options then
      for i=#money[2]+1, #options do
        money[2][i]=false
      end
    end
    if #money[3]<#fireOptions then
      for i=#money[3]+1, #fireOptions do
        money[3][i]=false
      end
    end
    -- [[bonus]] money[4] = money[4]==nil and 1 or 0
    return money
  end,
  saveScores = function(scoresTable)
    for i = 0, #scoresTable.score-3, 1 do
      table.remove( scoresTable.score, i )
    end
    saveFile(scoresTable, scoresPath)
  end,
  loadScores = function()
    local scoresTable = openFile( scoresPath )

    if ( scoresTable == nil or #scoresTable.score == 0 ) then
      scoresTable = { score={0, 0, 0} }
     
      saveFile(scoresTable, scoresPath)
    end
    return scoresTable
  end,
  saveStatsTasks = function(infoTasks)
    saveFile(infoTasks, taskPath)
  end,
  loadStatsTasks = function()

    local infoTasks = openFile(taskPath)

    if ( infoTasks == nil or #infoTasks.task == 0 ) then
      infoTasks = {task={{"score",10,20},{"shoper",35,50,0},{"die",30,20}}, stats={die=0,kd={0,0}}}
      saveFile(infoTasks, taskPath)
    end
    infoTasks.stats.kd = infoTasks.stats.kd==nil and {0,0} or infoTasks.stats.kd
    return infoTasks
  end,

  event = {
    add = function(name, butt, funcc)
    	events.list[#events.list+1]=name
    	events[name]={eventOn=false, but=butt, func=funcc}
    end,
    off = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:removeEventListener("tap", event.func)
          end
        end
      else
      	local event = events[name]
      	event.eventOn = enable or false
      	event.but:removeEventListener("tap", event.func)
      end
    end,
    on = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:addEventListener("tap", event.func)
          end
        end
      else
      	local event = events[name]
      	events.eventOn = enable or true
      	event.but:addEventListener("tap", event.func)
      end
    end
  },

  timer = {
    add = function(tag, time, func, cycle)
      timers.tags[#timers.tags+1]=tag
      timers[tag] = {enabled=true, func=func, time=time, cycle = cycle or 1}
     
    end,
    restart = function(tag)
      timer.cancel(tag)
      onTimer(tag)
    end,
    remove = function(tag)
      timer.cancel(tag)
      timers[tag]=nil
      for i=1, #timers.tags do
        if timers.tags[i]==tag then
          table.remove(timers.tags, i)
          break
        end
      end
    end,
    off = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            timer.cancel( tag )
          end
        end
      else
        timer.cancel( tag )
        timers[tag].enabled = enable or false
      end
    end,
    on = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            onTimer(tag)
          end
        end
      else
        timers[tag].enabled = enable or true
        onTimer(tag)
      end
    end
  },
  round = round,
  emitters = {laserShip = EMshipLfire}
  }
return base
