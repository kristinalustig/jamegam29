R = {}
local A = require "assets"

local beanPods

function R.load()
  
  beanPods = {}
  
end

function R.update()
  
end

function R.resetAll()
  
end

function R.setBeanDetails(b)
  local tempTable = {}
  
  for k, v in ipairs(b) do
    if v.found then
      table.insert(tempTable, {
          id = v.id,
          pod = v.pod,
          isVowel = v.isVowel,
          isGolden = v.isGolden
        })
    end
  end
  
  beanPods = tempTable
    
end

return R