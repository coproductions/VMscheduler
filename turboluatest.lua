#!/usr/bin/env luajit
local turbo = require("turbo")

--test_scheduler.lua
package.path = "./?.lua;"..package.path

local myScheduler = require("myScheduler")()

-- local myTask = require("myTask")

local Kernel = require("myKernel")({Scheduler = myScheduler})()



local HelloWorldHandler = class("HelloWorldHandler", turbo.web.RequestHandler)


local latestNumber = "hello from latest"
local function writeResponse(self,whatever)
    self:write(whatever)
    yield();
end

local function task2()
  print("second task, only line")
  yield();
end

function HelloWorldHandler:get()
    writeResponse(self,"hello again")
    self:write("second Response")
    print("got this far")
    
    spawn(task2)
--   local t0 = spawn(writeResponse, self, "hello again")
--   t0.priority = 2
--   latestNumber = "Michigan"
--   local t1 = spawn(writeResponse, self, "hello against")
--   t1.priority = 2
--   latestNumber = "hello some changes"
--   local t2 = spawn(writeResponse, self, "hello agaisrtnst")
--   t2.priority = 2
--   latestNumber = "have you heard the latest"
--   local t3 = spawn(writeResponse, self, "hello against")
--   t3.priority = 1
  print("got even further")
   
   while (true) do
    -- print("priorities: ", t1.priority, t2.priority)
    -- if t1:priority == "dead" and t2:getStatus() == "dead" then
    --   break;
    -- end
    myScheduler:step()
  end

end

turbo.web.Application({
    {"/hello", HelloWorldHandler}
}):listen(8080)
print("listening on 8080")

turbo.ioloop.instance():start()



