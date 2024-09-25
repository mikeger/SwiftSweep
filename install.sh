#!/bin/bash -e

CUR=$PWD

# Build for macOS universal
echo "** Clean/Build..."
rm -rf .build
swift build -c release --arch arm64 --arch x86_64

echo "** Install..."
cd .build/apple/Products/Release
tar -cvzf swift-sweep.tar.gz swift-sweep
mv swift-sweep.tar.gz "$CUR"

cd "$CUR"
echo "** Output file is swift-sweep.tar.gz"
echo "** Done."
