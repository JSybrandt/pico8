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
  local input = _vec2(0, 0)
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

function copy(tbl)
  copy = setmetatable({}, tbl)
  for k, v in pairs(tbl) do
    copy[k] = v
  end
  return copy
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
