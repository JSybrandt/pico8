_mountain = {}
setmetatable(_mountain, _mountain)

mountain_peak_spr = 13
mountain_left_slope_spr=28
mountain_fill_spr=29
mountain_right_slope_spr=30

function _mountain:__call(params)
  local instance = inherit({}, _mountain)
  local params = params or {}
  -- pos determines peak, and the other sprites fall from there
  instance.pos = params.pos or _vec2(0,0)
  instance.vel = params.vel or _vec2(0,0)
  instance.sprites = {}

  -- row 1: peak
  add(instance.sprites, _actor({pos=instance.pos, vel=instance.vel,
                                spr=mountain_peak_spr}))
  local num_rows = ceil((_height - instance.pos.y) / _spr_height)
  dbg(num_rows)
  for row_idx = 1,num_rows do
    local y = instance.pos.y + _spr_height * (row_idx)
    local left = instance.pos.x - _spr_width * row_idx
    local num_cols = 1 + 2 * (row_idx)
    for col_idx = 1,num_cols do
      local x = left + _spr_width * (col_idx - 1)
      local spr = mountain_fill_spr
      if col_idx == 1 then spr = mountain_left_slope_spr end
      if col_idx == num_cols then spr = mountain_right_slope_spr end
      add(instance.sprites, _actor({pos=_vec2(x, y), vel=instance.vel,
                                    spr=spr}))
    end
  end
  return instance
end

function _mountain:draw()
  for p in all(self.sprites) do
    p:draw()
  end
end

function _mountain:update()
  for p in all(self.sprites) do
    p:update()
  end
end

function _mountain:translate(delta_pos)
  for p in all(self.sprites) do
    p.pos += delta_pos
  end
end
