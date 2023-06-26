A = {}
local W = require "wordlist"

--list out asset names here
local beansSheet
local background
local ruler
local chompPuff
local chomping
local chompNum
local letterStorage
local beanFont
local letterX
local letterY
local title
local howToPlay
local pause
local results
local finishButton
local preButtons
local runningScore

--audio assets
local bite
local click
local climb
local eat
local fall
local open
local victory
local wordDown
local wordUp

local antSheet
local ant
local beanPods
local beanCount
local currPod
local antSpeed

local animCounter
local podFrame
local letterStorageX
local letterStorageY
local podOpen

local beansClimb

local currWord
local currStackY
local stackX
local sp
local isWordShaking
local shakeTimer
local climbing
local beanStackSize
local firstMove
local resultsData
local showBonus


--fonts
local headerFont
local beanFontStack
local headerFontSm


function A.loadAssetsOnStart()
  
  headerFont = lg.newFont("assets/CherryBombOne-Regular.ttf", 36)
  headerFontSm = lg.newFont("assets/CherryBombOne-Regular.ttf", 24)
  lg.setFont(headerFont)
  beanFont = lg.newFont("assets/Belanosima-SemiBold.ttf", 36)
  beanFontStack = lg.newFont("assets/Belanosima-SemiBold.ttf", 60)
  
  beansSheet = lg.newImage("assets/beans.png")
  antSheet = lg.newImage("assets/ant.png")
  ruler = lg.newImage("assets/ruler.png")
  letterStorage = lg.newImage("assets/letterStorage.png")
  chompPuff = QuadExtractor(384, 384, 128, 384, 1, 1, 896, 512)
  background = {
    image = lg.newImage("assets/bg.png"),
    x = -600, 
    y = 0,
    targetY = 0
  }
  
  title = lg.newImage("assets/title.png")
  howToPlay = lg.newImage("assets/howToPlay.png")
  pause = lg.newImage("assets/pause.png")
  results = lg.newImage("assets/results.png")
  finishButton = lg.newImage("assets/finishButton.png")
  
  ant = {
    image = antSheet,
    animClimb = QuadExtractor(0, 0, 384, 128, 4, 1, 896, 512),
    animFall = QuadExtractor(384, 0, 128, 384, 1, 4, 896, 512),
    currFrame = 1,
    x = 20,
    y = -40
  }
  
  
  --stalk1, stalk2, nopod
  beanPods = {
    image = beansSheet,
    all = {},
    cons = QuadExtractor(0, 0, 192, 192, 1, 3, 576, 576),
    vow = QuadExtractor(0, 192, 192, 192, 1, 3, 576, 576),
    gold = QuadExtractor(0, 384, 192, 192, 1, 3, 576, 576)
  }
  
  podOpen = {frame = 1}
  
  animCounter = 1
  chomping = false
  chompNum = 1
  beanCount = 0
  currPod = nil
  podFrame = 1
  letterStorageX = 0
  letterStorageY = 360
  beanStackSize = 100
  
  beansClimb = {}
  
  currWord = {}
  stackX = 340
  currStackY = 3300
  isWordShaking = false
  shakeTimer = 1
  climbing = 100
  antSpeed = 10
  letterX = 0
  letterY = 5
  firstMove = true
  preButtons = true
  runningScore = 0
  showBonus = ""
  
  if stateDebug then
    sp = 4
  else
    sp = 3
  end
  
  bite = la.newSource("assets/audio/bite.mp3", "static")
  click = la.newSource("assets/audio/click.mp3", "static")
  climb = la.newSource("assets/audio/climb.mp3", "stream")
  eat = la.newSource("assets/audio/eat.mp3", "static")
  fall = la.newSource("assets/audio/fall.mp3", "stream")
  open = la.newSource("assets/audio/open.mp3", "static")
  victory = la.newSource("assets/audio/victory.mp3", "stream")
  wordDown = la.newSource("assets/audio/wordDown.mp3", "static")
  wordUp = la.newSource("assets/audio/wordUp.mp3", "static")
  
  love.audio.setVolume(.5)
  climb:setLooping(true)
  climb:play()
  
end

function A.animUpdate(cs)
  
  if animCounter <= 1000 then
    animCounter = animCounter + 1
  else
    animCounter = 1
  end
  
  --FALLING.LUA ANIMATIONS
  if cs == scenes.FALLING then
    if animCounter % 15 == 0 then
      if ant.currFrame == 2 then
        ant.currFrame = 1 
      elseif ant.currFrame == 3 then
        ant.currFrame = 4
      elseif ant.currFrame == 4 then
        ant.currFrame = 3
      else
        ant.currFrame = 2
      end
    end
    if lk.isDown("space") and ant.currFrame < 3 then
      ant.currFrame = ant.currFrame + 2
      chomping = true
      chompNum = 1
    elseif not lk.isDown("space") and ant.currFrame > 2 then
      ant.currFrame = ant.currFrame - 2
    end
  elseif cs == scenes.REVEAL then
  --REVEAL.LUA ANIMATIONS
    if currPod == nil or currPod.state == "done" then
      for k, v in ipairs(beanPods.all) do
        if v.found == true and v.state == "not" then
          currPod = v
          open:play()
          currPod.state = "open"
          podFrame = 1
          break
        end
      end
      if currPod ~= nil and currPod.state == "done" then
        for k, v in ipairs(beanPods.all) do
          for k1, v1 in ipairs(v.pod) do
            if v1.x == nil then
              currPod = v
              break
            end
          end
          if currPod.state ~= "done" then
            break
          end
        end
        currentScene = scenes.CLIMBING
      end
    end
    if currPod == nil then
      return
    end
    if currPod.state == "open" then
      podOpen.frame = podOpen.frame + 1 
      if podOpen.frame >= 3 then
        podOpen.frame = 1
        local xStart = 200
        for k, v in ipairs(currPod.pod) do
          if letterStorageX >= 700 then
            letterStorageX = 30
            letterStorageY = letterStorageY + 70
          else
            letterStorageX = letterStorageX + 36
          end
          v.xCurr = xStart + (36*k)
          v.yCurr = 100
          v.xDest = letterStorageX
          v.yDest = letterStorageY
          v.xSpeed = 10*sp
          v.ySpeed = 10*sp
        end
        currPod.state = "show"
      end
    elseif currPod.state == "show" then
      if podFrame < 50 then
        podFrame = podFrame + 1
      else
        local placed = true
        for k, v in ipairs(currPod.pod) do
          if math.abs(v.xCurr - v.xDest) < 5*sp+1 then
            v.xCurr = v.xDest
          elseif v.xCurr < v.xDest then
            v.xCurr = v.xCurr + v.xSpeed
            placed = false
          else
            v.xCurr = v.xCurr - v.xSpeed
            placed = false
          end
          if math.abs(v.yCurr - v.yDest) < 5*sp+1 then
            v.yCurr = v.yDest
          elseif v.yCurr < v.yDest then
            v.yCurr = v.yCurr + v.ySpeed
            placed = false
          else
            v.yCurr = v.yCurr - v.ySpeed
            placed = false
          end
        end
        if placed then
          currPod.state = "done"
        end
      end
    end
  elseif cs == scenes.CLIMBING then
    local xStart = -18
    for k, v in ipairs(currWord) do
      v.xCurr = xStart + (40*k)
      v.yCurr = 290
    end
    if climbing > 0 then
      climbing = climbing - 1*antSpeed
      if ant.currFrame == 4 and animCounter % 15 == 0 then
        ant.currFrame = 1
      elseif animCounter % 15 == 0 then
        ant.currFrame = ant.currFrame + 1
      end
      ant.y = ant.y - 1*antSpeed
    else
      showBonus = ""
    end
    if background.targetY ~= background.y then
      if math.abs(background.targetY - background.y) <= 5 then
        background.y = background.targetY
      elseif background.targetY < background.y then
        background.y = background.y - 5
      elseif background.targetY > background.y then
        background.y = background.y + 5
      end
    end
  end
  
end

function A.draw(cs)
  
  if GamePaused then
    lg.draw(pause)
    return
  end
  
  if cs == scenes.TITLE then
    lg.draw(title)
  elseif cs == scenes.INTRO then
    lg.draw(howToPlay)
  elseif cs == scenes.FALLING then
    lg.draw(background.image, background.x, background.y)
    lg.printf(beanCount, 10, 5, 100, "left")
    
    if #beanPods.all ~= 0 then
      for k, v in ipairs(beanPods.all) do
        if not v.found then
          local dir = 1
            if v.x > 400 then
              dir = 2
            end
          if v.isVowel and IsOnScreen(v.y) then
            lg.draw(beansSheet, beanPods.vow[dir], v.x, background.y + v.y, 0, .5, .5)
          elseif v.isGolden and IsOnScreen(v.y) then
            lg.draw(beansSheet, beanPods.gold[dir], v.x, background.y + v.y, 0, .5, .5)
          elseif IsOnScreen(v.y) then
            lg.draw(beansSheet, beanPods.cons[dir], v.x, background.y + v.y, 0, .5, .5)
          end
        end
      end
    end
    
    lg.draw(ant.image, ant.animFall[ant.currFrame], ant.x, ant.y, 0, .8, .8)
    if ant.currFrame > 2 and chomping then
      lg.draw(antSheet, chompPuff, ant.x + 20, ant.y + 260)
      chompNum = chompNum + 1 
    elseif chompNum >= 5 then
      chomping = false
    end

elseif cs == scenes.REVEAL then
    lg.setFont(beanFont)
    lg.draw(background.image, background.x, background.y)
    lg.draw(letterStorage, 0, 0)
    local beanXStart = 180
    local opened = 0
    for k, v in ipairs(beanPods.all) do
      local sprite = nil
        if v.isVowel then
          sprite = beanPods.vow
        elseif v.isGolden then
          sprite = beanPods.gold
        else
          sprite = beanPods.cons
        end
      if v.state ~= "not" and v.state ~= "open" then
        opened = opened + 1
        for k1, v1 in ipairs(v.pod) do
          lg.draw(beansSheet, sprite[3], v1.xCurr, v1.yCurr, 0, .25, .25)
          lg.printf(v1.val:upper(), v1.xCurr+letterX, v1.yCurr+letterY, 46, "center")
        end
      elseif v.state == "not" then
        lg.draw(beansSheet, sprite[1], beanXStart - (k*40 - (opened*40)), 80, 0, .5, .5)
      end
    end
  elseif cs == scenes.CLIMBING then
    lg.draw(background.image, background.x, background.y)
    lg.draw(ruler, background.x, background.y)
    for k1, v1 in ipairs(beansClimb) do
      local sprite = nil
      if v1.isVowel then
        sprite = beanPods.vow
      elseif v1.isGolden then
        sprite = beanPods.gold
      else
        sprite = beanPods.cons
      end
      lg.setFont(beanFontStack)
      if v1.inStack then
        local x = v1.xCurr
        local y = background.y + v1.yCurr
        lg.draw(beansSheet, sprite[3], x, y, 0, .5, .5)
        lg.printf(v1.val:upper(), x+letterX+24, y+letterY*2, 60, "left")
      end
    end
    lg.draw(antSheet, ant.animClimb[ant.currFrame], ant.x, background.y + ant.y, -1.5708, .5, .5)
    lg.draw(letterStorage, 0, 0)
    if preButtons then
      lg.setFont(headerFontSm)
      lg.printf("Start typing!", 10, 220, 200, "left")
    end
    lg.setFont(beanFont)
    for k1, v1 in ipairs(beansClimb) do
      local sprite = nil
      if v1.isVowel then
        sprite = beanPods.vow
      elseif v1.isGolden then
        sprite = beanPods.gold
      else
        sprite = beanPods.cons
      end
      local x = v1.xCurr
      local y = v1.yCurr
      if isWordShaking and v1.used and not v1.inStack then
        if shakeTimer < 3 then
          y = y + 4
        elseif shakeTimer < 6 then
          y = y - 4
        else
          isWordShaking = false
        end
        shakeTimer = shakeTimer + 1
      end
      if not v1.inStack and x ~= nil then
        lg.draw(beansSheet, sprite[3], x, y, 0, .25, .25)
        lg.printf(v1.val:upper(), x+letterX, y+letterY, 46, "center")
      end
    end
    lg.draw(finishButton, 480, 270)
    lg.setFont(headerFontSm)
    lg.printf("Score: "..runningScore, 5, 5, 500, "left")
    lg.printf(showBonus, 5, 35, 500, "left")
  elseif cs == scenes.GAMEOVER then
    lg.draw(results)
    local yStart = 60
    local xVal = 464
    local incr = 48
    lg.printf(resultsData.podsGotten, xVal, yStart + incr*1, 200, "left")
    lg.printf(resultsData.beansFound, xVal, yStart + incr*2, 200, "left")
    lg.printf(resultsData.leftovers, xVal, yStart + incr*3, 200, "left")
    lg.printf(resultsData.maxHeight, xVal, yStart + incr*4, 200, "left")
    lg.printf(resultsData.bestWord, xVal, yStart + incr*5, 200, "left")
    lg.printf(resultsData.totalScore, xVal, yStart + incr*6, 200, "left")
    local wordList = ""
    for k, v in ipairs(resultsData.wordList) do
      if k == 1 then
        wordList = v
      else
        wordList = wordList ..", "..v
      end
    end
    lg.printf(wordList, 100, 454, 600, "center")
  end
  
end

function A.getWordForStack()
  return currWord
end

function A.stackify()
  
  local yDiff = 0
  
  for k, v in ipairs(currWord) do
    v.xPrev = v.xCurr
    v.yPrev = v.yCurr
    v.xCurr = stackX + math.random(-5, 5)
    currStackY = currStackY - beanStackSize
    v.yCurr = currStackY
    v.inStack = true
    yDiff = yDiff + beanStackSize
    runningScore = runningScore + v.score
  end
  if #currWord >= 6 then
    runningScore = runningScore + 5
    showBonus = "long word bonus +5!"
  end
  if firstMove then
    background.targetY = background.y + (yDiff*.8)
    firstMove = false
  else
    background.targetY = background.y + yDiff
    if background.targetY >= 0 then
      background.targetY = 0
    end
  end
  currWord = {}
  StartAntClimb(yDiff)
  
  
end

function A.updateCamera(x, y)
  background.x = -x
  background.y = y
end

function A.updateAntX(x)
  
  ant.x = ant.x + x
  
end

function A.getBeans(b, includeNotFound)
  
  local tempTable = {}
  
  for k, v in ipairs(b) do
    if v.found or includeNotFound then
      table.insert(tempTable, v)
    end
  end
  beanPods.all = tempTable
  
end

function A.getBeanDetails()
  
  return beansClimb
  
end

function A.setBeanCount(n)
  beanCount = n
end

function A.getAntLoc()
  
  local tempTable = {x = ant.x, y = ant.y}
  
  return tempTable
  
end

function A.getBackgroundY()
  return background.y
end

function A.getBeanUsed(num)
  
  beansClimb[num].used = true
  table.insert(currWord, beansClimb[num])
  beansClimb[num].xPrev = beansClimb[num].xCurr
  beansClimb[num].yPrev = beansClimb[num].yCurr
  preButtons = false
  
end

function A.setBeanNotUsed(num)
  
  local b = beansClimb[num]
  
  beansClimb[num].used = false
  beansClimb[num].xCurr = b.xStor
  beansClimb[num].yCurr = b.yStor
  
  table.remove(currWord, #currWord)
  
end

function A.getWordFromStack(word)
  
  local tempTable = {}
  
  if #word >= 6 then
    runningScore = runningScore - 5
  end
  
  for k, v in ipairs(word) do
    for k1, v1 in ipairs(beansClimb) do
      if v.id == v1.id then
        v1.inStack = false
        table.insert(tempTable, v1)
        break
      end
    end
  end
  
  local largestYInd = 1
  local iter = #tempTable
  for i=1, iter do
    local largestY = 0
    for k, v in ipairs(tempTable) do
      if v.yCurr > largestY then
        largestY = v.yCurr
        largestYInd = k
      end
    end
    table.insert(currWord, tempTable[largestYInd])
    runningScore = runningScore - tempTable[largestYInd].score
    table.remove(tempTable, largestYInd)
  end
  
  background.targetY = background.y - (#currWord*beanStackSize)
  if background.targetY < -3000 then
    background.targetY = -3000
  end
  
  ant.y = ant.y + (#currWord*beanStackSize)
  if ant.y > 3500 then
    ant.y = 3500
  end
    
  
  currStackY = currStackY + (#currWord*beanStackSize)
  
end

function A.flattenBeanList()
  
  for k, v in ipairs(beanPods.all) do
    for k1, v1 in ipairs(v.pod) do
      table.insert(beansClimb, v1)
      beansClimb[#beansClimb].used = false
      beansClimb[#beansClimb].xStor = v1.xCurr
      beansClimb[#beansClimb].yStor = v1.yCurr
      beansClimb[#beansClimb].inStack = false
      beansClimb[#beansClimb].score = W.getScore(v1.val)
    end
  end
  
  A.startSong("climb")
  
  ant.x = 290
  ant.y = 3500
  background.targetY = background.y
  
end

function A.getBeanCount()
  return beanCount
end

function A.getTotalBeans()
  return #beansClimb
end

function A.getLeftoverBeans()
  local sum = 0
  for k, v in ipairs(beansClimb) do
    if not v.inStack then
      sum = sum + 1
    end
  end
  return sum
end

function A.giveResults(r)
  
  resultsData = r
  
end

function A.getMaxHeight()
  
  return math.floor((3600 - currStackY)/133)
  
end

function A.shakeWord()
  isWordShaking = true
  shakeTimer = 1
end

function A.startSong(s)
  
  climb:stop()
  victory:stop()
  fall:stop()
  
  if s == "fall" then
    fall:play()
  elseif s == "climb" then
    climb:play()
  elseif s == "victory" then
    victory:play()
  end
  
end

function A.playSfx(s)
  eat:stop()
  bite:stop()
  wordUp:stop()
  wordDown:stop()
  click:stop()
  if s == "eat" then
    eat:play()
  elseif s == "bite" then
    bite:play()
  elseif s == "wordUp" then
    wordUp:play()
  elseif s == "wordDown" then
    wordDown:play()
  elseif s == "click" then
    click:play()
  end
end


function StartAntClimb(y)
    
    climbing = climbing + y
    
end


function IsOnScreen(y)
  
  return y >= -background.y-192 and y <= -background.y + 600
  
end

function QuadExtractor(x, y, w, h, r, c, sw, sh)
  
  local quads = {}
  
  for i=0, r-1, 1 do
    for j=0, c-1, 1 do
      table.insert(quads, lg.newQuad(x+(j*w), y+(i*h), w, h, sw, sh))
    end
  end

  if #quads == 1 then
    return quads[1]
  else
    return quads
  end
  
end

return A