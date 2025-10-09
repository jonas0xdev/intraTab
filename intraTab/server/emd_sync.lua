local function SendDataToPHP(data)
    if not Config.EMDSync or not Config.EMDSync.Enabled then
        return
    end
   
    if Config.Debug then
        print("^2[EMD-Sync]^7 Daten an PHP-Endpunkt senden...")
        print("^2[EMD-Sync]^7 Verwendung des API-Schlüssels: " .. Config.EMDSync.APIKey)
        print("^2[EMD-Sync]^7 Endpunkt: " .. Config.EMDSync.PHPEndpoint)
    end
    
    PerformHttpRequest(Config.EMDSync.PHPEndpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            if Config.Debug then
                print("^2[EMD-Sync]^7 Daten erfolgreich gesendet! Antwort: " .. response)
            end
        else
            print("^1[EMD-Sync]^7 Fehler beim Senden der Daten. Statuscode: " .. statusCode)
            if Config.Debug and response then
                print("^1[EMD-Sync]^7 Antwort: " .. response)
            end
        end
    end, 'POST', json.encode({
        intraRP_API_Key = Config.EMDSync.APIKey,
        timestamp = os.time(),
        data = data
    }), {
        ['Content-Type'] = 'application/json',
        ['User-Agent'] = 'FiveM-EMDSync/1.0'
    })
end

-- Funktion zum Abrufen der Emergency Dispatch Daten
local function GetDispatchData()
    if not Config.EMDSync or not Config.EMDSync.Enabled then
        return nil
    end
    
    local success, mannedVehicles = pcall(function()
        return exports['emergencydispatch']:mannedvehicles()
    end)

    if not success then
        print("^1[EMD-Sync]^7 Fehler beim Abrufen von Daten aus dem emergencydispatch Export!")
        return nil
    end

    if Config.Debug then
        print("^2[EMD-Sync]^7 Abgerufen: " .. (mannedVehicles and #mannedVehicles or 0) .. " besetzte Fahrzeuge")
    end

    return mannedVehicles
end

-- Haupt-Sync-Funktion
function SyncDispatchData()
    if not Config.EMDSync or not Config.EMDSync.Enabled then
        return
    end
    
    local dispatchData = GetDispatchData()
    
    if dispatchData and #dispatchData > 0 then
        local payload = {
            vehicles = dispatchData,
            serverName = GetConvar('sv_projectName', 'Unknown Server'),
            serverTime = os.date('%Y-%m-%d %H:%M:%S')
        }
        
        if Config.Debug then
            print("^2[EMD-Sync]^7 Payload vorbereitet mit " .. #dispatchData .. " Fahrzeugen")
        end
        
        SendDataToPHP(payload)
    else
        if Config.Debug then
            print("^3[EMD-Sync]^7 Keine Fahrzeuge zum Synchronisieren")
        end
    end
end

-- Event Handler für manuelle Synchronisation
RegisterServerEvent('emd:syncNow')
AddEventHandler('emd:syncNow', function()
    local source = source
    
    -- Prüfe ob Spieler Admin ist (optional)
    if IsPlayerAceAllowed(source, 'command.emdsync') then
        print("^2[EMD-Sync]^7 Manuelle Synchronisierung durch den Player ausgelöst " .. source)
        SyncDispatchData()
    else
        print("^1[EMD-Sync]^7 Unbefugter Synchronisierungsversuch durch Spieler " .. source)
    end
end)

-- Event Handler für Fahrzeug-Alarmierung
RegisterServerEvent('emd:vehicleAlerted')
AddEventHandler('emd:vehicleAlerted', function()
    if Config.Debug then
        print("^2[EMD-Sync]^7 Fahrzeugalarmierung ausgelöst, Synchronisierung läuft...")
    end
    
    -- Sende sofort bei Alarmierung (nutzt automatisch den Export)
    SyncDispatchData()
end)

-- Event Handler für Status-Änderungen
RegisterServerEvent('emd:statusChanged')
AddEventHandler('emd:statusChanged', function(vehicleId, newStatus)
    if Config.Debug then
        print("^2[EMD-Sync]^7 Status für Fahrzeug geändert: " .. vehicleId .. " zu " .. newStatus)
    end
    
    -- Sende bei Status-Änderung
    SyncDispatchData()
end)

-- Automatischer Sync-Timer
CreateThread(function()
    if not Config.EMDSync or not Config.EMDSync.Enabled then
        print("^3[EMD-Sync]^7 EMD-Sync ist in der Konfiguration deaktiviert")
        return
    end
    
    print("^2[EMD-Sync]^7 Automatische Synchronisierung starten (Intervall: " .. (Config.EMDSync.SyncInterval / 1000) .. "s)")
    print("^2[EMD-Sync]^7 PHP-Endpunkt: " .. Config.EMDSync.PHPEndpoint)
    
    while true do
        Wait(Config.EMDSync.SyncInterval)
        
        if Config.Debug then
            print("^2[EMD-Sync]^7 Timer ausgelöst - Synchronisierung wird gestartet...")
        end
        
        SyncDispatchData()
    end
end)

-- Command zum manuellen Triggern
RegisterCommand('emdsync', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'command.emdsync') then
        print("^2[EMD-Sync]^7 Manueller Synchronisierungsbefehl ausgeführt")
        SyncDispatchData()
    end
end, true)

-- Export für andere Scripts
exports('syncDispatchData', SyncDispatchData)

-- Beim Start einmal synchronisieren
CreateThread(function()
    if not Config.EMDSync or not Config.EMDSync.Enabled then
        return
    end
    
    Wait(5000) -- Warte 5 Sekunden nach Server-Start
    print("^2[EMD-Sync]^7 Erste Synchronisierung...")
    SyncDispatchData()
end)

print("^2[EMD-Sync]^7 Skript erfolgreich geladen!")