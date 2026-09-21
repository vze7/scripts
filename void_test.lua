
void:Load({
	Title   = "Void Test",
	SubText = "By iceboy",
	ConfigurationSaving = {
		Enabled    = false,
		FolderName = "VoidTest",
		FileName   = "TestConfig",
	},
	Discord = { Enabled = false },
	AutoJoinDiscord = { Enabled = false },
})

-- ============================================================
--  INIT  (monta a janela, devuelve ldata)
-- ============================================================
local Window = void:Init({
	Title   = "Void Test",
	SubText = "Elementos & Callbacks",
})

-- ============================================================
--  ABA 1 – BÁSICO
-- ============================================================
local Tab1 = Window:InitTab("Básico")

Tab1:Section("Informações")

Tab1:Label("Script de teste da Void UI.", "Left")

Tab1:Paragraph({
	Title   = "Sobre",
	Content = "Exercita todos os elementos: toggle, button, slider, dropdown, textinput, keybind, notificações e modal.",
})

Tab1:Section("Controles")

-- Toggle
local myToggle = Tab1:Toggle({
	Title       = "Ativar feature",
	Description = "Liga / desliga a feature de teste.",
	Value       = false,
	Flag        = "TestToggle",
	CallBack    = function(v)
		void:Notify({
			Title    = "Toggle",
			Content  = "Feature: " .. (v and "ON" or "OFF"),
			Duration = 2,
		})
	end,
})

-- Botão padrão
Tab1:Button({
	Title       = "Clique aqui",
	Description = "Dispara uma notificação.",
	Type        = "Default",
	CallBack    = function()
		void:Notify({
			Title    = "Botão",
			Content  = "CallBack executado com sucesso!",
			Duration = 3,
		})
	end,
})

-- Botão Hold
Tab1:Button({
	Title       = "Segurar (3 s)",
	Description = "Segure para acionar.",
	Type        = "Hold",
	HoldTime    = 3,
	CallBack    = function()
		void:Notify({
			Title    = "Hold completo!",
			Content  = "Você segurou por 3 segundos.",
			Duration = 3,
		})
	end,
})

-- ============================================================
--  ABA 2 – SLIDERS & DROPDOWN
-- ============================================================
local Tab2 = Window:InitTab("Sliders")

Tab2:Section("Valores numéricos")

Tab2:CreateSlider({
	Title = "Configurações",
	Sliders = {
		{
			Title        = "Velocidade",
			Range        = {1, 100},
			Increment    = 1,
			StarterValue = 50,
			Flag         = "SpeedSlider",
			CallBack     = function(v)
				print("[Slider] Velocidade:", v)
			end,
		},
		{
			Title        = "Alcance",
			Range        = {0, 500},
			Increment    = 10,
			StarterValue = 100,
			Flag         = "RangeSlider",
			CallBack     = function(v)
				print("[Slider] Alcance:", v)
			end,
		},
	},
})

Tab2:Section("Seleção")

Tab2:Dropdown({
	Title         = "Modo de jogo",
	PlaceHolder   = "Selecione...",
	Options       = {"Padrão", "Agressivo", "Furtivo", "Suporte"},
	StarterOption = "Padrão",
	Flag          = "GameModeDD",
	CallBack      = function(v)
		void:Notify({
			Title    = "Modo selecionado",
			Content  = tostring(v),
			Duration = 2,
		})
	end,
})

Tab2:Dropdown({
	Title       = "Alvos (multi)",
	PlaceHolder = "Escolha alvos...",
	Options     = {"Jogadores", "NPCs", "Objetos", "Veículos"},
	Multi       = true,
	Flag        = "TargetsDD",
	CallBack    = function(v)
		print("[Multi-DD]", table.concat(type(v) == "table" and v or {v}, ", "))
	end,
})

-- ============================================================
--  ABA 3 – INPUTS & KEYBIND
-- ============================================================
local Tab3 = Window:InitTab("Inputs")

Tab3:Section("Texto")

Tab3:TextInput({
	Title       = "Nome do jogador",
	PlaceHolder = "Digite um nome...",
	Flag        = "PlayerName",
	ClearOnLost = true,
	CallBack    = function(v)
		void:Notify({
			Title    = "Input recebido",
			Content  = "Valor: " .. tostring(v),
			Duration = 3,
		})
	end,
})

Tab3:TextInput({
	Title       = "Valor numérico",
	PlaceHolder = "Somente números...",
	NumberOnly  = true,
	Flag        = "NumInput",
	ClearOnLost = false,
	CallBack    = function(v)
		print("[TextInput numérico]", v)
	end,
})

Tab3:Section("Tecla de atalho")

Tab3:Keybind({
	Title       = "Toggle via teclado",
	Description = "Pressione H para alternar o toggle de teste.",
	Key         = Enum.KeyCode.H,
	Flag        = "TestKeybind",
	CallBack    = function()
		if myToggle then
			local novo = not myToggle.Value
			myToggle:Set(novo)
		end
	end,
})

-- ============================================================
--  ABA 4 – MODALS & NOTIFICAÇÕES
-- ============================================================
local Tab4 = Window:InitTab("Alerts")

Tab4:Section("Notificações")

Tab4:Button({
	Title    = "Notificação curta",
	CallBack = function()
		void:Notify({
			Title    = "Sucesso!",
			Content  = "Operação realizada.",
			Duration = 2,
		})
	end,
})

Tab4:Button({
	Title    = "Notificação longa",
	CallBack = function()
		void:Notify({
			Title    = "Aviso",
			Content  = "Este é um aviso com duração estendida. Leia antes de fechar.",
			Duration = 6,
		})
	end,
})

Tab4:Section("Modal de confirmação")

Tab4:Button({
	Title    = "Abrir Modal",
	CallBack = function()
		void:Modal({
			Title           = "Confirmação de Teste",
			Content         = "Deseja executar a ação de teste?",
			ConfirmCallBack = function()
				void:Notify({
					Title    = "Confirmado",
					Content  = "Modal confirmado com sucesso.",
					Duration = 3,
				})
			end,
		})
	end,
})

Tab4:Section("Programático")

Tab4:Button({
	Title    = "Forçar Toggle ON via :Set()",
	CallBack = function()
		if myToggle then
			myToggle:Set(true)
			void:Notify({
				Title    = "Set() chamado",
				Content  = "myToggle foi forçado para true.",
				Duration = 2,
			})
		end
	end,
})

-- ============================================================
--  NOTIFICAÇÃO INICIAL
-- ============================================================
void:Notify({
	Title    = "Void Test carregado",
	Content  = "Todos os elementos foram inicializados.",
	Duration = 4,
})

print("[VoidTest] Script de teste executado com sucesso.")

-- Made: By iceboy
