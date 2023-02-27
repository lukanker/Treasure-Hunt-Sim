local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Treasure Hunt Simulator", "DarkTheme")
local MainTab = Window:NewTab('Main')
local FarmTab = Window:NewTab('Farm')

local AutomationSection = MainTab:NewSection('Automation')
local IslandSection = MainTab:NewSection('Island')
local AutoFarmChestsSection = FarmTab:NewSection('Auto Farm Chests')
local AutoDigSection = FarmTab:NewSection('Auto Digging')

local RS = game:GetService('ReplicatedStorage')
local ToolModule = require(game.ReplicatedStorage.ToolModules.Tool)

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
local PlayerGui = LocalPlayer.PlayerGui

local AmountLabel = PlayerGui.Gui.Buttons.Sand.Amount
local RebirthFrame = PlayerGui.Gui.Rebirth
local CoinsLabel = PlayerGui.Gui.Buttons.Coins.Amount

local SandBlocks = workspace.SandBlocks

local BackpackTool = LocalPlayer.Backpack:FindFirstChildWhichIsA('Tool')
Character.Humanoid:EquipTool(BackpackTool)

local Tool = Character:FindFirstChildWhichIsA('Tool')
local AttackLength = Tool.Configurations.AttackLength.Value

local RemoteClick = Tool.RemoteClick
local RebirthRemote = RS.Events.Rebirth

local ChestVariants = {'Common Chest', 'Heart Chest', 'Rare Chest', 'Pumpkin Chest', 'Space Chest', 'Santa Chest', 'Epic Chest', 'Atlantis Chest', 'Dice Chest', 'Spooky Chest', 'Prisoner Chest', 'Mars Chest', 'Astronaut Chest', 'Legendary Chest', 'Christmas Chest', 'Stone Chest', 'Golden Chest', 'Trident Chest', 'Emerald Chest', 'Police Chest', 'Valentine Chest', 'Magma Chest', "Knight's Chest", 'Mermaid Chest', 'Alien Chest', 'Snow Chest', 'Mythical Chest', 'Rainbow Chest', 'Elite Chest', 'Hell Chest', 'Shadow Chest', 'Sacred Chest', 'Jackpot Chest'}
local ChosenChestVariant = 'Common Chest'

-- Booleans
local AutoFarmChestsToggle = false
local IsFarmingChests = false
local AutoSellToggle = false
local AutoDigToggle = false
local AutoRebirthToggle = false
local CollapseProtectionToggle = false

local CurrentIsland = 'Starter'
local IslandsTable = {'Starter', 'Pirate', 'Candy', 'Dino', 'Launch Site', 'Moon', 'VIP', 'Atlantis', 'Toy Land', 'Medieval', 'Mars', 'Prison', 'Dominus', 'Volcano', 'North Pole'}

local DigsiteClosed = workspace.Settings.Closed

AmountLabel:GetPropertyChangedSignal("Text"):Connect(function()

	AutoSell()
end)

CoinsLabel:GetPropertyChangedSignal("Text"):Connect(function()

	AutoRebirth()
end)

DigsiteClosed:GetPropertyChangedSignal("Value"):Connect(function()

	CollapseProtection()
end)

function AutoSell()
	if not AutoSellToggle then return end
	local MaxCapacity = tonumber(AmountLabel.Text:split(' / ')[2])
	local CurrentSandValue = tonumber(AmountLabel.Text:split(' / ')[1])

	local FoundIsland = false


	if CurrentSandValue >= MaxCapacity then
		for i, Child in pairs(workspace:GetChildren()) do
			local ShopBase = Child:FindFirstChild('ShopBase')

			if Child.Name == 'SellHut' and ShopBase and ShopBase.Island.Value.Parent[CurrentIsland] == ShopBase.Island.Value then
				FoundIsland = true
				local PosBeforeSelling = Character.HumanoidRootPart.Position
				Character:MoveTo(ShopBase.Position)
				wait(2)
				Character:MoveTo(PosBeforeSelling)
			end
		end

		if not FoundIsland then
			for i, Child in pairs(workspace:GetChildren()) do
				local ShopBase = Child:FindFirstChild('ShopBase')
	
				if Child.Name == 'SellHut' and ShopBase and ShopBase.Island.Value == RS.Islands.Starter then
					local PosBeforeSelling = Character.HumanoidRootPart.Position
					Character:MoveTo(ShopBase.Position)
					wait(2)
					Character:MoveTo(PosBeforeSelling)
				end
			end
		end
	end
end

function AutoDig()
	if not AutoDigToggle then return end

	local SandBlock = ToolModule.FindTargetBlockUnderPlayer(Tool, nil) 
	while AutoDigToggle do
		SandBlock = ToolModule.FindTargetBlockUnderPlayer(Tool, nil)

		if SandBlock then
			RemoteClick:FireServer(SandBlock)
		end
		task.wait(AttackLength)
	end
end

function AutoFarmChests()
	if not AutoFarmChestsToggle then return end
	for i, SandBlock in pairs(SandBlocks:GetChildren()) do
		local Chest = SandBlock:FindFirstChild('Chest')
		local ChestIsland = SandBlock:FindFirstChild('SpawnBrick').Value.Parent
		local Health = SandBlock:FindFirstChild('Health')
		local Variant = SandBlock:FindFirstChild('Mat')

		if Chest and ChestIsland == ChestIsland.Parent[CurrentIsland] and Variant.Value == ChosenChestVariant then
			SandBlock.CanCollide = false
			Character:MoveTo(SandBlock.Position)
			while SandBlock.Parent do
				if not AutoFarmChestsToggle then
					return
				end

				if Variant.Value ~= ChosenChestVariant and ChestIsland ~= ChestIsland.Parent[CurrentIsland] then
					break
				end

				Character:MoveTo(SandBlock.Position)
				wait(0.2)
				RemoteClick:FireServer(SandBlock)
				task.wait(AttackLength)
			end
		end
	end
end

function TeleportToIsland()
	local Island = RS.Islands[CurrentIsland]
	Character:MoveTo(Island.CloseMine.Position + Vector3.new(20, 0, 20))
end

function CollapseProtection()
	if not CollapseProtectionToggle then return end

	if not DigsiteClosed.Value then
		wait(1)
		TeleportToIsland()
	end
end

function AutoRebirth()
	if not AutoRebirthToggle then return end

	local CoinsNeeded = string.gsub(RebirthFrame.CoinsNeeded.Text, 'Coins Needed: ', '')
	CoinsNeeded = tonumber(CoinsNeeded)

	local CurrentCoins = string.gsub(CoinsLabel.Text, ',', '')
	CurrentCoins = tonumber(CurrentCoins)

	if CurrentCoins >= CoinsNeeded then
		RebirthRemote:FireServer()
	end
end

AutoFarmChestsSection:NewToggle('Start', 'Auto Farm Chests', function(State)
	AutoFarmChestsToggle = State

	AutoFarmChests()
end)

AutoDigSection:NewToggle('Start', 'Auto Dig', function(State)
	AutoDigToggle = State

	AutoDig()
end)

AutomationSection:NewToggle('Auto Rebirth', 'Auto Rebirth', function(State)
	AutoRebirthToggle = State

	AutoRebirth()
end)

AutomationSection:NewToggle('Auto Sell', 'Auto Sell', function(State)
	AutoSellToggle = State

	AutoSell()
end)

AutomationSection:NewToggle('Digsite Collapse Protection', 'Digsite Collapse Protection', function(State)
	CollapseProtectionToggle = State
end)

IslandSection:NewDropdown(CurrentIsland, 'Choose Island', IslandsTable, function(CurrentOption)
	CurrentIsland = CurrentOption

	TeleportToIsland()
end)


AutoFarmChestsSection:NewDropdown(ChosenChestVariant, 'Choose Chest Variant', ChestVariants, function(CurrentOption)
	ChosenChestVariant = CurrentOption

	AutoFarmChests()
end)

for i,v in pairs(getconnections(LocalPlayer.Idled)) do
	v:Disable()
end