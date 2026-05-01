local mod_path = ModPath
local save_path = SavePath
local menu_id = "crowbar_highlight_menu"

-- SETTINGS --
_G.CrowbarHL_Settings = _G.CrowbarHL_Settings or {
    r = 0.9, g = 0.3, b = 0.2,
    enabled = true
}

local function load_settings()
    local file = io.open(save_path .. "crowbar_highlight.json", "r")
    if file then
        local data = json.decode(file:read("*all"))
        file:close()
        if data then
            CrowbarHL_Settings.r = data.r or 0.9
            CrowbarHL_Settings.g = data.g or 0.3
            CrowbarHL_Settings.b = data.b or 0.2
            if data.enabled ~= nil then
                CrowbarHL_Settings.enabled = data.enabled
            else
                CrowbarHL_Settings.enabled = true
            end
        end
    end
end

local function save_settings()
    local file = io.open(save_path .. "crowbar_highlight.json", "w+")
    if file then
        file:write(json.encode(CrowbarHL_Settings))
        file:close()
    end
end

load_settings()

-- COLOR PREVIEW PANEL
local preview_ws = nil
local preview_panel = nil
local preview_rect = nil
local preview_label = nil
local hex_label = nil

local function rgb_to_hex(r, g, b)
    return string.format("%02X%02X%02X",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5)
    )
end

local function hex_to_rgb(hex)
    hex = hex:gsub("#", ""):upper()
    if #hex ~= 6 then return nil end
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)
    if not (r and g and b) then return nil end
    return r/255, g/255, b/255
end

local function update_preview()
    if alive(preview_rect) then
        preview_rect:set_color(Color(
            CrowbarHL_Settings.r,
            CrowbarHL_Settings.g,
            CrowbarHL_Settings.b
        ))
    end
    if alive(hex_label) then
        hex_label:set_text("Hex: #" .. rgb_to_hex(
            CrowbarHL_Settings.r,
            CrowbarHL_Settings.g,
            CrowbarHL_Settings.b
        ))
    end
    if CrowbarHighlight_Units then
        for _, unit in ipairs(CrowbarHighlight_Units) do
            if alive(unit) then
                local color = Vector3(CrowbarHL_Settings.r, CrowbarHL_Settings.g, CrowbarHL_Settings.b)
                local mat = unit:material(Idstring("mtr_crowbar"))
                if mat then mat:set_variable(Idstring("contour_color"), color) end
                local mat2 = unit:material(Idstring("mat_contour"))
                if mat2 then mat2:set_variable(Idstring("contour_color"), color) end
            end
        end
    end
end

local function show_preview()
    if preview_ws then return end
    preview_ws = managers.gui_data:create_saferect_workspace()
    local root = preview_ws:panel()

    preview_panel = root:panel({
        name = "crowbar_hl_preview",
        x = root:w() - 220,
        y = root:h() / 2 - 20,
        w = 200,
        h = 160,
        layer = 200,
    })

    preview_panel:rect({
        name = "bg",
        color = Color(0.85, 0.05, 0.05, 0.05),
        layer = -1,
    })

    preview_panel:rect({
        name = "border",
        color = Color(1, 0.4, 0.4, 0.4),
        layer = -2,
        x = -2, y = -2,
        w = preview_panel:w() + 4,
        h = preview_panel:h() + 4,
    })

    preview_label = preview_panel:text({
        name = "title",
        text = "Color Preview",
        font = tweak_data.menu.pd2_small_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        align = "center",
        vertical = "top",
        x = 0, y = 8,
        w = preview_panel:w(),
        h = 30,
        layer = 1,
    })

    preview_rect = preview_panel:rect({
        name = "swatch",
        color = Color(CrowbarHL_Settings.r, CrowbarHL_Settings.g, CrowbarHL_Settings.b),
        x = 20, y = 45,
        w = preview_panel:w() - 40,
        h = 70,
        layer = 1,
    })

    hex_label = preview_panel:text({
        name = "hex",
        text = "Hex: #" .. rgb_to_hex(CrowbarHL_Settings.r, CrowbarHL_Settings.g, CrowbarHL_Settings.b),
        font = tweak_data.menu.pd2_small_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        align = "center",
        vertical = "top",
        x = 0, y = 124,
        w = preview_panel:w(),
        h = 30,
        layer = 1,
    })
end

local function hide_preview()
    if preview_ws then
        managers.gui_data:destroy_workspace(preview_ws)
        preview_ws = nil
        preview_panel = nil
        preview_rect = nil
        preview_label = nil
        hex_label = nil
    end
end


-- CALLBACKS --
    MenuCallbackHandler.crowbar_hl_enabled = function(self, item)
        CrowbarHL_Settings.enabled = item:value() == "on"
        save_settings()
        if CrowbarHL_Settings.enabled then
            CrowbarHighlight_Enabled = true
            local has_crowbar = managers.player and managers.player:has_special_equipment("crowbar")
            if not has_crowbar then
                for i, unit in ipairs(CrowbarHighlight_Units or {}) do
                    local keeper = CrowbarHighlight_Keepers[i]
                    if alive(unit) and keeper and keeper.ext and keeper.ext._active then
                        keeper.running = true
                        keeper:run()
                    end
                end
            end
        else
            for _, keeper in ipairs(CrowbarHighlight_Keepers or {}) do
                keeper.running = false
            end
            for _, unit in ipairs(CrowbarHighlight_Units or {}) do
                if alive(unit) then CrowbarHL_Unhighlight(unit) end
            end
        end
    end

    MenuCallbackHandler.crowbar_hl_r = function(self, item)
        CrowbarHL_Settings.r = item:value()
        save_settings()
        update_preview()
    end

    MenuCallbackHandler.crowbar_hl_g = function(self, item)
        CrowbarHL_Settings.g = item:value()
        save_settings()
        update_preview()
    end

    MenuCallbackHandler.crowbar_hl_b = function(self, item)
        CrowbarHL_Settings.b = item:value()
        save_settings()
        update_preview()
    end

    MenuCallbackHandler.crowbar_hl_hex = function(self, item)
        local r, g, b = hex_to_rgb(item:value())
        if r then
            CrowbarHL_Settings.r = r
            CrowbarHL_Settings.g = g
            CrowbarHL_Settings.b = b
            save_settings()
            update_preview()
            pcall(function()
                local node = MenuHelper:GetMenu(menu_id)
                if node then
                    local ri = node:item("crowbar_hl_r")
                    local gi = node:item("crowbar_hl_g")
                    local bi = node:item("crowbar_hl_b")
                    if ri then ri:set_value(r) end
                    if gi then gi:set_value(g) end
                    if bi then bi:set_value(b) end
                end
            end)
        end
    end

    MenuCallbackHandler.crowbar_hl_preset_mod = function(self, item)
        CrowbarHL_Settings.r = 0.9
        CrowbarHL_Settings.g = 0.3
        CrowbarHL_Settings.b = 0.2
        save_settings()
        update_preview()
        pcall(function()
            local node = MenuHelper:GetMenu(menu_id)
            if node then
                local ri = node:item("crowbar_hl_r")
                local gi = node:item("crowbar_hl_g")
                local bi = node:item("crowbar_hl_b")
                if ri then ri:set_value(0.9) end
                if gi then gi:set_value(0.3) end
                if bi then bi:set_value(0.2) end
            end
        end)
    end

    MenuCallbackHandler.crowbar_hl_preset_pd2 = function(self, item)
        CrowbarHL_Settings.r = 1.0
        CrowbarHL_Settings.g = 0.5
        CrowbarHL_Settings.b = 0.0
        save_settings()
        update_preview()
        pcall(function()
            local node = MenuHelper:GetMenu(menu_id)
            if node then
                local ri = node:item("crowbar_hl_r")
                local gi = node:item("crowbar_hl_g")
                local bi = node:item("crowbar_hl_b")
                if ri then ri:set_value(1.0) end
                if gi then gi:set_value(0.5) end
                if bi then bi:set_value(0.0) end
            end
        end)
    end

    MenuCallbackHandler.crowbar_hl_focus = function(node, focus)
        if focus then show_preview() else hide_preview() end
    end

    MenuCallbackHandler.crowbar_hl_noop = function(self, item) end

-- MENU SETUP --
Hooks:Add("MenuManagerSetupCustomMenus", "CrowbarHL_Setup", function(menu_manager, nodes)
    MenuHelper:NewMenu(menu_id)
    LocalizationManager:add_localized_strings({
        crowbar_hl_menu_title = "Crowbar Highlight Settings",
        crowbar_hl_menu_desc  = "Configure crowbar highlight behavior and color",
        crowbar_hl_r_title          = "Red",
        crowbar_hl_r_desc           = "Red channel (0 - 1)",
        crowbar_hl_g_title          = "Green",
        crowbar_hl_g_desc           = "Green channel (0 - 1)",
        crowbar_hl_b_title          = "Blue",
        crowbar_hl_b_desc           = "Blue channel (0 - 1)",
        crowbar_hl_hex_title        = "Hex Code",
        crowbar_hl_hex_desc         = "Enter a hex color code (e.g. E64D33) and press enter to apply.",
        crowbar_hl_preset_mod_title = "Apply Mod Default",
        crowbar_hl_preset_mod_desc  = "Applies the mod's default orange-red (E64D33)",
        crowbar_hl_preset_pd2_title = "Apply PD2 Default",
        crowbar_hl_preset_pd2_desc  = "Applies PAYDAY 2's standard contour orange (FF8000)",
        crowbar_hl_black_warning_title = "Note: black (0,0,0) renders as no highlight",
        crowbar_hl_black_warning_desc  = "Setting all color channels to 0 will make the highlight invisible in-game.",
        crowbar_hl_enabled_title = "Mod Enabled",
        crowbar_hl_enabled_desc  = "Toggle the crowbar highlight mod on or off. Persists through heist and game restarts. Use the keybind for a temporary in-heist toggle.",
    })
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "CrowbarHL_Populate", function(menu_manager, nodes)
    MenuHelper:AddToggle({
        id = "crowbar_hl_enabled",
        title = "crowbar_hl_enabled_title",
        desc = "crowbar_hl_enabled_desc",
        callback = "crowbar_hl_enabled",
        value = CrowbarHL_Settings.enabled,
        menu_id = menu_id,
        priority = 11,
    })
    MenuHelper:AddSlider({
        id = "crowbar_hl_r",
        title = "crowbar_hl_r_title",
        desc = "crowbar_hl_r_desc",
        callback = "crowbar_hl_r",
        value = CrowbarHL_Settings.r,
        min = 0, max = 1, step = 0.01,
        show_value = true,
        display_precision = 2,
        menu_id = menu_id,
        priority = 10,
    })
    MenuHelper:AddSlider({
        id = "crowbar_hl_g",
        title = "crowbar_hl_g_title",
        desc = "crowbar_hl_g_desc",
        callback = "crowbar_hl_g",
        value = CrowbarHL_Settings.g,
        min = 0, max = 1, step = 0.01,
        show_value = true,
        display_precision = 2,
        menu_id = menu_id,
        priority = 9,
    })
    MenuHelper:AddSlider({
        id = "crowbar_hl_b",
        title = "crowbar_hl_b_title",
        desc = "crowbar_hl_b_desc",
        callback = "crowbar_hl_b",
        value = CrowbarHL_Settings.b,
        min = 0, max = 1, step = 0.01,
        show_value = true,
        display_precision = 2,
        menu_id = menu_id,
        priority = 8,
    })
    MenuHelper:AddButton({
        id = "crowbar_hl_black_warning",
        title = "crowbar_hl_black_warning_title",
        desc = "crowbar_hl_black_warning_desc",
        callback = "crowbar_hl_noop",
        menu_id = menu_id,
        priority = 7,
    })
    MenuHelper:AddDivider({
        id = "crowbar_hl_div",
        size = 16,
        menu_id = menu_id,
        priority = 6,
    })
    MenuHelper:AddInput({
        id = "crowbar_hl_hex",
        title = "crowbar_hl_hex_title",
        desc = "crowbar_hl_hex_desc",
        callback = "crowbar_hl_hex",
        value = "",
        menu_id = menu_id,
        priority = 5,
    })
    MenuHelper:AddButton({
        id = "crowbar_hl_preset_mod",
        title = "crowbar_hl_preset_mod_title",
        desc = "crowbar_hl_preset_mod_desc",
        callback = "crowbar_hl_preset_mod",
        menu_id = menu_id,
        priority = 4,
    })
    MenuHelper:AddButton({
        id = "crowbar_hl_preset_pd2",
        title = "crowbar_hl_preset_pd2_title",
        desc = "crowbar_hl_preset_pd2_desc",
        callback = "crowbar_hl_preset_pd2",
        menu_id = menu_id,
        priority = 3,
    })
end)

Hooks:Add("MenuManagerBuildCustomMenus", "CrowbarHL_Build", function(menu_manager, nodes)
    nodes[menu_id] = MenuHelper:BuildMenu(menu_id, {
        focus_changed_callback = "crowbar_hl_focus",
    })
    MenuHelper:AddMenuItem(
        nodes["blt_options"],
        menu_id,
        "crowbar_hl_menu_title",
        "crowbar_hl_menu_desc"
    )
end)