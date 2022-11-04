_player = {
  stand_spr = 1,
  look_down_spr = 7,
  look_up_spr = 6,

  spr = 1,
  pos = _vec2(0,0),
  last_pos = _vec2(0,0),

  aabb_size = _vec2(3,5),
  aabb_offset = _vec2(2,2),

  tail = _rope({size=4, color=_dark_blue}),
  tail_offset = _vec2(2,4),
  tail_acc_x = 2,
  tail_acc_y = -1,

  max_x_speed = 2,
  walk_acc = 1,
  max_y_speed = 6,
  jump_acc = 6,
  friction= 0,

  air_friction = 0.1,
  ground_friction = 0.4,

  facing_left = false,
  run_spr_start= 2,
  run_spr_end = 5,
  run_count = 0,
  run_count_per_frame = 2.5,

  -- works out to 3 blocks
  jump_spr = 17,

  -- state
  is_on_ground = false,

}

function _player:reset_pos(pos)
  self.pos = pos
  self.last_pos = pos
  self.spr = self.stand_spr
  self.tail:reset_pos(self:get_tail_pos())
end

function _player:get_tail_pos()
  local offset = self.aabb_offset + self.tail_offset
  return self.pos + offset
end

function _player:draw()
  self.tail:draw()
  spr(self.spr, self.pos.x, self.pos.y, 1, 1, self.facing_left)
  -- self:aabb():draw()
end

-- returns [-1, 1].
function _player:get_x_acc()
  local input_x = 0
  if btn(_right) then
    input_x += 1
    self.facing_left = false
  end
  if btn(_left) then
    input_x -= 1
    self.facing_left = true
  end
  return input_x * self.walk_acc
end

-- return [0, 1]
function _player:get_y_input()
  if not self.is_on_ground then return 0 end
  if btnp(_button_x) or btnp(_button_o) then return -self.jump_acc end
  return 0
end

function _player:get_acc()
  return _vec2(self:get_x_acc(), self:get_y_input()) + gravity
end

function _player:get_spr(input_x)
  -- if self.pos.y != self.floor then return self.jump_spr end
  if(input_x == 0) then
    self.run_count = 0
    if btn(_up) then return self.look_down_spr end
    if btn(_down) then return self.look_up_spr end
    return self.stand_spr
  end
  local num_run_spr = self.run_spr_end - self.run_spr_start + 1
  self.run_count += input_x
  return self.run_spr_start + flr(self.run_count / self.run_count_per_frame) % num_run_spr
end

function _player:vertlet_step(acc, friction)
  local init_pos = self.pos:copy()
  -- verlet step.
  self.pos += self:vel() * (1-friction) + acc
  self.last_pos = init_pos
end

function _player:vel() return self.pos - self.last_pos end

function _player:apply_max_speed_constraint()
  local vel = self:vel()
  vel.x = max(min(vel.x, self.max_x_speed), -self.max_x_speed)
  vel.y = max(min(vel.y, self.max_y_speed), -self.max_y_speed)
  self.pos = self.last_pos + vel
end

function _player:update()
  local acc = self:get_acc()
  local init_pos = self.pos:copy()
  self:vertlet_step(acc, self.friction)
  self:apply_max_speed_constraint()
  self.spr = _player:get_spr(acc.x)
  local desired_pos = self.pos:copy()

  self:reset_frame_state()

  -- Only move horizontally.
  self.pos = _vec2(desired_pos.x, init_pos.y)
  for ground in all(_stage.ground) do
    local ground_aabb = ground:aabb()
    if self:aabb():overlaps(ground_aabb) then
      self:aabb_separate_x(ground_aabb)
    end
  end
  -- Now move vertically.
  self.pos.y = desired_pos.y
  for ground in all(_stage.ground) do
    local ground_aabb = ground:aabb()
    if self:aabb():overlaps(ground_aabb) then
      self:aabb_separate_y(ground_aabb, {top=self.on_ground_callback})
    end
  end


  -- update tail
  self.tail.acc = _wind:get_acc() + _vec2(self.tail_acc_x * ternary(self.facing_left, 1, -1), self.tail_acc_y)
  self.tail.pos = self:get_tail_pos()
  self.tail:update()
end

function _player:aabb()
  return _aabb(self.pos+self.aabb_offset, self.aabb_size)
end

function _player:aabb_separate(...)
  _actor.aabb_separate(self, ...)
end

function _player:aabb_separate_x(...)
  _actor.aabb_separate_x(self, ...)
end

function _player:aabb_separate_y(...)
  _actor.aabb_separate_y(self, ...)
end

function _player:on_ground_callback()
  _player.is_on_ground = true
  _player.friction = _player.ground_friction
end

function _player:reset_frame_state()
  _player.is_on_ground = false
  _player.friction = _player.air_friction
end
