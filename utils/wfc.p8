
_wfc_generator = {}
setmetatable(_wfc_generator, _wfc_generator)

function _wfc_generator:__call(params)
  local inst = inherit({}, _wfc_generator)
  -- a list of sprite indices
  inst.sprites = params.sprites or {}
  -- each tile is this # of sprites wide / tall
  inst.tile_spr_width = params.tile_spr_width or 1
  inst.tile_spr_height= params.tile_spr_height or 1
  -- num tile_grid wide
  inst.width = params.width or 0
  -- num tile_grid tall
  inst.height = params.height or 0
  -- the top-left tile's top-left corner is placed here
  inst.offset = params.offset or _v2()

  -- todo: more here.
  inst.spr_constraints = _wfc_spr_constraint_index({
    sprites=inst.sprites,
    tile_spr_width=inst.tile_spr_width,
    tile_spr_height=inst.tile_spr_height})

  -- init tile grid
  inst.tile_grid = {}
  for tile_x = 1,inst.width do
    tile_row = {}
    for tile_y = 1,inst.height do
      offset_x = inst.offset.x + (tile_x-1) * inst.tile_spr_width * _spr_px_wide
      offset_y = inst.offset.y + (tile_y-1) * inst.tile_spr_height * _spr_px_high
      tile_row[tile_y] = _wfc_tile({candidates=inst.sprites,
                                    spr_constraints=inst.spr_constraints,
                                    offset = _v2(offset_x, offset_y),
                                    spr_width=inst.tile_spr_width,
                                    spr_height=inst.tile_spr_height})
    end
    inst.tile_grid[tile_x] = tile_row
  end

  function get_tile(x, y)
    row = inst.tile_grid[x]
    if row == nil then
      return nil
    end
    return row[y]
  end

  -- set neighbors
  for tile_x = 1,inst.width do
    for tile_y = 1,inst.height do
      inst.tile_grid[tile_x][tile_y]:set_neighbors({
          left=get_tile(tile_x-1, tile_y),
          right=get_tile(tile_x+1, tile_y),
          up=get_tile(tile_x, tile_y-1),
          down=get_tile(tile_x, tile_y+1)})
    end
  end
  return inst
end

function _wfc_generator:get_tile_with_min_candidates()
  local min_count = #self.sprites
  local candidates = {}
  for tile_row in all(self.tile_grid) do
    for tile in all(tile_row) do
      if #tile.candidates <= 1 or #tile.candidates > min_count then
        -- pass
      elseif #tile.candidates == min_count then
        add(candidates, tile)
      else
        min_count = #tile.candidates
        candidates = {tile}
      end
    end
  end
  if #candidates == 0 then
    return nil
  end
  return rnd_choose(candidates)
end

function _wfc_generator:generate()
  local tile = self:get_tile_with_min_candidates()
  while tile ~= nil do
    -- print(""..tile.offset.x..", "..tile.offset.y)
    -- print("#candidates: "..#tile.candidates)
    tile:collapse(_set({rnd_choose(tile.candidates:to_list())}))
    tile = self:get_tile_with_min_candidates()
  end
end

function _wfc_generator:draw()
  for tile_row in all(self.tile_grid) do
    for tile in all(tile_row) do
      tile:draw()
    end
  end
end

_wfc_spr_constraint_index = {}
setmetatable(_wfc_spr_constraint_index, _wfc_spr_constraint_index)

function __get_spr_aabb(spr_idx, spr_width, spr_height)
  -- pos and width
  return _aabb(_v2((spr_idx % _spr_sheet_width) * _spr_px_wide,
                   flr(spr_idx / _spr_sheet_width) * _spr_px_high),
               _v2(spr_width * _spr_px_wide, spr_height * _spr_px_high))
end

function __get_edge_key(edge)
  key = ""
  edge:visit_raster_points(function(x,y)
    key = key..tostring(sget(x, y))..","
  end)
  return key
end

function _wfc_spr_constraint_index:__call(params)
  local inst = inherit({}, _wfc_spr_constraint_index)
  inst.sprites = params.sprites
  inst.spr_width = params.tile_spr_width or 1
  inst.spr_height = params.tile_spr_height or 1

  inst.edge_keys_by_spr = {}
  inst.spr_by_edge_key_left = _set()
  inst.spr_by_edge_key_right= _set()
  inst.spr_by_edge_key_top = _set()
  inst.spr_by_edge_key_bottom = _set()

  for spr in all(inst.sprites) do
    edges = __get_spr_aabb(spr, inst.spr_width, inst.spr_height):edges()
    left_key = __get_edge_key(edges[1])
    right_key = __get_edge_key(edges[2])
    top_key = __get_edge_key(edges[3])
    bottom_key = __get_edge_key(edges[4])

    inst.edge_keys_by_spr[spr] = {left = left_key, right = right_key,
                                  top = top_key, bottom = bottom_key}
    inst.spr_by_edge_key_left:insert(left_key)
    inst.spr_by_edge_key_right:insert(right_key)
    inst.spr_by_edge_key_top:insert(top_key)
    inst.spr_by_edge_key_bottom:insert(bottom_key)
  end
  return inst
end
function __set_if_nil(x)
  if x ~= nil then
    return x
  end
  return _set()
end
function _wfc_spr_constraint_index:get_compatible_sprites_left(spr)
  return __set_if_nil(self.spr_by_edge_key_right[self.edge_keys_by_spr[spr].left])
end
function _wfc_spr_constraint_index:get_compatible_sprites_right(spr)
  return __set_if_nil(self.spr_by_edge_key_left[self.edge_keys_by_spr[spr].right])
end
function _wfc_spr_constraint_index:get_compatible_sprites_up(spr)
  return __set_if_nil(self.spr_by_edge_key_bottom[self.edge_keys_by_spr[spr].top])
end
function _wfc_spr_constraint_index:get_compatible_sprites_down(spr)
  return __set_if_nil(self.spr_by_edge_key_top[self.edge_keys_by_spr[spr].bottom])
end



_wfc_tile = {}
setmetatable(_wfc_tile, _wfc_tile)

function _wfc_tile:__call(params)
  local inst = inherit({}, _wfc_tile)
  inst.candidates = _set(params.candidates)
  inst.spr_constraints = params.spr_constraints
  inst.offset = params.offset
  inst.spr_width = params.spr_width or 1
  inst.spr_height = params.spr_height or 1
  return inst
end

function _wfc_tile:set_neighbors(params)
  -- these may be nil
  self.neigh_left = params.left
  self.neigh_right = params.right
  self.neigh_up = params.up
  self.neigh_down = params.down
end

function _wfc_tile:draw()
  local spr_idx = tern(#self.candidates == 1, next(self.candidates.values), 0)
  spr(spr_idx, self.offset.x, self.offset.y, self.spr_width, self.spr_height)
end

function __get_all_compatible_sprites(get_compatible_sprites_fn, candidates)
  local all_candidates = _set()
  for c in pairs(candidates.values) do
    local sprs = get_compatible_sprites_fn(c)
    all_candidates:union(sprs)
  end
  return all_candidates
end

function _wfc_tile:collapse(spr_subset)
  local candidate_subset = self.candidates:intersect(spr_subset)
  if #candidate_subset == #self.candidates then
    -- no update, stop here.
    return
  end
  -- update candidates.
  self.candidates = candidate_subset
  -- We failed to solve this problem.
  if #self.candidates == 0 then
    -- todo: backtrack
    return
  end

  -- propagate updates
  if self.neigh_left ~= nil then
    self.neigh_left:collapse(__get_all_compatible_sprites(
      function(x) return self.spr_constraints:get_compatible_sprites_left(x) end,
      self.candidates))
  end
  if self.neigh_right ~= nil then
    self.neigh_right:collapse(__get_all_compatible_sprites(
      function(x) return self.spr_constraints:get_compatible_sprites_right(x) end,
      self.candidates))
  end
  if self.neigh_up ~= nil then
    self.neigh_up:collapse(__get_all_compatible_sprites(
      function(x) return self.spr_constraints:get_compatible_sprites_up(x) end,
      self.candidates))
  end
  if self.neigh_down ~= nil then
    self.neigh_down:collapse(__get_all_compatible_sprites(
      function(x) return self.spr_constraints:get_compatible_sprites_down(x) end,
      self.candidates))
  end
end
