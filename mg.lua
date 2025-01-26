-- Load the SN-Lib UI Library
local SN_Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vFishyTurtle/SN-Lib/main/src"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local webhookURL = "" -- This will be set via the UI
local recipientName = ""
local amountToGive = 0

-- Admin check function
local function isAdmin(player)
    return player.UserId == 12345678 -- Replace with your UserId for admin check
end

-- Function to log transactions to a webhook
local function logTransaction(admin, recipient, amount)
    if webhookURL == "" then
        warn("Webhook URL not set!")
        return
    end

    local data = {
        ["username"] = "Money Logger",
        ["embeds"] = {{
            ["title"] = "Money Given",
            ["description"] = string.format("**Admin:** %s\n**Recipient:** %s\n**Amount:** %d", admin.Name, recipient.Name, amount),
            ["color"] = 0x00FF00, -- Green color
        }},
    }

    local success, error = pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Webhook failed: " .. tostring(error))
    end
end

-- Function to send a test message to the webhook
local function sendTestMessage()
    if webhookURL == "" then
        SN_Lib:Notify({
            Title = "Error",
            Content = "Webhook URL is not set!",
            Duration = 5,
        })
        return
    end

    local data = {
        ["username"] = "Test Bot",
        ["content"] = "This is a test message to verify your webhook.",
    }

    local success, error = pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        SN_Lib:Notify({
            Title = "Success",
            Content = "Test message sent successfully!",
            Duration = 5,
        })
    else
        SN_Lib:Notify({
            Title = "Error",
            Content = "Failed to send test message: " .. tostring(error),
            Duration = 5,
        })
    end
end

-- Create the GUI using SN-Lib
local Window = SN_Lib:CreateWindow({
    Name = "Money Giver Admin Panel",
    Size = UDim2.new(0, 500, 0, 400), -- Adjusted height to fit all components
    Pos = UDim2.new(0.5, -250, 0.5, -200), -- Centered window
    Title = "Money Giver Panel",
})

-- Create the Webhook URL TextBox
local webhookTextBox = Window:CreateTextBox({
    Name = "Webhook URL",
    PlaceholderText = "Enter Webhook URL",
    Callback = function(text)
        webhookURL = text
        SN_Lib:Notify({
            Title = "Webhook Set",
            Content = "Webhook URL has been updated!",
            Duration = 5,
        })
    end,
})

-- Create the Test Message Button
Window:CreateButton({
    Name = "Test Message",
    Callback = function()
        sendTestMessage() -- Trigger the test message function
    end,
})

-- Create the Recipient Username TextBox
local recipientTextBox = Window:CreateTextBox({
    Name = "Recipient Username",
    PlaceholderText = "Enter Recipient Username",
    Callback = function(text)
        recipientName = text
    end,
})

-- Create the Amount TextBox
local amountTextBox = Window:CreateTextBox({
    Name = "Amount",
    PlaceholderText = "Enter Amount to Give",
    Callback = function(text)
        amountToGive = tonumber(text)
    end,
})

-- Create the Give Money Button
Window:CreateButton({
    Name = "Give Money",
    Callback = function()
        local player = Players.LocalPlayer

        -- Admin check
        if not isAdmin(player) then
            SN_Lib:Notify({
                Title = "Permission Denied",
                Content = "You are not authorized to use this tool.",
                Duration = 5,
            })
            return
        end

        -- Check if webhook URL is set
        if webhookURL == "" then
            SN_Lib:Notify({
                Title = "Error",
                Content = "Webhook URL is not set!",
                Duration = 5,
            })
            return
        end

        -- Validate recipient
        local recipient = Players:FindFirstChild(recipientName)
        if not recipient then
            SN_Lib:Notify({
                Title = "Error",
                Content = "Recipient not found!",
                Duration = 5,
            })
            return
        end

        -- Validate amount
        if not amountToGive or amountToGive <= 0 then
            SN_Lib:Notify({
                Title = "Error",
                Content = "Invalid amount!",
                Duration = 5,
            })
            return
        end

        -- Add money to recipient
        local leaderstats = recipient:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Money") then
            leaderstats.Money.Value = leaderstats.Money.Value + amountToGive
            SN_Lib:Notify({
                Title = "Success",
                Content = string.format("Gave %d to %s.", amountToGive, recipient.Name),
                Duration = 5,
            })

            -- Log the transaction
            logTransaction(player, recipient, amountToGive)
        else
            SN_Lib:Notify({
                Title = "Error",
                Content = "Recipient does not have a 'Money' field.",
                Duration = 5,
            })
        end
    end,
})
