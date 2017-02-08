--[[
  |                             MiscProcesses.lua                              |
  |                                                                            |
  |   This file contains the functions that perform miscellaneous processes on |
  |an image.                                                                   |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda                                                      |
  |                                                                            |
--]]

require( "ip" )
local il = require( "il" )

local funcs = {}

--[[    threshold
  |
  |   Takes a color image and a threshold value. Performs a binary threshold
  |   on the image by setting all pixels whose intensity value is less than
  |   or equal to the threshold value to black and all other pixels to white.
  |
  |   Author:
  |     Scott Carda
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

return funcs