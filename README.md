# template-esp32

Generic Rust template for ESP32 bare-metal projects using [esp-hal](https://github.com/esp-rs/esp-hal) and the [Embassy](https://embassy.dev/) async runtime.

Supports two targets:
- **ESP32** (Xtensa) — for prototyping on DevKit boards
- **ESP32-C3** (RISC-V) — for production on SuperMini boards

## Prerequisites

### 1. Espressif Rust toolchain

```bash
cargo install espup
espup install
```

This creates `~/export-esp.sh`. You need to source it before building because the ESP32 (Xtensa) target is not part of upstream LLVM — Espressif maintains a custom LLVM/Clang fork and a GCC cross-compiler. The export script adds these to your `PATH` and sets `LIBCLANG_PATH` so the linker and compiler can be found.

The Makefile sources this script automatically.

### 2. espflash

```bash
cargo install espflash
```

Used to flash firmware and monitor serial output.

## Usage

```bash
make build    # compile for ESP32 DevKit (Xtensa)
make flash    # compile and flash to ESP32 DevKit, then open serial monitor
make stop     # erase flash on /dev/ttyUSB0
```

## Cargo aliases

For more control, use the cargo aliases defined in `.cargo/config.toml`:

| Alias             | Target          | Description                        |
|-------------------|-----------------|------------------------------------|
| `build-devkit`    | ESP32 (Xtensa)  | Build release for DevKit           |
| `build-supermini` | ESP32-C3 (RISC-V) | Build release for SuperMini     |
| `run-devkit`      | ESP32 (Xtensa)  | Build, flash, and monitor DevKit   |
| `run-supermini`   | ESP32-C3 (RISC-V) | Build, flash, and monitor SuperMini |

Example: `cargo +esp run-supermini`

## Environment variables

The build script (`build.rs`) loads variables from `.env` at compile time using `env!()`. This lets you embed configuration (Wi-Fi credentials, API keys, etc.) into the firmware without hardcoding them in source.

1. Copy or edit `.env` in the project root:
   ```
   EXAMPLE_ENV_VAR=example
   ```
2. Reference them in Rust:
   ```rust
   const EXAMPLE_ENV_VAR: &str = env!("EXAMPLE_ENV_VAR");
   ```

The `.env` file is tracked by cargo — changes to it trigger a rebuild automatically.

## Project structure

```
.cargo/config.toml   # build targets, runners, and cargo aliases
.env                 # compile-time environment variables (loaded by build.rs)
build.rs             # linker script setup, dotenv loading, friendly error messages
Cargo.toml           # dependencies and feature flags per target
rust-toolchain.toml  # pins the esp toolchain
src/main.rs          # entry point (hello world)
Makefile             # build / flash / stop shortcuts
```
