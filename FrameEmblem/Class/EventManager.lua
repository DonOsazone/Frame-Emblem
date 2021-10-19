--- ModuleScript  EventManager
--- Created by MangXiao
--- Latest Editted by Gyss
EventManager = class("EventManager")

local _private = setmetatable({}, {__mode = "k"})
local FireEvents, SleepCheck

--- @function FireEvents 触发事件队列中的所有事件
FireEvents = function()
    local _cursor_event = table.remove(_private[self].t_events, 1)
    _cursor_event[1]:Fire(table.unpack(_cursor_event[2]))
    if #(_private[self].t_events) == 0 then
        _private[self].b_sleeping = true
        SleepCheck()
    else
        FireEvents()
    end
end

--- @function SleepCheck 检查事件队列，决定何时唤醒EM执行所有事件
SleepCheck = function()
    while true do
        if (#(_private[self].t_events) ~= 0 and _private[self].b_sleeping) then
            FireEvents()
            _private[self].b_sleeping = false
            break
        end
        wait()
    end
end

--- @function AddEvent 添加事件，向事件队列中添加事件和参数表，添加的事件会顺序执行
--- @param E_NewEvent EventInstance 事件实例
--- @param t_args table 该事件的参数表，默认为{}
function EventManager:AddEvent(E_NewEvent, t_args)
    t_args = t_args or {}
    table.insert(_private[self].t_events, {E_NewEvent, t_args})
end

--- @function 构造函数
function EventManager:initialize()
    _private[self] = {
        t_events = {},
        b_sleeping = false
    }
    SleepCheck()
end

return EventManager
