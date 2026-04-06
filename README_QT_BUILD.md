# Qt 静态编译 GitHub Actions 使用指南

## 概述

本仓库包含用于编译多个 Qt 版本静态库的 GitHub Actions 工作流文件。支持以下配置：

| Qt 版本 | 编译器 | 架构 | 说明 |
|---------|--------|------|------|
| 5.6.3 | MinGW 4.9 | 32-bit | Windows XP 兼容 |
| 5.12.12 | MSVC 2015 | 32-bit | LTS 版本 |
| 5.12.12 | MSVC 2017 | 32-bit | LTS 版本 |
| 5.12.12 | MinGW 7.3 | 32-bit | LTS 版本 |
| 5.15.18 | MSVC 2019 | 32-bit | LTS 版本 |
| 5.15.18 | MinGW 8.1 | 32-bit | LTS 版本 |
| 6.5.3 | MSVC 2022 | 64-bit | Qt6 LTS 版本 |

## 工作流文件说明

### 1. `build-qt-single-test.yml` (推荐先测试这个)
- **用途**: 单个 Qt 版本测试编译
- **默认配置**: Qt 5.15.18 + MSVC 2019
- **预计时间**: 6-10 小时
- **适用场景**: 首次使用建议先运行此工作流测试

### 2. `build-qt-all-static.yml`
- **用途**: 批量编译所有 Qt 版本和编译器组合
- **构建数量**: 7 个独立构建任务
- **预计时间**: 每个任务 6-12 小时
- **适用场景**: 完整生产环境构建

## 使用方法

### 方法一：通过 GitHub Web 界面触发

1. 进入仓库的 **Actions** 标签页
2. 选择要运行的工作流：
   - `Build Qt Single Test (5.15 MSVC 2019)` - 测试用
   - `Build Qt All Static Versions` - 完整构建
3. 点击 **Run workflow** 按钮
4. 可选择特定 Qt 版本或编译器（对于全量构建）
5. 等待构建完成（可能需要数小时）
6. 在 **Artifacts** 部分下载编译好的 Qt 库

### 方法二：通过 Git 推送触发

```bash
# 推送到 main 分支会自动触发构建（如果配置了 push 触发）
git push origin main
```

## 自定义配置

### 修改要编译的 Qt 模块

编辑 `qt5-modules.txt` 文件，添加或移除需要编译的模块：

```
qtbase          # 核心模块（必须）
qtsvg           # SVG 支持
qtimageformats  # 额外图片格式
qttools         # 开发工具
qttranslations  # 翻译文件
qtwinextras     # Windows 扩展
# 添加其他需要的模块...
```

### 修改编译选项

编辑对应的工作流文件，调整以下参数：

- `QT_VERSION`: Qt 版本号
- `QT_SRC_URL`: 源码下载地址
- `QT_INSTALL_PREFIX`: 安装路径
- `make examples`: 是否编译示例（设为 `-nomake examples` 可跳过）
- `-skip <module>`: 跳过的模块

## 编译产物

每个构建任务会生成一个 ZIP 压缩包，包含：
- 静态库文件 (.lib 或 .a)
- 头文件
- qmake 工具
- 其他开发工具

### 产物位置
- GitHub Actions 页面 → 对应任务 → Artifacts 部分
- 保留期限：14 天

## 注意事项

1. **编译时间**: 
   - Qt 5.12/5.15 完整编译约需 6-10 小时
   - Qt 6.x 编译约需 8-12 小时

2. **GitHub Actions 限制**:
   - 免费账户每月 2000 分钟（约 33 小时）
   - 单个任务最长运行时间：24 小时
   - 建议在有足够配额时运行

3. **磁盘空间**:
   - 源码解压后约 5-10 GB
   - 编译产物约 2-5 GB（取决于模块数量）

4. **Windows XP 兼容性**:
   - 仅 Qt 5.6 + MinGW 4.9 组合支持 Windows XP
   - 其他版本需要 Windows 7 或更高版本

## 本地使用编译好的 Qt

下载并解压 Artifact 后：

1. 将解压目录添加到系统 PATH
2. 或在 Qt Creator 中添加该版本的 qmake：
   - Tools → Options → Kits → Qt Versions
   - 添加 `<install_dir>/bin/qmake.exe`

### CMake 项目使用

```cmake
set(CMAKE_PREFIX_PATH "D:/Qt/5.15.18_static/msvc2019")
find_package(Qt5 COMPONENTS Core Widgets REQUIRED)
```

### qmake 项目使用

```bash
D:/Qt/5.15.18_static/msvc2019/bin/qmake.exe your_project.pro
```

## 故障排除

### 构建失败常见原因

1. **下载超时**: Qt 源码较大（~500MB），可能下载失败
   - 解决：重新运行工作流

2. **编译错误**: 某些模块可能有平台兼容性问题
   - 解决：检查工作流日志，考虑跳过问题模块

3. **超时**: 编译时间超过设定限制
   - 解决：增加 `timeout-minutes` 值

### 获取帮助

查看 GitHub Actions 的详细日志输出，定位具体错误步骤。

## 许可证

Qt 源码遵循 LGPL v3 或 GPL 许可证，请遵守相应条款。
