
local characterSelected = {}

local function OpenCharacterCreationMenu(ply)
    surface.CreateFont("Large", {
        font = "Ninja Naruto",
        size = 30,
        weight = 500,
    })

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(21,21,21, 255)) 
    end

    local modelPanel = vgui.Create("DModelPanel", frame)
    modelPanel:SetPos(ScrW() / 4, ScrH() /14)
    modelPanel:SetSize(ScrW() / 2, ScrH())
    modelPanel:SetModel("models/falko_naruto_foc/body_upper/man_amefullbody_01_kusa.mdl")

    modelPanel:SetCamPos(Vector(50, 50, 50)) 
    modelPanel:SetLookAt(Vector(0, 0, 40))
    modelPanel:SetFOV(70)

    local backButton = vgui.Create("DButton", frame)
    backButton:SetPos(ScrW()/4 - 470, ScrH()/4 -240)
    backButton:SetSize(100,50)
    backButton:SetText("Retour")
    backButton:SetFont("DermaLarge")
    backButton:SetTextColor(Color(255, 255, 255))

    backButton.Paint = function(self, w, h)
        local bgColor = Color(51, 51, 51)
        if self:IsHovered() then
            bgColor = Color(32, 32, 32)
        end
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
    end

    backButton.DoClick = function()
        frame:Close()
    end
  
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetPos(ScrW() / 3.5 * 2.5, ScrH() / 4)
    rightPanel:SetSize(ScrW() / 4, ScrH()-350)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(26,26,26, 255))
    end

    local nameEntry = vgui.Create("DTextEntry", rightPanel)
    nameEntry:SetPos(20, 50)
    nameEntry:SetSize(rightPanel:GetWide() - 40, 40)
    nameEntry:SetPlaceholderText("Nom de personnage")
    nameEntry:SetFont("DermaLarge")
    nameEntry:SetTextColor(Color(0,0,0))

    local submitButton = vgui.Create("DButton", rightPanel)
    submitButton:SetPos(50, rightPanel:GetTall() - 80)
    submitButton:SetSize(rightPanel:GetWide() - 100, 40)
    submitButton:SetText("Valider")
    submitButton:SetFont("DermaLarge")
    submitButton:SetTextColor(Color(255, 255, 255))

    submitButton.Paint = function(self, w, h)
        local bgColor = Color(51, 51, 51)
        if self:IsHovered() then
            bgColor = Color(32, 32, 32)
        end
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
    end

    submitButton.DoClick = function()
        local playerName = nameEntry:GetValue()

        if playerName == "" then
            return
        end

        characterSelected = {
            steamid = ply:SteamID(),
            name = playerName,
            skin = "models/falko_naruto_foc/body_upper/man_amefullbody_01_kusa.mdl",
            weaponsName = "empty_hands"
        }

        net.Start("SaveOrUpdateCharacterData")
        net.WriteString(playerName)
        net.WriteString(characterSelected.skin)
        net.WriteString("empty_hands")
        net.SendToServer()

        net.Start("SelectedCharacter")
        net.WriteTable(characterSelected)
        net.SendToServer()

        ply:EmitSound("buttons/lightswitch2.wav")

        frame:Close()
    end
end


local function OpenCharacterSelectionMenu(characters, ply)

    surface.CreateFont("Large", {
        font = "Ninja Naruto",
        size = 100,
        weight = 500,
    })

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(21, 21, 21, 255))
    end

    local buttonStartY = (ScrH() / 2) - 200 
    local buttonSpacing = 400
    local maxButtons = 3
    local buttonStartX = (ScrW() / 2) - (maxButtons * buttonSpacing / 2 -50) 

    for i = 1, maxButtons do
        local character = characters[i]

        if character then
        
            local characterButton = vgui.Create("DButton", frame)
            characterButton:SetPos(buttonStartX + (i - 1) * buttonSpacing, buttonStartY)
            characterButton:SetSize(300, 400)
            characterButton:SetText("")
            characterButton.Paint = function(self, w, h)
                local bgColor = Color(26, 26, 26)
                if self:IsHovered() then
                    bgColor = Color(10, 10, 10)
                end
                draw.RoundedBox(10, 0, 0, w, h, bgColor)
                draw.SimpleText(
                    character.name,
                    "DermaLarge",
                    w / 2,
                    h - 40,
                    Color(255, 255, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end

            characterButton.DoClick = function()
                characterSelected = character

                net.Start("SelectedCharacter")
                net.WriteTable(character)
                net.SendToServer()

                ply:EmitSound("buttons/button14.wav")

                frame:Close()
            end

            local modelPanel = vgui.Create("DModelPanel", characterButton)
            modelPanel:SetPos(10, 10)
            modelPanel:SetSize(280, 280)
            modelPanel:SetModel(string.Replace(character.skin, "'", ""))

            modelPanel:SetCamPos(Vector(50, 50, 50)) 
            modelPanel:SetLookAt(Vector(0, 0, 40))
            modelPanel:SetFOV(70)

        else
          
            local createButton = vgui.Create("DButton", frame)
            createButton:SetPos(buttonStartX + (i - 1) * buttonSpacing, buttonStartY)
            createButton:SetSize(300, 400)
            createButton:SetText("+")
            createButton:SetFont("DermaLarge")
            createButton:SetTextColor(Color(255, 255, 255))

            createButton.Paint = function(self, w, h)
                local bgColor = Color(51, 51, 51)
                if self:IsHovered() then
                    bgColor = Color(32, 32, 32)
                end
                draw.RoundedBox(10, 0, 0, w, h, bgColor)
            end

            createButton.DoClick = function()
                frame:Close()
                OpenCharacterCreationMenu(ply)
                ply:EmitSound("buttons/lightswitch2.wav")
            end
        end
    end
end



local function CheckAndOpenMenu()
    net.Start("CheckCharacter")
    net.SendToServer()
end

net.Receive("CheckCharacterResponse", function()
    local characters = net.ReadTable()
    local plyCharacters = {}

    characterSelected = characters

    for _, character in ipairs(characters) do
        if character.steamid == LocalPlayer():SteamID() then
            table.insert(plyCharacters, character)
        end
    end

    OpenCharacterSelectionMenu(plyCharacters, LocalPlayer())
end)

hook.Add("InitPostEntity", "CheckCharacterOnSpawn", CheckAndOpenMenu)

concommand.Add("ts_characters", function(ply)

    CheckAndOpenMenu()
end)

concommand.Add("ts_characters_save", function(ply)

    local weaponsName = ply:GetWeapons()
    local filteredWeapons = {}
    for _, weapon in ipairs(weaponsName) do
        local weaponClass = weapon:GetClass()
        if weapon.Category == "TypeShit | Armes" or weapon.Category == "TypeShit | Invocations" then
            table.insert(filteredWeapons, weaponClass)
        end
    end
    local weaponsString = table.concat(filteredWeapons, ",")

    net.Start("SaveOrUpdateCharacterData")
    net.WriteString(characterSelected.name) 
    net.WriteString(ply:GetModel())
    net.WriteString(weaponsString)
    net.SendToServer()

    characterSelected = {steamid = characterSelected.steamid, name = characterSelected.name, skin = ply:GetModel(), weaponsName = filteredWeapons}

    PrintTable(characterSelected)
end)
