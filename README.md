# 🚀 Neovim IDE Config

이 설정은 Neovim을 강력한 IDE처럼 활용하기 위한 **최소 조작 환경**을 제공합니다. Java, Python, JS/TS, Rust, C/C++ 개발을 지원합니다.

## ✨ 주요 특징
- **Alt + r (Run)**: 현재 프로젝트의 언어를 자동 감지하여 빌드 및 실행합니다.
- **Modern UI**: Tokyo Night 테마와 구문 강조(Treesitter)가 적용되었습니다.
- **LSP 통합**: 자동 완성, 정의 이동, 에러 체크 기능을 기본으로 제공합니다.
- **F5 대체 매핑**: F5 키가 없는 미니 배열 커스텀 키보드에서도 편안하게 사용할 수 있는 `Alt + r` 단축키를 채택했습니다.

## ⌨️ 핵심 단축키
| 기능 | 단축키 | 비고 |
|:---:|:---:|:---|
| **빌드/실행** | `Alt + r` | 프로젝트 구조(Maven/Gradle/Cargo 등) 자동 감지 |
| **자동 완성 선택** | `Enter` | 코드 추천 목록에서 선택 |
| **목록 이동** | `Tab` / `S-Tab` | 완성 목록 내 상하 이동 |
| **LSP 관리** | `:Mason` | 언어 서버 설치 및 업데이트 |

## 🛠 언어별 실행 로직
- **Java**: Maven(`pom.xml`), Gradle(`gradlew`) 자동 감지 및 실행
- **Rust**: Cargo(`Cargo.toml`) 감지 및 실행 지원
- **C/C++**: `Makefile` 존재 시 활용, 단일 파일 시 자동 컴파일 실행
- **Web/Python**: `node`, `ts-node`, `python3` 기반 즉시 실행

## ⚙️ 설치 방법
1. 이 저장소의 `init.lua`를 `~/.config/nvim/` 폴더에 복사합니다.
2. Neovim을 실행하면 `lazy.nvim`이 플러그인을 자동으로 설치합니다.
3. 설치 후 `:Mason`을 입력하여 필요한 언어 서버를 설치합니다.
   - 권장 설치: `jdtls`, `pyright`, `typescript-language-server`, `rust-analyzer`, `clangd`
