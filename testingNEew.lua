local ball = {x = 100, y = 100, radius = 20, body = nil, speed = 50}

local player = {
    xp = 0,
    skin = nil
}


--#region Pen

local pen = {
    ink = {
        absoluteLimit = 100,
        extraPerXp = 0.1,
        startingAmount = 10,
    }
}

function pen:getAvilableInk()
    return math.min(pen.ink.absoluteLimit, pen.ink.startingAmount + (pen.ink.extraPerXp * player.xp))
end

--#endregion

--#region Levels/Worlds

--[[Each level is drawn accroding to these rules:

    Levels will be designed in a map editor with object placement supporting static and dynamic objects
        Objects will be predrfined so that the user can select an item then click on the screen where to add it
    

]]

local levelEditor = {
    objects = {
        {type = "ball", variables = {x = nil, y = nil, radius = nil, staticOrDynamic = nil}},
        {type = "rectangle", x = nil, y = nil, width = nil, height = nil},
        {type = "triangle"}

    }
}

local levels = {}

local world = {}

--#endregion