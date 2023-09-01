-- text --

_text_width = 4
_text_height = 5

function print_centered(str, x, y, color)
  local str = tostring(str)
  local color = color or _white
  local x = x - _text_width * #str / 2 + 1
  local y = y - _text_height / 2
  print(str, x, y, color)
end

function print_left_justified(str, x, y, color)
  local str = tostring(str)
  local color = color or _white
  print(str, x, y, color)
end

function print_right_justified(str, x, y, color)
  local str = tostring(str)
  local x = x - _text_width * #str
  print(str, x, y, color)
end
