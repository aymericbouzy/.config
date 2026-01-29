function e2e {
	function stress {
		git-amend-or-commit "e2e=$1\niterations=${2:-3}\nwipe_state=${WIPE_STATE:-true}"
	}

	function trigger {
		local triggers=""

		local trigger_map=(
			"pg" "trigger-run-backend-e2e-tests-against-postgres"
			"front" "trigger-frontend-e2e"
			"s2" "trigger-backend-e2e-singlestore"
			"ar-precomputed" "trigger-backend-e2e-ar-precomputed"
			"multi" "trigger-backend-e2e-multi-location"
			"okta" "trigger-okta-frontend-e2e-tests"
			"third-party" "trigger-test-third-party-integration"
			"e2e-third-party" "trigger-backend-e2e-third-party"
			"skip" "bypass-mandatory-back-e2e"
			"front-preview" "trigger-frontend-pr-preview"
		)

		for arg in "$@"; do
			is_known_trigger=false
			for i in {1..${#trigger_map[@]}}; do
				if [[ "${trigger_map[$i]}" == "$arg" ]]; then
					if [[ -n "$triggers" ]]; then
						triggers+=","
					fi
					triggers+="${trigger_map[$((i + 1))]}"
					is_known_trigger=true
					break
				fi
			done

			if [[ "$is_known_trigger" = false ]]; then
				echo "Unknown trigger: $arg"
				return 1
			fi
		done

		git-amend-or-commit "triggers=$triggers"
	}

	"$@"
}

export MONOREPO_PATH="$HOME/Dev/monorepo"

export PATH="$PATH:$MONOREPO_PATH/bin"
source <(toner completion zsh)

function morning {
	# Pigment monorepo
	cd "$MONOREPO_PATH"

	# git sync
	g fetch
	g ff master

	# backend build
	d build apps/all.sln

	# frontend build
	cd apps/Front
	npm install
	npm run generate
	npm run build

	# install updates
	brew upgrade

	# toner
	toner self-update

	cd "$MONOREPO_PATH"
}
