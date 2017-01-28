require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img, levels, model )
  --convert image based on model selected
  if model == "YIQ" then
    img = il.RGB2YIQ(img)
  elseif model == "YUV" then
    img = il.RGB2YUV(img)
  elseif model == "IHS" then
    img = il.RGB2IHS(img)
  end
  
  --posterize code
  local interval = 256/4
  local quanta = math.floor(255/(levels-1))
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      for chan = 0, 2 do
        img:at(row, col ).rgb[chan] = helpers.in_range(math.floor(img:at( row, col ).rgb[chan]/interval) * quanta)
      end
    end
  end
  --convert image back to RGB
  if model == "YIQ" then
    img = il.YIQ2RGB(img)
  elseif model == "YUV" then
    img = il.YUV2RGB(img)
  elseif model == "IHS" then
    img = il.IHS2RGB(img)
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
  local rlut = {}
  local glut = {}
  local blut = {}
  
  for i = 0, 255 do
    rlut[i] = helpers.in_range(  math.pow(i-64, 2) + 255)
    glut[i] = helpers.in_range(  math.floor(math.sqrt(i) + .5 ))
    blut[i] = helpers.in_range( -math.abs(i-128) + 128)
  end
  return img:mapPixels(function( r, g, b )
    return rlut[r], glut[g], blut[b]
    end
  )
end

--{"Contrast Specify", funcs.stretchSpecify,
--  {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
--   {name = "rp", type = "number", displaytype = "spin", default = 255, min = 0, max = 100}}},
function funcs.stretchSpecify( img, lp, rp, method )
  local lut = {}
  
  if method ~= "percent" then
    img = il.RGB2YIQ(img)
  end
  
  local ramp = 255/(rp-lp)  
  --create look up table
  for i = 0, 255 do
    lut[i] = helpers.in_range( math.floor( ( i - lp ) * ramp ) )
  end
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      img:at(row, col ).r = lut[img:at(row, col).r]
    end
  end
  
  img = il.YIQ2RGB(img)
  
  return img
  
end

function funcs.stretchPercent( img, lp, rp)
  img = il.RGB2YIQ(img)
  local h = helpers.get_hist(img, 0)
  local min = helpers.get_percent_location(h, img.width * img.height, lp, 0)
  local max = helpers.get_percent_location( h, img.width * img.height, rp, 255 )
  return funcs.stretchSpecify(img, min, max, "percent")
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
