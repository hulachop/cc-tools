require("/api/async")
require("/api/inv")
require("/api/trtl")
N = arg[1]
garbage = {}
gcing = false

function loadGarbage()
    local file = io.input("/api/garbage.txt")
    while true do
        local line = io.read("*line")
        if line then table.insert(garbage, line)
        else break end
    end
end
loadGarbage()

function main()
    trtl.dig(N)
    while true do
        trtl.turnRight()
        trtl.dig(N, true)
        trtl.turnRight()
        for i = 1, 3 do
            trtl.dig(2*N, true)
            trtl.turnRight()
        end
        trtl.dig(N, true)
        trtl.turnLeft()
        trtl.dig(1)
        N = N + 1
    end
end

function GC()
    if(inv.freeSlots > 1 or gcing == true) then return end
    gcing = true
    for i=1,#garbage do
        if(inv.items[garbage[i]] ~= nil) then
            inv.dropDown(garbage[i], inv.items[garbage[i]].count)
        end
    end
    gcing = false
end

function refuel()
    if(turtle.getFuelLevel() <= 2*N) then
        inv.refuel(0.5)
    end
end

async.on("_fuel", refuel)
async.on("inv_change", GC)

async.run(main)
async.start()