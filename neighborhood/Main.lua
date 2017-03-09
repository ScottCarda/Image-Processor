--[[
  |                                  Main.lua                                  |
  |   This is a program that implements image processing techniques, focusing  |
  |on neighborhood processes and edge detection with some of the processes     |
  |using filter convolution and others using rank-order filtering information  |
  |from the image. The program allows the viewing of image files which lets    |
  |the user see the results of the various image transformations. The menus    |
  |allow the user to select which processes they want to see.                  |
  |                                                                            |
  |   This file contains the definitions for the menus that appear in the      |
  |program's GUI, with the exception of the File menu, which is specified      |
  |elsewhere. The contents of this file are based heavily on the lip.lua file  |
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

local Merged = require( "Merged" )

local cmarg1 = {name = "color model", type = "string", displaytype = "combo", choices = {"rgb", "yiq", "ihs"}, default = "rgb"}
local cmarg2 = {name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}
local cmarg3 = {name = "interpolation", type = "string", displaytype = "combo", choices = {"nearest neighbor", "bilinear"}, default = "bilinear"}

imageMenu("Neighborhood Processes",
  {
    {"Smooth", Merged.smooth_filter },
    {"Sharpen", Merged.sharp_filter },
    {"Noise Cleaning", Merged.oor_noise_cleaning_filter,
        {{name = "Threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}
    },
    {"Mean", Merged.mean_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    {"Median", Merged.median_filter,
        {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    {"Median+", Merged.plus_median_filter},
    {"Minimum", Merged.min_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    {"Maximum", Merged.max_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    {"Emboss", Merged.emboss}
  }
)

imageMenu("Edge Detection",
  {
    {"Sobel Edge", Merged.sobel},
    {"Kirsch Edge", Merged.kirsch},
    {"Laplacian", Merged.laplacian},
    {"Range", Merged.range_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}
    },
    {"Variance", Merged.var_filter,
        {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}
    },
    {"Std Dev", Merged.sd_filter,
        {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}
    },
    
  }
)

imageMenu("Misc",
  {
    {"Grayscale YIQ\tCtrl-M", il.grayscaleYIQ, hotkey = "C-M"},
    {"Contrast Stretch", il.stretch, {cmarg2}},
    {"Histogram Equalize", il.equalize,
       {{name = "color model", type = "string", displaytype = "combo", choices = {"ihs", "yiq", "yuv", "rgb"}, default = "ihs"}}
    },
    {"Binary Threshold", il.threshold,
      {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}
    },
    {"Display Histogram", il.showHistogram,
       {{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "rgb"}, default = "yiq"}}
    }
  }
)

imageMenu("Noise",
  {
    {"Impulse Noise", il.impulseNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}
    },
    {"Gaussian Noise", il.gaussianNoise,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "16.0"}}
    }
  }
)

imageMenu("Help",
  {
    {"Help", viz.imageMessage( "Help", "Image processing software. Select an operation from a menu to perform the associated process on the currently selected image." )},
    {"About", viz.imageMessage( "Neighborhood Processing Assignment",
        "Authors: Scott Carda, Christopher Smith\n"..
        "Class: CSC442/542 Digital Image Processing\n"..
        "Date: Spring 2017\n"..
        "Uses the GUI framework, LuaIP, developed by Dr. Weiss and Alex Iverson"
      )}
  }
)

start()
