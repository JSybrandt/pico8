function tri(x1,y1,x2,y2,x3,y3,color)
  color = color or _white
  line(x1,y1,x2,y2,color)
  line(x2,y2,x3,y3,color)
  line(x3,y3,x1,y1,color)
end

function tri_v2(a, b, c, color)
  return tri(a.x, a.y, b.x, b.y, c.x, c.y, color)
end

function __fill_flat_top_tri(a,b,c,color)
  assert(b.y == c.y)
  assert(a.y <= c.y)
  local inv_ab_slope = (b.x-a.x) / (b.y-a.y)
  local inv_ac_slope = (c.x-a.x) / (c.y-a.y)
  local cursor_ab_x = a.x
  local cursor_ac_x = a.x
  for y = a.y,b.y do
    line(cursor_ab_x,y,cursor_ac_x,y,color)
    cursor_ab_x += inv_ab_slope
    cursor_ac_x += inv_ac_slope
  end
end
function __fill_flat_bot_tri(a,b,c,color)
  assert(a.y == b.y)
  assert(c.y >= a.y)
  local inv_ca_slope = (c.x - a.x) / (c.y - a.y);
  local inv_cb_slope = (c.x - b.x) / (c.y - b.y);
  local cursor_ca_x = c.x;
  local cursor_cb_x = c.x;
  for y = c.y,a.y,-1 do
    line(cursor_ca_x,y,cursor_cb_x,y,color)
    cursor_ca_x -= inv_ca_slope;
    cursor_cb_x -= inv_cb_slope;
  end
end

function trifill_v2(a, b, c, color)
  local a,b,c = unpack(insertion_sort({a, b, c}, function(x) return x.y end))
  -- a is the highest, c is the lowest point
  if a == b then
    return __fill_flat_top_tri(a,b,c,color)
  end
  if b == c then
    return __fill_flat_bot_tri(a,b,c,color)
  end
  -- split the triangle in half with a horizontal line from b to d.
  local d = _vec2(a.x + (b.y - a.y) / (c.y - a.y) * (c.x - a.x), b.y)
  __fill_flat_top_tri(a,b,d,color)
  __fill_flat_bot_tri(d,b,c,color)
end

function trifill(x1,y1,x2,y2,x3,y3,color)
  return trifill_v2(_vec2(x1,y1), _vec2(x2,y2), _vec2(x3,y3), color)
end
