require ("ip")
local il = require "il"
local helpers = {}

function helpers.get_minmax_intensities( img )
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

function helpers.count_values(img)
  local hist = {}
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do 
      hist[img:at(row,col).y] = hist[img:at(row,col).y] + 1
    end
  end
  return hist
end
--Scotts in_range function
function helpers.in_range( val )  
  
  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end
  
end

function helpers.get_hist( img, chan )
  local pix
  local hist = {}
  
  -- initialize the histogram
  for i = 0, 256 do
    hist[i] = 0
  end
  
  for row, col in img:pixels() do
    
    pix = img:at( row, col )
    
    hist[pix.rgb[chan]] = hist[pix.rgb[chan]] + 1
    
  end
  
  return hist
end

function helpers.round( val )
  return math.floor( val + 0.5 )
end
--get percent location given the image histogram, number of pixels in the image,  percent pixel from
function helpers.get_percent_location( hist, num_pixels, percent, start )
  local count = 0
  local dir = 1
  local last = 255
  local found = start
  if start == 255 then
    dir = -1
    last = 0
  end
  for i = start, last or count / num_pixels > percent, dir do
    count = count + hist[i]
    found = i+dir
  end
  return found
end


return helpers