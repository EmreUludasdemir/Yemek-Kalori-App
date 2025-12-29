# TürkKalori Makefile - Docker ve Test Komutları

.PHONY: help build up down restart logs shell test clean

# Varsayılan komut
.DEFAULT_GOAL := help

# Renkli output için
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

##@ Yardım

help: ## Bu yardım mesajını gösterir
	@echo "$(GREEN)TürkKalori Docker Komutları$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nKullanım:\n  make $(YELLOW)<komut>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Temel Komutlar

build: ## Tüm Docker image'larını build et
	@echo "$(GREEN)Building Docker images...$(NC)"
	docker-compose build

build-dev: ## Sadece development image'ını build et
	@echo "$(GREEN)Building dev image...$(NC)"
	docker-compose build flutter-dev

build-test: ## Sadece test image'ını build et
	@echo "$(GREEN)Building test image...$(NC)"
	docker-compose build flutter-test

build-web: ## Sadece web image'ını build et
	@echo "$(GREEN)Building web image...$(NC)"
	docker-compose build flutter-web

build-nc: ## Cache kullanmadan build et
	@echo "$(GREEN)Building without cache...$(NC)"
	docker-compose build --no-cache

up: ## Tüm servisleri başlat
	@echo "$(GREEN)Starting all services...$(NC)"
	docker-compose up -d

up-dev: ## Development ortamını başlat
	@echo "$(GREEN)Starting dev environment...$(NC)"
	docker-compose up -d flutter-dev

up-test: ## Test ortamını başlat
	@echo "$(GREEN)Starting test environment...$(NC)"
	docker-compose up -d flutter-test

up-web: ## Web preview'ı başlat
	@echo "$(GREEN)Starting web preview...$(NC)"
	docker-compose up -d flutter-web
	@echo "$(GREEN)Web preview: http://localhost:8080$(NC)"

up-db: ## Sadece database'i başlat
	@echo "$(GREEN)Starting database...$(NC)"
	docker-compose up -d postgres

down: ## Tüm servisleri durdur
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker-compose down

down-v: ## Servisleri durdur ve volume'ları sil
	@echo "$(RED)Stopping services and removing volumes...$(NC)"
	docker-compose down -v

restart: down up ## Servisleri yeniden başlat

restart-web: ## Web servisini yeniden başlat
	@echo "$(YELLOW)Restarting web service...$(NC)"
	docker-compose restart flutter-web

##@ Logs ve Monitoring

logs: ## Tüm logları göster
	docker-compose logs -f

logs-dev: ## Dev container loglarını göster
	docker-compose logs -f flutter-dev

logs-test: ## Test container loglarını göster
	docker-compose logs -f flutter-test

logs-web: ## Web container loglarını göster
	docker-compose logs -f flutter-web

logs-db: ## Database loglarını göster
	docker-compose logs -f postgres

ps: ## Çalışan container'ları listele
	docker-compose ps

stats: ## Container resource kullanımını göster
	docker stats

##@ Shell Access

shell: ## Dev container'a bağlan
	@echo "$(GREEN)Connecting to dev container...$(NC)"
	docker exec -it turkkalori-dev bash

shell-test: ## Test container'a bağlan
	docker exec -it turkkalori-test sh

shell-db: ## Database'e bağlan
	@echo "$(GREEN)Connecting to PostgreSQL...$(NC)"
	docker exec -it turkkalori-db psql -U postgres -d turkkalori

##@ Flutter Komutları

flutter-doctor: ## Flutter doctor çalıştır
	docker-compose run --rm flutter-dev flutter doctor -v

flutter-pub-get: ## Dependencies'leri yükle
	@echo "$(GREEN)Installing dependencies...$(NC)"
	docker-compose run --rm flutter-dev flutter pub get

flutter-clean: ## Flutter clean çalıştır
	@echo "$(YELLOW)Cleaning Flutter project...$(NC)"
	docker-compose run --rm flutter-dev flutter clean

flutter-analyze: ## Flutter analyze çalıştır
	@echo "$(GREEN)Analyzing code...$(NC)"
	docker-compose run --rm flutter-dev flutter analyze

flutter-format: ## Kodu formatla
	@echo "$(GREEN)Formatting code...$(NC)"
	docker-compose run --rm flutter-dev flutter format .

##@ Test Komutları

test: ## Tüm testleri çalıştır
	@echo "$(GREEN)Running all tests...$(NC)"
	docker-compose run --rm flutter-test flutter test

test-unit: ## Unit testleri çalıştır
	@echo "$(GREEN)Running unit tests...$(NC)"
	docker-compose run --rm flutter-test flutter test test/unit/

test-widget: ## Widget testleri çalıştır
	@echo "$(GREEN)Running widget tests...$(NC)"
	docker-compose run --rm flutter-test flutter test test/widget/

test-integration: ## Integration testleri çalıştır
	@echo "$(GREEN)Running integration tests...$(NC)"
	docker-compose run --rm flutter-test flutter test test/integration/

test-coverage: ## Coverage raporu oluştur
	@echo "$(GREEN)Generating coverage report...$(NC)"
	docker-compose run --rm flutter-test sh -c "flutter test --coverage && lcov --summary coverage/lcov.info"
	@echo "$(GREEN)Coverage report: coverage/lcov.info$(NC)"

coverage-html: test-coverage ## HTML coverage raporu oluştur
	@echo "$(GREEN)Generating HTML coverage report...$(NC)"
	docker-compose run --rm flutter-test sh -c "genhtml coverage/lcov.info -o coverage/html"
	@echo "$(GREEN)HTML report: coverage/html/index.html$(NC)"

coverage-serve: ## Coverage raporunu tarayıcıda aç
	@echo "$(GREEN)Serving coverage report at http://localhost:8081$(NC)"
	docker-compose up -d coverage-reporter

##@ Build Komutları

build-apk: ## Android APK build et (debug)
	@echo "$(GREEN)Building Android APK (debug)...$(NC)"
	docker-compose run --rm flutter-dev sh -c "flutter pub get && flutter build apk --debug"
	@echo "$(GREEN)APK: build/app/outputs/flutter-apk/app-debug.apk$(NC)"

build-apk-release: ## Android APK build et (release)
	@echo "$(GREEN)Building Android APK (release)...$(NC)"
	docker-compose run --rm flutter-dev sh -c "flutter pub get && flutter build apk --release"
	@echo "$(GREEN)APK: build/app/outputs/flutter-apk/app-release.apk$(NC)"

build-appbundle: ## Android App Bundle build et
	@echo "$(GREEN)Building Android App Bundle...$(NC)"
	docker-compose run --rm flutter-dev sh -c "flutter pub get && flutter build appbundle --release"
	@echo "$(GREEN)AAB: build/app/outputs/bundle/release/app-release.aab$(NC)"

build-ios: ## iOS build et (Sadece macOS'ta çalışır)
	@echo "$(YELLOW)iOS build Docker'da desteklenmiyor. macOS kullanın.$(NC)"

build-web-local: ## Web build et (local)
	@echo "$(GREEN)Building web version...$(NC)"
	docker-compose run --rm flutter-dev flutter build web --release
	@echo "$(GREEN)Web build: build/web/$(NC)"

##@ Database Komutları

db-init: ## Database'i initialize et
	@echo "$(GREEN)Initializing database...$(NC)"
	docker-compose up -d postgres
	@sleep 3
	docker-compose exec postgres psql -U postgres -d turkkalori -f /docker-entrypoint-initdb.d/init.sql

db-backup: ## Database backup oluştur
	@echo "$(GREEN)Creating database backup...$(NC)"
	docker-compose exec postgres pg_dump -U postgres turkkalori > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup created!$(NC)"

db-restore: ## Database restore et (BACKUP_FILE=filename.sql)
	@echo "$(YELLOW)Restoring database from $(BACKUP_FILE)...$(NC)"
	docker-compose exec -T postgres psql -U postgres turkkalori < $(BACKUP_FILE)

db-reset: ## Database'i sıfırla
	@echo "$(RED)Resetting database...$(NC)"
	docker-compose down -v
	docker-compose up -d postgres
	@sleep 3
	@$(MAKE) db-init

##@ Temizlik Komutları

clean: ## Flutter clean + container temizliği
	@echo "$(YELLOW)Cleaning project...$(NC)"
	docker-compose run --rm flutter-dev flutter clean
	docker-compose down

clean-all: ## Tüm Docker resources'ları temizle
	@echo "$(RED)Cleaning all Docker resources...$(NC)"
	docker-compose down -v --rmi all
	docker system prune -af

clean-volumes: ## Sadece volume'ları temizle
	@echo "$(RED)Removing volumes...$(NC)"
	docker volume rm turkkalori-pub-cache turkkalori-gradle-cache turkkalori-coverage || true

clean-images: ## Kullanılmayan image'ları temizle
	@echo "$(YELLOW)Removing unused images...$(NC)"
	docker image prune -af

##@ Utility Komutları

check: ## Sistem kontrolü yap
	@echo "$(GREEN)Checking system...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker not installed!$(NC)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)Docker Compose not installed!$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Docker installed$(NC)"
	@echo "$(GREEN)✓ Docker Compose installed$(NC)"
	@docker --version
	@docker-compose --version

health: ## Health check tüm servisler
	@echo "$(GREEN)Checking service health...$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(GREEN)Web service:$(NC)"
	@curl -f http://localhost:8080/health 2>/dev/null && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ Failed$(NC)"
	@echo "$(GREEN)Database:$(NC)"
	@docker-compose exec postgres pg_isready -U postgres && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ Failed$(NC)"

open-web: ## Web preview'ı tarayıcıda aç
	@echo "$(GREEN)Opening web preview...$(NC)"
	@which xdg-open >/dev/null && xdg-open http://localhost:8080 || echo "Visit: http://localhost:8080"

open-supabase: ## Supabase Studio'yu tarayıcıda aç
	@echo "$(GREEN)Opening Supabase Studio...$(NC)"
	@which xdg-open >/dev/null && xdg-open http://localhost:3000 || echo "Visit: http://localhost:3000"

##@ Development Workflow

dev: up-dev shell ## Dev ortamını başlat ve shell aç

quick-test: ## Hızlı test (sadece değişen dosyalar)
	@echo "$(GREEN)Running quick tests...$(NC)"
	docker-compose run --rm flutter-test flutter test --coverage

full-test: clean-volumes test-coverage ## Tam test (clean + coverage)

ci: check build test ## CI pipeline simülasyonu

deploy-prep: clean build-appbundle build-web-local ## Deploy hazırlığı

##@ Debugging

debug-logs: ## Detaylı log output
	docker-compose logs --tail=100 -f

debug-flutter: ## Flutter verbose mode
	docker-compose run --rm flutter-dev flutter doctor -v

debug-network: ## Network durumunu kontrol et
	docker network ls | grep turkkalori
	docker network inspect turkkalori-network

debug-volumes: ## Volume durumunu kontrol et
	docker volume ls | grep turkkalori
	docker system df -v | grep turkkalori
