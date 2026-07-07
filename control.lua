local start_items = require("scripts.start_items")
local signal = require("scripts.signal")
local foundry_surface = require("scripts.foundry_surface")

local function setup()
  start_items.give_to_all()
  signal.check_unlock()
  foundry_surface.process_surface()
  foundry_surface.recreate_if_needed()
end

commands.add_command("hf-reset-foundry-surface", "Deletes and recreates the Heliopause Foundry surface for testing.", function(command)
  local player = command.player_index and game.get_player(command.player_index) or nil

  if player and not player.admin then
    player.print("Heliopause Foundry: Nur Admins können die Foundry-Oberfläche zurücksetzen.")
    return
  end

  foundry_surface.request_reset(player)
end)

script.on_init(setup)
script.on_configuration_changed(setup)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_respawned
}, function(event)
  start_items.give_to_player(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]
  foundry_surface.process_existing_chunks(surface)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index)
  if not player or not player.valid then return end

  foundry_surface.process_existing_chunks(player.surface)
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  foundry_surface.process_area(event.surface, event.area)
end)

script.on_nth_tick(60, function()
  start_items.process_pending()
  signal.check_unlock()
  foundry_surface.recreate_if_needed()
end)
