local currentLobby = nil

RegisterCommand('lobby', function()
    openLobbyMenu()
end, false)

RegisterKeyMapping('lobby', 'Open Lobby Menu', 'keyboard', 'L')

function openLobbyMenu()
    lib.registerContext({
        id = 'lobby_menu',
        title = 'Lobby System',
        options = {
            {
                title = 'Create Lobby',
                description = 'Create a new private lobby',
                icon = 'plus',
                onSelect = function()
                    createLobbyDialog()
                end
            },
            {
                title = 'Join Lobby',
                description = 'Join an existing lobby',
                icon = 'door-open',
                onSelect = function()
                    showAvailableLobbies()
                end
            },
            {
                title = 'Leave Lobby',
                description = 'Exit current lobby',
                icon = 'door-closed',
                disabled = not currentLobby,
                onSelect = function()
                    leaveLobby()
                end
            }
        }
    })
    lib.showContext('lobby_menu')
end

function showAvailableLobbies()
    TriggerServerEvent('lobbies:requestLobbies')
end

RegisterNetEvent('lobbies:receiveLobbies')
AddEventHandler('lobbies:receiveLobbies', function(availableLobbies)
    local options = {}
    
    for _, lobby in pairs(availableLobbies) do
        table.insert(options, {
            title = lobby.name,
            description = string.format('Players: %d/%d', #lobby.players, Config.MaxPlayersPerLobby),
            icon = lobby.password and 'lock' or 'users',
            onSelect = function()
                joinLobbyDialog(lobby)
            end
        })
    end
    
    if #options == 0 then
        table.insert(options, {
            title = 'No Lobbies Available',
            description = 'Create a new lobby to get started!',
            icon = 'info-circle',
            disabled = true
        })
    end
    
    lib.registerContext({
        id = 'available_lobbies',
        title = 'Available Lobbies',
        options = options
    })
    
    lib.showContext('available_lobbies')
end)

function joinLobbyDialog(lobby)
    if lobby.password then
        local input = lib.inputDialog('Join Lobby', {
            {type = 'input', label = 'Password', password = true, required = true}
        })
        
        if input then
            TriggerServerEvent('lobbies:joinLobby', lobby.id, input[1])
        end
    else
        TriggerServerEvent('lobbies:joinLobby', lobby.id)
    end
end

function createLobbyDialog()
    local input = lib.inputDialog('Create Lobby', {
        {type = 'input', label = 'Lobby Name', required = true},
        {type = 'input', label = 'Password (optional)', password = true}
    })
    
    if input then
        TriggerServerEvent('lobbies:createLobby', input[1], input[2])
    end
end

RegisterNetEvent('lobbies:joinedLobby')
AddEventHandler('lobbies:joinedLobby', function(lobbyId)
    currentLobby = lobbyId
    lib.notify({
        title = 'Lobby System',
        description = 'Successfully joined lobby!',
        type = 'success',
        position = 'top-right',
        icon = 'check',
        iconColor = '#28a745',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.8)'
        }
    })
end)

RegisterNetEvent('lobbies:error')
AddEventHandler('lobbies:error', function(message)
    lib.notify({
        title = 'Lobby System',
        description = message,
        type = 'error',
        position = 'top-right',
        icon = 'xmark',
        iconColor = '#dc3545',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.8)'
        }
    })
end)

function leaveLobby()
    if currentLobby then
        TriggerServerEvent('lobbies:leaveLobby', currentLobby)
        currentLobby = nil
        lib.notify({
            title = 'Lobby System',
            description = 'You left the lobby',
            type = 'info',
            position = 'top-right',
            icon = 'door-closed',
            iconColor = '#3498db',
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.8)'
            }
        })
    end
end