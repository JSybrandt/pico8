_rope = {}
setmetatable(_rope, _rope)

flag_desired_delta = 1
flag_num_constraint_relaxations = 3

function _rope:__call(params)
  local params = params or {}
  instance = inherit({}, _rope)
  instance.pos = params.pos or _vec2(0,0)
  instance.size = params.size or 5
  assert(instance.size >= 1)
  instance.color = params.color or _white
  instance.acc = params.acc or _vec2(0,0)
  instance.width = params.width or 1
  instance.particles = {}
  instance:reset_pos(instance.pos)
  return instance
end

function _rope:reset_pos(pos)
  self.pos = pos
  for i = 1,self.size do
    -- its important these particles don't start on top of each other.
    local p = self.pos + _vec2(0, i*flag_desired_delta)
    -- these particles use verlet updates.
    self.particles[i]={pos=p, last_pos=p}
  end
end

function _rope:draw()
  for i = 2, #self.particles do
    local a = self.particles[i-1].pos
    local b = self.particles[i].pos
    for w = 0,(self.width-1) do
      line(a.x, a.y+w, b.x, b.y+w, self.color)
    end
  end
end

function _rope:translate(delta_pos)
  self.pos += delta_pos
  for p in all(self.particles) do
    p.pos += delta_pos
    p.last_pos += delta_pos
  end
end

function _rope:update()
  -- verlet step
  for particle in all(self.particles) do
    local init_pos = particle.pos:copy()
    particle.pos += particle.pos - particle.last_pos + self.acc
    particle.last_pos = init_pos
  end

  -- relax constraint
  for _ = 1,flag_num_constraint_relaxations do
    for i = 2,#self.particles do
      local a = self.particles[i-1].pos
      local b = self.particles[i].pos
      local diff = b - a
      local diff_delta = diff:unit() * ((diff:norm() - flag_desired_delta) / 2)
      if i > 2 then
        self.particles[i-1].pos += diff_delta
        self.particles[i].pos -= diff_delta
      else
        self.particles[i].pos -= diff_delta * 2
      end
    end
  end
  -- reset anchor particle
  self.particles[1].pos = self.pos
end

function _rope:aabb()
  local first_pos = self.particles[1].pos
  local last_pos = self.particles[#self.particles].pos
  local left_top = _vec2(min(first_pos.x, last_pos.x),
                         min(first_pos.y, last_pos.y))
  local right_bottom = _vec2(max(first_pos.x, last_pos.x),
                             max(first_pos.y, last_pos.y))
  return _aabb(left_top, right_bottom-left_top)
end
