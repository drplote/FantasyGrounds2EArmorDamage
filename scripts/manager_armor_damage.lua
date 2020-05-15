local lOldGetAbsorbedByType = nil;

function onInit()
	CharManager.calcItemArmorClass = calcItemArmorClass;
	
	lOldGetAbsorbedByType = ActionDamage.getAbsorbedByType;
	ActionDamage.getAbsorbedByType = getAbsorbedByType;
end

function getAbsorbedByType(rTarget, aSrcDmgClauseTypes, sRangeType, nDamageToAbsorb)
	local nAbsorbed = lOldGetAbsorbedByType(rTarget, aSrcDmgClauseTypes, sRangeType, nDamageToAbsorb);
	if nAbsorbed < nDamageToAbsorb then
		if ActorManager.isPC(rTarget) then
			local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
			local nodePcArmor = getDamageableArmorWorn(nodeTarget);
			local nArmorHpRemaining = math.max(DB.getValue(nodePcArmor, "maxhp", 0) - DB.getValue(nodePcArmor, "hplost", 0), 0);
			local nDamageSoaked = math.min(1, nArmorHpRemaining);
			nAbsorbed = nAbsorbed + nDamageSoaked;
			if nDamageSoaked > 0 then
				local sCharName = DB.getValue(nodeTarget, "name");
				local sItemName = getItemNameForPlayer(nodePcArmor);
				ChatManager.SystemMessage(sCharName .. "'s " .. sItemName .. " soaks " .. nDamageSoaked .. " damage.");
				addDamageToArmor(nodeTarget, nodePcArmor, nDamageSoaked);
			end
		end
	end
	return nAbsorbed;
end

function calcItemArmorClass(nodeChar)
  local nMainArmorBase = 10;
  local nMainArmorTotal = 0;
  local nMainShieldTotal = 0;
  local bNonCloakArmorWorn  = ItemManager2.isWearingArmorNamed(nodeChar, DataCommonADND.itemArmorNonCloak);
  local bMagicArmorWorn     = ItemManager2.isWearingMagicArmor(nodeChar);
  local bUsingShield        = ItemManager2.isWearingShield(nodeChar);
  
  for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
    if DB.getValue(vNode, "carried", 0) == 2 then
      local sTypeLower = StringManager.trim(DB.getValue(vNode, "type", "")):lower();
      local sSubtypeLower = StringManager.trim(DB.getValue(vNode, "subtype", "")):lower();
      local bIsArmor, _, _ = ItemManager2.isArmor(vNode);
      local bIsShield = (StringManager.contains(DataCommonADND.itemShieldArmorTypes, sSubtypeLower));
      if (not bIsShield) then
        bIsShield = ItemManager2.isShield(vNode);
      end
      local bIsRingOrCloak = (StringManager.contains(DataCommonADND.itemOtherArmorTypes, sSubtypeLower));
      if (not bIsRingOrCloak) then
        bIsRingOrCloak = ItemManager2.isProtectionOther(vNode);
      end
      -- cloaks of protection dont work with magic armor, shields or any armor other than leather.
      if ItemManager2.isItemAnyType("cloak",sTypeLower,sSubtypeLower) and (bNonCloakArmorWorn or bMagicArmorWorn or bUsingShield) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end
      -- robe of protection dont work with magic armor, shields or any armor other than leather.
      if ItemManager2.isItemAnyType("robe",sTypeLower,sSubtypeLower) and (bNonCloakArmorWorn or bMagicArmorWorn or bUsingShield) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end
      -- rings of protection dont work with any magic armor
      if ItemManager2.isItemAnyType("ring",sTypeLower,sSubtypeLower) and (bMagicArmorWorn) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end      

      if (bIsArmor or bIsShield or bIsRingOrCloak) and not isArmorBroken(vNode) then
        local bID = LibraryData.getIDState("item", vNode, true);
        -- we could use bID to make the AC not apply until the item is ID'd? --celestian
        if bIsShield then
          if bID then
            nMainShieldTotal = nMainShieldTotal + (DB.getValue(vNode, "ac", 0)) + (DB.getValue(vNode, "bonus", 0));
          else
            nMainShieldTotal = nMainShieldTotal + (DB.getValue(vNode, "ac", 0)) + (DB.getValue(vNode, "bonus", 0));
          end
        -- we only want the "bonus" value for ring/cloaks/robes
        elseif bIsRingOrCloak then 
          if bID then
            nMainShieldTotal = nMainShieldTotal + DB.getValue(vNode, "bonus", 0);
          else
            nMainShieldTotal = nMainShieldTotal + DB.getValue(vNode, "bonus", 0);
          end
        else
          if bID then
            nMainArmorBase = DB.getValue(vNode, "ac", 0);
          else
            nMainArmorBase = DB.getValue(vNode, "ac", 0);
          end
          -- convert bonus from +bonus to -bonus to adjust AC down for decending AC
          if bID then
            nMainArmorTotal = nMainArmorTotal -(DB.getValue(vNode, "bonus", 0));
          else
            nMainArmorTotal = nMainArmorTotal -(DB.getValue(vNode, "bonus", 0));
          end

        end
      end
    end
  end
  
  nMainShieldTotal = -(nMainShieldTotal);
    
  DB.setValue(nodeChar, "defenses.ac.base", "number", nMainArmorBase);
  DB.setValue(nodeChar, "defenses.ac.armor", "number", nMainArmorTotal);
  DB.setValue(nodeChar, "defenses.ac.shield", "number", nMainShieldTotal);

end

function isArmorBroken(nodeItem)
	local nHpLost = DB.getValue(nodeItem, "hplost", 0);
	local nMaxHp = DB.getValue(nodeItem, "maxhp", 0);
	
	return nMaxHp > 0 and nHpLost >= nMaxHp;
end

function getItemNameForPlayer(nodeItem)
	local bIsIdentified = DB.getValue(nodeItem, "isidentified", 1) == 1;
	local sDisplayName = DB.getValue(nodeItem, "name");
	if not bIsIdentified then
		local sNonIdName = DB.getValue(nodeItem, "nonid_name");
		if sNonIdName and sNonIdName ~= "" then
			sDisplayName = sNonIdName;
		end
	end
	return sDisplayName;
end

function addDamageToArmor(nodeChar, nodeItem, nAmount)
	if nodeItem then
		local nMaxHp = DB.getValue(nodeItem, "maxhp", 0);
		if nMaxHp > 0 then
			local nHpLost = DB.getValue(nodeItem, "hplost", 0);
			local nNewHpLost = math.min(nMaxHp, nHpLost + nAmount);
			if nHpLost < nNewHpLost then 
				DB.setValue(nodeItem, "hplost", "number", nNewHpLost);
				if nNewHpLost >= nMaxHp then
					local sCharName = DB.getValue(nodeChar, "name");
					local sItemName = getItemNameForPlayer(nodeItem);
					ChatManager.SystemMessage(sCharName .. "'s " .. sItemName .. " breaks!");
				end
			else
				Debug.console("manager_armor_damage.lua", "addDamageToArmor", "Can't raise armor damage past it's max HP"); 
			end			
		end
	end
end

function removeDamageFromArmor(nodeChar, nodeItem)
	if nodeItem then
		local nHpLost = DB.getValue(nodeItem, "hplost", 0);
		if nHpLost > 0 then
			DB.setValue(nodeItem, "hplost", "number", nHpLost - 1);		
		end
	end
end

function getDamageableShieldWorn(nodeChar)
	-- Possible problem: If the character has more than one shield worn, this is only going to return the first it finds
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		local nMaxHp = DB.getValue(vNode, "maxhp", 0);
		if DB.getValue(vNode, "carried", 0) == 2 and ItemManager2.isShield(vNode) and nMaxHp > 0 then
			return vNode;
		end
	end
	return nil;
end

function getDamageableArmorWorn(nodeChar)
	-- Possible problem: If the character has more than one armor worn, this is only going to return the first it finds
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		local nMaxHp = DB.getValue(vNode, "maxhp", 0);
		if DB.getValue(vNode, "carried", 0) == 2 and ItemManager2.isArmor(vNode) and not ItemManager2.isShield(vNode) and nMaxHp > 0 then
			return vNode;
		end
	end
	return nil;
end