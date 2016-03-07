#!/usr/bin/env luajit
local turbo = require("turbo")

local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)


local latestNumber = "hello"
local writeResponse = function(it)
    return self:write(it)
end

function HelloWorldHandler:get()
    writeResponse("hello")
end

turbo.web.Application({
    {"/hello", HelloWorldHandler}
}):listen(8080)
print("listening on 8080")

turbo.ioloop.instance():start()