.PHONY: help get gen clean format fix analyze test check-all fix-all build build-split build-debug build-aab run release

APP_NAME := ztime_widget

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

get: ## flutter pub get
	flutter pub get

gen: ## Run code generation (build_runner)
	dart run build_runner build

clean: ## Clean build cache
	flutter clean
	flutter pub get

format: ## dart format all files
	dart format lib/ test/

fix: ## dart fix --apply
	dart fix --apply

analyze: ## flutter analyze
	flutter analyze

test: ## Run tests
	flutter test

check-all: format analyze test ## Format + Analyze + Test

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
