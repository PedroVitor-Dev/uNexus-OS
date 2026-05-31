# Building PED OS

This guide explains how to build and run PED OS components from source.

---

## Requirements

| Dependency | Version | Install |
|---|---|---|
| Linux | any distro | — |
| CMake | 3.20+ | `sudo apt install cmake` |
| Qt6 | 6.x | `sudo apt install qt6-base-dev qt6-declarative-dev` |
| GCC / G++ | 12+ | `sudo apt install build-essential` |
| Git | any | `sudo apt install git` |

---

## Quick Setup (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y build-essential cmake git qt6-base-dev qt6-declarative-dev libqt6qml6
```

---

## Clone the Repository

```bash
git clone https://github.com/PedroVitor-Dev/Ped-Os.git
cd Ped-Os
```

---

## Building ped-shell

```bash
cd packages/ped-shell
cmake -B build
cmake --build build
```

---

## Running ped-shell

```bash
./build/ped-shell
```

Default password: `1234` (or leave blank)

---

## Updating

```bash
git pull
cd packages/ped-shell
rm -rf build
cmake -B build
cmake --build build
./build/ped-shell
```

---

## Gaming Dependencies (coming soon)

Future versions will require:

```bash
# Steam
sudo apt install steam

# Lutris
sudo apt install lutris

# Vulkan
sudo apt install vulkan-tools mesa-vulkan-drivers

# GameMode
sudo apt install gamemode
```

---

## Troubleshooting

**CMake can't find Qt6:**
```bash
sudo apt install qt6-base-dev qt6-declarative-dev
```

**libEGL / MESA warnings:**
Normal in virtual machines. Does not affect functionality.

**`./build/ped-shell: No such file or directory`:**
Build failed. Run `cmake --build build` again and check for errors.

**Battery shows 100% on VM:**
Expected behavior. Battery reading requires real hardware.

---

<sub>More components will be added as the project grows.</sub>