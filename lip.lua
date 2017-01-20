--[[

  * * * * lip.lua * * * *

Lua image processing program: exercise all LuaIP library routines.

Authors: John Weiss and Alex Iverson
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
require "visual"
local il = require "il"
-- for k, v in pairs(il) do io.write(k.."\n") end

-- load images listed on command line
local imgs = {...}
for i, fname in ipairs(imgs) do loadImage(fname) end

-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"Grayscale RGB", il.grayscaleRGB},
    {"Grayscale YIQ\tCtrl-M", il.grayscaleYIQ, hotkey = "C-M"},
    {"Negate\tCtrl-N", il.negate, hotkey = "C-N"},
    {"Posterize", il.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 8, min = 2, max = 64}}},
    {"Sawtooth", il.sawtooth, {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
    {"Gamma", il.gamma, {{name = "gamma", type = "string", default = "1.0"}}},
    {"Log", il.logscale},
    {"Solarize", il.solarize},
    {"Scale Intensities", il.scaleIntensities,
      {{name = "min", type = "number", displaytype = "spin", default = 0, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 255, min = 0, max = 255}}},
    {"Bitplane Slice", il.slice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
    {"Cont Pseudocolor", il.pseudocolor1},
    {"Disc Pseudocolor", il.pseudocolor2},
    {"Color Cube", il.pseudocolor3},
    {"Random Pseudocolor", il.pseudocolor4},
    {"Color Sawtooth RGB", il.sawtoothRGB},
    {"Color Sawtooth BGR", il.sawtoothBGR},
  }
)

imageMenu("Histogram processes",
  {
    {"Contrast Stretch", il.stretch},
    {"Contrast Specify\tCtrl-H", il.stretchSpecify, hotkey = "C-H",
      {{name = "lp", type = "number", displaytype = "spin", default = 1, min = 0, max = 100},
       {name = "rp", type = "number", displaytype = "spin", default = 99, min = 0, max = 100}}},
    {"Histogram Equalize YIQ", il.equalizeYIQ},
    {"Histogram Equalize YUV", il.equalizeYUV},
    {"Histogram Equalize RGB", il.equalizeRGB},
    {"Histogram Equalize Clip", il.equalizeClip, {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}},
  }
)

imageMenu("Neigborhood ops",
  {
    {"Smooth", il.smooth},
    {"Sharpen", il.sharpen},
    {"Mean", il.mean, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Weighted Mean 1", il.meanW1, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Weighted Mean 2", il.meanW2, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Gaussian\tCtrl-G", il.meanW3, hotkey = "C-G", {{name = "sigma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Minimum", il.minimum},
    {"Maximum", il.maximum},
    {"Median+", il.medianPlus},
    {"Median", il.timed(il.median), {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    -- {"Median 3", il.curry(il.median, 3)}
    {"Emboss", il.emboss},
  }
)

imageMenu("Edge detection",
  {
    {"Sobel Edge Mag\tCtrl-E", il.sobelMag, hotkey = "C-E"},
    {"Sobel Edge Dir", il.sobelDir},
    {"Morph Gradient", il.morphGradient},
    {"Range", il.range},
    {"Variance", il.variance, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Std Dev", il.stdDev, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
  }
)

imageMenu("Morphological operations",
  {
    {"Dilate+", il.dilate},
    {"Erode+", il.erode},
    {"Dilate", il.dilate, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Erode", il.erode,  {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Open", il.open, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Close", il.close, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"SmoothOC", il.smoothOC, {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"SmoothCO", il.smoothCO,  {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Morph Sharpen", il.sharpenMorph},
  }
)

imageMenu("Frequency domain",
  {
    {"DFT Magnitude", il.dftMagnitude},
    {"DFT Phase", il.dftPhase},
    {"Ideal LP filter", il.frequencyFilter,
      {{name = "filtertype", type = "string", default = "ideal"},
       {name = "cutoff", type = "number", displaytype = "spin", default = 10, min = 0, max = 100},
       {name = "lowscale", type = "string", default = "1.0"},
       {name = "highscale", type = "string", default = "0.0"}}},
    {"Ideal HP filter", il.frequencyFilter,
      {{name = "filtertype", type = "string", default = "ideal"},
       {name = "cutoff", type = "number", displaytype = "spin", default = 10, min = 0, max = 100},
       {name = "lowscale", type = "string", default = "0.0"},
       {name = "highscale", type = "string", default = "1.0"}}},
  }
)

imageMenu("Color models",
  {
    {"RGB->YIQ", il.RGB2YIQ}, {"YIQ->RGB", il.YIQ2RGB},
    {"RGB->YUV", il.RGB2YUV}, {"YUV->RGB", il.YUV2RGB},
    {"R", il.GetR}, {"G", il.GetG}, {"B", il.GetB},
    {"Y", il.GetY}, {"I", il.GetI}, {"Q", il.GetQ},
    {"U", il.GetU}, {"V", il.GetV},
    {"RGB->RBG", il.RGB2RBG},
    {"RGB->GRB", il.RGB2GRB},
    {"RGB->GBR", il.RGB2GBR},
    {"RGB->BRG", il.RGB2BRG},
    {"RGB->BGR", il.RGB2BGR},
  }
)

imageMenu("Misc",
  {
    {"Resize", il.rescale,
      {{name = "rows", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384},
       {name = "cols", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384}}},
    {"Binary Threshold", il.threshold, {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Auto Threshold", il.iterativeBinaryThreshold},
    {"Connected Components", il.connComp, {{name = "epsilon", type = "number", displaytype = "spin", default = 16, min = 0, max = 128}}},
    {"Size Filter", il.sizeFilter,
      {{name = "epsilon", type = "number", displaytype = "spin", default = 16, min = 0, max = 128},
        {name = "thresh", type = "number", displaytype = "spin", default = 100, min = 0, max = 16000000}}},
    {"Contours", il.contours, {{name = "interval", type = "number", displaytype = "spin", default = 32, min = 1, max = 128}}},
    {"Add Contours", il.addContours, {{name = "interval", type = "number", displaytype = "spin", default = 32, min = 1, max = 128}}},
    {"Stat Diff", il.statDiff,
      {{name = "w", type = "number", displaytype = "spin", default = 3, min = 0, max = 65},
       {name = "k", type = "string", default = "1.0"}}},
    {"Impulse Noise", il.impulse, {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}},
  }
)

start()