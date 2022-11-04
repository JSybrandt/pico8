_ball = {}
setmetatable(_ball, _ball)

ball_speed_min = 2
ball_speed_max = 8
ball_speed_delta = 0.05
ball_bounce_rand_frac = 0.01
ball_particle_min_lifespan  = 4
ball_particle_max_lifespan = 16
ball_particle_min_rad = 0
ball_particle_max_rad = 2.5
ball_particle_speed = 2
ball_particle_vel_rand_frac = 0.2

function _ball:__call(particles)
  local parent = _actor({sprite = 3})
  local instance = inherit(_ball, parent)
  instance.particles = particles
  instance:reset()
  return instance
end

function jitter_vec2(vec, jitter_frac)
  assert(jitter_frac >= 0)
  assert(jitter_frac <= 1)
  local new_unit = vec:unit() * (1-jitter_frac) + _vec2:random_unit() * jitter_frac
  return new_unit * vec:norm()
end

function _ball:get_particle_lifespan()
  return interp1d(self.speed_frac, ball_particle_min_lifespan, ball_particle_max_lifespan)
end

function _ball:get_particle_size()
  return interp1d(self.speed_frac, ball_particle_min_rad, ball_particle_max_rad)
end

function _ball:update()
  self.parent.update(self)
  for i = 1,5 do
    if rndbool(self.speed_frac) then
      add(self.particles, _ball_particle({
          pos=self:aabb():center(),
          lifespan=self:get_particle_lifespan(),
          vel=jitter_vec2(-self.vel, ball_particle_vel_rand_frac),
          size=self:get_particle_size(),
          young_color=self:get_dark_color(),
          old_color=_dark_grey,
          max_size=ball_particle_max_rad,
          min_size=ball_particle_min_rad,
      }))
    end
  end
end

function _ball:reset()
  self.pos = _vec2(_width / 2 - _spr_width / 2,
                   _height / 2 - _spr_height / 2)
  -- go horizontally to one of the players.
  self.vel = jitter_vec2(_vec2(1, 0), 0.3):unit() * ball_speed_min
  if rndbool() then self.vel.x *= -1 end
  self.speed_frac  = 0
  self.alive = false
  self.last_paddle_hit = nil
end

function _ball:maybe_bounce_off_top_or_bot(aabb)
  assert(aabb)
  if not self:aabb():overlaps(aabb) then return end
  self:aabb_separate(aabb)
  ball.vel.y *= -1
end

function _ball:maybe_bounce_off_paddle(paddle)
  assert(paddle)
  if not self:aabb():overlaps(paddle:aabb()) then return end
  self:aabb_separate(paddle:aabb())
  if self.last_paddle_hit != paddle.player_idx then
    self.speed_frac  = min(1, self.speed_frac + ball_speed_delta)
    self.last_paddle_hit = paddle.player_idx
  end
  local diff = (self:aabb():center() - paddle:aabb():center()):unit()
  diff = jitter_vec2(diff, ball_bounce_rand_frac)
  self.vel = diff * interp1d(self.speed_frac, ball_speed_min, ball_speed_max)

  for i = 1,20 do
    if rndbool(self.speed_frac) then
      add(self.particles, _ball_particle({
            pos=self:aabb():center(),
            lifespan=self:get_particle_lifespan(),
            young_color=_tan,
            old_color=self:get_color(),
            vel=jitter_vec2(self.vel, 2*ball_particle_vel_rand_frac)/2,
            size=self:get_particle_size(),
      }))
    end
  end
  paddle:nudge()
end

function _ball:get_color()
  if self.last_paddle_hit == nil then return _white end
  if self.last_paddle_hit == 0 then return _blue end
  if self.last_paddle_hit == 1 then return _red end
end

function _ball:get_dark_color()
  if self.last_paddle_hit == nil then return _light_grey end
  if self.last_paddle_hit == 0 then return _dark_blue end
  if self.last_paddle_hit == 1 then return _dark_purple end
end

function _ball:draw()
  local aabb = self:aabb()
  local center = self:aabb():center()
  circfill(center.x, center.y, aabb:width()/2, _white)
  circfill(center.x, center.y, aabb:width()/2-1, self:get_color())
end
