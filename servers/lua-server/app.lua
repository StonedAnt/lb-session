local lapis = require("lapis")
local app = lapis.Application()

function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

app:get("/", function()
  sleep(math.random(2))
  return "Welcome to Lua Sever"
end)

return app
