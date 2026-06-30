.PHONY: help get gen clean format fix analyze lint test slang-analyze check-all fix-all build build-split build-debug build-aab run release changelog bump bump-patch bump-minor bump-major _update_changelog _update_version

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

format-check: ## dart format (exit if unformatted)
	dart format --set-exit-if-changed lib/ test/

format:
	dart format lib/ test/

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

check-all: format-check analyze lint slang-analyze test ## Format + Analyze + Lint + Slang + Test

fix-all: format fix analyze ## Format + Fix + Analyze

build: build-tagged ## Alias for build-tagged

build-split: ## Build split APKs per ABI (no version bump)
	flutter build apk --split-per-abi --release

build-release: ## Build release APK universal (no version bump)
	flutter build apk --release

build-debug: ## Build debug APK (no version bump)
	flutter build apk --debug

build-aab: ## Build release AAB (no version bump)
	flutter build appbundle --release

build-tagged: _update_version _update_changelog ## Build split APKs per ABI + bump version + changelog
	flutter build apk --split-per-abi --release

run: ## Run on connected device
	flutter run

# === Version Management (SemVer 2.0.0) ===

_update_changelog: ## Regenerate CHANGELOG.md (internal, called by build targets)
	@git-cliff --output CHANGELOG.md 2>/dev/null || true

_update_version: ## Bump patch version in pubspec.yaml (internal, called by builds)
	@CUR=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}'); \
	NEW_VER=$$(awk -v v="$$CUR" 'BEGIN{split(v,d,".");d[3]++;print d[1]"."d[2]"."d[3]}'); \
	echo "Version: $$CUR → $$NEW_VER"; \
	sed -i '' "s/version: .*/version: $$NEW_VER/" pubspec.yaml

changelog: ## Generate CHANGELOG.md from git history
	git-cliff --output CHANGELOG.md
	prettier --write CHANGELOG.md

# X.Y.Z → X.Y.Z+1 (bug fixes)
bump-patch: ## SemVer patch bump + commit + tag
	@CUR=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}'); \
	NEW_VER=$$(awk -v v="$$CUR" 'BEGIN{split(v,d,".");d[3]++;print d[1]"."d[2]"."d[3]}'); \
	sed -i '' "s/version: .*/version: $$NEW_VER/" pubspec.yaml; \
	echo "v$$CUR → v$$NEW_VER"; \
	git add pubspec.yaml CHANGELOG.md; \
	git commit -m "chore(release): v$$NEW_VER" --allow-empty; \
	git tag -a "v$$NEW_VER" -m "Release v$$NEW_VER"; \
	echo "Tagged v$$NEW_VER"

# X.Y.Z → X.(Y+1).0 (new features, patch resets)
bump-minor: ## SemVer minor bump + commit + tag
	@CUR=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}'); \
	NEW_VER=$$(awk -v v="$$CUR" 'BEGIN{split(v,d,".");d[2]++;d[3]=0;print d[1]"."d[2]"."d[3]}'); \
	sed -i '' "s/version: .*/version: $$NEW_VER/" pubspec.yaml; \
	echo "v$$CUR → v$$NEW_VER"; \
	git add pubspec.yaml CHANGELOG.md; \
	git commit -m "chore(release): v$$NEW_VER" --allow-empty; \
	git tag -a "v$$NEW_VER" -m "Release v$$NEW_VER"; \
	echo "Tagged v$$NEW_VER"

# X.Y.Z → (X+1).0.0 (breaking changes, minor+patch reset)
bump-major: ## SemVer major bump + commit + tag
	@CUR=$$(grep 'version:' pubspec.yaml | head -1 | awk '{print $$2}'); \
	NEW_VER=$$(awk -v v="$$CUR" 'BEGIN{split(v,d,".");d[1]++;d[2]=0;d[3]=0;print d[1]"."d[2]"."d[3]}'); \
	sed -i '' "s/version: .*/version: $$NEW_VER/" pubspec.yaml; \
	echo "v$$CUR → v$$NEW_VER"; \
	git add pubspec.yaml CHANGELOG.md; \
	git commit -m "chore(release): v$$NEW_VER" --allow-empty; \
	git tag -a "v$$NEW_VER" -m "Release v$$NEW_VER"; \
	echo "Tagged v$$NEW_VER"

# Alias — default to patch
bump: bump-patch ## Alias for bump-patch

release: ## Full release: check + changelog + patch bump
	@$(MAKE) check-all
	@$(MAKE) changelog
	@$(MAKE) bump-patch
	@echo ""
	@echo "Release done! Push: git push && git push --tags"
