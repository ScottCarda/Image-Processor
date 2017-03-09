require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}
--[[    oor_noise_cleaning_filter
  |
  |   Takes an image and a threshold value to determine if the the center pixel
  |   in a 3x3 neighborhood is correlated to the surrounding pixels. If the sum
  |   of its neighbors multiplied by 1/8 is greater than the threshold, the
  |   pixel is deteremend to not be correlated and set to average of its neighbors
  |
  |     Author: Chris Smith
--]]

function funcs.oor_noise_cleaning_filter( img, thresh)
    il.RGB2YIQ( img )
    local cpy_img = img:clone()
    local pix
    local sum
    local size = 3
    local hist
    for row, col in img:pixels() do
        pix = cpy_img:at(row, col )
        hist = helpers.sliding_histogram(img, row, col, size)
        sum = 0
        for i = 0, 255 do
            sum = sum + i * hist[i]
        end
        sum = 1/8*(sum - pix.r)

        if math.abs( pix.r - sum ) >= thresh then
            pix.r = sum
        end
    end
    il.YIQ2RGB( cpy_img )
    return cpy_img
end
--[[    median_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument) and
  |  performs a median filter using a square neighborhood of the given side
  |  length. This will sort the values and set the center pixel in the neighborhood
  |  to the median value of all the pixels in the neighborhood.
  |
  |     Author: Chris Smith
--]]
function funcs.median_filter( img, size )
    il.RGB2YIQ( img )
    local cpy_img = img:clone()
    local pix
    
    local hist
    local count
    local i

    for row, col in img:pixels() do
        pix = cpy_img:at(row, col)
        hist = helpers.sliding_histogram(img, row, col, size)
        i = -1
        count = 0
        while count < math.ceil( size * size / 2 ) do
            i = i + 1
            count = count + hist[i]
        end
        pix.r = i
    end
    il.YIQ2RGB( cpy_img)

    return cpy_img

end

--[[    sd_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument ) and
  |  performs a standard deviation filter using a square neighborhood of the
  |  given side length. This calculates the standard deviation of the neighborhood
  |  and sets the center pixel to the standard deviation.
  |
  |     Author: Chris Smith
--]]
function funcs.sd_filter( img, size)
    il.RGB2YIQ( img )
    local cpy_img = img:clone()
    local pix

    local hist
    local sum
    local sq_sum
    local n = size * size
    for row, col in img:pixels() do
        pix = cpy_img:at( row, col)
        hist = helpers.sliding_histogram( img, row, col, size )
        sum = 0
        sq_sum = 0
        for i = 0, 255 do
            sum = sum + ( i * hist[i] )
            sq_sum = sq_sum + ( ( i * i ) * hist[i] )
        end
        pix.r = math.sqrt( ( sq_sum - ( sum*sum ) /n) / n)
    end
    il.YIQ2RGB (cpy_img)
    return cpy_img
end
--[[    var_filter
  |
  |  Takes an image and a neighborhood side length ( the size argument) and
  |  performs a variance filter using a square neighborhood of the given side
  |  length. This calculates the variance of the neighborhood and sets the center
  |  pixel to the variance
  |
  |     Author: Chris Smith
--]]
function funcs.var_filter( img, size )
    il.RGB2YIQ( img )
    local cpy_img = img:clone()
    local pix
    local hist
    local sum
    local sq_sum
    local n = size * size
    for row, col in img:pixels() do
        pix = cpy_img:at( row, col )
        hist = helpers.sliding_histogram( img, row, col, size )
        sum = 0
        sq_sum = 0
        for i = 0, 255 do
            sum = sum + ( i * hist[i] )
            sq_sum = sq_sum + ( ( i * i ) * hist[i] )
        end
        pix.r = helpers.in_range((sq_sum - (sum*sum) / n ) /n)
    end
    il.YIQ2RGB ( cpy_img)
    return cpy_img
end
--[[    kirsch_mag
  |
  |  Takes an image and applies the kirsch filters to each pixel in the image.
  |  There are 8 kirsch filters applied to each pixel in the image and the
  |  filter that produces the maximum is the value the center 
  |  pixel is set to.
  |
  |     Author: Chris Smith
--]]
function funcs.kirsch_mag( img )

end
--[[    kirsch_dir
  |
  |  Takes an image and applies the kirsch filters to each pixel in the image.
  |  There are 8 kirsch filters applied to each pixel in the image and the
  |  filter that produces the maximum magnitude is the value the center 
  |  pixel is set to.
  |
  |     Author: Chris Smith
--]]
function funcs.kirsch_dir( img )
    local kirsch_mask
    
    il.RGB2YIQ( img )
    
    local cpy_img = img:clone()
    local pix
    local x, y
    local sum
    
    for row, col in img:pixels() do
        pix = cpy_img:at( row, col )
        
        local max = 0
        sum = 0
        for rot = 0, 7 do
            --sum = 0
            kirsch_mask = helpers.rotate_kirsch( rot )
            for i = 1, 3 do
                y = helpers.reflection( (row+i-2), 0, img.height)
                for j = 1, 3 do
                    x = helpers.reflection( (col+j-2), 0, img.width )
                    sum = sum + img:at( y, x ).r * kirsch_mask[i][j]
                end
            end
            sum = math.abs( sum )
            --if sum > max then
              --max = sum
            --end
        end--end rotation
        
        pix.r = helpers.in_range( sum )
        pix.g = 128
        pix.b = 128
    end
    il.YIQ2RGB(cpy_img)
    return cpy_img

end
--[[    Kirsch
  |
  |  Takes an image and performs both the kirsch direction and magnitude
  |  calculations at once and returns both images.
  |
  |     Author: Chris Smith
--]]
function funcs.kirsch( img )
    local kirsch_mask
    
    il.RGB2YIQ( img )
    
    local cpy_img = img:clone()
    local pix
    local x, y
    local sum
    
    for row, col in img:pixels() do
        pix = cpy_img:at( row, col )
        
        local max = 0
        for rot = 0, 7 do
            sum = 0
            kirsch_mask = helpers.rotate_kirsch( rot )
            for i = 1, 3 do
                y = helpers.reflection( (row+i-2), 0, img.height)
                for j = 1, 3 do
                    x = helpers.reflection( (col+j-2), 0, img.width )
                    sum = sum + img:at( y, x ).r * kirsch_mask[i][j]
                end
            end
            --sum = math.abs( sum )
            if sum > max then
              max = sum
            end
        end--end rotation
        
        pix.r = helpers.in_range( max/3 )
        pix.g = 128
        pix.b = 128
    end
    il.YIQ2RGB(cpy_img)
    return cpy_img
end
--[[    emboss
  |
  |  Takes an image and applies an embossing filter where 1 is the pixel above 
  |  and to left of the current pixel and the -1 is down and to the right of 
  |  the center pixel. Those two pixels are then added together after being multiplied
  |  by 1 and -1 and the center pixel is set to the result.
  |
  |     Author: Chris Smith
--]]
function funcs.emboss( img)
  il.RGB2YIQ( img )
    
  local cpy_img = img:clone()
  local pix, neg_pix, pos_pix
  local x, y
  for row, col in img:pixels() do
    pix = cpy_img:at( row, col )
    pos_pix = img:at(  helpers.reflection( row-1,0,img.height) , helpers.reflection(col - 1,0,img.width))
    neg_pix = img:at( helpers.reflection( row+1,0,img.height) , helpers.reflection(col + 1,0,img.width))
    pix.r = helpers.in_range(128 + pos_pix.r - neg_pix.r)
  end
  il.YIQ2RGB(cpy_img)
  return cpy_img
end

return funcs
