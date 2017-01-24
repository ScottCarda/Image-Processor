require ("ip")
local helpers = {}

function get_minmax_intensities( img )
  local min = 256
  local max = 0
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do 
      if min > img:at(row, col ).r then
        min = img:at(row, col ).r
      end
      if max < img:at(row, col ).r then
        max = img:at(row, col ).r
      end
    end
  end
  return min, max
end

function count_values(img)
  local hist = {}
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do 
      hist[img:at(row,col).y] = hist[img:at(row,col).y] + 1
    end
  end
  return hist
end
--Scotts in_range function
function in_range( val )  
  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end
end

return helpers