up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

gen:
	docker compose exec -w /wks terraform bash -c '. /wks/.auth/env && for f in $$(find /wks -maxdepth 3 -type f -name "*.j2"); do j2 $${f} > $${f/.j2/} ; done'

init:
	docker compose exec terraform bash -c '. /wks/.auth/env && terraform -chdir=/wks/main-$(filter-out $@,$(MAKECMDGOALS)) init -upgrade'

plan:
	docker compose exec terraform bash -c '. /wks/.auth/env && terraform -chdir=/wks/main-$(filter-out $@,$(MAKECMDGOALS)) plan'

apply:
	docker compose exec terraform bash -c '. /wks/.auth/env && terraform -chdir=/wks/main-$(filter-out $@,$(MAKECMDGOALS)) apply'

refresh:
	docker compose exec terraform bash -c '. /wks/.auth/env && terraform -chdir=/wks/main-$(filter-out $@,$(MAKECMDGOALS)) refresh'

destroy:
	docker compose exec terraform bash -c '. /wks/.auth/env && terraform -chdir=/wks/main-$(filter-out $@,$(MAKECMDGOALS)) destroy'

docs:
	docker compose exec terraform bash -c 'for f in $$(find /wks -maxdepth 4 -type f -name "header.md"); do cd $${f/header.md/} && terraform-docs markdown table --config /wks/.terraform-docs.yml --output-file README.md  $${f/header.md/} ; done;'

tfsec:
	docker compose exec terraform bash -c 'for f in $$(find /wks -maxdepth 2 -type f -name "terraform.tfvars"); do tfsec $${f/terraform.tfvars/} ; done;'

exec:
	docker compose exec -it -w /wks terraform bash

dep:
	docker compose exec -it -w /wks terraform bash -c 'cat /wks/main-$(filter-out $@,$(MAKECMDGOALS))/.terraform/modules/modules.json | jq'
%: # Unknown targets