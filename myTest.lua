--test_scheduler.lua
package.path = "./?.lua;"..package.path

local myScheduler = require("myScheduler")()

local myTask = require("myTask")

local Kernel = require("schedlua.kernel")({Scheduler = myScheduler, Task = myTask})



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
  yield();
  print("first task, second line")
end

local function task2()
  print("second task, only line")
end

local function counter(name, nCount)
  for num in numbers(nCount) do
    print(name, num);
    yield();
  end
  halt();
end

local function main()
  local t0 = spawn(counter, "counter1", 5)
  t0.printHello()
  local t1 = spawn(task1)
  local t2 = spawn(task2)
  local t3 = spawn(counter, "counter2", 7)
end

run(main)


print("After kernel run...")