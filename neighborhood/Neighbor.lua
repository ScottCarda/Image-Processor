require "ip"
local il = require "il"
--local helpers = require "helper_functs"

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

function sum_filter( vals, weights )
  local sum = 0
  for i = 1, math.min( #vals, #weights ) do
    sum = sum + vals[i] * weights[i]
  end
  return sum
end

--[[function sum_and_scale( vals, weights )
  local sum = 0
  local scale = 0
  for i = 1, math.min( #vals, #weights ) do
    sum = sum + vals[i] * weights[i]
    scale = scale + weights[i]
  end
  sum = math.floor( sum / scale )
  return sum
end]]

function funcs.old_filter( img, chan, filter, operation, scale )
  
  if scale == nil then
    scale = 1
  end
  
  local n = #filter
  local m = #filter[1]
  local pix -- a pixel
  local vals
  local weights = {}
  local x
  local y
  
  local cpy_img = img:clone()
  
  for i = 1, n do
    for j = 1, m do
      weights[#weights+1] = filter[i][j] * scale
    end
  end
  
  for row, col in img:pixels() do
    
    pix = cpy_img:at( row, col )
    
    vals = {}
    for i = -(n-1)/2, (n-1)/2 do
      y = (row+i)%img.height
      for j = -(m-1)/2, (m-1)/2 do
        x = (col+j)%img.width
        vals[#vals+1] = img:at( y , x ).rgb[chan]
      end
    end
    
    pix.rgb[chan] = funcs.in_range( operation( vals, weights ) )
    
  end
  
  return cpy_img
  
end

function funcs.filter( img, chan, filter, operation, scale )
  
  if scale == nil then
    scale = 1
  end
  
  local n = #filter
  local m = #filter[1]
  local pix -- a pixel
  local vals
  local weights = {}
  local x
  local y
  
  local cpy_img = img:clone()
  
  for i = 1, n do
    for j = 1, m do
      weights[#weights+1] = filter[i][j] * scale
    end
  end
  
  for row, col in img:pixels() do
    
    pix = cpy_img:at( row, col )
    
    if col == 0 then
      vals = {}
      for i = -(n-1)/2, (n-1)/2 do
        y = (row+i)%img.height
        for j = -(m-1)/2, (m-1)/2 do
          x = (col+j)%img.width
          vals[#vals+1] = img:at( y , x ).rgb[chan]
        end
      end
    else
      table.remove( vals, 1 )
      x = (col+(m-1)/2)%img.width
      for i = 1, m do
        y = i-(m-1)/2-1
        y = (row+y)%img.height
        vals[n*i] = img:at( y , x ).rgb[chan]
      end
    end
    
    pix.rgb[chan] = funcs.in_range( operation( vals, weights ) )
    
  end
  
  return cpy_img
  
end

function funcs.fast_filter( img, chan, filter, scale, size )
  local n = ( size - 1 ) / 2
  local pix -- a pixel
  local total
  
  local cpy_img = img:clone()
  
  for row, col in img:pixels( 1 ) do
    
    pix = cpy_img:at( row, col )
    total = 0
    
    for i = -n, n do
      for j = -n, n do
        total = total + img:at( row + i, col + j ).rgb[chan] * filter[n*2 + i][n*2 + j]
      end
    end
    
    pix.rgb[chan] = funcs.in_range( total * scale )
    
  end
  
  return cpy_img
  
end

function funcs.smooth_filter( img )
  
  local filter = {
    {1,2,1},
    {2,4,2},
    {1,2,1}
  }
  
  local filter1 = {{ 1, 2, 1 }}
  local filter2 = {{1},{2},{1}}
  
  il.RGB2YIQ( img )
  
  --img = funcs.filter( img, 0, filter1, sum_filter, 1/4 )
  --img = funcs.filter( img, 0, filter2, sum_filter, 1/4 )
  
  img = funcs.fast_filter( img, 0, filter, 1/16, 3 )
  
  --[[
  local n = ( size - 1 ) / 2
  local pix -- a pixel
  local total
  
  local cpy_img = img:clone()
  
  for row, col in img:pixels( 1 ) do
    
    pix = cpy_img:at( row, col )
    total = 0
    
    for i = -n, n do
      for j = -n, n do
        total = total + img:at( row + i, col + j ).y * filter[n*2 + i][n*2 + j]
        --local x = 3
      end
    end
    
    pix.y = total / 16
    
  end
    ]]
    
  il.YIQ2RGB( img )
  
  return img
        
end

function funcs.sharp_filter( img )
  
  -- This sharpen filter give different output from the official sharpen operation
  
  local filter = {
    {0,-1,0},
    {-1,5,-1},
    {0,-1,0}
  }
  
  il.RGB2YIQ( img )
  
  img = funcs.filter( img, 0, filter, sum_filter )
  
  --img = funcs.filter( img, 0, filter, 1, 3 )
    
  il.YIQ2RGB( img )
  
  return img
end

function funcs.plus_median_filter( img )

  -- This filter is applied differently than that of the sharpen and smooth filters

  --[[
  local filter = {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  }
  
  il.RGB2YIQ( img )
  
  img = funcs.filter( img, 0, filter, 1, 3 )
    
  il.YIQ2RGB( img )
  ]]
  
  return img
end
  
return funcs
