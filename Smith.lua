require "ip"
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img, levels, model )
  --convert image based on model selected
  if model == "YIQ" or model == "yiq" then
    img = il.RGB2YIQ(img)
  elseif model == "YUV"or model == "YUV" then
    img = il.RGB2YUV(img)
  elseif model == "IHS"or model == "ihs" then
    img = il.RGB2IHS(img)
  end
  
  --posterize code
  local interval = 256/levels
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
    rlut[i] = helpers.in_range(  (i - 20) % 256)
    glut[i] = helpers.in_range(  (i + 47 )% 256)
    blut[i] = helpers.in_range( -math.abs(i-128))
  end
  return img:mapPixels(function( r, g, b )
    return rlut[r], glut[g], blut[b]
    end
  )
end
function funcs.stretchSpecify( img, lp, rp, method )
  local lut = {}
  if lp > rp then
    lp, rp = rp, lp
  end
  
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
  local max = helpers.get_percent_location( h, img.width * img.height, rp, 0 )
  return funcs.stretchSpecify(img, min, max, "percent")
end
function funcs.equalizeClip( img, perc )
  local size = img.height * img.width
  local sum
  local pix
  perc = 1/100
  local max_pixels = helpers.round( perc * size )
  
  for chan = 0, 2 do
    local largest_bins = {}
    local lb_size
    local cut_pixels
    local hist = helpers.get_hist( img, chan )
    hist, cut_pixels, largest_bins, lb_size = helpers.clip_hist( hist, max_pixels)
    hist = helpers.distribute_cut_pixels( hist, cut_pixels, largest_bins, lb_size)
    sum = 0
    for i = 0, 255 do
      sum = sum + hist[i] / size
      hist[i] = helpers.round( 255 * sum )
    end
    
    for row, col in img:pixels() do
      pix = img:at( row, col )
      pix.rgb[chan] = hist[ pix.rgb[chan] ]
    end
  end
  
  return img
end
--[[
function funcs.colorCube( img )
local pix = img:at( 0, 0 )
local lut = funcs.newAutotable(3)
  for r = 0, 255 do
    for g = 0, 255 do
      for b = 0, 255 do
        pix.r = b - r
        pix.g = g - 
        lut[r][g][b] = pix
  end
  return img:mapPixels(function( r, g, b )
    return rlut[r], glut[g], blut[b]
  end
  )
end

function funcs.newAutotable(dim)
    local MT = {};
    for i=1, dim do
        MT[i] = {__index = function(t, k)
                    if i < dim then
                      t[k] = setmetatable({}, MT[i+1])
                      return t[k];
                    end
                  end
                }
    end
    return setmetatable({}, MT[1]);
end
--]]


return funcs
