#!/usr/bin/env luajit
local turbo = require("turbo")

local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)


local latestNumber = "hello"
local writeResponse = self:write(latestNumber)

function HelloWorldHandler:get()
    writeResponse()
end

turbo.web.Application({
    {"/hello", HelloWorldHandler}
}):listen(8080)
print("listening on 8080")

turbo.ioloop.instance():start()