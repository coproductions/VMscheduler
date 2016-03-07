#!/usr/bin/env luajit
local turbo = require("turbo")

--test_scheduler.lua
package.path = "./?.lua;"..package.path

local myScheduler = require("myScheduler")()

-- local myTask = require("myTask")

local Kernel = require("myKernel")({Scheduler = myScheduler})()



local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)


local latestNumber = "hello from latest"
local function writeResponse(self)
    self:write(latestNumber)
end

function HelloWorldHandler:get()
    writeResponse(self)
    self:write("second Response")
end

turbo.web.Application({
    {"/hello", HelloWorldHandler}
}):listen(8080)
print("listening on 8080")

turbo.ioloop.instance():start()

local function main()
  local t0 = spawn(writeResponse)
  t0.priority = 2
  latestNumber = "Michigan"
  local t1 = spawn(writeResponse)
  t1.priority = 2
  latestNumber = "hello some changes"
  local t2 = spawn(writeResponse)
  t2.priority = 2
  latestNumber = "have you heard the latest"
  local t3 = spawn(writeResponse)
  t3.priority = 1
     while (true) do
    -- print("priorities: ", t1.priority, t2.priority)
    -- if t1:priority == "dead" and t2:getStatus() == "dead" then
    --   break;
    -- end
    myScheduler:step()
  end
end


run(main)