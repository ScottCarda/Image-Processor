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
local viz = require("visual")
local il = require("il")

local point = require( "PointProcesses" )
local hist = require( "HistProcesses" )
local misc = require( "MiscProcesses" )

imageMenu("Point processes",
  {
    {"Grayscale RGB", point.grayscaleRGB},
    {"Sepia", point.sepia},
    {"Negate", point.negate},
    {"Posterize", point.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}, {name = "Model", type = "string", default = "rgb"}}},
    {"Brighten", point.brighten, {{name = "Value", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
    {"Contrast", point.stretchSpecify,
      {{name = "Left endpoint", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "Right endpoint", type = "number", displaytype = "spin", default = 192, min = 0, max = 255},
       {name = "Model", type = "string", default = "yiq"}}},
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

imageMenu("Misc",
  {
    {"Binary Threshold", misc.threshold, {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}}
  }
)

imageMenu("Help",
  {
    {"Help", viz.imageMessage( "Help", "Image processing software. Select an operation from a menu to perform the associated process on the currently selected image." )},
    {"About", viz.imageMessage( "Point Processing Assignment",
      "Authors: Scott Carda, Christopher Smith\n"..
      "Class: CSC442/542 Digital Image Processing\n"..
      "Date: Spring 2017\n"..
      "Uses the GUI framework, LuaIP, developed by Dr. Weiss and Alex Iverson"
    )}
  }
)

start()