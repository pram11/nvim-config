# 🚀 Neovim & IDE Vim Configuration

이 설정은 Neovim을 강력한 IDE처럼 활용하기 위한 **최소 조작 환경**을 제공합니다. 또한 동일한 단축키 경험을 IntelliJ 및 VS Code에서도 누릴 수 있도록 구성되어 있습니다. Java, Python, JS/TS, Rust, C/C++ 개발을 완벽하게 지원합니다.

## ✨ 주요 특징
- **Alt + r (Run)**: 현재 프로젝트의 언어를 자동 감지하여 빌드 및 실행합니다.
- **좌측 파일 탐색기 (nvim-tree)**: VS Code와 유사한 파일 탐색기 환경을 제공합니다.
- **Modern UI**: Tokyo Night 테마와 구문 강조(Treesitter)가 적용되었습니다.
- **LSP 통합**: 자동 완성, 정의 이동, 에러 체크 기능을 기본으로 제공합니다.
- **F5 대체 매핑**: F5 키가 없는 미니 배열 커스텀 키보드에서도 편안하게 사용할 수 있는 `Alt + r` 단축키를 채택했습니다.

## ⌨️ 핵심 단축키
| 기능 | 단축키 | 비고 |
|:---|:---:|:---|
| **빌드/실행** | `Alt + r` | 프로젝트 구조(Maven/Gradle/Cargo 등) 자동 감지 |
| **파일 탐색기 열기/닫기** | `Ctrl + e` | 좌측 nvim-tree 토글 |
| **코드 정의로 이동** | `gd` | Definition 이동 (LSP 연동) |
| **구현체로 이동** | `gi` | Implementation 이동 (LSP 연동) |
| **심볼 이름 변경** | `\r` | 변수/메서드 일괄 Rename |

## 🪟 기본 창 및 탭 관리 (Window & Tab)
기본 설정(`vim.opt.mouse = 'a'`)이 적용되어 있어 **마우스 클릭 및 드래그**로도 경계선을 움직여 창 크기를 조절하거나 탭을 클릭해 이동할 수 있지만, 키보드를 활용하면 더욱 빠릅니다.

### 탭 (Tab) 제어
| 기능 | 명령어 / 단축키 | 비고 |
|:---|:---|:---|
| **새 탭 열기** | `:tabnew` | `:tabnew 파일명`으로 특정 파일을 새 탭에서 열기 가능 |
| **다음 탭 이동** | `gt` | |
| **이전 탭 이동** | `gT` | |
| **현재 탭 닫기** | `:tabclose` | 또는 해당 탭의 마지막 창에서 `:q` 입력 |

### 창 분할 및 크기 조절 (Split & Resize)
| 기능 | 명령어 / 단축키 | 비고 |
|:---|:---|:---|
| **수직 분할 (세로)** | `:vsp` | 화면을 좌우로 나눔 |
| **수평 분할 (가로)** | `:sp` | 화면을 위아래로 나눔 |
| **창 간 이동** | `Ctrl + w` 누른 후 방향키 | 방향키는 `h, j, k, l` 또는 일반 화살표 모두 가능 |
| **너비 조절** | `Ctrl + w` 누른 후 `<` 또는 `>` | 좌우 크기 조절 |
| **높이 조절** | `Ctrl + w` 누른 후 `+` 또는 `-` | 상하 크기 조절 |
| **크기 균등 정렬** | `Ctrl + w` 누른 후 `=` | 열려있는 모든 창의 크기를 똑같이 맞춤 |

## 📦 주요 플러그인 사용법

### 1. nvim-tree (파일 탐색기)
`Ctrl + e`를 눌러 좌측에 탐색기를 띄운 후, Vim의 기본 이동키를 사용하여 파일을 탐색합니다.
* `j` / `k` : 위아래로 이동
* `Enter` 또는 `o` : 파일 열기 / 폴더 열고 닫기
* `Tab` : 탐색기 창과 편집기 창 사이를 전환 (창 이동 기본키 `Ctrl+w` 후 방향키 이동도 가능)
* `q` : 탐색기 닫기

### 2. nvim-cmp (자동 완성)
코드를 작성하면 LSP가 분석하여 자동으로 추천 목록을 띄워줍니다.
* `Enter` : 추천 목록에서 현재 하이라이트된 항목 선택
* `Tab` / `Shift + Tab` : 추천 목록 내에서 위아래로 이동

### 3. ToggleTerm (터미널 & 실행 결과)
`Alt + r`을 누르면 하단에 플로팅(Float) 터미널이 열리며 코드가 실행됩니다.
* 실행이 끝난 후, 터미널 창을 닫고 싶다면 터미널 내부에서 `exit`를 입력하거나 창 닫기 단축키(일반적으로 `<C-\><C-n>`)를 사용합니다.

## 🛠 언어별 실행 로직
- **Java**: Maven(`pom.xml`), Gradle(`gradlew`) 자동 감지 및 실행
- **Rust**: Cargo(`Cargo.toml`) 감지 및 실행 지원
- **C/C++**: `Makefile` 존재 시 활용, 단일 파일 시 자동 컴파일 실행
- **Web/Python**: `node`, `ts-node`, `python3` 기반 즉시 실행

## ⚙️ Neovim 설치 방법
1. 이 저장소의 `init.lua`를 `~/.config/nvim/` 폴더에 복사합니다.
2. Neovim을 실행하면 `lazy.nvim`이 플러그인을 자동으로 설치합니다.
3. 설치 후 `:Mason`을 입력하여 필요한 언어 서버를 설치합니다.
   - 권장 설치: `jdtls`, `pyright`, `typescript-language-server`, `rust-analyzer`, `clangd`

---

## 📂 타 IDE 적용 방법 (Cross-Platform)

터미널 환경(Neovim)과 GUI 환경(IntelliJ/VS Code)에서 동일한 손맛을 유지하기 위한 설정입니다.

### 1. IntelliJ (IdeaVim)
1. IDE에서 `IdeaVim` 플러그인을 설치합니다.
2. 본 저장소의 `.ideavimrc` 내용을 복사하여 사용자 홈 디렉토리(`~/.ideavimrc`)에 저장합니다.
3. IDE를 재시작하거나 `:source ~/.ideavimrc`를 입력합니다.

### 2. VS Code (Vim Extension)
1. `Vim` 확장을 설치합니다.
2. `settings.json` 파일에 본 저장소의 `vscode-vim-settings.json` 내용을 추가합니다.
3. 별도의 설정 없이 즉시 적용됩니다.

## 💡 개발 철학
- **Cross-Platform Consistency**: Neovim, IntelliJ, VS Code 어디서든 일관된 조작 경험을 제공합니다.
- **Minimal Movement**: 커스텀 키보드 환경을 고려하여 F5 등 상단 기능키 대신 `Alt` 조합과 기본 자판 영역 내에서 모든 조작이 가능하도록 설계했습니다.
