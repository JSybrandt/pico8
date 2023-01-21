-- main --

function _init()
  player = _player()
end

function _draw()
  cls()
  player:draw()
end

function _update()
  player:update()
end
