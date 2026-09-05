-- ============================================================
-- MORUYO HUB v9.0 – LOADER (EXECUTAR NO EXECUTOR)
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Substitua pelo link RAW correto
local main = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualquerumapessoa913-ops/MoruyoHub/main/src/main.lua"))()
if main then
    main()
else
    warn("Falha ao carregar o hub!")
end