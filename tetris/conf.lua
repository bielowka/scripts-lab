local constants = require("constants")

function love.conf(t)
    t.window.width = constants.cols * constants.pixelSize
    t.window.height = constants.rows * constants.pixelSize
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.borderless = false
    t.identity = "tetris_save"
end