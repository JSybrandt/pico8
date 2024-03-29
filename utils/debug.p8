-- debug --

-- set to true to enable debugging
-- _debugging = true
_debug_logfile = "logs.txt"

-- prepare the debug environment.
if _debugging then
  -- override the debug logfile.
  printh("", _debug_logfile, true)
end

-- write to the debug logfile
function dbg_log(...)
  if not _debugging then return end
  local args = {...}
  msg = "["..t().."]:"
  for arg in all(args) do
    msg = msg.." "..tostring(arg)
  end
  printh(msg, _debug_logfile)
end

function profile(name, fn)
  local start_stat = stat(1)
  fn()
  local time = stat(1) - start_stat
  if not _debugging then return end
  print(name..": "..time, _white)
  printh(time, name..".profile.txt")
end
