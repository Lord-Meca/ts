if SERVER then

	AddCSLuaFile ()

end


SWEP.PrintName = "Puppets"
SWEP.Author = "Lord_Meca"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "TypeShit | Armes"
SWEP.HoldType = "normal"
SWEP.UseHands = true

SWEP.ViewModel = ''
SWEP.WorldModel = 'models/models/naruto/backpuppet.mdl'

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.defaultHoldType = "normal"

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_tenue_capuche_1.mdl")
end

function SWEP:Initialize()

    self:SetHoldType(self.defaultHoldType)

end

function SWEP:PrimaryAttack()
end

function puppetBase(ply, self, amount,duration)
    local cooldown = 1
    local range = 200

    if self.puppetbase_models and #self.puppetbase_models > 0 then
        for _, puppet in ipairs(self.puppetbase_models) do
            if IsValid(puppet) then
                puppet:Remove()
            end
        end
        self.puppetbase_models = {}
    end


    timer.Simple(cooldown, function() end)

    if SERVER then
        self.puppetbase_models = {}

        for i = 1, amount do
            local puppet = ents.Create("prop_physics")
            if IsValid(puppet) then
    
                puppet:SetModel("models/narutorp/puppets/marionette_2_bane.mdl")
                puppet:SetColor(Color(255, 255, 255))
                puppet:SetModelScale(1)
                puppet:Spawn()

                puppet:SetMoveType(MOVETYPE_NOCLIP)
                puppet:DrawShadow(false)

                
            
                local randomOffset = Vector(math.random(-70, 70), math.random(-40, 40), math.random(-20, 20))
                local offset = Vector(0, (i - 2) * 50, 100) + randomOffset
                puppet:SetPos(ply:GetPos() + ply:GetForward() * range + offset)
                puppet:SetAngles(ply:EyeAngles())


                local playerAttachPos = ply:EyePos() - Vector(0, 0, 20)
                local puppetAttachPos = Vector(0, 0, 40)

                local rope = constraint.Rope(
                    puppet,
                    ply,
                    0,
                    0,
                    puppetAttachPos,
                    playerAttachPos - ply:GetPos(),
                    range,
                    100,
                    0,
                    1,
                    "cable/physbeam",
                    Color(255, 255, 255)
                )

                table.insert(self.puppetbase_models, puppet)


                local sequence = puppet:LookupSequence("balanced_jump")
                if sequence > 0 then
                    puppet:SetSequence(sequence)
                    puppet:SetCycle(0)
                    puppet:SetPlaybackRate(1)
                end


                timer.Create("puppetbase_model_follow_" .. i, 0.01, 0, function()
                    if not IsValid(puppet) or not ply:Alive() then
                        if IsValid(puppet) then
                            puppet:Remove()
                        end
                        timer.Remove("puppetbase_model_follow_" .. i)
                        return
                    end

           
                    local forward = ply:GetForward()
                    local puppetOffset = forward * range + Vector(100, (i - 2) * 50, 100) + randomOffset
                    local targetPos = ply:GetPos() + puppetOffset

                    puppet:SetPos(targetPos)
                    puppet:SetAngles(ply:EyeAngles())

                    local sequence = puppet:LookupSequence("balanced_jump")
                    if sequence > 0 then
                        puppet:SetSequence(sequence)
                        puppet:SetCycle(0)
                        puppet:SetPlaybackRate(1) 
                    end

                    for _, entity in pairs(ents.FindInSphere(puppet:GetPos(), 300)) do
                        if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity:Alive() and entity ~= ply then
                            if SERVER then
                                ply:EmitSound(Sound( "physics/body/body_medium_break2.wav"))
                                ParticleEffect("nrp_kenjutsu_slash", entity:GetPos(), Angle(0, 0, 0), nil)
                
                                local damageInfo = DamageInfo()
                                damageInfo:SetDamage(950) 
                                damageInfo:SetAttacker(ply) 
                                damageInfo:SetInflictor(self)
                                entity:TakeDamageInfo(damageInfo)
                
                                net.Start("DisplayDamage")
                                net.WriteInt(950, 32)
                                net.WriteEntity(entity)
                                net.WriteColor(Color(249, 148, 6, 255))
                                net.Send(ply)
                            end

                        end
                    end
                end)
            end
        end

        timer.Simple(duration, function()
            for _, puppet in ipairs(self.puppetbase_models) do
                
                if IsValid(puppet) then puppet:Remove() end
             

            end
        end)
    end
end




function SWEP:SecondaryAttack()
    self.Weapon:SetNextSecondaryFire(CurTime() +1 )
    local ply = self.Owner


    self:SetHoldType("anim_ninjutsu2")
    ply:SetAnimation(PLAYER_ATTACK1)
    
    timer.Simple(0.6, function()
		puppetBase(ply, self, 1,10)
    end)
end



