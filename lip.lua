--[[

  * * * * lip.lua * * * *

Lua image processing demo program: exercise all LuaIP library routines.

Authors: John Weiss and Alex Iverson
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
-- for k,v in pairs( il ) do io.write( k .. "\n" ) end

-- load images listed on command line
local imgs = {...}
for i, fname in ipairs( imgs ) do loadImage( fname ) end

-----------
-- menus --
-----------

imageMenu("Point processes",
  {
    {"Grayscale YIQ\tCtrl-M", il.grayscaleYIQ, hotkey = "C-M"},
    {"Grayscale IHS", il.grayscaleIHS},
    {"Negate\tCtrl-N", il.negate, hotkey = "C-N",
      {{name = "color model", type = "string", default = "rgb"}}},
    {"Brighten", il.brighten,
      {{name = "amount", type = "number", displaytype = "slider", default = 0, min = -255, max = 255},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Contrast Stretch", il.contrastStretch,
      {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Scale Intensities", il.scaleIntensities,
      {{name = "min", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
       {name = "max", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Posterize", il.posterize,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Gamma", il.gamma,
      {{name = "gamma", type = "number", displaytype = "textbox", default = "1.0"},
       {name = "color model", type = "string", default = "rgb"}}},
    {"Log", il.logscale,
      {{name = "color model", type = "string", default = "rgb"}}},
    {"Solarize", il.solarize},
    {"Sawtooth", il.sawtooth,
      {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}}},
    {"Bitplane Slice", il.slice,
      {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
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

imageMenu("Neigborhood ops",
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
    {"Minimum", il.minimum},
    {"Maximum", il.maximum},
    {"Median+", il.medianPlus},
    {"Median", il.timed(il.median),
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
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
    {"Variance", il.variance,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Std Dev", il.stdDev,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
  }
)

imageMenu("Morphological operations",
  {
    {"Dilate+", il.dilate},
    {"Erode+", il.erode},
    {"Dilate", il.dilate,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Erode", il.erode,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Open", il.open,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Close", il.close,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"SmoothOC", il.smoothOC,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"SmoothCO", il.smoothCO,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Morph Sharpen", il.sharpenMorph},
  }
)

imageMenu("Frequency domain",
  {
    {"DFT Magnitude", il.dftMagnitude},
    {"DFT Phase", il.dftPhase},
    {"Ideal filter", il.frequencyFilter,
      {{name = "filtertype", type = "string", default = "ideal"},
       {name = "cutoff", type = "number", displaytype = "spin", default = 10, min = 0, max = 100},
       {name = "boost", type = "number", displaytype = "textbox", default = "0.0"},
       {name = "lowscale", type = "number", displaytype = "textbox", default = "1.0"},
       {name = "highscale", type = "number", displaytype = "textbox", default = "0.0"}}},
    {"Gaussian LP filter", il.frequencyFilter,
      {{name = "filtertype", type = "string", default = "gaussLPF"},
       {name = "cutoff", type = "number", displaytype = "spin", default = 10, min = 0, max = 100},
       {name = "boost", type = "number", displaytype = "textbox", default = "0.0"}}},
    {"Gaussian HP filter", il.frequencyFilter,
      {{name = "filtertype", type = "string", default = "gaussHPF"},
       {name = "cutoff", type = "number", displaytype = "spin", default = 10, min = 0, max = 100},
       {name = "boost", type = "number", displaytype = "textbox", default = "0.0"}}},
  }
)

imageMenu("Color models",
  {
    {"RGB->YIQ", il.RGB2YIQ}, {"YIQ->RGB", il.YIQ2RGB},
    {"RGB->YUV", il.RGB2YUV}, {"YUV->RGB", il.YUV2RGB},
    {"RGB->IHS", il.RGB2IHS}, {"IHS->RGB", il.IHS2RGB},
    {"R", il.getR}, {"G", il.getG}, {"B", il.getB},
    {"I(HS)", il.getI}, {"H", il.getH}, {"S", il.getS},
    {"Y", il.getY}, {"I(nphase)", il.getInphase}, {"Q", il.getQuadrature},
    {"U", il.getU}, {"V", il.getV},
    {"RGB->RBG", il.RGB2RBG},
    {"RGB->GRB", il.RGB2GRB},
    {"RGB->GBR", il.RGB2GBR},
    {"RGB->BRG", il.RGB2BRG},
    {"RGB->BGR", il.RGB2BGR},
    {"False Color", il.falseColor,
      {{name = "image R", type = "image"}, {name = "image G", type = "image"}, {name = "image B", type = "image"}}},
  }
)

imageMenu("Misc",
  {
    {"Resize", il.rescale,
      {{name = "rows", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384},
       {name = "cols", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384},
       {name = "interpolation", type = "string", default = "bilinear"}}},
    {"Rotate", il.rotate,
      {{name = "theta", type = "number", displaytype = "slider", default = 0, min = -360, max = 360},
       {name = "interpolation", type = "string", default = "bilinear"}}},
    {"Binary Threshold", il.threshold,
      {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
    {"Auto Threshold", il.iterativeBinaryThreshold},
    {"Adaptive Threshold", il.adaptiveThreshold,
      {{name = "width", type = "number", displaytype = "spin", default = 15, min = 3, max = 65}}},
    {"Connected Components", il.connComp,
      {{name = "epsilon", type = "number", displaytype = "spin", default = 16, min = 0, max = 128}}},
    {"Size Filter", il.sizeFilter,
      {{name = "epsilon", type = "number", displaytype = "spin", default = 16, min = 0, max = 128},
       {name = "thresh", type = "number", displaytype = "spin", default = 100, min = 0, max = 16000000}}},
    {"Contours", il.contours,
      {{name = "interval", type = "number", displaytype = "spin", default = 32, min = 1, max = 128}}},
    {"Add Contours", il.addContours,
      {{name = "interval", type = "number", displaytype = "spin", default = 32, min = 1, max = 128}}},
    {"Stat Diff", il.statDiff,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65},
       {name = "k", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Impulse Noise", il.impulseNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}},
    {"White (salt) Noise", il.whiteNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}},
    {"Black (pepper) Noise", il.blackNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}},
    {"Gaussian noise", il.gaussianNoise,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "16.0"}}},
    {"Add", il.add,
      {{name = "image", type = "image"}}},
    {"Subtract", il.sub,
      {{name = "image", type = "image"}}},
  }
)

imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "Abandon all hope, ye who enter here..." ) },
    { "About", viz.imageMessage( "LuaIP Demo " .. viz.VERSION, "Authors: JMW and AI\nClass: CSC442/542 Digital Image Processing\nDate: Spring 2017" ) },
    {"Debug Console", viz.imageDebug},
  }
)

start()
