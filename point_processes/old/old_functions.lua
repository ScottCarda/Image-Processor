local Carda = require("Carda")
local Smith = require("Smith")

local funcs = {}

local function tableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

tableMerge( funcs, Carda )
tableMerge( funcs, Smith )

function funcs.negate( img )
  
  for row, col in img:pixels() do
    for chan = 0, 2 do
      img:at( row, col ).rgb[chan] = 255 - img:at( row, col ).rgb[chan]
    end
  end
  
  return img
end

return funcs