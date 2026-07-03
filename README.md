We continue to update daily/weekly with your suggestions. Don't forget to join our Discord address to receive updates. https://discord.gg/p55UwT3TqM

### Server Exports (usage examples)
- `exports["devix-inventory"]:OpenStashInventory(source, uniqueId, label)`  
  Example: `exports['devix-inventory']:OpenStashInventory(source, "police_stash", "Police Stash")`

- `exports["devix-inventory"]:OpenSecondInventory(source, secondId, invType, label, secondType)`  
  Example: `exports['devix-inventory']:OpenSecondInventory(source, "stash_123", "stash", "House Stash", "player")`

- `exports["devix-inventory"]:OpenInventory(src, stashName, options)`  
  Example: `exports['devix-inventory']:OpenInventory(source, "player", { label = "My Inventory" })`

- `exports["devix-inventory"]:OpenInventoryById(src, playerId)`  
  Example: `exports['devix-inventory']:OpenInventoryById(source, targetPlayerId)`

- `exports["devix-inventory"]:OpenPlayerSearchForAdmin(searcherSource, targetServerId)`  
  Opens the target player's inventory for the searcher without distance, hands-up or weapon checks (same as `/inv [id]`). Returns `true` on success. Use from admin menus or other server scripts.  
  Example: `exports['devix-inventory']:OpenPlayerSearchForAdmin(source, tonumber(targetId))`

- `exports["devix-inventory"]:AddItem(source, item, amount, slot, info, reason)`  
  Example: `exports['devix-inventory']:AddItem(source, "weapon_pistol", 1, nil, { rarity = "legendary" }, "reward")`

- `exports["devix-inventory"]:RemoveItem(source, item, amount, slot, reason)`

- `exports["devix-inventory"]:HasItem(source, items, amount)` — returns boolean / table depending on usage.

- `exports["devix-inventory"]:GetItemByName(source, item)` / `GetItemsByName(source, item)`

- `exports["devix-inventory"]:GetTotalWeight(items)`

- `exports["devix-inventory"]:LoadInventory` / `SaveInventory` / `SetInventory` / `ClearInventory`

- `exports["devix-inventory"]:LoadGridInventory(identifier, invType, source)` / `SaveGridInventory(identifier, invType, items)`

- `exports["devix-inventory"]:LoadClothes(sourceOrIdentifier)`

- `exports["devix-inventory"]:GetSharedItemInfo(itemName)` / `GetItemSize(itemName)`

- `exports["devix-inventory"]:GetItemCondition(info)` / `SetItemCondition(info, value)`

- `exports["devix-inventory"]:UpdateItemInfoBySerie(...)`

- `exports["devix-inventory"]:UseItem(source, itemName, slot, extra)`

- `exports["devix-inventory"]:SetEquippedWeapon` / `GetEquippedWeapon` / `ClearEquippedWeapon`

### Client Exports (call from other client scripts)
- `exports["devix-inventory"]:SearchPlayer(targetServerId)`  
  Opens the target player's inventory as a second panel (search flow). Respects `Config.SearchPlayer` (RequireHandsUp, RequireWeapon). Pass the **target** player's server ID, not your own.

  **Example — from a menu that has the selected player's server ID:**
  ```lua
  -- selectedServerId = e.g. from your menu when player clicks "Search" on another player
  exports["devix-inventory"]:SearchPlayer(selectedServerId)
  ```

  **Example — search the closest player (same idea as F2, but from your script):**
  ```lua
  local closestPlayer, dist = DEVIX.GetClosestPlayer()
  if closestPlayer and closestPlayer ~= -1 and dist and dist <= 2.5 then
      local targetServerId = GetPlayerServerId(closestPlayer)
      if targetServerId and targetServerId ~= GetPlayerServerId(PlayerId()) then
          exports["devix-inventory"]:SearchPlayer(targetServerId)
      end
  end
  ```

### Client Events (callable from server via TriggerClientEvent)
- `devix-inventory:client:inventoryRefresh` — refresh target player's UI
- `devix-inventory:client:openSearchPlayerInventory` — open another player's search inventory UI (admin/search flow)
- `devix-inventory:client:setInventoryLockedBySearch` — lock/unlock player inventory during search
- `devix-inventory:client:notify` — show a notification: `TriggerClientEvent("devix-inventory:client:notify", src, "success", "Message")`
- `devix-inventory:client:itemNotify` — item added/removed notification for player

(There are many other internal client events used by the resource; use the exports above where possible.)

### Integration notes
- The resource exposes exports so other scripts can open inventories, add/remove items, and query item metadata. Prefer exports over triggering internal events for stability.
- Admin commands and permission checks are configurable:
  - Command names: `Config.AdminCommands` in `devix-inventory/config.lua`.
  - ACE permission: `Config.SearchPlayer.SearchAce` and `Config.ClearInvAce`.
  - devix-core helper: `DEVIX.HasPermission(source)` can be used to whitelist licenses (see `devix-core/shared/config.lua` -> `Config.AuthorizedLicenses`).

---

## Installation / Setup

Follow these steps to install and configure devix-inventory on your server.

1. Copy the resource folder to your server resources directory:
   - Example: `resources/[devix]/devix-inventory`

2. Ensure dependencies are present:
   - `devix-core` (required)
   - `qb-core` or your chosen framework (match `Config.Framework` in `devix-core/shared/config.lua`)
   - `oxmysql` or configured MySQL driver (match `Config.Mysql`)

3. Add resources to your `server.cfg` (or start them via your resource manager):
   - Example ordering:
     ensure devix-core
     ensure devix-inventory

4. Configure permissions (choose one or more options):
   - ACE-based: add ACEs in `server.cfg` (e.g. `add_ace group.admin devix-inventory.clearinv allow`) and assign principals.
   - Group-based: if you use `group.admin` already, the script checks `IsPlayerAceAllowed(..., "group.admin")`.
   - License whitelist: add allowed license IDs to `devix-core/shared/config.lua` under `Config.AuthorizedLicenses = { "license:...", ... }`

5. Adjust `devix-inventory/config.lua` to your needs:
   - Set `Config.Mysql`, grid sizes, item definitions (`Config.Items`), and `Config.AdminCommands` if you want custom command names.
   - Tune `Config.SearchPlayer` and `Config.ClearInvAce` permissions.

6. Restart the server (or restart the `devix-core` and `devix-inventory` resources).

7. Verify in-game:
   - Use F8 to print identifiers:  
     `for i,v in ipairs(GetPlayerIdentifiers(PlayerId())) do print(v) end`  
     Add the `license:...` value to `Config.AuthorizedLicenses` if you use license whitelist.
   - Test admin commands (e.g. `/inv <id>`, `/clearinv <id>`, `/giveitem <id> <item> <amount>`) and exports.

If you need a sample `server.cfg` snippet or help wiring ACE/principal entries, tell me your preferred identification method (license/steam/fivem) and I can produce the exact lines to add.