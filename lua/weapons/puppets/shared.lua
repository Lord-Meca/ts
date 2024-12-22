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
SWEP.attackAnimList = {"a_combo1", "a_combo2", "a_combo3", "a_combo4","seq_meleeattack01"}


function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_tenue_capuche_1.mdl")
end

function SWEP:Initialize()

    self:SetHoldType(self.defaultHoldType)

end

function SWEP:PrimaryAttack()
end

function puppetBase(ply, self, amount, duration)
    local cooldown = 0.1
    local range = 200
    local oscillationSpeed = 2
    local oscillationAmplitude = 10
    local hitCooldowns = {}
 

    if SERVER then

        if self.puppetbase_models and #self.puppetbase_models > 0 then
            for _, puppet in ipairs(self.puppetbase_models) do
                if IsValid(puppet) then
                    puppet:Remove()
                end
            end
        end
        self.puppetbase_models = {}

       
        for i = 1, amount do
            local puppet = ents.Create("prop_physics")
            if IsValid(puppet) then
                puppet:SetModel("models/marionnette_4_bane.mdl")
                puppet:SetColor(Color(255, 255, 255))
                puppet:SetModelScale(1)
                puppet:Spawn()

                puppet:SetSequence(puppet:LookupSequence("idle_all_01"))
                puppet:SetCycle(0)
                puppet:SetPlaybackRate(1)

                puppet:SetMoveType(MOVETYPE_NOCLIP)
                puppet:DrawShadow(false)
                puppet:SetNWInt("PuppetHealth", 100) 
                puppet:SetNWEntity("PuppetTarget", nil) 
                ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)

                local randomOffset = Vector(math.random(-70, 70), math.random(-40, 40), math.random(-20, 20))
                local offset = Vector(0, (i - 2) * 50, 100) + randomOffset
                puppet:SetPos(ply:GetPos() + ply:GetForward() * range + offset)
                puppet:SetAngles(ply:EyeAngles())

                table.insert(self.puppetbase_models, puppet)

                local playerAttachPos = ply:EyePos() - Vector(0, 0, 20)
                local puppetAttachPos = Vector(0, 0, 40)

                constraint.Rope(
                    puppet,
                    ply,
                    0,
                    0,
                    puppetAttachPos,
                    playerAttachPos - ply:GetPos(),
                    range,
                    100,
                    0,
                    5,
                    "cable/physbeam",
                    Color(255, 255, 255)
                )

                timer.Create("puppetbase_model_follow_" .. i, 0.01, 0, function()
                    if not IsValid(puppet) or not ply:Alive() then
                        if IsValid(puppet) then
                            puppet:Remove()
                        end
                        timer.Remove("puppetbase_model_follow_" .. i)
                        return
                    end

                    local time = CurTime()
                    local verticalOffset = math.sin(time * oscillationSpeed) * oscillationAmplitude
           
                    local circleRadius = 10
                    local circleSpeed = 1
                    
                    local circularOffsetX = math.cos(time * circleSpeed) * circleRadius
                    local circularOffsetY = math.sin(time * circleSpeed) * circleRadius
         
                    local forward = ply:GetForward()
                    local puppetOffset = forward * range + Vector(circularOffsetX, circularOffsetY, 100) + randomOffset
                    puppetOffset.z = puppetOffset.z + verticalOffset
                    local targetPos = ply:GetPos() + puppetOffset
                    
                    if not IsValid(puppet:GetNWEntity("PuppetTarget", nil)) then
                        puppet:SetPos(targetPos)
                        puppet:SetAngles(ply:EyeAngles())
                    else
                        local distanceToPlayer = ply:GetPos():Distance(puppet:GetNWEntity("PuppetTarget", nil):GetPos())

                        if distanceToPlayer >= 1500 then
                            puppet:SetNWEntity("PuppetTarget", nil)
                            puppet:SetSequence(puppet:LookupSequence("idle_all_01"))
                            puppet:SetCycle(0)
                            puppet:SetPlaybackRate(1)
                        end
                    end

                    for _, entity in pairs(ents.FindInSphere(puppet:GetPos(), 200)) do
                        if IsValid(entity) and entity:IsPlayer() and entity ~= ply then
                            local targetCloserPos = entity:GetPos() + entity:GetAngles():Forward() * 30
                            puppet:SetPos(targetCloserPos)

                            if not entity:Alive() then
                                puppet:SetPos(targetPos)
                                puppet:SetAngles(ply:EyeAngles())
                                puppet:SetNWEntity("PuppetTarget", nil)
                            end

                            if not hitCooldowns[entity] or hitCooldowns[entity] < CurTime() then
                                hitCooldowns[entity] = CurTime() + 2

                                if entity:Alive() then
                                    ply:EmitSound(Sound("physics/wood/wood_box_impact_bullet" .. math.random(1,3) .. ".wav"))
                                    ParticleEffect("nrp_hit_main", entity:GetPos(), Angle(0, 0, 0), nil)

                                    puppet:SetSequence(puppet:LookupSequence(self.attackAnimList[math.random(1, #self.attackAnimList)]))
                                    puppet:SetCycle(0)
                                    puppet:SetPlaybackRate(1)

                                    local damageInfo = DamageInfo()
                                    damageInfo:SetDamage(30)
                                    damageInfo:SetAttacker(ply)
                                    damageInfo:SetInflictor(self)
                                    entity:TakeDamageInfo(damageInfo)

                                    net.Start("DisplayDamage")
                                    net.WriteInt(30, 32)
                                    net.WriteEntity(entity)
                                    net.WriteColor(Color(249, 148, 6, 255))
                                    net.Send(ply)

                                    puppet:SetNWEntity("PuppetTarget", entity)
                                end
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

    if CLIENT then
        surface.CreateFont("LargeText", {
            font = "Arial",
            extended = false,
            size = 50,
        
            weight = 500,
        })
        hook.Add("PostDrawTranslucentRenderables", "DrawPuppetHP", function()
    
            for _, puppet in ipairs(ents.FindByClass("prop_physics")) do
                if IsValid(puppet) and puppet:GetModel() == "models/marionnette_4_bane.mdl" then
                    local hp = puppet:GetNWInt("PuppetHealth", 0)
                    local pos = puppet:GetPos() + Vector(0, 0, 80)
                    cam.Start3D2D(pos, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
                        draw.RoundedBox(4, -180, 0, 350, 50, Color(50, 50, 50, 200))
                        draw.RoundedBox(4, -180, 0, hp*3.5, 50, Color(200, 0, 0, 255))
                        draw.SimpleText(hp .. "/" .. "100", "LargeText", 0, 23, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    cam.End3D2D()
                end
            end
        end)
    end
end


function SWEP:SecondaryAttack()
    self.Weapon:SetNextSecondaryFire(CurTime() +5 )
    local ply = self.Owner


    self:SetHoldType("anim_ninjutsu2")
    ply:SetAnimation(PLAYER_ATTACK1)
    
    timer.Simple(0.6, function()
		puppetBase(ply, self, 1,20)
    end)
end

function SWEP:Reload()

    if not self.puppetbase_models or #self.puppetbase_models == 0 then return end

    for _, puppet in ipairs(self.puppetbase_models) do
        if IsValid(puppet) then
  
            puppet:SetNWEntity("PuppetTarget", nil)

        end
    end
end


