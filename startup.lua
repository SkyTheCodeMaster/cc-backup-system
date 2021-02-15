local redrun = require("redrun")
local paste = require("paste")
local sha256 = require("sha256")
local id = os.getComputerID()
local updateURL = "https://raw.githubusercontent.com/SkyTheCodeMaster/cc-backup-system/main/startup.lua"
local hash = sha256.pbkdf2(updateURL,updateURL,100):toHex()
local modem = peripheral.find("modem")
if not modem then print("modem not found!") end
if modem then modem.open(30000) end

local function fread(file)
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end
  
local function hread(url)
  local h,err = http.get(url)
  if not h then return nil,err end
  local contents = h.readAll()
  h.close()
  return contents
end

local function fwrite(file,str)
  local f = fs.open(file,"w")
  f.write(str)
  f.close()
end

local function removeROM(tbl) -- this will also remove any folders labelled "hidden"
  for i=1,#tbl do
    if tbl[i] == "rom" or tbl[i] == "hidden" then
      table.remove(tbl,i)
    end
  end
  return tbl
end

local function genString(filepath)
  local path = fs.combine(tostring(id),filepath)
  path = "--" .. path .. "\n"
  return path
end
  
local function combine(a,b) -- combine 2 tables
  for i=1, #a, 1 do b[#b+1]=a[i] end
  return b
end

local function addIdentification(file)
  local contents = fread(file)
  contents = genString(filepath) .. contents
  fwrite(file,contents)
end
  
local function recurseList(path)
  local files = removeROM(fs.list(path))
  local returnTbl = {}
  for i=1,#files do
    if fs.isDir(fs.combine(path,files[i])) then
      combine(recurseList(fs.combine(path,files[i])),returnTbl)
    else
      table.insert(returnTbl,fs.combine(path,files[i]))
    end
  end
  return returnTbl
end   

local function main()
  while true do
    if modem then
      local _,_,_,reply,msg = os.pullEvent("modem_message")
      if type(msg) == "table" then
        if msg.hash == hash and msg.cmd == "backupinit" then
          local files = recurseList(".")
          local ids = {}
          for i=1,#files do
            addIdentification(files[i])
            local id = paste.put(fread(files[i]),files[i])
            table.insert(ids,id)
          end
          modem.transmit(reply,30000,ids)
        elseif msg.hash == hash and msg.cmd == "locate" then
          local x,y,z = gps.locate(5)
          local tbl = {}
          if x then
            tbl = {
              x = x,
              y = y,
              z = z,
              id = id,
            }
          else
            tbl = {
              err = "unable to locate",
              id = id,
            }
          end
          modem.transmit(reply,30000,tbl)
        elseif msg.hash == hash and msg.cmd == "update" then
          local contents,err = hread(updateURL)
          if err then modem.transmit(reply,30000,{
            err = err,
            id = id,
          }) end
          if not err then
            fs.delete("startup")
            fwrite("startup",contents)
            modem.transmit(reply,30000,{
              success = true,  
              id = id,
            })
            os.reboot()
          end
        end
      end
    end
  end
end
_G.Skynet = {
  id = id,
  redrunPID = redrun.start(main,"bg"),
  redrun = redrun,
  paste = paste,
  sha256 = sha256,
}
if fs.exists("startup.bak") then
  shell.run("startup.bak")
elseif fs.exists("startup.lua") then
  shell.run("startup.lua")
end
