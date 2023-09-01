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
  a.turns = params.turns or 0
  a.scale = params.scale or 1
  return a
end

-- todo: modify aabb by scale

function _spr_actor:draw(params)
  local params = params or {}
  if not self.visible then return end
  draw_spr({spr=self.spr,
            center=self.pos,
            spr_width=self.spr_width,
            spr_height=self.spr_height,
            flip_x=self.flip_x,
            flip_y=self.flip_y,
            scale=self.scale,
            turns=self.turns})

  if _debugging then self:aabb():draw(params.dbg_color) end
end
