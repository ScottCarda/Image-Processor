--[[
  |                                  Menu.lua                                  |
  |                                                                            |
  |   This file contains the definitions for the menues that appear in the     |
  |program's GUI, with the exception of the File menu, which is specified      |
  |elsewhere. The contents of this file are based heavilly on the lip.lua file |
  |by Dr. Weiss.                                                               |
  |                                                                            |
  |   Authors:                                                                 |
  |     Scott Carda,                                                           |
  |     Christopher Smith                                                      |
  |                                                                            |
--]]

require("ip")
require("visual")
local il = require("il")

local point = require( "PointProcesses" )
local hist = require( "HistProcesses" )
local misc = require( "MiscProcesses" )

imageMenu("Point processes",
  {
    {"Grayscale RGB", point.grayscaleRGB},
    {"Negate", point.negate},
    {"Posterize", point.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}, {name = "Model", type = "string", default = "rgb"}}},
    {"His Posterize", il.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Brighten", point.brighten, {{name = "Value", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    {"Contrast", point.stretchSpecify,
      {{name = "Left endpoint", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "Right endpoint", type = "number", displaytype = "spin", default = 192, min = 0, max = 255}}},
    {"His Contrast Stretch", il.contrastStretch,
      {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Gamma", point.gamma, {{name = "Gamma", type = "string", default = "1.0"}}},
    {"Log", point.logscale, {{name = "Model", type = "string", default = "rgb"}}},
    {"Cont Pseudocolor", point.cont_pseudocolor},
    {"His Cont Pseudocolor", il.pseudocolor1},
    {"Disc Pseudocolor", point.disc_pseudocolor},
    {"Bitplane Slice", point.slice, {{name = "Plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
  }
)

imageMenu("Histogram processes",
  {
    {"Contrast Stretch", hist.auto_stretch, 
      {{name = "Model", type = "string", default = "yiq"}}},
    {"Contrast Percent", hist.stretchPercent,
      {{name = "Percent of points from min: ", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "Percent of pionts from max: ", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}, 
       {name = "Model", type = "string", default = "yiq"}}},
    {"Histogram Equalize RGB", hist.equalizeRGB},
    {"Histogram Equalize Clip", hist.equalizeClip, {{name = "Percent", type = "string", default = "1.0"}, {name = "Model", type = "string", default = "yiq"}}},
    {"Display Intensity Histogram", il.showHistogram, {{name = "Model", type = "string", default = "yiq"}}}
  }
)

imageMenu("His Histogram processes",
  {
    {"Contrast Stretch", il.stretch,
       {{name = "color model", type = "string", default = "yiq"}}},
    {"Contrast Specify\tCtrl-H", il.stretchSpecify, hotkey = "C-H",
      {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100},
       {name = "color model", type = "string", default = "yiq"}}},
    {"Histogram Equalize", il.equalize,
      {{name = "color model", type = "string", default = "yiq"}}},
    {"Histogram Equalize Clip", il.equalizeClip,
      {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"},
       {name = "color model", type = "string", default = "yiq"}}},
    {"Display Histogram", il.showHistogram,
       {{name = "color model", type = "string", default = "yiq"}}},
    {"Adaptive Equalize", il.adaptiveEqualize,
      {{name = "width", type = "number", displaytype = "spin", default = 15, min = 3, max = 65}}},
    {"Adaptive Contrast Stretch", il.adaptiveContrastStretch,
      {{name = "width", type = "number", displaytype = "spin", default = 15, min = 3, max = 65}}},
  }
)

imageMenu("Misc",
  {
    {"Binary Threshold", misc.threshold, {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}}
  }
)

start()