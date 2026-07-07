local foundry_resource_replacements = {
  ["coal"] = "heliopause-foundry-carbonized-regolith",
  ["tungsten-ore"] = "heliopause-foundry-slag-deposit",
  ["calcite"] = "heliopause-foundry-catalyst-crystal",
  ["sulfuric-acid-geyser"] = "heliopause-foundry-corrosive-vent"
}

local foundry_resource_graphics = {
  ["heliopause-foundry-carbonized-regolith"] = "__heliopause-foundry__/graphics/resources/carbonized-regolith.png",
  ["heliopause-foundry-slag-deposit"] = "__heliopause-foundry__/graphics/resources/slag-deposit.png",
  ["heliopause-foundry-catalyst-crystal"] = "__heliopause-foundry__/graphics/resources/catalyst-crystal.png",
  ["heliopause-foundry-corrosive-vent"] = "__heliopause-foundry__/graphics/resources/corrosive-vent.png"
}

local foundry_item_icons = {
  ["heliopause-foundry-carbonized-regolith"] = "__heliopause-foundry__/graphics/icons/item/carbonized-regolith-icon.png",
  ["heliopause-foundry-slag-deposit"] = "__heliopause-foundry__/graphics/icons/item/slag-deposit-icon.png",
  ["heliopause-foundry-catalyst-crystal"] = "__heliopause-foundry__/graphics/icons/item/catalyst-crystal-icon.png"
}

local foundry_fluid_icons = {
  ["heliopause-foundry-corrosive-coolant"] = "__heliopause-foundry__/graphics/icons/fluid/corrosive-coolant-fluid-icon.png"
}

local foundry_resource_map_colors = {
  ["heliopause-foundry-carbonized-regolith"] = {r = 0.08, g = 0.07, b = 0.06},
  ["heliopause-foundry-slag-deposit"] = {r = 0.35, g = 0.30, b = 0.26},
  ["heliopause-foundry-catalyst-crystal"] = {r = 0.95, g = 0.72, b = 0.32},
  ["heliopause-foundry-corrosive-vent"] = {r = 0.90, g = 0.75, b = 0.12}
}

local foundry_resource_products = {
  ["heliopause-foundry-carbonized-regolith"] = {
    type = "item",
    name = "heliopause-foundry-carbonized-regolith"
  },
  ["heliopause-foundry-slag-deposit"] = {
    type = "item",
    name = "heliopause-foundry-slag-deposit"
  },
  ["heliopause-foundry-catalyst-crystal"] = {
    type = "item",
    name = "heliopause-foundry-catalyst-crystal"
  },
  ["heliopause-foundry-corrosive-vent"] = {
    type = "fluid",
    name = "heliopause-foundry-corrosive-coolant"
  }
}

local function create_foundry_item(source_name, target_name, icon)
  local source = data.raw.item[source_name]

  if not source then
    error("Missing item prototype: " .. source_name)
  end

  local item = table.deepcopy(source)

  item.name = target_name
  item.localised_name = {"item-name." .. target_name}
  item.localised_description = {"item-description." .. target_name}
  item.icons = nil
  item.pictures = nil
  item.icon = icon
  item.icon_size = 512
  item.order = "z[heliopause-foundry]-" .. target_name

  return item
end

local function create_foundry_fluid(source_name, target_name, icon)
  local source = data.raw.fluid[source_name]

  if not source then
    error("Missing fluid prototype: " .. source_name)
  end

  local fluid = table.deepcopy(source)

  fluid.name = target_name
  fluid.localised_name = {"fluid-name." .. target_name}
  fluid.localised_description = {"fluid-description." .. target_name}
  fluid.icons = nil
  fluid.icon = icon
  fluid.icon_size = 512
  fluid.order = "z[heliopause-foundry]-" .. target_name

  return fluid
end

local function set_resource_product(resource, target_name)
  local product = foundry_resource_products[target_name]
  if not product then return end

  resource.minable = table.deepcopy(resource.minable or {})

  if product.type == "item" then
    resource.minable.result = product.name
    resource.minable.results = nil
    return
  end

  resource.minable.result = nil

  if resource.minable.results then
    for _, result in pairs(resource.minable.results) do
      if result.type == "fluid" then
        result.name = product.name
        return
      end
    end
  end

  resource.minable.results = {
    {
      type = "fluid",
      name = product.name,
      amount = 10
    }
  }
end

local function create_foundry_resource(source_name, target_name)
  local source = data.raw.resource[source_name]

  if not source then
    error("Missing resource prototype: " .. source_name)
  end

  local resource = table.deepcopy(source)

  resource.name = target_name
  resource.localised_name = {"entity-name." .. target_name}
  resource.localised_description = {"entity-description." .. target_name}
  resource.map_color = foundry_resource_map_colors[target_name] or resource.map_color
  resource.autoplace = nil

  set_resource_product(resource, target_name)

  local graphic = foundry_resource_graphics[target_name]

  if graphic then
    resource.stages = {
      sheet = {
        filename = graphic,
        priority = "extra-high",
        width = 512,
        height = 512,
        frame_count = 1,
        variation_count = 1,
        scale = 0.125
      }
    }

    resource.stage_counts = {1}
    resource.stages_effect = nil
  end

  return resource
end

local foundry_items = {
  create_foundry_item(
    "coal",
    "heliopause-foundry-carbonized-regolith",
    foundry_item_icons["heliopause-foundry-carbonized-regolith"]
  ),
  create_foundry_item(
    "tungsten-ore",
    "heliopause-foundry-slag-deposit",
    foundry_item_icons["heliopause-foundry-slag-deposit"]
  ),
  create_foundry_item(
    "calcite",
    "heliopause-foundry-catalyst-crystal",
    foundry_item_icons["heliopause-foundry-catalyst-crystal"]
  )
}

local foundry_fluids = {
  create_foundry_fluid(
    "sulfuric-acid",
    "heliopause-foundry-corrosive-coolant",
    foundry_fluid_icons["heliopause-foundry-corrosive-coolant"]
  )
}

local foundry_resource_prototypes = {}

for source_name, target_name in pairs(foundry_resource_replacements) do
  foundry_resource_prototypes[#foundry_resource_prototypes + 1] = create_foundry_resource(source_name, target_name)
end

data:extend(foundry_items)
data:extend(foundry_fluids)
data:extend(foundry_resource_prototypes)
