
local DATA = {}

DATA.Name = "Weapon Art"
DATA.HoldType = "weapon_art"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "b_idle"
DATA.Translations[ ACT_MP_WALK ]						= "walk_charactercustom"
DATA.Translations[ ACT_MP_RUN ]							= "run_charactercustom"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "couch_idle"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_melee1"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "h_left_t3" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "h_left_t3" 
DATA.Translations[ ACT_MP_RELOAD_STAND ]				= "foc_jiraiya_oil_bombs"

DATA.Translations[ ACT_MP_JUMP ]						= "wos_judge_a_idle"

DATA.Translations[ ACT_LAND ]							= "wos_bs_shared_jump_land"

wOS.AnimExtension:RegisterHoldtype( DATA )