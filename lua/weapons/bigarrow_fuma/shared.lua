
AddCSLuaFile()

SWEP.PrintName = "Grande Flèche | Invocation"
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

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/sogeki_man_sagerouge_1.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "normal" )

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



function shootArrow(ply, self, startPos)
    if not SERVER then return end

    util.AddNetworkString("DisplayDamage")

    local aimDir = ply:GetAimVector()
    local damage = 50
    local speed = 5000
    local velocity = aimDir * speed  

    local ent = ents.Create("prop_physics")
    ent:SetModel("models/foc_props_arme/arme_kidomaru_fleche/foc_arme_kidomaru_fleche.mdl")
    ent:SetPos(startPos + ply:EyeAngles():Forward() * 100 + ply:EyeAngles():Up() * 50)
    ent:SetModelScale(10)

    local eyeAng = ply:EyeAngles()
    eyeAng:RotateAroundAxis(eyeAng:Right(), 0)
    eyeAng:RotateAroundAxis(eyeAng:Up(), 90)
    eyeAng:RotateAroundAxis(eyeAng:Forward(), 90)
    
    ent:SetAngles(eyeAng)
    ent:Spawn()

    util.SpriteTrail(ent, 0, Color(255, 255, 255), false, 200, 200, 1, 50, "trails/laser.vmt")
    ParticleEffectAttach("nrp_ichibi_airgust", PATTACH_POINT_FOLLOW, ent, 0)

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableGravity(false)
        phys:EnableMotion(true)
        phys:SetVelocity(velocity)
    end

    hook.Add("Think", "bigArrowMove" .. ent:EntIndex(), function()
        if not IsValid(ent) then 
            hook.Remove("Think", "bigArrowMove" .. ent:EntIndex())
            return
        end

        ent:SetPos(ent:GetPos() + velocity * FrameTime())

        local tr = util.TraceLine({
            start = ent:GetPos(),
            endpos = ent:GetPos() + velocity * FrameTime(),
            filter = {ent, ply},
            mask = MASK_SOLID
        })
    
        if tr.Hit then
            ent:Remove() 
            hook.Remove("Think", "bigArrowMove" .. ent:EntIndex())
            return
        end

        for _, entity in pairs(ents.FindInSphere(ent:GetPos(), 300)) do
            if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply then

                ply:EmitSound("physics/body/body_medium_break3.wav")
                ParticleEffect("nrp_kenjutsu_slash", entity:GetPos(), entity:GetAngles(), nil)
                local damageInfo = DamageInfo()
                damageInfo:SetDamage(damage)
                damageInfo:SetDamageType(DMG_BLAST)
                damageInfo:SetAttacker(ply)
                damageInfo:SetInflictor(ent)
    
                entity:TakeDamageInfo(damageInfo)

                net.Start("DisplayDamage")
                net.WriteInt(damage, 32)
                net.WriteEntity(entity)
                net.WriteColor(Color(51, 125, 255, 255))
                net.Send(ply)

             
                return
            end
        end
    end)
end



local function invokeBow(ply,self)

    local modelEntity = ents.Create("prop_dynamic")
    local tickDamage = 100

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/foc_props_arme/arme_kidomaru_arc/foc_arme_kidomaru_arc.mdl")

    local playerAngles = ply:EyeAngles()
    local spawnOffset = playerAngles:Forward() * 100 
                            + playerAngles:Right() * 20 
                            + playerAngles:Up() * 50
    
    local spawnPos = ply:GetPos() + spawnOffset
    
    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 90))
    modelEntity:SetModelScale(3)
    modelEntity:Spawn()
    


    timer.Simple(1, function()

        shootArrow(ply, self, spawnPos)

        timer.Simple(1, function()

            if IsValid(modelEntity) then
                ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
                ply:EmitSound("ambient/explosions/explode_9.wav")
                timer.Simple(1, function()
                    modelEntity:Remove()
                   
                end)
            end
        end)

      
    end)
end



function SWEP:Reload()
	local ply = self.Owner

	--if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 5

	local particleName = "nrp_tool_invocation"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

	self:SetHoldType("anim_invoke")
    ply:SetAnimation(PLAYER_RELOAD)
	timer.Simple(1, function()
		self:SetHoldType("anim_invoke")
		ply:SetAnimation(PLAYER_ATTACK1)
	end)



	if SERVER then


		timer.Simple(1.5, function()
			--ply:SetNWBool("freezePlayer", true)
			ply:EmitSound("ambient/explosions/explode_9.wav")
			if attachment then
				ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
			end


			local modelEntity = ents.Create("prop_physics")
			if IsValid(modelEntity) then
				modelEntity:SetModel("models/foc_props_jutsu/jutsu_invocation/foc_jutsu_invocation.mdl")
				
				modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 4)) 
				modelEntity:SetAngles(Angle(180, 0, 0))
				modelEntity:SetColor(Color(0,0,0,255))
				modelEntity:SetModelScale(1)
				modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
				modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
				modelEntity:SetKeyValue("solid", "0")
					
				modelEntity:Spawn()

				local physObj = modelEntity:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:EnableMotion(false)
				end

			
                timer.Simple(0.5, function()
                    invokeBow(ply,self)

                    
                    timer.Simple(0.7, function() 
                        if IsValid(ply) then
                            ply:StopParticles()
                            --ply:SetNWBool("freezePlayer", false)
                        end

                        if IsValid(modelEntity) then
                            modelEntity:Remove()
                        end
                    end)
                end)

			end





		end)
	end

end
