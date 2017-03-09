require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}

--[[    mean_filter
  |
  |   Takes an image and a neighborhood side length (the size argument)
  |   and performs a mean filter using a square neighborhood of the
  |   given side length. This will calculate the mean intensity of the
  |   intensities in the neighborhood and assigns that mean as the intensity
  |   for the target pixel. It will perform this neighborhood operation
  |   on each pixel in the image.
  |
  |     Author: Scott Carda
--]]
function funcs.mean_filter( img, size )
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  local x1, x2, y1, y2 -- pixel coordinates
  
  local sum -- the summation of the intensities of the pixels in a neighborhood
  local row_start_sum -- the sum at the start of a row
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- if it is the first neighborhood of the image, start the sum from scratch
    if row == 0 and col == 0 then
      
      -- calculate the sum of the pixel intensities in the starting neighborhood
      row_start_sum = 0
      for i = 1, size do
        y1 = helpers.reflection( i-(size-(size-1)/2), 0, img.height )
        for j = 1, size do
          x1 = helpers.reflection( j-(size-(size-1)/2), 0, img.width )
          
          row_start_sum = row_start_sum + img:at( y1, x1 ).r
      
        end
      end
      sum = row_start_sum
      
    elseif col == 0 then -- if it is the first neighborhood of a row, slide down from the previous row_start_sum
      
      y1 = helpers.reflection( row-(size-(size-1)/2), 0, img.height ) -- row to be deleted
      y2 = helpers.reflection( row+(size-(size-1)/2)-1, 0, img.height ) -- row to be added
      for i = 1, size do
        x1 = helpers.reflection( col+i-(size-(size-1)/2), 0, img.width )
        
        row_start_sum = row_start_sum - img:at( y1, x1 ).r -- remove the pixel
        row_start_sum = row_start_sum + img:at( y2, x1 ).r -- add the pixel
        
      end
      sum = row_start_sum
      
    else -- else, slide right from the previous sum
      
      x1 = helpers.reflection( col-(size-(size-1)/2), 0, img.width ) -- col to be deleted
      x2 = helpers.reflection( col+(size-(size-1)/2)-1, 0, img.width ) -- col to be added
      for i = 1, size do
        y1 = helpers.reflection( row+i-(size-(size-1)/2), 0, img.height )
        
        sum = sum - img:at( y1, x1 ).r -- remove the pixel
        sum = sum + img:at( y1, x2 ).r -- add the pixel
        
      end
      
    end
    
    -- set the pixel intensity to the average the sum
    pix.r = helpers.in_range( math.floor( sum / (size*size) ) )
    
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( cpy_img )
  
  return cpy_img
end

--[[    min_filter
  |
  |   Takes an image and a neighborhood side length (the size argument)
  |   and performs a minimum filter using a square neighborhood of the
  |   given side length. This will calculate the minimum intensity of the
  |   intensities in the neighborhood and assigns that minimum as the intensity
  |   for the target pixel. It will perform this neighborhood operation
  |   on each pixel in the image.
  |
  |     Author: Scott Carda
--]]
function funcs.min_filter( img, size )
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  local min -- the minimum of the intensities of the pixels in a neighborhood
  local hist -- the histogram of pixel intensities in a neighborhood
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- using sliding histogram to efficiently get the
    -- histogram of the current pixel's neighborhood
    hist = helpers.sliding_histogram( img, row, col, size )
    
    -- loop from the start of the histogram until a non-zero is found
    -- this will be the minimum value in the histogram
    min = 0
    while hist[min] == 0 and min < 255 do
      min = min + 1
    end
    
    -- assign the minimum to the target pixel
    pix.r = min
    
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

--[[    max_filter
  |
  |   Takes an image and a neighborhood side length (the size argument)
  |   and performs a maximum filter using a square neighborhood of the
  |   given side length. This will calculate the maximum intensity of the
  |   intensities in the neighborhood and assigns that maximum as the intensity
  |   for the target pixel. It will perform this neighborhood operation
  |   on each pixel in the image.
  |
  |     Author: Scott Carda
--]]
function funcs.max_filter( img, size )

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  local max -- the maximum of the intensities of the pixels in a neighborhood
  local hist -- the histogram of pixel intensities in a neighborhood
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- using sliding histogram to efficiently get the
    -- histogram of the current pixel's neighborhood
    hist = helpers.sliding_histogram( img, row, col, size )
    
    -- loop from the end of the histogram until a non-zero is found
    -- this will be the maximum value in the histogram
    max = 255
    while hist[max] == 0 and max > 0 do
      max = max - 1
    end
    
    -- assign the maximum to the target pixel
    pix.r = max
    
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( cpy_img )
  
  return cpy_img

end

--[[    range_filter
  |
  |   Takes an image and a neighborhood side length (the size argument)
  |   and performs a range filter using a square neighborhood of the
  |   given side length. This will calculate the range of the intensities
  |   in the neighborhood and assigns that range as the intensity
  |   for the target pixel. It will perform this neighborhood operation
  |   on each pixel in the image.
  |
  |     Author: Scott Carda
--]]
function funcs.range_filter( img, size )

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  -- the maximum and minimum of the intensities of the pixels in a neighborhood
  local max, min
  local hist -- the histogram of pixel intensities in a neighborhood
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- using sliding histogram to efficiently get the
    -- histogram of the current pixel's neighborhood
    hist = helpers.sliding_histogram( img, row, col, size )
    
    -- loop from the start of the histogram until a non-zero is found
    -- this will be the minimum value in the histogram
    min = 0
    while hist[min] == 0 and min < 255 do
      min = min + 1
    end
    
    -- loop from the end of the histogram until a non-zero is found
    -- this will be the maximum value in the histogram
    max = 255
    while hist[max] == 0 and max > min do
      max = max - 1
    end
    
    -- calculate the intensity range and assign it to the target pixel
    pix.r = helpers.in_range( max - min )
    -- remove the color
    pix.g = 128
    pix.b = 128
    
  end
  
  -- convert image from YIQ to RGB
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

--[[    sobel
  |
  |   Takes an image and calculates the smoothed sobel magnitude and direction.
  |   This is an edge detection operation that uses the x and y
  |   partial derivatives to find local extrema, which represent edges.
  |
  |     Author: Scott Carda
--]]
function funcs.sobel( img )

  -- make a copy of the image to return
  local cpy_img = img:clone()

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local dir_img = img:clone() -- sobel direction image
  local mag_img = img:clone() -- sobel magnitude image
  local dir_pix -- a pixel from the dir_img
  local mag_pix -- a pixel from the mag_img
  
  local part_y -- the partial derivative for y
  local part_x -- the partial derivative for x
  local val -- unclipped calculated value of pixel sobel magnitude
  
  for row, col in img:pixels() do
    dir_pix = dir_img:at( row, col )
    mag_pix = mag_img:at( row, col )
    
    -- get the sobel partial x and partial y
    part_y, part_x = part_deriv( img, row, col )
    
    -- calculate the magnitude
    val = math.floor( math.sqrt( part_x*part_x + part_y*part_y ) )
    mag_pix.r = helpers.in_range( val )
    
    -- calculate the direction using arctangent
    val = math.atan2( part_y, part_x )
    -- adjust for negative values
    if val < 0 then
      val = val + 2 * math.pi
    end
    
    -- map from radians to pixel intensities
    val = math.floor( val / ( 2 * math.pi ) * 256 )
    dir_pix.r = helpers.in_range( val )
    
    -- remove the color
    mag_pix.g = 128
    mag_pix.b = 128
    dir_pix.g = 128
    dir_pix.b = 128
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( dir_img )
  il.YIQ2RGB( mag_img )
  
  return cpy_img, mag_img, dir_img

end



return funcs
