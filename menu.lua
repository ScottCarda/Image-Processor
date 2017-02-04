require("ip")
require("visual")
local il = require("il")
local funcs = require("functions")

imageMenu("Point processes",
  {
    {"Grayscale RGB", funcs.grayscaleRGB},
    {"Negate", funcs.negate},
    {"Posterize", funcs.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}, {name = "Model", type = "string", default = "rgb"}}},
    --{"Posterize", funcs.posterize},
    {"Brighten", funcs.brighten, {{name = "Value", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    --{"Gamma", funcs.gamma, {{name = "gamma", type = "string", default = "1.0"}}},
    {"Contrast", funcs.stretchSpecify,
      {{name = "Left endpoint", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
        {name = "Right endpoint", type = "number", displaytype = "spin", default = 192, min = 0, max = 255}}},
    {"Gamma", funcs.gamma, {{name = "Gamma", type = "string", default = "1.0"}}},
    {"His Gamma", il.gamma, {{name = "Gamma", type = "string", default = "1.0"}}},
    {"Log", funcs.logscale, {{name = "Model", type = "string", default = "rgb"}}},
    {"Cont Pseudocolor", funcs.cont_pseudocolor},
    {"Disc Pseudocolor", funcs.disc_pseudocolor},
    {"His Pseudocolor", il.pseudocolor2},
    --{"Bitplane Slice", funcs.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
    {"Bitplane Slice", funcs.slice, {{name = "Plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
    {"His Bitplane Slice", il.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}}
  }
)

imageMenu("Histogram processes",
  {
    {"Contrast Stretch", funcs.auto_stretch, 
      {{name = "Model", type = "string", default = "yiq"}}},
    {"Contrast Percent", funcs.stretchPercent,
      {{name = "Percent of points from min: ", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "Percent of pionts from max: ", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}, 
       {name = "Model", type = "string", default = "yiq"}}},
    --{"Contrast Specify", funcs.stretchSpecify},
    {"Histogram Equalize RGB", funcs.equalizeRGB},
    --{"Histogram Equalize Clip", funcs.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}}
    {"Histogram Equalize Clip", funcs.equalizeClip, {{name = "Percent", type = "string", default = "1.0"}, {name = "Model", type = "string", default = "yiq"}}},
    {"Hist Histogram", il.equalizeRGB},
    {"Display Intensity Histogram", il.showHistogram, {{name = "Model", type = "string", default = "yiq"}}}
  }
)

imageMenu("Misc",
  {
    {"Binary Threshold", funcs.threshold, {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}}
  }
)

start()