-- main --


scene_1 = {1,2,3,17,18,19,33,34,35}
scene_2 = {6, 7, 8, 9, 10,
           22,23,24,25,26,
           38,39,40,41,42}

function _init()
  cls()
  generator = _wfc_generator({
    sprites= scene_2,
    width=_width/_spr_px_wide,
    height=_height/_spr_px_high,
  })
  generator:generate()
end

function _draw()
  cls()
  generator:draw()
  extcmd("screen")
  stop()
end

function _update()
end
