local foundry_surface = {}

local foundry_base_surface = "heliopause-foundry-base"
local foundry_base_radius = 768
local foundry_base_radius_squared = foundry_base_radius * foundry_base_radius
local foundry_outside_tile = "out-of-map"

local foundry_lava_tiles = {"lava", "lava-hot"}
local foundry_lava_replacement_tile = "volcanic-soil-dark"

local foundry_demolishers = {
  "small-demolisher",
  "medium-demolisher",
  "big-demolisher"
}

local foundry_resource_replacements = {
  ["coal"] = "heliopause-foundry-carbonized-regolith",
  ["tungsten-ore"] = "heliopause-foundry-slag-deposit",
  ["calcite"] = "heliopause-foundry-catalyst-crystal",
  ["sulfuric-acid-geyser"] = "heliopause-foundry-corrosive-vent"
}

local fallback_resource_amounts = {
  ["coal"] = 3000,
  ["tungsten-ore"] = 2500,
  ["calcite"] = 2500,
  ["sulfuric-acid-geyser"] = 100000
}

local function init()
  storage.hf_recreate_foundry_surface = storage.hf_recreate_foundry_surface or false
end

local function get_resource_amount(resource, source_name)
  local ok, amount = pcall(function()
    return resource.amount
  end)

  if ok and amount and amount > 0 then
    return amount
  end

  return fallback_resource_amounts[source_name] or 1000
end

local function get_resource_initial_amount(resource)
  local ok, initial_amount = pcall(function()
    return resource.initial_amount
  end)

  if ok and initial_amount and initial_amount > 0 then
    return initial_amount
  end

  return nil
end

local function create_resource_entity(surface, name, position, amount, initial_amount)
  local ok, created = pcall(function()
    return surface.create_entity({
      name = name,
      position = position,
      amount = amount
    })
  end)

  if not ok or not created or not created.valid then
    ok, created = pcall(function()
      return surface.create_entity({
        name = name,
        position = position
      })
    end)
  end

  if not ok or not created or not created.valid then
    return nil
  end

  if initial_amount then
    pcall(function()
      created.initial_amount = initial_amount
    end)
  end

  return created
end

local function replace_resources_in_area(surface, area)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  for source_name, target_name in pairs(foundry_resource_replacements) do
    local resources = surface.find_entities_filtered({
      area = area,
      type = "resource",
      name = source_name
    })

    for _, resource in pairs(resources) do
      if resource.valid then
        local position = resource.position
        local amount = get_resource_amount(resource, source_name)
        local initial_amount = get_resource_initial_amount(resource)

        resource.destroy({raise_destroy = false})

        local created = create_resource_entity(
          surface,
          target_name,
          position,
          amount,
          initial_amount
        )

        if not created then
          create_resource_entity(
            surface,
            source_name,
            position,
            amount,
            initial_amount
          )
        end
      end
    end
  end
end

local function replace_lava_in_area(surface, area)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  local tiles = {}

  for _, tile in pairs(surface.find_tiles_filtered({area = area, name = foundry_lava_tiles})) do
    tiles[#tiles + 1] = {
      name = foundry_lava_replacement_tile,
      position = tile.position
    }
  end

  if #tiles > 0 then
    surface.set_tiles(tiles, true, true, true, false)
  end
end

local function remove_cliffs_in_area(surface, area)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  for _, cliff in pairs(surface.find_entities_filtered({area = area, type = "cliff"})) do
    if cliff.valid then
      cliff.destroy()
    end
  end
end

local function remove_demolishers_in_area(surface, area)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  for _, demolisher in pairs(surface.find_entities_filtered({area = area, name = foundry_demolishers})) do
    if demolisher.valid then
      demolisher.destroy()
    end
  end
end

local function is_inside_foundry_circle(position)
  local x = position.x or position[1] or 0
  local y = position.y or position[2] or 0

  return x * x + y * y <= foundry_base_radius_squared
end

local function apply_circle_to_area(surface, area)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  local tiles = {}

  local min_x = math.floor(area.left_top.x)
  local max_x = math.ceil(area.right_bottom.x) - 1
  local min_y = math.floor(area.left_top.y)
  local max_y = math.ceil(area.right_bottom.y) - 1

  for x = min_x, max_x do
    for y = min_y, max_y do
      local position = {x = x + 0.5, y = y + 0.5}

      if not is_inside_foundry_circle(position) then
        tiles[#tiles + 1] = {
          name = foundry_outside_tile,
          position = {x = x, y = y}
        }
      end
    end
  end

  if #tiles > 0 then
    surface.set_tiles(tiles, true, true, true, false)
  end
end

function foundry_surface.process_area(surface, area)
  replace_lava_in_area(surface, area)
  apply_circle_to_area(surface, area)
  remove_cliffs_in_area(surface, area)
  remove_demolishers_in_area(surface, area)
  replace_resources_in_area(surface, area)
end

function foundry_surface.process_existing_chunks(surface)
  if not surface or not surface.valid then return end
  if surface.name ~= foundry_base_surface then return end

  for chunk in surface.get_chunks() do
    foundry_surface.process_area(surface, {
      left_top = {
        x = chunk.x * 32,
        y = chunk.y * 32
      },
      right_bottom = {
        x = chunk.x * 32 + 32,
        y = chunk.y * 32 + 32
      }
    })
  end
end

function foundry_surface.process_surface()
  local surface = game.surfaces[foundry_base_surface]
  foundry_surface.process_existing_chunks(surface)
end

local function get_or_create_planet_surface(planet_name)
  local planet = game.planets[planet_name]
  if not planet then return nil end

  return planet.surface or planet.create_surface()
end

local function move_players_off_surface()
  local surface = game.surfaces[foundry_base_surface]
  if not surface then return end

  local nauvis_surface = game.surfaces["nauvis"]
  if not nauvis_surface then return end

  for _, player in pairs(game.players) do
    if player.valid and player.surface and player.surface.name == foundry_base_surface then
      local position = nauvis_surface.find_non_colliding_position("character", {0, 0}, 128, 1) or {0, 0}
      player.teleport(position, nauvis_surface)
      player.print("Heliopause Foundry: Du wurdest nach Nauvis teleportiert, bevor die Foundry-Oberfläche neu erzeugt wird.")
    end
  end
end

function foundry_surface.request_reset(player)
  init()

  local surface = game.surfaces[foundry_base_surface]

  if surface then
    move_players_off_surface()

    if game.delete_surface(surface) then
      storage.hf_recreate_foundry_surface = true

      if player then
        player.print("Heliopause Foundry: Foundry-Oberfläche gelöscht. Sie wird gleich neu erzeugt.")
      end

      return
    end

    if player then
      player.print("Heliopause Foundry: Foundry-Oberfläche konnte nicht gelöscht werden.")
    end

    return
  end

  storage.hf_recreate_foundry_surface = true

  if player then
    player.print("Heliopause Foundry: Foundry-Oberfläche existiert nicht. Sie wird neu erzeugt.")
  end
end

function foundry_surface.recreate_if_needed()
  init()

  if not storage.hf_recreate_foundry_surface then return end
  if game.surfaces[foundry_base_surface] then return end

  local planet = game.planets[foundry_base_surface]

  if not planet then
    storage.hf_recreate_foundry_surface = false
    game.print("Heliopause Foundry: Planet nicht gefunden: " .. foundry_base_surface)
    return
  end

  planet.reset_map_gen_settings()

  local surface = get_or_create_planet_surface(foundry_base_surface)

  if not surface then
    game.print("Heliopause Foundry: Foundry-Oberfläche konnte nicht neu erzeugt werden.")
    return
  end

  surface.request_to_generate_chunks({0, 0}, 8)
  surface.force_generate_chunk_requests()

  foundry_surface.process_existing_chunks(surface)

  storage.hf_recreate_foundry_surface = false

  game.print("Heliopause Foundry: Foundry-Oberfläche wurde neu erzeugt.")
end

return foundry_surface
