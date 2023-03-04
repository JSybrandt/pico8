_line = {}
setmetatable(_line, _line)

function _line:__call(head, tail)
  local instance = inherit({}, _line)
  instance.head=head
  instance.tail=tail
  return instance
end

function _line:__tostring() return "_line("..tostring(self.head)..", "..tostring(self.tail)..")" end

function _line:delta() return self.tail - self.head end

function _line:top()
  if self.head.y < self.tail.y then return self.head.y
  else return self.tail.y end
end

function _line:bottom()
  if self.head.y < self.tail.y then return self.tail.y
  else return self.head.y end
end

function _line:left()
  if self.head.x < self.tail.x then return self.head.x
  else return self.tail.x end
end

function _line:right()
  if self.head.x < self.tail.x then return self.tail.x
  else return self.head.x end
end

-- calls fn(x, y) for all x, y screen coords covered by the line.
function _line:visit_raster_points(fn)
  local x0, y0, x1, y1, dx, sx, dy, sy, err
  x0 = flr(self.head.x); y0 = flr(self.head.y)
  x1 = flr(self.tail.x); y1 = flr(self.tail.y)
  dx = abs(self.head.x- self.tail.x); dy = -abs(self.head.y - self.tail.y)
  sx = tern(x0 < x1, 1, -1); sy = tern(y0 < y1, 1, -1)
  err = dx + dy
  while true do
    fn(x0, y0)
    if x0 == x1 and y0 == y1 then break end
    local err2 = err * 2
    if err2 >= dy then
      if x0 == x1 then break end
      err += dy; x0 += sx
    end
    if err2 <= dx then
      if y0 == y1 then break end
      err += dx
      y0 += sy
    end
  end
end

function _line:height() return abs(self.tail.y - self.head.y) end

function _line:intersection(other)
  assert(other)
  assert(other.head)
  assert(other.tail)
  head_delta = other.head - self.head
  self_delta = self:delta()
  other_delta = other:delta()
  delta_cross = self_delta:cross(other_delta)

  -- colinear or parallel
  if delta_cross == 0 then return nil end

  -- number in [0, 1] representing where the intersection
  -- happens along self.
  self_intersection_frac = head_delta:cross(other_delta) / delta_cross

  -- intersection happens outside of self.
  if 0 > self_intersection_frac or self_intersection_frac > 1 then return nil end

  other_intersection_frac = head_delta:cross(self_delta) / delta_cross

  -- intersection happens outside of other.
  if 0 > other_intersection_frac or other_intersection_frac > 1 then return nil end

  return self.head + self_delta * self_intersection_frac
end

function _line:draw(color)
  local color = color or _green
  line(self.head.x, self.head.y,
       self.tail.x, self.tail.y, color)
end
