# 🛠️ ardour-build-tool

## 🇨🇳 中文

### 📖 项目简介

本项目通过 **GitHub Actions** 从 [Ardour/ardour](https://github.com/Ardour/ardour) 官方源码自动编译 Ardour（专业数字音频工作站 / DAW），并将构建产物发布为本仓库的 **Draft Release（草稿发布）**。

- 支持手动触发构建指定版本 / 指定平台
- 支持一键批量补齐所有缺失的「版本×平台」组合
- **仅构建 9.0 及之后的版本**（原因见下方「版本范围说明」）
- 产物仅以草稿形式发布，仅仓库所有者可见

三个平台的构建方式：

| 平台 | Runner | 音频/MIDI 后端 | 产物格式 |
| --- | --- | --- | --- |
| Windows | `windows-latest` + MSYS2 MINGW64 | PortAudio / JACK / Dummy | `ardour-<版本>-windows-x64.zip` |
| macOS | `macos-latest`（Apple Silicon）+ Homebrew | CoreAudio / Dummy | `ardour-<版本>-macos-arm64.dmg` |
| Linux | `ubuntu-latest` + apt | ALSA / JACK / PulseAudio / Dummy | `ardour-<版本>-linux-x64.tar.gz` |

### ✨ 徽章

> 请将下方链接中的用户名/仓库名替换为你的实际仓库。

![Build and Release](https://github.com/Zhang-Chang-Yuan/ardour-build-tool/actions/workflows/build_and_release.yml/badge.svg)

### 🎯 版本范围说明（重要）

本项目**仅构建 [9.0](https://github.com/Ardour/ardour/releases) 及之后发布的稳定版本**（tag 格式为 `X.Y`，如 `9.8`），原因如下：

1. **构建配方针对 9.x 验证**：三个平台的依赖清单与打包流程均以 9.x 为目标整理（Linux 参考官方/发行版打包依赖，macOS 使用 Homebrew 旧 API 版 GTK 绑定库，Windows 使用 MSYS2 MINGW64），更老的版本第三方库版本差异较大；
2. **版本 tag 格式特殊**：Ardour 的 release tag 为纯数字（`9.8`、`8.12`），仓库中还存在大量非版本 tag（`BUILD-ID`、`sae-1`、`prercu` 等），工作流已做严格过滤；
3. **成本考虑**：为旧版本逐一回溯适配旧依赖，在 CI 上成本极高且几乎必然失败，故不做尝试。

官方未来发布的新版本（如 9.9、10.0）只要仍在此配方适用范围内，就会在勾选 build_all 运行时被检测并构建。范围阈值由工作流中的 `MIN_VERSION` 环境变量控制，可自行修改。

### 🚀 快速开始

#### 手动触发

1. 进入仓库主页，点击 **Actions** 标签页；
2. 在左侧工作流列表中选择 **Build and Release Ardour**；
3. 点击右侧 **Run workflow** 按钮；
4. 填写参数：
   - **Ardour 版本 tag**（可选）：如 `9.8`（仅支持 9.0 及以上，**注意没有 v 前缀**）。⚠️ 由于 GitHub 原生不支持动态下拉列表，需手动输入版本 tag；**留空则自动构建最新稳定版**；
   - **平台**：下拉选择 `windows-latest` / `macos-latest` / `ubuntu-latest`，默认 `windows-latest`；
   - **构建全部缺失版本（build_all）**：勾选后一次性把所有缺失的版本在三个平台上全部构建；
5. 点击 **Run workflow** 开始构建。

#### 批量构建（build_all）

在手动触发时勾选 **build_all**，工作流会对比 [Ardour/ardour](https://github.com/Ardour/ardour) 官方 tags（仅 9.0 及之后的稳定版本）与本仓库已有 Release（含草稿），把所有缺失的「版本×平台」组合一次性构建补齐。已构建过的组合不会重复构建；再次构建同一产物时会以覆盖方式上传，保证始终是最新构建。

> ℹ️ 本项目**未启用定时构建**（schedule），一切构建均由手动触发。如需每日自动检测新版本，可在 `.github/workflows/build_and_release.yml` 中自行添加 `schedule` 触发器（与 build_all 逻辑完全兼容）。

#### 下载与安装

1. 构建完成后，进入仓库 **Releases** 页面（草稿仅仓库所有者可见）；
2. 下载对应平台的产物：
   - **Windows**：解压 zip 到任意目录（如 `D:\Ardour9`），双击运行目录中的 `Ardour9.cmd`（所需 DLL 均已内置，无需安装 MSYS2）；
   - **macOS**：挂载 dmg，把 `Ardour9.app` 拖入「应用程序」，首次打开如被 Gatekeeper 拦截，请在「系统设置 → 隐私与安全性」中点击「仍要打开」（构建为 ad-hoc 签名，未加入 Apple 开发者计划）；
   - **Linux**：解压 tar.gz 到任意目录，运行其中的 `ardour9` 启动脚本（如 `tar xf ardour-9.8-linux-x64.tar.gz && ./Ardour-9.8-Linux-x64/ardour9`）。

### ⚠️ 注意事项

- 📝 **Draft Release 仅仓库所有者/协作者可见**，其他人无法访问；确认无误后可手动发布为正式 Release；
- ⚖️ Ardour 源码遵循 **GPL v2+** 许可证，自编译二进制供个人使用完全没有问题；如需分发，请遵循 GPL 要求提供源码及对应权利。也请考虑[购买官方版本](https://ardour.org/download)支持 Ardour 的开发；
- ⏱️ 注意 GitHub Actions 的分钟数限制（免费额度公共仓库无限，私有仓库有限额）；
- 🕐 单次构建耗时约 **20–90 分钟**（视平台而定，Windows/MSYS2 通常最慢）；
- 🐧 **Linux 版为动态链接**（基于 Ubuntu 24.04 的 glibc），需要较新的发行版；Windows 产物已内置全部依赖 DLL；macOS 产物已内置 Homebrew 依赖库；
- 🖥️ macOS 产物为 **Apple Silicon（arm64）** 构建（基于 `macos-latest`），Intel Mac 无法运行；
- 🎛️ Windows 版音频后端为 PortAudio（WASAPI/MME/DS），未编译 ASIO 支持（ASIO SDK 许可证不允许再分发）；如需 ASIO 请自行参考 Ardour 官方文档本地编译。

### ❓ FAQ

**Q: 为什么版本号没有 v 前缀，需要手动输入，而不是下拉选择？**
A: Ardour 官方 tag 本身就是纯数字（如 `9.8`）；同时 GitHub Actions 原生不支持在 `workflow_dispatch` 输入中提供动态下拉列表（choice 选项必须写死），因此版本 tag 采用字符串输入，留空即自动使用最新稳定版。

**Q: 构建失败了怎么办？**
A: 可在 Actions 页面对应运行中点击 **Re-run failed jobs** 重试失败的任务；也可直接手动重新触发一次（同名 Release 草稿会被覆盖更新）。

**Q: 和官方版本有什么区别？**
A: 官方版本使用官方构建环境（自带依赖栈、正式签名、完整安装器与本站更新服务）。本项目的构建在 GitHub 托管机上完成：无正式签名（macOS 需手动放行）、未捆绑 harvid/xjadeo 视频工具、Windows 未启用 ASIO、部分可选组件（视频时间线等）不可用。核心的录音、混音、编辑、插件（LV2/VST3/LADSPA）功能一致。

**Q: 为什么发布为 Draft（草稿）？**
A: 草稿 Release 仅仓库所有者可见，便于先确认构建产物可用再决定是否公开发布；同时避免 CI 半成品被误下载。在 Releases 页面打开草稿条目，点击「Publish release」即可转正式发布。

**Q: Windows 版启动报错或闪退怎么办？**
A: 请确认解压到了纯英文/无特殊字符路径，并通过目录中的 `Ardour9.cmd` 启动（它会设置必要的环境变量）。若仍异常，可在 Actions 页面下载对应构建日志并提 Issue。

**Q: Linux 版启动提示缺库怎么办？**
A: Linux 产物动态链接了 ALSA / PulseAudio / JACK 等系统库，请确保发行版已安装 `libasound2`、`libpulse0`、`libjack0`（或 jackd2）等运行库；glibc 版本过低（如 Ubuntu 20.04）则需升级系统或自行修改工作流使用更旧的 runner 镜像重新构建。

### 📄 许可证说明

本仓库**仅包含 CI 脚本与说明文档**，不包含、不分发任何 Ardour 源码或二进制文件。Ardour 源码遵循 [GPL v2+](https://github.com/Ardour/ardour/blob/master/COPYING) 许可证，版权归 Ardour 团队及贡献者所有；由此工作流产出的二进制遵循同一许可证。

---

## 🇬🇧 English

### 📖 About

This project uses **GitHub Actions** to automatically build Ardour (a professional digital audio workstation) from the official [Ardour/ardour](https://github.com/Ardour/ardour) source code and publishes the artifacts as **Draft Releases** in this repository.

- Manual trigger with custom version / platform
- One-click batch fill of all missing version × platform combinations
- **Only versions 9.0 and later are built** (see "Supported Version Range" below)
- Artifacts are published as drafts, visible only to the repository owner

Build matrix:

| Platform | Runner | Audio/MIDI backends | Artifact |
| --- | --- | --- | --- |
| Windows | `windows-latest` + MSYS2 MINGW64 | PortAudio / JACK / Dummy | `ardour-<ver>-windows-x64.zip` |
| macOS | `macos-latest` (Apple Silicon) + Homebrew | CoreAudio / Dummy | `ardour-<ver>-macos-arm64.dmg` |
| Linux | `ubuntu-latest` + apt | ALSA / JACK / PulseAudio / Dummy | `ardour-<ver>-linux-x64.tar.gz` |

### ✨ Badge

> Replace the username/repository in the URLs below with your own.

![Build and Release](https://github.com/Zhang-Chang-Yuan/ardour-build-tool/actions/workflows/build_and_release.yml/badge.svg)

### 🎯 Supported Version Range (Important)

This project **only builds stable versions 9.0 and later** (tags are plain numbers like `9.8`):

1. **The build recipes are verified against 9.x**: the dependency lists and packaging steps for all three platforms target 9.x (Linux distro packaging deps, macOS Homebrew legacy-API GTK bindings, Windows MSYS2 MINGW64). Older releases differ too much in third-party library versions;
2. **Special tag format**: Ardour release tags are plain numbers (`9.8`, `8.12`), and the repository contains many non-release tags (`BUILD-ID`, `sae-1`, `prercu`, …) — the workflow filters them strictly;
3. **Cost**: back-porting old dependency stacks per legacy release on CI is expensive and almost guaranteed to fail, so it is not attempted.

Future official releases (e.g. 9.9, 10.0) are detected and built when running with build_all, as long as they stay within this recipe. The threshold is controlled by the `MIN_VERSION` environment variable in the workflow file.

### 🚀 Quick Start

#### Manual Trigger

1. Go to the repository's **Actions** tab;
2. Select **Build and Release Ardour** from the workflow list;
3. Click **Run workflow**;
4. Fill in the inputs:
   - **Ardour version tag** (optional): e.g. `9.8` (9.0 and later only, **no `v` prefix**). ⚠️ GitHub does not natively support dynamic dropdowns, so type the tag manually; **leave empty to build the latest stable release**;
   - **Platform**: choose `windows-latest` / `macos-latest` / `ubuntu-latest` (default: `windows-latest`);
   - **build_all**: check this to build every missing version × platform combination in one run;
5. Click **Run workflow** to start.

#### Batch Build (build_all)

When triggering manually with **build_all** checked, the workflow compares the official [Ardour/ardour](https://github.com/Ardour/ardour) tags (stable versions 9.0 and later only) with existing Releases (including drafts) in this repository, then builds every missing version × platform combination in one run. Already-built combinations are not rebuilt; re-built artifacts are uploaded with overwrite so they are always the latest build.

> ℹ️ This project does **not** use scheduled builds (`schedule`) — everything is triggered manually. If you want daily automatic detection of new versions, add a `schedule` trigger to `.github/workflows/build_and_release.yml` yourself (fully compatible with the build_all logic).

#### Download & Install

1. When the build finishes, open the **Releases** page (drafts are visible to the repository owner only);
2. Download the artifact for your platform:
   - **Windows**: extract the zip anywhere (e.g. `D:\Ardour9`) and double-click `Ardour9.cmd` inside (all required DLLs are bundled; MSYS2 is *not* needed);
   - **macOS**: mount the dmg and drag `Ardour9.app` to Applications. On first launch Gatekeeper may block it — go to *System Settings → Privacy & Security* and click *Open Anyway* (the build is ad-hoc signed, not notarized);
   - **Linux**: extract the tar.gz anywhere and run the `ardour9` launcher inside (e.g. `tar xf ardour-9.8-linux-x64.tar.gz && ./Ardour-9.8-Linux-x64/ardour9`).

### ⚠️ Notes

- 📝 **Draft Releases are visible only to the repository owner/collaborators**; publish them manually once verified;
- ⚖️ Ardour source is licensed under **GPL v2+** — self-built binaries for personal use are perfectly fine; if you redistribute, follow the GPL (provide source and the same rights). Please also consider [buying an official build](https://ardour.org/download) to support Ardour development;
- ⏱️ Be aware of GitHub Actions usage minute limits (unlimited for public repos, limited for private ones);
- 🕐 A single build takes about **20–90 minutes** depending on the platform (Windows/MSYS2 is usually the slowest);
- 🐧 The **Linux build is dynamically linked** (against Ubuntu 24.04 glibc) and needs a reasonably modern distribution; Windows artifacts bundle all required DLLs; macOS artifacts bundle their Homebrew dependency libraries;
- 🖥️ The macOS build is **Apple Silicon (arm64)** only (based on `macos-latest`) and will not run on Intel Macs;
- 🎛️ The Windows build uses the PortAudio backend (WASAPI/MME/DS) **without ASIO** (the ASIO SDK license does not allow redistribution); build locally per the official docs if you need ASIO.

### ❓ FAQ

**Q: Why is the version number plain (no `v` prefix), and why do I have to type it instead of picking it from a dropdown?**
A: Ardour's official tags are plain numbers (e.g. `9.8`). Also, GitHub Actions does not support dynamic option lists in `workflow_dispatch` inputs (choices must be static), so the version is a string input. Leaving it empty builds the latest stable version automatically.

**Q: What if a build fails?**
A: On the Actions run page, click **Re-run failed jobs** to retry, or simply trigger a manual run again (an existing draft Release with the same tag is overwritten).

**Q: How does this differ from the official builds?**
A: Official builds use Ardour's own build environment (bundled dependency stack, proper code signing, installers, website update service). This project builds on GitHub-hosted runners: no Apple notarization (macOS needs "Open Anyway"), no bundled harvid/xjadeo video tools, no ASIO on Windows, and some optional components (video timeline, etc.) are unavailable. Core recording/mixing/editing and plugin support (LV2/VST3/LADSPA) are the same.

**Q: Why are releases published as drafts?**
A: Drafts are visible only to the repository owner, so you can verify the artifacts before publishing, and half-finished CI uploads are never exposed accidentally. Open the draft on the Releases page and click "Publish release" to make it public.

**Q: Windows crashes or errors on launch?**
A: Make sure the path you extracted to contains no special characters, and launch via `Ardour9.cmd` in the folder (it sets up the required environment variables). If it still fails, download the build log from the Actions page and open an issue.

**Q: Linux reports missing libraries on launch?**
A: The Linux build dynamically links system libraries such as ALSA/PulseAudio/JACK. Make sure `libasound2`, `libpulse0` and `libjack0` (or jackd2) are installed. If your glibc is too old (e.g. Ubuntu 20.04), upgrade your distribution or modify the workflow to use an older runner image and rebuild.

### 📄 License Note

This repository **contains only CI scripts and documentation** — no Ardour source code or binaries are included or distributed. Ardour source code is licensed under [GPL v2+](https://github.com/Ardour/ardour/blob/master/COPYING), copyrighted by the Ardour team and contributors; binaries produced by this workflow are governed by the same license.
