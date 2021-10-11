--- script  Event
--- Created by Isle
--- Latest Editted by Isle
Event = class('Event')

local t_funcion_table = {};
function Event:Connect(Func)
    table.insert(t_funcion_table,Func);
end

function Event:Disconnect(Func)
    for key, value in ipairs(t_funcion_table) do
        if value == Func then
            table.remove(t_funcion_table,key);
            break;
        end
    end
end
function Event:initialize(Func)
    t_funcion_table[tostring(Func)] = Func;
end

function Event:Fire(...)
    for key, value in ipairs(t_funcion_table) do
        value(...)
    end
	--Debug
	if DebugList.Event then Debug.Log('事件被调用') end
end
function Event:ClearAll()
    t_funcion_table = {}
end

return Event
