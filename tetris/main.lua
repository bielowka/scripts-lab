love.graphics.setDefaultFilter("nearest", "nearest")

local constants = require("constants")

local grid = {}
local rows, cols = constants.rows, constants.cols
local pixelSize = constants.pixelSize
local dropInterval = constants.dropInterval
local saveFile = constants.saveFile

local currentBlock
local gameOver = false
local score = 0
local dropTimer = 0

local moveSound
local spawnSound
local clearLineSound
local gameOverSound

local blocks = {
    {{1, 1, 1}, {0, 1, 0}},  -- T
    {{1, 1, 1, 1}},          -- I
    {{1, 1}, {1, 1}},        -- O
    {{1, 1, 0}, {0, 1, 1}}   -- Z
}

local function newBlock()
    love.audio.play(spawnSound)
    local shape = blocks[math.random(#blocks)]
    return {x = math.floor(cols / 2) - 1, y = 0, shape = shape}
end

local function rotateBlock(block)
    local newShape = {}
    for i = 1, #block.shape[1] do
        newShape[i] = {}
        for j = 1, #block.shape do
            newShape[i][j] = block.shape[#block.shape - j + 1][i]
        end
    end
    return { x = block.x, y = block.y, shape = newShape}
end

local function isValidPosition(block)
    for y = 1, #block.shape do
        for x = 1, #block.shape[y] do
            if block.shape[y][x] == 1 then
                local gx, gy = block.x + x, block.y + y
                if gx < 1 or gx > cols or gy > rows or (grid[gy] and grid[gy][gx] == 1) then
                    return false
                end
            end
        end
    end
    return true
end

local function mergeBlock()
    for y = 1, #currentBlock.shape do
        for x = 1, #currentBlock.shape[y] do
            if currentBlock.shape[y][x] == 1 then
                local gx, gy = currentBlock.x + x, currentBlock.y + y
                grid[gy][gx] = 1
            end
        end
    end
end

local function clearLines()
    for y = rows, 1, -1 do
        local full = true
        for x = 1, cols do
            if grid[y][x] == 0 then
                full = false
                break
            end
        end
        if full then
            table.remove(grid, y)
            table.insert(grid, 1, {})
            for x = 1, cols do
                grid[1][x] = 0
            end
            score = score + 100
            love.audio.play(clearLineSound)
        end
    end
end

local function moveBlock(dx, dy)
    local newBlockVal = { x = currentBlock.x + dx, y = currentBlock.y + dy, shape = currentBlock.shape}
    if isValidPosition(newBlockVal) then
        currentBlock = newBlockVal
    elseif dy > 0 then
        mergeBlock()
        clearLines()
        currentBlock = newBlock()
        if not isValidPosition(currentBlock) then
            love.audio.play(gameOverSound)
            gameOver = true
        end
    end
end

save_game = function()
    local f = io.open(saveFile, "w")
    if f then
        f:write("score = " .. score .. "\n")
        f:write("grid = {\n")
        for y = 1, rows do
            f:write("{")
            for x = 1, cols do
                f:write(grid[y][x] .. ",")
            end
            f:write("},\n")
        end
        f:write("}\n")
        f:close()
    end
end

load_game = function()
    local f = io.open(saveFile, "r")
    if f then
        local line = f:read("*l")
        while line do
            local key, value = line:match("(%w+) = (.+)")
            if key == "score" then
                score = tonumber(value)
            elseif key == "grid" then
                for y = 1, rows do
                    line = f:read("*l")
                    local x = 1
                    for value in line:gmatch("(%d),") do
                        grid[y][x] = tonumber(value)
                        x = x + 1
                    end
                end
            end
            line = f:read("*l")
        end
        f:close()
    end
end

function love.load()
    love.window.setTitle("Tetris")
    moveSound = love.audio.newSource("move.mp3", "static")
    spawnSound = love.audio.newSource("whoosh.wav", "static")
    clearLineSound = love.audio.newSource("swipe.wav", "static")
    gameOverSound = love.audio.newSource("gameover.wav", "static")

    for y = 1, rows do
        grid[y] = {}
        for x = 1, cols do
            grid[y][x] = 0
        end
    end
    currentBlock = newBlock()
end

function love.update(dt)
    if not gameOver then
        dropTimer = dropTimer + dt
        if dropTimer >= dropInterval then
            moveBlock(0, 1)
            dropTimer = 0
        end
    end
end

function love.draw()
    for y = 1, rows do
        for x = 1, cols do
            if grid[y][x] == 1 then
                love.graphics.rectangle("fill", (x - 1) * pixelSize, (y - 1) * pixelSize, pixelSize, pixelSize)
            end
        end
    end

    for y = 1, #currentBlock.shape do
        for x = 1, #currentBlock.shape[y] do
            if currentBlock.shape[y][x] == 1 then
                love.graphics.rectangle("fill", (currentBlock.x + x - 1) * pixelSize, (currentBlock.y + y - 1) * pixelSize, pixelSize, pixelSize)
            end
        end
    end
    love.graphics.print("Score: " .. score, 10, 10)
    if gameOver then
        love.graphics.print("Game Over", 100, 200)
    end
end

local function tableToString(tbl)
    local result = "{\n"
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            result = result .. key .. " = " .. tableToString(value) .. ",\n"
        elseif type(value) == "string" then
            result = result .. key .. " = \"" .. value .. "\",\n"
        else
            result = result .. key .. " = " .. tostring(value) .. ",\n"
        end
    end
    return result .. "}"
end

function love.keypressed(key)
    if key == "left" then
        love.audio.play(moveSound)
        moveBlock(-1, 0)
    elseif key == "right" then
        love.audio.play(moveSound)
        moveBlock(1, 0)
    elseif key == "down" then
        love.audio.play(moveSound)
        moveBlock(0, 1)
    elseif key == "up" then
        love.audio.play(moveSound)
        currentBlock = rotateBlock(currentBlock)
    elseif key == "s" then
        save_game()
    elseif key == "l" then
        love.load()
        load_game()
    elseif key == "r" then
        if not gameOver then
            love.load()
            score = 0
        end
    elseif key == "escape" then
        love.audio.play(gameOverSound)
        love.timer.sleep(1)
        love.event.quit()
    end
end