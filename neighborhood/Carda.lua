require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}

function funcs.mean_filter( img, size )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x1, x2, y1, y2 -- coordinates for a pixel
  
  local sum
  local row_start_sum
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    if row == 0 and col == 0 then
      
      row_start_sum = 0
      for i = 1, size do
        y1 = helpers.reflection( i-(size-(size-1)/2), 0, img.height )
        for j = 1, size do
          x1 = helpers.reflection( j-(size-(size-1)/2), 0, img.width )
          
          row_start_sum = row_start_sum + img:at( y1, x1 ).r
      
        end
      end
      sum = row_start_sum
      
    elseif col == 0 then
      
      y1 = helpers.reflection( row-(size-(size-1)/2), 0, img.height ) -- row to be deleted
      y2 = helpers.reflection( row+(size-(size-1)/2)-1, 0, img.height ) -- row to be added
      for i = 1, size do
        x1 = helpers.reflection( col+i-(size-(size-1)/2), 0, img.width )
        
        row_start_sum = row_start_sum - img:at( y1, x1 ).r
        row_start_sum = row_start_sum + img:at( y2, x1 ).r
        
      end
      sum = row_start_sum
      
    else
      
      x1 = helpers.reflection( col-(size-(size-1)/2), 0, img.width ) -- col to be deleted
      x2 = helpers.reflection( col+(size-(size-1)/2)-1, 0, img.width ) -- col to be added
      for i = 1, size do
        y1 = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
        
        sum = sum - img:at( y1, x1 ).r
        sum = sum + img:at( y1, x2 ).r
        
      end
      
    end
    
    pix.r = helpers.in_range( math.floor( sum / (size*size) ) )
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
end

function funcs.other_min_filter( img, size )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local min
  local hist
  local sliding_histogram = helpers.sliding_histogram_factory( img, size )
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    hist = sliding_histogram( row, col )
    
    min = 0
    while hist[min] == 0 and min < 255 do
      min = min + 1
    end
    
    pix.r = min
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.min_filter( img, size )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local min
  local hist
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    hist = helpers.sliding_histogram( img, row, col, size )
    
    min = 0
    while hist[min] == 0 and min < 255 do
      min = min + 1
    end
    
    pix.r = min
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.max_filter( img, size )

  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local max
  local hist
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    hist = helpers.sliding_histogram( img, row, col, size )
    
    max = 255
    while hist[max] == 0 and max > 0 do
      max = max - 1
    end
    
    pix.r = max
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.range_filter( img, size )

  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  
  local max, min
  local hist
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    hist = helpers.sliding_histogram( img, row, col, size )
    
    min = 0
    while hist[min] == 0 and min < 255 do
      min = min + 1
    end
    
    max = 255
    while hist[max] == 0 and max > min do
      max = max - 1
    end
    
    pix.r = helpers.in_range( max - min )
    pix.g = 128
    pix.b = 128
    
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

--[[    part_deriv
  |
  |   Takes an image and a position in the image. Approximates the partial
  |   derivatives for x and y directions. Performs a preprocessing smooth operation.
  |
  |     Author: Scott Carda
--]]
local function part_deriv( img, row, col )
  
  local part_y = 0 -- the partial derivative for y
  local part_x = 0 -- the partial derivative for x
  local val -- value of a particular pixel's intensity
  local x, y -- coordinates for a pixel
  
  -- the y direciton difference filter, with smoothing 
  local y_diff = {
    { 1, 2, 1},
    { 0, 0, 0},
    {-1,-2,-1}
  }
  
  -- the x direciton difference filter, with smoothing 
  local x_diff = {
    {-1, 0, 1},
    {-2, 0, 2},
    {-1, 0, 1}
  }
  
  -- neighborhood loop
  for i = 1, 3 do
    y = helpers.reflection( row+i-2, 0, img.height )
    for j = 1, 3 do
      -- skip central element of the filters
      if i ~= 2 or j ~= 2 then
        x = helpers.reflection( col+j-2, 0, img.width )
        
        -- calculate part_x, part_y
        val = img:at( y, x ).r
        part_y = part_y + val * y_diff[i][j]
        part_x = part_x + val * x_diff[i][j]
        
      end
    end
  end
  
  return part_y, part_x
end

--[[    sobel_mag
  |
  |   Takes an image and calculates the smoothed sobel magnitude.
  |   This is an edge detection operation that uses the x and y
  |   partial derivatives to find local extrema, which represent edges.
  |
  |     Author: Scott Carda
--]]
function funcs.sobel_mag( img )

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  local part_y -- the partial derivative for y
  local part_x -- the partial derivative for x
  local val -- unclipped calculated value of pixel sobel magnitude
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- get the sobel partial x and partial y
    part_y, part_x = part_deriv( img, row, col )
    
    -- calculate the magnitude
    val = math.floor( math.sqrt( part_x*part_x + part_y*part_y ) )
    pix.r = helpers.in_range( val )
    
    -- remove the color
    pix.g = 128
    pix.b = 128
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.sobel_dir( img )
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  --local cpy_img = image.flat( img.width, img.height )
  local pix -- a pixel
  
  local part_y
  local part_x
  local val
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    part_y, part_x = part_deriv( img, row, col )
    
    val = math.atan2( part_y, part_x )
    if val < 0 then
      val = val + 2 * math.pi
    end
    val = math.floor( val / ( 2 * math.pi ) * 256 )
    pix.r = helpers.in_range( val )
    pix.g = 128
    pix.b = 128
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

function funcs.laplacian( img )

  local filter = {
      { 0,-1, 0},
      {-1, 4,-1},
      { 0,-1, 0}
    }
  
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone()
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  local sum
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    sum = 0
    -- neighborhood loop
    for i = 1, 3 do
      y = helpers.reflection( (row+i-2), 0, img.height )
      for j = 1, 3 do
        x = helpers.reflection( (col+j-2), 0, img.width )
        
        sum = sum + img:at( y, x ).r * filter[i][j]
        
      end
    end
    
    sum = sum + 128
      
    pix.rgb[0] = helpers.in_range( math.abs( sum ) )
  end
  
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

return funcs
