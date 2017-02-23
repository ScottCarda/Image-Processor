require "ip"
local il = require "il"
--local helpers = require "helper_functs"

--[[ Only the in_range, apply_scale, fast_smooth, fast_sharp, fast_plus_median are used! ]]

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
  |   that the value lies between the given min and max values, [min, max).
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

--[[function sum_filter( vals, weights )
  local sum = 0
  for i = 1, math.min( #vals, #weights ) do
    sum = sum + vals[i] * weights[i]
  end
  return sum
end]]

function sum_of_products( old_val, val, weight )
  if old_val == nil then
    old_val = 0
  end
  return old_val + val * weight
end

function freq_list( old_val, val, weight )
  if old_val == nil then
    old_val = {}
  end
  for i = 1, weight do
    old_val[#old_val+1] = val
  end
  return old_val
end

function apply_scale( filter, scale )
  
  for i = 1, #filter do
    for j = 1, #filter[i] do
      filter[i][j] = filter[i][j] * scale
    end
  end
  
end

--[[ make separate func
  local weights = {}
  local temp
  for i = 1, n do
    temp = {}
    for j = 1, m do
      temp[#temp+1] = filter[i][j] * scale
    end
    weights[#weights+1] = temp
  end]]

function funcs.small_filter( img, chan, row, col, filter, operation, n, m, y_off, x_off )
  
  --[[local n = #filter
  local m = #filter[1]
  local x_off = (1-m)/2-1
  local y_off = (1-n)/2-1]]
  local x
  local y
  local result
  
  for i = 1, n do
    y = (row+i+y_off)%img.height
    for j = 1, m do
      x = (col+j+x_off)%img.width
      --vals[#vals+1] = img:at( y , x ).rgb[chan]
      
      result = operation( result, img:at( y , x ).rgb[chan], filter[i][j] )
      
    end
  end
  
  return result
end

function funcs.apply_filter( img, chan, filter, operation, post_op )
  
  local n = #filter
  local m = #filter[1]
  
  local x
  local y
  local x_off = (1-m)/2-1
  local y_off = (1-n)/2-1
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local result
  
  for row, col in img:pixels() do
    
    pix = cpy_img:at( row, col )
    
    result = nil
    for i = 1, n do
      y = (row+i+y_off)%img.height
      for j = 1, m do
        x = (col+j+x_off)%img.width
        --vals[#vals+1] = img:at( y , x ).rgb[chan]
        
        result = operation( result, img:at( y , x ).rgb[chan], filter[i][j] )
        
      end
    end
    
    if post_op ~= nil then
      result = post_op( result )
    end
    
    --pix.rgb[chan] = funcs.in_range( operation( vals, weights ) )
    
    pix.rgb[chan] = funcs.in_range( result )
    
  end
  
  return cpy_img
  
end

function funcs.slow_filter( img, chan, filter, operation, scale )
  
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
      for i = 1, n do
        y = i-(n-1)/2-1
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


--[[  
  --local filter = {
  --  {1,2,1},
  --  {2,4,2},
  --  {1,2,1}
  --}
  
  --apply_scale( filter, 1/16 )
  
  local small_filter = { 1/4, 2/4, 1/4 }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local sum
  local x, y
  
  for row, col in img:pixels( 1 ) do
    pix = cpy_img:at( row, col )
    
    sum = 0
    --for i = 1, 3 do
    --  y = (row+i-2)%img.height
    for i = 1, 3 do
      --x = (col+i-2)%img.width
      --x = funcs.reflection( (col+i-2), 0, img.width-1 )
      x = (col+i-2)
      sum = sum + img:at( row, x ).r * small_filter[i]
    end
    --end
    
    pix.rgb[0] = funcs.in_range( sum )
  end
  
  for row, col in cpy_img:pixels( 1 ) do
    pix = img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      --y = (row+i-2)%img.height
      --y = funcs.reflection( (row+i-2), 0, img.height-1 )
      y = (row+i-2)
      sum = sum + cpy_img:at( y, col ).r * small_filter[i]
    end
    
    pix.rgb[0] = funcs.in_range( sum )
  end
  
  il.YIQ2RGB( img )
  
  return img
  
end]]

function funcs.fast_smooth( img )
  
  --local filter = {
  --  {1,2,1},
  --  {2,4,2},
  --  {1,2,1}
  --}
  
  --apply_scale( filter, 1/16 )
  
  local small_filter = { 1/4, 2/4, 1/4 }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local sum
  local x, y
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    sum = 0
    --for i = 1, 3 do
    --  y = (row+i-2)%img.height
    for i = 1, 3 do
      --x = (col+i-2)%img.width
      x = funcs.reflection( (col+i-2), 0, img.width )
      --x = col+i-2
      sum = sum + img:at( row, x ).r * small_filter[i]
    end
    --end
    
    pix.rgb[0] = funcs.in_range( sum )
  end
  
  for row, col in cpy_img:pixels() do
    pix = img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      --y = (row+i-2)%img.height
      y = funcs.reflection( (row+i-2), 0, img.height )
      --y = row+i-2
      sum = sum + cpy_img:at( y, col ).r * small_filter[i]
    end
    
    pix.rgb[0] = funcs.in_range( sum )
  end
  
  il.YIQ2RGB( img )
  
  return img
  
end

function funcs.fast_sharp( img )
  
  local filter = {
    {0,-1,0},
    {-1,5,-1},
    {0,-1,0}
  }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local sum
  local x, y
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      --y = (row+i-2)%img.height
      y = funcs.reflection( (row+i-2), 0, img.height-1 )
      for j = 1, 3 do
        --x = (col+j-2)%img.width
        x = funcs.reflection( (col+j-2), 0, img.width-1 )
        sum = sum + img:at( y, x ).r * filter[i][j]
      end
    end
    
    pix.rgb[0] = funcs.in_range( sum )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
  
end

function funcs.fast_plus_median( img )
  
  local filter = {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local list
  local x, y
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    list = {}
    --[[for i = 1, 3 do
      y = (row+i-2)%img.height
      for j = 1, 3 do
        x = (col+j-2)%img.width
        for k = 1, filter[i][j] do
          list[#list+1] = img:at( y, x ).r
        end
      end
    end]]
    
    list = {
      img:at( row, col ).r,
      img:at( funcs.reflection( (row+1), 0, img.height-1 ), col ).r,
      img:at( funcs.reflection( (row-1), 0, img.height-1 ), col ).r,
      img:at( row, funcs.reflection( (col+1), 0, img.width-1 ) ).r,
      img:at( row, funcs.reflection( (col-1), 0, img.width-1 ) ).r
      }
    
    --[[for i = 1, 3 do
      y = (row+i-2)%img.height
      for j = 1, 3 do
        x = (col+j-2)%img.width
        list[#list+1] = img:at( y, x ).r
      end
    end]]
    
    table.sort( list )
    
    pix.r = funcs.in_range( list[3] )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
  
end

function funcs.smooth_filter( img )
  
  local filter = {
    {1,2,1},
    {2,4,2},
    {1,2,1}
  }
  
  apply_scale( filter, 1/16 )
  
  local filter1 = {{ 1, 2, 1 }}
  local filter2 = {{1},{2},{1}}
  
  apply_scale( filter1, 1/4 )
  apply_scale( filter2, 1/4 )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local result
  
  local n = #filter1
  local m = #filter1[1]
  local x_off = (1-m)/2-1
  local y_off = (1-n)/2-1
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    result = funcs.small_filter( img, 0, row, col, filter1, sum_of_products, n, m, y_off, x_off )
    pix.rgb[0] = funcs.in_range( result )
  end
  
  --img = cpy_img
  n = #filter2
  m = #filter2[1]
  x_off = (1-m)/2-1
  y_off = (1-n)/2-1
  
  for row, col in cpy_img:pixels() do
    pix = img:at( row, col )
    result = funcs.small_filter( cpy_img, 0, row, col, filter2, sum_of_products, n, m, y_off, x_off )
    pix.rgb[0] = funcs.in_range( result )
  end
  
  --img = cpy_img
  
  --img = funcs.filter( img, 0, filter1, sum_filter, 1/4 )
  --img = funcs.filter( img, 0, filter2, sum_filter, 1/4 )
  
  --img = funcs.old_filter( img, 0, filter1, sum_of_products )
  --img = funcs.old_filter( img, 0, filter2, sum_of_products )
  
  --img = funcs.fast_filter( img, 0, filter, 1/16, 3 )
  
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
