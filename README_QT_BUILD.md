# Qt 静态编译指南 (GitHub Actions)

## 概述

本项目提供 GitHub Actions 工作流，用于在 Windows 上静态编译多个版本的 Qt，包括：

| Qt 版本 | 编译器 | 架构 | 说明 |
|---------|--------|------|------|
| 5.6.3 | MinGW 4.9 | x86 | Windows XP 兼容 |
| 5.12.12 | MSVC 2015 | x86 | LTS 版本 |
| 5.12.12 | MSVC 2017 | x86 | LTS 版本 |
| 5.12.12 | MinGW 7.3 | x86 | LTS 版本 |
| 5.15.18 | MSVC 2019 | x86 | LTS 版本 |
| 5.15.18 | MinGW 8.1 | x86 | LTS 版本 |
| 6.5.3 | MSVC 2022 | x64 | Qt6 LTS (仅 64 位) |

## 工作流文件

### 1. `build-qt-single-test.yml` - 单版本测试

**用途**: 先编译一个版本测试配置是否正确（约 1.5-3 小时）

**配置**: Qt 5.15.18 + MSVC 2019 x64 on windows-2022

**触发方式**:
- 手动: Actions → "Build Qt Static - Single Test" → Run workflow
- 自动: 推送修改到此工作流文件时

**产物**: `qt-5.15.18-static-msvc2019_64.zip` (保留 14 天)

### 2. `build-qt-all-static.yml` - 全量构建

**用途**: 编译所有 7 种配置

**触发方式**:
- 手动: Actions → "Build Qt All Static Versions" → Run workflow
  - 可选择特定 Qt 版本
  - 留空则构建全部
- 自动: 推送修改到此工作流文件时

**产物**: 7 个 ZIP 文件，每个对应一种配置

## 编译特性

所有构建均包含：
- ✅ 静态库 (.lib / .a)
- ✅ 示例代码 (examples)
- ✅ 工具 (qmake, rcc, uic, lupdate 等)
- ✅ SQLite 支持 (内置)
- ✅ zlib, libpng, libjpeg (内置)
- ❌ OpenSSL (使用 `-no-openssl`)
- ❌ WebEngine (跳过，依赖过多)
- ❌ 部分大型模块 (qt3d, qtdoc, qtwayland 等)

## 使用方法

### 第一步：测试单个版本

```bash
# 推送到 GitHub 后
1. 进入仓库的 Actions 标签
2. 选择 "Build Qt Static - Single Test"
3. 点击 "Run workflow"
4. 等待 1.5-3 小时
5. 下载 Artifacts 中的 ZIP 文件
```

### 第二步：全量构建

测试成功后：

```bash
1. Actions → "Build Qt All Static Versions"
2. 点击 "Run workflow"
3. 可选：选择特定 Qt 版本
4. 等待 10-20 小时 (并行执行)
5. 下载所有 Artifacts
```

## 本地验证

下载并解压后：

```batch
:: 设置环境变量
set QT_DIR=C:\Qt\5.15.18_static\msvc2019_64
set PATH=%QT_DIR%\bin;%PATH%

:: 验证 qmake
qmake -v

:: 创建测试项目
mkdir test_project && cd test_project
echo #include <QCoreApplication> > main.cpp
echo int main(int argc, char *argv[]) { QCoreApplication a(argc, argv); return 0; } >> main.cpp
qmake -project
qmake
nmake  :: 或 mingw32-make
```

## 配置说明

### 静态编译关键参数

```batch
configure.bat ^
  -static ^              # 静态库
  -static-runtime ^      # 静态运行时 (MSVC)
  -release ^             # Release 版本
  -make examples ^       # 编译示例
  -make tools ^          # 编译工具
  -nomake tests ^        # 不编译测试
  -mp ^                  # 多进程编译
  -no-openssl ^          # 不使用 OpenSSL
  -qt-sqlite ^           # 内置 SQLite
  -qt-zlib ^             # 内置 zlib
  -qt-libpng ^           # 内置 libpng
  -qt-libjpeg ^          # 内置 libjpeg
  -skip qtwebengine ^    # 跳过 WebEngine
  ...
```

### Windows XP 兼容 (Qt 5.6.3)

```batch
-no-opengl ^
-no-angle ^
-platform win32-g++
```

## 预计时间

| 配置 | 预计时间 |
|------|----------|
| Qt 5.6.3 + MinGW 4.9 | 3-5 小时 |
| Qt 5.12.12 + MSVC | 4-6 小时 |
| Qt 5.12.12 + MinGW | 3-5 小时 |
| Qt 5.15.18 + MSVC | 2-4 小时 |
| Qt 5.15.18 + MinGW | 3-5 小时 |
| Qt 6.5.3 + MSVC 2022 | 5-8 小时 |

**全量构建**: 约 10-20 小时 (并行执行)

## 产物大小

每个完整构建约 2-5 GB (压缩后)

## 常见问题

### Q: 为什么跳过 WebEngine?
A: WebEngine 依赖 Chromium，编译时间极长且需要大量内存。如需要，可单独编译。

### Q: 如何添加更多模块？
A: 修改 configure 命令，移除相应的 `-skip` 参数。

### Q: 编译失败怎么办？
A: 
1. 检查日志中的错误信息
2. 确认磁盘空间充足 (至少 50GB)
3. 尝试单独构建失败的配置

### Q: 可以编译 Debug 版本吗？
A: 当前配置仅编译 Release。如需 Debug，添加 `-debug` 参数。

## 许可证

Qt 遵循 LGPL v3 / GPL v3 / 商业许可。静态链接需注意许可证合规性。

## 参考链接

- [Qt 官方文档](https://doc.qt.io/)
- [Qt 源码归档](https://download.qt.io/archive/qt/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
