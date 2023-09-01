-- an efficient algorithm for detecting when actor aabb overlap a large set of points
-- actors needs to implement :aabb()
-- points needs to expose .pos
function check_actor_point_collisions(actors, points, callback)
  -- split the field into fixed sized gridsquares.
  local grid_size = 16
  local actor_grid = {}
  local actor_aabbs = {}
  -- put each enemy unit in gridsquares that it overlaps.
  for idx, actor in pairs(actors) do
    local aabb = actor:aabb()
    actor_aabbs[idx] = aabb
    for x = aabb:left(), aabb:right(), grid_size do
      local row = flr(x / grid_size)
      if actor_grid[row] == nil then
        actor_grid[row] = {}
      end
      for y = aabb:top(), aabb:bottom(), grid_size do
        local col = flr(y / grid_size)
        if actor_grid[row][col] == nil then
          actor_grid[row][col] = {}
        end
        add(actor_grid[row][col], idx)
      end
    end
  end

  for point in all(points) do
    local row = flr(point.pos.x / grid_size)
    local col = flr(point.pos.y / grid_size)
    if actor_grid[row] ~= nil and actor_grid[row][col] ~= nil then
      for actor_idx in all(actor_grid[row][col]) do
        if actor_aabbs[actor_idx]:contains(point.pos) then
          callback(actors[actor_idx], point)
        end
      end
    end
  end
end

-- checks whether any of the actors in set a collide with set b.
-- actors need to implement :aabb()
-- callback is (a_actor, b_actor)
function check_actor_actor_collisions(a_actors, b_actors, callback)
  local a_aabbs = {}
  for a_idx, a_actor in pairs(a_actors) do
    a_aabbs[a_idx] = a_actor:aabb()
  end
  for b_actor in all(b_actors) do
    local b_aabb = b_actor:aabb()
    for a_idx, a_aabb in pairs(a_aabbs) do
      if b_aabb:overlaps(a_aabb) then
        callback(a_actors[a_idx], b_actor)
      end
    end
  end
end
