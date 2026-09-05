-- MORUYO HUB v9.0 – LOADER (SCRIPT ÚNICO)
local success, err = pcall(function()
    local hub = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualquerumapessoa913-ops/Moruyo-Hub/refs/heads/Moon-Angel/hub.lua"))()
    if hub then
        print("✅ Moruyo Hub carregado com sucesso!")
    end
end)

if not success then
    warn("❌ Falha ao carregar o hub: " .. tostring(err))
end