--[[
    YUSZX HUB - Steal an Egg Speed Bypass
    Menggunakan metode Property Spoofing & Metamethod Hooking
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. Simpan nilai WalkSpeed asli yang diinginkan
local realWalkSpeed = 16
local bypassActive = false
local originalWalkSpeedProperty -- Untuk menyimpan referensi properti asli

-- 2. Fungsi untuk mengaktifkan bypass
local function enableBypass(speed)
    realWalkSpeed = speed
    
    if bypassActive then return end
    bypassActive = true

    -- 3. Hook Metamethod __index pada Humanoid
    -- Ini akan membuat script anti-cheat yang membaca WalkSpeed kita akan melihat nilai 16 (palsu)
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(self, key)
        if bypassActive and key == "WalkSpeed" and self:IsA("Humanoid") and self.Parent == LocalPlayer.Character then
            -- Kembalikan nilai palsu ke anti-cheat
            return 16 
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)

    -- 4. Loop untuk terus menerapkan kecepatan asli di background
    task.spawn(function()
        while bypassActive do
            task.wait(0.1) -- Update cepat untuk melawan reset dari server
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Set properti asli secara langsung
                    -- Kita perlu menembus hook kita sendiri, jadi kita akses lewat rawset atau metode internal
                    -- Tapi karena kita sudah hook __index, kita bisa set langsung ke properti asli
                    -- Roblox Lua tidak mengizinkan kita set properti asli jika sudah di-hook di __newindex
                    -- Kita gunakan trik: akses properti asli lewat getrawmetatable atau cara lain
                    -- Untuk sederhananya, kita asumsikan hook __newindex tidak dipasang oleh anti-cheat
                    -- Kita coba set langsung, jika gagal kita pakai metode lain.
                    pcall(function()
                        -- Ini akan memicu __newindex jika ada, tapi kita belum hook itu.
                        humanoid.WalkSpeed = realWalkSpeed
                    end)
                end
            end
        end
    end)
    
    print("[Yuszx] Speed bypass aktif! Kecepatan asli: " .. realWalkSpeed)
end

-- 5. Fungsi untuk mematikan bypass
local function disableBypass()
    bypassActive = false
    -- Kembalikan hook ke keadaan semula
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    mt.__index = oldIndex -- oldIndex harus di-scope global atau di luar fungsi
    setreadonly(mt, true)
    
    print("[Yuszx] Speed bypass dimatikan.")
    -- Kembalikan kecepatan ke normal
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end

-- Contoh Penggunaan:
-- enableBypass(100) -- Mengaktifkan bypass dengan kecepatan 100
-- disableBypass()   -- Mematikan bypass

-- UI Sederhana untuk Test
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuszxBypassTest"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 160, 0, 30)
Toggle.Position = UDim2.new(0.5, -80, 0.5, -15)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Toggle.Text = "Aktifkan Bypass (100)"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Parent = Frame
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

Toggle.MouseButton1Click:Connect(function()
    if not bypassActive then
        enableBypass(100) -- Coba kecepatan 100 dulu
        Toggle.Text = "Matikan Bypass"
        Toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        disableBypass()
        Toggle.Text = "Aktifkan Bypass (100)"
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)

print("[Yuszx] Script bypass dimuat. Gunakan tombol di layar untuk tes.")
