require "ip"
require "visual"
local il = require "il"

local funcs = {}

function funcs.grayscaleRGB( img )
  print( "Unimplemented" )
  return img
end

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

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img )
  print( "Unimplemented" )
  return img
end

function funcs.brighten( img )
  print( "Unimplemented" )
  return img
end

--{"Gamma", funcs.gamma, {{name = "gamma", type = "string", default = "1.0"}}},
function funcs.gamma( img )
  print( "Unimplemented" )
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

function funcs.disc_pseudocolor( img )
  print( "Unimplemented" )
  return img
end

--{"Bitplane Slice", funcs.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
function funcs.slice( img )
  print( "Unimplemented" )
  return img
end

function funcs.stretch( img )
  print( "Unimplemented" )
  return img
end
    
--{"Contrast Specify", funcs.stretchSpecify,
--  {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
--   {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
function funcs.stretchSpecify( img )
  print( "Unimplemented" )
  return img
end
    
function funcs.equalizeRGB( img )
  print( "Unimplemented" )
  return img
end
    
--{"Histogram Equalize Clip", funcs.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}}
function funcs.equalizeClip( img )
  print( "Unimplemented" )
  return img
end

function funcs.threshold( img )
  print( "Unimplemented" )
  return img
end

return funcs