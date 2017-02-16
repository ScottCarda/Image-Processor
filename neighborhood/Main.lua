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

local smith = require( "Smith" )
local carda = require( "Carda" )
local neighbor = require( "Neighbor" )

imageMenu("Point processes",
  {
  
  }
)

imageMenu("Histogram processes",
  {
  
  }
)
imageMenu("Neighborhood processes",
  {

  }
)

imageMenu("Misc",
  {
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
