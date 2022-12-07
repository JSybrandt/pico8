-- https://owlree.blog/posts/simulating-a-rope.html

function _init()
  dbg_init()

  _wind:init()
  _clouds:init()
  gravity = _vec2(0, 0.25)
  -- flags = {}
  -- flags[1] = _flag({pos = _vec2(25, 50), size = 7, color = _tan, width=7})
  -- flags[2] = _flag({pos = _vec2(50, 40), size = 7, color = _red, width=7})
  -- flags[3] = _flag({pos = _vec2(75, 60), size = 7, color = _dark_purple, width=7})
  _player:reset_pos(_vec2(30,0))

  -- _stage:set_scroll_speed(0)
end


count = 0
function _draw()
  cls(_blue)
  trifill(10,35,50,90,100,75,_orange)
  _clouds:draw()
  _stage:draw()
  -- foreach(flags, _flag.draw)
  _player:draw()

end

function _update()
  count += 1
  _stage:update()
  _wind:update()
  _clouds:update()
  _player:update()
  -- foreach(flags, _flag.update)
end
