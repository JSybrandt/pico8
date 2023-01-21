-- spr_actor --

_spr_actor={}
setmetatable(_spr_actor, _spr_actor)

function _spr_actor:__call(params)
  local params = params or {}
  local a = inherit(_spr_actor, _actor(params))
  a.spr = params.spr or 0
  a.spr_width = params.spr_width or 1
  a.spr_height = params.spr_height or 1
  a.width = a.spr_width * _spr_px_wide
  a.height = a.spr_width * _spr_px_high
  a.flip_x = params.flip_x or false
  a.flip_y = params.flip_y or false
  return a
end

function _spr_actor:draw(params)
  local params = params or {}
  if not self.visible then return end
  local x  = self.pos.x - self.width/2
  local y = self.pos.y - self.height/2
  spr(self.spr, x, y, self.spr_width, self.spr_height, self.flip_x, self.flip_y)
  if _debugging then self:aabb():draw(params.dbg_color) end
end
