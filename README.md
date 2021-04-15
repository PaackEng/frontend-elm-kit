# frontend-elm-kit

## Install instructions

In a repository which only contents are the `assets/ devops/ mock-server/ src/ README.md`, run:

```sh
git remote add -f frontend-elm-kit git@github.com:PaackEng/frontend-elm-kit.git
git subtree add --prefix ./frontend-elm-kit frontend-elm-kit --squash
ln -s frontend-elm-kit/github ./.github
ln -s frontend-elm-kit/.gitignore ./
git add .github .gitignore
git commit -m 'Add syslinks'
```

## Update instructions

Run:

```sh
git pull -s subtree frontend-elm-kit main
```
