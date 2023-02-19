_player = {}
setmetatable(_player, _player)

function _player:__call(idx)
  local p = inherit(_player, _spr_actor({
    spr = _player_spr,
    pos = _v2(_width/2, _height*0.9),
  }))
  p.idx = idx or 0
  p.bullets = {}
  p.shoot_left = false
  p.spawn_bullet_periodic = _periodic(_player_shoot_interval,
                                      function() p:spawn_bullet() end)
  return p
end

function _player:spawn_bullet()
  self.shoot_left = not self.shoot_left
  local x = self.pos.x + tern(self.shoot_left,
                              _player_shoot_loffset, _player_shoot_roffset)
  add(self.bullets, _bullet({pos = _v2(x, self.pos.y),
                             vel = _player_bullet_vel,
                             color = self:color()}))
end

-- only the center
function _player:aabb()
  return _aabb(_v2(self.pos.x-2, self.pos.y-2), _v2(3, 3))
end

function _player:update()
  if not self.alive then return end
  local speed = tern(btn(_fast_btn, self.idx),
                     _player_fast_speed, _player_speed)
  self.pos += read_unit_input(self.idx) * speed
  self:keep_on_screen()

  self.spawn_bullet_periodic:update()
  foreach(self.bullets, _bullet.update)
  filter(self.bullets, is_alive)
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
