--- script  EventTest
--- Created by Isle
--- Latest Editted by Isle
--启动事件测试模块
if DebugList.Event==nil then return end

local Event = require(Event)

local event = Event();

function func1(arg)
    print('第一个垃圾代码：'..arg);
end
function func2()
    local function inlinefunc(arg)
        print('第二个垃圾代码：'..arg);
     end
    return inlinefunc
end

local f1 = func1
local f2 = func1

--同一个函数引用，无法重复连接
event:Connect(f1)
event:Connect(f2)

--借助闭包的工厂，暂时无法合理使用，可以无视
--local f3 = func2()
--local f4 = func2()
--event:Connect(f3)
--event:Connect(f4)

local Test = function(arg)
    event:Fire(arg)
end

Test(1)

event:Disconnect(f2)

Test(2)

