--test_scheduler.lua
package.path = "./?.lua;"..package.path

local myScheduler = require("myScheduler")()

-- local myTask = require("myTask")

local Kernel = require("myKernel")({Scheduler = myScheduler})()

-- local Kernel = require("schedlua.kernel")()


local myReadyList = {};


local function numbers(ending)
  local idx = 0;
  local function fred()
    idx = idx + 1;
    if idx > ending then
      return nil;
    end
    return idx;
  end

  return fred;
end

local function task1()
  print("first task, first line")
  myScheduler:yield();
  print("first task, second line")
end

local function task2()
  print("second task, only line")
  myScheduler:yield();
end

local function counter(name, nCount)
  for num in numbers(nCount) do
    print(name, num);
  myScheduler:yield();
  end
  halt();
end

local function main()
  local t0 = spawn(counter, "counter1", 5)
  local t1 = spawn(task1)
  local t2 = spawn(task2)
  local t3 = spawn(counter, "counter2", 7)
  t0.priority = 1;
  t1.priority = 2;
  t2.priority = 3;
  t3.priority = 1;

 while (true) do
    -- print("priorities: ", t1.priority, t2.priority)
    -- if t1:priority == "dead" and t2:getStatus() == "dead" then
    --   break;
    -- end
    -- myScheduler:step()
  end
end


run(main)


print("After kernel run...")