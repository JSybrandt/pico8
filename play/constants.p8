pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

-- screen
_width = 128
_height = 128

-- colors
_black = 0
_dark_blue = 1
_dark_red = 2
_dark_green = 3
_dark_orange = 4
_dark_brown = 5
_grey = 6
_white = 7
_red = 8
_orange = 9
_yellow = 11
_blue = 12
_purple = 13
_pink = 14
_tan = 15
_num_colors = 16

-- buttons
_left = 0
_right = 1
_up = 2
_down = 3
_button_o = 4
_button_x = 5

-- utils
_tick = 0
function cls() rectfill(0,0,_width,_height,_black) end
