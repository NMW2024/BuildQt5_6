# Qt 静态编译完整脚本集

本目录包含用于编译所有指定 Qt 版本和编译器组合的完整脚本。

## 脚本列表

### 主控制脚本
- `build-all-qt.bat` - 一键编译所有 Qt 版本（推荐首次使用）

### 单独编译脚本

#### Qt 5.6.x (Windows XP 兼容)
- `build-qt5.6-mingw49-xp.bat` - Qt 5.6.3 + MinGW 4.9 (32-bit)

#### Qt 5.12.x
- `build-qt5.12-msvc2015.bat [x86|x64]` - Qt 5.12.12 + MSVC 2015
- `build-qt5.12-msvc2017.bat [x86|x64]` - Qt 5.12.12 + MSVC 2017
- `build-qt5.12-mingw73.bat [x86|x64]` - Qt 5.12.12 + MinGW 7.3

#### Qt 5.15.x
- `build-qt5.15-msvc2019.bat [x86|x64]` - Qt 5.15.14 + MSVC 2019
- `build-qt5.15-mingw81.bat [x86|x64]` - Qt 5.15.14 + MinGW 8.1

#### Qt 6.5.x
- `build-qt6.5-msvc2022.bat [x64]` - Qt 6.5.3 + MSVC 2022

## 快速开始

### 方法一：编译所有版本
```batch
cd scripts
build-all-qt.bat
```

### 方法二：单独编译特定版本
```batch
REM Qt 5.6 for Windows XP
build-qt5.6-mingw49-xp.bat

REM Qt 5.12 with MSVC 2015 (32-bit)
build-qt5.12-msvc2015.bat x86

REM Qt 5.12 with MSVC 2015 (64-bit)
build-qt5.12-msvc2015.bat x64

REM Qt 6.5 with MSVC 2022
build-qt6.5-msvc2022.bat x64
```

## 前置条件

### 所有版本通用
- Git
- Perl (Strawberry Perl, 仅 Qt5)
- Python 3.8+ (Qt6 必需)
- CMake 3.21+ (Qt6 必需)
- Ninja 构建工具

### 编译器要求

| 脚本 | 所需编译器 | 下载链接 |
|------|-----------|---------|
| build-qt5.6-mingw49-xp.bat | MinGW-w64 4.9.4 (i686, win32) | https://sourceforge.net/projects/mingw-w64/ |
| build-qt5.12-msvc2015.bat | Visual Studio 2015 Update 3 | https://my.visualstudio.com/ |
| build-qt5.12-msvc2017.bat | Visual Studio 2017 | https://my.visualstudio.com/ |
| build-qt5.12-mingw73.bat | MinGW-w64 7.3.0 或 Qt Tools\mingw730_* | https://sourceforge.net/projects/mingw-w64/ |
| build-qt5.15-msvc2019.bat | Visual Studio 2019 | https://visualstudio.microsoft.com/ |
| build-qt5.15-mingw81.bat | MinGW-w64 8.1.0 或 Qt Tools\mingw810_* | https://sourceforge.net/projects/mingw-w64/ |
| build-qt6.5-msvc2022.bat | Visual Studio 2022 | https://visualstudio.microsoft.com/ |

## 配置说明

### 路径配置
每个脚本顶部都有路径配置部分，请根据实际情况修改：
```batch
set BUILD_ROOT=C:\qt-build
set MINGW_ROOT=C:\mingw-w64\...
```

### 模块选择
默认配置包含常用模块。如需更完整的构建，修改 `init-repository.pl` 的 `-module-subset` 参数。

### 编译选项
- `-static`: 静态链接
- `-release`: 发布版本
- `-nomake examples`: 不编译示例（移除此行以包含示例）
- `-nomake tests`: 不编译测试

## 输出目录结构

```
C:\qt-build\
├── src\                    # Qt 源代码
│   ├── qt5.6.3\
│   ├── qt5.12.12\
│   ├── qt5.15.14\
│   └── qt6.5.3\
├── build\                  # 构建中间文件（可删除）
│   └── ...
└── install\                # 最终安装目录
    ├── qt5.6.3-mingw49-xp\
    ├── qt5.12.12-msvc2015\
    ├── qt5.12.12-msvc2015-x64\
    ├── qt5.12.12-msvc2017\
    ├── qt5.12.12-msvc2017-x64\
    ├── qt5.12.12-mingw73\
    ├── qt5.12.12-mingw73-x64\
    ├── qt5.15.14-msvc2019\
    ├── qt5.15.14-msvc2019-x64\
    ├── qt5.15.14-mingw81\
    ├── qt5.15.14-mingw81-x64\
    └── qt6.5.3-msvc2022\
```

## 验证安装

编译完成后，验证安装：

```batch
REM Qt5 验证
cd C:\qt-build\install\qt5.12.12-msvc2015\bin
qmake --version

REM Qt6 验证
cd C:\qt-build\install\qt6.5.3-msvc2022\bin
qmake --version
```

## 在项目中配置 qmake

### Qt Creator
1. 打开 工具 -> 选项 -> Kits
2. 添加新的 Kit
3. 设置 Compiler 为对应的 MSVC 或 MinGW
4. 设置 Qt version 指向新编译的 qmake
5. 设置 Debugger 和 CMake

### 命令行
```batch
REM 设置环境变量
set PATH=C:\qt-build\install\qt5.12.12-msvc2015\bin;%PATH%

REM 或使用完整路径
C:\qt-build\install\qt5.12.12-msvc2015\bin\qmake.exe your-project.pro
```

## 常见问题

### 1. 找不到编译器
确保使用正确的 Developer Command Prompt 或在脚本中正确设置 VS 环境。

### 2. 内存不足
减少并行编译数，编辑脚本中的 `-j%NUMBER_OF_PROCESSORS%` 为较小的值。

### 3. 磁盘空间不足
编译完成后可删除 `build` 目录下的内容。

### 4. Windows XP 兼容性
只有 Qt 5.6.3 + MinGW 4.9 支持 Windows XP。确保：
- 使用 i686 (32-bit) 架构
- 使用 win32 线程模型
- 不使用 C++11 特性

### 5. OpenSSL 支持
如需 SSL 功能，需要：
1. 下载 OpenSSL 源码
2. 静态编译 OpenSSL
3. 在 Qt 配置中添加 `-openssl-linked` 和相关路径

## 许可证

Qt 使用 LGPL v3 或 GPL v3 许可证。静态链接可能需要购买商业许可证或开源你的代码。

详细信息请参考：https://www.qt.io/licensing/
