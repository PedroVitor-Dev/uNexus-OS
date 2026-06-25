# uNexus AI - Local Assistant Architecture

uNexus AI is designed as a local-only assistant for OS usage, gaming setup,
GPU drivers, performance tuning and recovery guidance.

The core rule is architectural: there is no remote AI provider, no telemetry
path and no cloud fallback. If the local engine is unavailable, the feature
reports that it is unavailable.

## Components

```text
AIAssistantPanel.qml
        |
        v
AIAssistant C++ backend
        |
        v
AIEngine C++ process wrapper
        |
        v
llama-server on 127.0.0.1 + local .gguf model
```

## Privacy Guarantees

| Risk | Mitigation |
|---|---|
| Prompts sent to cloud AI | No cloud API code exists in the assistant backend. |
| Engine exposed on LAN | `AIEngine` hard-codes `--host 127.0.0.1`. |
| Automatic model downloads | Models are never downloaded automatically. |
| Unverified model downloads | `scripts/setup-ai-model.sh` refuses curated downloads without a pinned SHA-256. |
| Silent system inspection | Hardware/system context is opt-in and defaults to disabled. |
| Persistent chat logs | History is memory-only by default; disk persistence is opt-in. |

## Runtime Behavior

`AIAssistant` talks only to:

```text
http://127.0.0.1:<random-port>/v1/chat/completions
```

The port is chosen by probing loopback only. `AIEngine` also removes common
proxy environment variables before launching `llama-server`.

The current implementation parses OpenAI-compatible Server-Sent Events from
`llama-server` and streams tokens into `AIAssistantPanel.qml`.

## User Controls

Settings > uNexus AI exposes:

- `Let AI read system stats`: default off. When enabled, the prompt can include
  local CPU/RAM/GPU usage, GPU temperature availability and Game Mode state.
- `Save AI chat history`: default off. When enabled, history is stored under
  `~/.local/share/unexus/ai/history.txt` with owner-only permissions.
- `Wipe AI history now`: clears in-memory history and removes the local history
  file.

## Model Lifecycle

No model is bundled by default in this MVP.

The user can either:

- point the UI at an existing local `.gguf` file;
- run `setup-ai-model.sh --local /path/to/model.gguf`;
- use a curated model key only after the repository has a real pinned SHA-256.

Curated downloads intentionally fail while their checksum is a placeholder.

## Next Hardening Steps

- Run `llama-server` under `bwrap` or `firejail` with no network namespace.
- Replace loopback HTTP with a Unix domain socket when supported by the engine.
- Add a model manager UI with installed model list, size and delete action.
- Encrypt opt-in disk history before considering it production-ready.
