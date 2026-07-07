local start_items = {}

local robots = 10

local function init()
  storage.equipped = storage.equipped or {}
  storage.pending = storage.pending or {}
end

function start_items.give_to_player(player)
  if not player or not player.valid then return false end
  init()

  if storage.equipped[player.index] then return true end

  if not player.character then
    storage.pending[player.index] = true
    return false
  end

  local character = player.character
  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then return false end

  local armor = armor_inventory[1]

  if not armor.valid_for_read then
    if not armor.set_stack({name = "modular-armor", count = 1}) then
      return false
    end
  end

  local grid = armor.grid or armor.create_grid()

  if grid and grid.valid then
    grid.clear()

    if not grid.put({name = "personal-roboport-equipment", position = {x = 0, y = 0}}) then
      return false
    end

    for x = 2, 4 do
      if not grid.put({name = "battery-equipment", position = {x = x, y = 0}}) then
        return false
      end
    end

    for y = 2, 4 do
      for x = 0, 4 do
        if not grid.put({name = "solar-panel-equipment", position = {x = x, y = y}}) then
          return false
        end
      end
    end
  end

  character.insert({name = "construction-robot", count = robots})

  storage.equipped[player.index] = true
  storage.pending[player.index] = nil

  return true
end

function start_items.give_to_all()
  init()

  for _, player in pairs(game.players) do
    start_items.give_to_player(player)
  end
end

function start_items.process_pending()
  init()

  for player_index in pairs(storage.pending) do
    start_items.give_to_player(game.get_player(player_index))
  end
end

return start_items
