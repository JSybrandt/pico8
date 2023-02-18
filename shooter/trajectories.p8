-- trajectories --

-- instantly move here
-- args: pos
_traj_step_jump = 0

-- move incrementally here
-- args: pos, speed
_traj_step_move = 1
-- wait in place
-- args: count
_traj_step_wait = 2

_trajectory= {}
setmetatable(_trajectory, _trajectory)

function _trajectory:__call(actor, steps)
  local t = inherit({}, _trajectory)
  t.actor = actor
  t.steps = steps
  t.curr_step_idx = 1
  t.curr_counter = 0
  return t
end

function parse_step_string(step_tuple)
    if step_tuple[1] == _traj_step_jump then
        return {cmd = _traj_step_jump,
                pos=_v2(step_tuple[2], step_tuple[3])}
    elseif step_tuple[1] == _traj_step_move then
        return {cmd = _traj_step_move,
                pos=_v2(step_tuple[2], step_tuple[3]),
                speed=step_tuple[4]}
    elseif step_tuple[1] == _traj_step_wait then
        return {cmd = _traj_step_wait, count = step_tuple[2]}
    end
    -- Invalid step action.
    assert(false)
end

function parse_trajectory_steps(data_str)
    steps = {}
    for step_str in all(split(data_str, ";")) do
        -- split the step_str and convert numbers.
        add(steps, parse_step_string(split(step_str, ",", true)))
    end
    return steps
end

function _trajectory:update()
  if self:is_done() then return end
  self.curr_counter += 1
  local step = self:curr_step()
  if step.cmd == _traj_step_jump then return self:update_jump() end
  if step.cmd == _traj_step_wait then return self:update_wait() end
  if step.cmd == _traj_step_move then return self:update_move() end
  assert(false)
end

function _trajectory:update_jump()
  local step = self:curr_step()
  assert(step.pos)
  self.actor.pos = step.pos
  self:finish_step()
end

function _trajectory:update_move()
  local step = self:curr_step()
  assert(step.pos)
  assert(step.speed)
  local dir = (step.pos - self.actor.pos):unit()
  self.actor.pos += dir * step.speed
  if (self.actor.pos - step.pos):norm() < step.speed then self:finish_step() end
end

function _trajectory:update_wait()
  local step = self:curr_step()
  assert(step.count)
  if self.curr_counter >= step.count then self:finish_step() end
end

function _trajectory:curr_step()
  return self.steps[self.curr_step_idx]
end

function _trajectory:is_done()
  return self.curr_step_idx > #self.steps
end

function _trajectory:finish_step()
  self.curr_step_idx += 1
  self.curr_counter = 0
end

