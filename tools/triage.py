#!/usr/bin/env python3
"""
Triage tool for Spekkio extraction output.

Scans spec directories for [HUMAN_INPUT] and [ANOMALY] tags,
generates a triage summary (triage.md) and interactive HTML report (report.html).

Usage:
    python tools/triage.py specs/001-atm/
    python tools/triage.py specs/001-atm/ --triage-only
    python tools/triage.py specs/001-atm/ --report-only
"""

import argparse
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class Tag:
    tag_type: str  # "HUMAN_INPUT" or "ANOMALY"
    id: str  # e.g. "HI-001" or "ANO-001"
    source: str  # original source code reference
    content: str  # text between open/close tags
    spec_file: str  # which output file contained this tag
    line_number: int  # line in spec_file where tag starts


# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

class TagParser:
    """Extracts [HUMAN_INPUT] and [ANOMALY] tags from spec files."""

    # Matches [HUMAN_INPUT id=... source=...]...[/HUMAN_INPUT] (and ANOMALY)
    TAG_RE = re.compile(
        r'\[(HUMAN_INPUT|ANOMALY)\s+([^\]]+)\]'  # opening tag + attrs
        r'(.*?)'                                   # content (non-greedy)
        r'\[/\1\]',                                # closing tag
        re.DOTALL,
    )

    ATTR_RE = re.compile(r'(\w+)=(\S+)')

    def parse_file(self, path: Path) -> list[Tag]:
        """Parse a single file and return all tags found."""
        text = path.read_text(encoding="utf-8")
        rel = str(path)

        # For .feature files, strip leading "# " from each line before matching
        if path.suffix == ".feature":
            lines = text.splitlines()
            stripped_lines = []
            for line in lines:
                # Strip comment prefix for tag matching
                m = re.match(r'^(\s*)# ?(.*)', line)
                if m:
                    stripped_lines.append(m.group(1) + m.group(2))
                else:
                    stripped_lines.append(line)
            text_for_matching = "\n".join(stripped_lines)
        else:
            text_for_matching = text

        tags: list[Tag] = []
        for match in self.TAG_RE.finditer(text_for_matching):
            tag_type = match.group(1)
            attrs_str = match.group(2)
            content = match.group(3).strip()

            attrs = dict(self.ATTR_RE.findall(attrs_str))
            tag_id = attrs.get("id", "???")
            source = attrs.get("source", "unknown")

            # Find line number in original text
            # Use the tag id to locate in original file text
            tag_open = f"[{tag_type}"
            line_number = 1
            search_id = f"id={tag_id}"
            for i, line in enumerate(text.splitlines(), 1):
                if tag_open in line and search_id in line:
                    line_number = i
                    break

            tags.append(Tag(
                tag_type=tag_type,
                id=tag_id,
                source=source,
                content=content,
                spec_file=rel,
                line_number=line_number,
            ))

        return tags

    def parse_directory(self, spec_dir: Path) -> list[Tag]:
        """Scan all .md, .yml, .feature files in spec_dir recursively."""
        all_tags: list[Tag] = []
        extensions = {".md", ".yml", ".yaml", ".feature"}

        for root, _dirs, files in os.walk(spec_dir):
            for fname in sorted(files):
                fpath = Path(root) / fname
                if fpath.suffix in extensions:
                    all_tags.extend(self.parse_file(fpath))

        # Sort by ID for stable output
        def sort_key(t: Tag) -> tuple[str, int]:
            # Extract numeric part for sorting: HI-001 -> 1, ANO-012 -> 12
            m = re.search(r'(\d+)$', t.id)
            num = int(m.group(1)) if m else 0
            return (t.tag_type, num)

        all_tags.sort(key=sort_key)
        return all_tags


# ---------------------------------------------------------------------------
# Triage markdown generator
# ---------------------------------------------------------------------------

class TriageGenerator:
    """Generates triage.md from parsed tags."""

    def generate(self, tags: list[Tag], spec_dir: Path) -> str:
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

        hi_tags = [t for t in tags if t.tag_type == "HUMAN_INPUT"]
        ano_tags = [t for t in tags if t.tag_type == "ANOMALY"]

        lines: list[str] = []
        lines.append("# Triage Summary")
        lines.append("")
        lines.append(f"**Spec Directory**: {spec_dir}")
        lines.append(f"**Generated**: {now}")
        lines.append("")
        lines.append("## Overview")
        lines.append("")
        lines.append("| Type | Count |")
        lines.append("|------|-------|")
        lines.append(f"| HUMAN_INPUT | {len(hi_tags)} |")
        lines.append(f"| ANOMALY | {len(ano_tags)} |")
        lines.append(f"| **Total** | **{len(tags)}** |")
        lines.append("")

        if hi_tags:
            lines.append("## Items Requiring Human Input")
            lines.append("")
            for t in hi_tags:
                lines.append(f"### {t.id}")
                lines.append(f"- **File**: {_rel_path(t.spec_file, spec_dir)} (line {t.line_number})")
                lines.append(f"- **Source**: `{t.source}`")
                lines.append(f"- **Context**: {t.content}")
                lines.append("")

        if ano_tags:
            lines.append("## Anomalies Detected")
            lines.append("")
            for t in ano_tags:
                lines.append(f"### {t.id}")
                lines.append(f"- **File**: {_rel_path(t.spec_file, spec_dir)} (line {t.line_number})")
                lines.append(f"- **Source**: `{t.source}`")
                lines.append(f"- **Observation**: {t.content}")
                lines.append("")

        if not tags:
            lines.append("No tags found. Either the extraction has not been run with the")
            lines.append("new tag format, or all items have been resolved.")
            lines.append("")

        return "\n".join(lines)


# ---------------------------------------------------------------------------
# Minimal Markdown -> HTML converter
# ---------------------------------------------------------------------------

class MarkdownToHtml:
    """Converts a subset of markdown to HTML with inline tag highlighting."""

    TAG_OPEN_RE = re.compile(
        r'\[(HUMAN_INPUT|ANOMALY)\s+([^\]]+)\]'
    )
    TAG_CLOSE_RE = re.compile(r'\[/(HUMAN_INPUT|ANOMALY)\]')

    def convert(self, text: str, is_yaml: bool = False) -> str:
        """Convert markdown text to HTML string."""
        if is_yaml:
            return self._wrap_pre(self._escape(text))

        lines = text.splitlines()
        html_parts: list[str] = []
        i = 0
        in_code_block = False
        in_table = False
        table_rows: list[str] = []
        in_tag_block = False
        tag_block_type = ""
        tag_block_attrs = ""
        tag_block_lines: list[str] = []
        # Track heading context for tag blocks
        current_h2 = ""
        current_h2_slug = ""
        current_h3 = ""
        current_h3_slug = ""

        while i < len(lines):
            line = lines[i]

            # Code blocks (```)
            if line.strip().startswith("```"):
                if in_code_block:
                    html_parts.append("</code></pre>")
                    in_code_block = False
                else:
                    lang = line.strip()[3:].strip()
                    cls = f' class="language-{lang}"' if lang else ""
                    html_parts.append(f"<pre><code{cls}>")
                    in_code_block = True
                i += 1
                continue

            if in_code_block:
                html_parts.append(self._escape(line))
                html_parts.append("\n")
                i += 1
                continue

            # Tag blocks: check for opening/closing tags
            open_match = self.TAG_OPEN_RE.search(line)
            close_match = self.TAG_CLOSE_RE.search(line)

            if open_match and close_match:
                # Single-line tag — render any prefix text first
                before = line[:open_match.start()].strip()
                if before:
                    html_parts.append(f'<p class="my-2">{self._inline(before)}</p>')
                tag_type = open_match.group(1)
                attrs = open_match.group(2)
                content_start = open_match.end()
                content_end = close_match.start()
                content = line[content_start:content_end].strip()
                html_parts.append(self._render_tag_block(
                    tag_type, attrs, content,
                    ctx_heading=current_h2, ctx_slug=current_h2_slug,
                    ctx_sub=current_h3, ctx_sub_slug=current_h3_slug,
                ))
                i += 1
                continue

            if open_match and not close_match:
                # Render any text before the tag opener as a paragraph
                before = line[:open_match.start()].strip()
                if before:
                    html_parts.append(f'<p class="my-2">{self._inline(before)}</p>')
                in_tag_block = True
                tag_block_type = open_match.group(1)
                tag_block_attrs = open_match.group(2)
                # Content after the opening tag on same line
                after = line[open_match.end():].strip()
                tag_block_lines = [after] if after else []
                i += 1
                continue

            if in_tag_block:
                if close_match:
                    before = line[:close_match.start()].strip()
                    if before:
                        tag_block_lines.append(before)
                    content = "\n".join(tag_block_lines)
                    html_parts.append(self._render_tag_block(
                        tag_block_type, tag_block_attrs, content,
                        ctx_heading=current_h2, ctx_slug=current_h2_slug,
                        ctx_sub=current_h3, ctx_sub_slug=current_h3_slug,
                    ))
                    in_tag_block = False
                    tag_block_lines = []
                else:
                    tag_block_lines.append(line)
                i += 1
                continue

            # Flush table if we were in one and this line isn't a table row
            if in_table and not line.strip().startswith("|"):
                html_parts.append(self._render_table(table_rows))
                table_rows = []
                in_table = False

            # Table rows
            if line.strip().startswith("|"):
                in_table = True
                table_rows.append(line)
                i += 1
                continue

            # Headings
            heading_match = re.match(r'^(#{1,6})\s+(.*)', line)
            if heading_match:
                level = len(heading_match.group(1))
                text_content = heading_match.group(2)
                slug = re.sub(r'[^a-z0-9]+', '-', text_content.lower()).strip('-')
                # Spacing: h2 gets large top margin, h3 gets moderate, h4+ gets small
                spacing = {2: "mt-10 mb-4", 3: "mt-8 mb-3", 4: "mt-6 mb-2"}.get(level, "mt-4 mb-2")
                size = {2: "text-xl font-bold", 3: "text-lg font-bold", 4: "text-base font-semibold"}.get(level, "text-sm font-semibold")
                # Track heading context for tag blocks
                if level == 2:
                    current_h2 = text_content
                    current_h2_slug = slug
                    current_h3 = ""
                    current_h3_slug = ""
                elif level == 3:
                    current_h3 = text_content
                    current_h3_slug = slug
                html_parts.append(
                    f'<h{level} id="{slug}" class="{spacing} {size}">'
                    f'<a href="#{slug}" class="hover:text-blue-600">{self._inline(text_content)}</a>'
                    f'</h{level}>'
                )
                i += 1
                continue

            # Horizontal rule
            if re.match(r'^---+\s*$', line):
                html_parts.append("<hr>")
                i += 1
                continue

            # Unordered list
            if re.match(r'^[\s]*[-*]\s', line):
                list_items: list[str] = []
                while i < len(lines) and re.match(r'^[\s]*[-*]\s', lines[i]):
                    item_text = re.sub(r'^[\s]*[-*]\s+', '', lines[i])
                    list_items.append(f"<li>{self._inline(item_text)}</li>")
                    i += 1
                html_parts.append("<ul>" + "".join(list_items) + "</ul>")
                continue

            # Ordered list
            if re.match(r'^[\s]*\d+\.\s', line):
                list_items = []
                while i < len(lines) and re.match(r'^[\s]*\d+\.\s', lines[i]):
                    item_text = re.sub(r'^[\s]*\d+\.\s+', '', lines[i])
                    list_items.append(f"<li>{self._inline(item_text)}</li>")
                    i += 1
                html_parts.append("<ol>" + "".join(list_items) + "</ol>")
                continue

            # Empty lines
            if not line.strip():
                i += 1
                continue

            # Paragraph
            para_lines: list[str] = []
            while i < len(lines) and lines[i].strip() and not lines[i].startswith("#") and not lines[i].startswith("|") and not lines[i].startswith("```") and not lines[i].startswith("---"):
                # Check for tag opens too
                if self.TAG_OPEN_RE.search(lines[i]):
                    break
                para_lines.append(lines[i])
                i += 1
            if para_lines:
                html_parts.append(f'<p class="my-2">{self._inline(" ".join(para_lines))}</p>')
                continue

            i += 1

        # Flush remaining table
        if in_table and table_rows:
            html_parts.append(self._render_table(table_rows))

        return "\n".join(html_parts)

    def _render_tag_block(self, tag_type: str, attrs: str, content: str,
                          ctx_heading: str = "", ctx_slug: str = "",
                          ctx_sub: str = "", ctx_sub_slug: str = "") -> str:
        """Render a tag block as a highlighted div. Returns empty string if no content."""
        # Skip empty tag blocks entirely
        if not content.strip():
            return ""

        attr_dict = dict(re.findall(r'(\w+)=(\S+)', attrs))
        tag_id = attr_dict.get("id", "")
        source = attr_dict.get("source", "")

        if tag_type == "HUMAN_INPUT":
            color_classes = "bg-amber-50 border-l-4 border-amber-500"
            icon = "&#x2753;"  # question mark
            label = "Human Input Required"
        else:
            color_classes = "bg-red-50 border-l-4 border-red-500"
            icon = "&#x26A0;"  # warning
            label = "Anomaly Detected"

        content_html = self._inline(self._escape(content)).replace("\n", "<br>")

        # Build context breadcrumb (hidden by default, shown when filtering)
        ctx_parts = []
        if ctx_heading:
            ctx_parts.append(f'<span data-target="#{self._escape(ctx_slug)}" class="ctx-link text-blue-600 hover:underline cursor-pointer">{self._escape(ctx_heading)}</span>')
        if ctx_sub:
            ctx_parts.append(f'<span data-target="#{self._escape(ctx_sub_slug)}" class="ctx-link text-blue-600 hover:underline cursor-pointer">{self._escape(ctx_sub)}</span>')
        ctx_html = ""
        if ctx_parts:
            breadcrumb = ' <span class="text-gray-400">›</span> '.join(ctx_parts)
            ctx_html = (
                f'<div class="tag-context hidden text-xs text-gray-500 mb-2 pb-2 border-b border-gray-200">'
                f'{breadcrumb}'
                f'</div>'
            )

        return (
            f'<div class="tag-block {color_classes} p-4 my-4 rounded-r" '
            f'data-tag-type="{tag_type}" data-tag-id="{tag_id}">'
            f'{ctx_html}'
            f'<div class="flex items-center gap-2 font-semibold text-sm mb-1">'
            f'<span>{icon}</span>'
            f'<span>{label}</span>'
            f'<code class="text-xs bg-gray-200 px-1 rounded">{tag_id}</code>'
            f'{"<code class=&quot;text-xs bg-gray-200 px-1 rounded&quot;>" + self._escape(source) + "</code>" if source else ""}'
            f'</div>'
            f'<div class="text-sm">{content_html}</div>'
            f'</div>'
        )

    def _render_table(self, rows: list[str]) -> str:
        """Render markdown table rows as HTML table."""
        if len(rows) < 2:
            return ""

        html = '<table class="min-w-full border-collapse my-4">'

        # Header row
        headers = [c.strip() for c in rows[0].strip("|").split("|")]
        html += "<thead><tr>"
        for h in headers:
            html += f'<th class="border border-gray-300 px-3 py-2 bg-gray-100 text-left text-sm font-semibold">{self._inline(h)}</th>'
        html += "</tr></thead>"

        # Skip separator row (index 1)
        html += "<tbody>"
        for row in rows[2:]:
            cells = [c.strip() for c in row.strip("|").split("|")]
            html += "<tr>"
            for cell in cells:
                html += f'<td class="border border-gray-300 px-3 py-2 text-sm">{self._inline(cell)}</td>'
            html += "</tr>"
        html += "</tbody></table>"
        return html

    def _inline(self, text: str) -> str:
        """Process inline markdown: bold, italic, code, links."""
        # Code spans
        text = re.sub(r'`([^`]+)`', r'<code class="bg-gray-200 px-1 rounded text-sm">\1</code>', text)
        # Bold
        text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
        # Italic
        text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
        # Links
        text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2" class="text-blue-600 underline">\1</a>', text)
        return text

    def _escape(self, text: str) -> str:
        return (
            text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
        )

    def _wrap_pre(self, text: str) -> str:
        return f'<pre class="bg-gray-900 text-green-400 p-4 rounded overflow-x-auto text-sm my-3"><code>{text}</code></pre>'


# ---------------------------------------------------------------------------
# HTML Report generator
# ---------------------------------------------------------------------------

# File render order for the report
FILE_ORDER = [
    "spec.md",
    "inventory.yml",
    "source-mapping.md",
    # feature files inserted dynamically
    "checklists/extraction-review.md",
]


class ReportGenerator:
    """Generates a self-contained report.html."""

    def __init__(self):
        self.md_converter = MarkdownToHtml()

    def generate(self, tags: list[Tag], spec_dir: Path) -> str:
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

        hi_tags = [t for t in tags if t.tag_type == "HUMAN_INPUT"]
        ano_tags = [t for t in tags if t.tag_type == "ANOMALY"]

        # Collect files in order
        sections = self._collect_sections(spec_dir)

        # Convert each section to HTML
        section_html_parts: list[str] = []
        for sec_path, sec_label in sections:
            is_yaml = sec_path.suffix in (".yml", ".yaml")
            content = sec_path.read_text(encoding="utf-8")
            body_html = self.md_converter.convert(content, is_yaml=is_yaml)
            is_feature = sec_path.suffix == ".feature"

            if is_feature:
                section_html_parts.append(
                    f'<details class="my-4 border rounded">'
                    f'<summary class="px-4 py-2 bg-gray-50 cursor-pointer font-semibold">{_escape(sec_label)}</summary>'
                    f'<div class="p-4">{body_html}</div>'
                    f'</details>'
                )
            else:
                section_html_parts.append(
                    f'<section class="my-6">'
                    f'<h2 class="text-xl font-bold border-b pb-2 mb-4">{_escape(sec_label)}</h2>'
                    f'{body_html}'
                    f'</section>'
                )

        sections_joined = "\n".join(section_html_parts)

        return HTML_TEMPLATE.format(
            title=f"Spekkio Report — {spec_dir.name}",
            generated=now,
            spec_dir=str(spec_dir),
            hi_count=len(hi_tags),
            ano_count=len(ano_tags),
            total_count=len(tags),
            sections=sections_joined,
        )

    def _collect_sections(self, spec_dir: Path) -> list[tuple[Path, str]]:
        """Return ordered list of (file_path, display_label)."""
        sections: list[tuple[Path, str]] = []

        for rel in FILE_ORDER:
            fpath = spec_dir / rel
            if fpath.exists():
                sections.append((fpath, rel))

            # After source-mapping.md, insert feature files
            if rel == "source-mapping.md":
                features_dir = spec_dir / "features" / "characterization"
                if features_dir.is_dir():
                    for ff in sorted(features_dir.glob("*.feature")):
                        label = f"features/characterization/{ff.name}"
                        sections.append((ff, label))

        return sections


# ---------------------------------------------------------------------------
# HTML template
# ---------------------------------------------------------------------------

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .tag-block {{ transition: opacity 0.2s; }}
    .dimmed {{ opacity: 0.15; pointer-events: none; }}
    body {{ font-family: ui-sans-serif, system-ui, sans-serif; }}
  </style>
</head>
<body class="bg-gray-50 min-h-screen">

  <!-- Sticky header -->
  <header class="sticky top-0 z-50 bg-white shadow-sm border-b">
    <div class="max-w-5xl mx-auto px-6 py-3 flex flex-wrap items-center justify-between gap-3">
      <div>
        <h1 class="text-lg font-bold">Spekkio Report</h1>
        <p class="text-xs text-gray-500">{spec_dir} &middot; {generated}</p>
      </div>
      <div class="flex gap-2" id="filters">
        <button data-filter="all"
                class="filter-btn px-3 py-1 rounded-full text-sm font-medium bg-gray-800 text-white">
          All ({total_count})
        </button>
        <button data-filter="HUMAN_INPUT"
                class="filter-btn px-3 py-1 rounded-full text-sm font-medium bg-amber-100 text-amber-800 border border-amber-300">
          Human Input ({hi_count})
        </button>
        <button data-filter="ANOMALY"
                class="filter-btn px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-300">
          Anomalies ({ano_count})
        </button>
      </div>
    </div>
  </header>

  <!-- Summary -->
  <main class="max-w-5xl mx-auto px-6 py-6">
    <div class="grid grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-lg shadow p-4 text-center">
        <div class="text-3xl font-bold">{total_count}</div>
        <div class="text-sm text-gray-500">Total Items</div>
      </div>
      <div class="bg-amber-50 rounded-lg shadow p-4 text-center border-t-4 border-amber-500">
        <div class="text-3xl font-bold text-amber-700">{hi_count}</div>
        <div class="text-sm text-amber-600">Human Input</div>
      </div>
      <div class="bg-red-50 rounded-lg shadow p-4 text-center border-t-4 border-red-500">
        <div class="text-3xl font-bold text-red-700">{ano_count}</div>
        <div class="text-sm text-red-600">Anomalies</div>
      </div>
    </div>

    <!-- Rendered spec content -->
    {sections}
  </main>

  <!-- Filter JS -->
  <script>
    (function() {{
      const buttons = document.querySelectorAll('.filter-btn');
      const summaryGrid = document.querySelector('.grid');
      let activeFilter = 'all';

      buttons.forEach(btn => {{
        btn.addEventListener('click', () => {{
          activeFilter = btn.dataset.filter;
          buttons.forEach(b => b.classList.remove('ring-2', 'ring-offset-1', 'ring-gray-400'));
          btn.classList.add('ring-2', 'ring-offset-1', 'ring-gray-400');
          applyFilter();
        }});
      }});

      function applyFilter() {{
        const sections = document.querySelectorAll('main > section, main > details');

        if (activeFilter === 'all') {{
          summaryGrid.style.display = '';
          // Reset all hidden elements inside main
          document.querySelectorAll('main [style*="display: none"], main [style*="display:none"]').forEach(el => {{
            el.style.display = '';
          }});
          sections.forEach(s => s.style.display = '');
          // Hide context breadcrumbs in "all" mode
          document.querySelectorAll('.tag-context').forEach(el => el.classList.add('hidden'));
          return;
        }}

        // Show context breadcrumbs on matching tag blocks
        document.querySelectorAll('.tag-block').forEach(block => {{
          const ctx = block.querySelector('.tag-context');
          if (!ctx) return;
          if (block.dataset.tagType === activeFilter) {{
            ctx.classList.remove('hidden');
          }} else {{
            ctx.classList.add('hidden');
          }}
        }});

        // Hide summary cards when filtering
        summaryGrid.style.display = 'none';

        sections.forEach(section => {{
          const isDetails = section.tagName === 'DETAILS';
          // The container holding content elements
          const container = isDetails
            ? section.querySelector('.p-4') || section
            : section;
          const children = Array.from(container.children);

          // Check if this section has any matching tag blocks
          const hasMatch = children.some(el =>
            el.classList.contains('tag-block') && el.dataset.tagType === activeFilter
          );

          if (!hasMatch) {{
            section.style.display = 'none';
            return;
          }}

          section.style.display = '';
          if (isDetails) section.open = true;

          // Build a set of indices to show: matching tags + one preceding sibling for context
          const showIndices = new Set();
          children.forEach((el, i) => {{
            if (el.classList.contains('tag-block') && el.dataset.tagType === activeFilter) {{
              showIndices.add(i);
              if (i > 0) showIndices.add(i - 1);  // preceding context
            }}
          }});

          // Always show the first child if it's a heading (section title)
          if (children.length > 0 && /^H[1-6]$/.test(children[0].tagName)) {{
            showIndices.add(0);
          }}

          children.forEach((el, i) => {{
            el.style.display = showIndices.has(i) ? '' : 'none';
          }});

          // For sections, ensure the h2 title is visible
          const h2 = section.querySelector(':scope > h2');
          if (h2) h2.style.display = '';
        }});
      }}

      // Context breadcrumb links: switch to All, then scroll to anchor
      document.addEventListener('click', (e) => {{
        const link = e.target.closest('.ctx-link');
        if (!link) return;
        const hash = link.dataset.target;
        // Switch to All
        activeFilter = 'all';
        buttons.forEach(b => b.classList.remove('ring-2', 'ring-offset-1', 'ring-gray-400'));
        buttons[0].classList.add('ring-2', 'ring-offset-1', 'ring-gray-400');
        applyFilter();
        // Scroll to target
        const target = document.querySelector(hash);
        if (target) {{
          target.scrollIntoView({{ behavior: 'smooth', block: 'start' }});
          // Brief highlight
          target.style.backgroundColor = '#fef3c7';
          setTimeout(() => target.style.backgroundColor = '', 2000);
        }}
      }});

      buttons[0].classList.add('ring-2', 'ring-offset-1', 'ring-gray-400');
    }})();
  </script>
</body>
</html>"""


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _rel_path(file_path: str, base: Path) -> str:
    """Try to make file_path relative to base."""
    try:
        return str(Path(file_path).relative_to(base))
    except ValueError:
        return file_path


def _escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Generate triage summary and HTML report from Spekkio extraction output."
    )
    parser.add_argument(
        "spec_dir",
        help="Path to the spec directory (e.g., specs/001-atm/)",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--triage-only",
        action="store_true",
        help="Only generate triage.md",
    )
    group.add_argument(
        "--report-only",
        action="store_true",
        help="Only generate report.html",
    )
    args = parser.parse_args()

    spec_dir = Path(args.spec_dir).resolve()
    if not spec_dir.is_dir():
        print(f"Error: {spec_dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    # Parse tags
    tag_parser = TagParser()
    tags = tag_parser.parse_directory(spec_dir)

    hi_count = sum(1 for t in tags if t.tag_type == "HUMAN_INPUT")
    ano_count = sum(1 for t in tags if t.tag_type == "ANOMALY")
    print(f"Found {len(tags)} tags: {hi_count} HUMAN_INPUT, {ano_count} ANOMALY")

    if not args.report_only:
        triage_gen = TriageGenerator()
        triage_md = triage_gen.generate(tags, spec_dir)
        triage_path = spec_dir / "triage.md"
        triage_path.write_text(triage_md, encoding="utf-8")
        print(f"Wrote {triage_path}")

    if not args.triage_only:
        report_gen = ReportGenerator()
        report_html = report_gen.generate(tags, spec_dir)
        report_path = spec_dir / "report.html"
        report_path.write_text(report_html, encoding="utf-8")
        print(f"Wrote {report_path}")

    # Print tag manifest
    if tags:
        hi_ids = [t.id for t in tags if t.tag_type == "HUMAN_INPUT"]
        ano_ids = [t.id for t in tags if t.tag_type == "ANOMALY"]
        print("\nTag manifest:")
        if hi_ids:
            print(f"  HUMAN_INPUT: {hi_ids[0]}..{hi_ids[-1]} ({len(hi_ids)} items)")
        if ano_ids:
            print(f"  ANOMALY:     {ano_ids[0]}..{ano_ids[-1]} ({len(ano_ids)} items)")


if __name__ == "__main__":
    main()
