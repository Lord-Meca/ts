
util.AddNetworkString("CheckCharacter")
util.AddNetworkString("CheckCharacterResponse")
util.AddNetworkString("SaveOrUpdateCharacterData")
util.AddNetworkString("SelectedCharacter")
util.AddNetworkString("SelectedCharacterResponse")
util.AddNetworkString("EquipWeapons")

function CharacterSystem:GetCharacters()

    local result = sql.Query("SELECT * FROM characters")

    if not result then
        return {}
    end
    
    return result
end


function CharacterSystem:SetPlayerCharacter(ply, name)
    ply:SetNWString("CharacterName", name)
end

function CharacterSystem:UpdateCharacterData(ply, name, skin,weaponsName)

    if not name or name == "" or #name > 50 then
        return
    end


    local updateFields = {}

    if skin then
        table.insert(updateFields, "skin = " .. sql.SQLStr(skin))
    end

    if weaponsName then
        table.insert(updateFields, "weaponsName = " .. sql.SQLStr(weaponsName))
    end

    if #updateFields > 0 then
           
        local updateQuery = "UPDATE characters SET " .. table.concat(updateFields, ", ") ..
                        " WHERE steamid = '" .. ply:SteamID() .. "' AND name = " .. name
    
        sql.Query(updateQuery)
           

    end
end






net.Receive("SelectedCharacter", function(len, ply)
    local character = net.ReadTable()

    net.Start("SelectedCharacterResponse")
    net.WriteTable(character)  
    net.Send(ply)
    CharacterSystem:SetPlayerCharacter(ply, character.name)
    --PrintTable(character)

    ply:SetModel(string.Replace(character.skin, "'", ""))


    local weaponsString = character.weaponsName
    local weaponsTable = {}

    for weapon in string.gmatch(weaponsString, "([^,]+)") do
        table.insert(weaponsTable, weapon)
    end

    for _, weaponClass in ipairs(weaponsTable) do
        ply:Give(string.Replace(weaponClass, "'", ""))
    end
    
    net.Start("EquipWeapons")
    net.WriteString(weaponsString)
    net.Send(ply)

end)


net.Receive("CheckCharacter", function(_, ply)
    local characters = CharacterSystem:GetCharacters()
    net.Start("CheckCharacterResponse")
    net.WriteTable(characters)  
    net.Send(ply)
end)

local function CreateCharactersTableIfNotExists()
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS characters (
            steamid TEXT NOT NULL,
            name TEXT NOT NULL,
            skin TEXT NOT NULL,
            weaponsName TEXT NOT NULL,
            PRIMARY KEY(steamid, name)
        );
    ]]
    local result = sql.Query(createTableQuery)

    
end

CreateCharactersTableIfNotExists()
net.Receive("SaveOrUpdateCharacterData", function(_, ply)
    local name = net.ReadString()
    local skinName = net.ReadString()
    local filteredWeapons = net.ReadString()

    if not name or name == "" or #name > 50 then
        return
    end

    name = sql.SQLStr(name)
    skinName = sql.SQLStr(skinName)
    filteredWeapons = sql.SQLStr(filteredWeapons)

    local query = "SELECT * FROM characters WHERE steamid = '" .. ply:SteamID() .. "' AND name = " .. name
    local result = sql.Query(query)

    if result and #result > 0 then

        CharacterSystem:UpdateCharacterData(ply, name, skinName, filteredWeapons)
    else

        local insertQuery = "INSERT INTO characters (steamid, name, skin, weaponsName) VALUES ('" .. ply:SteamID() .. "', " .. name .. ", " .. skinName .. ", " .. filteredWeapons .. ")"
        local insertResult = sql.Query(insertQuery)

       
    end
end)

