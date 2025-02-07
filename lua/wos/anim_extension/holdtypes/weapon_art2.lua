
local DATA = {}

DATA.Name = "Weapon Art 2"
DATA.HoldType = "weapon_art2"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "b_idle"
DATA.Translations[ ACT_MP_WALK ]						= "walk_charactercustom"
DATA.Translations[ ACT_MP_RUN ]							= "run_charactercustom"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "couch_idle"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_melee1"

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "foc_jiraya_dbhouse" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "foc_jiraya_dbhouse" 
DATA.Translations[ ACT_MP_RELOAD_STAND ]				= "foc_customman_etc_emotion_bee_fistbump_loop"

DATA.Translations[ ACT_MP_JUMP ]						= "wos_judge_a_idle"

DATA.Translations[ ACT_LAND ]							= "wos_bs_shared_jump_land"

wOS.AnimExtension:RegisterHoldtype( DATA )