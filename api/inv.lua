assert(async ~= nil, "async module is required");
inv = {}
inv.items = {}
inv.freeSlots = 16

function inv.stack()
    for name, item in pairs(inv.items) do
        if(#item.slots > 1) then
            local last = item.slots[#item.slots]
            for i=1,#item.slots-1 do
                local space = turtle.getItemSpace(item.slots[i])
                if (space > 0) then
                    if(turtle.getSelectedSlot() ~= last) then turtle.select(last) end
                    turtle.transferTo(item.slots[i], space)
                    return
                end
            end
        end
    end
    os.queueEvent("inv_change")
end

function inv.update()
    inv.items = {}
    inv.freeSlots = 16
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if(item ~= nil) then
            if(inv.items[item.name] == nil) then 
                inv.items[item.name] = {
                    ["count"] = item.count,
                    ["slots"] = {i}
                }
            else
                inv.items[item.name].count = inv.items[item.name].count + item.count
                table.insert(inv.items[item.name].slots, i)
            end
        end
    end
    for name, item in pairs(inv.items) do
        inv.freeSlots = inv.freeSlots - #item.slots
    end
    inv.stack()
end
inv.update()
async.on("turtle_inventory", inv.update)

function inv.count(name)
    if(inv.items[name] == nil) then return 0
    else return inv.items[name].count end
end

function inv.select(name)
    if(inv.items[name] == nil) then return false
    else return turtle.select(inv.items[name].slot) end
end

function inv.place(name)
    if(name==nil) then return turtle.place()
    else
        if(inv.items[name] == nil) then return false
        else
            inv.select(name)
            return turtle.place()
        end
    end
end

function inv.placeUp(name)
    if(name==nil) then return turtle.placeUp()
    else
        if(inv.items[name] == nil) then return false
        else
            inv.select(name)
            return turtle.placeUp()
        end
    end
end

function inv.placeDown(name)
    if(name==nil) then return turtle.placeDown()
    else
        if(inv.items[name] == nil) then return false
        else
            inv.select(name)
            return turtle.placeDown()
        end
    end
end

function inv.drop(name, amount)
    if(name == nil) then return turtle.drop()
    else
        if(inv.items[name] == nil or inv.items[name].count < amount) then return false
        else
            local toDrop = amount
            while(true) do
                local slot = inv.items[name].slots[1]
                if(turtle.getSelectedSlot() ~= slot) then turtle.select(slot) end
                local am = turtle.getItemCount(slot)
                if(am >= toDrop) then
                    turtle.drop(toDrop)
                    sleep(0.05)
                    break
                else
                    turtle.drop(am)
                    sleep(0.05)
                    toDrop = toDrop - am
                end
            end
        end
    end
end

function inv.dropUp(name, amount)
    if(name == nil) then return turtle.dropUp()
    else
        if(inv.items[name] == nil or inv.items[name].count < amount) then return false
        else
            local toDrop = amount
            while(true) do
                local slot = inv.items[name].slots[1]
                if(turtle.getSelectedSlot() ~= slot) then turtle.select(slot) end
                local am = turtle.getItemCount(slot)
                if(am >= toDrop) then
                    turtle.dropUp(toDrop)
                    sleep(0.05)
                    break
                else
                    turtle.dropUp(am)
                    sleep(0.05)
                    toDrop = toDrop - am
                end
            end
        end
    end
end

function inv.dropDown(name, amount)
    if(name == nil) then return turtle.dropDown()
    else
        if(inv.items[name] == nil or inv.items[name].count < amount) then return false
        else
            local toDrop = amount
            while(true) do
                local slot = inv.items[name].slots[1]
                if(turtle.getSelectedSlot() ~= slot) then turtle.select(slot) end
                local am = turtle.getItemCount(slot)
                if(am >= toDrop) then
                    turtle.dropDown(toDrop)
                    sleep(0.05)
                    break
                else
                    turtle.dropDown(am)
                    sleep(0.05)
                    toDrop = toDrop - am
                end
            end
        end
    end
end

function inv.refuel(fraction)
    for i=1,16 do
        local count = turtle.getItemCount(i)
        if(count > 0) then
            turtle.select(i)
            if(turtle.refuel(0)) then turtle.refuel(math.ceil(fraction*count)) end
        end
    end
end


return inv;