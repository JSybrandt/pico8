_bullet = {}
setmetatable(_bullet, _bullet)

function _bullet:__call(params)
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
  if self.pos.x < 0 or
     self.pos.x > _width or
     self.pos.y < 0 or
     self.pos.y > _height then
     self.alive = false
     self.visible = false
   end
end
