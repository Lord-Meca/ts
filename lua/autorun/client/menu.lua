local QM_RingHud_Items = {}
local QM_entity_names = {
    "empty_hands",
	"weapon_jashin_nrp",
	"weapon_kiba_nrp",
	"weapon_kubikiribocho_nrp",
	"weapon_kabutowari_nrp",
	"weapon_samehada_nrp",
	"weapon_shibuki_nrp",
	"salamander_invoke",
	"salamander_rush",
	"toad_stomp",
	"toad_spy",
	"slug_division"
}
local QM_hud_names = {
    "Mains",
	"Jashin",
	"Kiba",
	"Kubikiribocho",
	"Kabutowari",
	"Samehada",
	"Shibuki",
	"Salamandre\nQui tourne",
	"Ruée de la\nSalamandre",
	"Piétinement\ndu Crapeau",
	"Espionnage\ndu Crapeau",
	"Division des\nLimaces"
}
local QM_OpenKey = KEY_X

function QM_Hover_Handler(i, mustPaint)
    local pictures = {"QM_mid_left.png","QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png",
	 "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png","QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png"}
    
    local baseSize = 100
    local hoverSize = 150  
    QM_RingHud_Items[i].Paint = function()
        surface.SetMaterial(Material("materials/" .. pictures[i], "noclamp"))
        
       
        if mustPaint then
            surface.SetDrawColor(color_white) 
        else
            surface.SetDrawColor(color_black) 
        end

       
        local size = mustPaint and hoverSize or baseSize
        surface.DrawTexturedRectUV(0, 0, size, size, 0, 0, 1, 1)
    end
end

function RefreshRingHud()
    for i = 1,12 do
        QM_RingHud_Items[i]:SetText(QM_hud_names[i])
   
        QM_RingHud_Items[i].OnMousePressed = function()

			local ply = LocalPlayer()

            RunConsoleCommand("give", QM_entity_names[i])
            RunConsoleCommand("use", QM_entity_names[i])

			if IsValid(ply) then
				ply:ChatPrint(string.Replace(QM_hud_names[i], "\n", " ") .. " | équipé !")
			end
	

        end

        QM_RingHud_Items[i].OnCursorEntered = function()
   
            QM_Hover_Handler(i, true)
        end

        QM_RingHud_Items[i].OnCursorExited = function()
            QM_Hover_Handler(i, false)
        end

      
    end
end

function CreateRingHud()
	local startX, startY = ScrW() / 1.017 - 50, ScrH() / 2 - 550  
	local pictures = {"QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png", "QM_mid_left.png","QM_mid_left.png",
	"QM_mid_left.png", "QM_mid_left.png","QM_mid_left.png","QM_mid_left.png","QM_mid_left.png"}
	for i=1,12 do
		local QM_HudButton = vgui.Create("DButton")
		QM_HudButton:SetPos(startX, startY + (i-1) * 85)  
		QM_HudButton:SetSize(80,80)
		QM_HudButton:SetVisible(false)
		QM_HudButton:SetFont("CenterPrintText")
		QM_HudButton:SetTextColor(Color(255, 255, 255, 255))
		QM_HudButton.OnMousePressed = function()
			RunConsoleCommand("givecurrentammo")
		end
		QM_HudButton.Paint = function()
	
			surface.SetMaterial(Material("materials/"..pictures[i], "noclamp"))
			surface.SetDrawColor(color_black)
			surface.DrawTexturedRectUV(0, 0, 100, 100, 0, 0, 1, 1)
		end
		table.insert(QM_RingHud_Items, QM_HudButton)
	end
end

function ShowRingHud()
	for i=1,12 do
		if QM_RingHud_Items[i] then
			QM_RingHud_Items[i]:SetVisible(true)
		end
	end
end

function HideRingHud()
	for i=1,12 do
		if QM_RingHud_Items[i] then
			QM_RingHud_Items[i]:SetVisible(false)
		end
	end
end

function QM_KeyPress()
	gui.EnableScreenClicker(input.IsKeyDown(QM_OpenKey))
	if input.IsKeyDown(QM_OpenKey) then
		ShowRingHud()
	else
		HideRingHud()
	end
end

hook.Add("Think", "QM_KeyPress", QM_KeyPress)
CreateRingHud()
RefreshRingHud()
