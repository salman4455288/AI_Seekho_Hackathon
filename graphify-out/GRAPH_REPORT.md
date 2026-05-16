# Graph Report - hackathon  (2026-05-16)

## Corpus Check
- 8 files · ~26,285 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 84 nodes · 96 edges · 7 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 6 edges
2. `package:google_fonts/google_fonts.dart` - 6 edges
3. `../models/insight_result.dart` - 6 edges
4. `package:flutter_animate/flutter_animate.dart` - 4 edges
5. `ActionCard` - 1 edges
6. `_priorityColor` - 1 edges
7. `_effortColor` - 1 edges
8. `build` - 1 edges
9. `GestureDetector` - 1 edges
10. `SizedBox` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "Community 0"
Cohesion: 0.11
Nodes (17): _ActionsTab, _ActionsTabState, build, Container, dispose, initState, _InsightsTab, ResultScreen (+9 more)

### Community 1 - "Community 1"
Cohesion: 0.14
Nodes (13): ActionCard, build, _effortColor, GestureDetector, Icon, _priorityColor, SizedBox, build (+5 more)

### Community 2 - "Community 2"
Cohesion: 0.13
Nodes (14): build, _buildInputView, _buildProcessingView, Center, _ExampleChip, GestureDetector, HomeScreen, _HomeScreenState (+6 more)

### Community 3 - "Community 3"
Cohesion: 0.15
Nodes (12): AnimatedContainer, build, Container, Icon, _MetricChip, Row, Scaffold, SimulationScreen (+4 more)

### Community 4 - "Community 4"
Cohesion: 0.22
Nodes (8): _callGemini, Exception, GeminiAgentService, InsightResult, jsonDecode, dart:convert, ../models/insight_result.dart, package:http/http.dart

### Community 5 - "Community 5"
Cohesion: 0.22
Nodes (8): build, Icon, Row, SingleChildScrollView, SizedBox, Spacer, TraceTimeline, package:flutter_animate/flutter_animate.dart

### Community 6 - "Community 6"
Cohesion: 0.4
Nodes (4): ActionItem, AgentStep, InsightResult, SimulationResult

## Knowledge Gaps
- **72 isolated node(s):** `ActionCard`, `_priorityColor`, `_effortColor`, `build`, `GestureDetector` (+67 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `../models/insight_result.dart` connect `Community 4` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 5`?**
  _High betweenness centrality (0.246) - this node is a cross-community bridge._
- **Why does `package:flutter/material.dart` connect `Community 1` to `Community 0`, `Community 2`, `Community 3`, `Community 5`?**
  _High betweenness centrality (0.134) - this node is a cross-community bridge._
- **Why does `package:google_fonts/google_fonts.dart` connect `Community 1` to `Community 0`, `Community 2`, `Community 3`, `Community 5`?**
  _High betweenness centrality (0.134) - this node is a cross-community bridge._
- **What connects `ActionCard`, `_priorityColor`, `_effortColor` to the rest of the system?**
  _72 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._