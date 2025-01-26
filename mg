local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Variables for webhook and money-giver inputs
local webhookURL = "" -- This will be set via the GUI
local recipientName = ""
local amountToGive = 0

-- Admin check function
local function isAdmin(player)
    return player.UserId == 12345678 -- Replace with your admin UserId
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
            ["color"] = 0x00FF00, -- Green
        }},
    }

    local success, error = pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Webhook failed: " .. tostring(error))
    end
end

-- Initialize Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Money Giver Admin Panel",
    LoadingTitle = "Loading Admin Panel",
    LoadingSubtitle = "Please wait...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MoneyGiver", -- Saved configurations folder
        FileName = "AdminConfig", -- Saved configurations file
    },
    KeySystem = false,
})

-- Webhook setup
Window:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Enter your Discord webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        webhookURL = text
        Rayfield:Notify({
            Title = "Webhook Set",
            Content = "Webhook URL has been updated!",
            Duration = 5,
            Image = 4483362458,
        })
    end,
})

-- Input for recipient name
Window:CreateInput({
    Name = "Recipient Username",
    PlaceholderText = "Enter recipient's name",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        recipientName = text
    end,
})

-- Input for amount
Window:CreateInput({
    Name = "Amount",
    PlaceholderText = "Enter amount to give",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        amountToGive = tonumber(text)
    end,
})

-- Button to give money
Window:CreateButton({
    Name = "Give Money",
    Callback = function()
        local player = Players.LocalPlayer

        -- Check if the player is an admin
        if not isAdmin(player) then
            Rayfield:Notify({
                Title = "Permission Denied",
                Content = "You are not authorized to use this tool.",
                Duration = 5,
                Image = 4483362458,
            })
            return
        end

        -- Validate inputs
        if webhookURL == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Webhook URL is not set!",
                Duration = 5,
                Image = 4483362458,
            })
            return
        end

        local recipient = Players:FindFirstChild(recipientName)
        if not recipient then
            Rayfield:Notify({
                Title = "Error",
                Content = "Recipient not found!",
                Duration = 5,
                Image = 4483362458,
            })
            return
        end

        if not amountToGive or amountToGive <= 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid amount!",
                Duration = 5,
                Image = 4483362458,
            })
            return
        end

        -- Update recipient's money
        local leaderstats = recipient:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Money") then
            leaderstats.Money.Value = leaderstats.Money.Value + amountToGive
            Rayfield:Notify({
                Title = "Success",
                Content = string.format("Gave %d to %s.", amountToGive, recipient.Name),
                Duration = 5,
                Image = 4483362458,
            })

            -- Log the transaction
            logTransaction(player, recipient, amountToGive)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Recipient does not have a 'Money' field.",
                Duration = 5,
                Image = 4483362458,
            })
        end
    end,
})