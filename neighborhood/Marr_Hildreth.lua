local il = require ( "il" )
local helpers = require ( "Helper_Funcs" )

local funcs = {}

function funcs.gaussian( img, sigma )
  il.RGB2YIQ(img)
  local e = math.exp
  local pi = math.pi
  local pix
  for row, col in img:pixels() do
    pix = img:at( row, col )
    pix.r = 1/(2*pi*sigma*sigma) * e( -(row*row-col*col)/(2*sigma*sigma))
  end
  il.YIQ2RGB( img )
  return img
end



function funcs.marr_hildreth( img )
  
end

return funcs

local function rotate_values(i)
  if i == 0 then
    return { 1, 1 }, {2,3} 
  elseif i == 1 then
    return { 2, 1 }, {1,3} 
  elseif i == 2 then
    return { 3, 1 }, {1,2} 
  elseif i == 3 then
    return { 3, 2 }, {1,1} 
  elseif i == 4 then
    return { 3, 3 }, {2,1} 
  elseif i == 5 then
    return { 2, 3 }, {3,1}
  end
    return { 1, 3 }, {3,2}
end

function funcs.new_kirsch( img )
  
  local kirsch_mask = {
          {-3,-3,5},
          {-3, 0,5},
          {-3,-3,5}
        }
  local lead_val = {}
  local trail_val = {}
  local cpy_img = img:clone()
  il.RGB2YIQ( img )

  local mag_img = img:clone()
  local dir_img = img:clone()
  local dir_pix, mag_pix
  local x, y, t_y, t_x
  local sum
  local max, mag

  for row, col in img:pixels() do
    dir_pix = dir_img:at( row, col )
    mag_pix = mag_img:at( row, col )
    
    lead_val = {1,2} 
    trail_val = {3,3}
    sum = 0
    max = 0
    for i = 1, 3 do
      y = helpers.reflection( (row+i-2), 0, img.height)
      for j = 1, 3 do
        x = helpers.reflection( (col+j-2), 0, img.width )
        sum = sum + kirsch_mask[i][j] * img:at(y,x).r
      end
    end
    mag = sum
    
    for i = 0, 6 do
      y = helpers.reflection(   row + lead_val[1] - 2, 0, img.height )
      x = helpers.reflection(   col + lead_val[2] - 2, 0, img.width  )
      t_y = helpers.reflection( row + trail_val[1]- 2, 0, img.height )
      t_x = helpers.reflection( col + trail_val[2]- 2, 0, img.width  )
      sum = sum  + 8 * img:at(y,x).r - 8 * img:at(t_y, t_x).r
      if( sum > mag) then
        mag = sum
        max = i + 1
      end
      lead_val, trail_val = rotate_values(i)
    end
    mag_pix.r = helpers.in_range( mag/3 )
    mag_pix.g = 128
    mag_pix.b = 128

    dir_pix.r = helpers.in_range( math.floor(max/8*256) )
    dir_pix.g = 128
    dir_pix.b = 128
  end
  il.YIQ2RGB(mag_img)
  il.YIQ2RGB(dir_img)
  return cpy_img, mag_img, dir_img
end
