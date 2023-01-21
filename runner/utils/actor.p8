_actor={}
setmetatable(_actor, _actor)

function _actor:__call(params)
  local params = params or {}

  local instance = inherit({}, _actor)
  instance.pos = params.pos or _vec2(0, 0)
  instance.vel = params.vel or _vec2(0, 0)
  instance.acc = params.acc or _vec2(0, 0)
  instance.spr = params.spr or 0
  instance.width = params.width or 1
  instance.height = params.height or 1
  instance.flip_x = params.flip_x or false
  instance.flip_y = params.flip_y or false
  instance.visible = params.visible or true
  instance.age = 0
  instance.lifespan = params.lifespan or 0
  assert(instance.lifespan >= 0)
  instance.alive = true
  return instance
end

-- age in [0, 1] from alive to dead. if lifespan = 0, this is always 0.
function _actor:age_frac()
  if self.lifespan == 0 then return 0 end
  return min(1, self.age / self.lifespan)
end

function _actor:aabb()
  return _aabb(
    _vec2(self.pos.x, self.pos.y),
    _vec2(_spr_width * self.width-1,
          _spr_height * self.height -1))
end

function _actor:draw()
  if not self.visible then return end
  spr(self.spr, self.pos.x, self.pos.y, self.width,
      self.height, self.flip_x, self.flip_y)
end

function _actor:update()
  if not self.alive then return end
  self.age += 1
  if self.lifespan > 0 and self.age >= self.lifespan then
    self.alive = false
    return
  end
  self.pos += self.vel
  self.vel += self.acc
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
