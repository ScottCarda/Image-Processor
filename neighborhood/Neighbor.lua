
require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}

--[[    smooth_filter
  |
  |   Takes an image and applies a smoothing filter to it.
  |   The smooth filter is separated into two 1-D filters, and applied
  |   consecutively to the image to produce the smoothing effect.
  |
  |     Author: Scott Carda
--]]
function funcs.smooth_filter( img )
  
  -- the smooth filter after it has been separated
  local small_filter = { 1/4, 2/4, 1/4 }
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  -- the neighborhood summation of the products of the
  -- intensities of pixels with their respective filter element
  local sum
  local x, y -- coordinates for a pixel
  
  -- apply the filter along the x dimension
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      x = helpers.reflection( (col+i-2), 0, img.width )
      -- convolve the neighborhood with the filter
      sum = sum + img:at( row, x ).r * small_filter[i]
      
    end
    
    pix.r = helpers.in_range( sum )
  end
  
  -- apply the filter along the y dimension
  for row, col in cpy_img:pixels() do
    pix = img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      y = helpers.reflection( (row+i-2), 0, img.height )
      -- convolve the neighborhood with the filter
      sum = sum + cpy_img:at( y, col ).r * small_filter[i]
      
    end
    
    pix.r = helpers.in_range( sum )
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )
  
  return img
  
end

--[[    sharp_filter
  |
  |   Takes an image and applies a sharpening filter to it.
  |
  |     Author: Scott Carda
--]]
function funcs.sharp_filter( img )
  
  -- the sharpen filter
  local filter = {
    {0,-1,0},
    {-1,5,-1},
    {0,-1,0}
  }
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local cpy_img = img:clone() -- copy of image
  local pix -- a pixel
  
  -- the neighborhood summation of the products of the
  -- intensities of pixels with their respective filter element
  local sum
  local x, y -- coordinates for a pixel
  
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    
    sum = 0
    for i = 1, 3 do
      y = helpers.reflection( (row+i-2), 0, img.height )
      for j = 1, 3 do
        x = helpers.reflection( (col+j-2), 0, img.width )
        -- convolve the neighborhood with the filter
        sum = sum + img:at( y, x ).r * filter[i][j]
        
      end
    end
    
    pix.r = helpers.in_range( sum )
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( cpy_img )
  
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
  
return funcs
