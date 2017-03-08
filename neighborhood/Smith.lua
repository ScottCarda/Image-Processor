require "ip"
local il = require("il")
local helpers = require "Helper_Funcs"

local funcs = {}

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

-- you may have to perform a contrast stretch afterwards
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

function funcs.kirsch_mag( img )

end

function funcs.kirsch_dir( img )

end

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
            sum = math.abs( sum )
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

function funcs.emboss( img)

end

return funcs
