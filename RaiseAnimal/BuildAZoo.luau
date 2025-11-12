----------------------------------- UI Setup -----------------------------------
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Window = MacLib:Window({
    Title = "FleXiZ Script",
    Subtitle = "Build A Zoo by FleXIZ",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 2,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.K,
})

----------------------------------- Variable -----------------------------------
local Collection = {}; Collection.__index = Collection
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserId = game:GetService("Players").LocalPlayer.UserId
local Pets = workspace.Pets
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Art = workspace.Art
local PlayerGui = LocalPlayer.PlayerGui
local ScreenFoodStore = PlayerGui.ScreenFoodStore
local ReplicatedStorage = game.ReplicatedStorage
local Remote = ReplicatedStorage:WaitForChild("Remote")
local CharacterRE = Remote:WaitForChild("CharacterRE")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Data = PlayerGui.Data
local FoodStoreLST = Data.FoodStore.LST
local FoodStoreRE = Remote.FoodStoreRE
local PetRE = Remote.PetRE
local Asset = Data.Asset
local selectedNormalEgg = {}
local selectedMutateEgg = {}
local selectedMutate = {}
local selectedFood = {}
local RootScreenFoodStore = PlayerGui.ScreenFoodStore.Root
local selectedFeed = {}
----------------------------------- Config -------------------------------------
local AutoCollect = {
    toggle = false,
    interval = 1,
    running = false
}
local AutoBuy = {
    normalToggle = false,
    mutateToggle = false,
    normalinterval = 1,
    mutateinterval = 1,
    normalRunning = false,
    mutateRunning = false,

}
local AutoBuyFoodConfig = {
    toggle = false,
    interval = 1,
    running = false
}
local AutoFeedConfig = {
    toggle = false,
    interval = 1,
    running = false
}
local AntiAFKConfig = {
    toggle = false,
    interval = 60 * 15,
    running = false
}
local eggList = {
    "Basic Egg", "Rare Egg", "Super Rare Egg", "Epic Egg", "Legend Egg", "Prismatic Egg", "Hyper Egg", "Dark Goaty Egg",
    "Void Egg", "Rhino Rock Egg",
    "Snow Bunny Egg", "Demon Egg", "Bowser Egg", "Corn Egg", "Bonedragon Egg", "Ultra Egg", "Unicorn Egg",
    "Unicorn Pro Egg", "Saber Cub Egg",
    "General Kong Egg", "Kaiju Egg", "Sly Fox Egg", "Axe Shark Egg",
}
local mutateList = {
    "Golden", "Diamond", "Electric", "Fire", "Jurassic", "Snow", "Halloween"
}
local foodList = {
    "Strawberry", "Blueberry", "Watermelon", "Apple", "Orange", "Corn", "Banana", "Grape", "Pear", "Pineapple"
, "DragonFruit", "GoldMango", "BloodstoneCycad", "ColossalPinecone", "VoltGinkgo", "DeepseaPearlFruit",
    "CandyCorn", "Durian", "Pumpkin", "Franken Kiwi",
}
----------------------------------- Function -----------------------------------

function Collection:getMoney()
    if AutoCollect.running then
        return
    end
    AutoCollect.running = true
    task.spawn(function()
        while AutoCollect.toggle do
            local timeObj = ReplicatedStorage:WaitForChild("Time")

            -- รอให้ Time object มีค่า security attribute "s"
            local securityValue = timeObj:GetAttribute("s")
            if not securityValue then
                -- รอให้ attribute มีค่า
                timeObj:GetAttributeChangedSignal("s"):Wait()
                securityValue = timeObj:GetAttribute("s")
            end

            -- รอให้ Time.Value มีค่า (ต้องมากกว่า 0)
            local timeValue = timeObj.Value
            while timeValue <= 0 and AutoCollect.toggle do
                task.wait(0.1)
                timeValue = timeObj.Value
            end
            if not AutoCollect.toggle then
                return
            end
            local UserId = LocalPlayer.UserId

            local claimValue = bit32.bxor(UserId, securityValue, timeValue)

            local claimedCount = 0
            for i, v in pairs(Pets:GetChildren()) do
                if not AutoCollect.toggle then
                    break
                end
                if v:GetAttribute("UserId") == UserId then
                    local petRE = v:FindFirstChild("RE")
                    if petRE then
                        petRE:FireServer("Claim", claimValue)
                        claimedCount = claimedCount + 1
                    end
                end
            end

            if claimedCount > 0 then
                print("เก็บเงินจาก " .. claimedCount .. " ตัว")
            else
                print("ไม่พบ pet ที่สามารถเก็บเงินได้")
            end
            task.wait(tonumber(AutoCollect.interval))
        end
        AutoCollect.running = false
    end)
end

function Collection:BuyNormalEgg(name)
    for i, island in pairs(Art:GetChildren()) do
        if island:GetAttribute("OccupyingPlayerId") == UserId then
            if island:FindFirstChild("ENV") then
                local conveyor = island.ENV:FindFirstChild("Conveyor")
                if conveyor then
                    local belt = conveyor:FindFirstChild("Belt", true)
                    if belt then
                        for j, v in pairs(belt:GetChildren()) do
                            if v:FindFirstChild("RootPart") then
                                local eggGUI = v.RootPart:FindFirstChild("GUI/EggGUI")
                                if eggGUI and eggGUI.EggName.Text == name then
                                    local args = {
                                        "BuyEgg",
                                        v.Name
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild(
                                        "CharacterRE"):FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Collection:BuyWithMutateEgg(name, mutate)
    for i, island in pairs(Art:GetChildren()) do
        if island:GetAttribute("OccupyingPlayerId") == UserId then
            if island:FindFirstChild("ENV") then
                local conveyor = island.ENV:FindFirstChild("Conveyor")
                if conveyor then
                    local belt = conveyor:FindFirstChild("Belt", true)
                    if belt then
                        for j, v in pairs(belt:GetChildren()) do
                            if v:FindFirstChild("RootPart") then
                                local eggGUI = v.RootPart:FindFirstChild("GUI/EggGUI")
                                if eggGUI and eggGUI.EggName.Text == name and eggGUI.Mutate.Text == mutate then
                                    local args = {
                                        "BuyEgg",
                                        v.Name
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild(
                                        "CharacterRE"):FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Collection:AutoBuyNormalEgg()
    task.spawn(function()
        while AutoBuy.normalToggle do
            for _, name in pairs(selectedNormalEgg) do
                Collection:BuyNormalEgg(name)
            end
            task.wait(tonumber(AutoBuy.normalinterval))
        end
    end)
end

function Collection:AutoBuyWithMutateEgg()
    task.spawn(function()
        while AutoBuy.mutateToggle do
            for _, name in pairs(selectedMutateEgg) do
                for _, mutate in pairs(selectedMutate) do
                    Collection:BuyWithMutateEgg(name, mutate)
                end
            end
            task.wait(tonumber(AutoBuy.mutateinterval))
        end
    end)
end

-- function Collection:autoBuyFood()
--     task.spawn(function()
--         while true do
--             if AutoBuyFoodConfig.toggle then
--                 for _, v in pairs(foodShopUI:GetChildren()) do
--                     local foodFrame = v:FindFirstChild("ButtonsFrame")
--                     if foodFrame then
--                         for _, stock in pairs(foodFrame:GetChildren()) do
--                             if stock.Name == "BuyButton" then
--                                 local canBuy = stock.Visible
--                                 if canBuy then
--                                     for _, buyFood in pairs(selectedFood) do
--                                         if v.Name == buyFood then
--                                             local args = {
--                                                 v.Name
--                                             }
--                                             game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild(
--                                                 "FoodStoreRE")
--                                                 :FireServer(unpack(args))
--                                         end
--                                     end
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--             task.wait(tonumber(AutoBuyFoodConfig.interval))
--         end
--     end)
-- end


function Collection:autoBuyFood()
    task.spawn(function()
        if AutoBuyFoodConfig.running then
            return
        end
        AutoBuyFoodConfig.running = true
        while true do
            if AutoBuyFoodConfig.toggle then
                for _, foodName in pairs(selectedFood) do
                    local amount = FoodStoreLST:GetAttribute(foodName)
                    if amount and amount > 0 then
                        FoodStoreRE:FireServer(foodName)
                    end
                end
                task.wait(tonumber(AutoBuyFoodConfig.interval))
            end
            task.wait()
        end
        AutoBuyFoodConfig.running = false
    end)
end

-- function Collection:AutoFeed()
--     if AutoFeedConfig.running then
--         return
--     end
--     AutoFeedConfig.running = true
--     task.spawn(function()
--         while true do
--             if AutoFeedConfig.toggle then
--                 for _, feedName in pairs(selectedFeed) do
--                     for i, v in pairs(Pets:GetChildren()) do
--                         local bigPetsGUI = v:FindFirstChild("GUI/BigPetGUI")
--                         if bigPetsGUI then
--                             local feed = bigPetsGUI.Feed
--                             if feed then
--                                 local feedCD = feed.TXT
--                                 if feedCD.Text == "00:00" or feedCD.Text == "???" then
--                                     print("กำลังให้อาหาร Big Pets")
--                                     local args = {
--                                         "Focus",
--                                         feedName
--                                     }
--                                     game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild(
--                                         "CharacterRE"):FireServer(unpack(args))
--                                     task.wait(1)
--                                     local args = {
--                                         "Feed",
--                                         v.Name
--                                     }
--                                     game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PetRE")
--                                         :FireServer(unpack(args))
--                                     task.wait(1)
--                                     local args = {
--                                         "Focus"
--                                     }
--                                     game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild(
--                                         "CharacterRE"):FireServer(unpack(args))
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--             task.wait(tonumber(AutoFeedConfig.interval))
--         end
--         AutoFeedConfig.running = false
--     end)
-- end



function Collection:AutoFeed()
    task.spawn(function()
        if AutoFeedConfig.running then
            return
        end
        AutoFeedConfig.running = true
        while true do
            if AutoFeedConfig.toggle then
                for _, feedName in pairs(selectedFeed) do
                    local amount = Asset:GetAttribute(feedName)
                    for i, v in pairs(Pets:GetChildren()) do
                        local bigPetsGUI = v:FindFirstChild("GUI/BigPetGUI")
                        if bigPetsGUI then
                            local feed = bigPetsGUI.Feed
                            if feed then
                                local feedCD = feed.TXT
                                if feedCD.Text == "00:00" or feedCD.Text == "???" then
                                    if amount and amount > 0 then
                                        print("กำลังให้อาหาร Big Pets")
                                        CharacterRE:FireServer("Focus", feedName)
                                        task.wait(1)
                                        PetRE:FireServer("Feed", v.Name)
                                        task.wait(1)
                                        CharacterRE:FireServer("Focus")
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(tonumber(AutoFeedConfig.interval))
            end
            task.wait()
        end
        AutoFeedConfig.running = false
    end)
end

function Collection:AntiAFK()
    if AntiAFKConfig.running then
        return
    end
    AntiAFKConfig.running = true
    task.spawn(function()
        while true do
            if AntiAFKConfig.toggle then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                print("Anti AFK")
                task.wait(AntiAFKConfig.interval)
            end
        end
        AntiAFKConfig.running = false
    end)
end

----------------------------------- MainTab ------------------------------------
local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://" .. NebulaIcons:GetIcon("view_in_ar", "Material"),
})


local AutoCollectection = MainTab:Section({
    Side = "Left"
})

AutoCollectection:Header({
    Text = "AutoCollect"
})
AutoCollectection:Toggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(value)
        AutoCollect.toggle = value
        if AutoCollect.toggle then
            Collection:getMoney()
        end
    end,
})
AutoCollectection:Slider({
    Name = "AutoCollect Interval",
    Default = 1,
    Minimum = 1,
    Maximum = 300,
    Precision = 0,
    DisplayMethod = "Value",
    Callback = function(Value)
        AutoCollect.interval = Value
    end,
})

local AutoFeedSection = MainTab:Section({
    Side = "Right"
})
AutoFeedSection:Header({
    Text = "Auto Feed Big Pets"
})
AutoFeedSection:Dropdown({
    Name = "Select Egg",
    Search = true,
    Multi = true,
    Required = false,
    Options = foodList,
    Default = {},
    Callback = function(select)
        selectedFeed = {}
        for name, isOn in pairs(select) do
            if isOn then
                table.insert(selectedFeed, name)
            end
        end
        print("Selected mutate:", #selectedFeed > 0 and table.concat(selectedFeed, ", ") or "none")
    end
})

AutoFeedSection:Slider({
    Name = "Interval",
    Default = 1,
    Minimum = 1,
    Maximum = 300,
    DisplayMethod = "Value",
    Callback = function(Value)
        AutoFeedConfig.interval = Value
    end,
})
AutoFeedSection:Toggle({
    Name = "Auto Feed Big Pets",
    Default = false,
    Callback = function(value)
        AutoFeedConfig.toggle = value
        if AutoFeedConfig.toggle then
            Collection:AutoFeed()
        end
    end,
})
local AntiAFKSection = MainTab:Section({
    Side = "Left"
})
AntiAFKSection:Header({
    Text = "Anti AFK"
})
AntiAFKSection:Toggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(value)
        AntiAFKConfig.toggle = value
        if AntiAFKConfig.toggle then
            Collection:AntiAFK()
        end
    end,
})
----------------------------------- Shop Tab ------------------------------------
local ShopTab = TabGroup:Tab({
    Name = "Shop",
    Image = "rbxassetid://" .. NebulaIcons:GetIcon("view_in_ar", "Material"),
})

local AutoBuyNormalEgg = ShopTab:Section({
    Side = "Right"
})
AutoBuyNormalEgg:Header({
    Text = "Auto Buy Normal Egg"
})
AutoBuyNormalEgg:Dropdown({
    Name = "Select Normal Egg",
    Search = true,
    Multi = true,
    Required = false,
    Options = eggList,
    Default = {},
    Callback = function(select)
        for name, isOn in pairs(select) do
            if isOn then
                table.insert(selectedNormalEgg, name)
            end
        end
        print("Selected eggs:", #selectedNormalEgg > 0 and table.concat(selectedNormalEgg, ", ") or "none")
    end
})
AutoBuyNormalEgg:Slider({
    Name = "Interval",
    Default = 1,
    Minimum = 1,
    Maximum = 300,
    DisplayMethod = "Value",
    Callback = function(Value)
        AutoBuy.normalinterval = Value
    end,
})
AutoBuyNormalEgg:Toggle({
    Name = "Auto Buy Normal Egg",
    Default = false,
    Callback = function(value)
        AutoBuy.normalToggle = value
        if AutoBuy.normalToggle then
            Collection:AutoBuyNormalEgg()
        end
    end,
})
local AutoBuyMutateEgg = ShopTab:Section({
    Side = "Left"
})
AutoBuyMutateEgg:Header({
    Text = "Auto Buy Mutate Egg"
})
AutoBuyMutateEgg:Dropdown({
    Name = "Select Egg",
    Search = true,
    Multi = true,
    Required = false,
    Options = eggList,
    Default = {},
    Callback = function(select)
        selectedMutateEgg = {}
        for name, isOn in pairs(select) do
            if isOn then
                table.insert(selectedMutateEgg, name)
            end
        end
        print("Selected mutate:", #selectedMutate > 0 and table.concat(selectedMutate, ", ") or "none")
    end
})
AutoBuyMutateEgg:Dropdown({
    Name     = "Select Mutate",
    Search   = true,
    Multi    = true,
    Required = false,
    Options  = mutateList,
    Default  = {},
    Callback = function(select)
        selectedMutate = {}
        for name, isOn in pairs(select) do
            if isOn then
                table.insert(selectedMutate, name)
            end
        end
        print("Selected mutate:", #selectedMutate > 0 and table.concat(selectedMutate, ", ") or "none")
    end
})
AutoBuyMutateEgg:Slider({
    Name = "Interval",
    Default = 1,
    Minimum = 1,
    Maximum = 300,
    DisplayMethod = "Value",
    Callback = function(Value)
        AutoBuy.mutateinterval = Value
    end,
})
AutoBuyMutateEgg:Toggle({
    Name = "Auto Buy Mutate Egg",
    Default = false,
    Callback = function(value)
        AutoBuy.mutateToggle = value
        if AutoBuy.mutateToggle then
            Collection:AutoBuyWithMutateEgg()
        end
    end,
})


local AutoBuyFood = ShopTab:Section({
    Side = "Left"
})
AutoBuyFood:Header({
    Text = "Auto Buy Food"
})
AutoBuyFood:Dropdown({
    Name = "Select Food",
    Search = true,
    Multi = true,
    Required = false,
    Options = foodList,
    Default = {},
    Callback = function(select)
        selectedFood = {}
        for name, isOn in pairs(select) do
            if isOn then
                table.insert(selectedFood, name)
            end
        end
    end
})
AutoBuyFood:Toggle({
    Name = "Auto Buy Food",
    Default = false,
    Callback = function(value)
        AutoBuyFoodConfig.toggle = value
        if AutoBuyFoodConfig.toggle then
            Collection:autoBuyFood()
            -- RootScreenFoodStore.Visible = false
            -- PlayerGui.ScreenFoodStore.Enabled = true
            -- task.wait(.1)
            -- RootScreenFoodStore.Visible = true
            -- PlayerGui.ScreenFoodStore.Enabled = false
        end
    end,
})
