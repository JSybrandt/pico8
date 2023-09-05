-- main --
function _init()
  cls()
  generator = _wfc_generator({
    sprites={1,2,3,17,18,19,33,34,35},
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
