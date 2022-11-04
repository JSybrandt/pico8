-- the camera is 16 tiles wide by 16 tall
_stage = {
  -- stand on this
  ground = {},
  -- flowers and fill
  decorations = {},

  ground_top_left_corner_spr=24,
  ground_top_center_spr=25,
  ground_top_right_corner_spr=26,
  ground_left_side_spr=40,
  ground_fill_spr=41,
  ground_right_side_spr=42,
  ground_bottom_left_corner=58,
  ground_bottom_right_corner=56,

  flowers = {8,9,10, 44},

  scroll_speed = 0.5,

  prev_tile_y = 14,
  curr_tile_y = 14,
  just_changed = false,

  min_tile_y = 6,
  max_tile_y = 15,

  rightmost_tile_x = 0,
}

function _stage:foreach_actor(fn)
  for actors in all({self.ground, self.decorations}) do
    for actor in all(actors) do fn(actor) end end
end

function _stage:filter_actors()
  local fn = function(a)
    return a.pos.x > -_spr_width
  end
  filter(self.ground, fn)
  filter(self.decorations, fn)
end

function _stage:set_scroll_speed(speed)
  self.scroll_speed = speed
  self:foreach_actor(function(a) a.vel.x = -self.scroll_speed end)
end

function _stage:create_actor(y, spr)
  return _actor({
      pos=_vec2(self.rightmost_tile_x, y),
      vel=_vec2(-self.scroll_speed, 0),
      spr=spr,
  })
end

function _stage:get_top_spr()
  if self.prev_tile_y == self.curr_tile_y then
    return self.ground_top_center_spr
  elseif self.prev_tile_y < self.curr_tile_y then
    return self.ground_top_right_corner_spr
  else -- prev_tile_y > self.curr_tile_y
    return self.ground_top_left_corner_spr
  end
end

function _stage:get_side_spr()
  if self.prev_tile_y < self.curr_tile_y then
    return self.ground_right_side_spr
  else -- prev_tile_y > self.curr_tile_y
    return self.ground_left_side_spr
  end
end

function _stage:get_bottom_spr()
  if self.prev_tile_y < self.curr_tile_y then
    return self.ground_bottom_left_corner
  else -- prev_tile_y > self.curr_tile_y
    return self.ground_bottom_right_corner
  end
end

function _stage:maybe_change_curr_tile_y()
  if self.just_changed then
    self.just_changed = false
    return
  else
    self.just_changed = true
  end

  local roll = rnd01()-0.5
  self.curr_tile_y += flr(roll * 6)


  self.curr_tile_y = min(self.max_tile_y, max(self.min_tile_y, self.curr_tile_y))
end

-- Adds new tiles at rightmost_tile_x, and updates rightmost_tile_x,
-- curr_tile_y, and prev_tile_y
function _stage:generate_new_tiles()
  self:maybe_change_curr_tile_y()
  local top_tile_y = min(self.curr_tile_y,self.prev_tile_y)
  local bottom_tile_y = max(self.curr_tile_y,self.prev_tile_y)
  local item_tile_y = top_tile_y - 1

  for i = top_tile_y,17 do
    local spr = self.ground_fill_spr
    if i == top_tile_y then
      spr = self:get_top_spr()
    elseif i < bottom_tile_y then
      spr = self:get_side_spr()
    elseif i == bottom_tile_y then
      spr = self:get_bottom_spr()
    end

    if i <= bottom_tile_y then
      add(self.ground, self:create_actor(i*_spr_height, spr))
    else
      add(self.decorations, self:create_actor(i*_spr_height, spr))
    end
  end

  if rndbool(0.3) then
    local flower_y =  item_tile_y*_spr_height
    local flower_spr = rnd_choose(self.flowers)
    add(self.decorations, self:create_actor(flower_y, flower_spr))
  end

  self.rightmost_tile_x += _spr_width
  self.prev_tile_y = self.curr_tile_y
end

function _stage:draw()
  self:foreach_actor(_actor.draw)
  -- foreach(self.ground, function(a) a:aabb():draw(_red) end)
end

function _stage:update()
  self.rightmost_tile_x -= self.scroll_speed
  _player.pos.x -= self.scroll_speed
  _player.last_pos.x -= self.scroll_speed
  while self.rightmost_tile_x <= _width do
    self:generate_new_tiles()
  end
  self:foreach_actor(_actor.update)
  self:filter_actors()
end
