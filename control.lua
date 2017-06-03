-- control.lua
require("mod-gui")

-- GUI
local function gui_init(player)
    local gui_names = {
        {"top", "search_inventory_button"},
        {"left", "search_inventory_frame"},
    }
    for k, v in pairs(gui_names) do
        if player.gui[v[1]][v[2]] then
            player.gui[v[1]][v[2]].destroy()
        end
    end

    local flow = mod_gui.get_button_flow(player)
    if not flow.search_inventory_button then
        local button = flow.add{
            type="sprite-button",
            name="search_inventory_button",
            style=mod_gui.button_style,
            sprite="search-sprite",
            tooltip={"search-inventory-search-button-tooltip"}
        }
        button.style.visible=true
    end
end

local function gui_toggle_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.search_inventory_frame
    if frame then
        frame.destroy()
        global["selected_entity"] = nil
    else
        -- Build Gui
        frame = flow.add{
            type="frame",
            caption={"search-inventory-frame-title"},
            name="search_inventory_frame",
            direction="vertical"
        }
        frame.add{
            type="textfield",
            name="search_inventory_textfield",
            text=""
        }
        global["selected_entity"] = player.selected
        local entity_name
        if global["selected_entity"] then 
            entity_name = global["selected_entity"].localised_name
        end
        frame.add{
            type="label",
            name="search_inventory_entity_label",
            caption={"search-inventory-entity-label", entity_name or ""}
        }
    end
end

local function get_LuaInventory(inventory, player, entity)
    local items
    if inventory == "main" then
        items = player.get_inventory(defines.inventory.player_main)
    elseif inventory == "quickbar" then
        items = player.get_inventory(defines.inventory.player_quickbar)
    elseif inventory == "trash" then
        items = player.get_inventory(defines.inventory.player_trash)
    else
        if entity then
            if inventory == "chest" then
                items = entity.get_inventory(defines.inventory.chest)
            elseif inventory == "assemblingmachineinput" then
                items = entity.get_inventory(defines.inventory.assembling_machine_input)
            elseif inventory == "assemblingmachineoutput" then
                items = entity.get_inventory(defines.inventory.assembling_machine_output)
            elseif inventory == "cartrunk" then
                items = entity.get_inventory(defines.inventory.car_trunk)
            elseif inventory == "cargowagon" then
                items = entity.get_inventory(defines.inventory.cargo_wagon)
            elseif inventory == "itemmain" then
                items = entity.get_inventory(defines.inventory.item_main)
            elseif inventory == "rocketsilorocket" then
                items = entity.get_inventory(defines.inventory.rocket_silo_rocket)
            elseif inventory == "rocketsiloresult" then
                items = entity.get_inventory(defines.inventory.rocket_silo_result)
            elseif inventory == "furnacesource" then
                items = entity.get_inventory(defines.inventory.furnace_source)
            elseif inventory == "furnaceresult" then
                items = entity.get_inventory(defines.inventory.furnace_result)
            elseif inventory == "fuel" then
                items = entity.get_inventory(defines.inventory.fuel)
            end
        end
    end
    return items
end

local function search_inventory(player, frame, text, inventory, multiplier)
    multiplier = multiplier or 1
    local entity = global["selected_entity"]
    local items = get_LuaInventory(inventory, player, entity)
    if not items then return end

    local scroll_pane = frame["scroll_pane_"..inventory] or frame.add{
        type="scroll-pane",
        name="scroll_pane_"..inventory,
        style="small_spacing_scroll_pane_style"
    }
    scroll_pane.style.maximal_height = math.floor(settings.global["search-inventory-scroll-pane-max-height"].value * multiplier)
    local results_label = scroll_pane["results_label_"..inventory] or scroll_pane.add{
        type="label",
        name="results_label_"..inventory,
        style="bold_label_style",
        caption={"search-inventory-results-label-"..inventory},
    }
    if scroll_pane["results_table_"..inventory] then
        scroll_pane["results_table_"..inventory].destroy()
    end
    local results_table = scroll_pane.add{
        type="table",
        name="results_table_"..inventory,
        colspan=3,
        style="row_table_style"
    }

    results_table.add{
        type="label",
        name="table_header_icon_"..inventory,
        caption={"search-inventory-table-header-icon"}
    }
    results_table.add{
        type="label",
        name="search_inventory_table_header_name_"..inventory,
        caption={"search-inventory-table-header-name"}
    }
    results_table.add{
        type="label",
        name="search_inventory_table_header_count_"..inventory,
        caption={"search-inventory-table-header-count"}
    }

    local found = false
    for item_name, count in pairs(items.get_contents()) do
        local item = game.item_prototypes[item_name]
        if item and item_name:lower():find(text) then
            found = true
            results_table.add{
                type="sprite",
                name="search_inventory_item_sprite_"..inventory.."_"..item_name,
                sprite="item/"..item_name
            }
            local label = results_table.add{
                type="label",
                name="search_inventory_item_label_"..inventory.."_"..item_name,
                caption=item.localised_name
            }
            --label.style.minimal_height = 34
            label.style.minimal_width = 75
            local label_count = results_table.add{
                type="label",
                name="search_inventory_item_count_"..inventory.."_"..item_name,
                caption=tostring(count)
            }
            --label_count.style.minimal_height = 34
            label_count.style.minimal_width = 20
        end
    end
    if not found then scroll_pane.destroy() end
end

local function on_search_inventory_changed(player, text)
    local frame = mod_gui.get_frame_flow(player).search_inventory_frame
    if not frame then return end
    if string.len(text) < settings.global["search-inventory-min-letter"].value then return end


    local results_frame = frame.results_frame or frame.add{
        type="flow",
        name="results_frame",
        direction="horizontal"
    }

    -- Remove capitals, escapes special characters, replace space with -. Taken from https://mods.factorio.com/mods/Coppermine/what-is-it-really-used-for
    text = text:lower():gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"):gsub(" ", "%%-")

    local categories = {"quickbar", "main", "trash"}
    local entity = global["selected_entity"]
    if entity then
        if entity.type == "assembling-machine" then
            table.insert(categories, "assemblingmachineinput")
            table.insert(categories, "assemblingmachineoutput")
        elseif entity.type == "car" then
            table.insert(categories, "chest")
            table.insert(categories, "cartrunk")
        elseif entity.type == "container" or entity.type == "logistic-container" then
            table.insert(categories, "chest")
        elseif entity.type == "cargo-wagon" then
            table.insert(categories, "cargowagon")
        elseif entity.type == "rocket-silo" then
            table.insert(categories, "rocketsilorocket")
            table.insert(categories, "rocketsiloresult")
        elseif entity.type == "furnace" then
            table.insert(categories, "furnacesource")
            table.insert(categories, "furnaceresult")
            table.insert(categories, "fuel")
        else
            table.insert(categories, "itemmain")
            table.insert(categories, "fuel")
        end
    end
    for _, inventory in pairs(categories) do
        search_inventory(player, results_frame, text, inventory)
    end
end

local function transfer_item_to_cursor(player, inventory, item_name)
    local entity = global["selected_entity"]
    if not player.clean_cursor() then
        game.player.print{"search-inventory-clean-cursor-fail"}
    end
    luainventory = get_LuaInventory(inventory, player, entity)

    local cursor_stack = player.cursor_stack
    local stack = luainventory.find_item_stack(item_name)
    local removed
    if cursor_stack.can_set_stack(stack) and cursor_stack.set_stack(stack) then
        luainventory.remove(stack)
    else
        game.player.print{"search-inventory-cannot-set-stack"}
    end
end

script.on_init(
    function ()
        for _, player in pairs(game.players) do
            gui_init(player)
        end
    end
)

script.on_configuration_changed(
    function(data)
        if not data or not data.mod_changes then return end
        if data.mod_changes["search-inventory"] then
            for _, player in pairs(game.players) do
                gui_init(player)
            end
        end
    end
)

script.on_event(
    {defines.events.on_player_joined_game, defines.events.on_player_created},
    function(event)
        gui_init(game.players[event.player_index])
    end
)

script.on_event(
    "search-inventory",
    function(event)
        gui_toggle_frame(game.players[event.player_index])
    end
)

script.on_event(
    "search-inventory-toggle-button",
    function(event)
        local player = game.players[event.player_index]
        local button = mod_gui.get_button_flow(player).search_inventory_button
        if button then
            button.style.visible = not button.style.visible
        end
    end
)

script.on_event(
    defines.events.on_gui_click,
    function(event)
        local player = game.players[event.player_index]
        if event.element.name == "search_inventory_button" then
            gui_toggle_frame(player)
        else
            local element, inventory, item_name = string.match(event.element.name, "search%_inventory%_item%_(%a+)%_(%a+)%_(.+)")
            if inventory and item_name and (element == "sprite" or element == "label" or element == "count") then
                transfer_item_to_cursor(player, inventory, item_name)
            end
        end
    end
)

script.on_event(
    defines.events.on_gui_text_changed,
    function(event)
        if event.element.name == "search_inventory_textfield" then
            local player = game.players[event.player_index]
            on_search_inventory_changed(player, event.element.text)
        end
    end
)
