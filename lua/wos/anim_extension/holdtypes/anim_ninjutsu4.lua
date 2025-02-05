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

DATA.Name = "Anim Ninjutsu4"
DATA.HoldType = "anim_ninjutsu4"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "foc_customman_bee_handseal_recoverychakra_loop"
DATA.Translations[ ACT_MP_WALK ]						= "foc_customman_bee_handseal_recoverychakra_loop"
DATA.Translations[ ACT_MP_RUN ]							= "foc_customman_bee_handseal_recoverychakra_loop"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "foc_customman_bee_handseal_recoverychakra_loop"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "foc_customman_bee_handseal_recoverychakra_loop"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "foc_kunai"
DATA.Translations[ ACT_MP_RELOAD_STAND ]				= "foc_customman_ay_etc_win_type01_start"

DATA.Translations[ ACT_MP_JUMP ]						= "jump_dual"


wOS.AnimExtension:RegisterHoldtype( DATA )