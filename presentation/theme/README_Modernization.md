# CleanEasy Beamer Theme Modernization

This document describes the extended options and design principles introduced while modernizing the `CleanEasy` Beamer theme for this project.

## 1. Overview
The original theme has been refactored into a configurable system supporting multiple visual styles:
- Modern (default) – clean sans-serif, accent color bar, progress footline.
- Academic – formal serif typesetting, subdued palette, minimal page footline.
- Dark – neutral dark background variant (pair with vibrant if you want stronger accent).
- Legacy – approximates the original look & feel.

Core option flags can be combined except where they intentionally replace a whole style (e.g. `academic` vs `legacy` vs plain modern). You normally choose at most one of: `academic`, `legacy`. Other modifiers (`dark`, `vibrant`, `icons`, `minimalblocks`) can layer on top of the modern base (some are ignored or internally neutralized in academic mode where not appropriate).

## 2. Theme Files
```
beamerthemeCleanEasy.sty      # Option parsing & orchestration
beamercolorthemeCleanEasy.sty # Color palettes & semantic mapping
beamerfontthemeCleanEasy.sty  # Font stacks & hierarchy
beamerinnerthemeCleanEasy.sty # Blocks, frametitle, titlepage, list markers
beamerouterthemeCleanEasy.sty # Footline, section pages, navigation
```

## 3. Options Summary
| Option | Purpose | Notes |
|--------|---------|-------|
| `academic` | Serif, subdued, minimalist layout | Disables accent bars & progress bar |
| `legacy` | Revert to near-original visuals | Mutually exclusive with `academic` |
| `dark` | Dark neutral background variant | Adjusts foreground/readability colors |
| `vibrant` | Stronger accent (teal→blue) | Pairs well with modern style |
| `icons` | Custom bullet symbols | Not applied in academic (kept conservative) |
| `minimalblocks` | Remove block backgrounds & frames | Keeps left accent bar unless academic |

Usage examples:
```latex
% Modern vibrant minimalist
\usetheme[vibrant,icons,minimalblocks]{CleanEasy}

% Academic formal style
\usetheme[academic]{CleanEasy}

% Dark + vibrant (modern)
\usetheme[dark,vibrant]{CleanEasy}
```

## 4. Color System
Defined semantic layers rather than hard-coded colors:
- Neutral scale (bg / surface / subtle / border / text) – light & dark variants.
- Accent triad: `CEAccent`, `CEAccentLight`, `CEAccentDark`.
- Semantic: `CEPositive` (green), `CEWarning` (amber), `CENegative` (crimson).

Academic mode desaturates structure color (muted deep gray / toned accent) and removes decorative progress indicators.

## 5. Typography
Engine-aware font selection:
- If using XeLaTeX or LuaLaTeX (recommended):
  - Modern: tries `Inter`, falls back to `Roboto`, then `Latin Modern Sans`.
  - Academic: tries `Libertinus Serif`, then `TeX Gyre Termes`, then `Latin Modern Roman`.
- If using pdfLaTeX: modern uses `\sfdefault`, academic switches to serif by setting `\familydefault`.

Hierarchy adjustments:
- Frametitile slightly larger + bold.
- Block titles semi-bold; content balanced for readability.
- Tightened letterspacing (`microtype`) improves polish.

## 6. Layout & Components
- Frametitile: solid accent bar (modern) vs thin neutral rule (academic).
- Blocks: subtle card style with left accent stripe (modern). In `minimalblocks`, background removed. Academic mode suppresses stripes and uses understated headings.
- Footline:
  - Modern: page number + progress bar.
  - Academic: centered (or right-aligned) page number only.
  - Title / section frames: footline suppressed for cleanliness.
- Section pages: simplified large title text; academic removes accent splash.

## 7. Recommended Compilation
For best font quality use XeLaTeX or LuaLaTeX:
```bash
latexmk -xelatex -shell-escape -interaction=nonstopmode main.tex
```
If constrained to pdfLaTeX you still get a functional layout, but with fallback fonts.

## 8. Switching Styles Quickly
Keep two entry files if you alternate often:
```
main.tex         # Academic (current)
main_modern.tex  # Modern showcase variant
```
Or define a single variable line and comment/uncomment options.

## 9. Customization Tips
- Change accent color: redefine `\definecolor{CEAccent}{HTML}{0F6D9A}` (pick hex) AFTER loading the theme files, or clone the color theme file.
- Disable progress bar but stay modern: remove `progress` code by adding `\CleanEasy@showprogressfalse` after `\usetheme{}` call (internal flag) or comment progress code in outer theme.
- Larger frametitles: adjust in `beamerfontthemeCleanEasy.sty` the `\setbeamerfont{frametitle}` size.
- Monospaced code blocks: add `\usepackage{inconsolata}` (XeLaTeX) and wrap with `verbatim` or `minted` (remember `-shell-escape`).

## 10. Academic Mode Philosophy
Focus on content density and formal tone:
- Reduced chroma.
- Serif body for long-form readability.
- Removed decorative bullets & progress visuals.
- Clear separation via whitespace rather than color blocks.

## 11. Known Notes / Future Ideas
- Could add a `numberlesssections` option to suppress section frames entirely.
- Potential `monochrome` option for printing handouts.
- Add automatic palette switch for `dark+academic` (currently uses modern dark neutrals; can be refined).

## 12. Attribution
Modernization and academic extension authored during project refactor (2025). Original base theme: CleanEasy Beamer Theme (adapted).

---
Feel free to extend. Keep option parsing centralized in `beamerthemeCleanEasy.sty` for maintainability.
