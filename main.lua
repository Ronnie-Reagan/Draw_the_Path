---@diagnostic disable: undefined-global

-- Suit UI Library
local suit = require 'suit'
local input = { text = "" }

local getHeight = love.graphics.getHeight
local getWidth = love.graphics.getWidth
local keyDown = love.keyboard.isDown
local levelsData = require("levelData")
local userLevelData = require("userLevelData")
local UI = require "UI"
local mainMenuBackground = love.graphics.newImage("mainMenuBackground.png")
local currentUserLevel = 1
local currentObject = "floor"
local world
local background
local floors = {}
local walls = {}
local flag
local obstacles = {}
local ballSkin
local levelSize = {}
local dtt
local camera = {
    x = 0,
    y = 0
}
local pen = {
    ink = {
        currentAmount = 10,
        limit = 10,
        vectorizedDeposits = {},
        nonVectorizedDeposits = {},
    },
    minimumDistance = 28
}

local game = {
    currentMenuState = "mainMenu",
    currentLevel = 1,
    numberOfLevels = #levelsData,
    uiElements = {},
    editor = {
        objects = {},
        finishLine = {},
        startPos = {},
    }
}

local player = {
    size = nil,
    rotationalPower = nil,
    gravitationalPower = nil,
    level = 1,
}

function getScreenCenterX()
    return getWidth() / 2
end

function getScreenCenterY()
    return getHeight() / 2
end

function getScreenYLayers(numberOfLayers, requestedLayerY)
    local layers = {}
    local layerHeight = getHeight() / numberOfLayers
    for i = 1, numberOfLayers, 1 do
        table.insert(layers, i, layerHeight * i)
    end
    if requestedLayerY then
        return layerHeight * requestedLayerY
    else
        return layers
    end
end

function mousePos()
    local x, y = love.mouse.getPosition()
    x = x + camera.x
    y = y + camera.y
    return x, y
end

function initWorld(isUserLevel, levelIndex)
    if isUserLevel == false and #levelsData <= levelIndex then
        floors = {}
        walls = {}
        obstacles = {}
        pen.ink.nonVectorizedDeposits = {}
        pen.ink.vectorizedDeposits = {}

        local level = levelsData[levelIndex]
        levelSize.x = level.worldWidth
        levelSize.y = level.worldHeight
        local scaleFactor = level.scaleFactor
        love.physics.setMeter(level.meter)
        world = love.physics.newWorld(level.gravityX, level.gravityY, true)

        -- initialize player
        ballSkin = love.graphics.newImage(level.ballSkin)
        player.character = level.playerCharacter
        player.character.body = love.physics.newBody(world, player.character.x, player.character.y, "dynamic")
        player.character.body:setMass(player.character.mass)
        player.character.shape = love.physics.newCircleShape(player.character.radius)
        player.fixture = love.physics.newFixture(player.character.body, player.character.shape)
        player.fixture:setFriction(player.character.friction)

        -- initialize floors
        for i, floorData in ipairs(level.floors) do
            floors[i] = {}
            floors[i].colour = floorData.colour
            floors[i].body = love.physics.newBody(world, floorData.x, floorData.y, "static")
            floors[i].shape = love.physics.newRectangleShape(floorData.width, floorData.height)
            floors[i].fixture = love.physics.newFixture(floors[i].body, floors[i].shape)
            floors[i].fixture:setFriction(floorData.friction)
        end

        -- initialize walls
        for i, wallData in ipairs(level.walls) do
            walls[i] = {}
            walls[i].colour = wallData.colour
            walls[i].body = love.physics.newBody(world, wallData.x, wallData.y, "static")
            walls[i].shape = love.physics.newRectangleShape(wallData.width, wallData.height)
            walls[i].fixture = love.physics.newFixture(walls[i].body, walls[i].shape)
        end

        -- now the obstacles
        for index, obs in pairs(level.obstacles) do
            obstacles[index] = {}
            obstacles[index].colour = obs.colour
            obstacles[index].body = love.physics.newBody(world, obs.x, obs.y, obs.type)
            obstacles[index].shape = love.physics.newRectangleShape(obs.width, obs.height)
            obstacles[index].fixture = love.physics.newFixture(obstacles[index].body, obstacles[index].shape)
            obstacles[index].fixture:setFriction(0.25)
        end

        -- stupid flag
        flag = {
            body = love.physics.newBody(world, level.finishFlag.x, level.finishFlag.y, "static"),
            shape = love.physics.newRectangleShape(level.finishFlag.width, level.finishFlag.height),
        }
        flag.fixture = love.physics.newFixture(flag.body, flag.shape)

        -- background image
        background = love.graphics.newImage(level.backGround)

        -- callback for level completion
        world:setCallbacks(beginContact)
        game.currentMenuState = "playing"
    elseif isUserLevel == true and currentUserLevel <= #userLevelData then
        floors = {}
        walls = {}
        obstacles = {}
        pen.ink.nonVectorizedDeposits = {}
        pen.ink.vectorizedDeposits = {}

        local level = userLevelData[levelIndex]
        levelSize.x = 1920
        levelSize.y = 1080
        local scaleFactor = 1
        love.physics.setMeter(1)
        world = love.physics.newWorld(level.gravityX, level.gravityY, true)

        -- initialize player
        ballSkin = love.graphics.newImage(level.ballSkin or "DR.Paint_Saved_Image_32.png")
        player.character = level.playerCharacter
        player.character.body = love.physics.newBody(world, player.character.x, player.character.y, "dynamic")
        player.character.body:setMass(player.character.mass)
        player.character.shape = love.physics.newCircleShape(player.character.radius)
        player.fixture = love.physics.newFixture(player.character.body, player.character.shape)
        player.fixture:setFriction(player.character.friction)

        -- initialize floors
        for i, floorData in ipairs(level.floors) do
            floors[i] = {}
            floors[i].colour = floorData.colour
            floors[i].body = love.physics.newBody(world, floorData.x, floorData.y, "static")
            floors[i].shape = love.physics.newRectangleShape(floorData.width, floorData.height)
            floors[i].fixture = love.physics.newFixture(floors[i].body, floors[i].shape)
            floors[i].fixture:setFriction(floorData.friction)
        end

        -- initialize walls
        for i, wallData in ipairs(level.walls) do
            walls[i] = {}
            walls[i].colour = wallData.colour
            walls[i].body = love.physics.newBody(world, wallData.x, wallData.y, "static")
            walls[i].shape = love.physics.newRectangleShape(wallData.width, wallData.height)
            walls[i].fixture = love.physics.newFixture(walls[i].body, walls[i].shape)
        end

        -- now the obstacles
        for index, obs in pairs(level.obstacles) do
            obstacles[index] = {}
            obstacles[index].colour = obs.colour
            obstacles[index].body = love.physics.newBody(world, obs.x, obs.y, obs.type)
            obstacles[index].shape = love.physics.newRectangleShape(obs.width, obs.height)
            obstacles[index].fixture = love.physics.newFixture(obstacles[index].body, obstacles[index].shape)
            obstacles[index].fixture:setFriction(0.25)
        end
        -- callback for level completion
        world:setCallbacks(beginContact)
    else
        game.currentLevel = #levelsData
        initWorld(game.currentLevel)
    end
end

function love.load()
    love.window.setMode(1920, 1080, console)
end

function love.mousepressed(x, y, button)
    for _, element in ipairs(UI.elements) do
        element:update(dtt)
    end
    if game.currentMenuState == "playing" then
        if button == 1 then
            x, y = mousePos()
            table.insert(pen.ink.nonVectorizedDeposits, { xo = x, yo = y, xt = nil, yt = nil })
        end
    end
end

function createNewLevel()

end

function love.mousereleased(x, y, button)
    if game.currentMenuState == "playing" then
        if button == 1 then
            if pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xt == nil then
                x, y = mousePos()
                pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xt = x
                pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].yt = y
            end
            createPhysicsFromPath()
        end
    end
    if game.currentMenuState == "editing" then
        -- Translate mouse position to world position based on camera
        x, y = mousePos()

        if button == 1 and x > 250 then
            addObject(currentObject, x, y)
        end
    end
end

function love.textedited(text, start, length)
    -- for IME input
    suit.textedited(text, start, length)
end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key)
    -- forward keypresses to SUIT
    suit.keypressed(key)
end

function createPhysicsFromPath()
    if true then
        local lastBody = nil
        local minWidth = 1

        for _, segment in ipairs(pen.ink.nonVectorizedDeposits) do
            local width = math.sqrt((segment.xt - segment.xo) ^ 2 + (segment.yt - segment.yo) ^ 2)

            if width >= minWidth then
                local angle = math.atan2(segment.yt - segment.yo, segment.xt - segment.xo)
                local height = 2
                local midX = (segment.xo + segment.xt) / 2
                local midY = (segment.yo + segment.yt) / 2

                local body = love.physics.newBody(world, midX, midY, "dynamic")
                local shape = love.physics.newRectangleShape(width, height)
                local fixture = love.physics.newFixture(body, shape)

                fixture:setDensity(width)
                fixture:setFriction(0.25)
                body:resetMassData()

                body:setAngle(angle)

                if lastBody then
                    local offsetX = (segment.xt - segment.xo) / width * (height / 2)
                    local offsetY = (segment.yt - segment.yo) / width * (height / 2)

                    love.physics.newWeldJoint(lastBody, body, segment.xo - offsetX, segment.yo - offsetY, false)
                    love.physics.newWeldJoint(lastBody, body, segment.xo + offsetX, segment.yo + offsetY, false)
                end

                pen.ink.currentAmount = pen.ink.currentAmount - width / 100

                lastBody = body

                table.insert(pen.ink.vectorizedDeposits, { body = body, fixture = fixture })
            end
        end

        pen.ink.nonVectorizedDeposits = {}
    end
end

function updateCameraPosition()
    local x, y = player.character.body:getPosition()
    local screenWidth, screenHeight = getWidth(), getHeight()

    local safeZoneWidth = screenWidth * 0.69
    local safeZoneHeight = screenHeight * 0.69
    local safeZoneLeft = camera.x + (screenWidth - safeZoneWidth) / 2
    local safeZoneRight = camera.x + (screenWidth + safeZoneWidth) / 2
    local safeZoneTop = camera.y + (screenHeight - safeZoneHeight) / 2
    local safeZoneBottom = camera.y + (screenHeight + safeZoneHeight) / 2

    if x < safeZoneLeft then
        camera.x = x - (screenWidth - safeZoneWidth) / 2
    elseif x > safeZoneRight then
        camera.x = x - (screenWidth + safeZoneWidth) / 2
    end

    if y < safeZoneTop then
        camera.y = y - (screenHeight - safeZoneHeight) / 2
    elseif y > safeZoneBottom then
        camera.y = y - (screenHeight + safeZoneHeight) / 2
    end
end

function updateUI(dt)
    if game.currentMenuState == "mainMenu" or game.currentMenuState == "paused" then
        camera.x, camera.y = 0, 0
        local menuItemWidth = 200
        local menuItemHeight = 30
        suit.layout:reset(getScreenCenterX() - (menuItemWidth / 2), getScreenCenterY() - (menuItemHeight / 2))
        if suit.Button("Start New Game", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            initWorld(1)
        end
        suit.layout:row(200, 15)
        if suit.Button("Start Editing", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            levelData = { [1] = { floors = {}, walls = {}, obstacles = {} } }
            game.currentMenuState = "editing"
        end
        suit.layout:row(200, 15)
        if suit.Button("Quit to Desktop", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            love.event.quit()
        end
    end

    if game.currentMenuState == "playing" then
        local menuItemWidth = 50
        local menuItemHeight = 50
        suit.layout:reset(0, 0) -- "docking" position

        -- creation of a button inside of a "hit" check, which is for clicking.
        if suit.Button("Pause", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            game.currentMenuState = "pauseMenu"
        end
    end

    if game.currentMenuState == "pauseMenu" then
        local menuItemWidth = 200
        local menuItemHeight = 30
        suit.layout:reset(getScreenCenterX() - (menuItemWidth / 2), getScreenCenterY() - (menuItemHeight / 2))
        if suit.Button("Resume Game", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            game.currentMenuState = "playing"
        end
        suit.layout:row(200, 15)
        if suit.Button("Quit to Main Menu", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            game.currentMenuState = "mainMenu"
            world = nil
        end
        suit.layout:row(200, 15)
        if suit.Button("Quit to Desktop", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            love.event.quit()
        end
    end

    if game.currentMenuState == "editing" then
        -- Layout for object buttons and properties editing
        local menuItemWidth = 200
        local menuItemHeight = 30
        suit.layout:reset(50, 50)

        -- Add button to place a floor
        if suit.Button("Add Floor", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            currentObject = "floor"
        end

        -- Add button to place a wall
        if suit.Button("Add Wall", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            currentObject = "wall"
        end

        -- Add button to place an obstacle
        if suit.Button("Add Obstacle", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            currentObject = "obstacle"
        end

        -- Properties panel for selected object
        if selectedObject then
            -- Change color button
            suit.Label("Change Color", suit.layout:row(menuItemWidth, menuItemHeight))
            suit.layout:row(menuItemWidth, 10)
            if suit.Button("Set Color", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
                changeObjectColor(selectedObject) -- Function to open color picker
            end

            -- Friction input
            --suit.Label("Friction: " .. selectedObject.friction, suit.layout:row(menuItemWidth, menuItemHeight))
            --selectedObject.friction = suit.Slider(selectedObject.friction, 0, 1, suit.layout:row(menuItemWidth, menuItemHeight))

            if suit.Button(selectedObject.isStatic and "Dynamic" or "Static", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
                selectedObject.isStatic = not selectedObject.isStatic
            end

            if suit.Button("Pause", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
                game.currentMenuState = "editorPauseMenu"
            end
        end
    end

    if game.currentMenuState == "editorPauseMenu" then
        local menuItemWidth = 200
        local menuItemHeight = 30
        suit.layout:reset(getScreenCenterX() - (menuItemWidth / 2), getScreenCenterY() - (menuItemHeight / 2))

        if suit.Button("Resume Editing", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            game.currentMenuState = "playing"
        end
        suit.layout:row(200, 15)
        if suit.Button("Test Level", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            initWorld(true, currentUserLevel)
            world = nil
        end
        suit.layout:row(200, 15)
        if suit.Button("Quit to Main Menu", suit.layout:row(menuItemWidth, menuItemHeight)).hit then
            game.currentMenuState = "mainMenu"
        end
    end
end

-- Function to add objects dynamically to the level
function addObject(type, x, y)
    local newObj
    if type == "floor" then
        newObj = {
            x = x,
            y = y,
            width = 400,
            height = 50,
            friction = 0.5,
            colour = { r = 102, g = 102, b = 102, a = 255 },
            isStatic = true
        }
        table.insert(userLevelData[currentUserLevel].floors, newObj)
    elseif type == "wall" then
        newObj = {
            x = x,
            y = y,
            width = 50,
            height = 500,
            friction = 0.5,
            colour = { r = 102, g = 102, b = 102, a = 255 },
            isStatic = true
        }
        table.insert(userLevelData[currentUserLevel].walls, newObj)
    elseif type == "obstacle" then
        newObj = {
            x = x,
            y = y,
            width = 60,
            height = 60,
            friction = 0.25,
            colour = { r = 178.5, g = 178.5, b = 178.5, a = 255 },
            type = "static",
            isStatic = true
        }
        table.insert(userLevelData[currentUserLevel].obstacles, newObj)
    end
    selectedObject = newObj -- Automatically select the new object
end

-- Function to change the color of an object
function changeObjectColor(obj)
    obj.colour = { r = math.random(1, 255), g = math.random(1, 255), b = math.random(1, 255), a = 255 }
end

function love.update(dt)
    updateUI(dt)
    if game.currentMenuState == "playing" then
        updateCameraPosition()
        world:update(dt)

        if keyDown("w") then
            player.character.body:applyForce(0, -player.character.gravitationalPower)
        end
        if keyDown("a") then
            player.character.body:applyTorque(-player.character.rotationalPower)
        end
        if keyDown("s") then
            player.character.body:applyForce(0, player.character.gravitationalPower)
        end
        if keyDown("d") then
            player.character.body:applyTorque(player.character.rotationalPower)
        end
        if keyDown("r") then
            initWorld(false, game.currentLevel)
        end

        if love.mouse.isDown(1) then
            local x, y = mousePos()
            if
                x > pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xo + pen.minimumDistance or
                y > pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].yo + pen.minimumDistance or
                x < pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xo - pen.minimumDistance or
                y < pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].yo - pen.minimumDistance then
                if pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xt == nil then
                    pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].xt = x
                    pen.ink.nonVectorizedDeposits[#pen.ink.nonVectorizedDeposits].yt = y
                end
                table.insert(pen.ink.nonVectorizedDeposits, { xo = x, yo = y, xt = nil, yt = nil })
            end
        end
    end
end

function beginContact(a, b, coll)
    if (a == player.fixture and b == flag.fixture) or (b == player.fixture and a == flag.fixture) then
        game.currentLevel = game.currentLevel + 1
        initWorld(false, game.currentLevel)
    end
end

function love.draw()
    if game.currentMenuState == "playing" then
        love.graphics.push()
        love.graphics.translate(-camera.x, -camera.y)
        love.graphics.draw(background, 0, 0, 0,
            levelSize.x / background:getWidth(),
            levelSize.y / background:getHeight())
        local x, y = player.character.body:getPosition()
        local angle = player.character.body:getAngle()
        local scaleX = player.character.size * 2 / ballSkin:getWidth()
        local scaleY = player.character.size * 2 / ballSkin:getHeight()

        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(
            ballSkin,
            x, y,
            angle,
            scaleX, scaleY,
            ballSkin:getWidth() / 2,
            ballSkin:getHeight() / 2
        )

        for floorIndex, floor in pairs(floors) do
            -- error showed up here, using destroyed body? need to find this bug as it means there are things being destroyed mid game or there are items being destroyed after initWorld
            love.graphics.setColor(floor.colour.r, floor.colour.g, floor.colour.b, floor.colour.a)
            love.graphics.polygon("fill", floor.body:getWorldPoints(floor.shape:getPoints()))
        end


        for wallIndex, wall in pairs(walls) do
            love.graphics.setColor(wall.colour.r, wall.colour.g, wall.colour.b, wall.colour.a)
            love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
        end

        -- to be revised to use the level data still, i want this to be a physical object the player has to touch to finish the level
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", flag.body:getWorldPoints(flag.shape:getPoints()))


        for _, obs in pairs(obstacles) do
            love.graphics.setColor(obs.colour.r, obs.colour.g, obs.colour.b, obs.colour.a)
            love.graphics.polygon("fill", obs.body:getWorldPoints(obs.shape:getPoints()))
        end

        love.graphics.setColor(0, 0, 1)
        for _, segment in ipairs(pen.ink.nonVectorizedDeposits) do
            if segment.xt then
                love.graphics.line(segment.xo, segment.yo, segment.xt, segment.yt)
            end
        end

        love.graphics.setColor(0, 1, 0)
        for _, deposit in ipairs(pen.ink.vectorizedDeposits) do
            local body = deposit.body
            local shape = deposit.fixture:getShape()
            love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
        end

        love.graphics.pop()
    end
    if game.currentMenuState == "mainMenu" or game.currentMenuState == "pauseMenu" then
        love.graphics.draw(mainMenuBackground)
    end
    if game.currentMenuState == "editing" then
        -- Floors
        if userLevelData[currentUserLevel] == nil or userLevelData[currentUserLevel].floors == nil then
            goto noLayers
        end
        for _, floor in ipairs(userLevelData[currentUserLevel].floors) do
            love.graphics.setColor(floor.colour.r / 255, floor.colour.g / 255, floor.colour.b / 255, floor.colour.a / 255)
            love.graphics.rectangle("fill", floor.x, floor.y, floor.width, floor.height)
        end

        -- Walls
        for _, wall in ipairs(userLevelData[currentUserLevel].walls or {}) do
            love.graphics.setColor(wall.colour.r / 255, wall.colour.g / 255, wall.colour.b / 255, wall.colour.a / 255)
            love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
        end

        -- Obstacles
        for _, obstacle in ipairs(userLevelData[currentUserLevel].obstacles or {}) do
            love.graphics.setColor(obstacle.colour.r / 255, obstacle.colour.g / 255, obstacle.colour.b / 255,
                obstacle.colour.a / 255)
            love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
        end
        ::noLayers::
        -- Reset color to white for UI
        love.graphics.setColor(1, 1, 1)
    end
    suit.draw()
end

function player:currentStrength()
    return math.min(player.maxPower, math.max(player.startingPower, player.startingPower + (player.level * 0.25)))
end
