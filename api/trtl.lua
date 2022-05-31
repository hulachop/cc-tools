trtl = {}
trtl.pos = vector.new(0,0,0)
trtl.dir = vector.new(1,0,0)
trtl.home = vector.new(0,0,0)

function trtl.init(x,y,z,dir)
    if(dir=="x") then trtl.dir = vector.new(1,0,0)
    else trtl.dir = vector.new(0,0,1) end
    trtl.pos = vector.new(x,y,z)
    trtl.home = vector.new(x,y,z)
end

function trtl.dig(dist, tunnel)
    if(dist == nil) then
        while(turtle.detect()) do
            turtle.dig()
            sleep(0.45)
        end
        return true
    end
    for i = 1, dist do
        while(true) do
            if(tunnel) then
                if(turtle.detectUp()) then turtle.digUp() end
                if(turtle.detectDown()) then turtle.digDown() end
            end
            if(turtle.detect()) then turtle.dig()
            else break end
            sleep(0.45)
        end
        if(not turtle.forward()) then i = i -1
        else
            trtl.pos = trtl.pos + trtl.dir
            os.queueEvent('_fuel')
        end
    end
    if(tunnel) then
        turtle.digUp()
        turtle.digDown()
    end
end

function trtl.turnRight()
    turtle.turnRight()
    trtl.dir = vector.new(-trtl.dir.z, 0, trtl.dir.x)
end

function trtl.turnLeft()
    turtle.turnLeft()
    trtl.dir = vector.new(trtl.dir.z, 0, -trtl.dir.x)
end