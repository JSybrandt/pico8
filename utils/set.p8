-- set --
_set = {}
setmetatable(_set, _set)

function _set:__call(values)
  local inst = inherit({}, _set)
  inst.values = {}
  for key in all(values or {}) do
    inst.values[key] = true
  end
  return inst
end

function _set:contains(key)
  return self.values[key] == true
end

function _set:insert(key)
  self.values[key] = true
end

function _set:remove(key)
  self.values[key] = nil
end

function _set:intersect(other)
  local result = _set()
  for key in pairs(self.values) do
    if other:contains(key) then
      result:insert(key)
    end
  end
  return result
end

function _set:union(other)
  local result = _set()
  for key in pairs(self.values) do
    result:insert(key)
  end
  for key in pairs(other.values) do
    result:insert(key)
  end
  return result
end

function _set:__len()
  return #self.values
end

function _set:to_list()
  local l = {}
  for k in pairs(self.values) do
    add(l, k)
  end
  return l
end
