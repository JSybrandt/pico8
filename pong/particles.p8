_ball_particle = {}
setmetatable(_ball_particle, _ball_particle)

function _ball_particle:__call(params)
  local params = params or {}
  local parent = _actor(params)
  local instance = inherit(_ball_particle, parent)
  instance.young_color = params.young_color or _white
  instance.old_color = params.old_color or _dark_grey
  instance.max_size = params.max_size or 1
  instance.min_size = params.min_size or 1
  return instance
end

function _ball_particle:draw()
  local age_frac = self:age_frac()
  local color = ternary(age_frac < 0.5, self.young_color, self.old_color)
  local size = interp1d(age_frac, self.max_size, self.min_size)
  circfill(self.pos.x, self.pos.y, size, color)
end
