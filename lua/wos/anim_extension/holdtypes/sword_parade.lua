--=====================================================================
/*		My Custom Holdtype
			Created by Lord_Meca( STEAM_0:0:530747788 )*/
local DATA = {}
DATA.Name = "Sword Parade"
DATA.HoldType = "sword_parade"
DATA.BaseHoldType = "melee2"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "wos_cast_lightning", Weight = 3 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "wos_cast_lightning", Weight = 3 },
}

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "wos_cast_lightning", Weight = 3 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )
--=====================================================================
