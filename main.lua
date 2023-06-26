S = require "scene"

lg = love.graphics
lk = love.keyboard
la = love.audio

scenes = {
  
  TITLE = 1,
  INTRO = 2,
  FALLING = 3,
  REVEAL = 4,
  CLIMBING = 5,
  GAMEOVER = 6
  
}

currentScene = scenes.TITLE
stateDebug = false
GlobalActionQueue = {}
GlobalActionInProgress = false
GlobalActionCountdown = 3
GamePaused = false

function love.load()
  
  S.load()
  
end

function love.update(dt)
  
  S.update(dt)
  
end

function love.draw()
  
  S.draw()
  
end

function love.keypressed(key, _, _)
  
  S.routePress(key)
  
end

function love.keyreleased(key, _)
  S.routeRelease(key)
end