# Idler

A tiny macOS menu bar app that keeps your Mac awake. One click to prevent sleep — no more interrupted downloads, builds, or long-running processes.

> Rewrite of the [original Go version](https://github.com/alexrett/idler) in Swift — native SwiftUI, zero dependencies, single binary.

<p align="center">
  <img src="screenshots/sleep-allowed.png" width="240" alt="Sleep allowed">
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/sleep-prevented.png" width="240" alt="Sleep prevented">
</p>

## Why?

Corporate-managed Macs often enforce aggressive sleep policies that you can't override in System Settings. Your screen locks after a few minutes, your Slack/Teams status flips to "Away", and colleagues think you disappeared — even though you just stepped out for coffee while a build is running.

You could use `caffeinate` in the terminal, but that's easy to forget and annoying to manage. Idler is simpler — one click in the menu bar, and your Mac stays awake. Your messenger stays green, your screen stays on, and your long-running processes don't get interrupted.

## How It Works

When activated, Idler:
1. Creates IOKit power assertions to prevent both **system sleep** and **display sleep**
2. Simulates user activity every 30 seconds
3. Performs imperceptible mouse nudges (1 pixel) to defeat idle detection

When deactivated, all assertions are released and your Mac sleeps normally.

## Features

- **One-click toggle** — `moon.zzz` / `bolt` icons right in the menu bar
- **Prevents both system and display sleep** via IOKit power management
- **Activity simulation** every 30 seconds — keeps Slack green too
- **No dock icon** — lives quietly in the menu bar
- **Native macOS** — SwiftUI, single binary (~300KB), zero dependencies

## Install

### Download

Grab the latest `Idler.dmg` from [Releases](https://github.com/alexrett/idler2/releases).

Signed and notarized with Apple Developer ID.

### Build from Source

```bash
git clone https://github.com/alexrett/idler2.git
cd idler2
swift build -c release
open .build/release/Idler
```

Universal binary (Intel + Apple Silicon):

```bash
swift build -c release --arch arm64 --arch x86_64
```

## Usage

1. Launch Idler — look for 🌙 in the menu bar
2. Click it → **Prevent Sleep** — icon changes to ⚡
3. Click again → **Allow Sleep** — back to 🌙
4. That's it

## Requirements

- macOS 13.0 (Ventura) or later
- Works on both Apple Silicon and Intel Macs

## License

MIT
