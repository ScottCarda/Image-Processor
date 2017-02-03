require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--[[    grayscaleRGB
  |
  |   Takes a color image and calculates, for each pixel, the gray value.
  |   Assigns each channel of the pixel to the calculated gray value,
  |   turning the image into a grayscale image while preserving the data
  |   structure of the image.
--]]
function funcs.grayscaleRGB( img )
  local gray -- the calculated gray value of a pixel
  local pix -- a pixel
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      gray = pix.r * 30        -- 30% red channel
      gray = val + pix.g * 59  -- 59% green channel
      gray = val + pix.b * 11  -- 11% blue channel
      gray = math.floor( gray / 100 )
      
      -- set channels to the calculated gray value
      for chan = 0, 2 do
        pix.rgb[chan] = val
      end
    
  end
  
  return img
end

--[[    threshold
  |
  |   Takes a color image and a threshold value. Performs a binary threshold
  |   on the image by setting all pixels whose intensity value is less than
  |   or equal to the threshold value to black and all other pixels to white.
--]]
function funcs.threshold( img, threshold )
  local val -- the calculated value of a pixel
  local pix -- a pixel
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      if pix.y <= threshold then
        val = 0
      else
        val = 255
      end
      
      -- set channels to the calculated gray value
      for chan = 0, 2 do
        pix.rgb[chan] = val
      end
    
  end
  
  return img
end

--[[    brighten
  |
  |   Takes a color image and a brightening value. This will brighten
  |   or darken the image by the brightening value. It will darken
  |   the image if the brightening value is negative.
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

--[[    gamma
  |
  |   Takes a color image and a gamma value. Raises each pixel to power
  |   of the gamma value.
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

--[[    disc_pseudocolor
  |
  |   Takes a color image and assigns a color to each pixel
  |   based on the pixel's original intensity value.
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
      color = math.floor( ( pix.y - min ) / divisor )
      
      -- sets the color for the pixel based on its color category
      for chan = 0, 2 do
        pix.rgb[chan] = color_table[color+1][chan+1]
      end
    
  end
  
  return img
end

--[[    auto_stretch
  |
  |   Takes a color image and performs a contrast stretch on the image.
  |   The minimum and maximum values are determined automatically.
--]]
function funcs.auto_stretch( img )
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  -- get the histogram of the intensity values
  local hist = helpers.get_hist( img, 0 )
  
  -- finds the first non-zero entry in the histogram
  local min = 0
  while hist[min] == 0 and min < 255 do
    min = min + 1
  end
  -- finds the last non-zero entry in the histogram
  local max = 255
  while hist[max] == 0 and max > min do
    max = max - 1
  end
  
  -- the slope of the linear transformation function
  local slope = 255 / ( max - min )
  
  local pix -- a pixel
  -- applies the linear transformation to each pixel's intensity
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.y = helpers.in_range( slope * ( pix.y - min ) )
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )
  
  return img
end

--[[    equalizeRGB
  |
  |   Takes a color image and performs a histogram equalization on each of the
  |   color channels separately.
--]]
function funcs.equalizeRGB( img )
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )]]
  
  local size = img.height * img.width -- number of pixels in the image
  local sum -- number of pixels at or less than a given intensity
  local pix -- a pixel
  
  -- perform histogram equalization for each color channel separately
  for chan = 0, 2 do
    -- get the color channel's histogram
    local hist = helpers.get_hist( img, chan )
    -- look up table for what each color intensity value with map to
    local LUT = {}
    
    sum = 0
    -- calculate the look up table value for each intensity
    for i = 0, 255 do
      sum = sum + hist[i] -- calculate sum for intensity i
      LUT[i] = helpers.round( 255 * sum / size )
    end
    
    -- transform the appropriate channel of each pixel in the image
    for row, col in img:pixels() do
      pix = img:at( row, col )
      pix.rgb[chan] = LUT[ pix.rgb[chan] ]
    end
  end
  
  return img
end

--[[    slice
  |
  |   Takes a color image and a bit plane indicator. Performs a bit
  |   plane slicing of each color channel separately.
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

return funcs