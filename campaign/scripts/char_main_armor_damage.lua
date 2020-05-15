function onInit()
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.hplost"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.maxhp"), "onUpdate", updateArmor);
	
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.hplost"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.maxhp"), "onUpdate", updateArmor);
end

function updateArmor()
	CharManager.calcItemArmorClass(getDatabaseNode());
end