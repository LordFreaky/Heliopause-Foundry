local signal_tech = "heliopause-foundry-signal-from-space"
local rocket_silo_tech = "rocket-silo"

local function has_prerequisite(technology, prerequisite)
  if not technology.prerequisites then return false end

  for _, existing_prerequisite in pairs(technology.prerequisites) do
    if existing_prerequisite == prerequisite then
      return true
    end
  end

  return false
end

local function add_prerequisite(technology, prerequisite)
  technology.prerequisites = technology.prerequisites or {}

  if has_prerequisite(technology, prerequisite) then return end

  table.insert(technology.prerequisites, prerequisite)
end

for _, technology in pairs(data.raw.technology) do
  if technology.name ~= signal_tech and has_prerequisite(technology, rocket_silo_tech) then
    add_prerequisite(technology, signal_tech)
  end
end
