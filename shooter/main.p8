-- main --

function _init()
  player_1 = _player(0)
  player_2 = _player(1)

  steps = {}
  add(steps, {
      cmd = _traj_step_jump,
      pos = _v2(_width/2, -10),
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
  example_enemy = _enemy({steps = steps})
end

function _draw()
  cls()
  player_1:draw()
  player_2:draw()
  example_enemy:draw()
  print(example_enemy.pos)
  print(example_enemy.trajectory.curr_step_idx)
end

function _update()
  player_1:update()
  player_2:update()
  example_enemy:update()

end
