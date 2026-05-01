CrowbarHighlight_Enabled = not CrowbarHighlight_Enabled
if CrowbarHighlight_Enabled then
    if managers.player and not managers.player:has_special_equipment("crowbar") then
        for _, keeper in ipairs(CrowbarHighlight_Keepers or {}) do
            keeper.running = true
            keeper:run()
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