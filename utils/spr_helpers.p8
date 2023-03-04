-- spr_helpers --

-- draws a sprite, rotated at the center point
function draw_spr(params)
  assert(params)
  local spr_idx = params.spr ; assert(spr)
  local center = params.center ; assert(center)
  local scale = params.scale or 1
  local turns = params.turns or 0
  local spr_width = params.spr_width or 1
  local spr_height = params.spr_height or 1

  local lines = rotated_rect_edges(
    center, --[[width--]]spr_width*_spr_px_wide*scale,
    --[[height--]]spr_height*_spr_px_high*scale, turns)

  -- min/max x coord per y horizontal line.
  local min_xs = {}
  local max_xs = {}
  for line in all(lines) do
    -- positive if the line goes "down" from head to tails.
    local dy = line.tail.y - line.head.y
    if dy == 0 then
      local y = line:top()
      min_xs[y] = line:left()
      max_xs[y] = line:right()
    else
      xs = tern(dy < 0, max_xs, min_xs)
      line:visit_raster_points(function(x, y) xs[y] = x end)
    end
  end

  -- its too expensive to use _v2 of even call a function in this inner loop.
  local screen_x, screen_y, spr_l, spr_t, spr_r, spr_b, spr_w, spr_h, px, py, sn, cn, pdx, pdy
  -- origin of screen px
  screen_x = lines[1].head.x; screen_y = lines[1].head.y
  -- bounds of the sprite, we need these to make sure we stay in bounds below
  spr_l = (spr_idx % _spr_sheet_width) * _spr_px_wide
  spr_t = flr(spr_idx / _spr_sheet_width) * _spr_px_high
  spr_w = spr_width * _spr_px_wide
  spr_h = spr_height * _spr_px_high
  spr_r = spr_l + spr_w - 1
  spr_b = spr_t + spr_h - 1
  -- idx of next color to draw
  px = 0; py = 0
  sn = sin(-turns) ;cn = cos(-turns)
  -- amt to move px after drawing each pixel
  pdx = cn / scale ; pdy = sn / scale
  for y, left_x in pairs(min_xs) do
    local right_x = max_xs[y]
    -- px is now the relative offset based on screen origin
    px = (left_x - screen_x) / scale; py = (y - screen_y) / scale
    -- rotate and reposition offset to spr sheet
    px, py = (px * cn - py * sn) + spr_l, (px * sn + py * cn) + spr_t
    for x = left_x, right_x do
      -- adjust px values in case floating point error lands us outside of the
      -- sprite.
      local npx, npy
      npx = px; npy = py
      if npx < spr_l then npx = spr_l
      elseif npx > spr_r then npx = spr_r end
      if npy < spr_t then npy = spr_t
      elseif npy > spr_b then npy = spr_b end

      -- actually draw a sprite!
      pset(x, y, sget(npx, npy))
      -- move px by the increment
      px += pdx; py += pdy
    end
  end
end

function rotated_rect_edges(center, width, height, turns)
  -- this looks like butt for performance reasons.
  local cx, cy, sn, cn, hw, hh, lt, lb, rt, rb
  cx = center.x; cy = center.y
  sn = sin(turns); cn = cos(turns)
  hw = width/2; hh = height/2
  lt = _v2(flr(((-hw)*cn-(-hh)*sn)+cx),
           flr(((-hw)*sn+(-hh)*cn)+cy))
  lb = _v2(flr(((-hw)*cn-( hh)*sn)+cx),
           flr(((-hw)*sn+( hh)*cn)+cy))
  rt = _v2(flr((( hw)*cn-(-hh)*sn)+cx),
           flr((( hw)*sn+(-hh)*cn)+cy))
  rb = _v2(flr((( hw)*cn-( hh)*sn)+cx),
           flr((( hw)*sn+( hh)*cn)+cy))
  return {_line(lt, lb), _line(lb, rb), _line(rb, rt), _line(rt, lt)}
end
