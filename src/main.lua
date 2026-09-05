local gameDetector = require(script.Parent.core.game_detector)
local logger = require(script.Parent.core.logger)

-- Verifica se o jogo é suportado
if not gameDetector.isSupported() then
    logger.warn("Jogo não suportado: " .. gameDetector.getCurrentGame())
    return
end

-- Carrega módulos universais
local speed = require(script.Parent.features.speed)
local noclip = require(script.Parent.features.noclip)
local infinitejump = require(script.Parent.features.infinitejump)
local fly = require(script.Parent.features.fly)
local fullbright = require(script.Parent.features.fullbright)

-- Carrega módulo específico do jogo
local currentGame = gameDetector.getCurrentGame()
local gameModule = require(script.Parent.games[currentGame:lower()])

-- Mescla funções universais no módulo do jogo
gameModule.speed = speed
gameModule.noclip = noclip
gameModule.infinitejump = infinitejump
gameModule.fly = fly
gameModule.fullbright = fullbright

-- Cria a GUI
local gui = require(script.Parent.gui)
gui.createGUI(gameModule)

logger.info("Moruyo Hub carregado para: " .. currentGame)