S = {}

local W = require "wordlist"
local A = require "assets"
local F = require "falling"
local R = require "reveal"
local C = require "climbing"
local G = require "gameOver"

local cs

--vars that need to be passed between scenes
local beanSet
local lastCurrScene
local climbStarted
local revealStarted
local fallStarted
local resultStarted
local results

function S.load()
  
  beanSet = {}
  
  W.loadWordsOnStart()
  A.loadAssetsOnStart()
  
  LoadAllScenes()
  
  climbStarted = false
  revealStarted = false
  fallStarted = false
  resultStarted = false
  results = {}
  
end

function S.update(dt)
  
  if GamePaused then
    return
  end
  
  cs = currentScene
  A.animUpdate(cs)
  
  if cs == scenes.TITLE then
    
  elseif cs == scenes.INTRO then
    
  elseif cs == scenes.FALLING then
    if not fallStarted then
      A.startSong("fall")
      fallStarted = true
    end
    F.update()
  elseif cs == scenes.REVEAL then
    if not revealStarted then
      beanSet = F.getBeanDetails()
      R.setBeanDetails(beanSet)
      revealStarted = true
    end
    R.update()
  elseif cs == scenes.CLIMBING then
    if not climbStarted then
      C.firstRun()
      beanSet = A.getBeanDetails()
      C.setBeanDetails(beanSet)
      climbStarted = true
    end
    C.update()
  elseif cs == scenes.GAMEOVER then
    if not resultStarted then
      A.startSong("victory")
      results = C.shareStacked()
      G.getResults(results)
      resultStarted = true
      A.giveResults(G.setFields())
    end
    G.update()
  end

end

function S.draw()
  
  A.draw(cs)

end

function S.resetAll()
  
end

function LoadAllScenes()
  F.load()
  C.load()
end

function S.routePress(key)
  
  cs = currentScene
  
  if GamePaused then
    if key == "escape" then
      GamePaused = false
      la.setVolume(.5)
    end
    return
  else
    if key == "escape" then
      GamePaused = true
      la.setVolume(.1)
      return
    end
  end
  
  if cs == scenes.TITLE then
    if key == "space" then
      currentScene = scenes.INTRO
    end
  elseif cs == scenes.INTRO then
    if key == "space" then
      currentScene = scenes.FALLING
    end
  elseif cs == scenes.FALLING then
    F.handleKeyPress(key)
  elseif cs == scenes.REVEAL then
    
  elseif cs == scenes.CLIMBING then
    C.handleKeyPress(key)
  elseif cs == scenes.GAMEOVER then
    
  end
  
end

function S.routeRelease(key)
  
  if GamePaused then
    return
  end
  
  if currentScene == scenes.CLIMBING then
    C.handleKeyRelease(key)
  end
  
end

return S