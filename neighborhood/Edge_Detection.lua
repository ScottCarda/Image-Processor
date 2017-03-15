--[[
  |                           Edge_Detection.lua                               |
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

--[[    sobel
  |
  |   Takes an image and calculates the smoothed sobel magnitude and direction.
  |   This is an edge detection operation that uses the x and y partial
  |   derivatives to find local extrema, which represent edges. The partial derivatives
  |   are approximated using separated filters to increase the efficiency of the operation.
  |
  |     Authors:
  |       Scott Carda,
  |       Christopher Smith
--]]
function funcs.sobel( img )

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
  --store global function calls to local variables for efficiency
  local reflection = helpers.reflection
  local floor = math.floor
  local sqrt = math.sqrt
  local in_range = helpers.in_range
  local atan2 = math.atan2
  local pi = math.pi

  -- first sweep of the image populates the x_table
  -- and y_table with the partially calculated values
  for row, col in img:pixels() do

    part_x = 0
    part_y = 0
    for i = 1, 3 do
      x = reflection( col+i-2, 0, img.width )
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
      y = reflection( row+i-2, 0, img.height )
      part_x = part_x + x_table[y][col] * filter2[i]
      part_y = part_y + y_table[y][col] * filter1[i]
    end

    -- calculate the magnitude
    val = floor( sqrt( part_x*part_x + part_y*part_y ) )
    mag_pix.r = in_range( val )

    -- calculate the direction using arctangent
    val = atan2( part_y, part_x )
    -- adjust for negative values
    if val < 0 then
      val = val + 2 * pi
    end

    -- map from radians to pixel intensities
    val = floor( val / ( 2 * pi ) * 256 )
    dir_pix.r = in_range( val )

  end

  -- convert image from YIQ to RGB
  il.YIQ2RGB( dir_img )
  il.YIQ2RGB( mag_img )

  return cpy_img, mag_img, dir_img

end


--[[    rotate_values
  |
  |  Helper function to return changing -3 and 5 locations in kirsch based on rotation.
  |  Similar to a sliding neighborhood solution.
  |
  |     Author: Chris Smith
--]]
local function rotate_values()
  return { {1, 2, 3, 3}, --E
    {1, 1, 2, 3}, --NE 
    {2, 1, 1, 3}, --N
    {3, 1, 1, 2}, --NW
    {3, 2, 1, 1}, --W
    {3, 3, 2, 1}, --SW
    {2, 3, 3, 1}, --S
    {1, 3, 3, 2}  --SE
  }
end
--[[    kirsch
  |
  |  Takes an image and performs both the kirsch direction and magnitude
  |  calculations at once and returns both images.
  |
  |  This Version of a kirsch uses a method similar to a sliding neighborhood so
  |  that values are not recalculated for every kirsch rotation.
  |
  |     Authors: Chris Smith, Scott Carda
--]]
function funcs.kirsch( img )
--East direction of the Kirsch Compass Masks
  local kirsch_mask = {
    {-3,-3,5},
    {-3, 0,5},
    {-3,-3,5}
  }
  --Used to keep track of the position that is changing from a -3 to 5
  local lead_val = {}
  --Used to keep track of the position that is changing from a 5 to -3
  local trail_val = {}

  local cpy_img = img:clone()
  il.RGB2YIQ( img )

  local mag_img = img:clone()
  local dir_img = img:clone()
  local dir_pix, mag_pix
  local x, y, t_y, t_x
  local sum
  --store global function calls to local variables for efficiency
  local floor = math.floor
  local in_range = helpers.in_range
  local reflection = helpers.reflection

  --keeps track of the rotation and max magnitude
  local rot, mag

  --x y locations for -3 and 5 positions that change between rotations
  local locations = rotate_values()
  for row, col in img:pixels() do
    dir_pix = dir_img:at(row, col)
    mag_pix = mag_img:at(row, col)
    sum = 0
    rot = 0
    --Apply the kirsch filter for the east direction
    for i = 1, 3 do
      y = reflection( (row+i-2), 0, img.height)
      for j = 1, 3 do
        x = reflection( (col+j-2), 0, img.width )
        sum = sum + kirsch_mask[i][j] * img:at(y,x).r
      end
    end
    mag = sum
    --Apply the remaining kirsch filters using a sliding neighborhood method
    for i = 1, 7 do
      y = reflection(   row + locations[i][1] - 2, 0, img.height )
      x = reflection(   col + locations[i][2] - 2, 0, img.width  )
      t_y = reflection( row + locations[i][3]- 2, 0, img.height )
      t_x = reflection( col + locations[i][4]- 2, 0, img.width  )
      --  8 *img:at(y,x) is for a pixel changing from a -3 to  a 5 in a rotation
      -- -8 * img:at(t_y, t_x) is for a pixel changing from a 5 to a -3 in a rotation
      sum = sum  + 8 * img:at(y,x).r - 8 * img:at(t_y, t_x).r
      if( sum > mag) then
        mag = sum
        rot = i
      end
    end
    mag_pix.r = in_range( mag/3 )
    mag_pix.g = 128
    mag_pix.b = 128

    dir_pix.r = in_range( floor(rot/8*256) )
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
--store global function calls to local variables for efficiency
  local reflection = helpers.reflection
  local in_range = helpers.in_range

  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )

    sum = 0
    -- neighborhood loop
    for i = 1, 3 do
      y = reflection( (row+i-2), 0, img.height )
      for j = 1, 3 do
        x = reflection( (col+j-2), 0, img.width )

        sum = sum + img:at( y, x ).r * filter[i][j]

      end
    end

    -- offset the value by 128
    sum = sum + 128

    -- assign the clipped value
    pix.r = in_range( math.abs( sum ) )

    -- remove the color
    pix.g = 128
    pix.b = 128

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

  --store global function calls to local variables for efficiency
  local sliding_histogram = helpers.sliding_histogram
  local in_range = helpers.in_range
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )

    -- using sliding histogram to efficiently get the
    -- histogram of the current pixel's neighborhood
    hist = sliding_histogram( img, row, col, size )

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
    pix.r = in_range( max - min )
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
  |  pixel to the variance.
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

  --store global function calls to local variables for efficiency
  local sliding_histogram = helpers.sliding_histogram
  local in_range = helpers.in_range

  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    hist = sliding_histogram( img, row, col, size )
    sum = 0
    sq_sum = 0
    --calculate the sum and the sum of the squares of neighborhood
    for i = 0, 255 do
      sum = sum + ( i * hist[i] )
      sq_sum = sq_sum + ( ( i * i ) * hist[i] )
    end
    --set the pixel to the variance of the neighborhood
    pix.r = in_range((sq_sum - (sum*sum) / n ) /n)
    pix.g = 128
    pix.b = 128
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

  --store global function calls to local variables for efficiency
  local sqrt = math.sqrt
  local sliding_histogram = helpers.sliding_histogram
  local in_range = helpers.in_range

  for row, col in img:pixels() do
    pix = cpy_img:at( row, col)
    hist = sliding_histogram( img, row, col, size )
    sum = 0
    sq_sum = 0
    --calculate the sum and the sum of the squares of neighborhood
    for i = 0, 255 do
      sum = sum + ( i * hist[i] )
      sq_sum = sq_sum + ( ( i * i ) * hist[i] )
    end
    --set pixel to the standard deviation of the neighborhood
    pix.r = in_range( sqrt( ( sq_sum - ( sum*sum ) /n) / n) )
    pix.g = 128
    pix.b = 128
  end
  il.YIQ2RGB (cpy_img)
  return cpy_img
end


return funcs