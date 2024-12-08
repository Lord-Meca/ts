
local DATA = {}

DATA.Name = "Taijutsu2"
DATA.HoldType = "taijutsu2"
DATA.BaseHoldType = "melee2"
DATA.Translations = {}

DATA.Translations[ ACT_MP_STAND_IDLE ]					= "foc_warwax_jeet_idle"
DATA.Translations[ ACT_MP_WALK ]						= "foc_warwax_jeet_walk"
DATA.Translations[ ACT_MP_RUN ]							= "foc_warwax_jeet_walk"
DATA.Translations[ ACT_MP_CROUCH_IDLE ]					= "cwalk_all"
DATA.Translations[ ACT_MP_CROUCHWALK ]					= "cwalk_all"
DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= "foc_warwax_jeet_fr" 
DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= "foc_warwax_jeet_fr" 
DATA.Translations[ ACT_MP_RELOAD_STAND ]				= "foc_warwax_jeet_br"

DATA.Translations[ ACT_MP_JUMP ]						= "jump_dual"


wOS.AnimExtension:RegisterHoldtype( DATA )


