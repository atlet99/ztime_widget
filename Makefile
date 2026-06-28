.PHONY: help get gen clean format fix analyze lint test slang-analyze check-all fix-all build build-split build-debug build-aab run release changelog bump release _update_changelog

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

build-split: _update_changelog ## Build split APKs per ABI (arm64, arm, x86_64)
	flutter build apk --split-per-abi --release

build-debug: _update_changelog ## Build debug APK (universal)
	flutter build apk --debug

build-aab: _update_changelog ## Build release AAB (for Play Store)
	flutter build appbundle --release

run: ## Run on connected device
	flutter run

# === Version Management ===

_update_changelog: ## Regenerate CHANGELOG.md (internal, called by build targets)
	@git-cliff --output CHANGELOG.md 2>/dev/null || true

changelog: ## Generate CHANGELOG.md from git history
	git-cliff --output CHANGELOG.md
	prettier --write CHANGELOG.md

bump: ## Bump version from commits + update pubspec.yaml
	@NEW_VERSION=$$(git-cliff --bumped-version 2>/dev/null | tr -d 'v'); \
	if [ -z "$$NEW_VERSION" ]; then \
		echo "No version bump needed"; \
		exit 0; \
	fi; \
	CURRENT_VERSION=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}' | cut -d'+' -f1); \
	BUILD_NUM=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}' | cut -d'+' -f2); \
	NEW_BUILD=$$$$(($$$${BUILD_NUM:-0} + 1)); \
	echo "Bumping $$CURRENT_VERSION → $$NEW_VERSION+$$NEW_BUILD"; \
	sed -i '' "s/version: .*/version: $$NEW_VERSION+$$NEW_BUILD/" pubspec.yaml; \
	git add pubspec.yaml; \
	git commit -m "chore(release): prepare for v$$NEW_VERSION"; \
	git tag -a "v$$NEW_VERSION" -m "Release v$$NEW_VERSION"; \
	echo "Tagged v$$NEW_VERSION"

release: changelog ## Full release: changelog + bump + tag
	@$(MAKE) bump
	@echo ""
	@echo "Release complete! Push with: git push && git push --tags"
