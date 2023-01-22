-- actor --

_actor={}
setmetatable(_actor, _actor)

function _actor:__call(params)
  local params = params or {}
  local a = inherit({}, _actor)
  a.pos = params.pos or _v2()
  a.vel = params.vel or _v2()
  a.acc = params.acc or _v2()
  a.width = params.width or 0
  a.height = params.height or 0
  a.visible = params.visible or true
  a.alive = params.alive or true
  return a
end

-- aabb centered at pos.
function _actor:aabb()
  return _aabb(_v2(self.pos.x-self.width/2, self.pos.y-self.height/2),
               _v2(self.width-1, self.height-1))
end

function _actor:draw(params)
  local params = params or {}
  if not self.visible then return end
  if _debugging then self:aabb():draw(params.dbg_color) end
end

function _actor:update()
  if not self.alive then return end
  self.pos += self.vel
  self.vel += self.acc
end

function _actor:is_on_screen()
  return screen_aabb():overlaps(_actor.aabb(self))
end

function _actor:keep_on_screen()
  local bb = _actor.aabb(self)
  if bb:left() < 0 then self.pos.x -= bb:left() end
  if bb:right() > _width then self.pos.x -= bb:right() - _width end
  if bb:top() < 0 then self.pos.y -= bb:top() end
  if bb:bottom() > _height then self.pos.y -= bb:bottom() - _height end
end

function _actor:aabb_separate_x(other_aabb, callbacks)
  local callbacks = callbacks or {}
  local actor_aabb = self:aabb()
  assert(actor_aabb:overlaps(other_aabb))
  local intersection = actor_aabb:intersect(other_aabb)
  if actor_aabb:center().x > other_aabb:center().x then
    if callbacks.right then callbacks.right() end
    self.pos.x += intersection:width()
  else
    if callbacks.left then callbacks.left() end
    self.pos.x -= intersection:width()
  end
end
function _actor:aabb_separate_y(other_aabb, callbacks)
  local callbacks = callbacks or {}
  local actor_aabb = self:aabb()
  assert(actor_aabb:overlaps(other_aabb))
  local intersection = actor_aabb:intersect(other_aabb)
  if actor_aabb:center().y > other_aabb:center().y then
    if callbacks.bottom then callbacks.bottom() end
    self.pos.y += intersection:height()
  else
    if callbacks.top then callbacks.top() end
    self.pos.y -= intersection:height()
  end
end

-- moves self outside of an aabb
function _actor:aabb_separate(other_aabb, callbacks)
  local callbacks = callbacks or {}

  local actor_aabb = self:aabb()
  assert(actor_aabb:overlaps(other_aabb))
  local intersection = actor_aabb:intersect(other_aabb)
  local intersection_center = intersection:center()
  local diff_dir = actor_aabb:center() - intersection:center()
  local diff_line = _line(
      intersection_center,
      intersection_center + diff_dir * (intersection:diagonal_sq()+1))
  local edges = intersection:edges()
  local left_edge = edges[1]
  local bottom_edge = edges[2]
  local right_edge = edges[3]
  local top_edge = edges[4]

  if top_edge:intersection(diff_line) then
    if callbacks.top then callbacks.top() end
    self.pos.y -= intersection:height()
  elseif bottom_edge:intersection(diff_line) then
    if callbacks.bottom then callbacks.bottom() end
    self.pos.y += intersection:height()
  elseif left_edge:intersection(diff_line) then
    if callbacks.left then callbacks.left() end
    self.pos.x -= intersection:width()
  elseif right_edge:intersection(diff_line) then
    if callbacks.right then callbacks.right() end
    self.pos.x += intersection:width()
  else -- totally inside, move up
    self.pos.y -= intersection:height()
  end
end

function is_alive(a) return a.alive end
