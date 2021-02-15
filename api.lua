local modem = peripheral.find("modem")
local paste = require("paste")
local sha256 = require("sha256")
local returnChannel = math.random(30001,40000)
modem.open(returnChannel)
local updateURL = "https://raw.githubusercontent.com/SkyTheCodeMaster/cc-backup-system/main/startup.lua"
local hash = sha256.pbkdf2(updateURL,updateURL,10):toHex()
local expect = require "cc.expect".expect
local recTable = {}

local function waitOnEventOrTime(event, time)
  expect(1, event, "string")
  expect(2, time, "number")

  local timer = os.startTimer(time)

  while true do
    local ev = table.pack(os.pullEvent())
    if ev[1] == "timer" and ev[2] == timer then
      return
    elseif ev[1] == event then
      return table.unpack(ev, 1, ev.n)
    end
  end
end

local function receive()
  recTable = {}
  while true do
    local result = waitOnEventOrTime("modem_message",10)
    if result then 
      local _,_,_,_,msg = result
      table.insert(recTable,msg) 
    else 
      break 
    end
  end
end

local function parse(file)
  file = file or "logs/skynettnr.sklog"
  local f = fs.open(file,"w")
  f.write(textutils.serialize(recTable))
  f.close()
  return recTable
end

local function transmit(cmd)
  local tbl = {
    hash = hash,
    cmd = cmd,
  }
  modem.transmit(30000,returnChannel,tbl)
  receive()
  return parse()
end

return {
  transmit = transmit,
  returnChannel = returnChannel,
}
