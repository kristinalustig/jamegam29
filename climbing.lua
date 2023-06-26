C = {}
local A = require "assets"
local W = require "wordlist"

local beans
local stacked

function C.load()
  
  beans = {}
  stacked = {}
  
end

function C.update()
  
  DoNextAction()
  
end

function C.firstRun()
  
  A.flattenBeanList()
  
end

function C.isWordValid(word)
  
  
  
end

function C.setBeanDetails(b)
  
  beans = b
  
end

function C.handleKeyPress(key)
  
  
  
end

function C.handleKeyRelease(key)
  
  table.insert(GlobalActionQueue, key)
  
end

function C.shareStacked()
  
  return stacked
  
end

function ParseWord(w)
  
  local word = ""
  for k, v in ipairs(w) do
    word = word..v.val
  end
  
  return word
end

function DoNextAction()
  
  if GlobalActionInProgress or #GlobalActionQueue == 0 then return end
  
  GlobalActionCountdown = GlobalActionCountdown - 1
  if GlobalActionCountdown == 0 then
    GlobalActionInProgress = true
    GlobalActionCountdown = 4
  else
    return
  end
  
  local key = table.remove(GlobalActionQueue, 1)
  GlobalActionInProgress = true
  
  if key == "9" then
    GlobalActionInProgress = false
    currentScene = scenes.GAMEOVER
  elseif key == "return" then
    local word = A.getWordForStack()
    local wordParsed = ParseWord(word)
    if W.checkWordList(wordParsed) == true then
      table.insert(stacked, word)
      A.playSfx("wordUp")
      A.stackify()
    else
      A.shakeWord()
    end
  elseif key == "backspace" or key == "delete" then
    local word = A.getWordForStack()
    if #word == 0 and #stacked ~= 0 then
      A.getWordFromStack(stacked[#stacked])
      A.playSfx("wordDown")
      table.remove(stacked, #stacked)
    elseif #word ~= 0 then
      local w = word[#word]
      for k, v in ipairs(beans) do
        if v.id == w.id then
          v.used = false
          A.setBeanNotUsed(k)
          break
        end
      end
    elseif #stacked == 0 then
      GlobalActionInProgress = false
      return
    end
  elseif string.byte(key) >= 97 and string.byte(key) <= 122 then
    for k, v in ipairs(beans) do
      if v.val == key and v.used == false then
        A.playSfx("click")
        v.used = true
        A.getBeanUsed(k)
        break
      end
    end
  end
  
  GlobalActionInProgress = false

end

return C