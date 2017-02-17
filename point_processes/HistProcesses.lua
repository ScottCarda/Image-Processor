--[[
  |                             HistProcesses.lua                              |
  |                                                                            |
  |   This file contains the functions that perform histogram processes on an  |
  |image.                                                                      |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

require( "ip" )
local il = require( "il" )

local helpers = require( "HelperFuncs" )
local point = require( "PointProcesses" )

local funcs = {}

--[[    auto_stretch
  |
  |   Takes a color image and performs a contrast stretch on the image.
  |   The minimum and maximum values are determined automatically.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.auto_stretch( img )

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )

  local min -- the minimum intensity in the image
  local max -- the maximum intensity in the image
  -- finds min and max
  min, max = helpers.get_minmax_intensities( img, 0 )

  -- the slope of the linear transformation function
  local slope = 255 / ( max - min )

  local pix -- a pixel
  -- applies the linear transformation to each pixel's intensity
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.y = helpers.in_range( helpers.round( slope * ( pix.y - min ) ) )
  end

  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )

  return img
end

--[[    stretchPercent
  |
  |   Computes the histogram of the image then finds the min and max locations
  |   based on the percent the user selects for the percent number of pixels to ignore
  |   from the tail ends of the histogram. These min max values are then used to specify 
  |   the stretchSpecify function min max as the end points for the contrast stretch.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.stretchPercent( img, lp, rp, model)
  img = helpers.convert_img( img, model)
  local h = helpers.get_hist(img, 0)
  --find endpoints
  local min = helpers.get_percent_location(h, img.width * img.height, lp, 0)
  local max = helpers.get_percent_location( h, img.width * img.height, rp, 0 )
  return point.stretchSpecify(img, min, max, model, "percent")
end

--[[    equalizeRGB
  |
  |   Takes a color image and performs a histogram equalization on the intensity
  |   channel.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.equalizeRGB( img )

  local size = img.height * img.width -- number of pixels in the image
  local sum -- number of pixels at or less than a given intensity
  local pix -- a pixel

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  -- perform histogram equalization for the intensity channel
  -- get the intensity histogram
  local hist = helpers.get_hist( img, 0 )
  -- look up table for what each color intensity value with map to
  local LUT = {}

  sum = 0
  -- calculate the look up table value for each intensity
  for i = 0, 255 do
    sum = sum + hist[i] -- calculate sum for intensity i
    LUT[i] = helpers.round( 255 * sum / size )
  end

  -- transform the intensity of each pixel in the image
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.y = LUT[ pix.y ]
  end

  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )
  
  return img
end

--[[    equalizeClip
  |
  |   Takes a color image and performs a histogram on the channels associated with the
  |   color model chosen. A clipping percent is applied to the initial histogram and the 
  |   clipped pixels are redistributed equally across all bins in the histogram. Once the 
  |   clipped pixels are distributed the equalization continues and calculatees the cdf 
  |   and uses that as the transformation function for the corresponding channel for all 
  |   pixels in the image.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.equalizeClip( img, perc, model)
  local size = img.height * img.width
  local hist = {}
  local max_pixels = helpers.round( (perc/100) * size )
  local n_chans = 0
  local cut
  img = helpers.convert_img( img, model)
  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end

  for chan = 0, n_chans do
    hist = helpers.get_hist( img, chan )
    --clip histogram returning the bins clipped and number of clipped pixels
    hist, cut = helpers.clip_hist( hist, max_pixels)
    size = size - cut
    --perform histogram equalization computing cdf and applying "transform function"
    local sum = 0
    --cdf
    for i = 0, 255 do
      sum = sum + hist[i] / size
      hist[i] = helpers.round( 255 * sum )
    end
    --apply transform
    for row, col in img:pixels() do
      local pix = img:at( row, col )
      pix.rgb[chan] = hist[ pix.rgb[chan] ]
    end
  end
  return helpers.convert_2rgb(img, model)
end

return funcs
