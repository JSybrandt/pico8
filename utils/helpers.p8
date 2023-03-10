-- helpers --

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

function inherit(prototype, parent)
  assert(not prototype.parent)
  child = setmetatable({}, parent)
  for k, v in pairs(parent) do child[k] = v end
  for k, v in pairs(prototype) do child[k] = v end
  child.parent = parent
  return child
end

function tern(cond, a, b)
  if cond then return a else return b end
end

function read_unit_input(player_idx)
  player_idx = player_idx or 0
  local input = _v2()
  if btn(_up, player_idx) then input.y -= 1 end
  if btn(_down, player_idx) then input.y += 1 end
  if btn(_left, player_idx) then input.x -= 1 end
  if btn(_right, player_idx) then input.x += 1 end
  return input:unit()
end

function interp1d(frac, min, max)
  assert(frac >= 0)
  assert(frac <= 1)
  delta = max-min
  return min + frac * delta
end

function shallow_copy(tbl)
  local cpy = setmetatable({}, tbl)
  for k, v in pairs(tbl) do
    cpy[k] = v
  end
  return cpy
end

function deep_copy(tbl)
  local cpy = setmetatable({}, tbl)
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      cpy[k] = deep_copy(v)
    else
      cpy[k] = v
    end
  end
  return cpy
end

function merge(a, b)
  local c = {}
  for x in all({a,b}) do
    for k,v in pairs(a) do c[k]=v end
  end
  return c
end

-- its just insertion sort
function sort(tbl, key_fn)
  local keys = {}
  for i = 1,#tbl do
    keys[i] = tern(key_fn, key_fn(tbl[i]), tbl[i])
  end
  for i = 1,#tbl-1 do
    min_idx = i
    for j = i+1, #tbl do
      if keys[min_idx] > keys[j] then min_idx = j end
    end
    if i != min_idx then
      tbl[i], tbl[min_idx] = tbl[min_idx], tbl[i]
      keys[i], keys[min_idx] = keys[min_iex], keys[i]
    end
  end
  return tbl
end

function screen_aabb()
  return _aabb(_v2(), _v2(_width, _height))
end

function is_alive(a) return a.alive end

function round(a)
  if (a%1)>0.5 then
    return ceil(a)
  else
    return flr(a)
  end
end

function sign(a) if a < 0 then return -1 else return 1 end end

-- float equals
function approx(a, b)
  if abs(a - b) < _eps then return true end
  return false
end

function clip(a, l, h)
  if a < l then
    return l
  elseif a > h then
    return h
  end
  return a
end

function minimum(tbl, fn)
  local min
  for x in all(tbl) do
    if fn then x = fn(x) end
    if min == nil or x < min then min = x end
  end
  return min
end

function maximum(tbl, fn)
  local max
  for x in all(tbl) do
    if fn then x = fn(x) end
    if max == nil or x > max then max = x end
  end
  return max
end
