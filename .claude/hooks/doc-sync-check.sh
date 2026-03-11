#!/bin/bash
# Stop Hook: Documentation sync verification
# Warns if Swift source files changed but no docs/ updates were made

# Count Swift file changes (staged + unstaged + untracked)
SWIFT_CHANGES=$(git diff --name-only HEAD 2>/dev/null | grep -c '\.swift$' 2>/dev/null || true)
SWIFT_STAGED=$(git diff --cached --name-only 2>/dev/null | grep -c '\.swift$' 2>/dev/null || true)
SWIFT_UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | grep -c '\.swift$' 2>/dev/null || true)

TOTAL_SWIFT=$(( ${SWIFT_CHANGES:-0} + ${SWIFT_STAGED:-0} + ${SWIFT_UNTRACKED:-0} ))

# No Swift changes → pass silently
if [[ "$TOTAL_SWIFT" -eq 0 ]]; then
    exit 0
fi

# Count docs/ file changes
DOC_CHANGES=$(git diff --name-only HEAD 2>/dev/null | grep -c '^docs/' 2>/dev/null || true)
DOC_STAGED=$(git diff --cached --name-only 2>/dev/null | grep -c '^docs/' 2>/dev/null || true)
DOC_UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | grep -c '^docs/' 2>/dev/null || true)

TOTAL_DOCS=$(( ${DOC_CHANGES:-0} + ${DOC_STAGED:-0} + ${DOC_UNTRACKED:-0} ))

# Swift changed but no docs → warn
if [[ "$TOTAL_DOCS" -eq 0 ]]; then
    echo "[Doc Sync Warning] Swift 파일이 ${TOTAL_SWIFT}개 변경되었으나 docs/ 업데이트가 없습니다."
    echo "  CLAUDE.md의 Post-Change Documentation Sync Rule 트리거 매트릭스를 확인하세요."
    echo "  문서 업데이트가 불필요한 경우(포맷팅, 내부 리팩토링 등)는 무시해도 됩니다."
fi

exit 0
