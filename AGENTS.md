# Repository Guidelines

## Project Goals & Experience
Mini Music is a SwiftUI player for kids: it mirrors songs already downloaded in the Music app (Apple Music now, Spotify later) and never ships its own catalog. Tapping artwork queues the full library through `SystemMusicPlayer.shared`, waits for playback before re-enabling, and keeps controls minimal so kids stay in the curated flow.

## Project Structure & Module Organization
The Xcode workspace lives under `Mini Music/` and defines three targets: the SwiftUI app (`Mini Music/Mini Music`), unit tests (`Mini Music/Mini MusicTests`), and UI tests (`Mini Music/Mini MusicUITests`). Shared UI like `ContentView.swift`, `SongItemView.swift`, and the `MusicLibraryViewModel.swift` live alongside `Mini_MusicApp.swift`. App assets (icons, artwork) belong in `Assets.xcassets`; keep audio or sample data out of the repo to avoid App Store review issues.

## Libraries
This app targets iOS 26. This app uses Apple's SwiftUI and MusicKit library. Use context7 to reference any related docs.

## Build, Test, and Development Commands
Open the project in Xcode with `xed Mini\ Music/Mini\ Music.xcodeproj`.

## Coding Style & Naming Conventions
Follow Swift API Design Guidelines: PascalCase types (`SongItemView`), camelCase properties and methods, and 4-space indents. Keep SwiftUI views small and composable; prefer computed `var body` extractions over long `switch` blocks. Place async MusicKit calls inside `Task` blocks and gate UI updates on `@State`/`@StateObject` so rendering stays deterministic.

## Testing Guidelines
Unit tests rely on the Swift Testing module (`import Testing`); name files `<Feature>Tests.swift` and test functions as `test<Scenario>()`. UI tests remain in XCTest—tag critical navigation flows inside `Mini_MusicUITests.swift` and keep launch-performance checkpoints alongside behavior tests.

## Commit & Pull Request Guidelines
Git history favors short, imperative subjects (e.g., `Init app`), so keep messages under ~55 characters. Each PR should describe the feature or fix, list simulator/device targets tested, and include screenshots whenever UI changes touch `ContentView`. Link related issues, note new entitlements or capabilities, and call out manual test steps so reviewers can reproduce MusicKit flows quickly.

## Security & Configuration Tips
Never commit MusicKit tokens or user credentials; manage them via Xcode Signing & Capabilities and the Apple Developer portal. If you must log errors, prefer `print` behind `#if DEBUG` so playback state stays private in release builds.

## MCPs

Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.
