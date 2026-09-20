# 🔥 Fire Hub & Syde UI Library

Repositório oficial do **Fire Hub** (Fling Things and People - FTAP) e da biblioteca de interface **Syde UI Library**.

O **Fire Hub** foi totalmente modernizado e migrado: a dependência legada da Orion Library foi completamente removida, passando a utilizar nativamente a **Syde UI Library**, garantindo carregamento ultrarrápido, sistema integrado de temas, binds com salvamento automático e pesquisa instantânea.

---

## ⚡ Como Executar (Quick Start)

Copie e cole o código abaixo no seu executor de preferência (Potassium, Synapse Z, Wave, Delta, Hydrogen, etc.):

### 🚀 Fire Hub (Script Principal)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/fire.lua", true))()
```

### 🎨 Syde UI Library (Biblioteca Isolada)
```lua
local syde = loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/syde.lua", true))()
```

### 🧪 Syde UI Showcase (Script de Testes & Exemplos)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vze7/scripts/main/syde_test.lua", true))()
```

---

## 🛠️ Migração: Orion ➔ Syde UI

O `fire.lua` agora comunica-se diretamente com o motor da `syde.lua`. Todas as funcionalidades visuais e comportamentais foram alinhadas e preservadas:

| Recurso | Orion Legado | Syde UI Library |
| :--- | :--- | :--- |
| **Instanciação** | `OrionLib:MakeWindow({...})` | `syde:MakeWindow({...})` |
| **Notificações** | `OrionLib:MakeNotification({...})` | `syde:MakeNotification({...})` |
| **Modo de Mouse** | `OrionLib.UMouseMode` | `syde.UMouseMode` |
| **Zoom de Câmera** | `OrionLib.maxds` / `minds` | `syde.maxds` / `minds` |
| **Inicialização** | `OrionLib:Init()` | `syde:Init()` |
| **Temas & Cores** | Estático ou manual | `AddSmartTheme` dinâmico com auto-save |
| **Performance** | Carregamento pesado | Otimizado para renderização imediata |

---

## 📦 Funcionalidades do Fire Hub

O script conta com uma suíte completa de ferramentas divididas em 8 abas especializadas:

### 1. 🧲 Grab Tab
* **Reach & Instant Grab**: Aumente a distância de agarre e capture itens imediatamente.
* **Fling & Throw Power**: Força customizável de arremesso e impulsão de objetos e jogadores.
* **Grip Modes**: Modificação de empunhadura e pontos de fixação.

### 2. 🛡️ Anti Tab
* **Anti Grab**: Impede que outros jogadores peguem você ou seus objetos.
* **Anti Fling & Anti Void**: Proteção contra impulsões extremas e quedas no vazio.
* **Anti Ragdoll & Anti Struggle**: Mantém o controle do seu personagem mesmo sob efeitos de física.
* **Loop Position (`AddPbind`)**: Trava o personagem ou alvos em coordenadas X, Y, Z customizadas.
* **Speed & Jump Mods**: Sliders reativos para controle de `WalkSpeed` e `JumpPower`.

### 3. ✨ Aura Tab
* **Ownership Aura (O)**: Toma posse dos objetos próximos automaticamente via rede.
* **PermOwnership Aura (PO)**: Garante a persistência contínua de dono dos objetos.
* **Bring & Grab Auras**: Interações automáticas em área sem necessidade de mira direta.

### 4. 🫧 Blob Tab
* **Blob Toys Control**: Manipulação direta dos blobs do mapa.
* **Auto Fling & Destroy**: Eliminação rápida de brinquedos indesejados.

### 5. 🔄 Loop Tab
* **Target Selector**: Dropdown dinâmico com atualização em tempo real da lista de jogadores (`Refresh`).
* **Loop Actions**: Modos de Loop Ragdoll, Loop Fling, Loop Bring e Loop Kill.

### 6. 👁️ ESP Tab
* **Visualização Tática**: Bounding Boxes, Tracers, Display de Distância e Highlights.
* **Color Customization**: Seletor de cores (`AddColorpicker`) integrado para diferenciar aliados e inimigos.

### 7. ⌨️ Bind Tab
* **Atalhos de Teclado**: Configuração rápida de teclas para ações críticas (Void Teleport, Safe Zone, Ativação de Antis e Fling).

### 8. ⚙️ Config Tab
* **UI Customization**:
  * `FreeMouseDrp()`: Alternância entre ThirdPerson e FreeMouse.
  * `AddUiBind()`: Definição de tecla para abrir/fechar a interface.
  * `AddSmartTheme()`: Geração e personalização em tempo real de temas e acentos visuais.
* **Whitelist & Proteção**: Gerenciamento de lista de amigos/aliados imunes às auras e loops.

---

## 📂 Estrutura do Repositório

```text
├── fire.lua          # Script principal do Fire Hub (compatível com Syde UI)
├── syde.lua          # Biblioteca de Interface Syde UI (suporte nativo + Orion)
├── syde_test.lua     # Script de demonstração com todos os elementos da Syde UI
├── README.md         # Documentação e guia de uso
```

---

## 🔒 Requisitos

* **Ambiente**: Roblox Client com executor Luau compatível (Level 7/8).
* **Funções Executor**:
  * `game:HttpGet`
  * `loadstring`
  * `readfile` / `writefile` / `isfolder` / `makefolder` (para salvamento automático de configurações).

---

## 👥 Créditos

* **Fire Hub**: Desenvolvido por `firemax`.
* **Syde UI Library & Adaptação**: `iceboy`.
