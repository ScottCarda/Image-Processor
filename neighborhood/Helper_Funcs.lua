--[[
  |                              HelperFuncs.lua                               |
  |                                                                            |
  |   This file contains various miscellaneous functions that are used commonly|
  |in the image processing functions.                                          |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

local il = require ( "il" )

local funcs = {}

--[[    in_range
  |
  |   Takes a value and return the value if it is in the range 0 to 255.
  |   If it is not in the range, it returns the range's endpoint that is
  |   the closest.
  |
  |     Author: Scott Carda
--]]
function funcs.in_range( val )  

  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end

end

--[[    reflection
  |
  |   Takes an index value and return the reflected index value to ensure
  |   that the value lies between the given min and max values, inclusive to the min.
  |
  |     Author: Scott Carda
--]]
function funcs.reflection( index, min, max )

  local i = index - min -- index, offset min
  local n = max - min -- size of range

  -- If the number of reflections is odd
  if (math.floor(i/n)%2 == 1) then
    index = n - i%n - 1 -- reflected index
  else
    index = i%n -- normal, modulated index
  end

  return index + min -- return the calculated index, offset min

end

--[[    get_hist
  |
  |   Takes an image, a channel specifier, a position in the
  |   image, and a neighborhood size. Calculates the histogram for the
  |   neighborhood centered around the given image position, for the
  |   given channel. Returns the caluclated histogram.
  |
  |     Authors: Scott Carda
--]]
function funcs.get_hist( img, chan, row, col, size )
  local pix -- a pixel
  local hist = {} -- histogram
  local x, y -- coordinates for a pixel

  -- initialize the histogram
  for i = 0, 255 do
    hist[i] = 0
  end

  local n = (size-1)/2 -- offset for the indexes of the neighborhood

  -- neighborhood loop
  for i = -n, n do
    y = funcs.reflection( row + i, 0, img.height )
    for j = -n, n do
      x = funcs.reflection( col + j, 0, img.width )

      pix = img:at( y, x )

      -- add the pixel to the histogram
      hist[pix.rgb[chan]] = hist[pix.rgb[chan]] + 1

    end
  end

  return hist
end

--[[    table_copy
  |
  |   Takes a table and returns a shallow copy of the given table.
  |
  |     Authors: Scott Carda
--]]
function funcs.table_copy( table )
  result = {}
  for key, val in pairs(table) do
    result[key] = val
  end
  return result
end

--[[    sliding_histogram
  |
  |   Takes an image, a position in the image, and a neighborhood size. Efficiently
  |   calculates the histogram of the neighborhood centered on the given position by
  |   using the previously computed histogram. This function is intended to be called
  |   in a row-major image loop.
  |
  |     Authors: Scott Carda
--]]
do
  local hist -- the histogram
  local row_start_hist -- the histogram at the beginning of a row
  function funcs.sliding_histogram( img, row, col, size )

    local x1, x2, y1, y2 -- pixel coordinates
    local val -- value of a particular pixel's intensity

    -- if it is the first histogram of the image, make a new histogram
    if row == 0 and col == 0 then

      row_start_hist = funcs.get_hist( img, 0, row, col, size )
      hist = funcs.table_copy( row_start_hist )

    elseif col == 0 then -- if it is the first histogram of a row, slide down from the previous row_start_hist

      y1 = funcs.reflection( row-(size-(size-1)/2), 0, img.height ) -- row to be deleted
      y2 = funcs.reflection( row+(size-(size-1)/2)-1, 0, img.height ) -- row to be added
      for i = 1, size do
        x1 = funcs.reflection( col+i-(size-(size-1)/2), 0, img.width )

        val = img:at( y1, x1 ).r
        row_start_hist[val] = row_start_hist[val] - 1 -- remove the pixel
        val = img:at( y2, x1 ).r
        row_start_hist[val] = row_start_hist[val] + 1 -- add the pixel

      end
      hist = funcs.table_copy( row_start_hist )

    else -- else, slide right from the previous histogram

      x1 = funcs.reflection( col-(size-(size-1)/2), 0, img.width ) -- col to be deleted
      x2 = funcs.reflection( col+(size-(size-1)/2)-1, 0, img.width ) -- col to be added
      for i = 1, size do
        y1 = funcs.reflection( row+i-(size-(size-1)/2), 0, img.height )

        val = img:at( y1, x1 ).r
        hist[val] = hist[val] - 1 -- remove the pixel
        val = img:at( y1, x2 ).r
        hist[val] = hist[val] + 1 -- add the pixel

      end

    end

    return hist

  end
end

--[[    rotate_kirsch
  |
  |  Returns the corresponding kirsch filter for the given rotation
  |
  |     Author: Chris Smith
--]]
function funcs.rotate_kirsch( rot )
  if rot == 0 then --East
    return {
      {-3,-3, 5},
      {-3, 0, 5},
      {-3,-3, 5}
    }
  elseif rot == 1 then --North East
    return {
      {-3, 5, 5},
      {-3, 0, 5},
      {-3,-3,-3}
    }
  elseif rot == 2 then --North
    return {
      { 5, 5, 5},
      {-3, 0,-3},
      {-3,-3,-3}
    }
  elseif rot == 3 then --North West
    return {
      { 5, 5,-3},
      { 5, 0,-3},
      {-3,-3,-3}
    }
  elseif rot == 4 then  --West
    return {
      {5,-3,-3},
      {5, 0,-3},
      {5,-3,-3}
    }
  elseif rot == 5 then --South West
    return {
      {-3,-3,-3},
      { 5, 0,-3},
      { 5, 5,-3}
    }
  elseif rot == 6 then --South
    return {
      {-3,-3,-3},
      {-3, 0,-3},
      { 5, 5, 5}
    }
  else              --South East
    return {
      {-3,-3,-3},
      {-3, 0, 5},
      {-3, 5, 5}
    }
  end
end

return funcs
