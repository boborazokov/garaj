# Graph Report - promotion  (2026-11-09)

## Corpus Check
- 5 files · ~2,105 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 109 nodes · 136 edges · 6 communities (5 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b94ae5bc`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- promote_plan_sheet.dart
- boost_plan_picker.dart
- promote_workshop_sheet.dart
- promotion_plan_option_tile.dart
- BoostPlanPicker
- build

## God Nodes (most connected - your core abstractions)
1. `BoostPlanPicker` - 3 edges
2. `_BoostPlanPickerState` - 3 edges
3. `_PromotePlanSheet` - 3 edges
4. `_PromotePlanSheetState` - 3 edges
5. `_submit` - 2 edges
6. `build` - 2 edges
7. `PromotionPlanOptionTile` - 2 edges
8. `s` - 1 edges
9. `buf` - 1 edges
10. `selected` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (6 total, 1 thin omitted)

### Community 0 - "promote_plan_sheet.dart"
Cohesion: 0.05
Nodes (32): activePlan, api, buf, _cancel, _cancelling, CancelPromotionCallback, createState, fallbackDays (+24 more)

### Community 1 - "boost_plan_picker.dart"
Cohesion: 0.08
Nodes (17): buf, build, compact, createState, _fallbackDays, _formatUzs, initState, _load (+9 more)

### Community 2 - "promote_workshop_sheet.dart"
Cohesion: 0.14
Nodes (7): showPromotePlanSheet, showPromoteProductSheet, context, profile, showPromotePlanSheet, showPromoteWorkshopByIdSheet, showPromoteWorkshopSheet

### Community 3 - "promotion_plan_option_tile.dart"
Cohesion: 0.12
Nodes (10): build, enabled, onTap, PromotionPlanOptionTile, recommended, recommendedLabel, selected, subtitle (+2 more)

### Community 4 - "BoostPlanPicker"
Cohesion: 0.40
Nodes (4): BoostPlanPicker, _BoostPlanPickerState, _PromotePlanSheet, _PromotePlanSheetState

## Knowledge Gaps
- **65 isolated node(s):** `s`, `buf`, `selected`, `onChanged`, `title` (+60 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 79 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_PromotePlanSheet` connect `BoostPlanPicker` to `promote_plan_sheet.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `s`, `buf`, `selected` to the rest of the system?**
  _65 weakly-connected nodes found - possible missing edges._
- **Should `promote_plan_sheet.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Why does `_PromotePlanSheetState` connect `BoostPlanPicker` to `promote_plan_sheet.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Should `boost_plan_picker.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `promote_workshop_sheet.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.13725490196078433 - nodes in this community are weakly interconnected._
- **Should `promotion_plan_option_tile.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._