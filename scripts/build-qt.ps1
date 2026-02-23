# scripts/build-qt.ps1
param(
    [string]$QtVersion = "5.15.2",
    [string]$InstallDir = "C:\Qt\Static"
)

$ErrorActionPreference = "Stop"

# 1. 环境检查
Write-Host "=== 检查环境 ==="
if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Host "安装 Ninja..."
    choco install ninja -y
}

# 2. 下载源码
# Qt 5.15 和 Qt 6.x 的源码结构略有不同，这里采用通用性较好的 qtbase 单独克隆
# 对于生产环境，建议 Qt5 使用 init-repository，但为了 CI 速度，我们只克隆 qtbase (包含 Widgets, Sql, Json)
Write-Host "=== 下载 Qt 源码 (Version: $QtVersion) ==="
$SourceDir = "C:\qt-src"
if (Test-Path $SourceDir) { Remove-Item -Recurse -Force $SourceDir }

# 确定分支/标签
$Branch = "v$QtVersion"
if ($QtVersion -like "6.*") {
    $RepoUrl = "https://github.com/qt/qtbase.git"
} else {
    # Qt 5 有时候标签是 v5.15.2，有时候是 5.15.2，尝试通用处理
    $RepoUrl = "https://github.com/qt/qtbase.git"
}

git clone --depth 1 --branch $Branch $RepoUrl $SourceDir
if ($LASTEXITCODE -ne 0) { 
    # 如果 v 前缀失败，尝试无前缀 (Qt5 某些版本)
    git clone --depth 1 --branch $QtVersion $RepoUrl $SourceDir 
}

# 3. 配置编译选项
Write-Host "=== 配置 Qt (Static, Release, No Network/QML) ==="
Set-Location $SourceDir

# 核心配置参数
# -static: 静态库
# -release: 发布版
# -opensource -confirm-license: 自动同意协议
# -nomake examples/tests: 不编译示例和测试，节省大量时间
# -no-openssl: 不需要网络 SSL 功能
# -sql-sqlite: 启用 SQLite 支持 (内置)
# -skip: 跳过不需要的模块 (Qt6 语法)
$ConfigureArgs = @(
    "-static",
    "-release",
    "-opensource",
    "-confirm-license",
    "-nomake", "examples",
    "-nomake", "tests",
    "-no-openssl",
    "-sql-sqlite",
    "-prefix", $InstallDir,
    "-install-prefix", $InstallDir
)

# Qt 6 需要额外跳过一些模块以加快速度
if ($QtVersion -like "6.*") {
    $ConfigureArgs += "-skip", "qtshadertools"
    $ConfigureArgs += "-skip", "qttranslations"
}

# 执行配置
Write-Host "Running: configure.bat $ConfigureArgs"
./configure.bat $ConfigureArgs
if ($LASTEXITCODE -ne 0) { throw "Qt Configure Failed" }

# 4. 编译
Write-Host "=== 开始编译 (使用 Ninja) ==="
# 使用 ninja 比 nmake 快很多
ninja
if ($LASTEXITCODE -ne 0) { throw "Qt Build Failed" }

# 5. 安装
Write-Host "=== 安装到 $InstallDir ==="
ninja install
if ($LASTEXITCODE -ne 0) { throw "Qt Install Failed" }

# 6. 清理 (保留安装目录，删除源码以节省空间)
Set-Location C:\
Remove-Item -Recurse -Force $SourceDir
Write-Host "=== 编译完成 ==="