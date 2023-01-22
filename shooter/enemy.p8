-- enemy --

_enemy = {}
setmetatable(_enemy, _enemy)

function _enemy:__call(params)
  local e = inherit(_enemy, _spr_actor({
    spr = _enemy_spr_1
  }))
  e.trajectory = _trajectory(e, params.steps)
  return e
end


function _enemy:update()
  self.trajectory:update()
  if self.trajectory:is_done() then
    self.alive = false
    self.visible = false
  end
end

