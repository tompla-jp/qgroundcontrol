# Repository layout

This document captures the agreed directory roles and the gitignore policy for this repo.

## Core source
- src/: C++/QML application source
- resources/: static assets (images, icons, shaders, etc.)
- translations/: Qt .ts translation sources used by builds
- qgcresources.qrc, qgcimages.qrc, qgroundcontrol.qrc: resource manifests

## Build system and platform config
- CMakeLists.txt, cmake/: CMake build configuration and modules
- CMakePresets.json, _CMakePresets.json: CMake presets
- android/: Android Gradle project and wrapper
- deploy/: packaging and installer scripts
- tools/: helper scripts and developer utilities

## Docs, QA, and CI
- docs/: documentation sources
- test/: tests
- .github/: CI workflows and actions
- CHANGELOG.md, LICENSE*, README.md: project metadata

## Customization
- custom/: custom build overrides
- custom-example/: reference customizations

## Local/generated artifacts (ignore)
- build*/, cmake-build-*/: build outputs
- android/.gradle/, android/local.properties, android/keystore.properties: local Android artifacts
- .venv/, node_modules/, .vscode/, .idea/: local environments and editor settings
- *.apk, *.aab, *.apks, *.idsig, *.app: built packages
- *.jks, *.keystore: signing keys (keep local)
- qgroundcontrol.zip, qgc_startup*.log*: local artifacts and logs

## Notes on ambiguous items
- qgroundcontrol.zip: no in-repo references found; treat as a local artifact unless a workflow proves otherwise.
- 2/: contains a copy of translations; files are tiny placeholders vs translations/ (e.g., qgc_json_ja_JP.ts is 205 bytes in 2/ vs 261,593 bytes in translations/), and no in-repo references found.
