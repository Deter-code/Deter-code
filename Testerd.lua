local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV4/main/Source.lua"))()

local Window = redzlib:MakeWindow({
  Title = "SXHM",
  SubTitle = "Boa sorte adminstrador",
  LoadText = "Carregando...",
  Flags = ""
})

local Notify = Library:MakeNotify({
  Title = "SXHM Notification",
  Text = "Sxhm Esta na versao beta, apeoveite!",
  Time = 5
})

--[[
  Notify:Wait() -- Wait for the notification to end
]]

local Notify = Library:MakeNotify({
  Title = "Criado por :",
  Text = "Nzx e Exly",
  Time = 5
})

--[[
  Notify:Wait() -- Wait for the notification to end
]]

Window:AddMinimizeButton({
    Button = {
        -- Propriedades do Botão
        Image = "rbxassetid://0"
    },
    UICorner = {
        true,
        -- Propriedades do Arredondamento
        CornerRadius = UDim.new(0.5, 0)
    },
    UIStroke = {false, {
        -- Propriedades do Contorno
    }}
})

-- creditos

local Tab = Window:MakeTab({Name = "Creditos", Icon = "Cloud"})

local Paragraph = Tab:AddParagraph({"ExlyConceptHub", "Um obrigado aos participantes"})

local Paragraph = Tab:AddParagraph({"Participantes - Bruxo777q", ""})

local Paragraph = Tab:AddParagraph({"Que se inicie a nova Era", ""})

local Paragraph = Tab:AddParagraph({"Nzx🩸", "Botou as funçoes op No hub"})

local ImageLabel = Tab:AddLabel({"Image", "This is a Image Label", "rbxassetid://0"})

local Tab = Window:MakeTab({Name = "Troll", Icon = "Skull"})

local selectedPlayer = nil
local teleporting = false

-- Adicionando o Dropdown
local Dropdown = Tab:AddDropdown({
    Name = "Players",
    Options = {},
    Default = {},
    MultSelect = false,
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
    end
})

-- Serviços necessários
local function updateDropdown()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    Dropdown:Refresh(playerNames)
end

-- Atualizar o dropdown quando um novo player entrar no jogo
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
updateDropdown()

-- Pega o couch
local function getCouch()
    return game:GetService("Workspace"):FindFirstChild("Couch")
end

local Toggle = Tab:AddToggle({
    Name = "CouchFling [Você precisa do sofá no inventário]",
    Default = false,
    Callback = function(Value)
        teleporting = Value
        if teleporting then
            spawn(function()
                local couch = getCouch()
                if couch then
                    while teleporting do
                        if selectedPlayer then
                            -- Teletransportar para o player selecionado
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
                            
                            -- Girar na velocidade 9999
                            couch.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                            couch.CFrame = couch.CFrame * CFrame.Angles(0, math.rad(9999), 0)
                        end
                        wait(0.1)
                    end
                end
            end)
        end
    end
})

local Toggle = Tab:AddToggle({
    Name = "Fling BodyVelocity/Com muito mais potência",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Ativando o fling
            local player = game.Players.LocalPlayer
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 9999, 0) -- Definindo a velocidade do fling
            bodyVelocity.Parent = player.Character.HumanoidRootPart

            -- Salvando a referência ao BodyVelocity para remoção posterior
            script:SetAttribute("FlingPart", bodyVelocity)
        else
            -- Desativando o fling
            local bodyVelocity = script:GetAttribute("FlingPart")
            if bodyVelocity then
                bodyVelocity:Destroy() -- Removendo o BodyVelocity para parar o fling
            end
        end
    end
})

local Button = Tab:AddButton({
  Name = "Boombox",
  Callback = function()
    local player = game.Players.LocalPlayer

-- Função que será executada após o renascimento
local function onCharacterAdded(character)
    -- Aguarda o personagem carregar completamente
    character:WaitForChild("HumanoidRootPart")

    -- Executa a sequência de comandos após renascer
    local args = {
        [1] = "CharacterSizeDown",
        [2] = 4
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clothe1s"):FireServer(unpack(args))
    wait(0.1)

    local args = {
        [1] = "SkateBoard"
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1NoMoto1rVehicle1s"):FireServer(unpack(args))
    wait(0.1)

    local args = {
        [1] = "CharacterSizeUp",
        [2] = 1
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Clothe1s"):FireServer(unpack(args))
end

-- Conecta a função ao evento CharacterAdded
player.CharacterAdded:Connect(onCharacterAdded)

-- Caso o jogador já tenha um personagem no momento do script ser executado
if player.Character then
    onCharacterAdded(player.Character)
end
wait(0.1)
-- Criar a Tool
local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

local tool = Instance.new("Tool")
tool.Name = "BoomBox"
tool.RequiresHandle = true
tool.Parent = backpack
tool.TextureId = "rbxassetid://135246786635323"

-- Criar a Handle invisível
local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 1, 1)
handle.Transparency = 1
handle.CanCollide = false
handle.Anchored = false
handle.Parent = tool

-- Função para enviar comandos
local function sendUpdateAvatar()
    local args = {
        [1] = "wear",
        [2] = 18756289999
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1Updat1eAvata1r"):FireServer(unpack(args))
end

local function sendPickingScooterMusicText(id)
    local args = {
        [1] = "PickingScooterMusicText",
        [2] = id
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1NoMoto1rVehicle1s"):FireServer(unpack(args))
end

local function sendPickingScooterMusicStop()
    local args = {
        [1] = "PickingScooterMusicStop"
    }
    game:GetService("ReplicatedStorage").RE:FindFirstChild("1NoMoto1rVehicle1s"):FireServer(unpack(args))
end

-- Variável para armazenar o menu do Boombox
local boomboxMenu

-- Menu do Boombox
local function createMenu()
    boomboxMenu = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    local frame = Instance.new("Frame", boomboxMenu)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Size = UDim2.new(0.3, 0, 0.3, 0)
    frame.Position = UDim2.new(0.35, 0, 0.35, 0)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local title = Instance.new("TextLabel", frame)
    title.Text = "Boombox Menu"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local textBox = Instance.new("TextBox", frame)
    textBox.Size = UDim2.new(0.8, 0, 0.1, 0)
    textBox.Position = UDim2.new(0.1, 0, 0.25, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textBox.BackgroundTransparency = 0.5
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.BorderSizePixel = 0
    textBox.Text = ""

    local submitButton = Instance.new("TextButton", frame)
    submitButton.Size = UDim2.new(0.8, 0, 0.1, 0)
    submitButton.Position = UDim2.new(0.1, 0, 0.4, 0)
    submitButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    submitButton.BackgroundTransparency = 0.5
    submitButton.Text = "Tocar Áudio"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.BorderSizePixel = 0

    local stopButton = Instance.new("TextButton", frame)
    stopButton.Size = UDim2.new(0.8, 0, 0.1, 0)
    stopButton.Position = UDim2.new(0.1, 0, 0.55, 0) -- Abaixo do botão Tocar Áudio
    stopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    stopButton.BackgroundTransparency = 0.5
    stopButton.Text = "Parar Áudio"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.BorderSizePixel = 0

    local closeButton = Instance.new("TextButton", frame)
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeButton.BackgroundTransparency = 0.5
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BorderSizePixel = 0

    closeButton.MouseButton1Click:Connect(function()
        boomboxMenu:Destroy() -- Destrói o menu ao clicar no botão "X"
        boomboxMenu = nil -- Limpa a referência
    end)

    submitButton.MouseButton1Click:Connect(function()
        local inputId = textBox.Text
        if tonumber(inputId) then
            sendPickingScooterMusicText(inputId)
        else
            print("Por favor, insira um número válido.")
        end
    end)

    stopButton.MouseButton1Click:Connect(function()
        sendPickingScooterMusicStop() -- Chama a função para parar o áudio
    end)
end

-- Função para alternar entre abrir e fechar o menu do Boombox
local function toggleMenu()
    if boomboxMenu then
        boomboxMenu:Destroy() -- Se o menu já existe, destrua-o
        boomboxMenu = nil -- Limpa a referência
    else
        createMenu() -- Se o menu não existe, crie-o
    end
end

-- Criar botão para abrir o menu do Boombox
local function createOpenButton()
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    local openButton = Instance.new("TextButton", screenGui)
    openButton.Size = UDim2.new(0, 50, 0, 50)  -- Tamanho quadrado
    openButton.Position = UDim2.new(0.01, 0, 0.01, 0)  -- Canto superior esquerdo
    openButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    openButton.BackgroundTransparency = 0.5
    openButton.BorderSizePixel = 0
    openButton.Text = ""
    openButton.AutoButtonColor = false
    openButton.AnchorPoint = Vector2.new(0, 0) -- Garante que o botão fique no canto

    -- Bordas arredondadas
    local corner = Instance.new("UICorner", openButton)
    corner.CornerRadius = UDim.new(0.25, 0) -- Borda arredondada

    local imageLabel = Instance.new("ImageLabel", openButton)
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Image = "rbxassetid://135246786635323"
    imageLabel.BackgroundTransparency = 1

    openButton.MouseButton1Click:Connect(function()
        toggleMenu() -- Alterna entre abrir e fechar o menu do Boombox
    end)

    return openButton
end

local openButton -- Variável para armazenar o botão

-- Conectar funções de equipar e desequipar
tool.Equipped:Connect(function()
    sendUpdateAvatar()
    openButton = createOpenButton() -- Cria o botão quando a ferramenta é equipada
end)

tool.Unequipped:Connect(function()
    sendUpdateAvatar()
    sendPickingScooterMusicStop() -- Para o áudio ao desequipar a ferramenta
    if openButton then
        openButton.Parent:Destroy() -- Remove o botão quando a ferramenta é desequipada
        openButton = nil
    end
    if boomboxMenu then
        boomboxMenu:Destroy() -- Remove o menu do Boombox quando a ferramenta é desequipada
        boomboxMenu = nil -- Limpa a referência
    end
end)
  end
})

local Tab = Window:MakeTab({Name = "GunAudio", Icon = "Settings"})

local Dropdown = Tab:AddDropdown({
  Name = "IDS",
  Options = {"7192461985", "3060494212", "7516826765"},
  Default = {"2"},
  MultSelect = false,
  Callback = function(Value)
    SelectedID = Value[1]  -- Captura o ID selecionado
  end
})

local Toggle = Tab:AddToggle({
  Name = "ActiveID",
  Default = false,
  Callback = function(Value)
    if Value then
      local soundId = SelectedID  -- Usa o ID selecionado
  local soundId = 7205082060

-- Função para pegar as ferramentas de "Assault"
local args1 = {
    [1] = "PickingTools",
    [2] = "Assault"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args1))

-- Configuração para reproduzir o som e os efeitos
local args2 = {
    [1] = workspace.Model.Street.Street,
    [2] = game:GetService("Players").LocalPlayer.Character.Assault.Handle,
    [3] = Vector3.new(0.20000000298023224, 0.30000001192092896, -2.5),
    [4] = Vector3.new(89.90302276611328, 0.02500009536743164, 8.947380065917969),
    [5] = game:GetService("Players").LocalPlayer.Character.Assault.GunScript_Local.MuzzleEffect,
    [6] = game:GetService("Players").LocalPlayer.Character.Assault.GunScript_Local.HitEffect,
    [7] = soundId, -- Substituído pelo ID de som solicitado
    [8] = soundId, -- Caso o script use outro ID de som, também substituímos aqui
    [9] = {
        [1] = false
    },
    [10] = {
        [1] = 25,
        [2] = Vector3.new(0.25, 0.25, 100),
        [3] = BrickColor.new(24),
        [4] = 0.25,
        [5] = Enum.Material.SmoothPlastic,
        [6] = 0.25
    },
    [11] = true,
    [12] = false
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Gu1n"):FireServer(unpack(args2))

-- Função para verificar o dono do servidor
local args3 = {
    [1] = "CheckForServerOwner"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Flyin1g"):FireServer(unpack(args3))

-- Função para garantir que o som e os efeitos atinjam todos os jogadores
local args4 = {
    [1] = "PCollisionPatch"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Flyin1g"):FireServer(unpack(args4))
      print("ID Ativo: " .. soundId)
    end
  end
})

-- Função para pegar as ferramentas de "Assault"
local args1 = {
    [1] = "PickingTools",
    [2] = "Assault"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args1))

-- Configuração para reproduzir o som e os efeitos
local args2 = {
    [1] = workspace.Model.Street.Street,
    [2] = game:GetService("Players").LocalPlayer.Character.Assault.Handle,
    [3] = Vector3.new(0.20000000298023224, 0.30000001192092896, -2.5),
    [4] = Vector3.new(89.90302276611328, 0.02500009536743164, 8.947380065917969),
    [5] = game:GetService("Players").LocalPlayer.Character.Assault.GunScript_Local.MuzzleEffect,
    [6] = game:GetService("Players").LocalPlayer.Character.Assault.GunScript_Local.HitEffect,
    [7] = soundId, -- Substituído pelo ID de som solicitado
    [8] = soundId, -- Caso o script use outro ID de som, também substituímos aqui
    [9] = {
        [1] = false
    },
    [10] = {
        [1] = 25,
        [2] = Vector3.new(0.25, 0.25, 100),
        [3] = BrickColor.new(24),
        [4] = 0.25,
        [5] = Enum.Material.SmoothPlastic,
        [6] = 0.25
    },
    [11] = true,
    [12] = false
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Gu1n"):FireServer(unpack(args2))

-- Função para verificar o dono do servidor
local args3 = {
    [1] = "CheckForServerOwner"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Flyin1g"):FireServer(unpack(args3))

-- Função para garantir que o som e os efeitos atinjam todos os jogadores
local args4 = {
    [1] = "PCollisionPatch"
}
game:GetService("ReplicatedStorage").RE:FindFirstChild("1Flyin1g"):FireServer(unpack(args4))
  end
})
