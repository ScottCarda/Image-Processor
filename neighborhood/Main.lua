--[[
  |                                  Main.lua                                  |
  |   This is a program that implements basic image processing techniques,     |
  |focusing on point processes with some of the processes using histogram      |
  |information from the image. The program allows the viewing of image files   |
  |which lets the user see the results of the various image transformations.   |
  |The menus allow the user to select which processes they want to see.        |
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

local Merged = require( "Merged" )

imageMenu("Point Processes",
  {
  
  }
)

imageMenu("Histogram Processes",
  {
  
  }
)

imageMenu("Neighborhood Processes",
  {
    {"Smooth", Merged.smooth_filter },
    {"Sharpen", Merged.sharp_filter },
    
    {"Mean", Merged.mean_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    --{"Median", il.timed(il.median)
    --  {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    --},
    {"Median+", Merged.plus_median_filter},
    {"Minimum", Merged.min_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    },
    {"Maximum", Merged.max_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}
    }
    --{"Emboss", il.emboss},
    
  }
)

imageMenu("His Neighborhood ops",
  {
    {"Smooth", il.smooth},
    {"Sharpen", il.sharpen},
    {"Mean", il.mean,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}},
    {"Weighted Mean 1", il.meanW1,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}},
    {"Weighted Mean 2", il.meanW2,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 3, max = 65}}},
    {"Gaussian\tCtrl-G", il.meanW3, hotkey = "C-G",
      {{name = "sigma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Minimum", il.minimum,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Maximum", il.maximum,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Median+", il.medianPlus},
    {"Median", il.timed(il.median),
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Emboss", il.emboss},
  }
)

imageMenu("Edge Detection",
  {
    {"Sobel Edge Magnitude", Merged.sobel_mag},
    {"Sobel Edge Direction", Merged.sobel_dir},
    {"Laplacian", Merged.laplacian,
      {
        {name='Filter Number',type='string',displaytype='combo',choices={'First', 'Second', 'Third', 'Fourth'}, default='First'},
        {name='Offset', type='boolean', displaytype='chkbox'}
      }
    },
    --{"Kirsch Edge Magnitude", il.kirsch},
    --{"Kirsch Edge Direction", il.kirsch},
    {"Range", Merged.range_filter,
      {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}
    },
    --{"Std Dev", il.stdDev,
    --  {{name = "Width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}
    --}
    
  }
)

imageMenu("His Edge detection",
  {
    {"Sobel Edge Mag\tCtrl-E", il.sobelMag, hotkey = "C-E"},
    {"Sobel Edge Mag/Dir", il.sobel},
    {"Horizontal/Vertical Edges", il.edgeHorVer},
    {"Kirsch Edge Mag/Dir", il.kirsch},
    {"Canny", il.canny,
      {
        {name = "sigma", type = "number", displaytype = "textbox", default = "2.0"},
        {name = "strong edge threshold", type = "number", displaytype = "slider", default = 32, min = 0, max = 255},
        {name = "weak edge threshold", type = "number", displaytype = "slider", default = 16, min = 0, max = 255},
      }},
    {"Laplacian", il.laplacian},
    {"Laplacian for ZC", il.laplacianZero},
    {"Laplacian of Gaussian", il.LoG,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "4.0"}}},
    {"Difference of Gaussians (DoG)", il.DoG,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "2.0"}}},
    {"Marr-Hildreth (LoG with ZC)", il.marrHildrethLoG,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "4.0"}}},
    {"Marr-Hildreth (DoG with ZC)", il.marrHildrethDoG,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "2.0"}}},
    {"Zero Crossings 2D", il.zeroCrossings},
    {"Morph Gradient", il.morphGradient},
    {"Range", il.range,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Variance", il.variance,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Std Dev", il.stdDev,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
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
