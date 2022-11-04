_vec2 = {}
setmetatable(_vec2, _vec2)

function _vec2:__call(x, y)
  local instance = inherit({}, _vec2)
  instance.x = x or 0
  instance.y = y or 0
  return instance
end

function _vec2:zero() return _vec2(0,0) end

-- unary minus
function _vec2:__unm()
  return _vec2(-self.x, -self.y)
end

function _vec2:__add(other)
  assert(other)
  return _vec2(self.x+other.x, self.y+other.y)
end

function _vec2:__sub(other)
  assert(other)
  return _vec2(self.x-other.x, self.y-other.y)
end

function _vec2:__mul(scalar)
  assert(scalar)
  return _vec2(self.x*scalar, self.y*scalar)
end

function _vec2:__div(scalar)
  assert(scalar)
  return _vec2(self.x/scalar, self.y/scalar)
end

function _vec2:__mod(scalar)
  assert(scalar)
  return _vec2(self.x%scalar, self.y%scalar)
end

function _vec2:__tostring()
  return "vec2("..self.x..", "..self.y..")"
end

function _vec2:norm()
  return sqrt(self.x^2 + self.y^2)
end

function _vec2:unit()
  if self.x == 0 and self.y == 0 then return _vec2(0,0) end
  return self / self:norm()
end

function _vec2:__eq(other)
  assert(other)
  return self.x == other.x and self.y == other.y
end

function _vec2:dot(other)
  assert(other)
  return self.x * other.x + self.y * other.y
end

function _vec2:cross(other)
  assert(other)
  return self.x*other.y - self.y*other.x
end

function _vec2:random_unit()
  local res = _vec2(0, 0)
  while res == _vec2(0, 0) do
    res = _vec2(rnd(100)-50, rnd(100)-50):unit()
  end
  return res
end

function _vec2:draw(color)
  local color = color or _green
  pset(self.x, self.y, color)
end

function _vec2:copy()
  return _vec2(self.x, self.y)
end
