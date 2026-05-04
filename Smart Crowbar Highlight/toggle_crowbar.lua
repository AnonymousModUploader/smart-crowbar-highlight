if not CrowbarHL_Settings or not CrowbarHL_Settings.enabled then return end

CrowbarHighlight_Enabled = not CrowbarHighlight_Enabled
if CrowbarHighlight_Enabled then
    if CrowbarHL_Settings.auto_unhighlight
        and managers.player and managers.player:has_special_equipment("crowbar") then
        -- don't highlight, player is holding a crowbar
    else
        for _, keeper in ipairs(CrowbarHighlight_Keepers or {}) do
            if keeper.ext and keeper.ext._active then
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