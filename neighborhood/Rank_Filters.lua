--[[
  |                           Rank_Filters.lua                                 |
  |                                                                            |
  |                                                                            |
  |   This file contains the function definitions for the rank based filters   |
  |   menu items.                                                              |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

local il = require ( "il" )
local helpers = require ( "Helper_Funcs" )

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

--[[    median_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument) and
  |  performs a median filter using a square neighborhood of the given side
  |  length. This will sort the values and set the center pixel in the neighborhood
  |  to the median value of all the pixels in the neighborhood.
  |
  |     Author: Chris Smith
--]]
function funcs.median_filter( img, size )
  il.RGB2YIQ( img )
  local cpy_img = img:clone()
  local pix

  local hist
  local count
  local i
  local ceil = math.ceil

  for row, col in img:pixels() do
    pix = cpy_img:at(row, col)
    hist = helpers.sliding_histogram(img, row, col, size)
    i = -1
    count = 0
    --find the middle value of the neighborhood and set pixel to it
    while count < ceil( size * size / 2 ) do
      i = i + 1
      count = count + hist[i]
    end
    pix.r = i
  end
  il.YIQ2RGB( cpy_img)

  return cpy_img

end

--[[    sliding_plus_histogram
  |
  |   Takes an image, a position in the image. Efficiently
  |   calculates the histogram of the plus-shaped neighborhood centered
  |   on the given position by using the previously computed histogram.
  |   This function is intended to be called in a row-major image loop.
  |
  |     Authors: Scott Carda
--]]
do
  local hist -- the histogram
  local row_start_hist -- the histogram at the beginning of a row
  function sliding_plus_histogram( img, row, col )
    
    local x, y -- coordinates for a pixel
    local val -- value of a particular pixel's intensity
    
    -- if it is the first histogram of the image, make a new histogram
    if row == 0 and col == 0 then
      
      -- initialize the histogram
      row_start_hist = {}
      for i = 0, 255 do
        row_start_hist[i] = 0
      end
      
      -- initial neighborhood histogram's values
      val = img:at( helpers.reflection( (row-1), 0, img.height ), col ).r
      row_start_hist[val] = row_start_hist[val] + 1
      val = img:at( row, col ).r
      row_start_hist[val] = row_start_hist[val] + 1
      val = img:at( row, helpers.reflection( (col-1), 0, img.width ) ).r
      row_start_hist[val] = row_start_hist[val] + 1
      val = img:at( row, helpers.reflection( (col+1), 0, img.width ) ).r
      row_start_hist[val] = row_start_hist[val] + 1
      val = img:at( helpers.reflection( (row+1), 0, img.height ), col ).r
      row_start_hist[val] = row_start_hist[val] + 1
      
      hist = helpers.table_copy( row_start_hist )
      
    -- if it is the first histogram of a row, slide down from the previous row_start_hist
    elseif col == 0 then
      
      -- remove old left value
      y = helpers.reflection( row-1, 0, img.height )
      x = helpers.reflection( col-1, 0, img.width )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] - 1
      
      -- remove old right value
      x = helpers.reflection( col+1, 0, img.width )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] - 1
      
      -- add new right value
      y = helpers.reflection( row, 0, img.height )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] + 1
      
      -- add new left value
      x = helpers.reflection( col-1, 0, img.width )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] + 1
      
      -- add new bottom value
      y = helpers.reflection( row+1, 0, img.height )
      x = helpers.reflection( col, 0, img.width )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] + 1
      
      -- remove old top value
      y = helpers.reflection( row-2, 0, img.height )
      val = img:at( y, x ).r
      row_start_hist[val] = row_start_hist[val] - 1
      
      hist = helpers.table_copy( row_start_hist )
      
    else -- else, slide right from the previous histogram
      
      -- remove old top value
      y = helpers.reflection( row-1, 0, img.height )
      x = helpers.reflection( col-1, 0, img.width )
      val = img:at( y, x ).r
      hist[val] = hist[val] - 1
      
      -- remove old bottom value
      y = helpers.reflection( row+1, 0, img.height )
      val = img:at( y, x ).r
      hist[val] = hist[val] - 1
      
      -- add new bottom value
      x = helpers.reflection( col, 0, img.width )
      val = img:at( y, x ).r
      hist[val] = hist[val] + 1
      
      -- add new top value
      y = helpers.reflection( row-1, 0, img.height )
      val = img:at( y, x ).r
      hist[val] = hist[val] + 1
      
      -- add new right value
      y = helpers.reflection( row, 0, img.height )
      x = helpers.reflection( col+1, 0, img.width )
      val = img:at( y, x ).r
      hist[val] = hist[val] + 1
      
      -- remove old left value
      x = helpers.reflection( col-2, 0, img.width )
      val = img:at( y, x ).r
      hist[val] = hist[val] - 1
      
    end
      
    return hist
    
  end
end

--[[    plus_median_filter
  |
  |   Takes an image and calculates the median intensity of the
  |   intensities in the plus-shaped neighborhood and assigns that median
  |   as the intensity for the target pixel. It will perform this
  |   neighborhood operation on each pixel in the image.
  |
  |     Authors: Scott Carda
--]]
function funcs.plus_median_filter( img )
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  local median -- the median of the intensities of the pixels in a neighborhood
  local hist -- the histogram of pixel intensities in a neighborhood
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    -- using sliding histogram plus to efficiently get the
    -- histogram of the current pixel's neighborhood
    hist = sliding_plus_histogram( img, row, col )
    
    median = -1
    local sum = 0 -- the number of pixels found so far
    -- there are 5 pixels in a neighborhood, so find the 3rd one
    while sum < 3 and median < 255 do
      median = median + 1
      sum = sum + hist[median]
    end
    
    pix.r = helpers.in_range( median )
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

return funcs