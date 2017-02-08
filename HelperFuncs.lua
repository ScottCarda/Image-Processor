--[[
  |                              HelperFuncs.lua                               |
  |                                                                            |
  |   This file contains various miscellaneous functions that are used commonly|
  |in the image processing functions.                                          |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

require( "ip" )
local il = require( "il" )

local helpers = {}

--[[    get_minmax_intensities
  |
  |   Takes an image and a channel specifier. Loops through the
  |   image finding the minimum and maximum intensities for
  |   that channel of the image. Returns the minimum and maximum found.
  |
  |     Authors: Christopher Smith, Scott Carda
--]]
function helpers.get_minmax_intensities( img, chan )
  local min = 256 -- the minimum intensity found
  local max = -1 -- the maximum intensity found
  local pix -- a pixel

  -- loop through the image, setting min and max
  for row, col in img:pixels() do

    pix = img:at( row, col )

    if min > pix.rgb[chan] then
      min = pix.rgb[chan]
    end
    if max < pix.rgb[chan] then
      max = pix.rgb[chan]
    end

  end

  return min, max
end

--[[    in_range
  |
  |   Takes a value and return the value if it is in the range 0 to 255.
  |   If it is not in the range, it returns the range's endpoint that is
  |   the closest.
  |
  |     Author: Scott Carda
--]]
function helpers.in_range( val )  

  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end

end

--[[    get_hist
  |
  |   Takes an image and a channel specifier. Creates and returns a
  |   table representation of the histogram for that channel of the image.
  |
  |     Authors: Scott Carda
--]]
function helpers.get_hist( img, chan )
  local pix
  local hist = {}

  -- initialize the histogram
  for i = 0, 255 do
    hist[i] = 0
  end

  for row, col in img:pixels() do

    pix = img:at( row, col )

    hist[pix.rgb[chan]] = hist[pix.rgb[chan]] + 1

  end

  return hist
end

--[[    round
  |     
  |   Takes a value and return the value rounded to the nearest integer.
  |
  |   Authors: Scott Carda
--]]
function helpers.round( val )
  return math.floor( val + 0.5 )
end
--[[    get_percent_location
  ]     
  |   Takes in the histogram and total number of pixels in the image. It then 
  |   finds bin the is either greater than or equal to the percentage of pixels 
  |   the user is looking for. The value of start dictates starting from the bin 
  |   0 or bin 255 to find the location from the end that sums up to or greater 
  |   than the percentage of pixels looking for.
  |
  |   Authors: Christopher Smith
--]]
--
function helpers.get_percent_location( hist, num_pixels, percent, start )
  local count = 0
  local dir = 1
  local last = 255
  local found = start
  if start == 255 then
    dir = -1
    last = 0
  end
  for i = start, last, dir do
    if (count / num_pixels) * 100 > percent then
      return i
    end
    count = count + hist[i]
    found = i
  end
  return found
end
--[[    clip_hist
  |
  |   Takes in a histogram and the maximum number of pixels per bin sets any bin 
  |   in the histogram greater than that number to that number. the cut pixels 
  |   are are kept track of and the bins cut from so the pixels can later be 
  |   redistributed throughout the histogram with an emphasis of placing extra 
  |   pixels in the largest bins cut from
  |
  |     Authors: Christopher Smith
--]]
function helpers.clip_hist( hist, max_pixels)
  local cut_pixels = 0
  --local largest_bins = {}
  --local k = 0
  for i = 0, 255 do
    if hist[i] > max_pixels then
      cut_pixels = cut_pixels + ( hist[i] - max_pixels)
      hist[i] = max_pixels
      --largest_bins[k] = i
      --k = k + 1
    end
  end
  return hist, cut_pixels
  --redistribute clipped pixels over histogram with leftover pixels placed in the largest bins
  --return helpers.distribute_cut_pixels(hist, cut_pixels, largest_bins, k)
end
--[[    distribute_cut_pixels
  |
  |   Takes in a histogram and the cut pixels and largest bins cut from. It
  |   redistributs the cut pixels throughout the histogram with an emphasis 
  |   of placing extra pixels in the largest bins cut from
  |
  |     Authors: Christopher Smith
--]]
function helpers.distribute_cut_pixels( hist, cut_pixels, largest_bins, size)
  local mod = cut_pixels % 256
  local num = math.floor(cut_pixels / 256)
  for i = 0, 255 do
    hist[i] = hist[i] + num
  end
  if mod ~= 0 then
    local k = 0
    for _ = 0, mod do
      hist[ largest_bins[k] ] = hist[ largest_bins[k] ] + 1
      k = (k + 1) % size
    end
  end
  return hist
end
--[[    convert_img
  |
  |   Returns a converted img based on the color model a user selects
  |
  |   Authors: Christopher Smith  
--]]
function helpers.convert_img( img, model)
  --convert image based on model selected
  if model == "YIQ" or model == "yiq" then
    return il.RGB2YIQ(img)
  elseif model == "YUV"or model == "YUV" then
    return il.RGB2YUV(img)
  elseif model == "IHS"or model == "ihs" then
    return il.RGB2IHS(img)
  end
  return img
end
--[[    convert_2rgb
  |  
  |   Returns an img in RGB based on the color model a user selects
  |
  |   Authors: Christopher Smith
--]]
function helpers.convert_2rgb(img, model)
  --convert image back to RGB
  if model == "YIQ" or model == "yiq" then
    return il.YIQ2RGB(img)
  elseif model == "YUV"or model == "YUV" then
    return il.YUV2RGB(img)
  elseif model == "IHS"or model == "ihs" then
    return il.IHS2RGB(img)
  end
  return img
end
--[[    use_lut
  |     
  |   Applies the look up table created for a specific image process to the image pixels
  |   n_chans is 2 or 0 meaning the user or process is modifying rgb or intensity values
  |
  |   Authors: Christopher Smith
--]]
function helpers.use_lut( img, lut, n_chans)
  for row, col in img:pixels() do
    local pix = img:at( row, col )
    for chan = 0, n_chans do
      pix.rgb[chan] = lut[ pix.rgb[chan] ]
    end
  end
  return img
end
--[[    choose
  |
  |   Simple helper function to clean up if then else statements
  |
  |   Authors: Christopher Smith
--]]
function helpers.choose(cond,a,b)
  if cond then return a else return b end
end


return helpers