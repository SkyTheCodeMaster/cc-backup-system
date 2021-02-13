--- Provides a pastebin api to interact with pastebin without using the pastebin shell command.
--
-- @module cc.http.pastebin
-- @usage get a string from pastebin
--     local pastebin = require "cc.http.pastebin"
--     local paste = pastebin.get("V7F7BPPM")
--     print(paste)
--
-- @usage put a string on pastebin
--     local pastebin = require "cc.http.pastebin"
--     local paste = "This is a string that will be put on pastebin!"
--     local id = pastebin.put(paste)
--     print(id)

local function extractId(paste)
    local patterns = {
        "^([%a%d]+)$",
        "^https?://pastebin.com/([%a%d]+)$",
        "^pastebin.com/([%a%d]+)$",
        "^https?://pastebin.com/raw/([%a%d]+)$",
        "^pastebin.com/raw/([%a%d]+)$",
    }

    for i = 1, #patterns do
        local code = paste:match(patterns[i])
        if code then return code end
    end

    return nil
end

--- get retrieves the paste from pastebin
-- @tparam string id The paste id that you want to download.
-- @treturn string|nil The string containing the paste, or nil.
-- @treturn nil|string The reason why it couldn't be retrieved.
local function get(url)
    local paste = extractId(url)
    if not paste then
        return nil, "invalid"
    end
    -- Add a cache buster so that spam protection is re-checked
    local cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
    local response, err = http.get(
        "https://pastebin.com/raw/" .. textutils.urlEncode(paste) .. "?cb=" .. cacheBuster
    )

    if response then
        -- If spam protection is activated, we get redirected to /paste with Content-Type: text/html
        local headers = response.getResponseHeaders()
        if not headers["Content-Type"] or not headers["Content-Type"]:find("^text/plain") then
            return nil, "captcha"
        end

        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        return nil, err
    end
end

--- puts a string onto pastebin
-- @tparam string string The string that you want to put on pastebin.
-- @tparam[opt] string name The name of the paste, defaults to "CC:T Paste".
-- @treturn string|nil A string containing the id of the paste.
local function put(sText, sName)
  sName = sName or "CC:T Paste"
  -- Upload a file to pastebin.com

   -- POST the contents to pastebin
  local key = "c0c823486cd22b8042775c0009c5ce62"
  local response = http.post(
    "https://pastebin.com/api/api_post.php",
    "api_option=paste&" ..
    "api_dev_key=" .. key .. "&" ..
    "api_paste_format=lua&" ..
    "api_paste_name=" .. textutils.urlEncode(sName) .. "&" ..
    "api_paste_code=" .. textutils.urlEncode(sText)
  )

  if response then

    local sResponse = response.readAll()
    response.close()

    local sCode = string.match(sResponse, "[^/]+$")
    return sCode
  else
    return nil
  end
end

return {
  get = get,
  put = put,
}
