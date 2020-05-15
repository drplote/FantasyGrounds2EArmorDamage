function onInit()
	update();
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	local bArmor = ItemManager2.isArmor(nodeRecord);
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("item", nodeRecord);
	
	updateControl("hplost", bReadOnly, bID and bArmor); 
	updateControl("maxhp", bReadOnly, bID and bArmor);
	label_max_hp.setVisible(bArmor);
    label_hp_lost.setVisible(bArmor);
	hplost.setVisible(bArmor);
	maxhp.setVisible(bArmor);

end
