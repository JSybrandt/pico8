_line = {}
setmetatable(_line, _line)

function _line:__call(head, tail)
  assert(head)
  assert(head.x)
  assert(head.y)
  assert(tail)
  assert(tail.x)
  assert(tail.y)
  local instance = inherit({}, _line)
  instance.head=head
  instance.tail=tail
  return instance
end

function _line:delta() return self.tail - self.head end

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
       self.tail.x, self.tail.y)
end
