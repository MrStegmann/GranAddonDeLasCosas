local _, GAC = ...
GAC = GAC or _G.GAC

if not GAC or not GAC.TestRunner then
    return
end

local runner = GAC.TestRunner

runner.RunModule("Weapon System Data Tests", function()
    runner.AssertNotNil(GAC.weapons, "GAC.weapons structure exists")

    -- Test Dagger Attributes
    local dagger = GAC.weapons.dagger
    runner.AssertNotNil(dagger, "Dagger weapon defined")
    runner.AssertEqual(dagger.damage, 4, "Dagger damage is 4")
    runner.AssertEqual(dagger.damageType, "piercing", "Dagger damageType is piercing")
    runner.AssertNotNil(dagger.throwable, "Dagger is throwable")

    -- Test Rapier Attributes
    local rapier = GAC.weapons.rapier
    runner.AssertNotNil(rapier, "Rapier weapon defined")
    runner.AssertEqual(rapier.damage, 8, "Rapier damage is 8")

    -- Test Spear Attributes
    local spear = GAC.weapons.spear
    runner.AssertNotNil(spear, "Spear weapon defined")
    runner.AssertEqual(spear.damage, 6, "Spear 1H damage is 6")
    runner.AssertNotNil(spear.twoHanded, "Spear has twoHanded mode")
    runner.AssertEqual(spear.twoHanded.damage, 8, "Spear 2H damage is 8")
end)
