-- main --

function _init()
  players = {}
  player_bullets = {}
  add(players, _player(0, player_bullets))
  -- add(players, _player(1, player_bullets))

  enemies = {}
  enemy_bullets = {}

  wave_spawner = _wave_spawner({enemies = enemies,
                                enemy_bullets = enemy_bullets})
end


function _draw()
  cls()
  foreach(players, _player.draw)
  foreach(enemies, _spr_actor.draw)
  foreach(enemy_bullets, _bullet.draw)

  print("# enemies: "..#enemies, _yellow)
  print("# enemy bullets: "..#enemy_bullets, _yellow)
  print("# player bullets: "..#player_bullets, _yellow)
end

function _update()
  wave_spawner:update()
  foreach(players, _player.update)
  foreach(player_bullets, _bullet.update)
  foreach(enemies, _enemy.update)
  foreach(enemy_bullets, _bullet.update)

  check_actor_point_collisions(enemies, player_bullets, enemy_player_bullet_callback)
  check_actor_point_collisions(players, enemy_bullets, player_enemy_bullet_callback)
  check_actor_actor_collisions(enemies, players, enemy_player_callback)

  filter(enemies, is_alive)
  filter(enemy_bullets, is_alive)
  filter(player_bullets, is_alive)
  filter(players, is_alive)
end

function enemy_player_bullet_callback(enemy, player_bullet)
  enemy:damage()
  player_bullet.alive = false
end

function enemy_player_callback(enemy, player)
  enemy:damage()
  -- player:damage()
end

function player_enemy_bullet_callback(player, enemy_bullet)
  enemy_bullet.alive = false
  -- player:damage()
end

