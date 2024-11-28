--[[-------------------------------------------------------------------
	Blade Symphony Judgement - Heavy Hold Type:
		Uses the Heavy variation of the Judgement animations from Blade Symphony to create a variety Hold Type
			Powered by
						  _ _ _    ___  ____  
				__      _(_) | |_ / _ \/ ___| 
				\ \ /\ / / | | __| | | \___ \ 
				 \ V  V /| | | |_| |_| |___) |
				  \_/\_/ |_|_|\__|\___/|____/ 
											  
 _____         _                 _             _           
|_   _|__  ___| |__  _ __   ___ | | ___   __ _(_) ___  ___ 
  | |/ _ \/ __| '_ \| '_ \ / _ \| |/ _ \ / _` | |/ _ \/ __|
  | |  __/ (__| | | | | | | (_) | | (_) | (_| | |  __/\__ \
  |_|\___|\___|_| |_|_| |_|\___/|_|\___/ \__, |_|\___||___/
                                         |___/             
----------------------------- Copyright 2017, David "King David" Wiltos ]]--[[
							  
	Lua Developer: King David
	Contact: http://steamcommunity.com/groups/wiltostech
		
-- Copyright 2017, David "King David" Wiltos ]]--


local DATA = {}

DATA.Name = "character holdtype"
DATA.HoldType = "rollsword"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "customcharacter_idle"
DATA.Translations[ ACT_MP_WALK ]						= "walk_charactercustom"
DATA.Translations[ ACT_MP_RUN ]							= "run_charactercustom"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "couch_idle"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_melee1"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "rollsword" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "rollsword" 
--DATA.Translations[ ACT_MP_RELOAD_STAND ]				= IdleActivity + 6
--DATA.Translations[ ACT_MP_RELOAD_CROUCH ]				= IdleActivity + 6
DATA.Translations[ ACT_MP_JUMP ]						= "wos_judge_a_idle"
--DATA.Translations[ ACT_MP_SWIM ]						= IdleActivity + 9
DATA.Translations[ ACT_LAND ]							= "wos_bs_shared_jump_land"

wOS.AnimExtension:RegisterHoldtype( DATA )