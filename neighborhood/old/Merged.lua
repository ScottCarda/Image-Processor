local Carda = require("Carda")
local Smith = require("Smith")
local Neigh = require("Neighbor")

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
tableMerge( funcs, Neigh )

return funcs