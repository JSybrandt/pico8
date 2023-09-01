-- main --
function _init()
  cls()
  generator = _wfc_generator({
    sprites={1,2,3,4,5,6,7,8,9},
    width=_width/_spr_px_wide,
    height=_height/_spr_px_high,
  })
  generator:generate()
end

function _draw()
  cls()
  generator:draw()
end

function _update()
end
