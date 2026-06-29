data:extend({
  {
    type = "technology",
    name = "heliopause-foundry-start-equipment",
    icon = "__base__/graphics/technology/construction-robotics.png",
    icon_size = 256,

    enabled = false,
    visible_when_disabled = true,

    prerequisites = {"automation"},

    effects = {},

    unit = {
      count = 25,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 10
    },

    order = "a-b-a"
  }
})
