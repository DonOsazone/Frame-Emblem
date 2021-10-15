EventManager =class('EventManager')

local t_events={}
local b_sleeping=false
local t_current_event ={}

function EventManager:initialize()
    if (eventManager~=nil)
     then
        eventManager=EventManager()--实例命名我按照MiddleClass里写的
    end
    
end

local _SleepCheck =function()
    while true do
        if (t_events~=nil and b_sleeping==true)  then
            EventManager:FireEvents()
            b_sleeping=false
            break
        end
    end
end


function EventManager:AddEvent(E_NewEvent)
    table.insert(t_events,E_NewEvent)
end

local FireEvents=function ()
  if (t_event~=nil) then
    t_current_event = table.unpack(t_events,1,1)
    print(t_current_event)
    table.remove(t_events,1)
    FireEvents()
    else
        b_sleeping=true
        _SleepCheck()
  end

end


