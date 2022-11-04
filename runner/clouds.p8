_clouds = {
  particles = {},
  max_size=12,
  min_size=3,
  total_vert_size = _height * 0.4,
  new_cloud_prob = 0.03,
}

function _clouds:rnd_y()
  return interp1d(rnd01(), -self.max_size, self.total_vert_size-self.max_size)
end

function _clouds:rnd_size()
  return interp1d(rnd01(),self.min_size,self.max_size)
end

function _clouds:maybe_new(x)
  local x = x or self.max_size + _width
  if rndbool(self.new_cloud_prob) then
    add(self.particles, {x=x, y=self:rnd_y(), size=self:rnd_size()})
  end
end


function _clouds:init()
  for x = -self.max_size, _width+self.max_size do
      self:maybe_new(x)
      self:maybe_new(x)
  end
end

function _clouds:update()
  self:maybe_new()
  for particle in all(self.particles) do
    if rndbool(_wind:get_amt()/3) then
      particle.x -= 1
    end
  end
  filter(self.particles, function(p) return p.x+p.size>0 end)
end

function _clouds:draw()
  for particle in all(self.particles) do
    circfill(particle.x+1, particle.y+1, particle.size, _light_grey)
    circfill(particle.x, particle.y, particle.size, _white)
  end
end
