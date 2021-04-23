# frontend-elm-kit

## Install instructions

```bash
git remote add -f frontend-elm-kit git@github.com:PaackEng/frontend-elm-kit.git
git subtree add --prefix=frontend-elm-kit frontend-elm-kit main --squash
```

**Note**: remember to add `frontend-elm-kit` to ignored lists in linters.

## Update instructions

Run:

```sh
git fetch frontend-elm-kit
git subtree pull --prefix=frontend-elm-kit frontend-elm-kit main --squash
```
