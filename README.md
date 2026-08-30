# 🛸 Zig Invaders

A high-performance, retro arcade Space Invaders clone written in **Zig** and powered by the **Raylib** game engine (via `raylib-zig`).

Features structured gameplay states (Home Screen, Active Gameplay, Game Over), dynamic movement patterns for invaders, bullet physics, collision detection, and score tracking—all compiled natively to machine code with zero external runtime dependencies.

---

## 🎬 Gameplay Demonstration

A recorded gameplay preview is available under the `assets` folder. You can play it using any media player:

![`assets/zig-invaders-gameplay.gif`](./assets/zig-invaders-gameplay.gif)

---

## 🕹️ Game Controls

| Action | Control Key | Screen |
| :--- | :--- | :--- |
| **Start Game** | `[space]` | Home Screen |
| **Move Left** | `[<-]` (Left Arrow) | Gameplay |
| **Move Right** | `[->]` (Right Arrow) | Gameplay |
| **Fire Laser** | `[space]` | Gameplay |
| **Restart Game** | `[r]` | Game Over Screen |
| **Return to Home** | `[q]` | Game Over Screen |
| **Quit Game** | `[esc]` | Any Screen |

---

## 🛠️ Requirements & Setup

To build and run this game, you will need:
* **Zig Compiler**: Version `0.16.0` or later.
* **Raylib bindings**: Handled automatically by Zig's package manager (`build.zig.zon`).

---

## 🚀 How to Run Locally

To build and run the game on your native system:

```bash
zig build run
```

---

## 🖥️ Building & Cross-Compiling

Zig's built-in toolchain makes cross-compiling to other platforms incredibly easy with absolutely zero extra toolchains or SDKs needed.

### For Windows 🪟

Compile a native 64-bit Windows executable (`.exe`) from macOS, Linux, or Windows:

```bash
# Build a debug version
zig build -Dtarget=x86_64-windows

# Build a fully optimized release version (smaller size & faster execution)
zig build -Dtarget=x86_64-windows -Doptimize=ReleaseFast
```
*Output Binary:* `zig-out/bin/zig_invaders.exe`

### For macOS 🍏

Build optimized binaries targeting specific Apple CPU architectures:

```bash
# Target Apple Silicon Macs (M1, M2, M3, M4...)
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast

# Target Intel Macs
zig build -Dtarget=x86_64-macos -Doptimize=ReleaseFast
```
*Output Binary:* `zig-out/bin/zig_invaders`

### For Linux 🐧

```bash
zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast
```
*Output Binary:* `zig-out/bin/zig_invaders`

---

## 🧪 Testing

Run the included module and executable test suites in parallel using:

```bash
zig build test
```

---

## 📁 Project Structure

* `src/main.zig` - The entry point of the game, controlling state transitions, keyboard inputs, and rendering routines.
* `src/game_setup.zig` - Initializes the game loop entities (Player, Invaders, Bullets) and resets game state.
* `src/game_config.zig` - The centralized configuration file for sizing, padding, game speeds, and parameters.
* `src/components.zig` - Entity models and update/draw functions for the player, bullets, and invaders.
* `assets/` - Directory containing gameplay recordings and resources.
