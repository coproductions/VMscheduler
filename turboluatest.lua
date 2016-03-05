#!/usr/bin/env luajit
local turbo = require("turbo")

local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)

function HelloWorldHandler:get()
    self:write("Hello World!")
end

turbo.web.Application({
    {"/hello", HelloWorldHandler}
}):listen(8080)
turbo.ioloop.instance():start()
print("listening on 8080")