-- axis aligned bounding box
_aabb={}
setmetatable(_aabb, _aabb)

function  _aabb:__call(pos, size)
  assert(pos)
  assert(pos.x)
  assert(pos.y)
  assert(size.x >= 0)
  assert(size.y >= 0)
  local instance = inherit({}, _aabb)
  instance.pos = pos
  instance.size = size
  return instance
end

function _aabb:from_ltrb(left, top, right, bottom)
  return _aabb(_vec2(left, top), _vec2(right-left, bottom-top))
end

function _aabb:left() return self.pos.x end
function _aabb:top() return self.pos.y end
function _aabb:bottom()
  return self.pos.y + self.size.y
end
function _aabb:right()
  return self.pos.x + self.size.x
end
function _aabb:width() return self.size.x end
function _aabb:height() return self.size.y end

function _aabb:center()
  return self.pos + self.size / 2
end

function _aabb:corners()
  return {_vec2(self:left(), self:top()),
          _vec2(self:left(), self:bottom()),
          _vec2(self:right(), self:bottom()),
          _vec2(self:right(), self:top())}
end

function _aabb:edges()
  corners = self:corners()
  return {_line(corners[1], corners[2]), -- left edge
          _line(corners[2], corners[3]), -- bottom edge
          _line(corners[3], corners[4]), -- right edge
          _line(corners[4], corners[1])} -- top edge
end

function _aabb:diagonal()
  return sqrt(self:diagonal_sq())
end

function _aabb:diagonal_sq()
  return self:width()^2+self:height()^2
end

function _aabb:onscreen()
  return self:top() <= _height and
         self:left() <= _width and
         self:bottom() >= 0 and
         self:right() >= 0
end

function _aabb:overlaps(other_aabb)
  assert(other_aabb)
  if self:left() - other_aabb:right() > -_eps then
    return false end
  if other_aabb:left() -  self:right() > -_eps then
    return false end
  if self:top() - other_aabb:bottom() > -_eps then
    return false end
  if other_aabb:top() - self:bottom() > -_eps then
    return false end
  return true
end

function _aabb:intersect(other_aabb)
  assert(other_aabb)
  assert(self:overlaps(other_aabb))
  local left = max(self:left(), other_aabb:left())
  local right = min(self:right(), other_aabb:right())
  local top = max(self:top(), other_aabb:top())
  local bottom = min(self:bottom(), other_aabb:bottom())
  return _aabb:from_ltrb(left, top, right, bottom)
end

function _aabb:contains(point)
  assert(point)
  return self:left() < point.x and
         point.x < self:right() and
         self:top() < point.y and
         point.y < self:bottom()
end

function _aabb:corner_in_dir(dir)
  assert(dir)
  return _vec2(
    ternary(dir.x>0, self:right(), self:left()),
    ternary(dir.y>0, self:bottom(), self:top()))
end


function _aabb:line_edge_intersection(line)
  assert(line)
  for edge in all(self:edges()) do
    pt = line:intersection(edge)
    if pt then return pt end
  end
  return nil
end

function _aabb:draw(color)
  local color = color or _green
  rect(self:left(), self:top(), self:right(), self:bottom(), color)
end

function _aabb:__tostring()
  return "aabb["..self:left()..", "..self:top()..", "
                ..self:right()..", "..self:bottom().."]"
end
