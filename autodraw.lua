-- GitHub'a yükleyeceğimiz asıl script bu olacak

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Oyunundaki çizim event'inin tam yolunu buraya yazmalısın
local drawEvent = ReplicatedStorage:WaitForChild("DrawEvent") 
local player = game.Players.LocalPlayer

-- Karakterin etrafına çember çizen bir test algoritması
local function spamDraw()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local radius = 5
    local points = 36 -- 36 noktalı bir çember
    
    for i = 1, points do
        local angle = math.rad((i / points) * 360)
        local x = rootPart.Position.X + math.cos(angle) * radius
        local z = rootPart.Position.Z + math.sin(angle) * radius
        local y = rootPart.Position.Y
        
        local drawPosition = Vector3.new(x, y, z)
        local drawColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        
        -- Sunucuya sahte veri yolluyoruz
        drawEvent:FireServer(drawPosition, drawColor)
        
        task.wait(0.05) -- Sunucuyu çok boğmamak için ufak bekleme
    end
end

-- Script çalıştığında döngüyü başlat
spamDraw()
print("Auto-draw test scripti başarıyla çalıştı!")
