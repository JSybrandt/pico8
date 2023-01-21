_mountain = {}
setmetatable(_mountain, _mountain)

function _mountain:__call(params)
  local instance = inherit({}, _mountain)
  local params = params or {}
  instance.width = params.width or interp1d(rnd01(), 50, 150)
  instance.height = params.height or interp1d(rnd01(), 50, 100)
  instance.pos = params.pos or _vec2(_width + instance.width / 2, 0)
  instance.vel = params.vel or _vec2(-1, 0)
  return instance
end

function _mountain:draw()
  local a = _vec2(self.pos.x, _height-self.height)
  local b = _vec2(self.pos.x-self.width/2, _height)
  local c = _vec2(self.pos.x+self.width/2, _height)
  trifill_v2(a,b,c,_dark_blue)
  local peak_height = 10
  local peak_width = self.width/self.height * peak_height
  local d = _vec2(self.pos.x+peak_width/2, _height-self.height+peak_height)
  local e = _vec2(self.pos.x-peak_width/2, _height-self.height+peak_height)
  trifill_v2(a,d,e,_light_grey)
  local f = a + _vec2(0, peak_height*0.75)
  trifill_v2(f,d,e,_dark_blue)
  tri_v2(f,d,e,_dark_blue)
end

function _mountain:update()
  self.pos += self.vel
end

function _mountain:translate(delta_pos)
  self.pos.x += delta_pos.x
end
