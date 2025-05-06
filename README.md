## Requirements 📋

- ox_lib

## Installation 

1. Drop the `wayne-lobby` folder into your server's resources directory
2. Add `ensure wayne-lobby` to your server.cfg
3. Make sure you have ox_lib installed and running
4. Restart your server and you're good to go!

## How to Use 

By default:
- Press `L` to open the lobby menu (if enabled in config)
- Or use `/lobby` command

From there you can:
- Create a new lobby
- Join an existing lobby
- Leave your current lobby

## Configuration ⚙️

You can tweak these settings in `shared/config.lua`:
```lua
Config.MaxLobbies = 20           -- Maximum number of lobbies
Config.MaxPlayersPerLobby = 10   -- Maximum players per lobby
Config.LobbyTimeout = 3600       -- Lobby timeout in seconds
Config.EnableKeyBinding = true   -- Enable/disable the key binding
Config.KeyBindingKey = 'L'       -- Key to open lobby menu
```

## Commands 💻

- `/lobby` - Opens the lobby menu (works regardless of key binding setting)

## License 📄

Feel free to use and modify this script for your server! Just remember to keep the credits "DONT BE A SKID PASTER TAKING CREDIT"

---
Waynesson
