.PHONY: help get gen clean format fix analyze lint test slang-analyze check-all fix-all build build-split build-debug build-aab run release

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

build-split: ## Build split APKs per ABI (arm64, arm, x86_64)
	flutter build apk --split-per-abi --release

build-debug: ## Build debug APK (universal)
	flutter build apk --debug

build-aab: ## Build release AAB (for Play Store)
	flutter build appbundle --release

run: ## Run on connected device
	flutter run

release: check-all build-split ## Full check + split release build
