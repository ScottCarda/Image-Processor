require("ip")
local il = require "il"
local helpers = require "helper_functs"

local funcs = {}

function funcs.grayscaleRGB( img )
  local val
  local pix
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      val = pix.r * 30
      val = val + pix.g * 59
      val = val + pix.b * 11
      val = math.floor( val / 100 )
      
      for chan = 0, 2 do
        pix.rgb[chan] = val
      end
    
  end
  return img
end

function funcs.threshold( img, threshold )
  local val
  local pix
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  for row, col in img:pixels() do
      
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
  
  return img
end

function funcs.brighten( img, val )
  local pix
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      for chan = 0, 2 do
        pix.rgb[chan] = helpers.in_range( pix.rgb[chan] + val )
      end
    
  end
  
  return img
end

function funcs.gamma( img, gamma )
  local c = 255
  local pix
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      for chan = 0, 2 do
        pix.rgb[chan] = helpers.in_range( c * ( pix.rgb[chan] / c ) ^ gamma )
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
  
  for row, col in img:pixels() do
      
      pix = img:at( row, col )
      
      color = math.floor( ( pix.y - min ) / divisor )
      
      for chan = 0, 2 do
        pix.rgb[chan] = color_table[color+1][chan+1]
      end
    
  end
  
  return img
end



function funcs.auto_stretch( img )
  
  -- convert image from RGB to YIQ
  il.RGB2YIQ( img )
  
  local hist = helpers.get_hist( img, 0 )
  
  local min = 0
  while hist[min] == 0 and min < 255 do
    min = min + 1
  end
  local max = 255
  while hist[max] == 0 and max > min do
    max = max - 1
  end
    
  local slope = 255 / ( max - min )
  
  local pix
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.y = helpers.in_range( slope * ( pix.y - min ) )
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )
  
  return img
end

function funcs.equalizeRGB( img )
  
  -- convert image from RGB to YIQ
  --[[il.RGB2YIQ( img )
  
  local hist = helpers.get_hist( img, 0 )
  local size = img.height * img.width
  
  local sum = 0
  for i = 0, 255 do
    sum = sum + hist[i] / size
    hist[i] = helpers.round( 255 * sum )
  end
  
  local pix
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.y = hist[pix.y]
  end
  
  -- convert image from YIQ to RGB
  il.YIQ2RGB( img )]]
  
  local size = img.height * img.width
  local sum
  local pix
  
  for chan = 0, 2 do
    local hist = helpers.get_hist( img, chan )
    
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

--{"Bitplane Slice", funcs.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
function funcs.slice( img )
  print( "Unimplemented" )
  return img
end

return funcs