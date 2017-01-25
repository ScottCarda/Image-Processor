--[[

  * * * * example1.lua * * * *

Lua image processing program:
Adds image negation and smoothing to viewer functionality.

Author: John Weiss, Ph.D.
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

-- LuaIP image processing routines
require "ip"
local viz = require "visual"
local il = require "il"

-----------------
-- IP routines --
-----------------

-- negate/invert image
local function my_negate( img )
  local nrows, ncols = img.height, img.width

  -- for each pixel in the image
  for r = 0, nrows-1 do
    for c = 0, ncols-1 do
      -- negate each RGB channel
      for ch = 0, 2 do
        img:at(r,c).rgb[ch] = 255 - img:at(r,c).rgb[ch]
      end
    end
  end
  
  -- return the negated image
  -- note: input image was modified (did not make a copy)
  return img
end

-----------------

-- 3x3 smoothing
local function my_smooth( img )
  local nrows, ncols = img.height, img.width

  -- convert image from RGB to YIQ
  img = il.RGB2YIQ( img )

  -- make a local copy of the image
  local res = img:clone()

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
      -- sum 3x3 neighborhood pixel intensities
      local sum = 0
      for i = -1, 1 do
        for j = -1, 1 do
          sum = sum + img:at(r+i,c+j).yiq[0]
        end
      end
      -- store the neighborhood average
      res:at(r,c).rgb[0] = sum / 9
    end
  end

  -- convert smoothed image from YIQ to RGB
  return il.YIQ2RGB( res )
end

-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"Grayscale", il.grayscaleYIQ},
    {"Negate", il.negate},
    {"My Negate", my_negate},
  }
)

imageMenu("Neighborhood processes",
  {
    {"Weighted 3x3 Smooth", il.smooth},
    {"My 3x3 Smooth", my_smooth},
  }
)

start()
