CrowbarHighlight_Enabled = true

CrowbarHighlight_Units   = CrowbarHighlight_Units   or {}
CrowbarHighlight_Keepers = CrowbarHighlight_Keepers or {}
_G.CrowbarHL_Settings = _G.CrowbarHL_Settings or { r = 0.9, g = 0.3, b = 0.2, enabled = true }

local function highlight(unit)
    local color = Vector3(CrowbarHL_Settings.r, CrowbarHL_Settings.g, CrowbarHL_Settings.b)
    local mat = unit:material(Idstring("mtr_crowbar"))
    if mat then
        mat:set_variable(Idstring("contour_opacity"), 1)
        mat:set_variable(Idstring("contour_color"), color)
    end
    local mat2 = unit:material(Idstring("mat_contour"))
    if mat2 then
        mat2:set_variable(Idstring("contour_opacity"), 1)
        mat2:set_variable(Idstring("contour_color"), color)
    end
end

function CrowbarHL_Unhighlight(unit)
    managers.enemy:remove_delayed_clbk("CrowbarHL_keep_" .. tostring(unit:key()))
    local mat = unit:material(Idstring("mtr_crowbar"))
    if mat then mat:set_variable(Idstring("contour_opacity"), 0) end
    local mat2 = unit:material(Idstring("mat_contour"))
    if mat2 then mat2:set_variable(Idstring("contour_opacity"), 0) end
end

function CrowbarHL_SetHighlights(visible)
    for _, keeper in ipairs(CrowbarHighlight_Keepers) do
        keeper.running = visible and CrowbarHighlight_Enabled and CrowbarHL_Settings.enabled
        if visible and CrowbarHighlight_Enabled and CrowbarHL_Settings.enabled then keeper:run() end
    end
    if not visible or not CrowbarHighlight_Enabled or not CrowbarHL_Settings.enabled then
        for _, unit in ipairs(CrowbarHighlight_Units) do
            if alive(unit) then CrowbarHL_Unhighlight(unit) end
        end
    end
end

local function start_keep_alive(unit, ext)
    local keeper = { unit = unit, running = false, ext = ext, original_active = ext and ext._active or true }
    function keeper:run()
        if alive(self.unit) and self.running and CrowbarHighlight_Enabled and CrowbarHL_Settings.enabled then
            highlight(self.unit)
            if managers.occlusion then
                managers.occlusion:remove_occlusion(self.unit)
            end
            managers.enemy:add_delayed_clbk(
                "CrowbarHL_keep_" .. tostring(self.unit:key()),
                callback(self, self, "run"),
                TimerManager:game():time() + 1
            )
        end
    end
    managers.enemy:add_delayed_clbk(
        "CrowbarHL_keep_" .. tostring(unit:key()),
        callback(keeper, keeper, "run"),
        TimerManager:game():time() + 1
    )
    return keeper
end

local function start_possession_check()
    local checker = { running = true }
    function checker:run()
        if not self.running then return end
        if not CrowbarHighlight_Enabled or not CrowbarHL_Settings.enabled then
            managers.enemy:add_delayed_clbk(
                "CrowbarHL_possession_check",
                callback(self, self, "run"),
                TimerManager:game():time() + 3
            )
            return
        end
        local has_crowbar = managers.player:has_special_equipment("crowbar")
        if has_crowbar then
            for _, keeper in ipairs(CrowbarHighlight_Keepers) do
                if keeper.running then
                    CrowbarHL_SetHighlights(false)
                    break
                end
            end
        else
            for _, keeper in ipairs(CrowbarHighlight_Keepers) do
                -- only restart if the crowbar is actually active
                if not keeper.running and keeper.ext and keeper.ext._active then
                    keeper.running = true
                    keeper:run()
                end
            end
        end
        managers.enemy:add_delayed_clbk(
            "CrowbarHL_possession_check",
            callback(self, self, "run"),
            TimerManager:game():time() + 3
        )
    end
    managers.enemy:add_delayed_clbk(
        "CrowbarHL_possession_check",
        callback(checker, checker, "run"),
        TimerManager:game():time() + 3
    )
end

if RequiredScript == "lib/units/interactions/interactionext" then

    local old_set_active = BaseInteractionExt.set_active
    function BaseInteractionExt:set_active(active, sync)
        old_set_active(self, active, sync)
        if not self._tweak_data then return end
        if self._tweak_data.special_equipment_block == "crowbar" then
            if not self._unit or not alive(self._unit) then return end
            if active then
                for _, keeper in ipairs(CrowbarHighlight_Keepers) do
                    if keeper.unit == self._unit then
                        if CrowbarHL_Settings.enabled and CrowbarHighlight_Enabled then
                            if managers.player:has_special_equipment("crowbar") then
                                keeper.running = false
                                CrowbarHL_Unhighlight(self._unit)
                                return
                            end
                            keeper.running = true
                            keeper:run()
                        end
                        break
                    end
                end
            else
                for _, keeper in ipairs(CrowbarHighlight_Keepers) do
                    if keeper.unit == self._unit then
                        keeper.running = false
                        break
                    end
                end
                CrowbarHL_Unhighlight(self._unit)
            end
        end
    end

    local old_init = BaseInteractionExt.init
    function BaseInteractionExt:init(unit)
        local is_crowbar = self.tweak_data == "gen_pku_crowbar"
        if is_crowbar then
            self._contour_override = true
        end
        old_init(self, unit)
        if is_crowbar then
            if not alive(unit) then return end
            unit:unit_data().ignore_portal = true
            local ext = self
            local keeper = start_keep_alive(unit, ext)
            table.insert(CrowbarHighlight_Units, unit)
            table.insert(CrowbarHighlight_Keepers, keeper)
            managers.enemy:add_delayed_clbk(
                "CrowbarHL_init_" .. tostring(unit:key()),
                function()
                    if not alive(unit) then return end
                    local lvl = Global.game_settings and Global.game_settings.level_id or "?"
                    local has = managers.player:has_special_equipment("crowbar")
                    log("[CrowbarHL] [" .. lvl .. "] Init callback"
                        .. " | active=" .. tostring(ext._active)
                        .. " | has_crowbar=" .. tostring(has)
                        .. " | pos=" .. tostring(unit:position())
                        .. " | key=" .. tostring(unit:key())
                        .. " | unit=" .. tostring(unit:name()))
                    if ext._active and CrowbarHL_Settings.enabled and CrowbarHighlight_Enabled then
                        local lvl = Global.game_settings and Global.game_settings.level_id or "?"
                        if lvl == "mex" then
                            keeper.running = false
                            return
                        end
                        if has then
                            keeper.running = false
                            CrowbarHL_Unhighlight(unit)
                            return
                        end
                        keeper.running = true
                        highlight(unit)
                        keeper:run()
                    else
                        keeper.running = false
                    end
                end,
                TimerManager:game():time() + 0.5
            )
            if #CrowbarHighlight_Units == 1 then
                start_possession_check()
            end
        end
    end

    local old_interact = BaseInteractionExt.interact
    function BaseInteractionExt:interact(player)
        local is_crowbar = self._tweak_data and self._tweak_data.special_equipment_block == "crowbar"
        old_interact(self, player)
        if is_crowbar then
            CrowbarHL_SetHighlights(false)
        end
    end

end

if RequiredScript == "lib/managers/playermanager" then

    local old_remove_special = PlayerManager.remove_special
    function PlayerManager:remove_special(name, ...)
        old_remove_special(self, name, ...)
        if name == "crowbar" and not self:has_special_equipment("crowbar") then
            CrowbarHL_SetHighlights(true)
        end
    end

    local old_add_special = PlayerManager.add_special
    function PlayerManager:add_special(data, ...)
        old_add_special(self, data, ...)
        local name = type(data) == "table" and data.name or data
        if name == "crowbar" then
            CrowbarHL_SetHighlights(false)
        end
    end

end
