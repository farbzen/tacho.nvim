local tacho_component = require("lualine.component"):extend()

function tacho_component:update_status()
  return require("tacho").statusline()
end

return tacho_component
