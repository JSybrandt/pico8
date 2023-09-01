-- progress bar --
_progress_bar = {}
setmetatable(_progress_bar, _progress_bar)

function _progress_bar:__call(params)
  local params = params or {}
  local p = inherit({}, _progress_bar)
  p.aabb = params.aabb or _aabb(_v2(), _v2())
  p.vertical = params.vertical or false
  p.display_value = params.display_value or false
  p.fill = params.fill or _red
  p.outline = params.outline or _white
  p.value_color = params.value_color or p.outline
  p.max = max(1, params.max or 100)
  p.fill_incr = tern(p.vertical, p.aabb:height(), p.aabb:width()) / p.max
  p:set_value(params.value or 0)
  return p
end

function _progress_bar:get_value()
  return self.value
end

function _progress_bar:set_value(value)
  self.value = min(self.max, max(0, value))

  if self.vertical then
    self.fill_aabb = _aabb:from_ltrb(
      self.aabb:left(),
      (self.aabb:bottom() - self.fill_incr * self.value),
      self.aabb:right(),
      self.aabb:bottom())
  else
    self.fill_aabb = _aabb:from_ltrb(
      self.aabb:left(),
      self.aabb:top(),
      (self.aabb:left() + self.fill_incr * self.value),
      self.aabb:bottom())
  end
end

function _progress_bar:incr(v)
  local v = v or 1
  self:set_value(self.value+v)
end

function _progress_bar:decr(v)
  local v = v or 1
  self:set_value(self.value-v)
end

function _progress_bar:draw()
  self.fill_aabb:draw_fill(self.fill)
  if self.outline then
    self.aabb:draw(self.outline)
  end
  if self.display_value then
    local pos = self.fill_aabb:center()
    if self.vertical then
      pos.y = self.fill_aabb:top()
      if self.value == self.max or self.value == 0 then
        pos.y -= _text_height / 2 + 1
      end
    else
      pos.x = self.fill_aabb:right()
      if self.value == self.max or self.value == 0 then
        pos.x -= _text_width / 2 + 1
      end
    end
    print_centered(self.value, pos.x, pos.y, self.value_color)
  end
end

