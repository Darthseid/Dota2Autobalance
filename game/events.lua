require("libraries/notifications")
ListenToGameEvent("dota_player_killed",function(keys)
	-- for k,v in pairs(keys) do print("dota_player_killed",k,v) end
	local playerID = keys.PlayerID
	local heroKill = keys.HeroKill
	local towerKill = keys.TowerKill

-- Send a notification to all players that displays up top for 5 seconds
Notifications:TopToAll({text="Top Notification for 5 seconds ", duration=5.0})
-- Send a notification to playerID 0 which will display up top for 9 seconds and be green, on the same line as the previous notification
Notifications:Top(0, {text="GREEEENNNN", duration=9, style={color="green"}, continue=true})

-- Display 3 styles of hero icons on the same line for 5 seconds.
Notifications:TopToAll({hero="npc_dota_hero_axe", duration=5.0})
Notifications:TopToAll({hero="npc_dota_hero_axe", imagestyle="landscape", continue=true})
Notifications:TopToAll({hero="npc_dota_hero_axe", imagestyle="portrait", continue=true})

-- Display a generic image and then 2 ability icons and an item on the same line for 5 seconds
Notifications:TopToAll({image="file://{images}/status_icons/dota_generic.psd", duration=5.0})
Notifications:TopToAll({ability="nyx_assassin_mana_burn", continue=true})
Notifications:TopToAll({ability="lina_fiery_soul", continue=true})
Notifications:TopToAll({item="item_force_staff", continue=true})


-- Send a notification to all players on radiant (GOODGUYS) that displays near the bottom of the screen for 10 seconds to be displayed with the NotificationMessage class added
Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="AAAAAAAAAAAAAA", duration=10, class="NotificationMessage"})
-- Send a notification to player 0 which will display near the bottom a large red notification with a solid blue border for 5 seconds
Notifications:Bottom(PlayerResource:GetPlayer(0), {text="Super Size Red", duration=5, style={color="red", ["font-size"]="110px", border="10px solid blue"}})


-- Remove 1 bottom and 2 top notifications 2 seconds later
Timers:CreateTimer(2,function()
  Notifications:RemoveTop(0, 2)
  Notifications:RemoveBottomFromTeam(DOTA_TEAM_GOODGUYS, 1)

  -- Add 1 more notification to the bottom
  Notifications:BottomToAll({text="GREEEENNNN again", duration=9, style={color="green"}})
end)

-- Clear all notifications from the bottom
Timers:CreateTimer(7, function()
  Notifications:ClearBottomFromAll()
end)

end, nil)

ListenToGameEvent("entity_killed", function(keys)
	-- for k,v in pairs(keys) do	print("entity_killed",k,v) end
	local attackerUnit = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
	local killedUnit = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	if (killedUnit and killedUnit:IsRealHero()) then
		-- when a hero dies
	end
end, nil)


ListenToGameEvent("npc_spawned", function(keys)
	local unit = keys.entindex and EntIndexToHScript(keys.entindex)
	if unit then
		if unit:GetClassname() == "npc_dota_courier" then    
			Timers:CreateTimer(
				1, 
				function() unit:AddNewModifier( unit, nil, "modifier_invulnerable", { duration = -1 } ) end
			)
		end
	end

end, nil)

ListenToGameEvent("entity_hurt", function(keys)
	-- for k,v in pairs(keys) do print("entity_hurt",k,v) end
	local damage = keys.damage
	local attackerUnit = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
	local victimUnit = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

end, nil)

ListenToGameEvent("dota_player_gained_level", function(keys)
	-- for k,v in pairs(keys) do print("dota_player_gained_level",k,v) end
	local newLevel = keys.level
	local playerEntindex = keys.player
	local playerUnit = EntIndexToHScript(playerEntindex)
	local heroUnit = playerUnit:GetAssignedHero()
	
end, nil)

ListenToGameEvent("dota_player_used_ability", function(keys)
	-- for k,v in pairs(keys) do print("dota_player_used_ability",k,v) end
	local casterUnit = keys.caster_entindex and EntIndexToHScript(keys.caster_entindex)
	local abilityname = keys.abilityname
	local playerID = keys.PlayerID
	local player = keys.PlayerID and PlayerResource:GetPlayer(keys.PlayerID)
	-- local ability = casterUnit and casterUnit.FindAbilityByName and casterUnit:FindAbilityByName(abilityname) -- bugs if hero has 2 times the same ability

end, nil)

ListenToGameEvent("last_hit", function(keys)
	-- for k,v in pairs(keys) do print("last_hit",k,v) end
	local killedUnit = keys.EntKilled and EntIndexToHScript(keys.EntKilled)
	local playerID = keys.PlayerID
	local firstBlood = keys.FirstBlood
	local heroKill = keys.HeroKill
	local towerKill = keys.TowerKill

end, nil)

ListenToGameEvent("dota_tower_kill", function(keys)
	-- for k,v in pairs(keys) do print("dota_tower_kill",k,v) end
	local gold = keys.gold
	local towerTeam = keys.teamnumber
	local killer_userid = keys.killer_userid

end, nil)

------------------------------------------ example --------------------------------------------------

ListenToGameEvent("this_is_just_an_example", function(keys)
	local targetUnit = EntIndexToHScript(keys.entindex)

	local neighbours = FindUnitsInRadius(
		targetUnit:GetTeam(), -- int teamNumber, 
		targetUnit:GetAbsOrigin(), -- Vector position, 
		false, -- handle cacheUnit, 
		1000, -- float radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- int teamFilter, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- int typeFilter, 
		DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, -- int flagFilter, 
		FIND_ANY_ORDER, -- int order, 
		false -- bool canGrowCache
	)

	for n,neighUnit in pairs(neighbours) do

		ApplyDamage({
			victim = neighUnit,
			attacker = targetUnit,
			damage = 100,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = nil
		})

		neighUnit:AddNewModifierButt(
			targetUnit, -- handle caster, 
			nil, -- handle optionalSourceAbility, 
			"someweirdmodifier", -- string modifierName, 
			{duration = 5} -- handle modifierData
		)

	end
end, nil)
