-- rnd --

function rnd_unit() return rnd(_max_num)/_max_num end

function rnd_bool(frac)
  local frac = frac or 0.5
  return rnd_unit() < frac
end

function rnd_choose(tbl)
  return tbl[flr(rnd01() * #tbl + 1)]
end
