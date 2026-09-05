-- ============================================================
-- MORUYO HUB v9.0 – LOADER (EXECUTAR NO EXECUTOR)
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Carrega o main.lua (que já carrega todos os módulos)
local main = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualquerumapessoa913-ops/MoruyoHub/main/src/main.lua"))()
main()