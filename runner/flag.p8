_flag = {}
setmetatable(_flag, _flag)

flag_head_sprite = 27
flag_body_sprite = 43

function _flag:__call(params)
  return inherit(_flag, _rope(params))
end

function _flag:draw()
  spr(flag_head_sprite, self.pos.x, self.pos.y)
  for y = self.pos.y+_spr_height,_height,_spr_height do
    spr(flag_body_sprite, self.pos.x, y)
  end
  self.parent.draw(self)
end

function _flag:update()
  self.acc = _wind:get_acc() + gravity
  self.parent.update(self)
end




