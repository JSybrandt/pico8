-- prepare the debug environemnt.
function dbg_init()
  -- override the debug logfile.
  if _debug then printh("", _logfile, true) end
end

-- print to the host OS console.
function dbg(...)
  local args = {...}
  if _debug then
    msg = "["..t().."]:"
    for arg in all(args) do
      msg = msg.." "..tostring(arg)
    end
    printh(msg, _logfile)
  end
end

-- returns elements where true.
function filter(tbl, fn)
  for i = #tbl,1,-1 do
    if not fn(tbl[i]) then deli(tbl, i) end
  end
end

function clear(tbl)
  local count = #tbl
  for i = 1,count do
    tbl[i] = nil
  end
end

-- setups prototype inheritance
function inherit(child_prototype, parent_instance)
  assert(not child_prototype.parent)
  child_instance = setmetatable({}, parent_instance)
  for k, v in pairs(parent_instance) do
    child_instance[k] = v
  end

  for k, v in pairs(child_prototype) do
    child_instance[k] = v
  end
  child_instance.parent = parent_instance
  return child_instance
end

-- a simple ternary operator
function ternary(condition, true_case, false_case)
  if condition then
    return true_case
  else
    return false_case
  end
end

function read_input_vec2(player_idx)
  assert(player_idx)
  local input = _vec2(0, 0)
  if btn(_up, player_idx) then input.y -= 1 end
  if btn(_down, player_idx) then input.y += 1 end
  if btn(_left, player_idx) then input.x -= 1 end
  if btn(_right, player_idx) then input.x += 1 end
  return input
end

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

function interp1d(frac, min, max)
  assert(frac >= 0)
  assert(frac <= 1)
  delta = max-min
  return min + frac * delta
end

function rnd01() return rnd(10000)/10000 end
function rndbool(frac)
  local frac = frac or 0.5
  return rnd01() < frac
end
