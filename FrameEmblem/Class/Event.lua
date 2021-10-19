--- ModuleScript  Event
--- Created by Isle
--- Latest Editted by Gyss
Event = class("Event")

local _private = setmetatable({}, {__mode = "k"})

local _temp = setmetatable({}, {__mode = "k"})

--- @function Connect 将事件与给定的函数绑定，当事件触发时，绑定的函数调用
--- @param Func function 待绑定的函数
--- @return EventInstance 解除绑定后的Event实例
function Event:Connect(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    table.insert(_private[self].t_funcion_table, Func)
    return self
end

--- @function DisconnectAll 断开与事件相连的全部函数，当一个事件绑定了多次相同的函数时，可以使用该函数直接清除所有的绑定
--- @param Func function 待解除的函数
--- @return EventInstance 解除绑定后的Event实例
function Event:DisconnectAll(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    local _keys = {}
    -- 遍历该事件所有绑定的Func并记录其所在的位置
    for key, value in ipairs(_private[self].t_funcion_table) do
        if value == Func or value == _temp[Func] then
            table.insert(_keys, key)
        end
    end
    -- 随后移除对应位置的所有函数（存在改进空间，反向遍历理论上可进一步提高效率
    for _shift, key in ipairs(_keys) do
        table.remove(_private[self].t_funcion_table, key - _shift + 1)
    end

    return self
end

--- @function Disconnect 断开与事件相连的Func函数，该操作仅删除一次绑定
--- @param Func function 待解除的函数
--- @return EventInstance 解除绑定后的Event实例
function Event:Disconnect(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    for key, value in ipairs(_private[self].t_funcion_table) do
        if value == Func or value == _temp[Func] then
            table.remove(_private[self].t_funcion_table, key)
        end
    end
    return self
end

--- @function initialize 构造函数
--- @param Func function 待绑定的函数（可选）
function Event:initialize(Func)
    _private[self] = {t_funcion_table = {}}
    if Func == nil then
        return
    end
    self:Connect(Func)
end

--- @function Fire 触发该事件，调用该事件绑定的所有函数，并将事件的参数传递给绑定的函数
function Event:Fire(...)
    for key, value in ipairs(_private[self].t_funcion_table) do
        value(...)
    end
    --Debug
    --if DebugList.Event then
    --    Debug.Log("事件被调用")
    --end
end

--- @function HasConnected 检查事件实例是否已经绑定了Func
--- @param Func function 待检查的函数
--- @return Boolean 布尔值，事件实例是否绑定了Func
function Event:HasConnected(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    for key, value in ipairs(_private[self].t_funcion_table) do
        if value == Func or value == _temp[Func] then
            return true
        end
    end
    return false
end

--- @function ClearAll 清空该事件实例所有已绑定的函数
function Event:ClearAll()
    _private[self].t_funcion_table = {}
    return self
end

--- @function TempConnect 临时绑定，该绑定传入的函数会在指定调用次数后自动解绑
--- @param Func function 待绑定的函数
--- @param n_times integer 调用指定次数后自动解绑函数（可选，默认为1）
--- *临时绑定在制作数回合后自动消失的效果时，可不用再额外维护变量，适用于处理Buff类的自动消散效果*
function Event:TempConnect(Func, n_times)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    n_times = n_times or 1
    local function _temp_function(...)
        Func(...)
        if n_times <= 1 then
            self:Disconnect(_temp_function)
            _temp[Func] = nil
        else
            n_times = n_times - 1
        end
    end
    _temp[Func] = _temp_function
    self:Connect(_temp_function)
    return self
end

return Event
