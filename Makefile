# Makefile

GRAPH_DIR := graphs

.PHONY: generate graph graph-clean common-graph splash-graph splash-graph onboarding-graph home-graph settings-graph dashboard-graph exercise-graph meal-graph profile-graph weight-graph

graph: common-graph splash-graph onboarding-graph home-graph settings-graph dashboard-graph exercise-graph meal-graph profile-graph weight-graph

generate:
	TUIST_ROOT_DIR=${PWD} tuist generate
	make graph

# 전체 타겟 그래프
common-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/common-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/graph.png"

# Splash 타겟 그래프
splash-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Splash -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/splash-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/splash-graph.png"

# Onboarding 타겟 그래프
onboarding-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Onboarding -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/onboarding-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/onboarding-graph.png"

# Home 타겟 그래프
home-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Home -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/home-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/home-graph.png"

# Settings 타겟 그래프
settings-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Settings -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/settings-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/setting-graph.png"
	
# Dashboard 타겟 그래프
dashboard-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Dashboard -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/dashboard-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/dashboard-graph.png"

# Exercise 타겟 그래프
exercise-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Exercise -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/exercise-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/exercise-graph.png"

# Meal 타겟 그래프
meal-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Meal -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/meal-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/meal-graph.png"

# Profile 타겟 그래프
profile-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Profile -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/profile-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/profile-graph.png"

# Weight 타겟 그래프
weight-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -t Weight -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/weight-graph.png
	@echo "✅ Generated: $(GRAPH_DIR)/weight-graph.png"

# 정리
graph-clean:
	rm -rf $(GRAPH_DIR)/*
	@echo "🧹 Cleaned graph output"
