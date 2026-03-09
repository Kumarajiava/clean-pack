# clean-pack

[English](README.md) | [中文](README_zh-CN.md)

一个专为 macOS 设计的压缩工具，生成的压缩包纯净无垃圾文件（自动去除 `.DS_Store`, `__MACOSX/`, `._*` 等文件）。

> **注意**: 原项目名为 `CleanZipForMac`，现已更名为 `clean-pack`。

## 功能特性

- 🗜️ 支持 ZIP 和 TAR.GZ 格式
- 🧹 自动排除 macOS 特有的垃圾文件：
  - `.DS_Store` 文件
  - `__MACOSX/` 目录
  - `._*` AppleDouble 资源文件
- 🖱️ 集成 macOS Finder 右键菜单（快速操作）
- 📝 输出文件名自动附带时间戳
- 🔒 已通过代码签名和公证（GitHub Releases）
- 🖥️ 自动检测 Apple Silicon (arm64) 或 Intel (x64) 架构

## 安装

### 一键安装（推荐）

在终端中运行以下命令，即可自动检测 Mac 架构、下载最新版本并配置 Finder 快速操作：

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash
```

### 手动安装 / 源码构建

如果你更喜欢手动安装或从源码构建：

```bash
git clone https://github.com/Kumarajiava/clean-pack.git
cd clean-pack
./scripts/install.sh
```

## 使用方法

### Finder 快速操作（右键菜单）

在 Finder 中选中任意文件或文件夹，点击右键：

1. 选择 **快速操作 (Quick Actions)**
2. 点击 **Compress as Clean ZIP** 或 **Compress as Clean TAR.GZ**

压缩包将生成在源文件所在的目录。

### 命令行使用

```bash
# 创建 ZIP 压缩包
clean-pack zip /path/to/folder 

# 创建 TAR.GZ 压缩包
clean-pack targz /path/to/folder

# 同时压缩多个文件/文件夹
clean-pack zip file1.txt folder2 file3.png
```

输出文件名格式：

- 单个文件/目录: `{文件名}.{YYMMDD_HHMMSS}.{后缀}`
- 多个文件/目录: `Archive.{YYMMDD_HHMMSS}.{后缀}` (生成在父目录中)

示例: `my-folder.260309_144331.zip`

## 更新

如需更新到最新版本，只需再次运行安装命令即可：

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash
```

## 卸载

运行以下命令即可卸载工具并移除右键菜单：

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash -s -- --uninstall
```

## 自动排除的文件

以下文件会被自动从压缩包中剔除：

| 匹配模式 | 说明 |
|---------|-------------|
| `.DS_Store` | macOS 文件夹显示设置 |
| `__MACOSX/` | macOS 资源分叉目录 |
| `._*` | AppleDouble 资源文件 |

## 开发

### 构建

```bash
cargo build --release
```

### 测试

```bash
cargo test
```

### 发布

```bash
# 创建新标签
git tag v0.1.0
git push origin v0.1.0

# GitHub Actions 将自动执行：
# 1. 构建 arm64 和 x64 版本
# 2. 签名和公证 (如果配置了密钥)
# 3. 创建 GitHub Release
```

### 必需的 GitHub Secrets (用于签名)

| Secret | 说明 |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | Base64 编码的 .p12 证书 |
| `APPLE_CERTIFICATE_PASSWORD` | 证书密码 |
| `APPLE_SIGNING_IDENTITY` | 例如: "Developer ID Application: Name (TEAMID)" |
| `APPLE_ID` | Apple ID 邮箱 |
| `APPLE_APP_SPECIFIC_PASSWORD` | 应用专用密码 |
| `APPLE_TEAM_ID` | Team ID |

## 许可证

Apache-2.0
