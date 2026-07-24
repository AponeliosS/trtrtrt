-- Rayfield UI Kütüphanesi
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- İŞTE SENİN GÖRSELDEN BULDUĞUMUZ DOĞRU REMOTE EVENT YOLU
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sprayEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Paint"):WaitForChild("SprayServer")

local Window = Rayfield:CreateWindow({
   Name = "🎨 Auto-Draw Pro v1",
   LoadingTitle = "Sistem Hazırlanıyor...",
   LoadingSubtitle = "by Sen",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Çizim Menüsü", 4483362458)

-- DEĞİŞKENLER
local TargetURL = ""
local StartPosition = nil
local IsDrawing = false

MainTab:CreateSection("1. Ayarlar")

local Input = MainTab:CreateInput({
   Name = "Resim Verisi (İleride kullanacağız)",
   PlaceholderText = "Buraya yapıştır...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       TargetURL = Text
   end,
})

MainTab:CreateSection("2. Çizim Alanı")

MainTab:CreateButton({
   Name = "📐 Başlangıç Noktasını Seç",
   Callback = function()
       StartPosition = Mouse.Hit.Position
       Rayfield:Notify({
           Title = "Nokta Seçildi",
           Content = "Duvara işaret konuldu!",
           Duration = 2,
           Image = 4483362458,
       })
   end,
})

MainTab:CreateSection("3. Motor")

MainTab:CreateButton({
   Name = "🚀 Simülasyonu / Çizimi Başlat",
   Callback = function()
       if not StartPosition then
           Rayfield:Notify({
               Title = "Hata!",
               Content = "Önce duvardan bir başlangıç noktası seç!",
               Duration = 3,
               Image = 4483362458,
           })
           return
       end
       
       if IsDrawing then return end
       IsDrawing = true
       
       Rayfield:Notify({
           Title = "Başladı",
           Content = "Çizim sunucuya gönderiliyor...",
           Duration = 2,
           Image = 4483362458,
       })

       -- TEST ÇİZİM DÖNGÜSÜ (Sağa doğru 20 tane kırmızı nokta çizer)
       for i = 1, 20 do
           if not IsDrawing then break end
           
           local currentPos = StartPosition + Vector3.new(i * 0.2, 0, 0)
           local currentColor = Color3.fromRGB(255, 0, 0) -- Kırmızı
           
           -- SPRAYSERVER'A VERİ YOLLAMA KISMI
           -- Not: Oyunun fırça boyutu veya başka bir parametre isteyip istemediğini bilmediğimizden
           -- standart pozisyon ve renk yolluyoruz.
           pcall(function()
               sprayEvent:FireServer(currentPos, currentColor)
           end)
           
           task.wait(0.05) -- Spam engeli
       end
       
       IsDrawing = false
   end,
})

MainTab:CreateButton({
   Name = "🛑 Durdur",
   Callback = function()
       IsDrawing = false
   end,
})
