-- Mapeamento de PlaceId para nome do jogo
local Games = {
    [840821278] = "PrisonLife",   -- Prison Life
    -- [ID_DO_JAILBIRD] = "Jailbird",
    -- [ID_DO_ARSENAL] = "Arsenal",
    -- [ID_DO_MM2] = "MM2",
}

-- Retorna o nome do jogo atual ou "Unknown"
local function getCurrentGame()
    return Games[game.PlaceId] or "Unknown"
end

-- Verifica se o jogo atual é suportado
local function isSupported()
    return Games[game.PlaceId] ~= nil
end

return {
    getCurrentGame = getCurrentGame,
    isSupported = isSupported
}