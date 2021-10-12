--- ModuleScript  Event
--- Created by Isle
--- Latest Editted by Gyss
Event = class("Event")

local t_funcion_table = {}

function Event:Connect(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    table.insert(t_funcion_table, Func)
    return self
end

function Event:DisconnectAll(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
	local _keys = {}
    for key, value in ipairs(t_funcion_table) do
        if value == Func then
            table.insert(_keys, key)
        end
    end
	for _shift, key in ipairs(_keys) do
		table.remove(t_funcion_table, key-_shift+1)
	end
	
    return self
end

function Event:Disconnect(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    for key, value in ipairs(t_funcion_table) do
        if value == Func then
            table.remove(t_funcion_table, key)
        end
    end
    return self
end

function Event:initialize(Func)
	if Func == nil then return end
    self:Connect(Func)
end

function Event:Fire(...)
    for key, value in ipairs(t_funcion_table) do
        value(...)
    end
    --Debug
    if DebugList.Event then
        Debug.Log("事件被调用")
    end
end

function Event:HasConnected(Func)
    assert(type(Func) == "function", "[ArgumentsTypeError] Func must be a function")
    for key, value in ipairs(t_funcion_table) do
        if value == Func then
            return true
        end
    end
    return false
end

function Event:ClearAll()
    t_funcion_table = {}
    return self
end

return Event
