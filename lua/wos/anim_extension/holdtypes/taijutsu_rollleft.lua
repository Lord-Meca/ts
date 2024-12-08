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

DATA.Name = "taijutsu rollleft"
DATA.HoldType = "taijutsu_rollleft"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "foc_warwax_jeet_idle"
DATA.Translations[ ACT_MP_WALK ]						= "foc_warwax_jeet_walk"
DATA.Translations[ ACT_MP_RUN ]							= "foc_warwax_jeet_walk"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "cwalk_all"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_all"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "rollleft" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "rollleft" 

DATA.Translations[ ACT_MP_JUMP ]						= "jump_dual"

wOS.AnimExtension:RegisterHoldtype( DATA )