_player = {}
setmetatable(_player, _player)

function _player:__call(idx, player_bullets)
  local p = inherit(_player, _spr_actor({
    spr = _player_spr,
    pos = _v2(_width/2, _height*0.9),
  }))
  p.idx = idx or 0
  p.bullets = player_bullets
  p.power_level = 1
  p.shoot_counter = 0
  p.shoot_fns = {}
  add(p.shoot_fns, _player.shoot_l1)
  add(p.shoot_fns, _player.shoot_l2)
  add(p.shoot_fns, _player.shoot_l3)
  add(p.shoot_fns, _player.shoot_l4)
  add(p.shoot_fns, _player.shoot_l5)
  p.shoot_intervals = {}
  add(p.shoot_intervals, _player_shoot_l1_interval)
  add(p.shoot_intervals, _player_shoot_l2_interval)
  add(p.shoot_intervals, _player_shoot_l3_interval)
  add(p.shoot_intervals, _player_shoot_l4_interval)
  add(p.shoot_intervals, _player_shoot_l5_interval)
  p.spawn_bullet_periodic = _periodic(_player_shoot_l1_interval,
                                      function() p:spawn_bullet() end)
  return p
end

function _player:level_up()
  self.power_level = min(self.power_level + 1, #self.shoot_fns)
end

function _player:level_down()
  self.power_level = max(self.power_level - 1, 1)
end

function _player:spawn_bullet()
  self.shoot_counter += 1
  self.shoot_fns[self.power_level](self)
  self.spawn_bullet_periodic:set_interval(self.shoot_intervals[self.power_level])
end

function _player:shoot_l1()
  add(self.bullets, _bullet({pos = self.pos,
                             vel = _player_bullet_vel,
                             color = self:color()}))
end

function _player:shoot_l2()
  local shoot_left = self.shoot_counter % 2 == 0
  local x = self.pos.x + tern(shoot_left,
                              _player_shoot_l2_loffset, _player_shoot_l2_roffset)
  add(self.bullets, _bullet({pos = _v2(x, self.pos.y),
                             vel = _player_bullet_vel,
                             color = self:color()}))
end

function _player:shoot_l3()
  add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l3_loffset, self.pos.y),
                             vel = _player_bullet_vel,
                             color = self:color()}))
  add(self.bullets, _bullet({pos = self.pos,
                             vel = _player_bullet_vel,
                             color = self:color()}))
  add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l3_roffset, self.pos.y),
                             vel = _player_bullet_vel,
                             color = self:color()}))
end

function _player:shoot_l4()
  local local_count = self.shoot_counter % 4
  local pos_delta = _v2()
  local vel_delta = _v2()
  if local_count == 0 then
    pos_delta.x += _player_shoot_l4_loffset
  elseif local_count == 1 then
    vel_delta.x += _player_shoot_l4_vel_l_delta
  elseif local_count == 2 then
    pos_delta.x += _player_shoot_l4_roffset
  else
    vel_delta.x += _player_shoot_l4_vel_r_delta
  end
  add(self.bullets, _bullet({pos = self.pos + pos_delta,
                             vel = _player_bullet_vel + vel_delta,
                             color = self:color()}))
  add(self.bullets, _bullet({pos = self.pos,
                             vel = _player_bullet_vel,
                             color = self:color()}))
end

function _player:shoot_l5()
  local local_count = self.shoot_counter % 2
  if local_count == 0 then
    add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l5_loffset, self.pos.y),
                               vel = _player_bullet_vel,
                               color = self:color()}))
    add(self.bullets, _bullet({pos = self.pos,
                               vel = _player_bullet_vel,
                               color = self:color()}))
    add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l5_roffset, self.pos.y),
                               vel = _player_bullet_vel,
                               color = self:color()}))
  else
    add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l5_loffset, self.pos.y),
                               vel = _player_bullet_vel + _v2(_player_shoot_l5_vel_l_delta, 0),
                               color = self:color()}))
    add(self.bullets, _bullet({pos = _v2(self.pos.x + _player_shoot_l5_roffset, self.pos.y),
                               vel = _player_bullet_vel + _v2(_player_shoot_l5_vel_r_delta, 0),
                               color = self:color()}))
  end
end

-- only the center
function _player:aabb()
  return _aabb(_v2(self.pos.x-2, self.pos.y-2), _v2(3, 3))
end

function _player:update()
  if not self.alive then return end
  if btnp(_button_o, self.idx) then
    self:level_up()
  end
  if btnp(_button_x, self.idx) then
    self:level_down()
  end
  local speed = tern(btn(_fast_btn, self.idx),
                     _player_fast_speed, _player_speed)
  self.pos += read_unit_input(self.idx) * speed
  self:keep_on_screen()

  self.spawn_bullet_periodic:update()
end

function _player:draw()
  _spr_actor.draw(self)
  self:aabb():oval_fill(self:color())
  foreach(self.bullets, _bullet.draw)
end

function _player:color()
  if self.idx == 0 then return _blue end;
  if self.idx == 1 then return _green end;
end

function _player:damage()
  self.alive = false
  self.visible = false
end
