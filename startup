local redrun = require("redrun")
local paste = require("paste")
local id = os.getComputerID()

local function fread(file)
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end

local function fwrite(file,str)
  local f = fs.open(file,"w")
  f.write(str)
  f.close()
end

local function removeROM(tbl)
  for i=1,#tbl do
    if tbl[i] == "rom" then
      tbl[i] = nil
    end
  end
  return tbl
end

local function genString(filepath)
  local path = fs.combine(tostring(id),filepath)
  path = "--" .. path
  return path
end

