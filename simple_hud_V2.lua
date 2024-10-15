-- Plugin metadata
local PLUGIN = PLUGIN

PLUGIN.name = "Simple HUD"
PLUGIN.description = "A simple HUD for Helix."
PLUGIN.author = "Juanzorro1997"
PLUGIN.schema = "Any"




ix.lang.AddTable("english", {
    optHealthColor = "Health Color",
    optArmorColor = "Shield Color",
    optStaminaColor = "Stamina Color",
    optBackgroundColor = "Background Color",
})

ix.lang.AddTable("spanish", {
    optHealthColor = "Color de la Vida",
    optArmorColor = "Color del Escudo",
    optStaminaColor = "Color de la Estamina",
    optBackgroundColor = "Color del Fondo",
})

-- Definición de opciones de color en el menú de Settings
ix.option.Add("healthColor", ix.type.color, Color(255, 75, 66), {
    category = "Simple HUD",
    description = "Color de la barra de vida."
})

ix.option.Add("armorColor", ix.type.color, Color(255, 132, 187), {
    category = "Simple HUD",
    description = "Color de la barra de armadura."
})

ix.option.Add("staminaColor", ix.type.color, Color(67, 223, 67), {
    category = "Simple HUD",
    description = "Color de la barra de estamina."
})

-- Nueva opción para el color de fondo
ix.option.Add("backgroundColor", ix.type.color, Color(0, 0, 0, 200), {
    category = "Simple HUD",
    description = "Color de fondo del HUD."
})

if CLIENT then
    -- Definición de variables para el tamaño de las barras
    local barW = 100  -- Ancho de las barras reducido a la mitad
    local barH = 20    -- Altura de las barras
    local headPanelWidth = 70  -- Ancho del panel de la cabeza
    local headPanelHeight = 90  -- Altura del panel de la cabeza

    -- Función para dibujar las barras del HUD
    local function DrawBar(x, y, w, h, color, percentage)
        -- Asegurarse de que el color tiene r, g, b, a
        local r, g, b, a = color.r, color.g, color.b, color.a or 255
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x, y, w * percentage, h)
        surface.SetDrawColor(0, 0, 0, 150)  -- Color negro para el borde
        surface.DrawOutlinedRect(x, y, w, h)  -- Dibuja el borde

        -- Dibuja el porcentaje sobre la barra
        draw.SimpleText(math.Round(percentage * 100) .. "%", "Trebuchet24", x + w / 2, y + h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Variable para el modelo
    local elegant_model = nil

    -- Hook para crear el DModelPanel
    hook.Add('InitPostEntity', 'player_give_head', function()
        if not IsValid(elegant_model) then
            elegant_model = vgui.Create("DModelPanel")
            elegant_model:SetModel(LocalPlayer():GetModel())
            elegant_model:SetSize(headPanelWidth, headPanelHeight)
            elegant_model:SetPos(15, ScrH() - 110)
            elegant_model:SetCamPos(Vector(0, 0, 65))
            elegant_model:SetLookAt(Vector(0, 0, 65))
            elegant_model:SetAnimated(true)

            function elegant_model:LayoutEntity(Entity) return end
        end
    end)

    -- Hook para actualizar el modelo
    hook.Add("Think", "UpdateElegantModel", function()
        if IsValid(elegant_model) and LocalPlayer():Alive() then
            elegant_model:SetModel(LocalPlayer():GetModel())

            -- Obtener la posición del hueso
            local boneIndex = elegant_model.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if boneIndex then
                elegant_model:SetSize(headPanelWidth, headPanelHeight)
                elegant_model:SetPos(15, ScrH() - 215)
                elegant_model:SetCamPos(Vector(15, -5, 65))
                elegant_model:SetLookAt(Vector(0, 0, 65))
                elegant_model:SetAnimated(true)
            end
        end
    end)

    -- Hook para dibujar el HUD
    hook.Add("HUDPaint", "Simple_HUD", function()
        if ix.option.Get("ocultarHUD", false) then return end

        local ply = LocalPlayer()
        if not ply:Alive() then return end

        -- Obtener los colores configurados
        local healthColor = ix.option.Get("healthColor", Color(255, 75, 66))
        local armorColor = ix.option.Get("armorColor", Color(255, 132, 187))
        local staminaColor = ix.option.Get("staminaColor", Color(67, 223, 67))
        local backgroundColor = ix.option.Get("backgroundColor", Color(0, 0, 0, 200))  -- Color de fondo

        local hp = ply:Health() / ply:GetMaxHealth()
        local armor = ply:Armor() / 100
        local stamina = ply:GetLocalVar("stm", 0) / 100
        local x, y = 15, ScrH() - barH * 4 - 20

        -- Dibujar el fondo configurado detrás del modelo de la cabeza
        local headBgX, headBgY = 15, y - 110  -- Ajustar posición del fondo
        surface.SetDrawColor(backgroundColor)  -- Color del fondo configurado
        surface.DrawRect(headBgX, headBgY, headPanelWidth, headPanelHeight)  -- Dibuja el fondo

        -- Dibujar el modelo de la cabeza como una foto de carnet
        if IsValid(elegant_model) then
            elegant_model:SetPos(headBgX, headBgY)
            elegant_model:PaintManual()
        end

        -- Posición para las barras a la derecha del fondo
        local barX = headBgX + headPanelWidth + 20  -- Ajustar posición de las barras
        local barY = headBgY + 10  -- Mover barras un poco más arriba

        -- Barra de Vida
        DrawBar(barX, barY, barW, barH, healthColor, hp)
        draw.SimpleText("HP", "Trebuchet24", barX + barW + 5, barY + barH / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Barra de Escudo
        DrawBar(barX, barY + barH + 5, barW, barH, armorColor, armor)
        draw.SimpleText("Armor", "Trebuchet24", barX + barW + 5, barY + barH * 1.5 + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Barra de Estamina
        DrawBar(barX, barY + 2 * (barH + 5), barW, barH, staminaColor, stamina)
        draw.SimpleText("Stamina", "Trebuchet24", barX + barW + 5, barY + 2 * (barH + 5) + barH / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    -- Comando para configurar los colores del HUD
    ix.command.Add("ConfigHUDColors", {
        description = "Configura los colores del HUD.",
        adminOnly = false,
        OnRun = function(self, client)
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Configurar Colores del HUD")
            frame:SetSize(300, 400)
            frame:Center()
            frame:MakePopup()

            -- Selector de color para la barra de vida
            local colorVida = vgui.Create("DColorMixer", frame)
            colorVida:Dock(TOP)
            colorVida:SetLabel("Color de Vida")
            colorVida:SetColor(ix.option.Get("healthColor", Color(255, 75, 66)))
            colorVida.ValueChanged = function(_, color)
                ix.option.Set("healthColor", color)
            end

            -- Selector de color para la barra de escudo
            local colorEscudo = vgui.Create("DColorMixer", frame)
            colorEscudo:Dock(TOP)
            colorEscudo:SetLabel("Color de Armadura")
            colorEscudo:SetColor(ix.option.Get("armorColor", Color(255, 132, 187)))
            colorEscudo.ValueChanged = function(_, color)
                ix.option.Set("armorColor", color)
            end

            -- Selector de color para la barra de estamina
            local colorEstamina = vgui.Create("DColorMixer", frame)
            colorEstamina:Dock(TOP)
            colorEstamina:SetLabel("Color de Estamina")
            colorEstamina:SetColor(ix.option.Get("staminaColor", Color(67, 223, 67)))
            colorEstamina.ValueChanged = function(_, color)
                ix.option.Set("staminaColor", color)
            end

            -- Selector de color para el fondo
            local colorFondo = vgui.Create("DColorMixer", frame)
            colorFondo:Dock(TOP)
            colorFondo:SetLabel("Color de Fondo")
            colorFondo:SetColor(ix.option.Get("backgroundColor", Color(0, 0, 0, 200)))
            colorFondo.ValueChanged = function(_, color)
                ix.option.Set("backgroundColor", color)
            end
        end
    })
end

-- Función para ocultar las barras originales del HUD
function PLUGIN:ShouldHideBars()
    return true
end
