function onInit()
	Debug.console("manager_armor_damage.lua", "onInit");
	CharManager.calcItemArmorClass = calcItemArmorClass;
end

function calcItemArmorClass(nodeChar)
  local nMainArmorBase = 10;
  local nMainArmorTotal = 0;
  local nMainShieldTotal = 0;
  local bNonCloakArmorWorn  = ItemManager2.isWearingArmorNamed(nodeChar, DataCommonADND.itemArmorNonCloak);
  local bMagicArmorWorn     = ItemManager2.isWearingMagicArmor(nodeChar);
  local bUsingShield        = ItemManager2.isWearingShield(nodeChar);
  
  Debug.console("manager_armor_damage.lua", "calcItemArmorClass");
-- Debug.console("manager_char.lua","calcItemArmorClass","bNonCloakArmorWorn",bNonCloakArmorWorn);      
-- Debug.console("manager_char.lua","calcItemArmorClass","bMagicArmorWorn",bMagicArmorWorn);      
-- Debug.console("manager_char.lua","calcItemArmorClass","bUsingShield",bUsingShield);      
  
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
      --
-- Debug.console("manager_char.lua","calcItemArmorClass","sTypeLower",sTypeLower);      
-- Debug.console("manager_char.lua","calcItemArmorClass","sSubtypeLower",sSubtypeLower);      
-- Debug.console("manager_char.lua","calcItemArmorClass","nMainArmorBase",nMainArmorBase);      
-- Debug.console("manager_char.lua","calcItemArmorClass","nMainArmorTotal",nMainArmorTotal);      
-- Debug.console("manager_char.lua","calcItemArmorClass","nMainShieldTotal",nMainShieldTotal);   
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
  
  -- if (nMainArmorTotal == 0) and (nMainShieldTotal == 0) and hasTrait(nodeChar, TRAIT_NATURAL_ARMOR) then
    -- nMainArmorTotal = 3;
  -- end
  
  -- flip value for decending ac in nMainShieldTotal -celestian
  nMainShieldTotal = -(nMainShieldTotal);
    
  DB.setValue(nodeChar, "defenses.ac.base", "number", nMainArmorBase);
  DB.setValue(nodeChar, "defenses.ac.armor", "number", nMainArmorTotal);
  DB.setValue(nodeChar, "defenses.ac.shield", "number", nMainShieldTotal);
  
  --steal/dex not used here
  -- DB.setValue(nodeChar, "defenses.ac.dexbonus", "string", sMainDexBonus);
  -- DB.setValue(nodeChar, "defenses.ac.disstealth", "number", nMainStealthDis);
  
  -- add speed penalty for armor type around here? --celestian
    
  -- local bArmorSpeedPenalty = false;
  -- local nArmorSpeed = 0;
  -- if bArmorSpeedPenalty then
    -- nArmorSpeed = -10;
  -- end
  -- DB.setValue(nodeChar, "speed.armor", "number", nArmorSpeed);
  -- local nSpeedTotal = DB.getValue(nodeChar, "speed.base", 12) + nArmorSpeed + DB.getValue(nodeChar, "speed.misc", 0) + DB.getValue(nodeChar, "speed.temporary", 0);
  -- DB.setValue(nodeChar, "speed.total", "number", nSpeedTotal);
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