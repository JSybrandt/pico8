-- enemy --

_enemy = {}
setmetatable(_enemy, _enemy)

function _enemy:__call(params)
  assert(params)
  assert(params.bullets)
  assert(params.enemy_idx)
  -- described at the bottom of this file
  print(params.enemy_idx)
  local details = _enemy_stats[params.enemy_idx]
  assert(details)
  local step_list = _step_lists[details.steps_name]
  assert(step_list)
  local e = inherit(_enemy, _spr_actor({spr = details.spr}))
  e.trajectory = _trajectory(e, step_list)
  if params.step_list_offset then
    e.trajectory = translate_step_list(e.trajectory, params.step_list_offset)
  end
  if params.flip_step_list then
    e.trajectory = flip_step_list(e.trajectory)
  end
  e.details = details
  e.health = details.max_health
  e.bullets = params.bullets
  e.spawn_bullet_periodic = _periodic(details.bullet_interval,
                                      function() e:spawn_bullet() end)
  e.damaged_last_frame = false
  e.delta_pos = _v2()
  return e
end

function _enemy:spawn_bullet_downward()
  add(self.bullets, _bullet({
    pos = self.pos,
    vel = _v2(0, 1.75),
    color = self.details.bullet_color,
    width = 2,
    height = 2,
  }))
end

function _enemy:update()
  local old_pos = shallow_copy(self.pos)
  self.trajectory:update()
  self.delta_pos = self.pos - old_pos
  if self.delta_pos:l1() > 0 then
    self.turns = self.delta_pos:atan2() + 0.25
  end
  if self.trajectory:is_done() then
    self.alive = false
    self.visible = false
    return
  end
  self.spawn_bullet_periodic:update()
end

function _enemy:damage()
  self.damaged_last_frame = true
  self.health -= 1
  if self.health <= 0 then
    self:die()
  end
end

function _enemy:die()
  self.alive = false
  self.visible = false
end

function _enemy:spawn_bullet()
  if rnd_bool(self.details.bullet_prob) then
    self.details.bullet_fn(self)
  end
end

function _enemy:draw()
  if self.damaged_last_frame then
    self.damaged_last_frame = false
    self:draw_damage()
  else
    self.parent.draw(self)
  end
end

function _enemy:draw_damage()
  for c in all(_colors) do
    if c ~= _black then
      pal(c, _white)
    end
  end
  self.parent.draw(self)
  pal()
end

-- enemy stats
_enemy_stats = {}
add(_enemy_stats, {
    spr = 2,
    steps_name = "top_wave",
    max_health = 3,
    bullet_fn = _enemy.spawn_bullet_downward,
    bullet_color = _red,
    bullet_interval = 40,
    bullet_prob = 1,
})
add(_enemy_stats, {
    spr = 3,
    steps_name = "top_wave",
    max_health = 5,
    bullet_fn = _enemy.spawn_bullet_downward,
    bullet_color = _red,
    bullet_interval = 40,
    bullet_prob = 1,
})
