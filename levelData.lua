local levelData = {}

levelData[1] = {
    name = "tutorial 1",
    worldHeight = 1000,
    worldWidth = 4000,
    meter = 64,
    scaleFactor = 100,
    gravityY = 500,
    gravityX = 0,
    floors = {
        [1] = { x = 2000, y = 1000, width = 4000, height = 50, friction = 0.25, colour = { r = 102, g = 102, b = 102, a = 255 } },
        [2] = { x = 100, y = 150, width = 100, height = 50, friction = 0.75, colour = { r = 255, g = 0, b = 255, a = 155 } }
    },
    walls = {
        [1] = { x = 25, y = 500, width = 50, height = 1000, colour = { r = 102, g = 102, b = 102 } },
        [2] = { x = 3975, y = 500, width = 50, height = 1000, colour = { r = 102, g = 102, b = 102 } }
    },
    backGround = "Background_Level1.png",
    finishFlag = {
        x = 3800,
        y = 950,
        width = 30,
        height = 50,
        colour = { r = 255, g = 0, b = 0 }
    },
    obstacles = {
        [1] = { x = 400, y = 950, width = 50, height = 50, type = "static", friction = 0.25, colour = { r = 178.5, g = 178.5, b = 178.5 } },
        [2] = { x = 600, y = 950, width = 60, height = 20, type = "static", friction = 0.25, colour = { r = 178.5, g = 178.5, b = 178.5 } },
        [3] = { x = 1200, y = 850, width = 150, height = 20, type = "dynamic", friction = 0.3, colour = { r = 128, g = 128, b = 128 } },
        [4] = { x = 1000, y = 900, width = 120, height = 30, type = "static", friction = 0.4, colour = { r = 102, g = 102, b = 255 } },
        [5] = { x = 1400, y = 850, width = 50, height = 150, type = "dynamic", friction = 0.75, colour = { r = 255, g = 102, b = 102 } },
        [6] = { x = 1800, y = 950, width = 80, height = 20, type = "static", friction = 0.1, colour = { r = 255, g = 204, b = 51 } },
        [7] = { x = 2200, y = 800, width = 100, height = 20, type = "dynamic", friction = 0.5, colour = { r = 76, g = 175, b = 80 } },
        [8] = { x = 2600, y = 950, width = 60, height = 60, type = "static", friction = 0.25, colour = { r = 139, g = 69, b = 19 } },
    },
    playerCharacter = {
        x = 100,
        y = 100,
        size = 25,
        radius = 25,
        friction = 2,
        mass = 25,
        rotationalPower = 5000,
        gravitationalPower = 1
    },
    ballSkin = "DR.Paint_Saved_Image_32.png",
    ballDiameter = 1,
}

levelData[2] = {
    name = "tutorial 2",
    worldHeight = 1000,
    worldWidth = 4000,
    meter = 64,
    scaleFactor = 100,
    gravityY = 250,
    gravityX = 0,
    floors = {
        [1] = { x = 2000, y = 1000, width = 4000, height = 50, friction = 0.5, colour = { r = 102, g = 102, b = 102 } }
    },
    walls = {
        [1] = { x = 25, y = 500, width = 50, height = 1000, colour = { r = 102, g = 102, b = 102 } },
        [2] = { x = 3975, y = 500, width = 50, height = 1000, colour = { r = 102, g = 102, b = 102 } }
    },
    backGround = "Background_Level2.png",
    finishFlag = {
        x = 3800,
        y = 400,
        width = 30,
        height = 50,
        colour = { r = 255, g = 0, b = 0 }
    },
    obstacles = {
        [1] = { x = 300, y = 950, width = 40, height = 40, type = "static", friction = 0.5, colour = { r = 178.5, g = 178.5, b = 178.5 } },
        [2] = { x = 500, y = 906, width = 80, height = 20, type = "dynamic", friction = 0.5, colour = { r = 178.5, g = 178.5, b = 178.5 } },
        [3] = { x = 900, y = 880, width = 60, height = 10, type = "dynamic", friction = 0.3, colour = { r = 192, g = 128, b = 64 } },
        [4] = { x = 1000, y = 897, width = 100, height = 20, type = "dynamic", friction = 0.3, colour = { r = 255, g = 153, b = 51 } },
        [5] = { x = 1200, y = 842, width = 30, height = 150, type = "static", friction = 0.6, colour = { r = 102, g = 153, b = 255 } },
        [6] = { x = 1400, y = 915, width = 50, height = 50, type = "static", friction = 0.8, colour = { r = 153, g = 255, b = 153 } },
        [7] = { x = 1600, y = 900, width = 120, height = 30, type = "dynamic", friction = 0.4, colour = { r = 255, g = 102, b = 178 } },
        [8] = { x = 1800, y = 950, width = 60, height = 15, type = "static", friction = 0.3, colour = { r = 255, g = 204, b = 0 } },
        [9] = { x = 2400, y = 850, width = 200, height = 20, type = "dynamic", friction = 0.4, colour = { r = 64, g = 64, b = 192 } },
    },
    playerCharacter = {
        x = 150,
        y = 100,
        size = 25,
        radius = 25,
        friction = 2.5,
        mass = 50,
        rotationalPower = 5000,
        gravitationalPower = 100
    },
    ballSkin = "DR.Paint_Saved_Image_32.png",
    ballDiameter = 1,
}

return levelData
