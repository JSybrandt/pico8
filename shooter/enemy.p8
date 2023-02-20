-- enemy --

_enemy = {}
setmetatable(_enemy, _enemy)

function _enemy:__call(params)
  local e = inherit(_enemy, _spr_actor({
    spr = _enemy_spr_1
  }))
  e.trajectory = _trajectory(e, params.steps)
  e.health = params.health or 1
  e.bullets = params.bullets
  e.spawn_bullet_periodic = _periodic(params.shot_interval,
                                      function() e:spawn_bullet() end)
  return e
end


function _enemy:update()
  self.trajectory:update()
  if self.trajectory:is_done() then
    self.alive = false
    self.visible = false
    return
  end
  self.spawn_bullet_periodic:update()
end

function _enemy:damage()
  self.health -= 1
  if self.health <= 0 then
    self.alive = false
    self.visible = false
  end
end

function _enemy:spawn_bullet()
  add(self.bullets, _bullet({
    pos = self.pos,
    vel = _enemy_bullet_vel,
    color = _enemy_bullet_color,
    width = 2,
    height = 2,
  }))
end
