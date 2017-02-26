local funcs = {}

--[[    in_range
  |
  |   Takes a value and return the value if it is in the range 0 to 255.
  |   If it is not in the range, it returns the range's endpoint that is
  |   the closest.
  |
  |     Author: Scott Carda
--]]
function funcs.in_range( val )  

  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end

end

--[[    reflection
  |
  |   Takes an index value and return the reflected index value to ensure
  |   that the value lies between the given min and max values, inclusive to the min.
  |
  |     Author: Scott Carda
--]]
function funcs.reflection( index, min, max )
  
  local i = index - min -- index, offset min
  local n = max - min -- size of range
  
  -- If the number of reflections is odd
  if (math.floor(i/n)%2 == 1) then
    index = n - i%n - 1 -- reflected index
  else
    index = i%n -- normal, modulated index
  end
  
  return index + min -- return the calculated index, offset min
  
end

function apply_scale( filter, scale )
  
  for i = 1, #filter do
    for j = 1, #filter[i] do
      filter[i][j] = filter[i][j] * scale
    end
  end
  
end

--[[function funcs.insert_sort_pixels( list )
  
  result = {}
  
  for i = 1, #list do 
  
end]]

-- implement counting sort
function funcs.sort_pixels( list )
  
  local buckets = {}
  local temp
  local result = {}
  
  for i = 0, 255 do
    buckets[i] = 0
  end
  
  for i = 1, #list do
    
    temp = list[i]
    
    buckets[temp] = buckets[temp] + 1
    
  end
  
  for i = 0, 255 do
    for j = 1, buckets[i] do
      result[#result+1] = i
    end
  end
  
  return result
  
end

return funcs