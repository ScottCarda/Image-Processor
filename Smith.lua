require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img, levels, model )
  --convert image based on model selected
  if model == "YIQ" then
    img = img.RGB2YIQ()
  elseif model == "YUV" then
    img = img.RGB2YUV()
  elseif model == "IHS" then
    img = img.RGB2IHS()
  end
  
  --posterize code
  local interval = 256/4
  local quanta = math.floor(255/(levels-1))
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      for chan = 0, 2 do
        img:at(row, col ).rgb[chan] = math.floor(img:at( row, col ).rgb[chan]/interval) * quanta
      end
    end
  end
  --convert image back to RGB
  if model == "YIQ" then
    img = img.YIQ2RGB()
  elseif model == "YUV" then
    img = img.YUV2RGB()
  elseif model == "IHS" then
    img = img.IHS2RGB()
  end
  
  return img
end
--linear ramp contrast
function funcs.lin_contrast( img, lp, rp)
    
end

function funcs.logscale( img )
  local lut = {}
  for i = 0, 255 do
    lut[i] = helpers.in_range(255 * math.log(1+i,256))
  end
  return img:mapPixels(function( r, g, b )
    return lut[r], lut[g], lut[b]
    end
  )
end

function funcs.cont_pseudocolor( img )
  print( "Unimplemented" )
  return img
end

--{"Contrast Specify", funcs.stretchSpecify,
--  {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
--   {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
function funcs.stretchSpecify( img, lp, rp )
  rp = rp or 100
  lp = lp or 0
  local lut = {}
  
  --img = il.RGB2YIQ(img)
  
  local min 
  local max
  min, max = helpers.get_minmax_intensities(img)
  
  local ramp = (rp-lp)/(max - min)
  --create look up table
  for i = 0, 255 do
    lut[i] = helpers.in_range( math.floor( ( i - lp ) * ramp ) )
  end
    
  --process pixels using lut
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      for chan = 0, 2 do
        img:at(row,col).rgb[chan] = lut[img:at(row,col).rgb[chan]]
      end
    end
  end
  
  --img = il.YIQ2RGB(img)
  return img
end

--{"Histogram Equalize Clip", funcs.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}}
function funcs.equalizeClip( img )
  print( "Unimplemented" )
  return img
end

function funcs.other( img )
  print( "Unimplemented" )
  return img
end

return funcs
