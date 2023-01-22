-- main --

function _init()
  players = {}
  add(players, _player(0))
  add(players, _player(1))

  steps = {}
  add(steps, {
      cmd = _traj_step_jump,
      pos = _v2(_width*0.2, -10),
  })
  add(steps, {
      cmd = _traj_step_move,
      pos = _v2(_width/2, _height/2),
      speed = 0.5,
  })
  add(steps, {
      cmd = _traj_step_wait,
      count = 60,
  })
  add(steps, {
      cmd = _traj_step_move,
      pos = _v2(10, _height*0.9),
      speed = 1,
  })
  add(steps, {
      cmd = _traj_step_wait,
      count = 20,
  })
  add(steps, {
      cmd = _traj_step_move,
      pos = _v2(10, _height*1.2),
      speed = 1,
  })
  enemies = {}
  enemy_bullets = {}
end

function _draw()
  cls()
  foreach(players, _player.draw)
  foreach(enemies, _spr_actor.draw)
  foreach(enemy_bullets, _bullet.draw)
end

function _update()
  if t() % 2 == 0 then
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
