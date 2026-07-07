local signal = {}

local signal_tech = "heliopause-foundry-signal-from-space"
local radar_tech = "radar"
local radar_entity = "radar"

local min_signal_delay = 5 * 60 * 60
local max_signal_delay = 20 * 60 * 60
local max_unpowered_radar_ticks = 30 * 60

local function init()
  storage.hf_signal_rng = storage.hf_signal_rng or game.create_random_generator()
  storage.hf_signal_researched_forces = storage.hf_signal_researched_forces or {}
  storage.hf_signal_unlock_ticks = storage.hf_signal_unlock_ticks or {}
  storage.hf_signal_unpowered_since_ticks = storage.hf_signal_unpowered_since_ticks or {}
end

local function random_signal_delay()
  init()

  local range = max_signal_delay - min_signal_delay + 1
  local rolled = math.floor(storage.hf_signal_rng() * range)

  if rolled >= range then
    rolled = range - 1
  end

  return min_signal_delay + rolled
end

local function print_to_force(force, message)
  for _, player in pairs(game.players) do
    if player.valid and player.force and player.force.name == force.name then
      player.print(message)
    end
  end
end

local function force_has_researched_technology(force, technology_name)
  local tech = force.technologies[technology_name]
  return tech and tech.researched
end

local function radar_has_power(radar)
  local status = radar.status
  return status and status ~= defines.entity_status.no_power and status ~= defines.entity_status.low_power
end

local function get_force_radar_status(force)
  local has_radar = false

  for _, surface in pairs(game.surfaces) do
    for _, radar in pairs(surface.find_entities_filtered({name = radar_entity, force = force})) do
      has_radar = true

      if radar_has_power(radar) then
        return true, true
      end
    end
  end

  return has_radar, false
end

local function reset_signal_timer_for_force(force)
  storage.hf_signal_unlock_ticks[force.name] = nil
  storage.hf_signal_unpowered_since_ticks[force.name] = nil
end

local function unlock_signal_for_force(force)
  local tech = force.technologies[signal_tech]

  if not tech then return end
  if tech.researched then return end
  if storage.hf_signal_researched_forces[force.name] then return end

  tech.enabled = true
  tech.visible_when_disabled = true
  tech.researched = true

  storage.hf_signal_researched_forces[force.name] = true
  reset_signal_timer_for_force(force)

  print_to_force(force, {"heliopause-foundry.signal-researched"})
end

local function update_signal_timer_for_force(force)
  local tech = force.technologies[signal_tech]

  if not tech then return end

  if tech.researched or storage.hf_signal_researched_forces[force.name] then
    reset_signal_timer_for_force(force)
    return
  end

  if not force_has_researched_technology(force, radar_tech) then
    reset_signal_timer_for_force(force)
    return
  end

  local has_radar, has_powered_radar = get_force_radar_status(force)

  if not has_radar then
    reset_signal_timer_for_force(force)
    return
  end

  local unlock_tick = storage.hf_signal_unlock_ticks[force.name]

  if not has_powered_radar then
    if not unlock_tick then
      storage.hf_signal_unpowered_since_ticks[force.name] = nil
      return
    end

    local unpowered_since_tick = storage.hf_signal_unpowered_since_ticks[force.name]

    if not unpowered_since_tick then
      storage.hf_signal_unpowered_since_ticks[force.name] = game.tick
      return
    end

    if game.tick - unpowered_since_tick > max_unpowered_radar_ticks then
      reset_signal_timer_for_force(force)
    end

    return
  end

  storage.hf_signal_unpowered_since_ticks[force.name] = nil

  if not unlock_tick then
    storage.hf_signal_unlock_ticks[force.name] = game.tick + random_signal_delay()
    print_to_force(force, {"heliopause-foundry.signal-unlocked"})
    return
  end

  if game.tick >= unlock_tick then
    unlock_signal_for_force(force)
  end
end

function signal.check_unlock()
  init()

  for _, force in pairs(game.forces) do
    update_signal_timer_for_force(force)
  end
end

return signal
