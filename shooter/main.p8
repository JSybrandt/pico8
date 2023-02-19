-- main --

function _init()
  players = {}
  add(players, _player(0))
  add(players, _player(1))

  -- load all of the step_lists that we exported.
  step_lists = {}
  for name, serialized_step_list in pairs(serialized_step_lists) do
      step_lists[name] = parse_trajectory_steps(serialized_step_list)
  end
  step_list_names = {}
  for name, _ in pairs(step_lists) do
      add(step_list_names, name)
  end

  enemies = {}
  enemy_bullets = {}
end

function rand_step_list()
    return step_lists[rnd(step_list_names)]
end

function _draw()
  cls()
  foreach(players, _player.draw)
  foreach(enemies, _spr_actor.draw)
  foreach(enemy_bullets, _bullet.draw)
  print(#enemies)
  print(#enemy_bullets)
  print(#players)
end

function _update()
  local a = step_lists["sweep"]
  local b = flip_step_list(a)
  local c = translate_step_list(a, _v2(32, 0))
  if t() % 1 == 0 then
    local count = t() % 10
    local steps = translate_step_list(step_lists["downward"], _v2(count*5, 0))
    if count > 5 then
      steps = flip_step_list(steps)
    end
    add(enemies, _enemy({
      steps = steps,
      health = 10,
      bullets = enemy_bullets,
      shot_interval = 60,
    }))
  end
  foreach(players, _player.update)
  foreach(enemies, _enemy.update)
  foreach(enemy_bullets, _bullet.update)

  check_bullet_enemy_collisions()
  check_enemy_player_collisions()
  check_enemy_bullet_player_collisions()
  filter(enemies, is_alive)
  filter(enemy_bullets, is_alive)
  filter(players, is_alive)
end

function check_bullet_enemy_collisions()
  for player in all(players) do
    for bullet in all(player.bullets) do
      local bb = bullet:aabb()
      for enemy in all(enemies) do
        if enemy:aabb():overlaps(bb) then
          enemy:damage()
          bullet.alive = false
        end
      end
    end
  end
end

function check_enemy_player_collisions()
  for player in all(players) do
    local pbb = player:aabb()
    for enemy in all(enemies) do
      if enemy:aabb():overlaps(pbb) then
        player:damage()
      end
    end
  end
end

function  check_enemy_bullet_player_collisions()
  for player in all(players) do
    local pbb = player:aabb()
    for bullet in all(enemy_bullets) do
      if bullet:aabb():overlaps(pbb) then
        player:damage()
      end
    end
  end
end
