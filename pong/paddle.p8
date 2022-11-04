_paddle={}
setmetatable(_paddle, _paddle)

paddle_speed = 4
paddle_x_margin = 12
paddle_nudge_amnt = 5
paddle_max_nudge_time = 4

function _paddle:__call(player_idx)
  assert(player_idx)
  local parent = _actor({sprite = ternary(player_idx==0, 1, 2),
                         width = 1, height = 4})
  local instance = inherit(_paddle, parent)
  instance.player_idx = player_idx
  instance:reset()
  return instance
end

function _paddle:reset()
  self.pos = _vec2(self:get_std_x_pos(),
                   _height / 2 - 2 * _spr_height)
  self.nudge_countdown = 0
end

function _paddle:get_std_x_pos()
  return ternary(self.player_idx==0, paddle_x_margin,
                 _width - paddle_x_margin - _spr_width)
end

function _paddle:get_nudge_offset()
  local nudge_frac = self.nudge_countdown / paddle_max_nudge_time
  local delta = interp1d(nudge_frac, 0, paddle_nudge_amnt)
  delta *= ternary(self.player_idx==0, 1, -1)
  dbg(self.player_idx, delta)
  return delta
end

function _paddle:update()
  self.nudge_countdown = max(0, self.nudge_countdown-1)
  input = read_input_vec2(self.player_idx)
  input.x = 0
  self.vel = input * paddle_speed
  self.pos.x = self:get_std_x_pos() + self:get_nudge_offset()
  self.parent.update(self)
end

function _paddle:nudge()
  if self.nudge_countdown == 0 then
    sfx(ternary(self.player_idx==0,0,1))
  end
  self.nudge_countdown = paddle_max_nudge_time
end
