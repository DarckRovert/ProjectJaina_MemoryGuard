--[[
    Project Jaina — MemoryGuard.lua
    Centinela inteligente de memoria virtual y recolección agresiva de basura Lua (Anti-OOM).
    Diseñado para World of Warcraft 3.3.5a (Build 12340) con cliente HD/FHD de 23.8 GB.

    PRINCIPIOS ARQUITECTÓNICOS L9:
    1. Zero Stutter: NUNCA ejecutar purgas completas durante InCombatLockdown().
    2. Event-Driven: Purgas masivas sincronizadas con pantallas de carga (PLAYER_ENTERING_WORLD, ZONE_CHANGED_NEW_AREA).
    3. Paced GC fuera de combate: Pasos incrementales collectgarbage("step", 150) cada 30 segundos.
    4. Cero Allocations: Frame estático OnUpdate con acumulador 'elapsed' sin crear tablas temporales.
]]

local ADDON_NAME = "ProjectJaina_MemoryGuard"
local VERSION = "1.0.0"

-- Configuración por defecto
local CONFIG = {
    MEM_HIGH_THRESHOLD_KB = 45000, -- 45 MB: umbral para activar pacing
    INTERVAL_SECONDS = 30.0,       -- Chequeo periódico fuera de combate
    DEBUG = false
}

local function InitDB()
    ProjectJaina_MemoryGuard_DB = ProjectJaina_MemoryGuard_DB or {}
    if ProjectJaina_MemoryGuard_DB.debug == nil then
        ProjectJaina_MemoryGuard_DB.debug = false
    end
    if not ProjectJaina_MemoryGuard_DB.thresholdKB then
        ProjectJaina_MemoryGuard_DB.thresholdKB = 45000
    end
    if not ProjectJaina_MemoryGuard_DB.interval then
        ProjectJaina_MemoryGuard_DB.interval = 30.0
    end
    CONFIG.DEBUG = ProjectJaina_MemoryGuard_DB.debug
    CONFIG.MEM_HIGH_THRESHOLD_KB = ProjectJaina_MemoryGuard_DB.thresholdKB
    CONFIG.INTERVAL_SECONDS = ProjectJaina_MemoryGuard_DB.interval
end

local pendingPurge = false
local timeSinceLastCheck = 0

-- Frame centinela único
local GuardFrame = CreateFrame("Frame", "ProjectJaina_MemoryGuard_Frame")

local function LogMessage(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF38BDF8[MemoryGuard]|r " .. tostring(msg))
    end
end

-- Función de purga profunda segura (solo fuera de combate o en loading)
local function PerformSafePurge(reason)
    if InCombatLockdown() then
        pendingPurge = true
        if CONFIG.DEBUG then
            LogMessage("|cFFFBBF24Purga pospuesta: Combate activo.|r")
        end
        return
    end

    local beforeKB = collectgarbage("count")
    collectgarbage("collect")
    local afterKB = collectgarbage("count")
    local freedMB = math.max(0, (beforeKB - afterKB) / 1024)

    pendingPurge = false

    if CONFIG.DEBUG or freedMB > 2.0 then
        LogMessage(string.format("Purga completada (%s): Liberados |cFF34D399%.2f MB|r (Memoria actual: %.2f MB)", reason or "Auto", freedMB, afterKB / 1024))
    end
end

-- Función de pacing incremental fuera de combate
local function PerformIncrementalStep()
    if InCombatLockdown() then
        return
    end

    local currentKB = collectgarbage("count")
    if currentKB > CONFIG.MEM_HIGH_THRESHOLD_KB then
        collectgarbage("step", 150)
        if CONFIG.DEBUG then
            LogMessage(string.format("Pacing paso incremental ejecutado (Uso: %.2f MB)", currentKB / 1024))
        end
    end
end

-- Manejador de eventos del Centinela
GuardFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == ADDON_NAME then
            InitDB()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Pantalla de carga completada: purga masiva de assets temporales
        PerformSafePurge("Carga de Mundo")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        -- Cambio de continente o estancia
        PerformSafePurge("Transición de Zona")
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Salida de combate: si había purga pendiente, ejecutarla ahora
        if pendingPurge then
            PerformSafePurge("Salida de Combate")
        else
            -- Pequeño paso incremental para limpiar tablas temporales de combate (DBM/GearScore)
            collectgarbage("step", 200)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entrada en combate: suspender purgas
        pendingPurge = false
    end
end)

GuardFrame:RegisterEvent("ADDON_LOADED")
GuardFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
GuardFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GuardFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
GuardFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

-- Exportación de API Global para el Ecosistema Project Jaina
_G.ProjectJaina_MemoryGuard_Purge = function(reason)
    return PerformSafePurge(reason or "API Externa")
end

_G.ProjectJaina_MemoryGuard_GetStatus = function()
    return collectgarbage("count") / 1024, InCombatLockdown(), pendingPurge
end

-- Loop de temporizador sin allocations dinámicas
GuardFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastCheck = timeSinceLastCheck + elapsed
    if timeSinceLastCheck >= CONFIG.INTERVAL_SECONDS then
        timeSinceLastCheck = 0
        PerformIncrementalStep()
    end
end)

-- Comandos de barra (Slash Commands)
SLASH_PROJECTJAINA_MEMGUARD1 = "/mem"
SLASH_PROJECTJAINA_MEMGUARD2 = "/memoria"
SLASH_PROJECTJAINA_MEMGUARD3 = "/memory"
SLASH_PROJECTJAINA_MEMGUARD4 = "/pjmem"
SLASH_PROJECTJAINA_MEMGUARD5 = "/memoryguard"
SlashCmdList["PROJECTJAINA_MEMGUARD"] = function(msg)
    local cmd = (msg or ""):lower():match("^%s*(%S+)")
    local currentMB = collectgarbage("count") / 1024
    local inCombat = InCombatLockdown()

    if cmd == "collect" or cmd == "purge" or cmd == "limpiar" or cmd == "purgar" then
        if inCombat then
            LogMessage("|cFFEF4444No se puede purgar memoria en combate.|r La purga se ejecutará al salir de combate.")
            pendingPurge = true
        else
            PerformSafePurge("Comando Manual")
        end
    elseif cmd == "debug" or cmd == "depurar" then
        CONFIG.DEBUG = not CONFIG.DEBUG
        if ProjectJaina_MemoryGuard_DB then
            ProjectJaina_MemoryGuard_DB.debug = CONFIG.DEBUG
        end
        LogMessage("Modo depuración: " .. (CONFIG.DEBUG and "|cFF34D399ACTIVADO|r" or "|cFFEF4444DESACTIVADO|r"))
    else
        LogMessage(string.format("Memoria Lua en uso: |cFF38BDF8%.2f MB|r | Estado Combate: %s | Purgas Pendientes: %s",
            currentMB,
            inCombat and "|cFFEF4444EN COMBATE|r" or "|cFF34D399FUERA DE COMBATE|r",
            pendingPurge and "|cFFFBBF24SÍ|r" or "NO"
        ))
        LogMessage("Comandos disponibles: |cFF38BDF8/mem limpiar|r (forzar purga de memoria) | |cFF38BDF8/mem depurar|r (alternar avisos)")
    end
end

-- Mensaje de bienvenida discreto
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    LogMessage(string.format("v%s |cFF34D399Activo|r • Blindaje Anti-OOM FHD operacional.", VERSION))
    initFrame:UnregisterAllEvents()
    initFrame = nil
end)
