function onInit()
	Debug.console("inv_contents_armor_damage.lua", "onInit");
	
	local node = getDatabaseNode();
	Debug.console("node", node);
	DB.addHandler(DB.getPath(node, ".inventorylist.*.hplost"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, ".inventorylist.*.maxhp"), "onUpdate", onArmorChanged);
end

function onClose()
  
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.hplost"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.maxhp"), "onUpdate", onArmorChanged);
end

function onArmorChanged(nodeField)
	Debug.console("Yo here I am");
	local nodeItem = DB.getChild(nodeField, "..");
	if (DB.getValue(nodeItem, "carried", 0) == 2) and ItemManager2.isArmor(nodeItem) then
		CharManager.calcItemArmorClass(DB.getChild(nodeItem, "..."));
	end
end