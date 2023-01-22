-- periodic --

_periodic = {}
setmetatable(_periodic, _periodic)

function _periodic:__call(interval, callback)
  local p = inherit({}, _periodic)
  p.counter = 0
  p.interval = interval
  p.callback = callback
  return p
end

function _periodic:update()
  self.counter += 1
  if self.counter >= self.interval then
    self.callback()
    self.counter = 0
  end
end
