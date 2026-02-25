# Pi ↔ Neovim RPC Flow (Nvim Side)

## What this owns
- Host RPC commands in Neovim
- External editor wrapper used by Pi

Files:
- `lua/jorge/pi_edit_rpc.lua`
- `bin/pi-nvim-editor`
- `lua/jorge/init.lua` (loads RPC module)

## Quick behavior model
1. Wrapper writes `requests/<id>.json`
2. Wrapper dispatches `PiEditOpen <id>` over `$NVIM`
3. Host opens target in a new tab and writes `acks/<id>.json` = `opened`
4. Finish edit (`:wq`, `:q!`, `:PiEditCommit`, `:PiEditAbort`)
5. Host writes final ack (`committed|aborted|error`)
6. Wrapper exits (`0|1|2`) and cleans state files

State root:
- `${XDG_STATE_HOME:-$HOME/.local/state}/pi-nvim-rpc`

## Host commands
- `:PiEditOpen {request_id}`
- `:PiEditCommit`
- `:PiEditAbort`

Buffer vars on Pi-edit buffers:
- `b:pi_edit_request_id`
- `b:pi_edit_written`
- `b:pi_edit_finalized`

## Expected outcomes
- `:wq` => committed
- `:q!` => aborted
- `:bd` / `:bd!` => aborted
- Finalized hidden Pi-edit buffers are wiped (should not linger)

## Fast health checks
```bash
# wrapper exists/executable
ls -l ~/.config/nvim/bin/pi-nvim-editor

# command registered in current host
nvim --server "$NVIM" --remote-expr "exists(':PiEditOpen')"

# inspect protocol files
find "${XDG_STATE_HOME:-$HOME/.local/state}/pi-nvim-rpc" -maxdepth 2 -type f
```

## Troubleshooting (short)

### 1) Opens nested local nvim instead of host tab
Cause: host unavailable (`$NVIM` missing/stale) or dispatch failed.
- Check `$NVIM` in Pi process context.
- Check host liveness:
  ```bash
  nvim --server "$NVIM" --remote-expr '1'
  ```
- If probe fails, fallback is expected.

### 2) Wrapper exits with code `2`
Common causes:
- malformed/unsupported ack JSON
- host died after `opened` and no final ack arrived
- request/ack validation failure

Check latest ack file `status/message` in state dir.

### 3) Draft buffer still visible after finish
Should be fixed by forced wipe after hidden finalization.
If encountered, run:
```vim
:ls
:bwipeout <bufnr>
```
and report repro steps.

### 4) Slow feeling on open
Current settings:
- open poll: 50ms
- open timeout: 3000ms
- dispatch-first (probe only on dispatch failure)

Tradeoff: lower latency vs more polling wakeups.

## Polling caveats + mitigation
Potential downside of 50ms polling:
- more CPU/battery churn during long waits or many concurrent wrappers

Mitigation options (if needed):
1. parse ack only when ack mtime changes
2. adaptive polling (fast open, slower final-wait)
3. add env/config override for poll interval
4. rollback to 100ms
