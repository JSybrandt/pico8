score_x_margin = 32
score_y_margin = 4
header_margin = 8

title = "<<pong!>>"


function _init()
  dbg_init()
  -- a global place to put actors.
  actors = {}
  particles = {}

  top_wall = _aabb(_vec2(0,-_height+header_margin), _vec2(_width, _height))
  bottom_wall = _aabb(_vec2(0,_height), _vec2(_width, _height))
  left_wall = _aabb(_vec2(-_width-8, 0), _vec2(_width, _height))
  right_wall = _aabb(_vec2(_width+8, 0), _vec2(_width, _height))

  walls = {top_wall, bottom_wall, left_wall, right_wall}

  p0 = _paddle(0)
  p1 = _paddle(1)
  p0_score = 0
  p1_score = 0
  ball = _ball(particles)
  add(actors, p0)
  add(actors, p1)
  add(actors, ball)
end

function _draw()
  cls()
  map(0, 1, -1, header_margin-1, 16, 16)
  foreach(particles, function(a) a:draw() end)
  foreach(actors, function(a) a:draw() end)

  print_centered(p0_score, score_x_margin, score_y_margin, _blue)
  print_centered(p1_score, _width-score_x_margin, score_y_margin, _red)
  print_centered(title, _width/2, score_y_margin, _white)

  if not ball.alive then
    print_centered("p1: ⬆️|⬇️", _width/2, 44, _white)
    print_centered(" p2:  e|d", _width/2, 52, _white)
    print_centered("z to start", _width/2, 80, _white)
  end
end

function _update()
  if btn(_button_x) or btn(_button_o) then
    ball.alive = true
  end

  if not ball.alive then return end

  foreach(actors, function(a) a:update() end)
  foreach(particles, function(a) a:update() end)
  filter(particles, function(a) return a.alive end)

  ball:maybe_bounce_off_paddle(p0)
  ball:maybe_bounce_off_paddle(p1)
  ball:maybe_bounce_off_top_or_bot(top_wall)
  ball:maybe_bounce_off_top_or_bot(bottom_wall)

  -- keep paddles on screen
  for wall in all({top_wall, bottom_wall}) do
    for paddle in all({p0, p1}) do
      if paddle:aabb():overlaps(wall) then
        paddle:aabb_separate(wall)
      end
    end
  end

  if ball:aabb():overlaps(left_wall) then
    p1_score += 1
    sfx(3) -- p1 score
    reset()
  end
  if ball:aabb():overlaps(right_wall) then
    p0_score += 1
    sfx(2) -- p1 score
    reset()
  end
end

function reset()
  ball:reset()
  p0:reset()
  p1:reset()
  clear(particles)
end
