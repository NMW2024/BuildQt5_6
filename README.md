# Qt 静态编译指南

本文档提供完整的 Qt 静态库编译指南，涵盖所有指定版本和编译器组合。

## 编译目标

| Qt 版本 | 编译器 | 架构 | 用途 |
|---------|--------|------|------|
| 5.6.3 | MinGW 4.9 | 32-bit | Windows XP 兼容 |
| 5.12.12 | MSVC 2015 | 32/64-bit | LTS 版本 |
| 5.12.12 | MSVC 2017 | 32/64-bit | LTS 版本 |
| 5.12.12 | MinGW 7.3 | 32/64-bit | LTS 版本 |
| 5.15.14 | MSVC 2019 | 32/64-bit | LTS 版本 |
| 5.15.14 | MinGW 8.1 | 32/64-bit | LTS 版本 |
| 6.5.3 | MSVC 2022 | 64-bit | 最新 LTS |

## 快速开始

### 在 Windows 上编译所有版本

```batch
cd scripts
build-all-qt.bat
```

### 单独编译特定版本

```batch
REM Qt 5.6 for Windows XP
scripts\build-qt5.6-mingw49-xp.bat

REM Qt 5.12 with MSVC 2015 (32-bit)
scripts\build-qt5.12-msvc2015.bat x86

REM Qt 5.12 with MSVC 2017 (64-bit)
scripts\build-qt5.12-msvc2017.bat x64

REM Qt 5.15 with MinGW 8.1
scripts\build-qt5.15-mingw81.bat x64

REM Qt 6.5 with MSVC 2022
scripts\build-qt6.5-msvc2022.bat x64
```

详细使用说明请参考 [scripts/README.md](scripts/README.md)

## 前置要求

### 通用依赖
- Git (最新版本)
- Python 3.8+ (Qt6 必需)
- Perl (Strawberry Perl, Qt5 必需)
- Ninja 构建工具

### 各版本特定要求

#### Qt 5.6.x + MinGW 4.9 (Windows XP)
- Windows 7/10/11 (用于编译)
- MinGW-w64 4.9.4 (32-bit, i686)
- 下载地址: https://sourceforge.net/projects/mingw-w64/files/
- 注意：必须使用 `i686` 架构以支持 XP

#### Qt 5.12.x + MSVC 2015
- Visual Studio 2015 Update 3
- Windows SDK 8.1 或 10

#### Qt 5.12.x + MSVC 2017
- Visual Studio 2017 (v14.1 工具集)

#### Qt 5.12.x + MinGW 7.3
- Qt 官方提供的 MinGW 7.3.0 工具链
- 或自行安装 MinGW-w64 7.3.0

#### Qt 5.15.x + MSVC 2019
- Visual Studio 2019 (v14.2 工具集)

#### Qt 5.15.x + MinGW 8.1
- Qt 官方提供的 MinGW 8.1.0 工具链

#### Qt 6.5.x + MSVC 2022
- Visual Studio 2022 (v14.3 工具集)
- Windows 10 SDK (10.0.19041+)
- CMake 3.21+

## 目录结构建议

```
C:\qt-build\
├── src\                    # 源代码
│   ├── qt5.6.3\
│   ├── qt5.12.12\
│   ├── qt5.15.14\
│   └── qt6.5.3\
├── build\                  # 构建目录
│   ├── qt5.6.3-mingw49-xp\
│   ├── qt5.12.12-msvc2015\
│   ├── qt5.12.12-msvc2017\
│   ├── qt5.12.12-mingw73\
│   ├── qt5.15.14-msvc2019\
│   ├── qt5.15.14-mingw81\
│   └── qt6.5.3-msvc2022\
└── install\                # 安装目录
    ├── qt5.6.3-mingw49-xp\
    ├── qt5.12.12-msvc2015\
    └── ...
```

## 编译选项说明

### 核心配置
- `-static`: 静态链接
- `-release`: 仅发布版本（可添加 `-debug` 同时构建调试版）
- `-opensource -confirm-license`: 开源许可证
- `-prefix <path>`: 安装路径
- `-install-prefix <path>`: 安装前缀

### 模块选择
- `-nomake examples`: 不编译示例（如需示例请移除此选项）
- `-nomake tests`: 不编译测试
- `-skip <module>`: 跳过指定模块

### 功能选项 (Qt5)
- `-no-openssl`: 不使用 OpenSSL（或使用 `-openssl-linked` 静态链接）
- `-sql-sqlite`: 启用 SQLite 支持
- `-opengl desktop`: 桌面 OpenGL（或 `-no-opengl`）

### Qt6 特殊选项
- `-feature-static`: 静态构建
- `-no-system-proxies`: 不使用系统代理

## 磁盘空间需求

完整编译（包含所有模块、示例、文档）预计需要：
- Qt 5.6.x: ~15 GB
- Qt 5.12.x: ~25 GB
- Qt 5.15.x: ~30 GB
- Qt 6.5.x: ~35 GB

**总计**: 建议预留 150 GB+ 可用空间

## 编译时间预估

根据硬件配置不同：
- 低端 (4 核/8GB): 每个版本 4-8 小时
- 中端 (8 核/16GB): 每个版本 2-4 小时
- 高端 (16 核/32GB): 每个版本 1-2 小时

## 注意事项

1. **环境变量**: 确保正确的编译器在 PATH 中
2. **管理员权限**: 某些操作可能需要管理员权限
3. **网络**: 首次需要下载源代码和依赖
4. **清理**: 编译完成后可删除构建目录节省空间
5. **兼容性**: 
   - Qt 5.6 是最后一个支持 Windows XP 的版本
   - Qt 6.x 不再支持 Windows 7/8

## 验证安装

编译完成后，运行以下命令验证：

```batch
cd <install_dir>\bin
qmake --version
```

对于 MSVC 版本，还需检查：
```batch
dumpbin /headers Qt5Core.dll | findstr "machine"
```

## 故障排除

### 常见问题

1. **找不到编译器**
   - 确保使用正确的开发者命令行 (Developer Command Prompt)
   - 检查 PATH 环境变量

2. **链接错误**
   - 检查是否混用了不同编译器的库
   - 确认运行时库设置一致 (/MT vs /MD)

3. **内存不足**
   - 减少并行编译作业数 (`-j` 参数)
   - 关闭其他应用程序

4. **磁盘空间不足**
   - 清理旧的构建目录
   - 使用 `-skip` 跳过不需要的模块

详细脚本请参考 `scripts/` 目录中的各个批处理文件。
