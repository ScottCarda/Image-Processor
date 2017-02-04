require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--[[    posterize
  |   Takes the image and converts it to the specific color model and performs a
  |   Posterization ( a quantization technique that reduces 256 gray levels to a much 
      smaller number) The number of levels are specified by the user.
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
  local quanta = helpers.round(255/(levels-1))
  --compute look up table
  for i = 0, 255 do
    lut[i] =  helpers.in_range(helpers.round((i/interval) * quanta) )
  end
  --apply look up table to image
  img = helpers.use_lut( img, lut, n_chans)
  --conver image back to rgb
  return helpers.convert_2rgb(img, model)
end
--[[    logscale

  |   This function performs a logs scaling to each pixel value by compressing the dynamic range
      of the values and replacing the original value of the pixel with the log scaled variant.
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
      applies this mapping to the pixels to create a continuous psudocolor mapping 
      from the original image.
--]]
function funcs.cont_pseudocolor( img )
  local rlut = {}
  local glut = {}
  local blut = {}
  --create mappings for rgb channels
  for i = 0, 255 do
    rlut[i] = helpers.in_range(  (i - 20) % 256)
    glut[i] = helpers.in_range(  (i + 47 )% 256)
    blut[i] = helpers.in_range( -math.abs(i-128))
  end
  --apply mappings of rgb channels
  return img:mapPixels(function( r, g, b )
    return rlut[r], glut[g], blut[b]
    end
  )
end
--[[    stretchSpecify
  |
  |   Takes a color image and performs a contrast stretch on the image.
  |   The minimum and maximum values are set by the user or percent method.
--]]
function funcs.stretchSpecify( img, lp, rp, model, method )
  local lut = {}
  if lp > rp then
    lp, rp = rp, lp
  end
  
  if method ~= nil then
    img = helpers.convert_img( img, model)
  end
  
  local ramp = 255/(rp-lp)  
  --create look up table
  for i = 0, 255 do
    lut[i] = helpers.in_range( math.floor( ( i - lp ) * ramp ) )
  end
  --apply look up table
  img = helpers.use_lut( img, lut, 0)
  return helpers.convert_2rgb(img, model)
end

--[[    stretchPercent
  |
  |   Computes the histogram of the image then finds the min and max locations
      based on the percent the user selects for the percent number of pixels to ignore
      from the tail ends of the histogram. These min max values are then used to specify 
      the stretchSpecify function min max as the end points for the contrast stretch
--]]
function funcs.stretchPercent( img, lp, rp, model)
  img = helpers.convert_img( img, model)
  local h = helpers.get_hist(img, 0)
  --find endpoints
  local min = helpers.get_percent_location(h, img.width * img.height, lp, 0)
  local max = helpers.get_percent_location( h, img.width * img.height, rp, 0 )
  return funcs.stretchSpecify(img, min, max, model, "percent")
end
--[[    equalizeClip

      Takes a color image and performs a histogram on the channels associated with the
      color model chosen. A clipping percent is applied to the initial histogram and the 
      clipped pixels are redistributed equally across all bins in the histogram. Once the 
      clipped pixels are distributed the equalization continues and calculatees the cdf 
      and uses that as the transformation function for the corresponding channel for all 
      pixels in the image.
--]]
function funcs.equalizeClip( img, perc, model)
  local size = img.height * img.width
  local largest_bins = {}
  local lb_size = 0
  local cut_pixels = 0
  local hist = {}
  local max_pixels = helpers.round( (perc/100) * size )
  local n_chans = 0
  
  img = helpers.convert_img( img, model)
  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end
  
  for chan = 0, n_chans do
    hist = helpers.get_hist( img, chan )
    --clip histogram returning the bins clipped and number of clipped pixels
    hist, cut_pixels, largest_bins, lb_size = helpers.clip_hist( hist, max_pixels)
    --redistribute clipped pixels over histogram with leftover pixels placed in the largest bins
    hist = helpers.distribute_cut_pixels( hist, cut_pixels, largest_bins, lb_size)
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
