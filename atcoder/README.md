# atcoder

AtCoder competitive programming environment with Nix.

## Setup

```bash
cd ~/atcoder
nix develop --impure
```

First time only: login via browser cookie.

```bash
setup
```

## Tools

| Command | Description |
|---------|-------------|
| `cpprun` | compile & run C++ (auto-detect) |
| `cpprun -t` | run sample tests |
| `cpprun -d` | debug build with sanitizers |
| `cpprun -k` | keep binary after run |
| `setup` | login via browser (aclogin) |
| `chelp` | show help |
| `acc new <id>` | create contest dir |
| `acc submit` | submit solution |
| `oj test` | official test runner |

## Flow

```
nix develop --impure
acc new abc123 --choice all
cd abc123/a
# write code
cpprun -t
acc submit
```
