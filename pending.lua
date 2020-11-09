PendingIndicator = PendingIndicator or {}

local window_name = "pending_indicator_console"

function PendingIndicator:show()

    local window_width, window_height = getMainWindowSize()
    local height = 70
    local width = window_width - 30

    self.container = Geyser.Container:new({
        name = "pending_indicator",
        x = 0, y = 0,
        width = width, height = height
    })

    self.window = Geyser.MiniConsole:new({
        name = window_name,
        width = "100%", height = height,
        autoWrap = true,
        color = "dim_gray",
        scrollBar = false,
        fontSize = 14,
    }, self.container)

    local int = 0
    local base = "       Pobieram edytor. Moze to troche potrwac"
    self.timer = tempTimer(0.2, function() 
        clearUserWindow(window_name)
        cecho(window_name, "\n")
        cecho(window_name, "<green:dim_gray>" .. base .. string.rep(".", int))
        int = int + 1
        if int > 3 then
            int = 0
        end
    end, true)

end

function PendingIndicator:hide()
    killTimer(self.timer)
    self.container:hide()
end