--[[
  |                             PointProcesses.lua                             |
  |                                                                            |
  |   This file contains the functions that perform point processes on an      |
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

local funcs = {}

--[[    grayscaleRGB
  |
  |   Takes a color image and calculates, for each pixel, the gray value.
  |   Assigns each channel of the pixel to the calculated gray value,
  |   turning the image into a grayscale image while preserving the data
  |   structure of the image.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.grayscaleRGB( img )
  local gray -- the calculated gray value of a pixel
  local pix -- a pixel

  for row, col in img:pixels() do

    pix = img:at( row, col )

    gray = pix.r * 30        -- 30% red channel
    gray = gray + pix.g * 59  -- 59% green channel
    gray = gray + pix.b * 11  -- 11% blue channel
    gray = math.floor( gray / 100 )

    -- set channels to the calculated gray value
    for chan = 0, 2 do
      pix.rgb[chan] = gray
    end

  end

  return img
end

--[[    negate
  |
  |   Takes the image and negates each color channel separately by subtracting
  |   each pixel's intensity in that channel from the maximum possible intensity.
  |
  |   Author:
  |     Dr. Weiss
--]]
function funcs.negate( img )
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      for chan = 0, 2 do
        img:at( row, col ).rgb[chan] = 255 - img:at( row, col ).rgb[chan]
      end
    end
  end
  return img
end

--[[    posterize
  |
  |   Takes the image and converts it to the specific color model and performs a
  |   Posterization ( a quantization technique that reduces 256 gray levels to a much 
  |   smaller number) The number of levels are specified by the user.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.posterize( img, levels, model )
  --convert image based on model selected
  img = helpers.convert_img( img, model)
  local n_chans = 0
  local lut = {}
  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end
  --posterize code
  local interval = 256/levels
  local quanta = math.floor(255/(levels-1))
  --compute look up table
  for i = 0, 255 do
    lut[i] =  helpers.in_range(math.floor((i/interval)) * quanta) 
  end
  --apply look up table to image
  img = helpers.use_lut( img, lut, n_chans)
  --conver image back to rgb
  return helpers.convert_2rgb(img, model)
end

--[[    brighten
  |
  |   Takes a color image and a brightening value. This will brighten
  |   or darken the image by the brightening value. It will darken
  |   the image if the brightening value is negative.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.brighten( img, val )
  local pix -- a pixel

  for row, col in img:pixels() do

    pix = img:at( row, col )

    -- add the brightening value to each channel
    for chan = 0, 2 do
      pix.rgb[chan] = helpers.in_range( pix.rgb[chan] + val )
    end

  end

  return img
end

--[[    stretchSpecify
  |
  |   Takes a color image and performs a contrast stretch on the image.
  |   The minimum and maximum values are set by the user or percent method.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.stretchSpecify( img, lp, rp, model, method )
  local lut = {}
  if lp > rp then
    lp, rp = rp, lp
  end
  local n_chans = 0
  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end
  if method ~= "percent" then
    img = helpers.convert_img( img, model)
  end

  local ramp = 255/(rp-lp)  
  --create look up table
  for i = 0, 255 do
    lut[i] = helpers.in_range( helpers.round( ( i - lp ) * ramp ) )
  end
  --apply look up table
  img = helpers.use_lut( img, lut, n_chans)
  return helpers.convert_2rgb(img, model)
end

--[[    gamma
  |
  |   Takes a color image and a gamma value. Raises each pixel to power
  |   of the gamma value.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.gamma( img, gamma )
  local c = 255 -- scaling factor
  local pix -- a pixel

  for row, col in img:pixels() do

    pix = img:at( row, col )

    -- Applies gamma to each color channel separately
    for chan = 0, 2 do
      pix.rgb[chan] = helpers.in_range( c * ( pix.rgb[chan] / c ) ^ gamma )
    end

  end

  return img
end

--[[    logscale
  |
  |   This function performs a logs scaling to each pixel value by compressing the dynamic range
  |   of the values and replacing the original value of the pixel with the log scaled variant.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.logscale( img, model )
  img = helpers.convert_img( img, model)
  local n_chans = 0
  local lut = {}
  --create look up table using log scaling
  for i = 0, 255 do
    lut[i] = helpers.in_range(255 * math.log(1+i,256))
  end

  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end
  --apply look up table to image
  img = helpers.use_lut( img, lut, n_chans)

  return helpers.convert_2rgb(img, model)
end

--[[    cont_psuedocolor
  |
  |   This function computes a mapping for each color channel of the image and then 
  |   applies this mapping to the pixels to create a continuous psudocolor mapping 
  |   from the original image.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.cont_pseudocolor( img )
  local rlut = {}
  local glut = {}
  local blut = {}
  --create mappings for rgb channels
  for i = 0, 255 do
    rlut[i] = i
    glut[i] = 255 - i
    blut[i] = (-math.abs(i-64)-257) % 256
  end
  --apply mappings of rgb channels
  return img:mapPixels(function( r, g, b )
      return rlut[r], glut[g], blut[b]
    end
  )
end

--[[    disc_pseudocolor
  |
  |   Takes a color image and assigns a color to each pixel
  |   based on the pixel's original intensity value.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.disc_pseudocolor( img )
  local pix -- a pixel
  local min = 0 -- minimum intensity
  local max = 256 -- maximum intensity
  local num_colors = 8

  local divisor = ( max - min ) / num_colors

  -- look up table for colors
  local color_table =
  {
    {000,000,000},
    {128,000,128},
    {000,000,255},
    {000,255,000},
    {255,255,000},
    {255,128,000},
    {255,000,000},
    {255,255,255}
  }

  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )

  for row, col in img:pixels() do

    pix = img:at( row, col )

    -- calculates which color category for the pixel
    local color = math.floor( ( pix.y - min ) / divisor )

    -- sets the color for the pixel based on its color category
    for chan = 0, 2 do
      pix.rgb[chan] = color_table[color+1][chan+1]
    end

  end

  return img
end

--[[    slice
  |
  |   Takes a color image and a bit plane indicator. Performs a bit
  |   plane slicing of each color channel separately.
  |
  |   Author:
  |     Scott Carda
--]]
function funcs.slice( img, plane )
  local pix -- a pixel
  local bit -- the value of the selected bit

  for row, col in img:pixels() do
    pix = img:at( row, col )

    -- process each channel separately
    for chan = 0, 2 do
      -- get the bit of the selected plane
      bit = ( pix.rgb[chan] % 2^(plane+1) - pix.rgb[chan] % 2^plane ) / 2^plane
      -- if the bit is 0, set value to 0, if the bit is 1, set value to 255
      pix.rgb[chan] = helpers.in_range( 255 * math.floor( bit ) )
    end

  end

  return img
end
--[[    sepia
  |
  |   Takes a color image and converts it to shades of brown.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.sepia(img)
  return img:mapPixels(function( r, g, b )
      return helpers.in_range((r * .393) + (g *.769) + (b * .189)),
      helpers.in_range((r * .349) + (g *.686) + (b * .168)), 
      helpers.in_range((r * .272) + (g *.534) + (b * .131))
    end
  )
end
--[[    solarize
  |
  |   Takes a color image and thresholds the individual rgb channels to create
  |   a solarization effect that the user can choose. Similar to negation instead 
  |   a threshold is used and the pixel is negated if below or above the threshold 
  |   based on user choice.
  |
  |   Author:
  |     Christopher Smith
--]]
function funcs.solarize(img, rthresh, gthresh, bthresh)
  local pix

  --If user wanted to negate if less than the threshold
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.r = helpers.choose( pix.r < rthresh, 255-pix.r, pix.r) 
    pix.g = helpers.choose( pix.g < gthresh, 255-pix.g, pix.g)
    pix.b = helpers.choose( pix.b < bthresh, 255-pix.b, pix.b)
  end
  return img
end

return funcs