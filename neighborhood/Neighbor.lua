require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

--[[ Only the in_range, apply_scale, fast_smooth, fast_sharp, fast_plus_median are used! ]]

local funcs = {}

function funcs.smooth_filter( img )
  
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
    for i = 1, 3 do
      x = helpers.reflection( (col+i-2), 0, img.width )
      
      sum = sum + img:at( row, x ).r * small_filter[i]
      
    end
    
    pix.rgb[0] = helpers.in_range( sum )
  end
  
  for row, col in cpy_img:pixels() do
    pix = img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      y = helpers.reflection( (row+i-2), 0, img.height )
      
      sum = sum + cpy_img:at( y, col ).r * small_filter[i]
      
    end
    
    pix.rgb[0] = helpers.in_range( sum )
  end
  
  il.YIQ2RGB( img )
  
  return img
  
end

function funcs.sharp_filter( img )
  
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
      y = helpers.reflection( (row+i-2), 0, img.height )
      --y = row+i-2
      for j = 1, 3 do
        x = helpers.reflection( (col+j-2), 0, img.width )
        --x = col+j-2
        
        sum = sum + img:at( y, x ).r * filter[i][j]
        
      end
    end
    
    pix.rgb[0] = helpers.in_range( sum )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
  
end

--[[function funcs.plus_median_filter( img )
  local filter = {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local list
  local sorted_list
  local where
  local x, y
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    list = {}
    
    if col == 0 then
      list = {
        img:at( helpers.reflection( (row-1), 0, img.height ), col ).r,
        img:at( row, col ).r,
        img:at( row, helpers.reflection( (col-1), 0, img.width ) ).r,
        img:at( row, helpers.reflection( (col+1), 0, img.width ) ).r,
        img:at( helpers.reflection( (row+1), 0, img.height ), col ).r
      }
      where = 1
    else
      list[where] = -1
      list[where+2] = -1
      list[where+4] = -1
      where = where + 5
    end
    
    sorted_list = helpers.sort_pixels( list )
    
    pix.r = helpers.in_range( sorted_list[3] )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
  
end]]

function funcs.plus_median_filter( img )
  local filter = {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local list
  local sorted_list
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
      img:at( helpers.reflection( (row+1), 0, img.height ), col ).r,
      img:at( helpers.reflection( (row-1), 0, img.height ), col ).r,
      img:at( row, helpers.reflection( (col+1), 0, img.width ) ).r,
      img:at( row, helpers.reflection( (col-1), 0, img.width ) ).r
    }
    
    --[[list = {
      img:at( row, col ).r,
      img:at( row+1, col ).r,
      img:at( row-1, col ).r,
      img:at( row, col+1 ).r,
      img:at( row, col-1 ).r
    }]]
    
    --[[for i = 1, 3 do
      y = (row+i-2)%img.height
      for j = 1, 3 do
        x = (col+j-2)%img.width
        list[#list+1] = img:at( y, x ).r
      end
    end]]
    
    sorted_list = helpers.sort_pixels( list )
    
    pix.r = helpers.in_range( sorted_list[3] )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
  
end
  
return funcs
