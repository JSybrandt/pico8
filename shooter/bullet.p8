_bullet = {}
setmetatable(_bullet, _bullet)

function _bullet:__call(params)
  local params = params or {}
  params.width = params.width or 1
  params.height = params.height or 1
  local b = inherit(_bullet, _actor(params))
  b.color = params.color or _white
  return b
end

function _bullet:draw()
  if not self.visible then return end
  pset(self.pos.x, self.pos.y, self.color)
end

function _bullet:update()
  _actor.update(self)
  if not self:is_on_screen() then
     self.alive = false
     self.visible = false
   end
end
