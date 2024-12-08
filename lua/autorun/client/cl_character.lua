
local characterSelected = {}

local function OpenCharacterCreationMenu(ply)
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 600)
    frame:Center()
    frame:SetTitle("Nouveau personnage")
    frame:MakePopup()

    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetPos(50, 50)
    nameEntry:SetSize(300, 30)
    nameEntry:SetPlaceholderText("Nom")

    local submitButton = vgui.Create("DButton", frame)
    submitButton:SetPos(150, 500)
    submitButton:SetSize(100, 30)
    submitButton:SetText("Valider")
    submitButton.DoClick = function()
        local playerName = nameEntry:GetValue()

        if playerName == "" then
            return
        end

        characterSelected = {steamid = ply:SteamID(), name = playerName, skin = "models/falko_naruto_foc/body_upper/man_amefullbody_01_kusa.mdl", weaponsName = "empty_hands"}

        net.Start("SaveOrUpdateCharacterData")
        net.WriteString(playerName) 
        net.WriteString(ply:GetModel())
        net.WriteString("empty_hands")
        net.SendToServer()

        net.Start("SelectedCharacter")
        net.WriteTable(characterSelected)
        net.SendToServer()

        frame:Close()
    end
end

local function OpenCharacterSelectionMenu(characters, ply)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255)) 
        draw.SimpleText("Sélectionner un personnage", "DermaLarge", w / 2, (h/2)-200, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local buttonStartY = (ScrH()/2)-100
    local buttonSpacing = 80
    local maxButtons = 3

    if #characters == 0 then
        local createButton = vgui.Create("DButton", frame)
        createButton:SetPos(ScrW() / 2 - 150, buttonStartY)
        createButton:SetSize(300, 50)
        createButton:SetText("Créer personnage")
        createButton:SetFont("DermaLarge")
        createButton:SetTextColor(Color(255, 255, 255))

        createButton.Paint = function(self, w, h)
            local bgColor = Color(100, 200, 100)  
            if self:IsHovered() then
                bgColor = Color(120, 220, 120)  
            end
            draw.RoundedBox(10, 0, 0, w, h, bgColor) 
        end
        
        createButton.DoClick = function()
            frame:Close()
            OpenCharacterCreationMenu(ply) 
        end
    else
        for i = 1, math.min(#characters, maxButtons) do
            local character = characters[i]
            local characterButton = vgui.Create("DButton", frame)
            characterButton:SetPos(ScrW() / 2 - 150, buttonStartY + (i - 1) * buttonSpacing)
            characterButton:SetSize(300, 50)
            characterButton:SetText(character.name)
            characterButton:SetFont("DermaLarge")
            characterButton:SetTextColor(Color(255, 255, 255))
      
            characterButton.Paint = function(self, w, h)
                local bgColor = Color(100, 62, 62) 
                if self:IsHovered() then
                    bgColor = Color(34, 21, 21) 
                end
                draw.RoundedBox(10, 0, 0, w, h, bgColor) 
            end
            characterButton.DoClick = function()

                characterSelected = character

                net.Start("SelectedCharacter")
                net.WriteTable(character)
                net.SendToServer()
                frame:Close()
            end
        end
    end

    if #characters < maxButtons then
        local createButton = vgui.Create("DButton", frame)
        createButton:SetPos(ScrW() / 2 - 150, buttonStartY + #characters * buttonSpacing)
        createButton:SetSize(300, 50)
        createButton:SetText("+")
        createButton:SetFont("DermaLarge")
        createButton:SetTextColor(Color(255, 255, 255))

        createButton.Paint = function(self, w, h)
            local bgColor = Color(108, 125, 161)
            if self:IsHovered() then
                bgColor = Color(55, 63, 82) 
            end
            draw.RoundedBox(10, 0, 0, w, h, bgColor) 
        end

        createButton.DoClick = function()
            frame:Close()
            OpenCharacterCreationMenu(ply)
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
