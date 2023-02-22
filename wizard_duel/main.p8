-- main --

_max_time_per_player = 10
_max_health = 10

function _init()
  p1 = {}
  p2 = {}
  p1_color = _blue
  p2_color = _green
  player_turn = 1
  curr_time = -1
  local pbar_width = 6
  local pbar_margin = 32
  p1_health_bar = _progress_bar({
      aabb = _aabb(_v2(0, pbar_margin), _v2(pbar_width, _height-2*pbar_margin)),
      vertical = true,
      fill = p1_color,
      outline = _white,
      max = _max_health,
      value = _max_health,
      display_value = true,
  })

  p2_health_bar = _progress_bar({
      aabb = _aabb(_v2(_width-pbar_width-1, pbar_margin), _v2(pbar_width, _height-2*pbar_margin)),
      vertical = true,
      fill = p2_color,
      outline = _white,
      max = _max_health,
      value = _max_health,
      display_value = true,
  })

  msg = ""

  cursor = 1
  spells = {}
  add(spells, {
      name = "fireball",
      desc = "2 dmg",
      fn = cast_fireball,
      cost = 5,
  })
  add(spells, {
      name = "magic missle",
      desc = "1 dmg",
      fn = cast_magic_missle,
      cost = 3,
  })
  add(spells, {
      name = "wait",
      desc = "nothing",
      fn = cast_wait,
      cost = 1,
  })
end

function _draw()
  cls()
  --rect(0,0,_width-1,_height-1, _white)
  draw_turn_line()
  p1_health_bar:draw()
  p2_health_bar:draw()
  draw_spells()
  print_centered(msg, _width/2, 32, _white)
end

function _update()
  if btnp(_up, active_player()) then
    cursor_decr()
  end
  if btnp(_down, active_player()) then
    cursor_incr()
  end
  if btnp(_button_o, active_player()) then
    msg = player_name(active_player()).." cast "..spells[cursor].name
    spells[cursor].fn()
    spend_time(spells[cursor].cost, active_player())
    cursor = 1
  end
end

function player_color(p_idx)
  return tern(p_idx == _p1, p1_color, p2_color)
end

function active_player()
  return tern(curr_time < 0, _p1, _p2)
end

function inactive_player()
  return tern(active_player() == _p1, _p2, _p1)
end

function player_name(p_idx)
  return tern(p_idx == _p1, "player 1", "player 2")
end

function spend_time(amt, player_idx)
  if player_idx == _p2 then
    amt *= -1
  end
  curr_time = max(-_max_time_per_player, min(_max_time_per_player, curr_time+amt))
  if curr_time == 0 then
    if player_idx == _p1 then
      curr_time += 1
    else
      curr_time -= 1
    end
  end
end

function deal_damage(player_idx, amt)
  if player_idx == _p1 then
    p1_health_bar:decr(amt)
  else
    p2_health_bar:decr(amt)
  end
end


function draw_turn_line()
  local half_width = _width / 2
  local h_margin = 4
  local v_margin = 4
  local minor_tick_height = 4
  local left = h_margin
  local right = _width - h_margin
  local top = v_margin
  local bottom = top + minor_tick_height
  local y = (top + bottom) / 2
  local interval = (right - left) / (_max_time_per_player * 2)

  line(left, y, half_width, y, p1_color)
  for x = left, half_width-interval, interval do
    line(x, top, x, bottom, p1_color)
  end

  line(half_width, y, right, y, p2_color)
  for x = half_width+interval, right, interval do
    line(x, top, x, bottom, p2_color)
  end

  local rad = 2
  circfill(half_width, y, rad, _dark_grey)

  local x = (curr_time + _max_time_per_player)*interval + h_margin
  line(x, top-1, x, bottom+1, _white)

  local text_y = bottom + _text_height + 1
  if curr_time ~= 0 then
    print_centered(abs(curr_time), x, text_y, tern(curr_time < 0, p1_color, p2_color))
  end
end

function cast_fireball()
  deal_damage(inactive_player(), 3)
end

function cast_magic_missle()
  deal_damage(inactive_player(), 1)
end

function cast_wait()
end

function cursor_incr()
  cursor = min(#spells, cursor+1)
end

function cursor_decr()
  cursor = max(1, cursor-1)
end

function draw_spells()
  local aabb = _aabb:from_ltrb(16, _height/2, _width-16, _height-8)
  local v_inc = aabb:height() / #spells
  for i = 1,#spells do
    local box = _aabb:from_ltrb(aabb:left(),
                                aabb:top() + (i-1)*v_inc,
                                aabb:right(),
                                aabb:top() + i*v_inc)
    box:draw(_white)
    local margin = 4
    print_left_justified(spells[i].name,
                         box:left()+margin,
                         box:top()+2,
                         _white)
    print_right_justified(spells[i].desc,
                          box:right()-margin,
                          box:bottom()-_text_width - 2,
                          _white)
    if cursor == i then
     trifill(
       box:left() - 3,
       box:top()+2,
       box:left() + 3,
       box:center().y,
       box:left() - 3,
       box:bottom()-2,
       player_color(active_player())
      )
    end
  end
end

