
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
	local kamatari = ents.Create("prop_dynamic")
	kamatari:SetModel("models/fsc/billy/furetprout.mdl")
	kamatari:SetPos(startPos + ply:EyeAngles():Forward() * 200)
	kamatari:SetModelScale(2)
	kamatari:SetAngles(aimDir:Angle()+Angle(0,0,60))
	kamatari:Spawn()

	local kusarigama = ents.Create("prop_physics")
	kusarigama:SetModel("models/warwax_et_tsu/foc/naruto/faux_kusarigama2.mdl")
	kusarigama:SetModelScale(2)
	kusarigama:SetAngles(aimDir:Angle()+Angle(0,70,60))
	--kusarigama:SetAngles(aimDir:Angle()+Angle(45,20,0))
	kusarigama:Spawn()


	local offset = Vector(-120,-20,-40) 
	local offset = Vector(-120,-20,-30) 
	local furetAngles = kamatari:GetAngles()
	local attachedPos = kamatari:GetPos() + furetAngles:Forward() * offset.x + furetAngles:Right() * offset.y + furetAngles:Up() * offset.z
	kusarigama:SetPos(attachedPos)

	constraint.Weld(kamatari, kusarigama, 0, 0, 0, true)

    print(kamatari:GetSequence())

	util.SpriteTrail(kamatari, 0, Color(255,255,255), false, 50, 50, 1, 50, "trails/laser.vmt")

	local phys = kamatari:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(false)
		phys:EnableMotion(true) 
		phys:SetVelocity(velocity)
	end

    hook.Add("Think", "kamatariMove" .. kamatari:EntIndex(), function()
        if not IsValid(kamatari) or not IsValid(kusarigama) then return end
    
        local currentAngles = kamatari:GetAngles()
        local newAngles = currentAngles + Angle(0, 500 * FrameTime(), 0)
        --local newAngles = currentAngles + Angle(300 * FrameTime(), 0, 0)
        kamatari:SetAngles(newAngles)
    
        local kusarigamaAngles = kusarigama:GetAngles()
        local newkusarigamaAngles = kusarigamaAngles + Angle(300 * FrameTime(), 0, 0)
        kusarigama:SetAngles(newkusarigamaAngles)

        local trace = util.TraceLine({
            start = kamatari:GetPos(),
            endpos = kamatari:GetPos() + velocity * 0.2,
            filter = kamatari
        })
    
        if trace.Hit then
     
            if trace.Entity == kamatari or trace.Entity == kusarigama then
                return
            end

            local effectdata = EffectData()
            effectdata:SetOrigin(trace.HitPos)
            effectdata:SetNormal(trace.HitNormal)
            ParticleEffect("nrp_tool_invocation", kamatari:GetPos(), Angle(0, 0, 0), nil)
            ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)
    
            for _, entity in ipairs(ents.FindInSphere(trace.HitPos, 350)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply then
                    
                        ParticleEffect("nrp_kenjutsu_tranchant", kamatari:GetPos(),kamatari:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
           
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(350) 
                        damageInfo:SetAttacker(kamatari) 
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
    

            kamatari:Remove()
            kusarigama:Remove()
            hook.Remove("Think", "kamatariMove" .. kamatari:EntIndex())
        else
   
            kamatari:SetPos(kamatari:GetPos() + velocity * FrameTime())
            kusarigama:SetPos(kusarigama:GetPos() + velocity * FrameTime())

            for _, entity in ipairs(ents.FindInSphere(kamatari:GetPos(), 200)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply and not affectedNearbyEntities[entity] then

                        kamatari:SetSequence(kamatari:LookupSequence("d52_ninjutsu_d52nj2_attack_kmt_start"))
                        kamatari:SetCycle(0)
                        kamatari:SetPlaybackRate(1)


                        ply:EmitSound("physics/body/body_medium_break3.wav", 50, 100, 0.5)
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(100)
                        damageInfo:SetAttacker(kamatari)
                        damageInfo:SetInflictor(self)
                        entity:TakeDamageInfo(damageInfo)

                        net.Start("DisplayDamage")
                        net.WriteInt(100, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
 
                        affectedNearbyEntities[entity] = true
   
                        ParticleEffect("nrp_kenjutsu_slash", kamatari:GetPos(), kamatari:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
                      
                    end
                end
            end
        end
    end)

    timer.Simple(5, function()

        if not IsValid(ent) then return end

        ParticleEffect("nrp_tool_invocation", kamatari:GetPos(), Angle(0, 0, 0), nil)
        ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)

        for _, entity in ipairs(ents.FindInSphere(kamatari:GetPos(), 350)) do
            if entity:IsPlayer() or entity:IsNPC() then
                if entity ~= ply then

                
                    ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)

       
                    local damageInfo = DamageInfo()
                    damageInfo:SetDamage(350) 
                    damageInfo:SetAttacker(kamatari) 
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

        kamatari:Remove()
        kusarigama:Remove()
        hook.Remove("Think", "kamatariMove" .. kamatari:EntIndex())

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

