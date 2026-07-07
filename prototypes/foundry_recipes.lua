local foundry_item_icons = {
  ["heliopause-foundry-carbonized-regolith"] = "__heliopause-foundry__/graphics/icons/item/carbonized-regolith-icon.png",
  ["heliopause-foundry-slag-deposit"] = "__heliopause-foundry__/graphics/icons/item/slag-deposit-icon.png",
  ["heliopause-foundry-catalyst-crystal"] = "__heliopause-foundry__/graphics/icons/item/catalyst-crystal-icon.png"
}

local foundry_fluid_icons = {
  ["heliopause-foundry-corrosive-coolant"] = "__heliopause-foundry__/graphics/icons/fluid/corrosive-coolant-fluid-icon.png"
}

data:extend({
  {
    type = "recipe",
    name = "heliopause-foundry-process-carbonized-regolith",
    icon = foundry_item_icons["heliopause-foundry-carbonized-regolith"],
    icon_size = 512,
    enabled = false,
    categories = {"crafting"},
    energy_required = 1,
    ingredients = {
      {type = "item", name = "heliopause-foundry-carbonized-regolith", amount = 1}
    },
    results = {
      {type = "item", name = "coal", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "heliopause-foundry-process-slag-deposit",
    icon = foundry_item_icons["heliopause-foundry-slag-deposit"],
    icon_size = 512,
    enabled = false,
    categories = {"crafting"},
    energy_required = 1,
    ingredients = {
      {type = "item", name = "heliopause-foundry-slag-deposit", amount = 1}
    },
    results = {
      {type = "item", name = "tungsten-ore", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "heliopause-foundry-process-catalyst-crystal",
    icon = foundry_item_icons["heliopause-foundry-catalyst-crystal"],
    icon_size = 512,
    enabled = false,
    categories = {"crafting"},
    energy_required = 1,
    ingredients = {
      {type = "item", name = "heliopause-foundry-catalyst-crystal", amount = 1}
    },
    results = {
      {type = "item", name = "calcite", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "heliopause-foundry-process-corrosive-coolant",
    icon = foundry_fluid_icons["heliopause-foundry-corrosive-coolant"],
    icon_size = 512,
    enabled = false,
    categories = {"chemistry"},
    energy_required = 1,
    ingredients = {
      {type = "fluid", name = "heliopause-foundry-corrosive-coolant", amount = 10}
    },
    results = {
      {type = "fluid", name = "sulfuric-acid", amount = 10}
    }
  }
})
