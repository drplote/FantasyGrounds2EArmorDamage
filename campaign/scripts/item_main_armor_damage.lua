function onInit()
	update();
end


function update()
	Debug.console("YO HERE I AM");
	super.update();
	local nodeRecord = getDatabaseNode();
	local bArmor = ItemManager2.isArmor(nodeRecord);
    label_hp_lost.setVisible(bArmor);
	hplost.setVisible(bArmor);
end
