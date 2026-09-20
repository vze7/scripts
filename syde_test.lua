-- Made: By iceboy

local Players = game:GetService("Players")

-- Referência à biblioteca Syde: utiliza a instância local (se colado no final de syde.lua)
-- ou carrega dinamicamente caso seja executado separadamente.
local syde = syde or loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/syde.lua", true))()

-- Função auxiliar para obter o Humanoid do jogador local de forma segura
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
	Logo = "7488932274",
	Name = "Syde Test",
	Status = "Stable", -- Opções: Stable, Unstable, Detected, Patched
	Accent = Color3.fromRGB(251, 144, 255),
	HitBox = Color3.fromRGB(251, 144, 255),
	AutoLoad = false,
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
		FolderName = "SydeTest",
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
	Title = "Syde Test",
	SubText = "Elementos & Callbacks",
})

-- ============================================================
-- ABA 1: BÁSICO (CONTROLES E INFORMAÇÕES)
-- ============================================================
local Tab1 = Window:InitTab({ Title = "Básico" })

Tab1:Section("Informações")
Tab1:Label("Script de teste para validação completa da biblioteca Syde UI.", "Left")

local aboutParagraph = Tab1:Paragraph({
	Title = "Sobre o Syde",
	Content = "Biblioteca moderna com suporte a temas, animações suaves, gerenciamento de configurações e elementos interativos.",
})

Tab1:Section("Controles Principais")

-- Toggle Interativo
local myToggle = Tab1:Toggle({
	Title = "Ativar Feature",
	Description = "Liga ou desliga a funcionalidade de teste.",
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
			Title = "Botão Padrão",
			Content = "Ação executada com sucesso!",
			Duration = 2.5,
		})
	end,
})

-- Botão com tempo de segurar (Hold)
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

Tab2:Section("Valores Numéricos")

Tab2:Slider({
	Title = "Configurações do Personagem",
	Description = "Ajuste de velocidade e força de pulo em tempo real.",
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

Tab2:Section("Menus de Seleção")

-- Dropdown Simples
Tab2:Dropdown({
	Title = "Modo de Operação",
	Options = {"Padrão", "Furtivo", "Agressivo", "Defensivo"},
	StarterOption = "Padrão",
	PlaceHolder = "Selecione o modo...",
	Multi = false,
	CallBack = function(selected)
		syde:Notify({
			Title = "Modo Selecionado",
			Content = "Modo atual: " .. tostring(selected),
			Duration = 2,
		})
	end,
})

-- Dropdown Multi-Seleção
Tab2:Dropdown({
	Title = "Filtrar Alvos (Múltiplo)",
	Options = {"Jogadores", "NPCs", "Inimigos", "Itens Coletáveis"},
	PlaceHolder = "Escolha um ou mais alvos...",
	Multi = true,
	CallBack = function(selectedList)
		local listaFormatada = typeof(selectedList) == "table" and table.concat(selectedList, ", ") or tostring(selectedList)
		print("[Syde Multi-Dropdown] Alvos selecionados:", listaFormatada)
	end,
})

-- ============================================================
-- ABA 3: INPUTS & ATALHOS
-- ============================================================
local Tab3 = Window:InitTab({ Title = "Inputs & Atalhos" })

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
		print("[Syde NumberInput] Valor digitado:", num)
	end,
})

Tab3:Section("Atalho de Teclado")

Tab3:Keybind({
	Title = "Alternar Toggle",
	Description = "Pressione a tecla definida para inverter o Toggle.",
	Key = Enum.KeyCode.H,
	CallBack = function()
		if myToggle then
			local novoEstado = not myToggle.V
			myToggle:Set(novoEstado)
		end
	end,
})

Tab3:Section("Seletor de Cores")

Tab3:ColorPicker({
	Title = "Cor de Destaque",
	Color = Color3.fromRGB(251, 144, 255),
	Linkable = true,
	Flag = "TestColorPicker",
	CallBack = function(color)
		print("[Syde ColorPicker] Cor selecionada:", color)
	end,
})

-- ============================================================
-- ABA 4: DIÁLOGOS & CONFIGURAÇÃO
-- ============================================================
local Tab4 = Window:InitTab({ Title = "Alerts & Sistema" })

Tab4:Section("Diálogos e Notificações")

-- Modal de Confirmação (suporta ambas as grafias para compatibilidade com o syde)
Tab4:Button({
	Title = "Abrir Modal de Confirmação",
	Description = "Exibe um diálogo modal com botões de Confirmar e Cancelar.",
	Type = "Default",
	CallBack = function()
		syde:Modal({
			Title = "Confirmação de Teste",
			Content = "Deseja realmente confirmar esta ação de teste?",
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
	Description = "Exibe uma notificação com texto maior e duração de 5 segundos.",
	Type = "Default",
	CallBack = function()
		syde:Notify({
			Title = "Aviso do Sistema",
			Content = "Esta é uma notificação com tempo estendido para leitura completa de informações.",
			Duration = 5,
		})
	end,
})

Tab4:Button({
	Title = "Forçar Toggle via :Set()",
	Description = "Altera o estado do Toggle programaticamente.",
	Type = "Default",
	CallBack = function()
		if myToggle then
			myToggle:Set(true)
			syde:Notify({
				Title = "Método :Set()",
				Content = "Toggle foi forçado para ATIVADO!",
				Duration = 2,
			})
		end
	end,
})

Tab4:Section("Gerenciamento de Perfis")

Tab4:Button({
	Title = "Salvar Perfil ('default')",
	Description = "Grava o estado das flags salvas no disco.",
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
	Title = "Recarregar Perfil ('default')",
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
-- 3. CARREGAMENTO DE CONFIGURAÇÃO & NOTIFICAÇÃO DE SUCESSO
-- ============================================================
syde:LoadSaveConfig()

syde:Notify({
	Title = "Syde Test",
	Content = "Interface inicializada com sucesso!",
	Duration = 4,
})

print("[Syde Test] Interface e callbacks carregados com sucesso.")

return syde
