--test_scheduler.lua
package.path = "./?.lua;"..package.path

local myScheduler = require("myScheduler")()

-- local myTask = require("myTask")

local AsyncSocket = require("AsyncSocket")

local Kernel = require("myKernel")({Scheduler = myScheduler})()

-- local Kernel = require("schedlua.kernel")()

local function main()
    print('socket',AsyncSocket)
--   local t0 = spawn(counter, "counter1", 5)
--   t0.priority = 2;
--   local t1 = spawn(task1)
--   t1.priority = 2;
--   local t2 = spawn(task2)
--   t2.priority = 2;
--   local t3 = spawn(counter, "counter2", 7)
--   t3.priority = 1;

 while (true) do
    -- print("priorities: ", t1.priority, t2.priority)
    -- if t1:priority == "dead" and t2:getStatus() == "dead" then
    --   break;
    -- end
    myScheduler:step()
  end
end


run(main)


print("After kernel run...")