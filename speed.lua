--[[
    YUSZX - Auto Return After Grab
    Cara pakai:
    1. Jalan manual ke BASE, terus ketik: setBase()
    2. Jalan ke bioma, ambil telur
    3. Pas telur ke-grab, otomatis TP balik ke base
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- ========== CONFIG ==========
local BASE_CFRAME = nil
local AUTO_RETURN = true
local RETURN_DELAY = 0.3  -- Delay sebelum TP (biar grab selesai dulu)

-- ========== FUNGSI SAVE BASE ==========
_G.setBase = function()
    local char = LocalPlayer.Character
    if not char then return warn("Karakter belum spawn") end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return warn("Root gak ada") end
    
    BASE_CFRAME = root.CFrame
    warn("✅ Base tersimpan di: " .. tostring(root.Position))
    warn("Sekarang jalan ke bioma & ambil telur!")
end

_G.tpBase = function()
    if not BASE_CFRAME then return warn("❌ Base belum diset! Ketik setBase() dulu") end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = BASE_CFRAME
        warn("🚀 TP ke base!")
    end
end

-- ========== HOOK DETECT GRAB EGG ==========
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

local SKIP = {
    ["statsreport"] = true, ["stats"] = true, ["ping"] = true,
    ["heartbeat"] = true, ["log"] = true, ["render"] = true,
}

local isReturning = false

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    local name = string.lower(self.Name)
    local fullName = string.lower(self:GetFullName())
    
    if (method == "FireServer" or method == "InvokeServer") and not SKIP[name] then
        -- Cek apakah ini remote grab/steal egg
        local isGrabRemote = string.find(name, "grab")
            or string.find(name, "steal")
            or string.find(name, "egg")
            or string.find(name, "collect")
            or string.find(name, "pickup")
            or string.find(fullName, "egg")
            or string.find(fullName, "grab")
        
        if isGrabRemote then
            warn("🎯 Egg grab terdeteksi: " .. self:GetFullName())
            
            -- Auto TP balik ke base setelah delay
            if AUTO_RETURN and BASE_CFRAME and not isReturning then
                isReturning = true
                task.spawn(function()
                    task.wait(RETURN_DELAY)
                    local char = LocalPlayer.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = BASE_CFRAME
                            warn("🚀 Auto return ke base!")
                        end
                    end
                    task.wait(1)
                    isReturning = false
                end)
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuszxAutoReturn"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 230)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
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

-- TopBar
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
Title.Text = "YUSZX | Auto Return"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Base: ❌ Belum diset"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Tombol Set Base
local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(1, -20, 0, 40)
SetBaseBtn.Position = UDim2.new(0, 10, 0, 78)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
SetBaseBtn.Text = "📍 SET BASE (Dari Posisi Sekarang)"
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Font = Enum.Font.Code
SetBaseBtn.TextSize = 12
SetBaseBtn.Parent = MainFrame

local SetCorner = Instance.new("UICorner")
SetCorner.CornerRadius = UDim.new(0, 6)
SetCorner.Parent = SetBaseBtn

-- Tombol TP Manual
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -20, 0, 40)
TpBtn.Position = UDim2.new(0, 10, 0, 125)
TpBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
TpBtn.Text = "🚀 TP KE BASE (Manual)"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Font = Enum.Font.Code
TpBtn.TextSize = 12
TpBtn.Parent = MainFrame

local TpCorner = Instance.new("UICorner")
TpCorner.CornerRadius = UDim.new(0, 6)
TpCorner.Parent = TpBtn

-- Toggle Auto
local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(1, -20, 0, 40)
AutoBtn.Position = UDim2.new(0, 10, 0, 172)
AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
AutoBtn.Text = "✅ AUTO RETURN: ON"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.Code
AutoBtn.TextSize = 12
AutoBtn.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoBtn

-- ========== LOGIKA ==========
SetBaseBtn.MouseButton1Click:Connect(function()
    _G.setBase()
    StatusLabel.Text = "Base: ✅ Tersimpan"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
end)

TpBtn.MouseButton1Click:Connect(function()
    _G.tpBase()
end)

AutoBtn.MouseButton1Click:Connect(function()
    AUTO_RETURN = not AUTO_RETURN
    if AUTO_RETURN then
        AutoBtn.Text = "✅ AUTO RETURN: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    else
        AutoBtn.Text = "❌ AUTO RETURN: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ========== HOTKEY ==========
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.B then
        _G.tpBase()
    elseif input.KeyCode == Enum.KeyCode.N then
        _G.setBase()
        StatusLabel.Text = "Base: ✅ Tersimpan"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

-- ========== INIT ==========
warn("========================================")
warn("YUSZX AUTO RETURN LOADED")
warn("========================================")
warn("Cara pakai:")
warn("  1. Jalan ke BASE, klik 'SET BASE' (atau tekan N)")
warn("  2. Jalan ke bioma, ambil telur")
warn("  3. Otomatis TP balik ke base! ✅")
warn("")
warn("Hotkey:")
warn("  B = TP ke base")
warn("  N = Set base")
warn("========================================")
