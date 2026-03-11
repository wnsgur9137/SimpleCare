#!/bin/bash
# PostToolUse Hook: Documentation sync reminder
# Triggers on Edit/Write tools for Swift source files under Projects/

# Read tool input from stdin
INPUT=$(cat)

# Extract file_path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# If no file_path found, exit silently
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Only trigger for Swift files under Projects/
if [[ ! "$FILE_PATH" =~ Projects/.*\.swift$ ]]; then
    exit 0
fi

# Extract module name from path
# e.g., Projects/Feature/Meal/Domain/Sources/... -> Meal
# e.g., Projects/Infrastructure/AIServiceInfra/... -> AIServiceInfra
# e.g., Projects/Application/... -> Application
MODULE=""
DOCS=""

if [[ "$FILE_PATH" =~ Projects/Feature/Meal/ ]]; then
    MODULE="Meal"
    DOCS="docs/02-설계/modules/Meal.md, docs/03-구현/API.md"
elif [[ "$FILE_PATH" =~ Projects/Feature/Home/ ]]; then
    MODULE="Home"
    DOCS="docs/02-설계/modules/Home.md, docs/01-전략/HOME_SCREEN_PLAN.md"
elif [[ "$FILE_PATH" =~ Projects/Feature/([^/]+)/ ]]; then
    MODULE="${BASH_REMATCH[1]}"
    DOCS="docs/02-설계/modules/${MODULE}.md"
elif [[ "$FILE_PATH" =~ Projects/Infrastructure/AIServiceInfra/ ]]; then
    MODULE="AIServiceInfra"
    DOCS="docs/02-설계/modules/AIServiceInfra.md, docs/03-구현/API.md"
elif [[ "$FILE_PATH" =~ Projects/Infrastructure/NetworkInfra/ ]]; then
    MODULE="NetworkInfra"
    DOCS="docs/02-설계/modules/NetworkInfra.md, docs/02-설계/ARCHITECTURE.md"
elif [[ "$FILE_PATH" =~ Projects/Infrastructure/StorageInfra/ ]]; then
    MODULE="StorageInfra"
    DOCS="docs/02-설계/modules/StorageInfra.md, docs/03-구현/SETUP.md"
elif [[ "$FILE_PATH" =~ Projects/Infrastructure/([^/]+)/ ]]; then
    MODULE="${BASH_REMATCH[1]}"
    DOCS="docs/02-설계/modules/${MODULE}.md, docs/02-설계/ARCHITECTURE.md"
elif [[ "$FILE_PATH" =~ Projects/Application/ ]]; then
    MODULE="Application"
    DOCS="docs/02-설계/ARCHITECTURE.md"
else
    # Other Projects/ Swift files
    exit 0
fi

echo "[Doc Sync] ${MODULE} 모듈 수정 → 관련 문서 확인: ${DOCS}"
echo "  해당 모듈의 AGENTS.md 문서 동기화 규칙도 참고하세요."
