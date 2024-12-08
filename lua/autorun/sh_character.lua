
CharacterSystem = CharacterSystem or {}

function CharacterSystem.GetPlayerCharacterName(ply)
    return ply:GetNWString("CharacterName", "Inconnu")
end
