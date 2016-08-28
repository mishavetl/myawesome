-- @module activeram
-- Awesome WM ActiveRAM widget

local wibox = require("wibox")

activeram = {}
activeram.widget = wibox.widget.textbox()
activeram.timer = timer({ timeout = 10 })

function activeram.update()
    local active
    for line in io.lines('/proc/meminfo') do
        for key, value in string.gmatch(line, "(%w+):\ +(%d+).+") do
            if key == "Active" then active = tonumber(value) end
        end
    end

    activeram.widget:set_markup(string.format(" %.2fMB ", (active / 1024)))
end

function activeram.init()
    activeram.update()
    activeram.timer:connect_signal("timeout", function () activeram.update() end)
    activeram.timer:start()
end

return activeram
