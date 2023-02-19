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
  -- load all of the step_lists that we exported to step_lists.p8
  w.step_lists = {}
  for name, serialized_step_list in pairs(serialized_step_lists) do
      w.step_lists[name] = parse_trajectory_steps(serialized_step_list)
  end
  w.step_list_names = {}
  for name, _ in pairs(w.step_lists) do
      add(w.step_list_names, name)
  end
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
                         wave_number = self.wave_number,
                         step_list = self:rnd_step_list()}))
end

_wave = {}
setmetatable(_wave, _wave)

function _wave:__call(params)
  local w = inherit({}, _wave)
  w.enemies = params.enemies
  w.enemy_bullets = params.enemy_bullets
  w.wave_number = params.wave_number
  w.num_enemies = min(8, ceil(w.wave_number / 2))
  w.enemy_count = 0
  w.step_list = params.step_list
  w.flipped_list= flip_step_list(w.step_list)
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
  add(self.enemies, _enemy({steps=tern(self.enemy_count % 2 == 0, self.step_list, self.flipped_list),
                            health=10,
                            bullets = self.enemy_bullets,
                            shot_interval = 60}))
end
