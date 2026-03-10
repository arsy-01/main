local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- [ VARIABEL GLOBAL ]
-- ==========================================
local webhookUrl = "" 
local webhookEnabled = false 
local selectedTiers = {} 

-- ==========================================
-- 1. KAMUS DATA TIER & ASSET ID
-- ==========================================
local tierDataList = {}
local tierToName = {}

local tiersModule = ReplicatedStorage:WaitForChild("Tiers", 5)
if tiersModule and tiersModule:IsA("ModuleScript") then
    local success, tData = pcall(require, tiersModule)
    if success and type(tData) == "table" then
        for _, data in pairs(tData) do
            if type(data) == "table" and data.Name and type(data.Tier) == "number" then
                table.insert(tierDataList, {level = data.Tier, name = data.Name})
                tierToName[data.Tier] = data.Name
            end
        end
        table.sort(tierDataList, function(a, b) return a.level < b.level end)
    end
end

if #tierDataList == 0 then
    tierDataList = {
        {level = 1, name = "Common"}, {level = 2, name = "Uncommon"}, {level = 3, name = "Rare"},
        {level = 4, name = "Epic"}, {level = 5, name = "Legendary"}, {level = 6, name = "Mythic"},
        {level = 7, name = "SECRET"}, {level = 8, name = "FORGOTTEN"}
    }
    for _, t in ipairs(tierDataList) do tierToName[t.level] = t.name end
end

local fishDictionary = {}

task.spawn(function()
    local itemsFolder = ReplicatedStorage:WaitForChild("Items", 10)
    if not itemsFolder then return end
    task.wait(1) 
    
    for _, instance in ipairs(itemsFolder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, data = pcall(require, instance)
            if success and type(data) == "table" and data.Data and data.Data.Type == "Fish" and data.Data.Name then
                local assetId = nil
                local rawIconData = data.Data.Icon or data.Data.Image or data.Data.ThumbnailId
                if rawIconData then
                    assetId = string.match(tostring(rawIconData), "%d+")
                end

                fishDictionary[string.lower(data.Data.Name)] = {
                    Tier = data.Data.Tier or 1,
                    AssetId = assetId
                }
            end
        end
    end
    print("[Arsy] Sistem Kamus Siap.")
end)

-- ==========================================
-- 2. FUNGSI PENGIRIMAN DISCORD
-- ==========================================
local function SendToDiscord(pName, fName, fTier, fWeight, fMutation, fChance, fAssetId)
    local request = http_request or request or HttpPost or syn.request
    if not request or webhookUrl == "" then return end
    
    local rarityName = tierToName[fTier] or ("Tier " .. tostring(fTier))
    local cleanChance = string.gsub(fChance, " in ", "/")
    local combinedRarity = rarityName .. " | " .. cleanChance
    
    local finalImageUrl = ""
    if fAssetId then
        local success, res = pcall(function()
            return request({
                Url = "https://thumbnails.roproxy.com/v1/assets?assetIds=" .. fAssetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false",
                Method = "GET"
            })
        end)
        if success and res and res.Body then
            local s2, jsonData = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if s2 and jsonData and jsonData.data and jsonData.data[1] and jsonData.data[1].imageUrl then
                finalImageUrl = jsonData.data[1].imageUrl
            end
        end
        if finalImageUrl == "" then
            finalImageUrl = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. fAssetId .. "&width=420&height=420&format=png"
        end
    end

    local embedToSend = {
        ["title"] = "New Fish Caught!",
        ["color"] = tonumber(0x0A84FF),
        ["fields"] = {
            { ["name"] = "Player Name", ["value"] = "||**" .. pName .. "**||", ["inline"] = false },
            { ["name"] = "Fish Name", ["value"] = "**" .. fName .. "**", ["inline"] = false },
            
            { ["name"] = "Rarity ㅤ ㅤ ㅤ", ["value"] = combinedRarity, ["inline"] = true },
            { ["name"] = "Weight ㅤ ㅤ ㅤ", ["value"] = fWeight, ["inline"] = true },
            { ["name"] = "Mutation", ["value"] = fMutation, ["inline"] = true }
        },
        -- MENGGUNAKAN NATIVE DISCORD TIMESTAMP (Otomatis menyesuaikan dengan jam perangkat yang buka Discord)
        ["footer"] = { ["text"] = "Arsy Server Notification" },
        ["timestamp"] = DateTime.now():ToIsoDate()
    }

    if finalImageUrl ~= "" then
        embedToSend["thumbnail"] = { ["url"] = finalImageUrl }
    end

    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({["content"] = "", ["embeds"] = {embedToSend}})
    })
end

local function SendConnectionNotif()
    local request = http_request or request or HttpPost or syn.request
    if not request or webhookUrl == "" then return end
    
    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            ["content"] = "", 
            ["embeds"] = {{
                ["title"] = "System Connected", 
                ["description"] = "Arsy Server Notification is actively monitoring chat.", 
                ["color"] = tonumber(0x32D74B),
                -- NATIVE TIMESTAMP
                ["footer"] = { ["text"] = "Arsy Server Notification" },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        })
    })
end

-- ==========================================
-- 3. UI KONTROL
-- ==========================================
local guiName = "ArsyNotificationUI"
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
if parentGui:FindFirstChild(guiName) then parentGui[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 0) 
MainFrame.Position = UDim2.new(0.5, 120, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26) 
MainFrame.BackgroundTransparency = 0.1
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(60, 60, 65)
stroke.Thickness = 1

local Layout = Instance.new("UIListLayout", MainFrame)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6) 

local Padding = Instance.new("UIPadding", MainFrame)
Padding.PaddingTop = UDim.new(0, 8)
Padding.PaddingBottom = UDim.new(0, 8)
Padding.PaddingLeft = UDim.new(0, 8)
Padding.PaddingRight = UDim.new(0, 8)

local HeaderFrame = Instance.new("Frame", MainFrame)
HeaderFrame.Size = UDim2.new(1, 0, 0, 10)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.LayoutOrder = 1

local CloseBtn = Instance.new("TextButton", HeaderFrame)
CloseBtn.Size = UDim2.new(0, 8, 0, 8) 
CloseBtn.Position = UDim2.new(0, 0, 0.5, 0)
CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 86) 
CloseBtn.Text = ""
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local HeaderTitle = Instance.new("TextLabel", HeaderFrame)
HeaderTitle.Size = UDim2.new(1, -12, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Arsy Server Notification"
HeaderTitle.TextColor3 = Color3.fromRGB(150, 150, 155) 
HeaderTitle.Font = Enum.Font.Gotham
HeaderTitle.TextSize = 9 
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Right 

local ComboFrame = Instance.new("Frame", MainFrame)
ComboFrame.Size = UDim2.new(1, 0, 0, 22) 
ComboFrame.BackgroundTransparency = 1
ComboFrame.LayoutOrder = 2
local ComboLayout = Instance.new("UIListLayout", ComboFrame)
ComboLayout.FillDirection = Enum.FillDirection.Horizontal
ComboLayout.SortOrder = Enum.SortOrder.LayoutOrder
ComboLayout.Padding = UDim.new(0, 6)

local WebhookInput = Instance.new("TextBox", ComboFrame)
WebhookInput.Size = UDim2.new(0.74, -3, 1, 0) 
WebhookInput.BackgroundColor3 = Color3.fromRGB(36, 36, 38) 
WebhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WebhookInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
WebhookInput.PlaceholderText = "Paste Webhook URL..."
WebhookInput.Text = ""
WebhookInput.Font = Enum.Font.Gotham
WebhookInput.TextSize = 10
WebhookInput.TextXAlignment = Enum.TextXAlignment.Left
WebhookInput.ClearTextOnFocus = false
WebhookInput.ClipsDescendants = true
Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 4)
local inputPad = Instance.new("UIPadding", WebhookInput)
inputPad.PaddingLeft = UDim.new(0, 6)
inputPad.PaddingRight = UDim.new(0, 6)
WebhookInput:GetPropertyChangedSignal("Text"):Connect(function() webhookUrl = WebhookInput.Text end)

local ToggleBtn = Instance.new("TextButton", ComboFrame)
ToggleBtn.Size = UDim2.new(0.26, -3, 1, 0) 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 10
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

ToggleBtn.MouseButton1Click:Connect(function()
    webhookEnabled = not webhookEnabled
    if webhookEnabled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 215, 75) 
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SendConnectionNotif()
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

local DropdownFrame = Instance.new("Frame", MainFrame)
DropdownFrame.Size = UDim2.new(1, 0, 0, 22)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
DropdownFrame.ClipsDescendants = true
DropdownFrame.LayoutOrder = 3 
Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 4)

local DropdownBtn = Instance.new("TextButton", DropdownFrame)
DropdownBtn.Size = UDim2.new(1, 0, 0, 22)
DropdownBtn.BackgroundTransparency = 1
DropdownBtn.Text = "Select Target Tiers ▼"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 10
DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
local dropPad = Instance.new("UIPadding", DropdownBtn)
dropPad.PaddingLeft = UDim.new(0, 6)

local function UpdateDropdownText()
    local selectedNames = {}
    for _, tData in ipairs(tierDataList) do
        if selectedTiers[tData.level] then table.insert(selectedNames, tData.name) end
    end
    if #selectedNames > 0 then
        local joinedText = table.concat(selectedNames, ", ")
        DropdownBtn.Text = string.len(joinedText) > 28 and (string.sub(joinedText, 1, 25) .. "... ▼") or (joinedText .. " ▼")
    else
        DropdownBtn.Text = "Select Target Tiers ▼"
    end
end

local ListPanel = Instance.new("Frame", DropdownFrame)
ListPanel.Size = UDim2.new(1, 0, 0, 100) 
ListPanel.Position = UDim2.new(0, 0, 0, 22)
ListPanel.BackgroundTransparency = 1
ListPanel.Visible = false

local ScrollFrame = Instance.new("ScrollingFrame", ListPanel)
ScrollFrame.Size = UDim2.new(1, -6, 1, -4)
ScrollFrame.Position = UDim2.new(0, 3, 0, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.BorderSizePixel = 0

local ScrollLayout = Instance.new("UIListLayout", ScrollFrame)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0, 2)

for _, tierData in ipairs(tierDataList) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Size = UDim2.new(1, 0, 0, 20) 
    itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemBtn.Text = tierData.name
    itemBtn.Font = Enum.Font.Gotham
    itemBtn.TextSize = 10
    Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
    itemBtn.Parent = ScrollFrame
    
    itemBtn.MouseButton1Click:Connect(function()
        if selectedTiers[tierData.level] then
            selectedTiers[tierData.level] = false
            itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        else
            selectedTiers[tierData.level] = true
            itemBtn.BackgroundColor3 = Color3.fromRGB(10, 132, 255) 
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        UpdateDropdownText()
    end)
end

ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y)
end)

DropdownBtn.MouseButton1Click:Connect(function() ListPanel.Visible = not ListPanel.Visible end)

-- ==========================================
-- 4. MESIN PENYADAP CHAT
-- ==========================================
local recentMessages = {} 

local function checkMessage(rawMsg)
    if not webhookEnabled or webhookUrl == "" or not rawMsg or rawMsg == "" then return end
    
    local cleanMsg = string.gsub(rawMsg, "<[^>]+>", "")
    cleanMsg = string.gsub(cleanMsg, "[\194\160]", " ")
    cleanMsg = string.gsub(cleanMsg, "%s+", " ")
    local lowerMsg = string.lower(cleanMsg)
    
    if not string.find(lowerMsg, "%[server%]:") or not string.find(lowerMsg, "obtained") then return end
    if recentMessages[lowerMsg] then return end

    local foundBaseName = nil
    local foundTier = nil
    local foundAssetId = nil

    for dictName, fishData in pairs(fishDictionary) do
        if string.find(lowerMsg, dictName, 1, true) then
            if not foundBaseName or string.len(dictName) > string.len(foundBaseName) then
                foundBaseName = dictName
                foundTier = fishData.Tier
                foundAssetId = fishData.AssetId
            end
        end
    end

    if foundBaseName then
        if selectedTiers[foundTier] then
            recentMessages[lowerMsg] = true
            task.delay(10, function() recentMessages[lowerMsg] = nil end)
            
            local playerName = string.match(cleanMsg, "%[Server%]:%s*([^%s]+)") or "Unknown"
            local itemStr = string.match(cleanMsg, "obtained%s+an?%s+(.-)%s+with") or ""
            local chance = string.match(cleanMsg, "with%s+a%s+(.-)%s+chance") or "N/A"
            
            local fullFishName, weight = string.match(itemStr, "^(.-)%s*%((.-)%)%s*$")
            if not fullFishName then
                fullFishName = itemStr
                weight = "N/A"
            end

            fullFishName = string.match(fullFishName, "^%s*(.-)%s*$") or fullFishName
            
            local mutation = "None"
            local pureFishName = fullFishName
            local s_start, s_end = string.find(string.lower(fullFishName), foundBaseName, 1, true)
            
            if s_start and s_start > 1 then
                mutation = string.sub(fullFishName, 1, s_start - 2)
                pureFishName = string.sub(fullFishName, s_start)
                if mutation == "" then mutation = "None" end
            end

            SendToDiscord(playerName, pureFishName, foundTier, weight, mutation, chance, foundAssetId)
        end
    end
end

-- ==========================================
-- HOOK LANGSUNG KE JANTUNG SERVER CHAT
-- ==========================================
local function StartChatRadar()
    pcall(function() 
        game:GetService("TextChatService").MessageReceived:Connect(function(t) 
            checkMessage((t.PrefixText or "") .. " " .. (t.Text or "")) 
        end) 
    end)
    pcall(function() 
        local ce = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5)
        if ce then 
            ce:WaitForChild("OnMessageDoneFiltering", 5).OnClientEvent:Connect(function(d) 
                checkMessage((d.FromSpeaker or "") == "" and ("["..d.OriginalChannel.."] "..d.Message) or ("["..d.OriginalChannel.."] "..d.FromSpeaker..": "..d.Message)) 
            end) 
        end 
    end)
end

StartChatRadar()
