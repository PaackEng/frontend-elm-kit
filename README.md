# frontend-elm-kit

## Install instructions

In a repository which only contents are the `assets/ devops/ mock-server/ src/ README.md`, run:

```bash
git remote add -f frontend-elm-kit git@github.com:PaackEng/frontend-elm-kit.git
git subtree add --prefix=frontend-elm-kit frontend-elm-kit main --squash

ln -s frontend-elm-kit/github ./.github
ln -s frontend-elm-kit/.{editorconfig,tool-versions} ./
echo 'frontend-elm-kit/' .gitignore
git add .github .gitignore .editorconfig .tool-versions
git commit -m 'Add syslinks'
```

## Update instructions

Run:

```sh
git fetch frontend-elm-kit
git subtree pull --prefix=frontend-elm-kit frontend-elm-kit main --squash
```

## Running instructions

Do what you're used to, but inside `frontend-elm-kit` directory. E.g.:

```sh
cd frontend-elm-kit
yarn install --check-files
yarn run review
yarn run build
```

## Deploy instructions

Use the environment variable `PROJ` to indicate what project you're deploying.

```sh
PROJ=lmo-web make deploy-staging
```

## Graphql generation instructions

Add the sub path and a sub module to a file called `graphql.env`. E.g.:

```sh
# Will search schemas file in ../schemas/graphql/${GQL_PATH}/schema.graphql
GQL_PATH=lmo
# Will import modules as `import Schemas.${GQL_MODULE}.Scalar as Scalar`
GQL_MODULE=LMO

```

