require "ip"
require "helper_functs"

local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img, levels )
  local interval = 256/4
  local quanta = math.floor(255/(levels-1))
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      for chan = 0, 2 do
        img:at(row, col ).rgb[chan] = math.floor(img:at( row, col ).rgb[chan]/interval) * quanta
      end
    end
  end
  return img
end

function funcs.stretch( img )
  stretchSpecify( img, 0, 255)
end
  
  return img
end

function funcs.logscale( img )
  print( "Unimplemented" )
  return img
end

function funcs.cont_pseudocolor( img )
  print( "Unimplemented" )
  return img
end

--{"Contrast Specify", funcs.stretchSpecify,
--  {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
--   {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
function funcs.stretchSpecify( img, lp, rp )
  rp = rp or 255
  lp = lp or 0
  local lut = {}
  
  img = RGB2YIQ(img)
  
  local min 
  local max
  min, max = get_minmax_intensities(img)
  
  local denom = max - min
  local numer = rp - lp
  local ramp = numer/denom
  --create look up table
  for i = 0, 255 do
    lut[i] = ( i - lp ) * ramp
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      img:at(row,col).y = lut[img:at(row,col).y]
    end
  end
  img = YIQ2RGB(img)
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
