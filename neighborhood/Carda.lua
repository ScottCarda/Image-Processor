require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}

function funcs.mean_filter( img, size )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local sum
  
  for row, col in img:pixels( --[[(size-1)/2]] ) do
    pix = cpy_img:at( row, col )
    
    sum = 0
    
    for i = 1, size do
      y = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
      --y = row+i-(size-(size-1)/2)
      for j = 1, size do
        x = helpers.reflection( col+j-(size-(size-1)/2), 0, img.width )
        --x = col+j-(size-(size-1)/2)
        
        sum = sum + img:at( y, x ).r
        
      end
    end
    
    pix.r = helpers.in_range( math.floor( sum / (size*size) ) )
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
end

function funcs.min_filter( img, size )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local min
  local val -- value of a particular pixel's intensity
  
  for row, col in img:pixels( --[[(size-1)/2]] ) do
    pix = cpy_img:at( row, col )
    
    min = 256
    
    for i = 1, size do
      y = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
      --y = row+i-(size-(size-1)/2)
      for j = 1, size do
        x = helpers.reflection( col+j-(size-(size-1)/2), 0, img.width )
        --x = col+j-(size-(size-1)/2)
        
        val = img:at( y, x ).r
        if min > val then
          min = val
        end
        
      end
    end
    
    pix.r = helpers.in_range( min )
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.max_filter( img, size )

  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local max
  local val -- value of a particular pixel's intensity
  
  for row, col in img:pixels( --[[(size-1)/2]] ) do
    pix = cpy_img:at( row, col )
    
    max = -1
    
    for i = 1, size do
      y = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
      --y = row+i-(size-(size-1)/2)
      for j = 1, size do
        x = helpers.reflection( col+j-(size-(size-1)/2), 0, img.width )
        --x = col+j-(size-(size-1)/2)
        
        val = img:at( y, x ).r
        if max < val then
          max = val
        end
        
      end
    end
    
    pix.r = helpers.in_range( max )
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.range_filter( img, size )

  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local min
  local max
  local val -- value of a particular pixel's intensity
  
  for row, col in img:pixels( --[[(size-1)/2]] ) do
    pix = cpy_img:at( row, col )
    
    min = 256
    max = -1
    
    for i = 1, size do
      y = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
      --y = row+i-(size-(size-1)/2)
      for j = 1, size do
        x = helpers.reflection( col+j-(size-(size-1)/2), 0, img.width )
        --x = col+j-(size-(size-1)/2)
        
        val = img:at( y, x ).r
        if min > val then
          min = val
        end
        if max < val then
          max = val
        end
        
      end
    end
    
    pix.r = helpers.in_range( max - min )
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end


local function sobel( img, row, col )
  
  local part_y = 0
  local part_x = 0
  local val
  local x, y -- coordinates for a pixel
  
  local y_sobel = {
    {-1,-2,-1},
    { 0, 0, 0},
    { 1, 2, 1}
  }
  
  local x_sobel = {
    { 1, 0,-1},
    { 2, 0,-2},
    { 1, 0,-1}
  }
    
  for i = 1, 3 do
    y = helpers.reflection( row+i-2, 0, img.height )
    --y = row+i-2
    for j = 1, 3 do
      if i ~= 2 or j ~= 2 then
        x = helpers.reflection( col+j-2, 0, img.width )
        --x = col+j-2
        
        val = img:at( y, x ).r
        part_y = part_y + val * y_sobel[i][j]
        part_x = part_x + val * x_sobel[i][j]
        
      end
    end
  end
  
  return part_y, part_x
end

function funcs.sobel_mag( img )

  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local part_y
  local part_x
  local val
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    part_y, part_x = sobel( img, row, col )
    
    val = math.floor( math.sqrt( part_x*part_x + part_y*part_y ) )
    pix.r = helpers.in_range( val )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.sobel_dir( img )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local part_y
  local part_x
  local val
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    part_y, part_x = sobel( img, row, col )
    
    val = math.floor( ( math.atan2( part_y, part_x ) + math.pi ) / ( 2 * math.pi ) * 256 )
    pix.r = helpers.in_range( val )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.laplacian( img, filter_type, offset )

  local filter1 = {
      { 0, 1, 0},
      { 1,-4, 1},
      { 0, 1, 0}
    }
    
  local filter2 = {
      { 1, 1, 1},
      { 1,-8, 1},
      { 1, 1, 1}
    }
    
  local filter3 = {
      { 0,-1, 0},
      {-1, 4,-1},
      { 0,-1, 0}
    }
    
  local filter4 = {
      {-1,-1,-1},
      {-1, 8,-1},
      {-1,-1,-1}
    }
    
  local filter
  
  if filter_type == 'First' then
    filter = filter1
  elseif filter_type == 'Second' then
    filter = filter2
  elseif filter_type == 'Third' then
    filter = filter3
  elseif filter_type == 'Fourth' then
    filter = filter4
  end
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local sum
  
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
    
    if offset == true then
      sum = sum + 128
    end
      
    pix.rgb[0] = helpers.in_range( sum )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

return funcs
