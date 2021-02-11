-- This is a simple utility to install this repository onto a computer

if not fs.exists("redrun.lua") then
  local f = fs.open("redrun.lua","w")
  local h,err = http.get("https://gist.githubusercontent.com/MCJack123/473475f07b980d57dd2bd818026c97e8/raw/74d412696e1993e9d9ac664e7247cb534261ac13/redrun.lua")
  if not h then error(err) end
  f.write(h.readAll())
  f.close()
  h.close()
end

-- move `startup` to another file if it exists
if fs.exists("startup") then
  fs.move("startup","startup.bak")
end

-- begin grabbing files from this repository
-- soon:tm:
