-- waves --
-- sends increasingly difficult enemy patterns at the player.

_wave_spawner = {}
setmetatable(_wave_spawner, _wave_spawner)

function _wave_spawner:__call(params)
  local w = inherit({}, _wave_spawner)
  w.enemies = params.enemies
  w.enemy_bullets = params.enemy_bullets
  w.waves = {}
  w.wave_number = 0
  w.new_wave_periodic = _periodic(_wave_spawner_interval,
                                  function() w:start_new_wave() end)
  return w
end

function _wave_spawner:rnd_step_list()
  local name = rnd(self.step_list_names)
  dbg_log(name)
  return self.step_lists[name]
end

function _wave_spawner:update()
  self.new_wave_periodic:update()
  foreach(self.waves, _wave.update)
  filter(self.waves, is_alive)
end

function _wave_spawner:start_new_wave()
  self.wave_number += 1
  add(self.waves, _wave({enemies = self.enemies,
                         enemy_bullets = self.enemy_bullets,
                         wave_number = self.wave_number}))
end

_wave = {}
setmetatable(_wave, _wave)

function _wave:__call(params)
  local w = inherit({}, _wave)
  w.enemies = params.enemies
  w.enemy_bullets = params.enemy_bullets
  w.wave_number = params.wave_number
  w.num_enemies = w.wave_number
  w.enemy_count = 0
  w.enemy_idx = w.wave_number
  w.alive = true
  local spawn_timer = _wave_alive_time / w.num_enemies
  w.spawn_periodic = _periodic(spawn_timer, function() w:spawn_enemy() end)
  w.die_periodic = _periodic(_wave_alive_time, function() w.alive = false end)
  return w
end

function _wave:update()
  self.spawn_periodic:update()
  self.die_periodic:update()
end

function _wave:spawn_enemy()
  self.enemy_count += 1
  add(self.enemies, _enemy({enemy_idx = self.enemy_idx,
                            bullets = self.enemy_bullets}))
end
