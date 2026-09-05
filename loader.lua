-- ============================================================
-- MORUYO HUB v9.0 – LOADER (EXECUTAR NO EXECUTOR)
-- ============================================================

-- Carrega e executa o hub
local success, err = pcall(function()
    local main = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualquerumapessoa913-ops/Moruyo-Hub/refs/heads/Moon-Angel/src/main.lua"))()
    if main then
        main()  -- Só chama UMA vez
    end
end)

if not success then
    warn("❌ Falha ao carregar o hub: " .. tostring(err))
else
    print("✅ Moruyo Hub carregado com sucesso!")
end