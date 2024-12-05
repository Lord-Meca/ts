
AddCSLuaFile()

SWEP.PrintName = "Danse du Faucheur | Invocation"
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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_hood_01.mdl")
end

function SWEP:Initialize()
    self:SetHoldType( "none" )

end


function SWEP:PrimaryAttack()
end

function invokeFuret(ply,self)

	local startPos = ply:GetShootPos()
    local aimDir = ply:GetAimVector()

    ply:EmitSound("content/shukaku_scream2.wav",39,100,5)

	local speed = 1500
    local velocity = aimDir * speed  
    local affectedNearbyEntities = {}
	local ent = ents.Create("prop_dynamic")
	ent:SetModel("models/fsc/billy/furetprout.mdl")
	ent:SetPos(startPos + ply:EyeAngles():Forward() * 200)
	ent:SetModelScale(2)
	ent:SetAngles(aimDir:Angle())
	ent:Spawn()

	local kusarigama = ents.Create("prop_physics")
	kusarigama:SetModel("models/warwax_et_tsu/foc/naruto/faux_kusarigama2.mdl")
	kusarigama:SetModelScale(2)
	kusarigama:SetAngles(aimDir:Angle()+Angle(45,20,0))
	kusarigama:Spawn()


	local offset = Vector(-120,-20,-40) 
	local furetAngles = ent:GetAngles()
	local attachedPos = ent:GetPos() + furetAngles:Forward() * offset.x + furetAngles:Right() * offset.y + furetAngles:Up() * offset.z
	kusarigama:SetPos(attachedPos)

	constraint.Weld(ent, kusarigama, 0, 0, 0, true)

    print(ent:GetSequence())

	util.SpriteTrail(ent, 0, Color(255,255,255), false, 50, 50, 1, 50, "trails/laser.vmt")

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(false)
		phys:EnableMotion(true) 
		phys:SetVelocity(velocity)
	end

    hook.Add("Think", "furetMove" .. ent:EntIndex(), function()
        if not IsValid(ent) or not IsValid(kusarigama) then return end
    

        local currentAngles = ent:GetAngles()
        local newAngles = currentAngles + Angle(100 * FrameTime(), 0, 0)
        ent:SetAngles(newAngles)
    
        local kusarigamaAngles = kusarigama:GetAngles()
        local newkusarigamaAngles = kusarigamaAngles + Angle(100 * FrameTime(), 0, 0)
        kusarigama:SetAngles(newkusarigamaAngles)

        local trace = util.TraceLine({
            start = ent:GetPos(),
            endpos = ent:GetPos() + velocity * 0.2,
            filter = ent
        })
    
        if trace.Hit then
     
            if trace.Entity == ent or trace.Entity == kusarigama then
                return
            end

            local effectdata = EffectData()
            effectdata:SetOrigin(trace.HitPos)
            effectdata:SetNormal(trace.HitNormal)
            ParticleEffect("nrp_tool_invocation", ent:GetPos(), Angle(0, 0, 0), nil)
            ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)
    
            for _, entity in ipairs(ents.FindInSphere(trace.HitPos, 350)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply then
                    
                        ParticleEffect("nrp_kenjutsu_tranchant", ent:GetPos(),ent:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
           
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(350) 
                        damageInfo:SetAttacker(ent) 
                        damageInfo:SetInflictor(self)
                        entity:TakeDamageInfo(damageInfo)
    
          
                        net.Start("DisplayDamage")
                        net.WriteInt(350, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
                    end
                end
            end
    

            ent:Remove()
            kusarigama:Remove()
            hook.Remove("Think", "furetMove" .. ent:EntIndex())
        else
   
            ent:SetPos(ent:GetPos() + velocity * FrameTime())
            kusarigama:SetPos(kusarigama:GetPos() + velocity * FrameTime())

            for _, entity in ipairs(ents.FindInSphere(ent:GetPos(), 200)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply and not affectedNearbyEntities[entity] then

                        ent:SetSequence(ent:LookupSequence("d52_ninjutsu_d52nj2_attack_kmt_start"))
                        ent:SetCycle(0)
                        ent:SetPlaybackRate(1)


                        ply:EmitSound("physics/body/body_medium_break3.wav", 50, 100, 0.5)
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(100)
                        damageInfo:SetAttacker(ent)
                        damageInfo:SetInflictor(self)
                        entity:TakeDamageInfo(damageInfo)

                        net.Start("DisplayDamage")
                        net.WriteInt(100, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
 
                        affectedNearbyEntities[entity] = true
   
                        ParticleEffect("nrp_kenjutsu_slash", ent:GetPos(), ent:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
                      
                    end
                end
            end
        end
    end)

    timer.Simple(5, function()

        if not IsValid(ent) then return end

        ParticleEffect("nrp_tool_invocation", ent:GetPos(), Angle(0, 0, 0), nil)
        ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)

        for _, entity in ipairs(ents.FindInSphere(ent:GetPos(), 350)) do
            if entity:IsPlayer() or entity:IsNPC() then
                if entity ~= ply then

                
                    ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)

       
                    local damageInfo = DamageInfo()
                    damageInfo:SetDamage(350) 
                    damageInfo:SetAttacker(ent) 
                    damageInfo:SetInflictor(self)
                    entity:TakeDamageInfo(damageInfo)

      
                    net.Start("DisplayDamage")
                    net.WriteInt(350, 32)
                    net.WriteEntity(entity)
                    net.WriteColor(Color(249, 148, 6, 255))
                    net.Send(ply)
                end
            end
        end

        ent:Remove()
        kusarigama:Remove()
        hook.Remove("Think", "furetMove" .. ent:EntIndex())

    end)
    
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
	local ply = self.Owner

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 5

	self:SetHoldType("anim_invoke")
    ply:SetAnimation(PLAYER_RELOAD)
	timer.Simple(1, function()
		self:SetHoldType("anim_invoke")
		ply:SetAnimation(PLAYER_ATTACK1)
	end)



	if SERVER then
		util.AddNetworkString("DisplayDamage")
		timer.Simple(1.5, function()
			--ply:Freeze(true)
			ply:EmitSound("ambient/explosions/explode_9.wav")

			ParticleEffect("nrp_tool_invocation", ply:GetPos(), Angle(0,0,0), nil)

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
                    invokeFuret(ply,self)

                    
                    timer.Simple(0.7, function() 
                        if IsValid(ply) then
                            ply:StopParticles()
                            --ply:Freeze(false)
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

