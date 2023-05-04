BUTTINGS = BUTTINGS or {}
require("internal/utils/butt_api")
--require("internal/courier")
require("libraries/notifications")
_Thinker = class({})

ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then
		Timers:CreateTimer( BUTTINGS.COMEBACK_TIMER*60, _Thinker.ComebackXP )
		Timers:CreateTimer( BUTTINGS.COMEBACK_TIMER*60, _Thinker.ComebackGold )
		Timers:CreateTimer( BUTTINGS.ALT_TIME_LIMIT*60, _Thinker.WinThinker )
		Timers:CreateTimer( _Thinker.XPThinker )
		-- Timers:CreateTimer( _Thinker.Outpost )
	end
end, self)

function _Thinker:ComebackXP()
	local team = 0
	local amt = nil
	for t,xp in pairs(TeamList:GetTotalEarnedXP()) do
		if (not amt) or (amt>xp) then
			team = t
			amt = xp
		end
	end
	for h,hero in pairs(HeroListButt:GetMainHeroesInTeam(team)) do
		hero:AddExperience(1, DOTA_ModifyXP_Unspecified, false, true)
	end
	return 60/BUTTINGS.COMEBACK_XPPM
end

function _Thinker:ComebackGold()
	local team = 0
	local amt = nil
	for t,gold in pairs(TeamList:GetTotalEarnedGold()) do
		if (not amt) or (amt>gold) then
			team = t
			amt = gold
		end
	end
	for p,player in pairs(PlayerList:GetPlayersInTeam(team)) do
		PlayerResource:ModifyGold(p, 1, false, DOTA_ModifyGold_GameTick) 
	end
	return 60/BUTTINGS.COMEBACK_GPM
end

function _Thinker:XPThinker()
	for h,hero in pairs(HeroListButt:GetMainHeroes()) do
		hero:AddExperience(1, DOTA_ModifyXP_Unspecified, false, true)
	end
	return 60/BUTTINGS.XP_PER_MINUTE
end

function _Thinker:WinThinker()
	if (1==BUTTINGS.ALT_WINNING) then
		local playerID = 0
        local RadiantNetWorth = 0
        local DireNetWorth = 0
        local PlayerTeam = 0
        local PlayerNetWorth = 0
		local WinningTeam = 0
		local LosingTeam = 0
		local HighestNetWorth = 0
		local LowestNetWorth = 99999
		local BestPlayer = 0
		local WorstPlayer = 0
		local BestPlayerOwner = nil
		local WorstPlayerOwner = nil
		local hero1 = nil
		local keepgold1 = 0
		local keepgold2 = 0
		local hero2 = nil
		local WinnerUnit = {}
		local LoserUnit = {}
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do --Cycle through all the players.
                if PlayerResource:IsValidPlayerID(playerID) then --Ignoring invalid players.
                    PlayerTeam = PlayerResource:GetTeam(playerID) --Get what team a player is on.
                    PlayerNetWorth = PlayerResource:GetNetWorth(playerID) --Get their net worth.
                        if PlayerTeam == 2 then --If that player is playing for the Radiant.
                            RadiantNetWorth = RadiantNetWorth + PlayerNetWorth --Add the player's net worth to the Radiant side.
                        else
                            DireNetWorth = DireNetWorth + PlayerNetWorth --Add the NetWorth to the dire side if nothing else is valid.
                        end
                end
            end
        print("[BAREBONES] Radiant Net Worth is ", RadiantNetWorth )
        print("[BAREBONES] Dire Net Worth is ", DireNetWorth )
         if RadiantNetWorth > DireNetWorth then --Seeing which team has more money.
            WinningTeam = DOTA_TEAM_GOODGUYS
			LosingTeam = DOTA_TEAM_BADGUYS
         else
			WinningTeam = DOTA_TEAM_BADGUYS
			LosingTeam = DOTA_TEAM_GOODGUYS
         end
		 for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do --Cycle through all the players.
                if PlayerResource:IsValidPlayerID(playerID) then --Ignoring invalid players.
                    PlayerTeam = PlayerResource:GetTeam(playerID) --Get what team a player is on.
                    PlayerNetWorth = PlayerResource:GetNetWorth(playerID) --Get their net worth.
                        if PlayerTeam == WinningTeam then --If that player is playing for the Winning Team.
							if PlayerNetWorth > HighestNetWorth then
								HighestNetWorth = PlayerNetWorth --Get the value of the Highest Net Worth
							end
						end
                        if PlayerTeam == LosingTeam then --If that player is playing for the Losing Team.
							if PlayerNetWorth < LowestNetWorth then
								LowestNetWorth = PlayerNetWorth --Get the value of the Lowest Net Worth
							end
						end	
                end
         end
		print("[BAREBONES] Winning Team is ", WinningTeam )
        print("[BAREBONES] Losing Team is ", LosingTeam )
		 for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do --Cycle through all the players.
                if PlayerResource:IsValidPlayerID(playerID) then --Ignoring invalid players.
                    PlayerTeam = PlayerResource:GetTeam(playerID) --Get what team a player is on.
                    PlayerNetWorth = PlayerResource:GetNetWorth(playerID) --Get their net worth.
                        if PlayerTeam == WinningTeam then --If that player is playing for the Winning Team.
							if PlayerNetWorth == HighestNetWorth then --If this is the player who has the greatest Net Worth out of anyone.
								BestPlayer = playerID --Get their ID.
								hero1 = PlayerResource:GetSelectedHeroEntity(BestPlayer) --get the hero of the player.
								keepgold1 = hero1:GetGold() -- Get the gold of the swapped player.
								BestPlayerOwner = hero1:GetOwner() --Get the owner of the hero.
								WinnerUnit = hero1:GetAdditionalOwnedUnits() --Get the table of all units owned by this hero. Sadly this doesn't work with illusions or summons.
								hero1:SetTeam(LosingTeam) --Put them on the losing team.
								
								BestPlayerOwner:SetTeam(DOTA_TEAM_NOTEAM)
							end
						end
                        if PlayerTeam == LosingTeam then --If that player is playing for the Losing Team.
							if PlayerNetWorth == LowestNetWorth then --If this player has the lowest net worth out of anyone.
								WorstPlayer = playerID --Get their ID
								hero2 = PlayerResource:GetSelectedHeroEntity(WorstPlayer) --get the hero of the player.
								WorstPlayerOwner = hero2:GetOwner()
								keepgold2 = hero2:GetGold()
								LoserUnit = hero2:GetAdditionalOwnedUnits()
								hero2:SetTeam(WinningTeam) --Put them on the winning team.
								
								WorstPlayerOwner:SetTeam(DOTA_TEAM_NOTEAM)
							end
						end	
                end
         end 
		 print("[BAREBONES] Best Player is ", BestPlayer )
        print("[BAREBONES] Worst Player is ", WorstPlayer )
		Notifications:TopToAll({text="Top Notification for 5 seconds ", duration=5.0})
		BestPlayerOwner:SetTeam(LosingTeam)
		WorstPlayerOwner:SetTeam(WinningTeam)
		hero1:SetGold(keepgold1, true)
		hero2:SetGold(keepgold2, true)
		CustomGameEventManager:Send_ServerToAllClients("top_notification", {hero1, "is now playing for", LosingTeam, hero2, "is now playing for", WinningTeam} )
		for _, hUnit in pairs( WinnerUnit ) do
									hUnit:ForceKill(false)
									hUnit:RespawnUnit()
								end
								for _, hUnit in pairs( LoserUnit ) do
									hUnit:ForceKill(false)
									hUnit:RespawnUnit()
								end
	end
	Timers:CreateTimer( BUTTINGS.ALT_TIME_LIMIT*60, _Thinker.WinThinker )
end
