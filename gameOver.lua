G = {}

local A = require "assets"

local results
local fields
local wordsParsed
local totalScore

function G.update()
  
end

function G.getResults(r)
  results = r
end

function G.setFields()
  
  wordsParsed = {}
  
  fields = {
    podsGotten = A.getBeanCount(),
    beansFound = A.getTotalBeans(),
    leftovers = A.getLeftoverBeans(),
    maxHeight = A.getMaxHeight() .. " inches",
    bestWord = G.calcScore(),
    totalScore = totalScore,
    wordList = wordsParsed
  }
  
  return fields
end

function G.calcScore()
  
  totalScore = 0
  local bestWord = ""
  local bestWordScore = 0
  for k, v in ipairs(results) do
    local word = ""
    local currScore = 0
    for k1, v1 in ipairs(v) do
      word = word ..v1.val
      currScore = currScore + v1.score
    end
    if currScore > bestWordScore then
      bestWord = word
      bestWordScore = currScore
    end
    totalScore = totalScore + currScore
    if word:len() >= 6 then
      totalScore = totalScore + 5
    end
    table.insert(wordsParsed, word)
  end
  
  return (bestWord.." ("..bestWordScore..")")
  
end

return G