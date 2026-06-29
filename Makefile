.PHONY: help get gen clean format fix analyze lint test slang-analyze check-all fix-all build build-split build-debug build-aab run release changelog bump release _update_changelog _update_version

APP_NAME := ztime_widget

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

get: ## flutter pub get
	flutter pub get

gen: ## Run code generation (build_runner + slang)
	dart run build_runner build -d
	dart run slang

clean: ## Clean build cache
	flutter clean
	flutter pub get

format: ## dart format (exit if unformatted)
	dart format --set-exit-if-changed lib/ test/

fix: ## dart fix --apply
	dart fix --apply

analyze: ## flutter analyze
	flutter analyze

lint: ## Check hardcoded strings
	dart hack/check_hardcoded_strings.dart lib/

test: ## Run tests
	flutter test

slang-analyze: ## Check translations (missing/unused keys, full source scan)
	dart run slang analyze --full

check-all: format analyze lint slang-analyze test ## Format + Analyze + Lint + Slang + Test

fix-all: format fix analyze ## Format + Fix + Analyze

build: build-split ## Alias for build-split

build-split: _update_version _update_changelog ## Build split APKs per ABI (arm64, arm, x86_64)
	flutter build apk --split-per-abi --release

build-debug: _update_version _update_changelog ## Build debug APK (universal)
	flutter build apk --debug

build-aab: _update_version _update_changelog ## Build release AAB (for Play Store)
	flutter build appbundle --release

run: ## Run on connected device
	flutter run

# === Version Management ===

_update_changelog: ## Regenerate CHANGELOG.md (internal, called by build targets)
	@git-cliff --output CHANGELOG.md 2>/dev/null || true

_update_version: ## Bump patch + build number in pubspec.yaml (internal)
	@NEW_VER=$$(awk 'BEGIN{ \
		getline l<"pubspec.yaml"; \
		gsub(/version: /,"",l); \
		n=split(l,s,"+"); \
		v=s[1]; b=s[2]; \
		n=split(v,d,"."); \
		p=d[3]+1; t=""; \
		c="git tag -l v* 2>/dev/null | head -1"; c|getline t; close(c); \
		nv="1.0."p; \
		if(t!=""){ \
			c="git-cliff --bumped-version 2>/dev/null | tr -d v"; c|getline g; close(c); \
			if(g!=""&&g!=v) nv=g \
		}; print nv \
	}'); \
	BUILD=$$(git rev-list --count $$(git tag -l 'v*' 2>/dev/null | head -1)..HEAD 2>/dev/null); \
	[ -z "$$BUILD" ] || [ "$$BUILD" -eq 0 ] && BUILD=1; \
	CUR=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}'); \
	echo "Version: $$CUR → $$NEW_VER+$$BUILD"; \
	awk -v nv="$$NEW_VER" -v nb="$$BUILD" '{ \
		gsub(/version: .*/,"version: "nv"+"nb); \
	}1' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml

changelog: ## Generate CHANGELOG.md from git history
	git-cliff --output CHANGELOG.md
	prettier --write CHANGELOG.md

bump: ## Bump version, commit + tag for release
	@VERSION=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}' | cut -d'+' -f1); \
	BUILD=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}' | cut -d'+' -f2); \
	echo "Tagging v$$VERSION (build $$BUILD)"; \
	git add pubspec.yaml CHANGELOG.md; \
	git commit -m "chore(release): v$$VERSION+$$BUILD" --allow-empty; \
	git tag -a "v$$VERSION" -m "Release v$$VERSION (build $$BUILD)"; \
	echo "Tagged v$$VERSION"

release: ## Full release: check + changelog + version + tag
	@$(MAKE) check-all
	@$(MAKE) changelog
	@$(MAKE) bump
	@echo ""
	@echo "Release done! Push: git push && git push --tags"
