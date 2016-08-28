-- @module battery
-- Awesome WM battery widget

-- {{{ Dependecies
local wibox = require("wibox")
-- }}}

local battery = {}

battery.widget = wibox.widget.textbox()
battery.timer = timer({timeout = 20})

function battery.init(adapter)
    battery.battery_info(adapter)

    battery.timer:connect_signal("timeout", function()
        battery.battery_info(adapter)
    end)
    battery.timer:start()
end

function battery.battery_info(adapter)
    spacer = " "

    local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")    
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")

    local cur = fcur:read()
    local cap = fcap:read()
    local sta = fsta:read()

    local charge_percent = math.floor(cur * 100 / cap)

    if sta:match("Charging") then
        dir = "^"
        charge_percent = "A/C ("..charge_percent..")"
    elseif sta:match("Discharging") then
        dir = "v"
        if tonumber(charge_percent) > 25 and tonumber(charge_percent) < 75 then
            charge_percent = charge_percent
        elseif tonumber(charge_percent) < 25 then
            if tonumber(charge_percent) < 10 then
                naughty.notify({ title      = "Battery Warning"
                            , text       = "Battery low!"..spacer..charge_percent.."%"..spacer.."left!"
                            , timeout    = 5
                            , position   = "top_right"
                            , fg         = beautiful.fg_focus
                            , bg         = beautiful.bg_focus
                            })
            end
            charge_percent = charge_percent
        else
            charge_percent = charge_percent
        end
    else
        dir = "="
        charge_percent = "A/C"
    end

    battery.widget:set_markup(spacer.."Bat:"..spacer..dir..charge_percent..dir..spacer)

    fcur:close()
    fcap:close()
    fsta:close()
end

return battery
