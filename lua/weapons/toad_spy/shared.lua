
AddCSLuaFile()

SWEP.PrintName = "Espionnage du Crapeau | Invocation"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Invocations"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.NextSpecialMove = 0

SWEP.PlayerStates = {} 
SWEP.PlayerState = {
	DEFAULT = 0,
    MUST_PLACE = 1,
    HAS_PLACED = 2,
    WATCHING = 3
}

SWEP.toadPos = {loc = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
SWEP.oldPosToad = 0
SWEP.oldPosVision = 0


function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/konoha_ninja_npc.mdl")

	
end


function SWEP:Initialize()

    self:SetHoldType( "none" )
	self:SetPlayerState(self.Owner, self.PlayerState.DEFAULT)
 	self.tempClone = nil
end



function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
	local ply = self.Owner
    if ply:Crouching() then

        removeToad(self)
    end
end

function SWEP:DoAnimation( anim, type )
	self:SetHoldType(anim)
	self.Owner:SetAnimation(type)
end

function SWEP:SetPlayerState(ply, state)
    if not IsValid(ply) then return end
    self.PlayerStates[ply] = state
end

function SWEP:GetPlayerState(ply)
    if not IsValid(ply) then return nil end
    return self.PlayerStates[ply]
end

function takeVisionToad(ply, bool)

	if bool then

		ply:Freeze(true)
		ply:SetModelScale(0.5)

	else
		ply:Freeze(false)
		ply:SetModel("models/falko_naruto_foc/body_upper/konoha_ninja_npc.mdl")
		ply:SetModelScale(1)
	end

end

function SWEP:Think()
    local ply = self.Owner
    if not IsValid(ply) then return end

    if self:GetPlayerState(ply) == 3 then

        ply:SetNWBool("IsInVignetteState", true)
    else
        ply:SetNWBool("IsInVignetteState", false)
    end

    self:NextThink(CurTime())
    return true
end

hook.Add("HUDPaint", "DrawThickVignette", function()
    local ply = LocalPlayer()

    if ply:GetNWBool("IsInVignetteState", false) then
        local width, height = ScrW(), ScrH()
        local radius = 750
        local centerX, centerY = width / 2, height / 2

        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, width, height)

        for i = 0, 2000 do
            local alpha = math.max(255) 
            surface.SetDrawColor(0, 0, 0, alpha)
            surface.DrawCircle(centerX, centerY, radius + (i * 1))
        end
    end
end)


function controlToad(ply, time, self)

    self.oldPosToad = ply:GetPos()

    ply:SetModel("models/warwax/gamabunta.mdl")
    ply:SetModelScale(0.5)

    timer.Create("toad_untransform", time, 1, function()

        if not IsValid(ply) then return end

		removeClone(self)
        
        takeVisionToad(ply, false)
        self:SetPlayerState(ply, self.PlayerState.DEFAULT)
		ply:SetPos(self.oldPosToad)
        ply:EmitSound("ambient/explosions/explode_9.wav")

        self:DoAnimation("anim_invoke", PLAYER_ATTACK1)

    end)
end

function spawnDynamicModel(pos, ang, model, animation, scale)

    local modelEntity = ents.Create("prop_dynamic") 
    if not IsValid(modelEntity) then return end

    modelEntity:SetModel(model) 
    modelEntity:SetPos(pos)
	modelEntity:SetModelScale(scale)
    modelEntity:SetAngles(ang or Angle(0, 0, 0)) 

    modelEntity:Spawn() 
    modelEntity:Activate()

    local animID = modelEntity:LookupSequence(animation)
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    return modelEntity
end


function createPlyClone(ply, self)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if IsValid(self.tempClone) then
        self.tempClone:Remove()
    end

    self.tempClone = ents.Create("prop_dynamic")
    if not IsValid(self.tempClone) then return end

    self.tempClone:SetModel(ply:GetModel())
    self.tempClone:SetPos(ply:GetPos() + ply:GetRight() * 50 + Vector(0, 0, 5)) 
    self.tempClone:SetAngles(ply:GetAngles())
    self.tempClone:SetKeyValue("solid", "6")
    self.tempClone:Spawn()

    self.tempClone:SetColor(ply:GetColor())
    self.tempClone:SetMaterial(ply:GetMaterial())
    self.tempClone:SetSkin(ply:GetSkin())

    for i = 0, ply:GetNumBodyGroups() - 1 do
        self.tempClone:SetBodygroup(i, ply:GetBodygroup(i))
    end

    if self.tempClone:LookupSequence("kisame_ninjutsu_sharkbomb_charge_loop") >= 0 then
        self.tempClone:ResetSequence("kisame_ninjutsu_sharkbomb_charge_loop")
     end

end

function removeClone(self)
    if IsValid(self.tempClone) then

		
	    self.tempClone:Remove()
        self.tempClone = nil


    end
end

function removeNearlyEntities(pos, modelName, radius)
	if SERVER then
	
		local nearbyEntities = ents.FindInSphere(pos, radius)
		for _, ent in pairs(nearbyEntities) do
			if IsValid(ent) and ent:GetClass() == "prop_dynamic" then
				if ent:GetModel() == modelName then
					ent:Remove()

				end
			end
		end
	end
end


function removeToad(self)

	removeNearlyEntities(self.toadPos.loc, "models/warwax/gamabunta.mdl", 1)
	
   	self:SetPlayerState(self.Owner, self.PlayerState.DEFAULT)

	self.toadPos = {loc = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	self.oldPosToad = 0
	self.oldPosVision = 0

end


function SWEP:Reload()
	local ply = self.Owner

	if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 3

	local particleName = "nrp_tool_invocation"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")
	local currentState = self:GetPlayerState(ply)

	if currentState == 0 or currentState == nil then

		self:DoAnimation("anim_invoke", PLAYER_RELOAD)
		timer.Simple(1, function()
			self:DoAnimation("anim_invoke", PLAYER_ATTACK1)
		end)

		if SERVER then

		    util.AddNetworkString("TemporaryClone")


			timer.Simple(1.5, function()
				ply:Freeze(true)
				ply:EmitSound("ambient/explosions/explode_9.wav")
				if attachment then
					ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
				end


				local modelEntity = ents.Create("prop_physics")
				if IsValid(modelEntity) then
					modelEntity:SetModel("models/foc_props_jutsu/jutsu_sceau_piege/foc_jutsu_sceau_piege.mdl")
					
					modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 0)) 
					modelEntity:SetAngles(Angle(0, 0, 0))
					modelEntity:SetColor(Color(0,0,0,255))
					modelEntity:SetModelScale(4)
					modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
					modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
					modelEntity:SetKeyValue("solid", "0")
						
					modelEntity:Spawn()

					local physObj = modelEntity:GetPhysicsObject()
					if IsValid(physObj) then
						physObj:EnableMotion(false)
					end

				
					timer.Simple(0.5, function()

						self:SetHoldType("anim_gamabunta")
						self:SetPlayerState(ply, self.PlayerState.MUST_PLACE)
						
						createPlyClone(ply, self)
						controlToad(ply,10,self)
						

						timer.Simple(0.7, function() 
							if IsValid(ply) then
							
								ply:Freeze(false)
							end

							if IsValid(modelEntity) then
								modelEntity:Remove()
							end
						end)
					end)

				end





			end)
		end
	
	elseif currentState == 1 then
	
	    self.toadPos = {
			loc = ply:GetPos(),
			ang = ply:EyeAngles()
		}
	
		removeClone(self)
		self:SetPlayerState(ply, self.PlayerState.HAS_PLACED)
		spawnDynamicModel(self.toadPos.loc, self.toadPos.ang, "models/warwax/gamabunta.mdl", "idle", 0.5)

		takeVisionToad(ply, false)
		timer.Remove("toad_untransform")

        
		
		ply:SetPos(self.oldPosToad)
		self.oldPosToad = 0

	elseif currentState == 2 then

		self.oldPosVision = ply:GetPos()
		self:SetPlayerState(ply, self.PlayerState.WATCHING)

		createPlyClone(ply, self)
		takeVisionToad(ply, true)
		ply:SetNoDraw(true)

		ply:SetPos(self.toadPos.loc)	
		ply:SetEyeAngles(self.toadPos.ang)	
		

		timer.Simple(3, function()
		
			self:SetPlayerState(ply, self.PlayerState.HAS_PLACED)
			removeClone(self)

			takeVisionToad(ply, false)

			ply:SetPos(self.oldPosVision)
			ply:SetNoDraw(false)	
			self.oldPosVision = 0
		end)

	end





end
