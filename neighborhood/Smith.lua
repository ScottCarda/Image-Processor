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

function funcs.emboss( img)

end

return funcs
