local function give_starting_equipment(player)
  if not player or not player.valid or not player.character then
    return
  end

  -- Give construction robots to the player's inventory.
  player.insert{name = "construction-robot", count = 10}

  -- Equip modular armor.
  local armor_inventory = player.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then
    return
  end

  armor_inventory[1].set_stack{name = "modular-armor", count = 1}

  local armor = armor_inventory[1]
  if not armor.valid_for_read or not armor.grid then
    return
  end

  local grid = armor.grid

  -- Add equipment to the armor grid.
  grid.put{name = "personal-roboport-equipment"}

  for i = 1, 3 do
    grid.put{name = "battery-equipment"}
  end

  for i = 1, 15 do
    grid.put{name = "solar-panel-equipment"}
  end

  player.print("Starting construction equipment installed.")
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  give_starting_equipment(player)
end)
