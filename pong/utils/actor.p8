_actor={}
setmetatable(_actor, _actor)

function _actor:__call(params)
  local params = params or {}

  local instance = inherit({}, _actor)
  instance.pos = params.pos or _vec2(0, 0)
  instance.vel = params.vel or _vec2(0, 0)
  instance.acc = params.acc or _vec2(0, 0)
  instance.sprite = params.sprite or 0
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
  spr(self.sprite, self.pos.x, self.pos.y, self.width,
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

-- moves self outside of an aabb
function _actor:aabb_separate(aabb)
  assert(aabb)
  -- point in the direction of movement
  inside_point = self:aabb():corner_in_dir(self.vel)
  -- last frame, we didn't collide
  outside_point = inside_point - self.vel
  movement_line = _line(inside_point, outside_point)
  edge_point = aabb:line_edge_intersection(
    movement_line)
  if not edge_point then
    dbg("Expected to separate bb's, but they don't collide")
    return
  end
  self.pos += edge_point - inside_point
end
