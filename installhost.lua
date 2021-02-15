local function hwrite(file,url)
  local h,err = http.get(url)
  if not h then error(err) end
  local f = fs.open(file,"w")
  f.write(h.readAll())
  f.close()
  h.close()
end

local function ensure(file,url)
  if not fs.exists(file) then
    hwrite(file,url)
  end
end

ensure("sha256.lua","https://pastebin.com/raw/6UV4qfNF")
ensure("paste.lua","https://raw.githubusercontent.com/SkyTheCodeMaster/cc-backup-system/main/pastebin.lua")

