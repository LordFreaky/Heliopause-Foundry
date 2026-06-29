local STARTING_EQUIPMENT = {
  robots = 10,
  batteries = 3,
  solar_panels = 15
}

local function setup_storage()
  storage.heliopause_foundry_equipped_players =
    storage.heliopause_foundry_equipped_players or {}
end

local function give_starting_equipment(player)
  if not player or not player.valid or not player.character then
    return false
  end

  setup_storage()

  if storage.heliopause_foundry_equipped_players[player.index] then
    return true
  end

  local character = player.character

  character.insert{name = "construction-robot", count = STARTING_EQUIPMENT.robots}

  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then
    player.print("Heliopause Foundry: Could not access armor inventory.")
    return false
  end

  local armor_stack = armor_inventory[1]

  if not armor_stack.set_stack{name = "modular-armor", count = 1} then
    player.print("Heliopause Foundry: Could not equip modular armor.")
    return false
  end

  local grid = armor_stack.grid or armor_stack.create_grid()
  if not grid or not grid.valid then
    player.print("Heliopause Foundry: Could not create armor equipment grid.")
    return false
  end

  grid.clear()

  if not grid.put{name = "personal-roboport-equipment"} then
    player.print("Heliopause Foundry: Could not insert personal roboport.")
    return false
  end

  for i = 1, STARTING_EQUIPMENT.batteries do
    if not grid.put{name = "battery-equipment"} then
      player.print("Heliopause Foundry: Could not insert battery " .. i .. ".")
      return false
    end
  end

  for i = 1, STARTING_EQUIPMENT.solar_panels do
    if not grid.put{name = "solar-panel-equipment"} then
      player.print("Heliopause Foundry: Could not insert solar panel " .. i .. ".")
      return false
    end
  end

  storage.heliopause_foundry_equipped_players[player.index] = true
  player.print("Heliopause Foundry: Starting construction equipment installed.")
  return true
end

local function give_to_all_players()
  setup_storage()

  for _, player in pairs(game.players) do
    give_starting_equipment(player)
  end
end

script.on_init(function()
  setup_storage()
  give_to_all_players()
end)

script.on_configuration_changed(function()
  setup_storage()
  give_to_all_players()
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  give_starting_equipment(player)
end)
