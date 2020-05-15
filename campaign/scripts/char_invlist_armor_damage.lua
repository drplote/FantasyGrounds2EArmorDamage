function onInit()
	Debug.console("char_invlist_armor_damage.lua", "onInit");
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.hplost"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.maxhp"), "onUpdate", onArmorChanged);
end

function onClose()
	super.onInit();
  
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.hplost"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.maxhp"), "onUpdate", onArmorChanged);
end

function onArmorChanged()
	Debug.console("Yo here I am");
	super.onArmorChanged();
end