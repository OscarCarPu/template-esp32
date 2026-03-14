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
# DevKit (ESP32 / Xtensa) — serial on /dev/ttyUSB0
make build            # compile
make flash            # compile, flash, and open serial monitor
make stop             # erase flash

# SuperMini (ESP32-C3 / RISC-V) — serial on /dev/ttyACM0
make build-supermini  # compile
make flash-supermini  # compile, flash, and open serial monitor
make stop-supermini   # erase flash
```

## Target differences

| | ESP32 DevKit (Xtensa) | ESP32-C3 SuperMini (RISC-V) |
|---|---|---|
| **Cargo target** | `xtensa-esp32-none-elf` | `riscv32imc-unknown-none-elf` |
| **Feature flag** | `esp32` | `esp32c3` |
| **Serial port** | `/dev/ttyUSB0` (USB-UART bridge) | `/dev/ttyACM0` (built-in USB CDC) |
| **Linker** | Espressif GNU ld | `rust-lld` |
| **RTOS init** | `esp_rtos::start(timer)` | `esp_rtos::start(timer, software_interrupt)` — RISC-V requires a `SoftwareInterrupt<0>` |
| **Linker error hints** | `--error-handling-script` provides friendly messages | Skipped (unsupported by `rust-lld`) |

The cargo aliases use `--no-default-features` to prevent both chip features from being enabled at the same time (the default feature is `esp32`).

## Cargo aliases

For more control, use the cargo aliases defined in `.cargo/config.toml`:

| Alias             | Target          | Description                        |
|-------------------|-----------------|------------------------------------|
| `build-devkit`    | ESP32 (Xtensa)  | Build release for DevKit           |
| `build-supermini` | ESP32-C3 (RISC-V) | Build release for SuperMini     |
| `run-devkit`      | ESP32 (Xtensa)  | Build, flash, and monitor DevKit   |
| `run-supermini`   | ESP32-C3 (RISC-V) | Build, flash, and monitor SuperMini |

Example: `cargo +esp run-supermini`

## WiFi

The template connects to a WiFi network on boot using embassy-net (DHCP, DNS, TCP). Set your credentials in `.env`:

```
WIFI_SSID=your_ssid
WIFI_PASSWORD=your_password
```

On startup the firmware will:
1. Connect to the configured WiFi network (auto-reconnects on disconnect)
2. Obtain an IP address via DHCP
3. Ping google.com every 5 seconds via TCP connect as a connectivity check

## Environment variables

The build script (`build.rs`) loads variables from `.env` at compile time using `env!()`. This lets you embed configuration (Wi-Fi credentials, API keys, etc.) into the firmware without hardcoding them in source.

1. Copy `.env.example` to `.env` and fill in your values:
   ```
   WIFI_SSID=your_ssid
   WIFI_PASSWORD=your_password
   ```
2. Reference them in Rust:
   ```rust
   const WIFI_SSID: &str = env!("WIFI_SSID");
   ```

The `.env` file is tracked by cargo — changes to it trigger a rebuild automatically.

## Project structure

```
.cargo/config.toml   # build targets, runners, and cargo aliases
.env.example         # template for .env (copy and fill in your values)
.env                 # compile-time environment variables (loaded by build.rs, git-ignored)
build.rs             # linker script setup, dotenv loading, friendly error messages
Cargo.toml           # dependencies and feature flags per target
rust-toolchain.toml  # pins the esp toolchain
src/main.rs          # entry point (hello world)
Makefile             # build / flash / stop shortcuts
```
