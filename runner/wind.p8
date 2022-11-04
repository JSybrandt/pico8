_wind = {}

function _wind:init()
  self.count = 0
  self.amts = {}
  for i = 1,6 do
    self.amts[i] = rnd01()
  end
end

function _wind:update()
  self.count += 1
  self.count %= 1 << #self.amts
  for i = 1,#self.amts do
    local map = 1 << (i-1)
    if self.count & map != 0 then
      self.amts[i] = rnd01()
      return
    end
  end
end

function _wind:get_amt()
  local sum = 0
  local weights = 0
  for i = 1,#self.amts do
    weights += i
    sum += self.amts[i] * i
  end
  return sum / weights
end

function _wind:get_acc()
  return (_vec2(-1, 0) * self:get_amt() * 0.8) + _vec2:random_unit() * 0.2
end
