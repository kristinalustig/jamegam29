W = {}

local wordList

local letterValues
local letterMax

function W.loadWordsOnStart()
  
  letterMax = 3
  
  letterValues = {
    a = 1,
    b = 3,
    c = 3,
    d = 2,
    e = 1,
    f = 3,
    g = 2,
    h = 3,
    i = 1,
    j = 8,
    k = 5,
    l = 1,
    m = 3,
    n = 2,
    o = 1,
    p = 3,
    q = 8,
    r = 1,
    s = 1,
    t = 1,
    u = 1,
    v = 3,
    w = 3,
    x = 8,
    y = 5,
    z = 8
  }
  
  wordList = {}
  
  for line in love.filesystem.lines("words.txt") do
    local wordLetter=line:sub(1,1)
    if wordList.wordLetter == nil then
      wordList.wordLetter = {}
    end
    table.insert(wordList.wordLetter, line)
  end
  
end


function W.createLetterSet(n)
  local letterSet = {}
  local letterCount = {}
  local totalValue = 0
  local currVowels = 0
  local vowelMax = math.floor(n*.66)

  while #letterSet < n do
    local ind = love.math.random(26)
    local letter = string.char(string.byte("a") + ind - 1)
    local value = letterValues[letter]
    local p = 1 / value

    if not letterCount[letter] or letterCount[letter] < letterMax then
      if (W.isVowel(letter) and currVowels < vowelMax) or not W.isVowel(letter) then
        if love.math.random() <= p then
          if W.isVowel(letter) then
            currVowels = currVowels + 1
          end
          table.insert(letterSet, letter)
          totalValue = totalValue + value
          letterCount[letter] = (letterCount[letter] or 0) + 1
        end
      end
    end
  end

  return letterSet
end


function W.checkWordList(word)
  
  local wordLetter = word:sub(1,1)
  
  for k, v in ipairs(wordList.wordLetter) do
    if v == word then
      return true
    end
  end
  
  return false
  
end

function W.getScore(word)
  
  local score = 0
  
  for k, v in string.gmatch(word, "(.)") do
    score = score + letterValues[k]
  end
  
  return score
  
end

function W.getLetterScore(s)
  return letterValues[s]
end

function W.isVowel(v)
  
  return (v == "a" or v == "e" or v == "i" or v == "o" or v == "u")
  
end

function W.isGolden(v)
  
  return (letterValues[v] >= 8)
  
end

return W