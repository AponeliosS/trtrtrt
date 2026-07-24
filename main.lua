local HttpService = game:GetService("HttpService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sprayEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Paint"):WaitForChild("SprayServer")

local Window = Rayfield:CreateWindow({
   Name = "🎨 Auto-Draw Pro v2",
   LoadingTitle = "Gelişmiş Çizim Motoru Yükleniyor...",
   LoadingSubtitle = "by Sen",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Çizim Motoru", 4483362458)

-- DEĞİŞKENLER
local PointA = nil -- Sol Üst Köşe
local PointB = nil -- Sağ Alt Köşe
local PixelData = nil -- JSON'dan gelecek veri
local IsDrawing = false

-- ==========================================
-- 1. AŞAMA: JSON VERİSİ YÜKLEME
-- ==========================================
MainTab:CreateSection("1. Resim Verisi Yükle (JSON URL)")

MainTab:CreateInput({
   Name = "Raw JSON Linki (Pastebin/GitHub)",
   PlaceholderText = "URL'yi buraya yapıştır ve Enter'a bas...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text ~= "" then
           pcall(function()
               -- İnternetteki metni (JSON) indir
               local rawJson = game:HttpGet(Text)
               -- Metni Lua'nın okuyabileceği bir tabloya çevir
               PixelData = HttpService:JSONDecode(rawJson)
               
               Rayfield:Notify({
                   Title = "Başarılı!",
                   Content = "Resim verisi başarıyla yüklendi. Pikseller hafızada.",
                   Duration = 3,
                   Image = 4483362458,
               })
           end)
       end
   end,
})

-- ==========================================
-- 2. AŞAMA: ALAN SEÇİMİ (KARE/DİKDÖRTGEN)
-- ==========================================
MainTab:CreateSection("2. Çizim Alanı Seçimi")

MainTab:CreateButton({
   Name = "📍 1. Nokta: Sol Üst Köşeyi Seç",
   Callback = function()
       PointA = Mouse.Hit.Position
       Rayfield:Notify({
           Title = "1. Nokta Seçildi",
           Content = "Şimdi sağ alt köşeyi seçin.",
           Duration = 2,
       })
   end,
})

MainTab:CreateButton({
   Name = "📍 2. Nokta: Sağ Alt Köşeyi Seç",
   Callback = function()
       PointB = Mouse.Hit.Position
       Rayfield:Notify({
           Title = "2. Nokta Seçildi",
           Content = "Çizim alanı başarıyla belirlendi!",
           Duration = 2,
       })
   end,
})

-- ==========================================
-- 3. AŞAMA: ÇİZİM MOTORU
-- ==========================================
MainTab:CreateSection("3. Çizimi Başlat")

MainTab:CreateButton({
   Name = "🚀 Çizimi Başlat",
   Callback = function()
       if not PointA or not PointB then
           Rayfield:Notify({ Title = "Hata", Content = "Lütfen önce 2 noktayı da seçin!", Duration = 3 })
           return
       end
       
       if not PixelData then
           Rayfield:Notify({ Title = "Hata", Content = "Lütfen önce bir JSON resim linki girin!", Duration = 3 })
           return
       end

       if IsDrawing then return end
       IsDrawing = true
       
       Rayfield:Notify({ Title = "Başlıyor", Content = "Çizim sunucuya aktarılıyor...", Duration = 3 })

       -- Gerçek çizim algoritması
       for i, pixel in ipairs(PixelData) do
           if not IsDrawing then break end
           
           -- JSON'dan gelen veriler genelde 0-1 arası (yüzde) olarak hesaplanmalı
           -- Eğer JSON verin direkt piksel kordinatı (0-100 vb) ise buraya bir maksimum genişlik değeri ekleyeceğiz.
           -- Şimdilik pixel.x ve pixel.y'nin 0.0 ile 1.0 arasında bir değer olduğunu varsayıyoruz (Örn: 0.5 tam orta demek)
           
           -- X ve Y ekseninde iki nokta arası hesaplama (Lerp = Linear Interpolation)
           local targetX = PointA.X + (PointB.X - PointA.X) * pixel.x
           local targetY = PointA.Y + (PointB.Y - PointA.Y) * pixel.y
           local targetZ = PointA.Z + (PointB.Z - PointA.Z) * pixel.x -- Derinlik/açı için
           
           local currentPos = Vector3.new(targetX, targetY, targetZ)
           local currentColor = Color3.fromRGB(pixel.r, pixel.g, pixel.b)
           
           -- Sunucuya yolla
           pcall(function()
               sprayEvent:FireServer(currentPos, currentColor)
           end)
           
           -- Hızlı çizim için çok kısa bekleme
           task.wait(0.01) 
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
