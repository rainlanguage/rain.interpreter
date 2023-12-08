# Usage

All the commands assume that you are on `subgraph` folder.

1 - Install forge deps in root:

```bash
forge install --root ../ --shallow
```

2 - Install the subgraph submodules:

```bash
git submodule update --init --recursive --depth 1 rain.extrospection/
```

3 - Init the setup:

```bash
nix run .#init-setup 
```
