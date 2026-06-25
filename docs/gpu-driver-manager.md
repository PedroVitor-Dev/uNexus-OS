# GPU Driver Manager

The GPU Driver Manager is the first-login path for reducing NVIDIA/AMD driver friction after installing uNexus on real hardware.

## Current Integration

Files:

- `packages/unexus-shell/include/gpudrivermanager.h`
- `packages/unexus-shell/src/gpudrivermanager.cpp`
- `packages/unexus-shell/qml/GpuDriverPanel.qml`
- `scripts/unexusctl.sh`
- `packaging/linux/io.github.PedroVitorDev.uNexusDriverManager.policy`

The C++ manager is exposed to QML as `gpuDriverManager` and registers the `GpuDriverManager` enum under `UNexus.System 1.0`.

`GpuDriverPanel.qml` is plugged into First Setup so the first login can detect the GPU, show the active driver and offer the correct action without opening a terminal.

## Behavior

| Vendor | Driver state | uNexus action |
|---|---|---|
| AMD | `amdgpu` / Mesa path | Report ready; recommend Mesa and Vulkan packages |
| Intel | `i915` / Mesa path | Report ready; recommend Mesa, Vulkan and media packages |
| NVIDIA | `nvidia` active | Report ready |
| NVIDIA | `nouveau` or no active NVIDIA driver | Offer `nvidia-dkms nvidia-utils lib32-nvidia-utils` through `pkexec unexusctl driver-apply --yes` |

Hybrid GPU systems are detected when multiple VGA/3D/display controllers exist. If NVIDIA is present, uNexus prioritizes it for the driver decision and tells the user a hybrid system was detected.

Secure Boot is detected through `mokutil --sb-state` when available, with an EFI variable fallback. When Secure Boot is active, the panel warns that NVIDIA DKMS modules may need signing or Secure Boot may need to be disabled.

## Rollback Model

The panel does not call `pacman` directly. It delegates privileged changes to:

```sh
unexusctl driver-apply --yes
```

That backend records installed packages before the change, installs the target package set, enables `unexus-driver-rollback.service` and waits for the next successful uNexus boot to confirm the driver switch.

If the next boot does not confirm in time, the systemd rollback guard runs:

```sh
unexusctl driver-rollback --boot
```

## Still Required For Production Confidence

- Test `nouveau -> nvidia-dkms` on real NVIDIA hardware.
- Test hybrid Intel/NVIDIA hardware.
- Record AMD and Intel detection results in `docs/test-results/`.
- Validate Secure Boot messaging on a Secure Boot enabled machine.
- Add screenshots after the panel is verified on the Arch/Hyprland test machine.
