--[[
    YUSZX - Steal an Egg Speed Hack
    Simple WalkSpeed modifier
]]

-- ========== KONFIGURASI ==========
local DEFAULT_SPEED = 16
local MAX_SPEED = 5000000000000  -- 5T
local currentSpeed = DEFAULT_SPEED

-- ========== PARSER ==========
local function parseSpeed(input)
    if not input then return nil end
    input = tostring(input):lower():gsub("%s", "")
    local num, suffix = input:match("^([%d%.]+)([kmbt]?)$")
    if not num then return nil end
    num = tonumber(num)
    if not num then return nil end
    local mult = 1
    if suffix == "k" then mult = 1e3
    elseif suffix == "m" then mult = 1e6
    elseif suffix == "b" then mult = 1e9
    elseif suffix == "t" then mult = 1e12
    end
    return math.floor(num * mult)
end

local function formatSpeed(v)
    v = tonumber(v) or 0
    if v >= 1e12 then return string.format("%.2fT", v / 1e12)
    elseif v >= 1e9 then return string.format("%.2fB", v / 1e9)
    elseif v >= 1e6 then return string.format("%.2fM", v / 1e6)
    elseif v >= 1e3 then return string.format("%.2fK", v / 1e3)
    else return tostring(math.floor(v)) end
end

-- ========== UI ==========
local Player = game:GetService("Players").LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuszxSpeed"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "YUSZX | Speed Hack"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -70, 0, 3)
MinButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
MinButton.Text = "—"
MinButton.TextColor3 = Color3.fromRGB(0, 200, 255)
MinButton.Font = Enum.Font.Code
MinButton.TextSize = 16
MinButton.BorderSizePixel = 0
MinButton.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

-- Close
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 3)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 10, 20)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.Code
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Floating reopen
local ReopenButton = Instance.new("TextButton")
ReopenButton.Size = UDim2.new(0, 100, 0, 35)
ReopenButton.Position = UDim2.new(0, 20, 0, 100)
ReopenButton.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
ReopenButton.Text = "⚡ Yuszx"
ReopenButton.TextColor3 = Color3.fromRGB(0, 200, 255)
ReopenButton.Font = Enum.Font.Code
ReopenButton.TextSize = 13
ReopenButton.BorderSizePixel = 0
ReopenButton.Active = true
ReopenButton.Draggable = true
ReopenButton.Visible = false
ReopenButton.Parent = ScreenGui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0, 8)
ReopenCorner.Parent = ReopenButton

local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = Color3.fromRGB(0, 200, 255)
ReopenStroke.Thickness = 1.5
ReopenStroke.Parent = ReopenButton

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Siap"
StatusLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Speed label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 72)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ WalkSpeed (max 5T):"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
SpeedLabel.Font = Enum.Font.Code
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Size = UDim2.new(0, 100, 0, 20)
SpeedValueLabel.Position = UDim2.new(1, -110, 0, 72)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = "16"
SpeedValueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
SpeedValueLabel.Font = Enum.Font.Code
SpeedValueLabel.TextSize = 12
SpeedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
SpeedValueLabel.Parent = MainFrame

-- Slider
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -20, 0, 10)
SliderFrame.Position = UDim2.new(0, 10, 0, 97)
SliderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 5)
SliderCorner.Parent = SliderFrame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderFrame

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 5)
FillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0, 18, 0, 18)
SliderButton.Position = UDim2.new(0.5, -9, 0, -4)
SliderButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SliderButton.Text = ""
SliderButton.BorderSizePixel = 0
SliderButton.Parent = SliderFrame

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderButton

local SliderBtnStroke = Instance.new("UIStroke")
SliderBtnStroke.Color = Color3.fromRGB(255, 255, 255)
SliderBtnStroke.Thickness = 1
SliderBtnStroke.Parent = SliderButton

-- Input box
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 28)
SpeedBox.Position = UDim2.new(0, 10, 0, 118)
SpeedBox.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
SpeedBox.BorderSizePixel = 0
SpeedBox.Text = "16"
SpeedBox.PlaceholderText = "100 / 5k / 1m / 500b / 5t"
SpeedBox.TextColor3 = Color3.fromRGB(0, 200, 255)
SpeedBox.Font = Enum.Font.Code
SpeedBox.TextSize = 12
SpeedBox.ClearTextOnFocus = false
SpeedBox.Parent = MainFrame

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 6)
SpeedBoxCorner.Parent = SpeedBox

local SpeedBoxStroke = Instance.new("UIStroke")
SpeedBoxStroke.Color = Color3.fromRGB(0, 150, 255)
SpeedBoxStroke.Thickness = 1
SpeedBoxStroke.Parent = SpeedBox

-- Presets
local presets = {
    {"16", 16}, {"100", 100}, {"500", 500}, {"1k", 1e3}, {"5k", 5e3},
    {"10k", 1e4}, {"100k", 1e5}, {"1m", 1e6}, {"1b", 1e9}, {"5t", 5e12}
}

local function makePresetRow(yPos, startIdx, endIdx)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 24)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = row
    
    for i = startIdx, endIdx do
        local preset = presets[i]
        if not preset then break end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 34, 0, 22)
        btn.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
        btn.Text = preset[1]
        btn.TextColor3 = Color3.fromRGB(100, 200, 255)
        btn.Font = Enum.Font.Code
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.Parent = row
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            SpeedBox.Text = preset[1]
            applySpeed(preset[2])
        end)
    end
end

local applySpeed -- forward declaration

makePresetRow(153, 1, 5)
makePresetRow(181, 6, 10)

-- Apply / Reset
local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size = UDim2.new(0.5, -15, 0, 28)
ApplyBtn.Position = UDim2.new(0, 10, 0, 213)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
ApplyBtn.Text = "⚡ APPLY"
ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyBtn.Font = Enum.Font.Code
ApplyBtn.TextSize = 12
ApplyBtn.Parent = MainFrame

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 6)
ApplyCorner.Parent = ApplyBtn

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.5, -15, 0, 28)
ResetBtn.Position = UDim2.new(0.5, 5, 0, 213)
ResetBtn.BackgroundColor3 = Color3.fromRGB(60, 5, 20)
ResetBtn.Text = "🔄 RESET"
ResetBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
ResetBtn.Font = Enum.Font.Code
ResetBtn.TextSize = 12
ResetBtn.Parent = MainFrame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetBtn

-- ========== LOGIKA ==========
local function updateSliderVisual(value)
    value = math.max(tonumber(value) or 1, 1)
    local ratio = math.log10(value) / math.log10(MAX_SPEED)
    ratio = math.clamp(ratio, 0, 1)
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    SliderButton.Position = UDim2.new(ratio, -9, 0, -4)
end

local function updateSliderFromInput(input)
    local ratio = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
    local value = math.floor(10 ^ (ratio * math.log10(MAX_SPEED)))
    value = math.max(value, 1)
    SpeedBox.Text = tostring(value)
    SpeedValueLabel.Text = formatSpeed(value)
    updateSliderVisual(value)
    return value
end

applySpeed = function(value)
    value = tonumber(value)
    if not value or value <= 0 then
        StatusLabel.Text = "❌ Nilai gak valid"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    value = math.clamp(value, 1, MAX_SPEED)
    
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = value
        currentSpeed = value
        SpeedBox.Text = tostring(value)
        SpeedValueLabel.Text = formatSpeed(value)
        updateSliderVisual(value)
        StatusLabel.Text = "⚡ Speed = " .. formatSpeed(value)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        StatusLabel.Text = "❌ Karakter belum spawn"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

-- Slider drag
local dragging = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

SliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        applySpeed(updateSliderFromInput(input))
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local value = updateSliderFromInput(input)
        if Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end
end)

SpeedBox.FocusLost:Connect(function()
    local parsed = parseSpeed(SpeedBox.Text)
    if parsed then applySpeed(parsed)
    else
        StatusLabel.Text = "❌ Format salah! Contoh: 100, 5k, 5t"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

ApplyBtn.MouseButton1Click:Connect(function()
    local parsed = parseSpeed(SpeedBox.Text)
    if parsed then applySpeed(parsed)
    else
        StatusLabel.Text = "❌ Format salah!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

ResetBtn.MouseButton1Click:Connect(function()
    applySpeed(DEFAULT_SPEED)
    StatusLabel.Text = "🔄 Reset ke 16"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
end)

-- Minimize
local isMinimized = false
local uiElements = {StatusLabel, SpeedLabel, SpeedValueLabel, SliderFrame, SpeedBox, ApplyBtn, ResetBtn}

MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 380, 0, 35)
        MinButton.Text = "□"
        for _, o in ipairs(uiElements) do o.Visible = false end
        for _, row in ipairs(MainFrame:GetChildren()) do
            if row:IsA("Frame") and row.BackgroundTransparency == 1 then row.Visible = false end
        end
    else
        MainFrame.Size = UDim2.new(0, 380, 0, 280)
        MinButton.Text = "—"
        for _, o in ipairs(uiElements) do o.Visible = true end
        for _, row in ipairs(MainFrame:GetChildren()) do
            if row:IsA("Frame") and row.BackgroundTransparency == 1 then row.Visible = true end
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ReopenButton.Visible = true
end)

ReopenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ReopenButton.Visible = false
end)

-- Auto-apply respawn
Player.CharacterAdded:Connect(function(char)
    if currentSpeed > DEFAULT_SPEED then
        char:WaitForChild("Humanoid", 5)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = currentSpeed
            StatusLabel.Text = "🔄 Auto-apply: " .. formatSpeed(currentSpeed)
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
    end
end)

updateSliderVisual(16)
print("[Yuszx] Steal an Egg Speed Hack loaded!")
