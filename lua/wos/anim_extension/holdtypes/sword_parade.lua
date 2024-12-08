
local DATA = {}

DATA.Name = "Sword Parade"
DATA.HoldType = "sword_parade"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "idle_all_01"
DATA.Translations[ ACT_MP_WALK ]						= "walk_all"
DATA.Translations[ ACT_MP_RUN ]							= "run_all_01"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "cidle_all"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_all"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "foc_naruto_ninjutsu_rasengun_charge_lv2tolv3" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "foc_naruto_ninjutsu_rasengun_charge_lv2tolv3" 
DATA.Translations[ ACT_MP_RELOAD_STAND ]				= "foc_pain_ninjutsu_almightypush_start"
DATA.Translations[ ACT_MP_JUMP ]						= "jump_dual"

wOS.AnimExtension:RegisterHoldtype( DATA )