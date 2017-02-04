require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
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

  for i = 0, 255 do
    lut[i] =  helpers.in_range(helpers.round((i/interval) * quanta) )
  end
  img = helpers.use_lut( img, lut, n_chans)
  return helpers.convert_2rgb(img, model)
end

function funcs.logscale( img, model )
  img = helpers.convert_img( img, model)
  local n_chans = 0
  local lut = {}
  
  for i = 0, 255 do
    lut[i] = helpers.in_range(255 * math.log(1+i,256))
  end
  
  if model == "rgb" or model == "RGB" then
    n_chans = 2
  end
  img = helpers.use_lut( img, lut, n_chans)
  
  return helpers.convert_2rgb(img, model)
end

function funcs.cont_pseudocolor( img )
  local rlut = {}
  local glut = {}
  local blut = {}
  
  for i = 0, 255 do
    rlut[i] = helpers.in_range(  (i - 20) % 256)
    glut[i] = helpers.in_range(  (i + 47 )% 256)
    blut[i] = helpers.in_range( -math.abs(i-128))
  end
  return img:mapPixels(function( r, g, b )
    return rlut[r], glut[g], blut[b]
    end
  )
end
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
  
  img = helpers.use_lut( img, lut, 0)
  return helpers.convert_2rgb(img, model)
end

function funcs.stretchPercent( img, lp, rp, model)
  img = helpers.convert_img( img, model)
  local h = helpers.get_hist(img, 0)
  local min = helpers.get_percent_location(h, img.width * img.height, lp, 0)
  local max = helpers.get_percent_location( h, img.width * img.height, rp, 0 )
  return funcs.stretchSpecify(img, min, max, model, "percent")
end
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
    hist, cut_pixels, largest_bins, lb_size = helpers.clip_hist( hist, max_pixels)
    hist = helpers.distribute_cut_pixels( hist, cut_pixels, largest_bins, lb_size)
    local sum = 0
    for i = 0, 255 do
      sum = sum + hist[i] / size
      hist[i] = helpers.round( 255 * sum )
    end
    
    for row, col in img:pixels() do
      local pix = img:at( row, col )
      pix.rgb[chan] = hist[ pix.rgb[chan] ]
    end
  end
  return helpers.convert_2rgb(img, model)
end
return funcs
