local STARTING_EQUIPMENT = {
  robots = 10,
  batteries = 3,
  solar_panels = 15
}

local TECHS_TO_UNLOCK = {
  "modular-armor",
  "solar-panel-equipment",
  "battery-equipment",
  "construction-robotics",
  "personal-roboport-equipment"
}

local function setup_storage()
  storage.heliopause_foundry_equipped_players =
    storage.heliopause_foundry_equipped_players or {}
end

local function unlock_technologies(force)
  for _, tech_name in pairs(TECHS_TO_UNLOCK) do
    local tech = force.technologies[tech_name]
    if tech then
      tech.researched = true
    end
  end
end

local function put_or_error(grid, equipment)
  local result = grid.put(equipment)

  if not result then
    return false, "Konnte Equipment nicht einsetzen: " .. equipment.name
  end

  return true
end

local function give_starting_equipment(player, force_again)
  if not player or not player.valid then
    return false
  end

  if not player.character then
    player.print("Heliopause Foundry: Spieler hat noch keinen Character. Versuche es spaeter erneut.")
    return false
  end

  setup_storage()

  if storage.heliopause_foundry_equipped_players[player.index] and not force_again then
    player.print("Heliopause Foundry: Startausruestung wurde diesem Spieler bereits gegeben.")
    return true
  end

  local character = player.character

  unlock_technologies(player.force)

  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then
    player.print("Heliopause Foundry: Konnte Armor-Inventar nicht finden.")
    return false
  end

  local armor_stack = armor_inventory[1]

  if not armor_stack.set_stack({name = "modular-armor", count = 1}) then
    player.print("Heliopause Foundry: Konnte modulare Ruestung nicht ausruesten.")
    return false
  end

  local grid = armor_stack.grid
  if not grid then
    grid = armor_stack.create_grid()
  end

  if not grid or not grid.valid then
    player.print("Heliopause Foundry: Konnte Equipment-Grid nicht erstellen.")
    return false
  end

  grid.clear()

  local ok, err

  ok, err = put_or_error(grid, {
    name = "personal-roboport-equipment",
    position = {x = 0, y = 0}
  })
  if not ok then player.print("Heliopause Foundry: " .. err) return false end

  local battery_positions = {
    {x = 2, y = 0},
    {x = 3, y = 0},
    {x = 4, y = 0}
  }

  for _, position in pairs(battery_positions) do
    ok, err = put_or_error(grid, {
      name = "battery-equipment",
      position = position
    })
    if not ok then player.print("Heliopause Foundry: " .. err) return false end
  end

  local panel_count = 0
  for y = 2, 4 do
    for x = 0, 4 do
      panel_count = panel_count + 1
      if panel_count <= STARTING_EQUIPMENT.solar_panels then
        ok, err = put_or_error(grid, {
          name = "solar-panel-equipment",
          position = {x = x, y = y}
        })
        if not ok then player.print("Heliopause Foundry: " .. err) return false end
      end
    end
  end

  character.insert({name = "construction-robot", count = STARTING_EQUIPMENT.robots})

  storage.heliopause_foundry_equipped_players[player.index] = true

  player.print("Heliopause Foundry: Startausruestung installiert. Roboport muss Energie laden.")
  return true
end

local function give_to_all_players(force_again)
  setup_storage()

  for _, player in pairs(game.players) do
    give_starting_equipment(player, force_again)
  end
end

script.on_init(function()
  setup_storage()
  give_to_all_players(false)
end)

script.on_configuration_changed(function()
  setup_storage()
  give_to_all_players(false)
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  give_starting_equipment(player, false)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  give_starting_equipment(player, false)
end)

commands.add_command("hf-start", "Gibt die Heliopause-Foundry-Startausruestung erneut.", function(command)
  local player = game.get_player(command.player_index)

  if not player then
    game.print("Heliopause Foundry: Kein Spieler gefunden.")
    return
  end

  give_starting_equipment(player, true)
end)
