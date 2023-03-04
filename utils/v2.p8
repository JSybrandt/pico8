_v2 = {}
setmetatable(_v2, _v2)

function _v2:__call(x, y)
  local v = inherit({}, _v2)
  v.x = x or 0
  v.y = y or 0
  return v
end

function _v2:__unm() return _v2(-self.x, -self.y) end
function _v2:__add(other) return _v2(self.x+other.x, self.y+other.y) end
function _v2:__sub(other) return _v2(self.x-other.x, self.y-other.y) end
function _v2:__mul(scalar) return _v2(self.x*scalar, self.y*scalar) end
function _v2:__div(scalar) return _v2(self.x/scalar, self.y/scalar) end
function _v2:__mod(scalar) return _v2(self.x%scalar, self.y%scalar) end
function _v2:__eq(other) return self.x == other.x and self.y == other.y end
function _v2:__tostring() return "vec2("..tostring(self.x)..", "..tostring(self.y)..")" end

-- in place
function _v2:addi(other) self.x += other.x; self.y += other.y end
function _v2:subi(other) self.x -= other.x; self.y -= other.y end
function _v2:muli(scalar) self.x *= scalar; self.y *= scalar end
function _v2:divi(scalar) self.x /= scalar; self.y /= scalar end
function _v2:flri() self.x = flr(self.x); self.y = flr(self.y) end
function _v2:roundi() self.x = round(self.x); self.y = round(self.y) end
function _v2:set(x, y) self.x = x; self.y = y end


function _v2:norm()
  -- because we're squaring, we need to check for overflows.
  local x2 = self.x^2
  -- overflow check
  if x2 < 0 then return _max_num end
  local y2 = self.y^2
  -- overflow check
  if y2 < 0 then return _max_num end
  -- overflow check
  local sum2 = x2 + y2
  if sum2 < 0 then return _max_num end
  return sqrt(sum2)
end

function _v2:unit()
  if self.x == 0 and self.y == 0 then return _v2(0,0) end
  -- sometimes, we will have large vectors that could overflow our tiny ints
  -- so we will prematurely divide our vectors by a constant factor
  local v = self / 100
  return v / v:norm()
end

function _v2:dot(other)
  return self.x * other.x + self.y * other.y
end

function _v2:cross(other)
  return self.x*other.y - self.y*other.x
end

function _v2:flr()
  return _v2(flr(self.x), flr(self.y))
end

function _v2:sign()
  return _v2(sign(self.x), sign(self.y))
end

function _v2:abs()
  return _v2(abs(self.x, abs(self.y)))
end

function _v2:ceil()
  return _v2(ceil(self.x), ceil(self.y))
end

function _v2:round()
  return _v2(round(self.x), round(self.y))
end

function _v2:pset(color)
  local color = color or _green
  pset(self.x, self.y, color)
end

function _v2:rotate(turns)
  local sn = sin(turns)
  local cn = cos(turns)
  return _v2(self.x * cn - self.y * sn,
             self.x * sn + self.y * cn)
end

function _v2:rotatei(turns)
  local sn = sin(turns)
  local cn = cos(turns)
  local x = self.x * cn - self.y * sn
  local y = self.x * sn + self.y * cn
  self.x = x; self.y = y
end

function _v2:rotateics(cn, sn)
  local x = self.x * cn - self.y * sn
  local y = self.x * sn + self.y * cn
  self.x = x; self.y = y
end
-- v2 helpers

function rnd_v2()
  return _v2(rnd(_max_num)-_max_num/2, rnd(_max_num)-_max_num/2)
end
