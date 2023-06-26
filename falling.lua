F = {}

local A = require "assets"

local cameraX
local cameraY
local cameraSpeed
local antSpeed
local numLetters
local beanXMin
local beanXMax
local beanYMin
local beanYMax
local beanSet
local beanCount
local podSize

function F.load()
  
  beanXMin = 100 --x tied to screen
  beanXMax = 700 
  beanYMin = 400 --y tied to bg scroll
  beanYMax = 3000
  
  cameraX = 600
  cameraY = 0
  cameraSpeed = 3
  antSpeed = 7
  numLetters = 60
  beanSet = {}
  beanCount = 0
  
  podSize = 80
  
  CreateBeans()
  
end

function F.update()
  
  if stateDebug then
    A.updateCamera(320, -3000)
    A.getBeans(beanSet, false)
    currentScene = scenes.REVEAL
    return
  end
  
  if cameraY > -3000 then
    cameraY = cameraY - cameraSpeed
  elseif cameraX > 0 then
    A.updateCamera(320, -3000)
    A.getBeans(beanSet, false)
    currentScene = scenes.REVEAL
    return
  end
  A.updateCamera(cameraX, cameraY)
  
  if lk.isDown("a") or lk.isDown("left") then
    A.updateAntX(-antSpeed)
  elseif lk.isDown("d") or lk.isDown("right") then
    A.updateAntX(antSpeed)
  end
  
end

function F.getBeanDetails()
  
  return beanSet
  
end

function F.resetAll()
  
  
  
end

function F.handleKeyPress(key)
  
  if key == "space" then
    local beans = CheckBeanOverlap(A.getAntLoc())
    if beans > 0 then
      beanCount = beanCount + beans
      A.setBeanCount(beanCount)
      A.playSfx("eat")
    else
      A.playSfx("bite")
    end
  end
  
end

function CheckBeanOverlap(loc)
  
  local x = loc.x
  local y = loc.y - A.getBackgroundY()
  
  for k, v in ipairs(beanSet) do
    if v.x >= x - podSize and v.x <= x + podSize then
      if v.y >= y + podSize*2 and v.y <= y + podSize*4 and not v.found then
        v.found = true
        return 1
      end
    end
  end
  
  return 0
  
end

function CreateBeans()
  
  local letterSet = W.createLetterSet(numLetters)
  
  for k, v in ipairs(letterSet) do
    letterSet[k] = {
      val = v,
      id = k,
      isVowel = W.isVowel(v),
      isGolden = W.isGolden(v)
    }
  end
  
  local tempBeanPods = {}
  tempBeanPods = GroupBeans(letterSet)
  local used = {}
  for i = 1, #tempBeanPods do
    used[i] = false
  end
  
  local by = beanYMin
  local prevX = beanXMin
  local allUsed = false
  local iter = 1
  local plusY = math.floor((beanYMax - beanYMin) / #tempBeanPods)
  while allUsed == false do
    local podNum = love.math.random(#tempBeanPods)
    if used[podNum] == false then
      local plusYMod = math.random(-50, 50)
      by = by + plusY + plusYMod
      local bx = math.random(beanXMin, beanXMax)
      local v = tempBeanPods[podNum]
      v.id = podNum
      v.x = bx
      v.y = by
      v.isVowel = v.pod[1].isVowel
      v.isGolden = v.pod[1].isGolden
      if stateDebug then
        v.found = true
      else
        v.found = false
      end
      v.state = "not"
      tempBeanPods[podNum] = v
      used[podNum] = true
    end
    if iter >= #tempBeanPods * 3 then
      for k, v in ipairs(tempBeanPods) do
        if used[k] == false then
          local plusYMod = math.random(-50, 50)
          by = by + plusY + plusYMod
          local bx = math.random(beanXMin, beanXMax)
          v.id = k
          v.x = bx
          v.y = by
          v.isVowel = v.pod[1].isVowel
          v.isGolden = v.pod[1].isGolden
          if stateDebug then
            v.found = true
          else
            v.found = false
          end
          v.state = "not"
          used[k] = true
          tempBeanPods[podNum] = v
        end
      end
      allUsed = true
    end
    iter = iter + 1
  end
  
  beanSet = tempBeanPods
  A.getBeans(tempBeanPods, true)
  
end

function GroupBeans(letterSet)
  
  local beans = {}
  
  local groups = {}
  groups.vow = {}
  groups.cons = {}
  groups.gold = {}
  
  for k, v in ipairs(letterSet) do
    if v.isVowel then
      table.insert(groups.vow, v)
    elseif v.isGolden then
      table.insert(groups.gold, v)
    else
      table.insert(groups.cons, v)
    end
  end
  
  beans = SplitUp(beans, groups.vow)
  beans = SplitUp(beans, groups.cons)
  beans = SplitUp(beans, groups.gold)
  
  return beans

end

function SplitUp(beans, g)
  local i = 1
  while i < #g do
    local r = math.random(2)
    table.insert(beans, {})
    beans[#beans] = {
      pod = {}
      }
    for j = 0, r do
      if (i+j) <= #g then
        table.insert(beans[#beans].pod, g[i+j])
      else
        i = #g
      end
    end
    i=i+r+1
  end
  return beans
end
    
return F