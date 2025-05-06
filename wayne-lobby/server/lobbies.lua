local lobbies = {}

local function generateLobbyId()
    return tostring(os.time() .. math.random(1000, 9999))
end

local function isPlayerInLobby(source)
    for lobbyId, lobby in pairs(lobbies) do
        for _, playerId in ipairs(lobby.players) do
            if playerId == source then
                return lobbyId
            end
        end
    end
    return false
end

local function notifyLobbyMembers(lobbyId, excludePlayer, message)
    if lobbies[lobbyId] then
        for _, playerId in ipairs(lobbies[lobbyId].players) do
            if playerId ~= excludePlayer then
                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = 'Lobby System',
                    description = message,
                    type = 'info',
                    position = 'top-right',
                    icon = 'users',
                    iconColor = '#3498db',
                    style = {
                        backgroundColor = 'rgba(0, 0, 0, 0.8)'
                    }
                })
            end
        end
    end
end

RegisterNetEvent('lobbies:requestLobbies')
AddEventHandler('lobbies:requestLobbies', function()
    local source = source
    local currentLobbyId = isPlayerInLobby(source)
    local availableLobbies = {}
    
    for id, lobby in pairs(lobbies) do
        if id ~= currentLobbyId then
            availableLobbies[id] = lobby
        end
    end
    
    TriggerClientEvent('lobbies:receiveLobbies', source, availableLobbies)
end)

RegisterNetEvent('lobbies:joinLobby')
AddEventHandler('lobbies:joinLobby', function(lobbyId, password)
    local source = source
    local lobby = lobbies[lobbyId]
    
    local currentLobbyId = isPlayerInLobby(source)
    if currentLobbyId then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'You are already in a lobby! Leave your current lobby first.',
            type = 'error',
            position = 'top-right',
            icon = 'xmark',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    if not lobby then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'Lobby not found!',
            type = 'error',
            position = 'top-right',
            icon = 'xmark',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    if #lobby.players >= Config.MaxPlayersPerLobby then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'This lobby is full!',
            type = 'error',
            position = 'top-right',
            icon = 'users-slash',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    if lobby.password and lobby.password ~= password then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'Incorrect password!',
            type = 'error',
            position = 'top-right',
            icon = 'lock',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    table.insert(lobby.players, source)
    SetPlayerRoutingBucket(source, tonumber(lobbyId))
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Lobby System',
        description = 'Successfully joined lobby: ' .. lobby.name,
        type = 'success',
        position = 'top-right',
        icon = 'check',
        iconColor = '#28a745',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.8)'
        }
    })
    
    local playerName = GetPlayerName(source)
    
    notifyLobbyMembers(lobbyId, source, playerName .. ' has joined the lobby!')
    
    -- Update client-side lobby status
    TriggerClientEvent('lobbies:joinedLobby', source, lobbyId)
end)

RegisterNetEvent('lobbies:leaveLobby')
AddEventHandler('lobbies:leaveLobby', function(lobbyId)
    local source = source
    local lobby = lobbies[lobbyId]
    
    if lobby then
        for i, playerId in ipairs(lobby.players) do
            if playerId == source then
                table.remove(lobby.players, i)
                break
            end
        end
        
        SetPlayerRoutingBucket(source, 0)
        
        local playerName = GetPlayerName(source)
        
        notifyLobbyMembers(lobbyId, source, playerName .. ' has left the lobby!')
        
        if #lobby.players == 0 then
            lobbies[lobbyId] = nil
        elseif lobby.owner == source and #lobby.players > 0 then
            lobby.owner = lobby.players[1]
            notifyLobbyMembers(lobbyId, nil, GetPlayerName(lobby.players[1]) .. ' is now the lobby owner!')
        end
    end
end)

RegisterNetEvent('lobbies:createLobby')
AddEventHandler('lobbies:createLobby', function(name, password)
    local source = source
    
    if isPlayerInLobby(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'You are already in a lobby! Leave your current lobby first.',
            type = 'error',
            position = 'top-right',
            icon = 'xmark',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    if #lobbies >= Config.MaxLobbies then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Lobby System',
            description = 'Maximum number of lobbies reached!',
            type = 'error',
            position = 'top-right',
            icon = 'xmark',
            iconColor = '#dc3545',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
        return
    end
    
    local lobbyId = generateLobbyId()
    
    lobbies[lobbyId] = {
        id = lobbyId,
        name = name,
        owner = source,
        password = password,
        players = {source},
        created = os.time()
    }
    
    SetPlayerRoutingBucket(source, tonumber(lobbyId))
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Lobby System',
        description = 'You created lobby: ' .. name,
        type = 'success',
        position = 'top-right',
        icon = 'check',
        iconColor = '#28a745',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.8)'
        }
    })
    
    TriggerClientEvent('lobbies:joinedLobby', source, lobbyId)
end)

AddEventHandler('playerDropped', function()
    local source = source
    local lobbyId = isPlayerInLobby(source)
    
    if lobbyId then
        TriggerEvent('lobbies:leaveLobby', lobbyId)
    end
end)