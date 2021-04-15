.PHONY: deploy{,-sandbox,-staging,-production} {diff,debug}-deploy-{sandbox,staging} check-env

GIT_BRANCH=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`

diff-deploy-sandbox:
	helm diff upgrade ${PROJ_REPO} . --values values_sandbox.yaml

debug-deploy-sandbox:
	helm upgrade ${PROJ_REPO} --dry-run --debug . --values values_sandbox.yaml

diff-deploy-staging:
	helm diff upgrade ${PROJ_REPO} . --values values_staging.yaml

debug-deploy-staging:
	helm upgrade ${PROJ_REPO} --dry-run --debug . --values values_staging.yaml


deploy-production: export ENVIRONMENT := production
deploy-production: deploy

deploy-staging: export ENVIRONMENT := staging
deploy-staging: deploy

deploy-sandbox: export ENVIRONMENT := sandbox
deploy-sandbox: deploy
	echo "Check https://github.com/PaackEng/${PROJ_REPO}/actions?query=workflow%3ADeploy"

deploy:
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
		-H "Accept: application/vnd.github.ant-man-preview+json"  \
		-H "Content-Type: application/json" \
		https://api.github.com/repos/PaackEng/${PROJ_REPO}/deployments \
		--data '{"ref": "'${GIT_BRANCH}'", "required_contexts": [], "environment": "${ENVIRONMENT}", "auto_merge": false}'

check-env:
ifndef PROJ_REPO
  $(error PROJ_REPO is undefined)
endif
