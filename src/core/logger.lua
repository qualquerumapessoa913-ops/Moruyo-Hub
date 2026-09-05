local function info(msg)
    print("[MoruyoHub] " .. msg)
end

local function warn(msg)
    warn("[MoruyoHub] " .. msg)
end

return {
    info = info,
    warn = warn
}