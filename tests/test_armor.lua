local _, GAC = ...
GAC = GAC or _G.GAC

if not GAC or not GAC.TestRunner then
    return
end

local runner = GAC.TestRunner

runner.RunModule("Armor System Data Tests", function()
    runner.AssertNotNil(GAC.armor, "GAC.armor structure exists")
    runner.AssertNotNil(GAC.armor.types, "GAC.armor.types exists")
    runner.AssertNotNil(GAC.armor.slots, "GAC.armor.slots exists")

    -- Test Plate Armor Attributes
    local plate = GAC.armor.types.plate
    runner.AssertNotNil(plate, "Plate armor type defined")
    runner.AssertEqual(plate.physicalReduction, 6, "Plate physical reduction is 6")
    runner.AssertEqual(plate.magicalReduction, 0, "Plate magical reduction is 0")
    runner.AssertEqual(plate.durability, 8, "Plate durability is 8")

    -- Test Clothes Armor Attributes
    local clothes = GAC.armor.types.clothes
    runner.AssertNotNil(clothes, "Clothes armor type defined")
    runner.AssertEqual(clothes.physicalReduction, 0, "Clothes physical reduction is 0")
    runner.AssertEqual(clothes.magicalReduction, 4, "Clothes magical reduction is 4")

    -- Test Leather Armor Attributes
    local leather = GAC.armor.types.leather
    runner.AssertNotNil(leather, "Leather armor type defined")
    runner.AssertEqual(leather.physicalReduction, 2, "Leather physical reduction is 2")
    runner.AssertEqual(leather.magicalReduction, 1, "Leather magical reduction is 1")
end)
