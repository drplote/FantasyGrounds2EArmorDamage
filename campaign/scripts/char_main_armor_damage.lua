function onInit()
	Debug.console("char_main_armor_damage.lua", "onInit");
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(nodeChar, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(nodeChar, "inventorylist.*.hplost"), "onUpdate", updateArmor);
	
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeChar, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeChar, "inventorylist.*.hplost"), "onUpdate", updateArmor);
end

function updateArmor()
	CharManager.calcItemArmorClass(getDatabaseNode());
end