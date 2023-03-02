-- spr_helpers --

_tline_scale = 1/8
_rotate_clip = 1/16

-- draws a sprite, rotated at the center point
function draw_spr(params)
  assert(params)
  local spr_idx = params.spr ; assert(spr)
  local center = params.center ; assert(center)
  local scale = params.scale or 1
  local turns = params.turns or 0
  local spr_width = params.spr_width or 1
  local spr_height = params.spr_height or 1
  local flip_x = params.flip_x or false
  local flip_y = params.flip_y or false

  local px_size = _v2(spr_width*_spr_px_wide*scale-1,
                      spr_height*_spr_px_high*scale-1)
  local lt, lb, rb, rt = unpack(_aabb:from_centered(center, px_size):rotate(turns))
  local lines = { _line(lt, lb), _line(lb, rb), _line(rb, rt), _line(rt, lt) }

  local min_xs = {}
  local max_xs = {}

  for line in all(lines) do
    local dy = line:delta().y
    if dy == 0 then
      local y = flr(line:top())
      min_xs[y] = flr(line:left())
      max_xs[y] = flr(line:right())
    else
      line:visit_raster_points(function(x, y)
        if dy < 0 then
          max_xs[y] = x
        else -- dy > 0
          min_xs[y] = x
        end
      end)
    end
  end

  local screen_lt = lt:flr()
  local spr_lt = _v2((spr_idx % _spr_sheet_width) * _spr_px_wide,
                     flr(spr_idx / _spr_sheet_width) * _spr_px_high)

  local top_y = flr(minimum(lines, function(l) return l:top() end))
  local bot_y = flr(maximum(lines, function(l) return l:bottom() end))

  for y = top_y, bot_y do
    local left_x = min_xs[y]
    local right_x = max_xs[y]
    local px = spr_lt + ((_v2(left_x, y) - screen_lt):rotate(-turns) / scale)
    local px_delta = _v2(1, 0):rotate(-turns) / scale
    for x = left_x, right_x do
      pset(x, y, sget(px.x, px.y))
      px += px_delta
    end
  end
end
