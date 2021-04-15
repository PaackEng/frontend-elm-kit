# frontend-elm-kit

## Install instructions

In a repository which only contents are the `assets/ devops/ mock-server/ src/ README.md`, run:

```bash
git remote add -f frontend-elm-kit git@github.com:PaackEng/frontend-elm-kit.git
git subtree add --prefix=frontend-elm-kit frontend-elm-kit --squash
ln -s frontend-elm-kit/github ./.github
ln -s frontend-elm-kit/.{gitignore,editorconfig,tool-versions} ./
git add .github .gitignore
git commit -m 'Add syslinks'
```

## Update instructions

Run:

```sh
git subtree pull --prefix=frontend-elm-kit frontend-elm-kit main --squash
```

## Running instructions

Do what you're used to, but inside `frontend-elm-kit` directory. E.g.:

```sh
cd frontend-elm-kit
yarn run review
yarn run build
```

## Deploy instructions

Use the environment variable `PROJ` to indicate what project you're deploying.

```sh
PROJ=lmo-web make deploy-staging
```
