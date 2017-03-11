--[[
  |                            Edge_Detection.lua                              |
  |                                                                            |
  |                                                                            |
  |   This file contains the function definitions for the edge detection       |
  |   menu items.                                                              |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

require ( "ip" )
local il = require ( "il" )
local helpers = require ( "Helper_Funcs" )

local funcs = {}

function funcs.new_sobel( img )
  
  -- make a copy of the image to return
  local cpy_img = img:clone()
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  -- tables for keeping track of partially computed partial derivatives
  local y_table = {}
  local x_table = {}
  
  -- make the tables 2D
  for i = 0, img.height-1 do
    x_table[i] = {}
    y_table[i] = {}
  end
  
  local dir_img = image.flat( img.width, img.height, 128 ) -- sobel direction image
  local mag_img = image.flat( img.width, img.height, 128 ) -- sobel magnitude image
  local dir_pix -- a pixel from the dir_img
  local mag_pix -- a pixel from the mag_img
  
  local part_y -- the partial derivative for y
  local part_x -- the partial derivative for x
  local val -- temperary value used for calculations
  
  local x, y -- pixel coordinates
  
  -- separated filters for the sobel partial derivative filters
  local filter1 = { -1, 0, 1 }
  local filter2 = { 1, 2, 1 }
  
  -- first sweep of the image populates the x_table
  -- and y_table with the partially calculated values
  for row, col in img:pixels() do
    
    part_x = 0
    part_y = 0
    for i = 1, 3 do
      x = helpers.reflection( col+i-2, 0, img.width )
      part_x = part_x + img:at( row, x ).r * filter1[i]
      part_y = part_y + img:at( row, x ).r * filter2[i]
    end
    
    x_table[row][col] = part_x
    y_table[row][col] = part_y
  end
  
  -- filter one has to be adjusted here to get the proper direction on y
  filter1 = { 1, 0, -1 }
  
  -- second sweep grabs the partially calculated values from the tables
  -- and finishes the calculation for part_x and part_y
  for row, col in img:pixels() do
    dir_pix = dir_img:at( row, col )
    mag_pix = mag_img:at( row, col )
    
    part_x = 0
    part_y = 0
    for i = 1, 3 do
      y = helpers.reflection( row+i-2, 0, img.height )
      part_x = part_x + x_table[y][col] * filter2[i]
      part_y = part_y + y_table[y][col] * filter1[i]
    end
  
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
  
  end

  -- convert image from YIQ to RGB
  il.YIQ2RGB( dir_img )
  il.YIQ2RGB( mag_img )
  
  return cpy_img, mag_img, dir_img
  
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

--[[    kirsch
  |
  |  Takes an image and performs both the kirsch direction and magnitude
  |  calculations at once and returns both images.
  |
  |     Author: Chris Smith
--]]
function funcs.kirsch( img )
  local kirsch_mask
  local cpy_img = img:clone()
  il.RGB2YIQ( img )

  local mag_img = img:clone()
  local dir_img = img:clone()
  local dir_pix, mag_pix
  local x, y
  local sum
  local max, mag

  for row, col in img:pixels() do
    dir_pix = dir_img:at( row, col )
    mag_pix = mag_img:at( row, col )

    max = 0
    mag = 0
    for rot = 0, 7 do
      sum = 0
      --get kirsch mask and sum up values using reflection on image borders
      kirsch_mask = helpers.rotate_kirsch( rot )
      for i = 1, 3 do
        y = helpers.reflection( (row+i-2), 0, img.height)
        for j = 1, 3 do
          x = helpers.reflection( (col+j-2), 0, img.width )
          sum = sum + img:at( y, x ).r * kirsch_mask[i][j]
        end
      end-- end filter

      if sum > mag then
        mag = sum -- store the maximum magnitude
        max = rot -- store the direction that gives largest magnitude
      end
    end--end rotation

    mag_pix.r = helpers.in_range( mag/3 )
    mag_pix.g = 128
    mag_pix.b = 128

    dir_pix.r = helpers.in_range( math.floor(max/8*256) )
    dir_pix.g = 128
    dir_pix.b = 128
  end
  il.YIQ2RGB(mag_img)
  il.YIQ2RGB(dir_img)
  return cpy_img, mag_img, dir_img
end

--[[    laplacian
  |
  |   Takes an image and calculates the Laplacian edge operator.
  |   This is an edge detection operation that uses the a filter.
  |
  |     Author: Scott Carda
--]]
function funcs.laplacian( img )

  -- the filter for the Laplacian operation
  local filter = {
      { 0,-1, 0},
      {-1, 4,-1},
      { 0,-1, 0}
    }
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  local x, y -- coordinates for a pixel
  
  -- the neighborhood summation of the products of the
  -- intensities of pixels with their respective filter element
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
    
    -- offset the value by 128
    sum = sum + 128
    
    -- assign the clipped value
    pix.rgb[0] = helpers.in_range( math.abs( sum ) )
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

--[[    var_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument) and
  |  performs a variance filter using a square neighborhood of the given side
  |  length. This calculates the variance of the neighborhood and sets the center
  |  pixel to the variance
  |
  |     Author: Chris Smith
--]]
function funcs.var_filter( img, size )
  il.RGB2YIQ( img )
  local cpy_img = img:clone()
  local pix
  local hist
  local sum
  local sq_sum
  local n = size * size
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    hist = helpers.sliding_histogram( img, row, col, size )
    sum = 0
    sq_sum = 0
    --calculate the sum and the sum of the squares of neighborhood
    for i = 0, 255 do
      sum = sum + ( i * hist[i] )
      sq_sum = sq_sum + ( ( i * i ) * hist[i] )
    end
    --set the pixel to the variance of the neighborhood
    pix.r = helpers.in_range((sq_sum - (sum*sum) / n ) /n)
  end
  il.YIQ2RGB ( cpy_img)
  return cpy_img
end

--[[    sd_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument ) and
  |  performs a standard deviation filter using a square neighborhood of the
  |  given side length. This calculates the standard deviation of the neighborhood
  |  and sets the center pixel to the standard deviation.
  |
  |     Author: Chris Smith
--]]
function funcs.sd_filter( img, size)
  il.RGB2YIQ( img )
  local cpy_img = img:clone()
  local pix

  local hist
  local sum
  local sq_sum
  local n = size * size
  local sqrt = math.sqrt
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col)
    hist = helpers.sliding_histogram( img, row, col, size )
    sum = 0
    sq_sum = 0
    --calculate the sum and the sum of the squares of neighborhood
    for i = 0, 255 do
      sum = sum + ( i * hist[i] )
      sq_sum = sq_sum + ( ( i * i ) * hist[i] )
    end
    --set pixel to the standard deviation of the neighborhood
    pix.r = sqrt( ( sq_sum - ( sum*sum ) /n) / n)
  end
  il.YIQ2RGB (cpy_img)
  return cpy_img
end


return funcs