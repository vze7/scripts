# Orion X

Orion X é uma versão moderna e responsiva da Orion Library para interfaces Luau no Roblox. Inclui pesquisa inteligente, resize otimizado, temas adaptativos, animação de minimizar, blur, keystrokes para PC, preview mobile, horário local e temperatura aproximada.

## Links

- [Source da biblioteca](https://github.com/Lilwagz/scripts/blob/main/Orion%20X)
- [Source raw](https://raw.githubusercontent.com/Lilwagz/scripts/main/Orion%20X)
- [Teste completo](https://github.com/Lilwagz/scripts/blob/main/Orion%20X%20Test.lua)

## Carregamento

```lua
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Lilwagz/scripts/main/Orion%20X?cache="
    .. tostring(os.time())
))()
```

`loadstring`, `game:HttpGet` e as funções de arquivo usadas pelo sistema de configuração precisam existir no ambiente onde o script será executado.

## Exemplo mínimo

```lua
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Lilwagz/scripts/main/Orion%20X?cache="
    .. tostring(os.time())
))()

local Window = OrionLib:MakeWindow({
    Name = "Minha Interface",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
})

local Main = Window:MakeTab({
    Name = "Principal",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

Main:AddButton({
    Name = "Executar",
    Callback = function()
        print("Executado")
    end,
})

Window:AddConfigTab()
OrionLib:Init()
```

## Janela

```lua
local Window = OrionLib:MakeWindow({
    Name = "Orion X",
    ConfigFolder = "OrionX",
    SaveConfig = false,
    HidePremium = true,
    IntroEnabled = false,
    FreeMouse = false,
    KeyToOpenWindow = "RightShift",
    IntroText = "Orion X",
    ShowIcon = false,
    Icon = "rbxassetid://8834748103",
    IntroIcon = "rbxassetid://8834748103",
    CloseCallback = function()
        print("Interface escondida")
    end,
})
```

| Campo | Tipo | Padrão | Função |
|---|---|---|---|
| `Name` | string | `Orion Library` | Título da janela |
| `ConfigFolder` | string | valor de `Name` | Pasta das configurações |
| `SaveConfig` | boolean | `false` | Salva valores marcados com `Save` |
| `HidePremium` | boolean | `false` | Esconde texto premium antigo |
| `IntroEnabled` | boolean | `true` | Mostra animação inicial |
| `FreeMouse` | boolean | `false` | Libera cursor |
| `KeyToOpenWindow` | string | `RightShift` | Tecla para esconder/reabrir |
| `IntroText` | string | `Orion Library` | Texto da introdução |
| `ShowIcon` | boolean | `false` | Mostra ícone no topo |
| `Icon` | string | padrão Orion | Ícone da janela |
| `IntroIcon` | string | padrão Orion | Ícone da introdução |
| `CloseCallback` | function | vazia | Executada ao esconder |

O tamanho alterado pelo resize é preservado ao minimizar e restaurar. No modo minimizado, o título é compactado para evitar colisão com horário, temperatura e botões.

## Horário e temperatura

O cabeçalho mostra `HH:MM / 25°C`.

- Localização aproximada por IP usando IPInfo.
- IPWho funciona como fallback.
- Temperatura e fuso vêm da Open-Meteo.
- Atualização do relógio a cada segundo.
- Atualização climática a cada dez minutos.
- Falha de rede mantém a interface funcional e mostra somente o horário disponível.
- Localização por IP pode apontar para cidade próxima, VPN ou região da operadora.

## Tabs

```lua
local Tab = Window:MakeTab({
    Name = "Jogador",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})
```

O primeiro tab criado é aberto automaticamente.

## Seções

```lua
local Section = Tab:AddSection({
    Name = "Movimento",
})
```

Tabs e seções aceitam os mesmos componentes.

## Label

```lua
local Label = Tab:AddLabel("Estado: pronto")
Label:Set("Estado: executando")
Label:SetVisible(true)
Label:Destroy()
```

## Parágrafo

```lua
local Paragraph = Tab:AddParagraph("Informação", "Conteúdo detalhado")
Paragraph:Set("Novo conteúdo")
Paragraph:SetVisible(true)
Paragraph:Destroy()
```

## Parágrafo de jogador

```lua
local PlayerCard = Tab:AddPlayerParagraph(1)
PlayerCard:Set(game.Players.LocalPlayer.UserId)
```

## Botão

```lua
local Button = Tab:AddButton({
    Name = "Confirmar",
    Icon = "rbxassetid://3944703587",
    Callback = function()
        print("Confirmado")
    end,
})

Button:Set("Novo nome")
Button:SetVisible(true)
Button:Destroy()
```

## Toggle

```lua
local Toggle = Tab:AddToggle({
    Name = "Ativado",
    Default = false,
    Flag = "enabled",
    Save = true,
    Callback = function(value)
        print(value)
    end,
})

Toggle:Set(true)
```

O valor atual fica em `Toggle.Value`. Toggles seguem automaticamente o tema ativo.

## Slider

```lua
local Slider = Tab:AddSlider({
    Name = "Velocidade",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    ValueName = "%",
    Flag = "speed",
    Save = true,
    Callback = function(value)
        print(value)
    end,
})

Slider:Set(75)
```

## Dropdown

```lua
local Dropdown = Tab:AddDropdown({
    Name = "Modo",
    Options = {"Normal", "Rápido", "Seguro"},
    Default = "Normal",
    SearchBar = true,
    MaxElements = 5,
    MultipleSelection = false,
    Flag = "mode",
    Save = true,
    Callback = function(value)
        print(value)
    end,
})

Dropdown:Set("Rápido")
Dropdown:Refresh({"A", "B", "C"}, true)
```

Para múltipla seleção, use `MultipleSelection = true` e uma tabela em `Default`. O callback recebe uma tabela com os nomes selecionados.

## Dropdown de jogadores

```lua
local PlayersDropdown = Tab:AddPlayersDropdown({
    Name = "Jogadores",
    Options = {},
    Default = "",
    MultipleSelection = false,
    Flag = "players",
    Save = false,
    Callback = function(value)
        print(value)
    end,
})

PlayersDropdown:Refresh()
PlayersDropdown:Set("Nome", false)
PlayersDropdown:SetOnce("Nome")
```

## Keybind

```lua
local Bind = Tab:AddBind({
    Name = "Abrir menu",
    Default = Enum.KeyCode.F,
    Hold = false,
    Flag = "menu_key",
    Save = true,
    Callback = function(holding)
        print(holding)
    end,
})

Bind:Set(Enum.KeyCode.G)
```

Com `Hold = true`, o callback recebe `true` ao pressionar e `false` ao soltar.

## Textbox

```lua
Tab:AddTextbox({
    Name = "Nome",
    Default = "",
    TextDisappear = false,
    Callback = function(text)
        print(text)
    end,
})
```

## Colorpicker

```lua
local Picker = Tab:AddColorpicker({
    Name = "Cor",
    Default = Color3.fromRGB(80, 120, 255),
    Flag = "color",
    Save = true,
    Callback = function(color)
        print(color)
    end,
})

Picker:Set(Color3.fromRGB(255, 80, 80))
```

## Pesquisa inteligente

A busca lateral indexa tabs, seções e controles. Ela aceita:

- correspondência exata;
- prefixos;
- palavras parciais;
- texto sem espaços;
- pequenas sequências incompletas;
- nomes de tabs, seções e componentes.

Ao encontrar um item, a Orion abre o tab correto, rola até o controle e aplica um destaque temporário que retorna à cor do tema.

```lua
OrionLib:FindAndFocusElement("veloc")
OrionLib:GoToTab("Jogador")
OrionLib:ScrollTo("Jogador", "Movimento", true)
OrionLib:ScrollToElement("Jogador", "Velocidade", true, "center")
```

## Tema

```lua
OrionLib.Themes.Custom = OrionLib:GenTheme(Color3.fromRGB(25, 80, 120))
OrionLib.SelectedTheme = "Custom"
OrionLib:SetTheme()
```

`GenTheme` calcula automaticamente fundo, divisores, stroke, texto e accent com contraste adaptativo.

## UI Config

```lua
Window:AddConfigTab()
```

Adiciona controles para:

- cor base e reset do tema;
- espessura do stroke;
- blur e intensidade;
- keystrokes e trava de posição no PC.

## Blur

```lua
Window:SetBlur(true, 20)
Window:SetBlur(false)
```

O blur usa `Lighting.BlurEffect`. Ele afeta o mundo 3D, não colore a tela e não consegue desfocar `CoreGui`, outras `ScreenGui` ou elementos do Windows.

## Keystrokes

```lua
Window:SetKeystrokes(true)
Window:SetKeystrokesLocked(false)
```

Mostra WASD, LMB e RMB. O painel pode ser arrastado enquanto não estiver travado. A seção e o painel aparecem somente em PC com teclado. Não aparecem em mobile real.

## Preview mobile

```lua
Window:SetMobilePreview(true)
Window:SetMobilePreview(false)
```

Serve para desenvolvimento no PC. Simula o botão móvel usado para reabrir a interface minimizada ou escondida.

## Notificações

```lua
OrionLib:MakeNotification({
    Name = "Concluído",
    Content = "Configuração aplicada",
    Image = "rbxassetid://4384403532",
    Time = 5,
})
```

## Flags e configuração

Componentes com `Flag` ficam disponíveis em `OrionLib.Flags`.

```lua
print(OrionLib.Flags.speed.Value)
OrionLib.Flags.speed:Set(25)
```

Use `SaveConfig = true` na janela e `Save = true` nos controles desejados. Finalize a criação da interface com:

```lua
OrionLib:Init()
```

## Encerramento

```lua
OrionLib:Destroy()
```

Remove a interface e encerra os efeitos vinculados a ela.

## Exemplo completo de teste

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Lilwagz/scripts/main/Orion%20X%20Test.lua?cache="
    .. tostring(os.time())
))()
```

