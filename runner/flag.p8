_flag = {}
setmetatable(_flag, _flag)

flag_head_sprite = 27
flag_body_sprite = 43

function _flag:__call(params)
  local instance = inherit(_flag, _rope(params))
  instance.vel = params.vel or _vec2(0,0)
  return instance
end

function _flag:draw()
  spr(flag_head_sprite, self.pos.x, self.pos.y)
  for y = self.pos.y+_spr_height,_height,_spr_height do
    spr(flag_body_sprite, self.pos.x, y)
  end
  self.parent.draw(self)
end

function _flag:update()
  self:translate(self.vel)
  self.acc = _wind:get_acc() + gravity
  self.parent.update(self)
end

function _flag:translate(delta_pos)
  self.pos += delta_pos
  self.parent.translate(self, delta_pos)
end




