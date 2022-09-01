echo "start build yoyo.app"
flutter build macos --release
echo "cp yoyo.app to /Applications"
cp -rf build/macos/Build/Products/Release/yoyo.app /Applications