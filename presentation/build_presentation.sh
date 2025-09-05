#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Build script for CleanEasy project presentation (CleanEasy.tex)
# -----------------------------------------------------------------------------
# Features:
#   * Uses latexmk if available, falls back to pdflatex multiple runs
#   * Optional bibliography pass if .bib detected (currently commented out)
#   * Output placed in ./build directory (created if missing)
#   * Flags:
#       --clean        Remove build artifacts
#       --watch        Continuous compilation (latexmk -pvc)
#       --open         Open resulting PDF (if xdg-open available)
#       --quiet        Suppress non-error output
#       --shell-escape Enable shell-escape (only if truly needed)
#
# Usage examples:
#   ./build_presentation.sh            # one-off build
#   ./build_presentation.sh --open     # build and open PDF
#   ./build_presentation.sh --watch    # auto rebuild on changes
#   ./build_presentation.sh --clean    # clean artifacts
# -----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE="CleanEasy.tex"
OUTDIR="build"
FINAL_PDF="${SOURCE%.tex}.pdf"
PDF_OUTPUT="${OUTDIR}/${FINAL_PDF}"

quiet=false
watch=false
clean=false
open_pdf=false
shell_escape=false

for arg in "$@"; do
	case "$arg" in
		--quiet) quiet=true ;;
		--watch) watch=true ;;
		--clean) clean=true ;;
		--open) open_pdf=true ;;
		--shell-escape) shell_escape=true ;;
		-h|--help)
			grep '^# ' "$0" | sed 's/^# //'
			exit 0
			;;
		*) echo "[WARN] Ignoring unknown argument: $arg" >&2 ;;
	esac
done

log() { $quiet || echo -e "$*"; }
err() { echo -e "[ERROR] $*" >&2; }

if [[ ! -f "$SOURCE" ]]; then
	err "Source file $SOURCE not found in $SCRIPT_DIR"; exit 1
fi

if $clean; then
	log "[CLEAN] Removing build directory '$OUTDIR' and auxiliary files."
	rm -rf "$OUTDIR"
	find . -maxdepth 1 -type f \( -name '*.aux' -o -name '*.log' -o -name '*.out' -o -name '*.toc' -o -name '*.nav' -o -name '*.snm' -o -name '*.fls' -o -name '*.fdb_latexmk' -o -name '*.bbl' -o -name '*.blg' -o -name '*.synctex.gz' \) -print -delete || true
	exit 0
fi

mkdir -p "$OUTDIR"

LATEXMK_OPTS=(-pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$OUTDIR")
PDflatex_CMD=(pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$OUTDIR")

if $shell_escape; then
	LATEXMK_OPTS+=(-shell-escape)
	PDflatex_CMD+=("-shell-escape")
fi

need_bib=false
if grep -Eq '\\bibliography\{' "$SOURCE"; then
	need_bib=true
fi

build_once() {
	if command -v latexmk >/dev/null 2>&1; then
		log "[INFO] Building with latexmk"
		latexmk "${LATEXMK_OPTS[@]}" "$SOURCE"
	else
		log "[INFO] latexmk not found, falling back to manual pdflatex runs"
		"${PDflatex_CMD[@]}" "$SOURCE"
		if $need_bib && command -v bibtex >/dev/null 2>&1; then
			base="${SOURCE%.tex}";
			(cd "$OUTDIR" && bibtex "$base" || log "[WARN] BibTeX failed or not needed")
			"${PDflatex_CMD[@]}" "$SOURCE"
		fi
		"${PDflatex_CMD[@]}" "$SOURCE"
	fi
}

if $watch; then
	if ! command -v latexmk >/dev/null 2>&1; then
		err "--watch requires latexmk. Please install it (e.g., sudo apt install latexmk)."; exit 2
	fi
	log "[WATCH] Watching for changes... (Ctrl+C to stop)"
	if $shell_escape; then LATEXMK_OPTS+=(-shell-escape); fi
	latexmk -pvc "${LATEXMK_OPTS[@]}" "$SOURCE"
	exit 0
else
	build_once
fi

if [[ -f "$PDF_OUTPUT" ]]; then
	# Compare with existing PDF (if present) before overwriting
	OLD_HASH=""; OLD_SIZE=""; OLD_MTIME=""; OLD_EXISTS=false
	if [[ -f "$FINAL_PDF" ]]; then
		OLD_EXISTS=true
		OLD_HASH=$(sha256sum "$FINAL_PDF" | awk '{print $1}' || true)
		OLD_SIZE=$(du -h "$FINAL_PDF" | cut -f1 || true)
		OLD_MTIME=$(date -r "$FINAL_PDF" '+%Y-%m-%d %H:%M:%S' || true)
	fi

	# Copy (not move) then we will delete build dir later; copy ensures we still have source if something fails post-step
	cp -f "$PDF_OUTPUT" "$FINAL_PDF"

	NEW_HASH=$(sha256sum "$FINAL_PDF" | awk '{print $1}')
	NEW_SIZE=$(du -h "$FINAL_PDF" | cut -f1)
	NEW_MTIME=$(date -r "$FINAL_PDF" '+%Y-%m-%d %H:%M:%S')

	LAST_HASH_FILE=".last_build_hash"
	PREV_HASH=""
	[[ -f $LAST_HASH_FILE ]] && PREV_HASH=$(cat "$LAST_HASH_FILE" 2>/dev/null || true)
	echo "$NEW_HASH" > "$LAST_HASH_FILE"

	if $OLD_EXISTS; then
		if cmp -s "$PDF_OUTPUT" "$FINAL_PDF" && [[ "$OLD_HASH" == "$NEW_HASH" ]]; then
			# Content identical to previous version: touch to force viewer reload
			touch "$FINAL_PDF"
			NEW_MTIME=$(date -r "$FINAL_PDF" '+%Y-%m-%d %H:%M:%S')
			log "[SUCCESS] Built (UNCHANGED CONTENT) : ./$(basename "$FINAL_PDF") $NEW_SIZE"
			log "[INFO] Hash: $NEW_HASH  |  Prev Hash: $OLD_HASH"
			log "[INFO] Timestamp touched ($NEW_MTIME) per forzare il reload del viewer."
		else
			log "[SUCCESS] Built (UPDATED) : ./$(basename "$FINAL_PDF") $NEW_SIZE"
			log "[INFO] New Hash: $NEW_HASH"
			if [[ -n "$OLD_HASH" ]]; then
				log "[INFO] Old  Hash: $OLD_HASH  (era $OLD_SIZE, $OLD_MTIME)"
			fi
		fi
	else
		log "[SUCCESS] Built (NEW) : ./$(basename "$FINAL_PDF") $NEW_SIZE"
		log "[INFO] Hash: $NEW_HASH  |  Modified: $NEW_MTIME"
	fi
else
	err "PDF not generated. Check LaTeX errors above."; exit 3
fi

# Clean build artifacts except final PDF
log "[CLEAN] Removing intermediate build artifacts."
rm -rf "$OUTDIR"
find . -maxdepth 1 -type f \( -name '*.aux' -o -name '*.log' -o -name '*.out' -o -name '*.toc' -o -name '*.nav' -o -name '*.snm' -o -name '*.fls' -o -name '*.fdb_latexmk' -o -name '*.bbl' -o -name '*.blg' -o -name '*.synctex.gz' \) -delete 2>/dev/null || true

if $open_pdf; then
	if command -v xdg-open >/dev/null 2>&1; then
		(xdg-open "$FINAL_PDF" >/dev/null 2>&1 & ) || log "[WARN] Could not open PDF viewer."
	else
		log "[INFO] xdg-open not available; skipping auto-open."
	fi
fi

exit 0
