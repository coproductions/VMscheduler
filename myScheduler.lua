
local ffi = require("ffi");

local Queue = require("schedlua.queue")
local Task = require("schedlua.task");

-- local Task = require("myTask")
-- test comment
-- more changes
--[[
  The Scheduler supports a collaborative processing
  environment.  As such, it manages multiple tasks which
  are represented by Lua coroutines.

  The scheduler works by being the main routine which is running
  in the application.  When work is to be done, it is encapsulated in
  the form of a task object.  The scheduler relies upon that task object
  to call a form of 'yield' at some point, at which time it will receive
  the main thread of execution, and will pick the next task out of the ready
  list to run.
--]]
local Scheduler = {}
setmetatable(Scheduler, {
  __call = function(self, ...)
    return self:new(...)
  end,
})
local Scheduler_mt = {
  __index = Scheduler,
}

function Scheduler.init(self, ...)
  --print("==== Scheduler.init ====")
  local obj = {
    TasksReadyToRun1 = Queue();
    TasksReadyToRun2 = Queue();


  }
  setmetatable(obj, Scheduler_mt)

  return obj;
end

function Scheduler.new(self, ...)
  return self:init(...)
end

--[[
    Instance Methods
--]]

function Scheduler.tasksPending(self)
  return self.TasksReadyToRun1:length() + self.TasksReadyToRun2:length();
end


--[[
  Task Handling
--]]

-- put a task on the ready list
-- the 'task' should be something that can be executed,
-- whether it's a function, functor, or something that has a '__call'
-- metamethod implemented.
-- The 'params' is a table of parameters which will be passed to the function
-- when it's ready to run.
function Scheduler.scheduleTask(self, task, params)
  --print("Scheduler.scheduleTask: ", task, params)
  params = params or {}

  if not task then
    return false, "no task specified"
  end

  task:setParams(params);
  if task.priority == 1 then
    self.TasksReadyToRun1:enqueue(task);
  else
    self.TasksReadyToRun2:enqueue(task);
  end
  task.state = "readytorun"

  return task;
end



function Scheduler.removeFiber(self, fiber)
  --print("REMOVING DEAD FIBER: ", fiber);
  return true;
end
function Scheduler.inMainFiber(self)
  return coroutine.running() == nil;
end

function Scheduler.getCurrentTask(self)
  return self.CurrentFiber;
end

function Scheduler.suspendCurrentFiber(self, ...)
  self.CurrentFiber.state = "suspended"
end

function Scheduler.incListCount(self, list, n)
  n = n or 1
  if list.counter then
    list.counter = list.counter + n
  else
    list.counter = 1
  end
end

function Scheduler.resetListCounter(self, list)
  list.counter = 0
end

function Scheduler.determineRunList(self)
  local high = self.TasksReadyToRun1
  local low = self.TasksReadyToRun2
  if not high.counter then
    high.counter = 0
  end
  if not low.counter then
    low.counter = 0
  end
  if high.counter < 3 and high:length() > 0 then
    self.resetListCounter(self,low)
    return high
  elseif high.counter > 10 then
    self.resetListCounter(self,high)
    return low
  elseif low:length() > low:length()*3 then
    self.resetListCounter(self,high)
    return low
  else
    self.resetListCounter(self,low)
    return high
  end
end


function Scheduler.step(self)
  -- Now check the regular fibers
  local runList = self.determineRunList(self)
  local task = runList:dequeue()
  self.incListCount(self,runList)
  -- print('local created, new length of list: ',self.TasksReadyToRun:length())
  -- if task and nextTask then
  --   print('ready to run list counter: ',self.TasksReadyToRun.counter)
  --   if task.priority < nextTask.priority then

  --   -- print('next task is not null so it will be replaced')
  --     self.TasksReadyToRun:pushFront(task)
  --     task = nextTask
  --   -- print('local requeued, new length of list: ',self.TasksReadyToRun:length())
  --   else
  --     self.TasksReadyToRun:pushFront(nextTask)
  --   end
  --   -- print('next task was nil')
  -- end
    -- print('nexttaskId:',nextTask.TaskID)

    -- print('first in queue b4 requeue: ',self.TasksReadyToRun.first)
    -- print('first in queue after requeue: ',self.TasksReadyToRun.first)
  -- print('task: ',task,' nextTask: ',nextTask)

    -- check the priority of the current task and compare it to the next task in the list
  -- if nextTask then
  --   print('nexttaskId:',nextTask.TaskID)
  --   print('in nextTask','task priority: ',task.priority,' nextTask priority: ',nextTask.priority)
  --   print('length',self.TasksReadyToRun:length())
  --   if task.priority < nextTask.priority then
  --     self.TasksReadyToRun:pushFront(task)
  --     -- task.state = "readytorun"
  --     task = nextTask
  --     print('switched tasks')
  --     print('newtaskId:',task.TaskID)

  --     -- print('length',self.TasksReadyToRun:length())

  --   end
  --   -- self.TasksReadyToRun:Entries(print)
  -- end

  -- If no fiber in ready queue, then just return
  if task == nil then
    -- print("Scheduler.step: NO TASK")
    return true
  end

  if task:getStatus() == "dead" then
    self:removeFiber(task)

    return true;
  end

  -- If the task we pulled off the active list is
  -- not dead, then perhaps it is suspended.  If that's true
  -- then it needs to drop out of the active list.
  -- We assume that some other part of the system is responsible for
  -- keeping track of the task, and rescheduling it when appropriate.
  if task.state == "suspended" then
    print("suspended task wants to run")
    return true;
  end

  -- If we have gotten this far, then the task truly is ready to
  -- run, and it should be set as the currentFiber, and its coroutine
  -- is resumed.
  self.CurrentFiber = task;
  local results = {task:resume()};

  -- once we get results back from the resume, one
  -- of two things could have happened.
  -- 1) The routine exited normally
  -- 2) The routine yielded
  --
  -- In both cases, we parse out the results of the resume
  -- into a success indicator and the rest of the values returned
  -- from the routine
  --local pcallsuccess = results[1];
  --table.remove(results,1);

  local success = results[1];
  table.remove(results,1);

--print("PCALL, RESUME: ", pcallsuccess, success)

  -- no task is currently executing
  self.CurrentFiber = nil;


  if not success then
    print("RESUME ERROR")
    print(unpack(results));
  end

  -- Again, check to see if the task is dead after
  -- the most recent resume.  If it's dead, then don't
  -- bother putting it back into the readytorun queue
  -- just remove the task from the list of tasks
  if task:getStatus() == "dead" then
    self:removeFiber(task)

    return true;
  end

  -- The only way the task will get back onto the readylist
  -- is if it's state is 'readytorun', otherwise, it will
  -- stay out of the readytorun list.
  if task.state == "readytorun" then
    self:scheduleTask(task, results);
  end
end

function Scheduler.yield(self, ...)
  return coroutine.yield(...);
end


return Scheduler