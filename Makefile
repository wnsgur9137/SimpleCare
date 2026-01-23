# Makefile

GRAPH_DIR := graphs

.PHONY: generate graph graph-clean common-graph splash-graph splash-graph onboarding-graph home-graph settings-graph

graph: common-graph splash-graph onboarding-graph home-graph settings-graph

generate:
	TUIST_ROOT_DIR=${PWD} tuist generate

# 전체 타겟 그래프
common-graph:
	@mkdir -p $(GRAPH_DIR)
	tuist graph -d -o $(GRAPH_DIR)
	mv $(GRAPH_DIR)/graph.png $(GRAPH_DIR)/graph.png
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

# 정리
graph-clean:
	rm -rf $(GRAPH_DIR)/*
	@echo "🧹 Cleaned graph output"
