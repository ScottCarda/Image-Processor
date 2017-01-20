local funcs = {}

--{"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
function funcs.posterize( img )
  print( "Unimplemented" )
  return img
end

function funcs.stretch( img )
  print( "Unimplemented" )
  return img
end

function funcs.logscale( img )
  print( "Unimplemented" )
  return img
end

function funcs.cont_pseudocolor( img )
  print( "Unimplemented" )
  return img
end

--{"Contrast Specify", funcs.stretchSpecify,
--  {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
--   {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
function funcs.stretchSpecify( img )
  print( "Unimplemented" )
  return img
end

--{"Histogram Equalize Clip", funcs.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}}
function funcs.equalizeClip( img )
  print( "Unimplemented" )
  return img
end

function funcs.other( img )
  print( "Unimplemented" )
  return img
end

return funcs