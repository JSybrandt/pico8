_v2 = {}
setmetatable(_v2, _v2)

function _v2:__call(x, y)
  local v = inherit({}, _v2)
  v.x = x or 0
  v.y = y or 0
  return v
end

function _v2:__unm()
  return _v2(-self.x, -self.y)
end

function _v2:__add(other)
  return _v2(self.x+other.x, self.y+other.y)
end

function _v2:__sub(other)
  return _v2(self.x-other.x, self.y-other.y)
end

function _v2:__mul(scalar)
  return _v2(self.x*scalar, self.y*scalar)
end

function _v2:__div(scalar)
  return _v2(self.x/scalar, self.y/scalar)
end

function _v2:__mod(scalar)
  return _v2(self.x%scalar, self.y%scalar)
end

function _v2:__eq(other)
  return self.x == other.x and self.y == other.y
end

function _v2:__tostring()
  return "vec2("..self.x..", "..self.y..")"
end

function _v2:norm()
  return sqrt(self.x^2 + self.y^2)
end

function _v2:unit()
  if self.x == 0 and self.y == 0 then return _v2(0,0) end
  return self / self:norm()
end

function _v2:dot(other)
  return self.x * other.x + self.y * other.y
end

function _v2:cross(other)
  return self.x*other.y - self.y*other.x
end

function _v2:pset(color)
  local color = color or _green
  pset(self.x, self.y, color)
end

-- v2 helpers

function rnd_v2()
  return _v2(rnd(_max_num)-_max_num/2, rnd(_max_num)-_max_num/2)
end
