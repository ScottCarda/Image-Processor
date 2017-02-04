require ("ip")
local il = require "il"
local helpers = {}

function helpers.get_minmax_intensities( img )
  local min = 256
  local max = 0
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do 
      if min > img:at(row, col ).r then
        min = img:at(row, col ).r
      end
      if max < img:at(row, col ).r then
        max = img:at(row, col ).r
      end
    end
  end
  return min, max
end

function helpers.count_values(img)
  local hist = {}
  for row = 0, img.height-1 do
    for col = 0, img.width-1 do 
      hist[img:at(row,col).y] = hist[img:at(row,col).y] + 1
    end
  end
  return hist
end
--Scotts in_range function
function helpers.in_range( val )  
  
  if val > 255 then
    return 255
  elseif val < 0 then
    return 0
  else
    return val
  end
  
end

function helpers.get_hist( img, chan )
  local pix
  local hist = {}
  
  -- initialize the histogram
  for i = 0, 255 do
    hist[i] = 0
  end
  
  for row, col in img:pixels() do
    
    pix = img:at( row, col )
    
    hist[pix.rgb[chan]] = hist[pix.rgb[chan]] + 1
    
  end
  
  return hist
end

function helpers.round( val )
  return math.floor( val + 0.5 )
end
--get percent location given the image histogram, number of pixels in the image,  percent pixel from
function helpers.get_percent_location( hist, num_pixels, percent, start )
  local count = 0
  local dir = 1
  local last = 255
  local found = start
  if start == 255 then
    dir = -1
    last = 0
  end
  for i = start, last, dir do
    if (count / num_pixels) * 100 > percent then
      return i
    end
    count = count + hist[i]
    found = i
  end
  return found
end

function helpers.clip_hist( hist, max_pixels)
  local cut_pixels = 0
  local largest_bins = {}
  local k = 0
  for i = 0, 255 do
    if hist[i] >= max_pixels then
      cut_pixels = cut_pixels + ( hist[i] - max_pixels)
      hist[i] = max_pixels
      largest_bins[k] = i
      k = k + 1
    end
  end
  return hist, cut_pixels, largest_bins, k
end

function helpers.distribute_cut_pixels( hist, cut_pixels, largest_bins, size)
  local mod = cut_pixels % 256
  local num = math.floor(cut_pixels / 256)
  for i = 0, 255 do
    hist[i] = hist[i] + num
  end
  if mod ~= 0 then
    local k = 0
    for i = 0, mod do
      hist[ largest_bins[k] ] = hist[ largest_bins[k] ] + 1
      k = (k + 1) % size
    end
  end
  return hist
end

function helpers.convert_img( img, model)
  --convert image based on model selected
  if model == "YIQ" or model == "yiq" then
    return il.RGB2YIQ(img)
  elseif model == "YUV"or model == "YUV" then
    return il.RGB2YUV(img)
  elseif model == "IHS"or model == "ihs" then
    return il.RGB2IHS(img)
  end
  return img
end

function helpers.convert_2rgb(img, model)
  --convert image back to RGB
  if model == "YIQ" or model == "yiq" then
    return il.YIQ2RGB(img)
  elseif model == "YUV"or model == "YUV" then
    return il.YUV2RGB(img)
  elseif model == "IHS"or model == "ihs" then
    return il.IHS2RGB(img)
  end
  return img
end
function helpers.use_lut( img, lut, n_chans)
  for row, col in img:pixels() do
    local pix = img:at( row, col )
    for chan = 0, n_chans do
      pix.rgb[chan] = lut[ pix.rgb[chan] ]
    end
  end
  return img
end

return helpers