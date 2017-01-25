require("ip")
require("visual")
local il = require("il")
local funcs = require("functions")

imageMenu("Point processes",
  {
    {"Grayscale RGB", funcs.grayscaleRGB},
    {"Negate", funcs.negate},
    {"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
    --{"Posterize", funcs.posterize},
    {"Brighten", funcs.brighten, {{name = "Value", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    --{"Gamma", funcs.gamma, {{name = "gamma", type = "string", default = "1.0"}}},
    {"Gamma", funcs.gamma, {{name = "Gamma", type = "string", default = "1.0"}}},
    {"Log", funcs.logscale},
    {"Cont Pseudocolor", funcs.cont_pseudocolor},
    {"Disc Pseudocolor", funcs.disc_pseudocolor},
    {"His Pseudocolor", il.pseudocolor2},
    --{"Bitplane Slice", funcs.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
    {"Bitplane Slice", funcs.slice}
  }
)

imageMenu("Histogram processes",
  {
    {"Contrast Stretch", funcs.auto_stretch},
    {"His Contrast Stretch", il.stretch},
    {"Contrast Specify", funcs.stretchSpecify,
      {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
    --{"Contrast Specify", funcs.stretchSpecify},
    {"Histogram Equalize RGB", funcs.equalizeRGB},
    --{"Histogram Equalize Clip", funcs.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}}
    {"Histogram Equalize Clip", funcs.equalizeClip}
  }
)

imageMenu("Misc",
  {
    {"Binary Threshold", funcs.threshold, {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}}
    --{"Binary Threshold", funcs.threshold}
  }
)

start()