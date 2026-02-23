@echo off
setlocal EnableDelayedExpansion

set QT_VERSION=%1
set QT_INSTALL_DIR=%2
set BUILD_TYPE=%3
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Release

echo ========================================
echo Qt Version: %QT_VERSION%
echo Install Dir: %QT_INSTALL_DIR%
echo Build Type: %BUILD_TYPE%
echo ========================================

cd qt-src\qtbase

set CONFIGURE_OPTS=-static -release -opensource -confirm-license ^
    -prefix %QT_INSTALL_DIR% ^
    -nomake examples -nomake tests ^
    -no-opengl -no-dbus ^
    -no-feature-network -no-feature-http -no-feature-ssl ^
    -no-feature-qml -no-feature-quick ^
    -no-feature-sql -no-feature-sql-mysql -no-feature-sql-odbc ^
    -no-feature-printsupport -no-feature-printer ^
    -no-feature-accessibility -no-feature-gif -no-feature-ico ^
    -skip qt3d -skip qtactiveqt -skip qtandroidextras ^
    -skip qtcanvas3d -skip qtconnectivity -skip qtlocation ^
    -skip qtmacextras -skip qtpurchasing -skip qtquick3d ^
    -skip qtquickcontrols -skip qtquickcontrols2 ^
    -skip qtquicktimeline -skip qtremoteobjects ^
    -skip qtscript -skip qtscxml -skip qtsensors ^
    -skip qtserialbus -skip qtserialport -skip qtspeech ^
    -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel ^
    -skip qtwebengine -skip qtwebsockets -skip qtwebview ^
    -skip qtx11extras -skip qtxmlpatterns

echo Configuring Qt...
configure.bat %CONFIGURE_OPTS%
if errorlevel 1 exit /b 1

echo Building Qt...
nmake -j%NUMBER_OF_PROCESSORS%
if errorlevel 1 exit /b 1

echo Installing Qt...
nmake install
if errorlevel 1 exit /b 1

echo ========================================
echo Qt5 Static Build Complete!
echo ========================================

endlocal
