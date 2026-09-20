-- Made: By iceboy

local Players = game:GetService("Players")

-- Referência à biblioteca: utiliza a instância local ou carrega dinamicamente via GitHub
local syde = syde or loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/syde.lua", true))()

-- Função auxiliar para obter o Humanoid do jogador local
local function getHumanoid(): Humanoid?
	local lp = Players.LocalPlayer
	local char = lp and lp.Character
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

-- ============================================================
-- 1. CARREGAMENTO INICIAL (LOADER & CONFIGURAÇÃO)
-- ============================================================
syde:Load({
	Logo = "", -- Imagem de gato removida
	Name = "Test Hub",
	Status = "Stable", -- Opções: Stable, Unstable, Detected, Patched
	Accent = Color3.fromRGB(251, 144, 255),
	HitBox = Color3.fromRGB(251, 144, 255),
	AutoLoad = true, -- Auto-carrega tema e configurações salvas
	Socials = {
		{
			Name = "Discord",
			Style = "Discord",
			Size = "Large",
			CopyToClip = true,
		},
		{
			Name = "GitHub",
			Style = "GitHub",
			Size = "Small",
			CopyToClip = true,
		},
	},
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "TestHub",
		FileName = "config",
	},
	AutoJoinDiscord = {
		Enabled = false,
		Invite = "CZRZBwPz",
		RememberJoins = false,
	},
})

-- ============================================================
-- 2. INICIALIZAÇÃO DA JANELA PRINCIPAL
-- ============================================================
local Window = syde:Init({
	Title = "Test Hub",
	SubText = "Elementos & Auto-Save",
})

-- ============================================================
-- ABA 1: BÁSICO (CONTROLES E INFORMAÇÕES)
-- ============================================================
local Tab1 = Window:InitTab({ Title = "Básico" })

Tab1:Section("Informações")
Tab1:Label("Script de teste com suporte a salvamento automático de tema e binds.", "Left")

Tab1:Paragraph({
	Title = "Sistema de Auto-Save",
	Content = "Qualquer alteração em temas (Accent/Hitbox), binds de teclado, toggles, sliders e dropdowns é gravada e restaurada automaticamente.",
})

Tab1:Section("Controles Principais")

-- Toggle Interativo com Auto-Save
local myToggle = Tab1:Toggle({
	Title = "Ativar Feature",
	Description = "Liga ou desliga a funcionalidade (salva automaticamente).",
	Value = false,
	Flag = "FeatureToggle",
	CallBack = function(state)
		syde:Notify({
			Title = "Toggle",
			Content = "Estado alterado para: " .. (state and "ATIVADO" or "DESATIVADO"),
			Duration = 2,
		})
	end,
})

-- Botão Padrão (Default)
Tab1:Button({
	Title = "Botão Padrão",
	Description = "Executa um callback e envia notificação.",
	Type = "Default",
	CallBack = function()
		syde:Notify({
			Title = "Botão",
			Content = "Ação executada com sucesso!",
			Duration = 2.5,
		})
	end,
})

-- Botão Hold
Tab1:Button({
	Title = "Segurar (3 segundos)",
	Description = "Segure o botão pressionado para confirmar a ação.",
	Type = "Hold",
	HoldTime = 3,
	CallBack = function()
		syde:Notify({
			Title = "Ação Concluída",
			Content = "Botão Hold segurado por 3 segundos!",
			Duration = 3,
		})
	end,
})

-- ============================================================
-- ABA 2: SLIDERS & SELEÇÃO
-- ============================================================
local Tab2 = Window:InitTab({ Title = "Sliders & Seleção" })

Tab2:Section("Valores Numéricos (Auto-Save)")

Tab2:Slider({
	Title = "Configurações do Personagem",
	Description = "Ajuste de velocidade e força de pulo (salvo automaticamente).",
	Sliders = {
		{
			Title = "Velocidade (WalkSpeed)",
			Range = {16, 250},
			Increment = 1,
			StarterValue = 16,
			Flag = "WalkSpeedSlider",
			CallBack = function(val)
				local hum = getHumanoid()
				if hum then
					hum.WalkSpeed = val
				end
			end,
		},
		{
			Title = "Pulo (JumpPower)",
			Range = {50, 300},
			Increment = 5,
			StarterValue = 50,
			Flag = "JumpPowerSlider",
			CallBack = function(val)
				local hum = getHumanoid()
				if hum then
					hum.JumpPower = val
				end
			end,
		},
	},
})

Tab2:Section("Menus de Seleção (Auto-Save)")

-- Dropdown Simples com Flag
Tab2:Dropdown({
	Title = "Modo de Operação",
	Options = {"Padrão", "Furtivo", "Agressivo", "Defensivo"},
	StarterOption = "Padrão",
	PlaceHolder = "Selecione o modo...",
	Multi = false,
	Flag = "GameModeDropdown",
	CallBack = function(selected)
		syde:Notify({
			Title = "Modo Selecionado",
			Content = "Modo atual: " .. tostring(selected),
			Duration = 2,
		})
	end,
})

-- Dropdown Multi-Seleção com Flag
Tab2:Dropdown({
	Title = "Filtrar Alvos (Múltiplo)",
	Options = {"Jogadores", "NPCs", "Inimigos", "Itens Coletáveis"},
	PlaceHolder = "Escolha um ou mais alvos...",
	Multi = true,
	Flag = "TargetsDropdown",
	CallBack = function(selectedList)
		local listaFormatada = typeof(selectedList) == "table" and table.concat(selectedList, ", ") or tostring(selectedList)
		print("[Multi-Dropdown] Alvos selecionados:", listaFormatada)
	end,
})

-- ============================================================
-- ABA 3: INPUTS, BINDS & TEMA
-- ============================================================
local Tab3 = Window:InitTab({ Title = "Binds & Tema" })

Tab3:Section("Atalho de Teclado (Auto-Save)")

-- Keybind com Flag (salva tecla e estado automaticamente)
Tab3:Keybind({
	Title = "Alternar Toggle",
	Description = "Pressione a tecla para alternar. Nova tecla salva automaticamente.",
	Key = Enum.KeyCode.H,
	Flag = "ToggleKeybind",
	CallBack = function()
		if myToggle then
			local novoEstado = not myToggle.V
			myToggle:Set(novoEstado)
		end
	end,
})

Tab3:Section("Cores do Tema (Auto-Save)")

Tab3:ColorPicker({
	Title = "Cor de Destaque (Accent)",
	Color = syde.theme.Accent,
	Linkable = true,
	Flag = "AccentThemePicker",
	CallBack = function(color)
		syde:UpdateTheme({ Accent = color })
		syde:Notify({
			Title = "Tema",
			Content = "Cor de destaque salva automaticamente!",
			Duration = 2,
		})
	end,
})

Tab3:ColorPicker({
	Title = "Cor dos Elementos (HitBox)",
	Color = syde.theme.HitBox,
	Linkable = true,
	Flag = "HitBoxThemePicker",
	CallBack = function(color)
		syde:UpdateTheme({ HitBox = color })
		syde:Notify({
			Title = "Tema",
			Content = "Cor de hitbox salva automaticamente!",
			Duration = 2,
		})
	end,
})

Tab3:Section("Campos de Texto")

Tab3:TextInput({
	Title = "Texto Livre",
	PlaceHolder = "Digite uma mensagem...",
	ClearOnLost = true,
	CallBack = function(text)
		syde:Notify({
			Title = "Input Recebido",
			Content = "Texto: " .. tostring(text),
			Duration = 2.5,
		})
	end,
})

Tab3:TextInput({
	Title = "Somente Números",
	PlaceHolder = "Insira apenas dígitos...",
	NumberOnly = true,
	ClearOnLost = false,
	CallBack = function(num)
		print("[NumberInput] Valor digitado:", num)
	end,
})

-- ============================================================
-- ABA 4: DIÁLOGOS & SISTEMA
-- ============================================================
local Tab4 = Window:InitTab({ Title = "Alerts & Perfis" })

Tab4:Section("Diálogos e Confirmação")

Tab4:Button({
	Title = "Abrir Modal de Confirmação",
	Description = "Exibe um diálogo modal com botões de Confirmar e Cancelar.",
	Type = "Default",
	CallBack = function()
		syde:Modal({
			Title = "Confirmação de Teste",
			Content = "Deseja realmente confirmar esta ação?",
			ConfimCallBack = function()
				syde:Notify({
					Title = "Confirmado!",
					Content = "Ação confirmada através do Modal.",
					Duration = 3,
				})
			end,
			ConfirmCallBack = function()
				syde:Notify({
					Title = "Confirmado!",
					Content = "Ação confirmada através do Modal.",
					Duration = 3,
				})
			end,
		})
	end,
})

Tab4:Button({
	Title = "Disparar Notificação Longa",
	Description = "Exibe uma notificação com tempo estendido.",
	Type = "Default",
	CallBack = function()
		syde:Notify({
			Title = "Aviso do Sistema",
			Content = "Esta é uma notificação detalhada com tempo de exibição estendido para leitura.",
			Duration = 5,
		})
	end,
})

Tab4:Section("Gerenciamento de Perfis")

Tab4:Button({
	Title = "Salvar Perfil Manual ('default')",
	Description = "Força a gravação de todas as flags e tema no disco.",
	Type = "Default",
	CallBack = function()
		syde:SaveConfigAs("default")
		syde:Notify({
			Title = "Configuração Salva",
			Content = "Perfil 'default' armazenado com sucesso.",
			Duration = 2.5,
		})
	end,
})

Tab4:Button({
	Title = "Recarregar Perfil Manual ('default')",
	Description = "Carrega e restaura as flags salvas no perfil.",
	Type = "Default",
	CallBack = function()
		syde:LoadSaveConfig("default")
		syde:Notify({
			Title = "Configuração Carregada",
			Content = "Perfil 'default' restaurado com sucesso.",
			Duration = 2.5,
		})
	end,
})

-- ============================================================
-- ABA 5: RECURSOS E ELEMENTOS ORION
-- ============================================================
local Tab5 = Window:MakeTab({ Name = "Orion Elements", Title = "Elementos Orion" })

Tab5:AddSection("Componentes Especiais Orion")

local logElem = Tab5:AddLog("Log do Sistema: Ativo e Operando")
local labelElem = Tab5:AddLabel("Texto com Suporte a Cores e Tags", "Left")
local colorLabelElem = Tab5:ColorLabel("Status: Conectado com Sucesso", Color3.fromRGB(0, 255, 180), "Center")
local playerPara = Tab5:AddPlayerParagraph(Players.LocalPlayer.UserId)
local pbind = Tab5:AddPbind({ Name = "Posicao (X, Y, Z)", DefaultX = "100", DefaultY = "50", DefaultZ = "200" })

Tab5:AddSection("Controles Orion (Auto-Save & Aliases)")

Tab5:AddButton({
	Name = "Disparar MakeNotification",
	Callback = function()
		syde:MakeNotification({
			Name = "Orion Notification",
			Content = "Notificacao do subsistema Orion disparada com sucesso!",
			Time = 3,
		})
	end,
})

Tab5:AddButton({
	Name = "Alternar Visibilidade do Log (:toggle)",
	Callback = function()
		logElem:toggle()
	end,
})

Tab5:AddToggle({
	Name = "Orion Toggle",
	Default = true,
	Flag = "OrionToggleFlag",
	Callback = function(state)
		print("[Orion Toggle] Estado:", state)
	end,
})

Tab5:AddSlider({
	Name = "Orion Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Flag = "OrionSliderFlag",
	Callback = function(val)
		print("[Orion Slider] Valor:", val)
	end,
})

Tab5:AddDropdown({
	Name = "Orion Dropdown",
	Options = {"Opcao Alfa", "Opcao Beta", "Opcao Gama"},
	Default = "Opcao Alfa",
	Flag = "OrionDropdownFlag",
	Callback = function(val)
		print("[Orion Dropdown] Selecionado:", val)
	end,
})

Tab5:AddBind({
	Name = "Orion Keybind",
	Default = Enum.KeyCode.G,
	Flag = "OrionKeybindFlag",
	Callback = function()
		syde:MakeNotification({
			Name = "Keybind Disparada",
			Content = "Tecla G pressionada!",
			Time = 2,
		})
	end,
})

Tab5:AddTextbox({
	Name = "Orion Textbox",
	Default = "Texto Inicial",
	Callback = function(txt)
		print("[Orion Textbox]:", txt)
	end,
})

Tab5:AddSmartTheme()
Tab5:FreeMouseDrp()

-- ============================================================
-- 3. CARREGAMENTO INICIAL & NOTIFICAÇÃO
-- ============================================================
syde:LoadSaveConfig()

syde:Notify({
	Title = "Test Hub",
	Content = "Interface inicializada com sucesso!",
	Duration = 4,
})

print("[Test Hub] Interface e auto-save ativos.")

return syde
