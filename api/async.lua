async = {}
local eventListeners = {}
local routines = {}
local filters = {}
local routineCount = 0
async.mode = "default"

function async.run(func, ...)
    local c = coroutine.create(func)
    local success, param = coroutine.resume(c, unpack(arg))
    if (success and coroutine.status(c) ~= "dead") then
        if(param == nil) then param = 0 end
        table.insert(routines, c)
        table.insert(filters, param)
        routineCount = routineCount + 1
    elseif (not success) then
        error(param)
    end
    return true
end

function await(func, ...)
    local c = coroutine.create(func)
    local success, param = coroutine.resume(c, unpack(arg))
    if (success and coroutine.status(c) ~= "dead") then
        if(param == nil) then param = 0 end
        table.insert(routines, c)
        table.insert(filters, param)
        routineCount = routineCount + 1
        coroutine.yield("callback_"..string.sub(tostring(c), 9))
    elseif (not success) then
        error(param)
    end
    return true
end

function async.on(event, func, _mode)
    if(_mode == nil) then _mode = "default" end
    if(event == nil or func == nil) then error("shit") end
    if(eventListeners[_mode] == nil) then eventListeners[_mode] = {} end
    if (eventListeners[_mode][event] == nil) then eventListeners[_mode][event] = {} end
    table.insert(eventListeners[_mode][event], func)
end

function async.removeEventListener(event, index, _mode)
    if(eventListeners[_mode][event] == nil) then return false end
    if(index == nil) then table.remove(eventListeners[_mode][event]); return true
    else table.remove(eventListeners[_mode][event], index); return true
    end
end

function async.start()
    while true do
        -- PULL EVENT --
        local eventData = {os.pullEventRaw()};
        local event = eventData[1]
        local currentMode = async.mode
        -- SCHEDULER --
        for i = 1, routineCount do
            if(filters[i] == 0 or filters[i] == event or event == "terminate") then
                local callback = "callback_"..string.sub(tostring(routines[i]), 9)
                local success, param = coroutine.resume(routines[i], unpack(eventData))
                if(success) then
                    if(param == nil) then param = 0 end
                    filters[i] = param
                else
                    error(param)
                end
                if(coroutine.status(routines[i]) == "dead") then
                    table.remove(routines, i)
                    table.remove(filters, i)
                    routineCount = routineCount - 1
                    i = i - 1
                    os.queueEvent(callback)
                end
            end
        end
        -- ADD ROUTINES --
        if (eventListeners[currentMode] ~= nil and eventListeners[currentMode][event] ~= nil) then
            table.remove(eventData, 1)
            for i=1, #eventListeners[currentMode][event] do
                local c = coroutine.create(eventListeners[currentMode][event][i])
                local success, param = coroutine.resume(c, unpack(eventData))
                if(success and coroutine.status(c) ~= "dead") then
                    if(param == nil) then param = 0 end
                    table.insert(routines, c)
                    table.insert(filters, param)
                    routineCount = routineCount + 1
                elseif(not success) then
                    error(param)
                end
            end
        elseif (event == "terminate") then
            print("fuck fuck termination fuck")
            return false
        end
    end
end

return async;