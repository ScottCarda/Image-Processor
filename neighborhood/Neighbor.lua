--[[
  |                           Neighbor.lua                                     |
  |                                                                            |
  |                                                                            |
  |   This file contains the definitions neighborhood processes that use       |
  |   filter convlolution.                                                     |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

local il = require ( "il" )
local helpers = require ( "Helper_Funcs" )

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

--[[    oor_noise_cleaning_filter
  |
  |   Takes an image and a threshold value to determine if the the center pixel
  |   in a 3x3 neighborhood is correlated to the surrounding pixels. If the sum
  |   of its neighbors multiplied by 1/8 is greater than the threshold, the
  |   pixel is deteremend to not be correlated and set to average of its neighbors
  |
  |     Author: Chris Smith
--]]
function funcs.oor_noise_cleaning_filter( img, thresh)
  il.RGB2YIQ( img )
  local cpy_img = img:clone()
  local pix
  local sum
  local size = 3
  local hist
  local abs = math.abs
  for row, col in img:pixels() do
    pix = cpy_img:at(row, col )
    hist = helpers.sliding_histogram(img, row, col, size)
    sum = 0
    --calculate sume of the neighboring pixels
    for i = 0, 255 do
      sum = sum + i * hist[i]
    end
    --set sum equal to 1/8 * sum. Removing the center pixel from sum
    sum = 1/8*(sum - pix.r)
    --If pixel minus sum is greater then user threshold set pixel equal to sum
    if abs( pix.r - sum ) >= thresh then
      pix.r = sum
    end
  end
  il.YIQ2RGB( cpy_img )
  return cpy_img
end

--[[    emboss
  |
  |  Takes an image and applies an embossing filter where 1 is the pixel above 
  |  and to left of the current pixel and the -1 is down and to the right of 
  |  the center pixel. Those two pixels are then added together after being multiplied
  |  by 1 and -1 and the center pixel is set to the result.
  |
  |   Emboss Filter: 1  0  0
  |                  0  0  0
  |                  0  0 -1
  |
  |     Author: Chris Smith
--]]
function funcs.emboss( img)
  il.RGB2YIQ( img )

  local cpy_img = img:clone()
  local pix, neg_pix, pos_pix
  local x, y
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    pos_pix = img:at(  helpers.reflection( row-1,0,img.height) , helpers.reflection(col - 1,0,img.width))
    neg_pix = img:at( helpers.reflection( row+1,0,img.height) , helpers.reflection(col + 1,0,img.width))
    pix.r = helpers.in_range(128 + pos_pix.r - neg_pix.r)
  end
  il.YIQ2RGB(cpy_img)
  return cpy_img
end
  
return funcs
