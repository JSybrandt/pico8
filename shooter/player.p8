_player = {}
setmetatable(_player, _player)

function _player:__call(idx)
  local p = inherit(_player, _spr_actor({
    spr = _player_spr,
    pos = _v2(_width/2, _height*0.9),
  }))
  p.idx = idx or 0
  p.bullets = {}
  p.shoot_counter = 0
  p.shoot_left = false
  return p
end

-- only the center
function _player:aabb()
  return _aabb(_v2(self.pos.x-1, self.pos.y-1), _v2(1, 1))
end

function _player:update()
  if not self.alive then return end
  local speed = tern(btn(_fast_btn, self.idx), _player_fast_speed, _player_speed)
  self.pos.x += get_x_input(self.idx) * speed
  local half_w = self.width / 2
  local l = self.pos.x - half_w
  local r = self.pos.x + half_w
  if l < 0 then self.pos.x -= l end
  if r > _width then self.pos.x -= r-_width end

  self.shoot_counter += 1
  if self.shoot_counter >= _player_shoot_interval then
    self.shoot_counter = 0
    self.shoot_left = not self.shoot_left
    local x = self.pos.x + tern(self.shoot_left, _player_shoot_loffset, _player_shoot_roffset)
    add(self.bullets, _bullet({
      pos = _v2(x, self.pos.y),
      vel = _player_bullet_vel,
    }))
  end

  foreach(self.bullets, _bullet.update)
  filter(self.bullets, function(b) return b.alive end)
end

function _player:draw()
  _spr_actor.draw(self)
  foreach(self.bullets, _bullet.draw)
end

function get_x_input(idx)
  local idx = idx or 0
  if btn(_up, idx) then return 0.5 end
  if btn(_down, idx) then return -0.5 end
  if btn(_left, idx) then return -1 end
  if btn(_right, idx) then return 1 end
  return 0
end

