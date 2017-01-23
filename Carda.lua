require("ip")
local il = require "il"

local funcs = {}

local function in_range( val )
  
  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end
  
end

function funcs.grayscaleRGB( img )
  local val
  local pix
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      
      pix = img:at( row, col )
      
      val = pix.r * 30
      val = val + pix.g * 59
      val = val + pix.b * 11
      val = math.floor( val / 100 )
      
      for chan = 0, 2 do
        pix.rgb[chan] = val
      end
      
    end
  end
  return img
end

function funcs.threshold( img, threshold )
  local val
  local pix
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      
      pix = img:at( row, col )
      
      if pix.y <= threshold then
        val = 0
      else
        val = 255
      end
      
      for chan = 0, 2 do
        pix.rgb[chan] = val
      end
      
    end
  end
  
  return img
end

function funcs.brighten( img, val )
  local pix
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      
      pix = img:at( row, col )
      
      for chan = 0, 2 do
        pix.rgb[chan] = in_range( pix.rgb[chan] + val )
      end
      
    end
  end
  
  return img
end

function funcs.gamma( img, gamma )
  local c = 255
  local pix
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      
      pix = img:at( row, col )
      
      for chan = 0, 2 do
        pix.rgb[chan] = in_range( c * ( pix.rgb[chan] / c ) ^ gamma )
      end
      
    end
  end
  
  return img
end

function funcs.disc_pseudocolor( img )
  local pix
  local min = 0
  local max = 256
  local num_colors = 8
  
  local divisor = ( max - min ) / num_colors
  
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
  
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do
      
      pix = img:at( row, col )
      
      color = math.floor( ( pix.y - min ) / divisor )
      
      for chan = 0, 2 do
        pix.rgb[chan] = color_table[color+1][chan+1]
      end
      
    end
  end
  
  return img
end

function funcs.stretch( img )
  print( "Unimplemented" )
  return img
end

function funcs.equalizeRGB( img )
  print( "Unimplemented" )
  return img
end

--{"Bitplane Slice", funcs.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
function funcs.slice( img )
  print( "Unimplemented" )
  return img
end

return funcs