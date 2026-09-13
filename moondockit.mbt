///|
/// A source page in a MoonDocKit documentation site.
pub(all) struct DocPage {
  title : String
  slug : String
  source : String
}

///|
/// A rendered page that can be written to disk by a CLI package.
pub(all) struct RenderedPage {
  path : String
  html : String
}

///|
/// A generated output file ready for a CLI to write to disk.
pub(all) struct OutputFile {
  path : String
  content : String
}

///|
/// File metadata derived from a generated output manifest.
pub(all) struct OutputFileInfo {
  path : String
  kind : String
  byte_count : Int
}

///|
/// Aggregate report for generated output files.
pub(all) struct BuildReport {
  file_count : Int
  html_count : Int
  data_count : Int
  total_bytes : Int
  files : Array[OutputFileInfo]
}

///|
/// One quality gate check result.
pub(all) struct QualityCheck {
  name : String
  passed : Bool
  message : String
}

///|
/// Aggregate quality gate result for a documentation site.
pub(all) struct QualityGate {
  passed : Bool
  score : Int
  checks : Array[QualityCheck]
}

///|
/// Searchable text metadata for one route.
pub(all) struct SearchEntry {
  title : String
  path : String
  text : String
  tags : Array[String]
}

///|
/// One public declaration extracted from a generated MoonBit interface.
pub(all) struct ApiSymbol {
  kind : String
  name : String
  signature : String
  arity : Int
  return_type : String
}

///|
/// Public package information extracted from a `.mbti` interface.
pub(all) struct ApiReference {
  package_name : String
  symbols : Array[ApiSymbol]
}

///|
/// Aggregate metadata for a documentation site.
pub(all) struct SiteSummary {
  page_count : Int
  output_count : Int
  search_entry_count : Int
  tag_count : Int
}

///|
/// Content metrics for one parsed documentation page.
pub(all) struct DocumentMetrics {
  heading_count : Int
  paragraph_count : Int
  list_item_count : Int
  code_block_count : Int
  word_count : Int
  reading_minutes : Int
}

///|
/// Aggregate content metrics for a documentation site.
pub(all) struct SiteMetrics {
  page_count : Int
  heading_count : Int
  code_block_count : Int
  word_count : Int
  reading_minutes : Int
}

///|
/// Visual theme values used by generated HTML pages.
pub(all) struct SiteTheme {
  background : String
  surface : String
  text : String
  accent : String
  border : String
  code_background : String
  code_text : String
  sidebar_width_px : Int
  content_width_px : Int
}

///|
/// Page template options used by generated HTML pages.
pub(all) struct SiteOptions {
  language : String
  description : String
  site_url : String
  footer : String
}

///|
/// Severity level for site validation diagnostics.
pub(all) enum DiagnosticLevel {
  DiagError
  DiagWarning
}

///|
/// A validation finding for a site or one source page.
pub(all) struct SiteDiagnostic {
  level : DiagnosticLevel
  code : String
  message : String
  page : String?
}

///|
/// Site validation result returned before rendering or publishing.
pub(all) struct ValidationReport {
  diagnostics : Array[SiteDiagnostic]
}

///|
/// Planned route metadata for one documentation page.
pub(all) struct RouteEntry {
  title : String
  slug : String
  path : String
  order : Int?
  tags : Array[String]
}

///|
/// Parsed page metadata from a leading front matter block.
pub(all) struct FrontMatter {
  title : String?
  order : Int?
  tags : Array[String]
  fields : Array[(String, String)]
}

///|
/// Markdown source split into metadata and body blocks.
pub(all) struct ParsedDocument {
  front_matter : FrontMatter
  blocks : Array[MarkdownBlock]
}

///|
/// A heading entry extracted from a source page.
pub(all) struct TocItem {
  level : Int
  title : String
  anchor : String
}

///|
/// A heading with a page-unique anchor.
pub(all) struct AnchoredHeading {
  level : Int
  title : String
  anchor : String
}

///|
/// Block-level Markdown nodes used by the documentation pipeline.
pub(all) enum MarkdownBlock {
  Heading(Int, String)
  Paragraph(String)
  UnorderedList(Array[String])
  BlockQuote(String)
  CodeBlock(String, String)
}

///|
/// Return empty front matter metadata.
pub fn empty_front_matter() -> FrontMatter {
  { title: None, order: None, tags: [], fields: [], }
}

///|
/// Parse a generated MoonBit interface into public API declarations.
pub fn parse_mbti(source : String) -> ApiReference {
  let symbols : Array[ApiSymbol] = []
  let mut package_name = ""
  let lines = source.split("\n").collect()
  let mut i = 0
  while i < lines.length() {
    let line = lines[i].to_owned().trim().to_owned()
    if line.has_prefix("package \"") && line.has_suffix("\"") {
      package_name = line[9:line.length() - 1].to_owned()
    } else if line.has_prefix("pub fn ") {
      symbols.push({
        kind: "function",
        name: declaration_name(line, "pub fn "),
        signature: line,
        arity: function_arity(line),
        return_type: return_type(line),
      })
    } else if line.has_prefix("pub(all) struct ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "struct",
        name: declaration_name(line, "pub(all) struct "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    } else if line.has_prefix("pub(all) enum ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "enum",
        name: declaration_name(line, "pub(all) enum "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    } else if line.has_prefix("pub trait ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "trait",
        name: declaration_name(line, "pub trait "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    }
    i = i + 1
  }
  { package_name, symbols, }
}

///|
/// Convert a generated MoonBit interface into a documentation page.
pub fn mbti_to_page(source : String) -> DocPage {
  let api = parse_mbti(source)
  let title = if api.package_name == "" {
    "MoonBit API"
  } else {
    api.package_name + " API"
  }
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: MoonBit API\norder: 900\ntags: [api, moonbit]\n---\n",
  )
  out.write_string("# MoonBit API\n\n")
  if api.package_name != "" {
    out.write_string("Package `")
    out.write_string(api.package_name)
    out.write_string("` exposes ")
    out.write_string(api.symbols.length().to_string())
    out.write_string(" public declarations.\n\n")
  }
  if api.symbols.length() > 0 {
    out.write_string("## API Summary\n\n")
    let kinds = ["function", "struct", "enum", "trait"]
    for kind in kinds {
      let count = api.symbols.filter(symbol => symbol.kind == kind).length()
      if count > 0 {
        out.write_string("- ")
        out.write_string(api_section_title(kind))
        out.write_string(": ")
        out.write_string(count.to_string())
        out.write_string("\n")
      }
    }
    out.write_string("\n")
    out.write_string("## Review Notes\n\n")
    out.write_string(
      "- Source: generated `.mbti` package interface from `moon info`.\n",
    )
    out.write_string(
      "- Navigation: symbol index links point to each generated declaration.\n",
    )
    out.write_string(
      "- Function entries include parameter counts and return types when available.\n\n",
    )
    out.write_string("## Symbol Index\n\n")
    for kind in kinds {
      let matching = api.symbols.filter(symbol => symbol.kind == kind)
      if matching.length() > 0 {
        out.write_string("### ")
        out.write_string(api_section_title(kind))
        out.write_string("\n\n")
        for symbol in matching {
          out.write_string("- [")
          out.write_string(symbol.name)
          out.write_string("](#")
          out.write_string(slugify(symbol.name))
          out.write_string(")\n")
        }
        out.write_string("\n")
      }
    }
  }
  let kinds = ["function", "struct", "enum", "trait"]
  for kind in kinds {
    let matching = api.symbols.filter(symbol => symbol.kind == kind)
    if matching.length() > 0 {
      out.write_string("## ")
      out.write_string(api_section_title(kind))
      out.write_string("\n\n")
      for symbol in matching {
        out.write_string("### ")
        out.write_string(symbol.name)
        out.write_string("\n\n")
        if symbol.kind == "function" {
          out.write_string("- Parameters: ")
          out.write_string(symbol.arity.to_string())
          if symbol.return_type != "" {
            out.write_string("\n- Returns: `")
            out.write_string(symbol.return_type)
            out.write_string("`")
          }
        }
        out.write_string("\n\n```mbt\n")
        out.write_string(symbol.signature)
        out.write_string("\n```\n\n")
      }
    }
  }
  { title, slug: "api-reference", source: out.to_string(), }
}

///|
fn declaration_name(line : String, prefix : String) -> String {
  let rest = line[prefix.length():].to_owned()
  let mut end = rest.length()
  for index, ch in rest {
    if ch == '(' || ch == '[' || ch == ' ' || ch == '{' {
      end = index
      break
    }
  }
  rest[0:end].to_owned()
}

///|
fn function_arity(signature : String) -> Int {
  let start = find_char(signature, '(')
  let finish = find_matching_paren(signature, start)
  if start < 0 || finish <= start + 1 {
    return 0
  }
  let args = signature[start + 1:finish].to_owned().trim().to_owned()
  if args == "" {
    0
  } else {
    count_top_level_commas(args) + 1
  }
}

///|
fn return_type(signature : String) -> String {
  match signature.split_once(" -> ") {
    Some((_, result)) => result.trim().to_owned()
    None => ""
  }
}

///|
fn find_char(input : String, target : Char) -> Int {
  for index, ch in input {
    if ch == target {
      return index
    }
  }
  -1
}

///|
fn find_matching_paren(input : String, start : Int) -> Int {
  if start < 0 {
    return -1
  }
  let mut depth = 0
  for index, ch in input {
    if index < start {
      continue
    }
    if ch == '(' {
      depth = depth + 1
    } else if ch == ')' {
      depth = depth - 1
      if depth == 0 {
        return index
      }
    }
  }
  -1
}

///|
fn count_top_level_commas(input : String) -> Int {
  let mut count = 0
  let mut depth = 0
  for _, ch in input {
    if ch == '(' || ch == '[' || ch == '{' {
      depth = depth + 1
    } else if ch == ')' || ch == ']' || ch == '}' {
      if depth > 0 {
        depth = depth - 1
      }
    } else if ch == ',' && depth == 0 {
      count = count + 1
    }
  }
  count
}

///|
fn capture_interface_block(
  lines : Array[StringView],
  start : Int,
) -> (String, Int) {
  let out = StringBuilder()
  let mut i = start
  while i < lines.length() {
    let line = lines[i].to_owned()
    if i > start {
      out.write_char('\n')
    }
    out.write_string(line)
    if line.trim().to_owned() == "}" {
      return (out.to_string(), i)
    }
    i = i + 1
  }
  (out.to_string(), i - 1)
}

///|
fn api_section_title(kind : String) -> String {
  match kind {
    "function" => "Functions"
    "struct" => "Structs"
    "enum" => "Enums"
    "trait" => "Traits"
    _ => "Declarations"
  }
}

///|
/// Return the default MoonDocKit page theme.
pub fn default_theme() -> SiteTheme {
  {
    background: "#faf8f3",
    surface: "#fffdf8",
    text: "#1a1923",
    accent: "#14635a",
    border: "#e6dfd2",
    code_background: "#191b22",
    code_text: "#ece7dc",
    sidebar_width_px: 272,
    content_width_px: 760,
  }
}

///|
/// Return a warm documentation theme for package guide sites.
pub fn package_theme() -> SiteTheme {
  {
    background: "#f8faf7",
    surface: "#fffdf9",
    text: "#18231c",
    accent: "#2f7d57",
    border: "#e0e8df",
    code_background: "#161d19",
    code_text: "#e6f0e8",
    sidebar_width_px: 268,
    content_width_px: 780,
  }
}

///|
/// Return a compact theme tuned for API reference-heavy sites.
pub fn api_reference_theme() -> SiteTheme {
  {
    background: "#f8fafc",
    surface: "#fffdfd",
    text: "#16202e",
    accent: "#5b5f97",
    border: "#dde3ea",
    code_background: "#161a24",
    code_text: "#e9edf7",
    sidebar_width_px: 260,
    content_width_px: 900,
  }
}

///|
/// Return default generated page metadata and footer options.
pub fn default_site_options() -> SiteOptions {
  {
    language: "en",
    description: "",
    site_url: "",
    footer: "Generated by MoonDocKit",
  }
}

///|
/// Site metadata and pages.
pub(all) struct DocSite {
  title : String
  pages : Array[DocPage]
}

///|
/// Build a stable route table for all pages in a site.
pub fn plan_routes(site : DocSite) -> Array[RouteEntry] {
  let routes : Array[RouteEntry] = []
  for page in site.pages {
    routes.push(route_for_page(page))
  }
  routes.sort_by(compare_routes)
  routes
}

///|
fn compare_routes(left : RouteEntry, right : RouteEntry) -> Int {
  match (left.order, right.order) {
    (Some(a), Some(b)) =>
      if a != b {
        a - b
      } else {
        compare_route_title(left, right)
      }
    (Some(_), None) => -1
    (None, Some(_)) => 1
    (None, None) => compare_route_title(left, right)
  }
}

///|
fn compare_route_title(left : RouteEntry, right : RouteEntry) -> Int {
  let by_title = left.title.compare(right.title)
  if by_title != 0 {
    by_title
  } else {
    left.slug.compare(right.slug)
  }
}

///|
/// Escape text for safe HTML output.
pub fn html_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// Convert a heading or page title into a stable URL slug.
pub fn slugify(title : String) -> String {
  let out = StringBuilder(size_hint=title.length())
  let mut pending_dash = false
  let mut wrote = false
  for _, ch in title {
    let lower = ch.to_ascii_lowercase()
    if lower is ('a'..='z') || lower is ('0'..='9') {
      if pending_dash && wrote {
        out.write_char('-')
      }
      out.write_char(lower)
      pending_dash = false
      wrote = true
    } else {
      pending_dash = wrote
    }
  }
  out.to_string()
}

///|
/// Extract level-1 and level-2 headings from Markdown source.
pub fn extract_toc(markdown : String) -> Array[TocItem] {
  blocks_to_toc(parse_blocks(markdown))
}

///|
/// Extract heading entries from parsed Markdown blocks.
pub fn blocks_to_toc(blocks : Array[MarkdownBlock]) -> Array[TocItem] {
  extract_headings(blocks).map(heading => {
    level: heading.level,
    title: heading.title,
    anchor: heading.anchor,
  })
}

///|
/// Extract headings and assign page-unique anchors.
pub fn extract_headings(
  blocks : Array[MarkdownBlock],
) -> Array[AnchoredHeading] {
  let headings : Array[AnchoredHeading] = []
  let seen : Array[String] = []
  for block in blocks {
    match block {
      Heading(level, title) => {
        let base = slugify(title)
        let anchor = unique_anchor(base, seen)
        seen.push(anchor)
        headings.push({ level, title, anchor, })
      }
      _ => ()
    }
  }
  headings
}

///|
fn unique_anchor(base : String, seen : Array[String]) -> String {
  let stable_base = if base == "" { "section" } else { base }
  let mut count = 1
  for item in seen {
    if item == stable_base || item.has_prefix(stable_base + "-") {
      count = count + 1
    }
  }
  if count == 1 {
    stable_base
  } else {
    stable_base + "-" + count.to_string()
  }
}

///|
/// Parse a useful Markdown subset into block-level nodes.
pub fn parse_blocks(markdown : String) -> Array[MarkdownBlock] {
  parse_document(markdown).blocks
}

///|
/// Parse optional front matter and Markdown blocks.
pub fn parse_document(markdown : String) -> ParsedDocument {
  let (front_matter, body) = split_front_matter(markdown)
  { front_matter, blocks: parse_body_blocks(body), }
}

///|
fn split_front_matter(markdown : String) -> (FrontMatter, String) {
  let lines = markdown.split("\n").map(line => line.to_owned()).to_array()
  if lines.length() == 0 || lines[0].trim().to_owned() != "---" {
    return (empty_front_matter(), markdown)
  }
  let meta_lines : Array[String] = []
  let body_lines : Array[String] = []
  let mut in_meta = true
  let mut closed = false
  for i in 1..<lines.length() {
    let line = lines[i]
    if in_meta && line.trim().to_owned() == "---" {
      in_meta = false
      closed = true
      continue
    }
    if in_meta {
      meta_lines.push(line)
    } else {
      body_lines.push(line)
    }
  }
  if !closed {
    return (empty_front_matter(), markdown)
  }
  (parse_front_matter_lines(meta_lines), body_lines.join("\n"))
}

///|
fn parse_front_matter_lines(lines : Array[String]) -> FrontMatter {
  let fields : Array[(String, String)] = []
  let tags : Array[String] = []
  let mut title : String? = None
  let mut order : Int? = None
  for raw in lines {
    let line = raw.trim().to_owned()
    if line == "" || line.has_prefix("#") {
      continue
    }
    match line.split_once(":") {
      Some((key_view, value_view)) => {
        let key = key_view.to_owned().trim().to_owned()
        let value = value_view.to_owned().trim().to_owned()
        fields.push((key, value))
        if key == "title" {
          title = Some(unquote(value))
        } else if key == "order" {
          order = parse_positive_int(value)
        } else if key == "tags" {
          for tag in parse_tags(value) {
            tags.push(tag)
          }
        }
      }
      None => ()
    }
  }
  { title, order, tags, fields, }
}

///|
fn parse_tags(value : String) -> Array[String] {
  let inner = strip_brackets(value)
  let tags : Array[String] = []
  for item in inner.split(",") {
    let tag = unquote(item.to_owned().trim().to_owned())
    if tag != "" {
      tags.push(tag)
    }
  }
  tags
}

///|
fn strip_brackets(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.length() >= 2 && trimmed.has_prefix("[") && trimmed.has_suffix("]") {
    trimmed[1:trimmed.length() - 1].to_owned()
  } else {
    trimmed
  }
}

///|
fn unquote(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.length() >= 2 {
    let first = trimmed[0]
    let last = trimmed[trimmed.length() - 1]
    if (first == '"' && last == '"') || (first == '\'' && last == '\'') {
      return trimmed[1:trimmed.length() - 1].to_owned()
    }
  }
  trimmed
}

///|
fn parse_positive_int(value : String) -> Int? {
  let trimmed = value.trim().to_owned()
  if trimmed == "" {
    return None
  }
  let mut result = 0
  for _, ch in trimmed {
    if !(ch is ('0'..='9')) {
      return None
    }
    result = result * 10 + (ch.to_int() - '0'.to_int())
  }
  Some(result)
}

///|
fn parse_body_blocks(markdown : String) -> Array[MarkdownBlock] {
  let blocks : Array[MarkdownBlock] = []
  let mut in_code = false
  let mut code_language = ""
  let code = StringBuilder()
  let mut in_list = false
  let list_items : Array[String] = []
  let paragraph = StringBuilder()
  for raw in markdown.split("\n") {
    let line = raw.to_owned()
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("```") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      if in_code {
        blocks.push(CodeBlock(code_language, code.to_string()))
        code.reset()
        code_language = ""
      } else {
        code.reset()
        code_language = trimmed[3:].to_owned().trim().to_owned()
      }
      in_code = !in_code
      continue
    }
    if in_code {
      code.write_string(line)
      code.write_char('\n')
      continue
    }
    if trimmed == "" {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      continue
    }
    if trimmed.has_prefix("# ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(1, trimmed[2:].to_owned()))
    } else if trimmed.has_prefix("## ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(2, trimmed[3:].to_owned()))
    } else if trimmed.has_prefix("### ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(3, trimmed[4:].to_owned()))
    } else if trimmed.has_prefix("- ") {
      close_pending_paragraph(blocks, paragraph)
      in_list = true
      list_items.push(trimmed[2:].to_owned())
    } else if trimmed.has_prefix("> ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(BlockQuote(trimmed[2:].to_owned()))
    } else {
      if in_list {
        close_pending_list(blocks, list_items, in_list)
        in_list = false
      }
      append_paragraph_line(paragraph, trimmed)
    }
  }
  close_pending_paragraph(blocks, paragraph)
  if in_list {
    blocks.push(UnorderedList(list_items.copy()))
  }
  if in_code {
    blocks.push(CodeBlock(code_language, code.to_string()))
  }
  blocks
}

///|
fn append_paragraph_line(paragraph : StringBuilder, line : String) -> Unit {
  if !paragraph.is_empty() {
    paragraph.write_char(' ')
  }
  paragraph.write_string(line)
}

///|
fn close_pending_paragraph(
  blocks : Array[MarkdownBlock],
  paragraph : StringBuilder,
) -> Unit {
  if !paragraph.is_empty() {
    blocks.push(Paragraph(paragraph.to_string()))
    paragraph.reset()
  }
}

///|
fn close_pending_list(
  blocks : Array[MarkdownBlock],
  list_items : Array[String],
  is_open : Bool,
) -> Unit {
  if is_open {
    blocks.push(UnorderedList(list_items.copy()))
    list_items.clear()
  }
}

///|
/// Render parsed Markdown blocks to HTML.
pub fn render_blocks(blocks : Array[MarkdownBlock]) -> String {
  let out = StringBuilder()
  let headings = extract_headings(blocks)
  let mut heading_index = 0
  for block in blocks {
    match block {
      Heading(level, text) => {
        let anchor = headings[heading_index].anchor
        heading_index = heading_index + 1
        out.write_string("<h")
        out.write_string(level.to_string())
        out.write_string(" id=\"")
        out.write_string(anchor)
        out.write_string("\">")
        out.write_string(html_escape(text))
        out.write_string("</h")
        out.write_string(level.to_string())
        out.write_string(">\n")
      }
      Paragraph(text) => {
        out.write_string("<p>")
        out.write_string(render_inline(text))
        out.write_string("</p>\n")
      }
      UnorderedList(items) => {
        out.write_string("<ul>\n")
        for item in items {
          out.write_string("<li>")
          out.write_string(render_inline(item))
          out.write_string("</li>\n")
        }
        out.write_string("</ul>\n")
      }
      BlockQuote(text) => {
        out.write_string("<blockquote>")
        out.write_string(render_inline(text))
        out.write_string("</blockquote>\n")
      }
      CodeBlock(language, code) => {
        if language == "" {
          out.write_string("<pre><code>")
        } else {
          out.write_string("<pre><code class=\"language-")
          out.write_string(html_escape(slugify(language)))
          out.write_string("\">")
        }
        out.write_string(html_escape(code))
        out.write_string("</code></pre>\n")
      }
    }
  }
  out.to_string()
}

///|
/// Render a useful subset of Markdown into HTML.
pub fn render_markdown(markdown : String) -> String {
  render_blocks(parse_blocks(markdown))
}

///|
fn render_inline(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  let mut i = 0
  while i < input.length() {
    if starts_with_at(input, i, "`") {
      match find_char_from(input, i + 1, '`') {
        Some(close) => {
          out.write_string("<code>")
          out.write_string(html_escape(input[i + 1:close].to_owned()))
          out.write_string("</code>")
          i = close + 1
        }
        None => {
          out.write_string("`")
          i = i + 1
        }
      }
    } else if starts_with_at(input, i, "**") {
      match find_marker_from(input, i + 2, "**") {
        Some(close) => {
          out.write_string("<strong>")
          out.write_string(render_inline(input[i + 2:close].to_owned()))
          out.write_string("</strong>")
          i = close + 2
        }
        None => {
          out.write_string("**")
          i = i + 2
        }
      }
    } else if starts_with_at(input, i, "*") {
      match find_char_from(input, i + 1, '*') {
        Some(close) => {
          out.write_string("<em>")
          out.write_string(render_inline(input[i + 1:close].to_owned()))
          out.write_string("</em>")
          i = close + 1
        }
        None => {
          out.write_string("*")
          i = i + 1
        }
      }
    } else if starts_with_at(input, i, "![") {
      match parse_link(input, i + 1) {
        Some((close, label, src)) => {
          out.write_string("<img src=\"")
          out.write_string(html_escape(safe_href(src)))
          out.write_string("\" alt=\"")
          out.write_string(html_escape(label))
          out.write_string("\" loading=\"lazy\">")
          i = close + 1
        }
        None => {
          out.write_string("!")
          i = i + 1
        }
      }
    } else if input[i] == '<' {
      match parse_autolink(input, i) {
        Some((close, href)) => {
          out.write_string("<a href=\"")
          out.write_string(html_escape(href))
          out.write_string("\">")
          out.write_string(html_escape(href))
          out.write_string("</a>")
          i = close + 1
        }
        None => {
          out.write_string("&lt;")
          i = i + 1
        }
      }
    } else if input[i] == '[' {
      match parse_link(input, i) {
        Some((close, label, href)) => {
          out.write_string("<a href=\"")
          out.write_string(html_escape(safe_href(href)))
          out.write_string("\">")
          out.write_string(render_inline(label))
          out.write_string("</a>")
          i = close + 1
        }
        None => {
          out.write_string(html_escape(input[i:i + 1].to_owned()))
          i = i + 1
        }
      }
    } else {
      out.write_string(html_escape(input[i:i + 1].to_owned()))
      i = i + 1
    }
  }
  out.to_string()
}

///|
fn starts_with_at(input : String, index : Int, marker : String) -> Bool {
  index + marker.length() <= input.length() &&
  input[index:index + marker.length()].to_owned() == marker
}

///|
fn find_char_from(input : String, start : Int, target : UInt16) -> Int? {
  let mut i = start
  while i < input.length() {
    if input[i] == target {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
fn find_marker_from(input : String, start : Int, marker : String) -> Int? {
  let mut i = start
  while i + marker.length() <= input.length() {
    if starts_with_at(input, i, marker) {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
fn parse_link(input : String, start : Int) -> (Int, String, String)? {
  match find_char_from(input, start + 1, ']') {
    Some(label_end) =>
      if label_end + 1 < input.length() && input[label_end + 1] == '(' {
        match find_char_from(input, label_end + 2, ')') {
          Some(href_end) =>
            Some(
              (
                href_end,
                input[start + 1:label_end].to_owned(),
                input[label_end + 2:href_end].to_owned(),
              ),
            )
          None => None
        }
      } else {
        None
      }
    None => None
  }
}

///|
fn parse_autolink(input : String, start : Int) -> (Int, String)? {
  match find_char_from(input, start + 1, '>') {
    Some(close) => {
      let href = input[start + 1:close].to_owned().trim().to_owned()
      if (href.has_prefix("http://") || href.has_prefix("https://")) &&
        safe_href(href) == href {
        Some((close, href))
      } else {
        None
      }
    }
    None => None
  }
}

///|
fn safe_href(href : String) -> String {
  let value = href.trim().to_owned()
  if value.has_prefix("http://") ||
    value.has_prefix("https://") ||
    value.has_prefix("#") ||
    value.has_prefix("./") ||
    value.has_prefix("../") ||
    !value.contains(":") {
    value
  } else {
    "#"
  }
}

///|
/// Render a complete HTML page with navigation.
pub fn render_page(site : DocSite, page : DocPage) -> RenderedPage {
  render_page_with_options(site, page, default_theme(), default_site_options())
}

///|
/// Render a complete HTML page with navigation and a custom theme.
pub fn render_page_with_theme(
  site : DocSite,
  page : DocPage,
  theme : SiteTheme,
) -> RenderedPage {
  render_page_with_options(site, page, theme, default_site_options())
}

///|
/// Render a complete HTML page with custom theme and template options.
pub fn render_page_with_options(
  site : DocSite,
  page : DocPage,
  theme : SiteTheme,
  options : SiteOptions,
) -> RenderedPage {
  let route = route_for_page(page)
  let body = render_markdown(page.source)
  let toc = render_toc(extract_toc(page.source))
  let routes = plan_routes(site)
  let out = StringBuilder(size_hint=body.length() + 1024)
  out.write_string("<!doctype html>\n<html lang=\"")
  out.write_string(html_escape(safe_language(options.language)))
  out.write_string("\"><head><meta charset=\"utf-8\">\n")
  out.write_string(
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  )
  out.write_string(render_theme_bootstrap())
  if options.description.trim().to_owned() != "" {
    out.write_string("<meta name=\"description\" content=\"")
    out.write_string(html_escape(options.description.trim().to_owned()))
    out.write_string("\">\n")
  }
  out.write_string("<title>")
  out.write_string(html_escape(route.title))
  out.write_string(" - ")
  out.write_string(html_escape(site.title))
  out.write_string("</title>\n")
  write_social_metadata(out, site, route, options)
  out.write_string(render_theme_style(theme))
  out.write_string(
    "</head><body><div class=\"reading-progress\" data-progress></div><a class=\"skip-link\" href=\"#content\">Skip to content</a><aside><a class=\"brand\" href=\"",
  )
  if routes.length() > 0 {
    out.write_string(html_escape(routes[0].path))
  } else {
    out.write_string("#")
  }
  out.write_string("\"><span class=\"brand-mark\">M</span><span>")
  out.write_string(html_escape(site.title))
  out.write_string(
    "</span></a><div class=\"search\"><label for=\"site-search\">Search documentation</label><input id=\"site-search\" data-search-input type=\"search\" placeholder=\"Search docs\" autocomplete=\"off\"><div class=\"search-results\" data-search-results aria-live=\"polite\" hidden></div></div><nav aria-label=\"Documentation\">",
  )
  for item in routes {
    out.write_string("<a href=\"")
    out.write_string(html_escape(item.path))
    if item.path == route.path {
      out.write_string("\" class=\"active\" aria-current=\"page\">")
    } else {
      out.write_string("\">")
    }
    out.write_string(html_escape(item.title))
    out.write_string("</a>")
  }
  out.write_string(
    "</nav><button class=\"theme-toggle\" type=\"button\" data-theme-toggle aria-pressed=\"false\"><span class=\"toggle-track\"><span class=\"toggle-thumb\"></span></span><span class=\"toggle-text\">Nightfall</span></button></aside><main id=\"content\"><div class=\"content\">\n",
  )
  out.write_string("<div class=\"prose\">")
  out.write_string(body)
  if options.footer.trim().to_owned() != "" {
    out.write_string("<footer>")
    out.write_string(render_inline(options.footer.trim().to_owned()))
    out.write_string("</footer>\n")
  }
  out.write_string("</div>")
  out.write_string(toc)
  out.write_string("</div></main>")
  out.write_string(render_search_script())
  out.write_string(render_ui_script())
  out.write_string("</body></html>\n")
  { path: route.path, html: out.to_string(), }
}

///|
fn write_social_metadata(
  out : StringBuilder,
  site : DocSite,
  route : RouteEntry,
  options : SiteOptions,
) -> Unit {
  let title = route.title + " - " + site.title
  out.write_string("<meta property=\"og:title\" content=\"")
  out.write_string(html_escape(title))
  out.write_string("\">\n")
  if options.description.trim().to_owned() != "" {
    out.write_string("<meta property=\"og:description\" content=\"")
    out.write_string(html_escape(options.description.trim().to_owned()))
    out.write_string("\">\n")
  }
  match canonical_url(options.site_url, route.path) {
    Some(url) => {
      out.write_string("<link rel=\"canonical\" href=\"")
      out.write_string(html_escape(url))
      out.write_string("\">\n")
      out.write_string("<meta property=\"og:url\" content=\"")
      out.write_string(html_escape(url))
      out.write_string("\">\n")
    }
    None => ()
  }
}

///|
fn canonical_url(site_url : String, path : String) -> String? {
  let base = site_url.trim().to_owned()
  if base == "" {
    return None
  }
  if !(base.has_prefix("http://") || base.has_prefix("https://")) {
    return None
  }
  let clean_base = if base.has_suffix("/") {
    base[0:base.length() - 1].to_owned()
  } else {
    base
  }
  let clean_path = if path.has_prefix("/") { path[1:].to_owned() } else { path }
  Some(clean_base + "/" + clean_path)
}

///|
fn render_search_script() -> String {
  (
    #|<script>
    #|(() => {
    #|  const input = document.querySelector("[data-search-input]");
    #|  const results = document.querySelector("[data-search-results]");
    #|  let entries = [];
    #|  let active = null;
    #|  fetch("search-index.json")
    #|    .then(response => response.json())
    #|    .then(value => { entries = value; })
    #|    .catch(() => {});
    #|  const close = () => {
    #|    results.replaceChildren();
    #|    results.hidden = true;
    #|    active = null;
    #|  };
    #|  const highlight = index => {
    #|    const rows = results.querySelectorAll("a");
    #|    if (rows.length === 0) { return; }
    #|    if (active !== null && rows[active]) { rows[active].classList.remove("is-active"); }
    #|    active = (index + rows.length) % rows.length;
    #|    rows[active].classList.add("is-active");
    #|    rows[active].scrollIntoView({ block: "nearest" });
    #|  };
    #|  input.addEventListener("input", () => {
    #|    const query = input.value.trim().toLowerCase();
    #|    results.replaceChildren();
    #|    active = null;
    #|    if (query.length < 2) {
    #|      results.hidden = true;
    #|      return;
    #|    }
    #|    const matches = entries.filter(item =>
    #|      `${item.title} ${item.text} ${(item.tags || []).join(" ")}`.toLowerCase().includes(query)
    #|    ).slice(0, 8);
    #|    for (const item of matches) {
    #|      const link = document.createElement("a");
    #|      const title = document.createElement("strong");
    #|      const excerpt = document.createElement("span");
    #|      link.href = item.path;
    #|      title.textContent = item.title;
    #|      excerpt.textContent = item.text.slice(0, 96);
    #|      link.append(title, excerpt);
    #|      results.append(link);
    #|    }
    #|    if (matches.length === 0) {
    #|      const empty = document.createElement("span");
    #|      empty.textContent = "No matching pages";
    #|      results.append(empty);
    #|    }
    #|    results.hidden = false;
    #|  });
    #|  input.addEventListener("keydown", event => {
    #|    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
    #|      event.preventDefault();
    #|      const step = event.key === "ArrowDown" ? 1 : -1;
    #|      highlight(active === null ? (step > 0 ? 0 : -1) : active + step);
    #|      return;
    #|    }
    #|    if (event.key === "Enter") {
    #|      const rows = results.querySelectorAll("a");
    #|      const target = active === null ? rows[0] : rows[active];
    #|      if (target) { event.preventDefault(); window.location.assign(target.href); }
    #|      return;
    #|    }
    #|    if (event.key === "Escape") { close(); input.blur(); }
    #|  });
    #|  document.addEventListener("keydown", event => {
    #|    if (event.key === "/" && document.activeElement !== input) {
    #|      event.preventDefault();
    #|      input.focus();
    #|    }
    #|  });
    #|  document.addEventListener("click", event => {
    #|    if (event.target !== input && !results.contains(event.target)) { close(); }
    #|  });
    #|})();
    #|</script>
    #|
  )
}

///|
/// Emit an inline script that resolves the stored theme before first paint.
fn render_theme_bootstrap() -> String {
  (
    #|<script>
    #|(() => {
    #|  try {
    #|    const saved = localStorage.getItem("moondockit-theme");
    #|    if (saved === "dark" || saved === "light") {
    #|      document.documentElement.setAttribute("data-theme", saved);
    #|    }
    #|  } catch (error) {}
    #|})();
    #|</script>
    #|
  )
}

///|
/// Emit an inline script for theme switching, code copying and reading progress.
fn render_ui_script() -> String {
  (
    #|<script>
    #|(() => {
    #|  const root = document.documentElement;
    #|  const toggles = document.querySelectorAll("[data-theme-toggle]");
    #|  const label = document.querySelector("[data-theme-toggle] .toggle-text");
    #|  const preferred = () => window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    #|  const apply = mode => {
    #|    root.setAttribute("data-theme", mode);
    #|    for (const control of toggles) {
    #|      control.setAttribute("aria-pressed", mode === "dark" ? "true" : "false");
    #|    }
    #|    if (label) { label.textContent = mode === "dark" ? "Daylight" : "Nightfall"; }
    #|  };
    #|  let saved = null;
    #|  try { saved = localStorage.getItem("moondockit-theme"); } catch (error) {}
    #|  apply(saved === "dark" || saved === "light" ? saved : preferred());
    #|  for (const control of toggles) {
    #|    control.addEventListener("click", () => {
    #|      const next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
    #|      apply(next);
    #|      try { localStorage.setItem("moondockit-theme", next); } catch (error) {}
    #|    });
    #|  }
    #|  for (const block of document.querySelectorAll("pre")) {
    #|    const source = block.querySelector("code");
    #|    if (!source) { continue; }
    #|    const button = document.createElement("button");
    #|    button.type = "button";
    #|    button.className = "copy-code";
    #|    button.textContent = "Copy";
    #|    button.addEventListener("click", () => {
    #|      const done = () => { button.textContent = "Copied"; };
    #|      try {
    #|        navigator.clipboard.writeText(source.textContent).then(done, () => {});
    #|      } catch (error) { done(); }
    #|      setTimeout(() => { button.textContent = "Copy"; }, 1800);
    #|    });
    #|    block.prepend(button);
    #|  }
    #|  const bar = document.querySelector("[data-progress]");
    #|  const links = Array.from(document.querySelectorAll(".toc a"));
    #|  const waypoints = [];
    #|  for (const link of links) {
    #|    const id = link.getAttribute("href");
    #|    if (!id || id.length < 2) { continue; }
    #|    let target = null;
    #|    try { target = document.querySelector(id); } catch (error) {}
    #|    if (target) { waypoints.push([target, link]); }
    #|  }
    #|  let frame = 0;
    #|  const paint = () => {
    #|    frame = 0;
    #|    if (bar) {
    #|      const span = document.documentElement.scrollHeight - window.innerHeight;
    #|      const ratio = span > 0 ? Math.min(1, Math.max(0, window.scrollY / span)) : 0;
    #|      bar.style.transform = "scaleX(" + ratio.toFixed(4) + ")";
    #|    }
    #|    if (waypoints.length > 0) {
    #|      let current = waypoints[0][1];
    #|      for (const pair of waypoints) {
    #|        if (pair[0].getBoundingClientRect().top <= 132) { current = pair[1]; }
    #|      }
    #|      for (const link of links) { link.removeAttribute("aria-current"); }
    #|      current.setAttribute("aria-current", "true");
    #|    }
    #|  };
    #|  const schedule = () => { if (frame === 0) { frame = requestAnimationFrame(paint); } };
    #|  window.addEventListener("scroll", schedule, { passive: true });
    #|  window.addEventListener("resize", schedule);
    #|  paint();
    #|})();
    #|</script>
    #|
  )
}

///|
/// Render all pages in a documentation site.
pub fn render_site(site : DocSite) -> Array[RenderedPage] {
  render_site_with_theme(site, default_theme())
}

///|
/// Render all pages in a documentation site with a custom theme.
pub fn render_site_with_theme(
  site : DocSite,
  theme : SiteTheme,
) -> Array[RenderedPage] {
  render_site_with_options(site, theme, default_site_options())
}

///|
/// Render all pages in a documentation site with custom theme and options.
pub fn render_site_with_options(
  site : DocSite,
  theme : SiteTheme,
  options : SiteOptions,
) -> Array[RenderedPage] {
  site.pages.map(page => render_page_with_options(site, page, theme, options))
}

///|
/// Build all static output files for a site without touching the filesystem.
pub fn build_site_manifest(site : DocSite) -> Array[OutputFile] {
  build_site_manifest_with_theme(site, default_theme())
}

///|
/// Build all static output files for a site using a custom theme.
pub fn build_site_manifest_with_theme(
  site : DocSite,
  theme : SiteTheme,
) -> Array[OutputFile] {
  build_site_manifest_with_options(site, theme, default_site_options())
}

///|
/// Build all static output files using custom theme and template options.
pub fn build_site_manifest_with_options(
  site : DocSite,
  theme : SiteTheme,
  options : SiteOptions,
) -> Array[OutputFile] {
  let files : Array[OutputFile] = []
  for page in site.pages {
    let rendered = render_page_with_options(site, page, theme, options)
    files.push({ path: rendered.path, content: rendered.html, })
  }
  match build_index_page(site) {
    Some(content) => files.push({ path: "index.html", content, })
    None => ()
  }
  files.push({ path: "search-index.json", content: build_search_index(site), })
  files.push({
    path: "quality-report.json",
    content: build_quality_report_json(site),
  })
  files.push({ path: "sitemap.xml", content: build_sitemap(site), })
  files.push({ path: "robots.txt", content: build_robots_txt(), })
  files.push({
    path: "site-manifest.json",
    content: build_output_manifest_json(files),
  })
  files.sort_by((left, right) => left.path.compare(right.path))
  files
}

///|
/// Build a lightweight root page that directs visitors to the first route.
pub fn build_index_page(site : DocSite) -> String? {
  let routes = plan_routes(site)
  if routes.length() == 0 {
    return None
  }
  let first = routes[0]
  let title = html_escape(site.title)
  let path = html_escape(first.path)
  Some(
    "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
    "<meta http-equiv=\"refresh\" content=\"0; url=" +
    path +
    "\">\n<title>" +
    title +
    "</title></head><body>\n<p>Open <a href=\"" +
    path +
    "\">" +
    title +
    "</a>.</p>\n</body></html>\n",
  )
}

///|
/// Build a robots.txt file that points crawlers to the generated sitemap.
pub fn build_robots_txt() -> String {
  "User-agent: *\nAllow: /\nSitemap: sitemap.xml\n"
}

///|
/// Build a machine-readable manifest for generated output files.
pub fn build_output_manifest_json(files : Array[OutputFile]) -> String {
  let report = inspect_manifest(files)
  let out = StringBuilder()
  out.write_string("{\n")
  out.write_string("  \"file_count\": ")
  out.write_string(report.file_count.to_string())
  out.write_string(",\n  \"html_count\": ")
  out.write_string(report.html_count.to_string())
  out.write_string(",\n  \"data_count\": ")
  out.write_string(report.data_count.to_string())
  out.write_string(",\n  \"total_bytes\": ")
  out.write_string(report.total_bytes.to_string())
  out.write_string(",\n  \"files\": [\n")
  for i, file in report.files {
    out.write_string("    {\"path\":\"")
    out.write_string(json_escape(file.path))
    out.write_string("\",\"kind\":\"")
    out.write_string(json_escape(file.kind))
    out.write_string("\",\"bytes\":")
    out.write_string(file.byte_count.to_string())
    out.write_string("}")
    if i + 1 < report.files.length() {
      out.write_string(",")
    }
    out.write_string("\n")
  }
  out.write_string("  ]\n}\n")
  out.to_string()
}

///|
/// Build a machine-readable quality report for review and CI artifacts.
pub fn build_quality_report_json(site : DocSite) -> String {
  let gate = evaluate_quality(site)
  let metrics = measure_site(site)
  let validation = validate_site(site)
  let out = StringBuilder()
  out.write_string("{\n")
  out.write_string("  \"site_title\": \"")
  out.write_string(json_escape(site.title))
  out.write_string("\",\n  \"passed\": ")
  out.write_string(json_bool(gate.passed))
  out.write_string(",\n  \"score\": ")
  out.write_string(gate.score.to_string())
  out.write_string(",\n  \"checks\": [\n")
  for i, check in gate.checks {
    out.write_string("    {\"name\":\"")
    out.write_string(json_escape(check.name))
    out.write_string("\",\"passed\":")
    out.write_string(json_bool(check.passed))
    out.write_string(",\"message\":\"")
    out.write_string(json_escape(check.message))
    out.write_string("\"}")
    if i + 1 < gate.checks.length() {
      out.write_string(",")
    }
    out.write_string("\n")
  }
  out.write_string("  ],\n  \"metrics\": {")
  out.write_string("\"page_count\":")
  out.write_string(metrics.page_count.to_string())
  out.write_string(",\"heading_count\":")
  out.write_string(metrics.heading_count.to_string())
  out.write_string(",\"code_block_count\":")
  out.write_string(metrics.code_block_count.to_string())
  out.write_string(",\"word_count\":")
  out.write_string(metrics.word_count.to_string())
  out.write_string(",\"reading_minutes\":")
  out.write_string(metrics.reading_minutes.to_string())
  out.write_string("},\n  \"diagnostics\": [\n")
  for i, diagnostic in validation.diagnostics {
    out.write_string("    {\"level\":\"")
    out.write_string(diagnostic_level_name(diagnostic.level))
    out.write_string("\",\"code\":\"")
    out.write_string(json_escape(diagnostic.code))
    out.write_string("\",\"message\":\"")
    out.write_string(json_escape(diagnostic.message))
    out.write_string("\",\"page\":")
    match diagnostic.page {
      Some(page) => {
        out.write_string("\"")
        out.write_string(json_escape(page))
        out.write_string("\"")
      }
      None => out.write_string("null")
    }
    out.write_string("}")
    if i + 1 < validation.diagnostics.length() {
      out.write_string(",")
    }
    out.write_string("\n")
  }
  out.write_string("  ]\n}\n")
  out.to_string()
}

///|
/// Build a minimal XML sitemap for generated HTML pages.
pub fn build_sitemap(site : DocSite) -> String {
  let routes = plan_routes(site)
  let out = StringBuilder()
  out.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  out.write_string(
    "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n",
  )
  for route in routes {
    out.write_string("  <url><loc>")
    out.write_string(xml_escape(route.path))
    out.write_string("</loc></url>\n")
  }
  out.write_string("</urlset>\n")
  out.to_string()
}

///|
/// Inspect generated output files and return a deterministic build report.
pub fn inspect_manifest(files : Array[OutputFile]) -> BuildReport {
  let infos : Array[OutputFileInfo] = []
  let mut html_count = 0
  let mut data_count = 0
  let mut total_bytes = 0
  for file in files {
    let kind = classify_output(file.path)
    if kind == "html" {
      html_count = html_count + 1
    } else if kind == "data" {
      data_count = data_count + 1
    }
    total_bytes = total_bytes + file.content.length()
    infos.push({ path: file.path, kind, byte_count: file.content.length(), })
  }
  infos.sort_by((left, right) => left.path.compare(right.path))
  {
    file_count: infos.length(),
    html_count,
    data_count,
    total_bytes,
    files: infos,
  }
}

///|
/// Build a report for the default generated site manifest.
pub fn build_site_report(site : DocSite) -> BuildReport {
  inspect_manifest(build_site_manifest(site))
}

///|
/// Evaluate a documentation site against basic publish-readiness checks.
pub fn evaluate_quality(site : DocSite) -> QualityGate {
  let checks : Array[QualityCheck] = []
  let validation = validate_site(site)
  let metrics = measure_site(site)
  let generated_html_count = if metrics.page_count == 0 {
    0
  } else {
    metrics.page_count + 1
  }
  let generated_data_count = 4
  let max_page_reading_minutes = max_page_reading_minutes(site)
  checks.push({
    name: "validation",
    passed: !has_validation_errors(validation),
    message: if has_validation_errors(validation) {
      "site has validation errors"
    } else {
      "site validation passed"
    },
  })
  checks.push({
    name: "content",
    passed: metrics.word_count > 0 && metrics.heading_count > 0,
    message: if metrics.word_count > 0 && metrics.heading_count > 0 {
      "site has measurable documentation content"
    } else {
      "site needs headings and body content"
    },
  })
  checks.push({
    name: "outputs",
    passed: generated_html_count == metrics.page_count + 1 &&
    generated_data_count >= 3,
    message: if generated_html_count == metrics.page_count + 1 &&
      generated_data_count >= 3 {
      "manifest includes html pages and data outputs"
    } else {
      "manifest output mix is incomplete"
    },
  })
  checks.push({
    name: "readability",
    passed: max_page_reading_minutes <= 30,
    message: if max_page_reading_minutes <= 30 {
      "every page is within the baseline reading threshold"
    } else {
      "one or more pages may need splitting into smaller pages"
    },
  })
  let mut passed_count = 0
  for check in checks {
    if check.passed {
      passed_count = passed_count + 1
    }
  }
  {
    passed: passed_count == checks.length(),
    score: if checks.length() == 0 {
      0
    } else {
      passed_count * 100 / checks.length()
    },
    checks,
  }
}

///|
fn max_page_reading_minutes(site : DocSite) -> Int {
  let mut maximum = 0
  for page in site.pages {
    let minutes = measure_document(page.source).reading_minutes
    if minutes > maximum {
      maximum = minutes
    }
  }
  maximum
}

///|
/// Build a small JSON search index for the rendered site.
pub fn build_search_index(site : DocSite) -> String {
  let entries = collect_search_entries(site)
  let out = StringBuilder()
  out.write_string("[")
  for i, entry in entries {
    if i > 0 {
      out.write_string(",")
    }
    out.write_string("{\"title\":\"")
    out.write_string(json_escape(entry.title))
    out.write_string("\",\"path\":\"")
    out.write_string(json_escape(entry.path))
    out.write_string("\",\"text\":\"")
    out.write_string(json_escape(entry.text))
    out.write_string("\",\"tags\":[")
    for j, tag in entry.tags {
      if j > 0 {
        out.write_string(",")
      }
      out.write_string("\"")
      out.write_string(json_escape(tag))
      out.write_string("\"")
    }
    out.write_string("]}")
  }
  out.write_string("]")
  out.to_string()
}

///|
/// Collect structured search entries before JSON serialization.
pub fn collect_search_entries(site : DocSite) -> Array[SearchEntry] {
  let entries : Array[SearchEntry] = []
  for page in site.pages {
    let route = route_for_page(page)
    let doc = parse_document(page.source)
    entries.push({
      title: route.title,
      path: route.path,
      text: blocks_to_plain_text(doc.blocks),
      tags: route.tags,
    })
  }
  entries.sort_by((left, right) => left.path.compare(right.path))
  entries
}

///|
/// Summarize the generated site for demos, logs and validation.
pub fn summarize_site(site : DocSite) -> SiteSummary {
  let routes = plan_routes(site)
  let manifest = build_site_manifest(site)
  let search_entries = collect_search_entries(site)
  let tags : Array[String] = []
  for route in routes {
    for tag in route.tags {
      if !tags.contains(tag) {
        tags.push(tag)
      }
    }
  }
  {
    page_count: routes.length(),
    output_count: manifest.length(),
    search_entry_count: search_entries.length(),
    tag_count: tags.length(),
  }
}

///|
/// Measure content size and structure for one Markdown document.
pub fn measure_document(markdown : String) -> DocumentMetrics {
  measure_blocks(parse_blocks(markdown))
}

///|
/// Measure content size and structure for parsed Markdown blocks.
pub fn measure_blocks(blocks : Array[MarkdownBlock]) -> DocumentMetrics {
  let mut heading_count = 0
  let mut paragraph_count = 0
  let mut list_item_count = 0
  let mut code_block_count = 0
  let mut word_count = 0
  for block in blocks {
    match block {
      Heading(_, title) => {
        heading_count = heading_count + 1
        word_count = word_count + count_words(title)
      }
      Paragraph(text) | BlockQuote(text) => {
        paragraph_count = paragraph_count + 1
        word_count = word_count + count_words(text)
      }
      UnorderedList(items) =>
        for item in items {
          list_item_count = list_item_count + 1
          word_count = word_count + count_words(item)
        }
      CodeBlock(_, _) => code_block_count = code_block_count + 1
    }
  }
  {
    heading_count,
    paragraph_count,
    list_item_count,
    code_block_count,
    word_count,
    reading_minutes: reading_minutes_for_words(word_count),
  }
}

///|
/// Measure aggregate content size and structure for all site pages.
pub fn measure_site(site : DocSite) -> SiteMetrics {
  let mut heading_count = 0
  let mut code_block_count = 0
  let mut word_count = 0
  for page in site.pages {
    let metrics = measure_document(page.source)
    heading_count = heading_count + metrics.heading_count
    code_block_count = code_block_count + metrics.code_block_count
    word_count = word_count + metrics.word_count
  }
  {
    page_count: site.pages.length(),
    heading_count,
    code_block_count,
    word_count,
    reading_minutes: reading_minutes_for_words(word_count),
  }
}

///|
/// Validate a site before rendering or publishing.
pub fn validate_site(site : DocSite) -> ValidationReport {
  let diagnostics : Array[SiteDiagnostic] = []
  if site.title.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagWarning,
      code: "empty-site-title",
      message: "site title is empty",
      page: None,
    })
  }
  if site.pages.length() == 0 {
    diagnostics.push({
      level: DiagError,
      code: "empty-site",
      message: "site has no pages",
      page: None,
    })
  }
  let paths : Array[String] = []
  for page in site.pages {
    validate_page(page, paths, diagnostics)
  }
  { diagnostics, }
}

///|
fn validate_page(
  page : DocPage,
  paths : Array[String],
  diagnostics : Array[SiteDiagnostic],
) -> Unit {
  let route = route_for_page(page)
  let page_name = if page.title.trim().to_owned() == "" {
    page.slug
  } else {
    page.title
  }
  if route.title.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagError,
      code: "empty-page-title",
      message: "page title is empty",
      page: Some(page_name),
    })
  }
  if route.slug.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagError,
      code: "empty-route",
      message: "page route slug is empty",
      page: Some(page_name),
    })
  } else if paths.contains(route.path) {
    diagnostics.push({
      level: DiagError,
      code: "duplicate-route",
      message: "more than one page renders to " + route.path,
      page: Some(page_name),
    })
  } else {
    paths.push(route.path)
  }
  if page.source.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagWarning,
      code: "empty-source",
      message: "page source is empty",
      page: Some(page_name),
    })
  }
}

///|
/// Return true when a validation report contains at least one error.
pub fn has_validation_errors(report : ValidationReport) -> Bool {
  for diagnostic in report.diagnostics {
    match diagnostic.level {
      DiagError => return true
      DiagWarning => ()
    }
  }
  false
}

///|
/// Render diagnostics as stable text for CLI output and logs.
pub fn diagnostics_to_text(report : ValidationReport) -> String {
  if report.diagnostics.length() == 0 {
    return "ok"
  }
  let out = StringBuilder()
  for diagnostic in report.diagnostics {
    match diagnostic.level {
      DiagError => out.write_string("error")
      DiagWarning => out.write_string("warning")
    }
    out.write_string(" ")
    out.write_string(diagnostic.code)
    match diagnostic.page {
      Some(page) => {
        out.write_string(" [")
        out.write_string(page)
        out.write_string("]")
      }
      None => ()
    }
    out.write_string(": ")
    out.write_string(diagnostic.message)
    out.write_char('\n')
  }
  out.to_string()
}

///|
fn blocks_to_plain_text(blocks : Array[MarkdownBlock]) -> String {
  let out = StringBuilder()
  for block in blocks {
    match block {
      Heading(_, text) | Paragraph(text) | BlockQuote(text) =>
        append_search_text(out, text)
      UnorderedList(items) =>
        for item in items {
          append_search_text(out, item)
        }
      CodeBlock(_, code) => append_search_text(out, code)
    }
  }
  out.to_string()
}

///|
fn append_search_text(out : StringBuilder, text : String) -> Unit {
  if !out.is_empty() {
    out.write_char(' ')
  }
  out.write_string(text.trim().to_owned())
}

///|
fn count_words(text : String) -> Int {
  let mut count = 0
  let mut in_word = false
  for _, ch in text {
    let lower = ch.to_ascii_lowercase()
    let is_word = lower is ('a'..='z') || lower is ('0'..='9')
    if is_word && !in_word {
      count = count + 1
    }
    in_word = is_word
  }
  count
}

///|
fn reading_minutes_for_words(word_count : Int) -> Int {
  if word_count == 0 {
    0
  } else {
    (word_count + 199) / 200
  }
}

///|
fn json_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn json_bool(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn diagnostic_level_name(level : DiagnosticLevel) -> String {
  match level {
    DiagError => "error"
    DiagWarning => "warning"
  }
}

///|
fn xml_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&apos;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn classify_output(path : String) -> String {
  if path.has_suffix(".html") || path.has_suffix(".htm") {
    "html"
  } else if path.has_suffix(".json") || path.has_suffix(".xml") {
    "data"
  } else {
    "asset"
  }
}

///|
fn route_for_page(page : DocPage) -> RouteEntry {
  let doc = parse_document(page.source)
  let title = match doc.front_matter.title {
    Some(value) => value
    None => page.title
  }
  let slug = if page.slug == "" { slugify(title) } else { page.slug }
  {
    title,
    slug,
    path: slug + ".html",
    order: doc.front_matter.order,
    tags: doc.front_matter.tags,
  }
}

///|
fn render_theme_style(theme : SiteTheme) -> String {
  let sidebar_width = positive_or_default(theme.sidebar_width_px, 260)
  let content_width = positive_or_default(theme.content_width_px, 820)
  let rail_break = sidebar_width + 900
  let narrow = sidebar_width + content_width + 60
  let out = StringBuilder()
  out.write_string("<style>")
  out.write_string(
    (
      #|*,*::before,*::after{box-sizing:border-box}
      #|html{-webkit-text-size-adjust:100%;text-size-adjust:100%;scroll-behavior:smooth;scrollbar-color:color-mix(in oklab,var(--ink) 26%,transparent) transparent;scrollbar-width:thin}
      #|::selection{background:color-mix(in oklab,var(--accent) 26%,transparent);color:var(--ink)}
      #|:focus-visible{outline:2px solid var(--accent);outline-offset:3px;border-radius:4px}
      #|
    ),
  )
  out.write_string(":root{color-scheme:light dark;--page:")
  out.write_string(theme.background)
  out.write_string(";--card:")
  out.write_string(theme.surface)
  out.write_string(";--ink:")
  out.write_string(theme.text)
  out.write_string(";--accent:")
  out.write_string(theme.accent)
  out.write_string(";--rule:")
  out.write_string(theme.border)
  out.write_string(";--plate:")
  out.write_string(theme.code_background)
  out.write_string(";--plate-ink:")
  out.write_string(theme.code_text)
  out.write_string(";--sidebar:")
  out.write_string(sidebar_width.to_string())
  out.write_string("px;--measure:")
  out.write_string(content_width.to_string())
  out.write_string(
    (
      #|;--font-display:"Iowan Old Style","Palatino Linotype",Palatino,"Book Antiqua","Songti SC",STSong,"Noto Serif CJK SC","Source Han Serif SC",Georgia,serif;--font-body:ui-sans-serif,-apple-system,"Segoe UI Variable Display","Segoe UI","PingFang SC","Hiragino Sans GB","Microsoft YaHei",system-ui,sans-serif;--font-mono:ui-monospace,"SF Mono","Cascadia Code","JetBrains Mono","Fira Code",Menlo,Consolas,"Liberation Mono",monospace;--step-neg2:clamp(0.68rem,0.66rem+0.08vw,0.74rem);--step-neg1:clamp(0.78rem,0.76rem+0.09vw,0.85rem);--step-0:clamp(1.02rem,0.99rem+0.16vw,1.12rem);--step-1:1.26rem;--step-2:clamp(1.5rem,1.26rem+1.02vw,1.95rem);--step-3:clamp(2.05rem,1.42rem+2.6vw,3rem);--step-4:clamp(2.8rem,2rem+4vw,4.2rem);--gold-light:#d4b07a;--rose:#a65d57;--violet:#6b5b95;--ink-muted:#8a8894;--surface-warm:#f5ede0;--ink-soft:#565460;--ink-faint:#6f6d78;--accent-soft:#eeeef4;--accent-ring:#c9c7d4;--gold:#b08948;--ink-soft:color-mix(in oklab,var(--ink) 76%,transparent);--ink-faint:color-mix(in oklab,var(--ink) 62%,transparent);--accent-soft:color-mix(in oklab,var(--accent) 11%,transparent);--accent-ring:color-mix(in oklab,var(--accent) 30%,transparent);--accent-deep:color-mix(in oklab,var(--accent) 62%,var(--ink));--halo:color-mix(in oklab,var(--accent) 20%,transparent);--gold:#b08948;--moon-hi:#fffdf7;--moon-mid:#f5edda;--moon-lo:#dccfb4;--ease:cubic-bezier(.2,.7,.2,1);--shadow-card:0 1px 2px color-mix(in oklab,var(--ink) 8%,transparent);--shadow-lift:0 18px 44px -26px color-mix(in oklab,var(--ink) 34%,transparent);
      #|
    ),
  )
  out.write_string("}\n")
  out.write_string("body{margin:0;background:")
  out.write_string(theme.background)
  out.write_string(";background:var(--page)")
  out.write_string(
    ";color:var(--ink);font-family:var(--font-body);font-size:var(--step-0);line-height:1.72;font-kerning:normal;background-image:radial-gradient(1100px 620px at 10% -12%,var(--accent-soft),transparent 62%),radial-gradient(900px 520px at 102% 0%,color-mix(in oklab,var(--gold) 7%,transparent),transparent 60%);background-repeat:no-repeat;background-attachment:fixed;transition:background-color .4s var(--ease),color .4s var(--ease)}\n",
  )
  out.write_string("aside{width:")
  out.write_string(sidebar_width.to_string())
  out.write_string("px}\n")
  out.write_string("main{margin-left:")
  out.write_string(sidebar_width.to_string())
  out.write_string("px}\n")
  out.write_string("a{color:")
  out.write_string(theme.accent)
  out.write_string(
    ";text-decoration:none;transition:color .2s var(--ease)}a:hover{color:var(--accent-deep)}\n",
  )
  out.write_string(".content{max-width:")
  out.write_string(content_width.to_string())
  out.write_string(
    "px;margin:0 auto;padding:64px 40px 104px;display:grid;grid-template-columns:minmax(0,1fr);align-items:start}\n",
  )
  out.write_string(
    (
      #|.reading-progress{position:fixed;inset:0 0 auto 0;height:2px;z-index:9;pointer-events:none;transform:scaleX(0);transform-origin:0 50%;background:linear-gradient(90deg,var(--accent),color-mix(in oklab,var(--gold) 76%,var(--accent)));opacity:.85;transition:transform .12s linear}
      #|.skip-link{position:fixed;left:16px;top:14px;z-index:30;transform:translateY(-240%);padding:11px 18px;border-radius:999px;background:var(--accent);color:var(--card);font-family:var(--font-body);font-size:.875rem;font-weight:650;letter-spacing:.01em;box-shadow:0 12px 32px -8px rgba(20,16,40,.45);transition:transform .3s var(--ease)}
      #|.skip-link:focus-visible{transform:translateY(0);outline:2px solid var(--accent);outline-offset:3px}
      #|aside{position:fixed;z-index:6;inset:0 auto 0 0;display:flex;flex-direction:column;gap:0;padding:30px 22px 24px;overflow-y:auto;overscroll-behavior:contain;background:linear-gradient(178deg,color-mix(in oklab,var(--card) 92%,var(--accent)),var(--card) 62%);border-right:1px solid var(--rule);box-shadow:1px 0 0 color-mix(in oklab,var(--ink) 5%,transparent),28px 0 64px -52px rgba(20,16,40,.55)}
      #|.brand{display:flex;align-items:center;gap:12px;padding:2px 6px 0;color:var(--ink);text-decoration:none;font-family:var(--font-display);font-size:1.3rem;font-weight:600;letter-spacing:-.015em;transition:color .25s var(--ease)}
      #|.brand:hover{color:var(--accent);text-decoration:none}
      #|.brand-mark{position:relative;flex:0 0 auto;display:grid;place-items:center;width:38px;height:38px;border-radius:50%;font-family:var(--font-display);font-size:1.05rem;font-weight:600;color:color-mix(in oklab,var(--accent) 66%,#12111a);background:radial-gradient(124% 124% at 30% 26%,var(--moon-hi) 0%,var(--moon-mid) 44%,var(--moon-lo) 100%);box-shadow:inset 0 0 0 1px rgba(255,255,255,.7),inset -7px -9px 18px -7px color-mix(in oklab,#6a5330 40%,transparent),0 6px 18px -6px rgba(52,42,24,.42);transition:transform .6s var(--ease),box-shadow .6s var(--ease)}
      #|.brand-mark::after{content:"";position:absolute;inset:-7px;border-radius:50%;border:1px solid color-mix(in oklab,var(--gold) 42%,transparent);opacity:0;transform:scale(.82);transition:opacity .5s var(--ease),transform .5s var(--ease)}
      #|.brand:hover .brand-mark{transform:rotate(-9deg)}
      #|.brand:hover .brand-mark::after{opacity:1;transform:scale(1)}
      #|.search{position:relative;margin:26px 0 6px}
      #|.search label{position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%);white-space:nowrap}
      #|.search input{width:100%;padding:11px 40px 11px 15px;font-family:var(--font-body);font-size:.9rem;color:var(--ink);background:color-mix(in oklab,var(--page) 62%,var(--card));border:1px solid var(--rule);border-radius:12px;outline:none;box-shadow:inset 0 1px 2px color-mix(in oklab,var(--ink) 7%,transparent);transition:border-color .25s var(--ease),box-shadow .25s var(--ease)}
      #|.search input::placeholder{color:var(--ink-faint)}
      #|.search input:focus-visible{border-color:var(--accent);box-shadow:0 0 0 3px var(--accent-ring)}
      #|.search::after{content:"/";position:absolute;right:12px;top:50%;transform:translateY(-50%);padding:1px 7px;border:1px solid var(--rule);border-radius:6px;color:var(--ink-faint);font-family:var(--font-body);font-size:.72rem;line-height:1.5;pointer-events:none;transition:opacity .2s var(--ease)}
      #|.search:focus-within::after{opacity:0}
      #|.search-results{display:grid;gap:2px;position:absolute;z-index:8;top:calc(100% + 8px);left:0;right:0;max-height:min(58vh,360px);overflow-y:auto;overscroll-behavior:contain;padding:7px;border:1px solid var(--rule);border-radius:14px;background:color-mix(in oklab,var(--card) 92%,transparent);backdrop-filter:blur(14px) saturate(1.25);box-shadow:0 26px 62px -24px rgba(22,18,52,.44),var(--shadow-card)}
      #|.search-results[hidden]{display:none}
      #|.search-results a{display:grid;gap:3px;padding:9px 11px;border-radius:9px;border-left:2px solid transparent;color:var(--ink);text-decoration:none;transition:background .18s var(--ease),border-color .18s var(--ease)}
      #|.search-results a:hover,.search-results a:focus-visible,.search-results a.is-active{background:var(--accent-soft);border-left-color:var(--accent);text-decoration:none}
      #|.search-results strong{font-family:var(--font-display);font-size:1rem;font-weight:600;letter-spacing:-.012em}
      #|.search-results a span{font-size:.82rem;line-height:1.45;color:var(--ink-soft)}
      #|.search-results>span{padding:12px 11px;font-size:.85rem;color:var(--ink-faint)}
      #|nav{display:grid;gap:1px;margin:20px 0 18px;padding-top:15px;border-top:1px solid var(--rule)}
      #|nav a{position:relative;padding:8px 30px 8px 12px;border-radius:8px;color:var(--ink-soft);font-size:.92rem;font-weight:500;text-decoration:none;transition:color .2s var(--ease),background .2s var(--ease)}
      #|nav a:hover{color:var(--ink);background:color-mix(in oklab,var(--ink) 5%,transparent);text-decoration:none}
      #|nav a.active{color:var(--accent);font-weight:650;background:var(--accent-soft)}
      #|nav a.active::before{content:"";position:absolute;left:0;top:50%;transform:translateY(-50%);width:2px;height:58%;background:var(--accent);border-radius:0 2px 2px 0}
      #|nav a.active::after{content:"";position:absolute;right:12px;top:50%;margin-top:-4px;width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:3px 0 0 -1.5px var(--card)}
      #|.theme-toggle{margin-top:auto;display:flex;align-items:center;gap:10px;width:100%;padding:9px 11px;font-family:var(--font-body);font-size:.82rem;font-weight:550;color:var(--ink-soft);background:transparent;border:1px solid var(--rule);border-radius:999px;cursor:pointer;transition:color .25s var(--ease),border-color .25s var(--ease),background .25s var(--ease)}
      #|.theme-toggle:hover{color:var(--ink);border-color:var(--accent-ring);background:var(--accent-soft)}
      #|.toggle-track{position:relative;flex:0 0 auto;width:34px;height:18px;border-radius:999px;background:var(--accent-soft);box-shadow:inset 0 0 0 1px var(--rule);transition:background .3s var(--ease)}
      #|.toggle-thumb{position:absolute;top:2px;left:2px;width:14px;height:14px;border-radius:50%;background:var(--moon-mid);box-shadow:inset -3px -4px 7px -3px color-mix(in oklab,#6a5330 55%,transparent),0 1px 3px rgba(24,20,44,.3);transition:transform .34s var(--ease)}
      #|:root[data-theme="dark"] .toggle-thumb{transform:translateX(16px)}
      #|.toggle-text{letter-spacing:.01em}
      #|main{min-height:100vh}
      #|.content{max-width:var(--measure);margin:0 auto;padding:clamp(40px,6vw,72px) clamp(20px,4vw,48px) 96px;display:grid;grid-template-columns:minmax(0,1fr);align-items:start;overflow-wrap:break-word}
      #|.prose{grid-column:1;min-width:0;counter-reset:phase}
      #|.prose>*{scroll-margin-top:32px}
      #|.content h1,.content h2{font-family:var(--font-display);color:color-mix(in oklab,var(--ink) 90%,#000);line-height:1.16;letter-spacing:-.02em;text-wrap:balance}
      #|.content h1{font-size:var(--step-3);font-weight:600;margin:0 0 .62em;background:linear-gradient(135deg,var(--ink) 30%,var(--accent) 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
      #|.content h1::after{content:"";display:block;width:66px;height:2px;margin-top:.92rem;border-radius:2px;background:linear-gradient(90deg,var(--accent),color-mix(in oklab,var(--gold) 84%,transparent))}
      #|.content h2{counter-increment:phase;font-size:var(--step-2);font-weight:600;margin:2.5em 0 .82em;padding-top:1.6rem;background:linear-gradient(90deg,var(--rule),color-mix(in oklab,var(--rule) 0%,transparent) 76%) no-repeat top left/100% 1px;display:grid;grid-template-columns:auto 1fr;gap:14px;align-items:baseline}
      #|.content h2::before{content:counter(phase,decimal-leading-zero);font-family:var(--font-mono);font-size:.55em;font-weight:700;letter-spacing:.04em;color:var(--accent);opacity:.75;font-variant-numeric:tabular-nums;align-self:center;background:var(--accent-soft);padding:.18em .55em .22em;border-radius:7px;transform:none;display:inline-block;margin:0}
      #|.content h3{font-family:var(--font-body);font-size:var(--step-1);font-weight:650;letter-spacing:-.012em;line-height:1.34;color:var(--ink);margin:2em 0 .62em;text-wrap:balance}
      #|.prose p{margin:0 0 1.28em;max-width:70ch;text-wrap:pretty}
      #|.prose ul{margin:0 0 1.28em;padding-left:1.15em}
      #|.prose li{margin-bottom:.42em}
      #|.prose li::marker{color:var(--accent)}
      #|.prose p a,.prose li a,.toc a{text-underline-offset:.17em;text-decoration-thickness:1px}
      #|.prose p a,.prose li a{text-decoration:underline;text-decoration-color:var(--accent-ring)}
      #|.prose p a:hover,.prose li a:hover{text-decoration-color:var(--accent);text-decoration-thickness:2px}
      #|blockquote{margin:0 0 1.6em;padding:.2em 0 .2em 1.45em;border-left:2px solid var(--gold);font-family:var(--font-display);font-size:1.07em;line-height:1.62;color:color-mix(in oklab,var(--ink) 84%,transparent)}
      #|blockquote p:last-child{margin-bottom:0}
      #|code{font-family:var(--font-mono);font-size:.85em;font-variant-ligatures:none;letter-spacing:-.012em}
      #|.prose :not(pre)>code,footer code{padding:.16em .44em;border:1px solid color-mix(in oklab,var(--ink) 11%,transparent);border-radius:6px;background:color-mix(in oklab,var(--accent) 7%,var(--card));color:var(--accent-deep)}
      #|.callout{display:flex;gap:16px;padding:18px 20px;border-radius:13px;margin:1.6em 0;border:1px solid var(--rule);background:linear-gradient(135deg,color-mix(in oklab,var(--surface-warm) 70%,transparent),var(--card) 60%)}
      #|.callout-icon{flex:0 0 auto;width:32px;height:32px;border-radius:8px;display:grid;place-items:center;background:var(--accent-soft);color:var(--accent);font-family:var(--font-display);font-weight:700}
      #|.callout-body{flex:1;min-width:0;font-size:var(--step-neg1);line-height:1.6;color:var(--ink-muted)}
      #|.callout-body p{margin:0 0 .4em;color:var(--ink-muted);max-width:none}
      #|.callout-body p:last-child{margin-bottom:0}
      #|.tag{display:inline-block;padding:2px 10px;border-radius:999px;font-size:var(--step-neg2);font-weight:550;letter-spacing:.02em;background:var(--accent-soft);color:var(--accent);margin-right:6px;margin-bottom:6px}
      #|.doc-figure{margin:1.8em 0 2.2em;padding:0;display:block;overflow:hidden;border-radius:18px;background:var(--surface-warm);box-shadow:var(--shadow-lift);border:1px solid var(--rule)}
      #|.doc-figure img{display:block;width:100%;max-width:100%;height:auto;max-height:clamp(220px,42vh,420px);object-fit:cover;object-position:center;border-radius:0;transition:transform .5s var(--ease)}
      #|.doc-figure:hover img{transform:scale(1.015)}
      #|.doc-figure figcaption{margin:0;padding:11px 18px 13px;font-size:var(--step-neg1);color:var(--ink-faint);font-style:italic;letter-spacing:.01em;text-align:center;background:linear-gradient(180deg,color-mix(in oklab,var(--card) 60%,transparent),var(--card));border-top:1px solid var(--rule)}
      #|.page-section{padding:1em 0 2em;border-bottom:1px dashed var(--rule)}
      #|.page-section:last-of-type{border-bottom:none}
      #|.page-header{display:flex;align-items:center;gap:18px;margin:0 0 1.2em}
      #|.page-num{flex:0 0 auto;width:42px;height:42px;display:grid;place-items:center;border-radius:50%;background:linear-gradient(135deg,var(--accent),color-mix(in oklab,var(--accent) 60%,#fff));color:var(--card);font-family:var(--font-display);font-size:1.1rem;font-weight:700;letter-spacing:-.01em;box-shadow:0 4px 12px -4px color-mix(in oklab,var(--accent) 40%,transparent)}
      #|pre{position:relative;margin:0 0 1.7em;padding:1.15rem 1.3rem;border:1px solid color-mix(in oklab,var(--ink) 13%,transparent);border-radius:13px;background:var(--plate);color:var(--plate-ink);overflow:auto;box-shadow:inset 0 1px 0 color-mix(in oklab,#ffffff 7%,transparent),0 20px 44px -30px rgba(10,8,26,.8)}
      #|pre code{font-size:.875rem;line-height:1.72;background:none;border:0;padding:0;color:inherit}
      #|.copy-code{position:absolute;top:10px;right:10px;padding:5px 10px;font-family:var(--font-body);font-size:.68rem;font-weight:650;letter-spacing:.09em;text-transform:uppercase;white-space:nowrap;color:color-mix(in oklab,var(--plate-ink) 72%,transparent);background:color-mix(in oklab,var(--plate-ink) 9%,transparent);border:1px solid color-mix(in oklab,var(--plate-ink) 15%,transparent);border-radius:8px;cursor:pointer;opacity:0;transition:opacity .22s var(--ease),color .22s var(--ease),background .22s var(--ease)}
      #|pre:hover .copy-code,.copy-code:focus-visible{opacity:1}
      #|.copy-code:hover{color:var(--plate-ink);background:color-mix(in oklab,var(--plate-ink) 18%,transparent)}
      #|table{border-collapse:collapse;width:100%;margin:0 0 1.7em;font-size:.94rem}
      #|th,td{padding:10px 14px;border-bottom:1px solid var(--rule);text-align:left;vertical-align:top}
      #|th{border-bottom:1px solid color-mix(in oklab,var(--ink) 22%,transparent);font-family:var(--font-body);font-size:.72rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--ink-soft)}
      #|tbody tr:hover{background:var(--accent-soft)}
      #|.toc{padding:19px 20px;margin:0 0 2.1rem;border:1px solid var(--rule);border-radius:13px;background:linear-gradient(178deg,color-mix(in oklab,var(--accent) 5%,var(--card)),var(--card));box-shadow:var(--shadow-card)}
      #|.toc-title{font-family:var(--font-body);font-size:.69rem;font-weight:700;text-transform:uppercase;letter-spacing:.19em;color:var(--ink-faint);margin-bottom:12px}
      #|.toc a{display:block;padding:5px 0 5px 15px;border-left:1px solid var(--rule);color:var(--ink-soft);font-size:.875rem;line-height:1.45;text-decoration:none;transition:color .2s var(--ease),border-color .2s var(--ease)}
      #|.toc a:hover{color:var(--accent);border-left-color:var(--accent-ring)}
      #|.toc a[aria-current]{color:var(--accent);border-left-color:var(--accent);font-weight:650}
      #|.toc .level-2{padding-left:15px}
      #|.toc .level-3{padding-left:30px;font-size:.83rem}
      #|footer{margin-top:4.2rem;padding-top:1.7rem;border-top:1px solid var(--rule);font-size:.85rem;line-height:1.65;color:var(--ink-faint)}
      #|
    ),
  )
  out.write_string(
    (
      #|@media(prefers-color-scheme:dark){
      #|:root:not([data-theme="light"]){--page:color-mix(in oklab,#0c1018 91%,var(--accent));--card:color-mix(in oklab,#151b26 93%,var(--accent));--ink:#e8e4db;--rule:color-mix(in oklab,#e8e4db 15%,transparent);--plate:color-mix(in oklab,#080b12 85%,var(--accent));--plate-ink:#eae6dd;--gold:#d8b871;--halo:color-mix(in oklab,var(--accent) 30%,transparent);--shadow-card:0 1px 2px rgba(0,0,0,.5);--shadow-lift:0 22px 50px -28px rgba(0,0,0,.8)}
      #|:root:not([data-theme="light"]) .toggle-track{background:color-mix(in oklab,var(--accent) 22%,transparent)}
      #|:root:not([data-theme="light"]) .search input{background:color-mix(in oklab,var(--card) 70%,#000)}
      #|:root:not([data-theme="light"]) pre{border-color:color-mix(in oklab,#e8e4db 12%,transparent)}
      #|:root:not([data-theme="light"]) nav a.active::after{box-shadow:3px 0 0 -1.5px var(--card)}
      #|}
      #|:root[data-theme="dark"]{--page:color-mix(in oklab,#0c1018 91%,var(--accent));--card:color-mix(in oklab,#151b26 93%,var(--accent));--ink:#e8e4db;--rule:color-mix(in oklab,#e8e4db 15%,transparent);--plate:color-mix(in oklab,#080b12 85%,var(--accent));--plate-ink:#eae6dd;--gold:#d8b871;--halo:color-mix(in oklab,var(--accent) 30%,transparent);--shadow-card:0 1px 2px rgba(0,0,0,.5);--shadow-lift:0 22px 50px -28px rgba(0,0,0,.8)}
      #|:root[data-theme="dark"] .toggle-track{background:color-mix(in oklab,var(--accent) 22%,transparent)}
      #|:root[data-theme="dark"] .search input{background:color-mix(in oklab,var(--card) 70%,#000)}
      #|:root[data-theme="dark"] pre{border-color:color-mix(in oklab,#e8e4db 12%,transparent)}
      #|:root[data-theme="dark"] nav a.active::after{box-shadow:3px 0 0 -1.5px var(--card)}
      #|:root:not([data-theme="light"]) .doc-figure{background:color-mix(in oklab,var(--card) 70%,#000);border-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root:not([data-theme="light"]) .page-section{border-bottom-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root:not([data-theme="light"]) .callout{background:linear-gradient(135deg,color-mix(in oklab,var(--accent) 9%,transparent),color-mix(in oklab,var(--card) 92%,#000) 62%);border-color:color-mix(in oklab,#e8e4db 11%,transparent)}
      #|:root:not([data-theme="light"]) .prose th{background:color-mix(in oklab,var(--accent) 16%,var(--card))}
      #|:root:not([data-theme="light"]) .prose td{border-top-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root:not([data-theme="light"]) a{color:color-mix(in oklab,var(--accent) 70%,#fff)}
      #|:root:not([data-theme="light"]) .prose :not(pre)>code{background:color-mix(in oklab,var(--accent) 16%,transparent);border-color:color-mix(in oklab,var(--accent) 24%,transparent);color:color-mix(in oklab,var(--accent) 62%,#fff)}
      #|:root:not([data-theme="light"]) .prose strong{color:color-mix(in oklab,var(--accent) 70%,#fff)}
      #|:root[data-theme="dark"] .doc-figure{background:color-mix(in oklab,var(--card) 70%,#000);border-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root[data-theme="dark"] .page-section{border-bottom-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root[data-theme="dark"] .callout{background:linear-gradient(135deg,color-mix(in oklab,var(--accent) 9%,transparent),color-mix(in oklab,var(--card) 92%,#000) 62%);border-color:color-mix(in oklab,#e8e4db 11%,transparent)}
      #|:root[data-theme="dark"] .prose th{background:color-mix(in oklab,var(--accent) 16%,var(--card))}
      #|:root[data-theme="dark"] .prose td{border-top-color:color-mix(in oklab,#e8e4db 10%,transparent)}
      #|:root[data-theme="dark"] a{color:color-mix(in oklab,var(--accent) 70%,#fff)}
      #|:root[data-theme="dark"] .prose :not(pre)>code{background:color-mix(in oklab,var(--accent) 16%,transparent);border-color:color-mix(in oklab,var(--accent) 24%,transparent);color:color-mix(in oklab,var(--accent) 62%,#fff)}
      #|:root[data-theme="dark"] .prose strong{color:color-mix(in oklab,var(--accent) 70%,#fff)}
      #|
    ),
  )
  out.write_string(
    (
      #|@media(min-width:
      #|
    ),
  )
  out.write_string(rail_break.to_string())
  out.write_string(
    (
      #|px){
      #|.content:has(> .toc){max-width:calc(var(--measure) + 268px);grid-template-columns:minmax(0,1fr) 212px;column-gap:56px}
      #|.content:has(> .toc) > .toc{grid-column:2;grid-row:1;margin:0;position:sticky;top:64px;max-height:calc(100vh - 108px);overflow-y:auto}
      #|}
      #|@media(max-width:
      #|
    ),
  )
  out.write_string(narrow.to_string())
  out.write_string(
    (
      #|px){
      #|.content{margin:0;padding-left:32px;padding-right:32px}
      #|}
      #|@media(max-width:760px){
      #|aside{position:relative;width:auto;padding:20px 20px 16px;border-right:0;border-bottom:1px solid var(--rule);box-shadow:none;background:var(--card)}
      #|.brand{padding:0}
      #|.search{margin:16px 0 10px}
      #|.search-results{position:relative;top:6px;box-shadow:var(--shadow-card)}
      #|nav{display:flex;gap:6px;margin:14px 0 14px;overflow-x:auto;scrollbar-width:none}
      #|nav a{white-space:nowrap;padding:7px 14px}
      #|nav a.active::before,nav a.active::after{display:none}
      #|.theme-toggle{width:auto;margin-top:16px;align-self:flex-start}
      #|main{margin-left:0;min-height:0}
      #|.content{padding:34px 20px 64px}
      #|.content h1{font-size:clamp(1.85rem,1.3rem+2vw,2.3rem)}
      #|.content h2{margin-top:2em;padding-top:1.2rem}
      #|.toc{grid-row:auto;margin-bottom:1.6rem;padding:16px 18px}
      #|}
      #|@media print{
      #|aside,.reading-progress,.skip-link,.theme-toggle,.search,.copy-code{display:none!important}
      #|main{margin-left:0}
      #|.content{max-width:none;display:block;padding:0}
      #|body{background:#fff;color:#000}
      #|pre{border:1px solid #b9b9b9;background:#f7f7f7;color:#111;box-shadow:none}
      #|pre code{color:#111}
      #|.toc{display:none}
      #|a{color:#000;text-decoration:underline}
      #|}
      #|@media(prefers-reduced-motion:reduce){
      #|html{scroll-behavior:auto}
      #|*,*::before,*::after{transition-duration:.01ms!important;animation-duration:.01ms!important;animation-iteration-count:1!important}
      #|.reading-progress{transition:none}
      #|}
      #|
    ),
  )
  out.write_string("</style>\n")
  out.to_string()
}

///|
fn positive_or_default(value : Int, fallback : Int) -> Int {
  if value > 0 {
    value
  } else {
    fallback
  }
}

///|
fn safe_language(language : String) -> String {
  let value = language.trim().to_owned()
  if value == "" {
    return "en"
  }
  for _, ch in value {
    let lower = ch.to_ascii_lowercase()
    if !(lower is ('a'..='z')) && !(lower is ('0'..='9')) && ch != '-' {
      return "en"
    }
  }
  value
}

///|
fn render_toc(items : Array[TocItem]) -> String {
  if items.length() == 0 {
    return ""
  }
  let out = StringBuilder()
  out.write_string(
    "<section class=\"toc\"><div class=\"toc-title\">On this page</div>\n",
  )
  for item in items {
    out.write_string("<a class=\"level-")
    out.write_string(item.level.to_string())
    out.write_string("\" href=\"#")
    out.write_string(html_escape(item.anchor))
    out.write_string("\">")
    out.write_string(html_escape(item.title))
    out.write_string("</a>\n")
  }
  out.write_string("</section>\n")
  out.to_string()
}

///|
/// One runnable MoonBit example extracted from a fenced code block.
pub(all) struct DocExample {
  index : Int
  code : String
}

///|
fn first_token(text : String) -> String {
  let out = StringBuilder()
  for ch in text {
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      break
    }
    out.write_char(ch)
  }
  out.to_string()
}

///|
fn info_has_flag(language : String, flag : String) -> Bool {
  let mut found = false
  for word in language.split(" ") {
    if word == flag {
      found = true
    }
  }
  found
}

///|
/// Report whether a fenced code block info string marks a runnable MoonBit
/// example. Blocks tagged `nocheck` are skipped, matching the MoonBit
/// documentation convention, so illustrative snippets stay illustrative.
pub fn is_runnable_moonbit_example(language : String) -> Bool {
  if info_has_flag(language, "nocheck") {
    return false
  }
  let tag = first_token(language)
  tag == "mbt" || tag == "moonbit"
}

///|
/// Extract runnable MoonBit examples from one Markdown document.
pub fn extract_doc_examples(markdown : String) -> Array[DocExample] {
  let out : Array[DocExample] = []
  for block in parse_body_blocks(markdown) {
    match block {
      CodeBlock(language, code) =>
        if is_runnable_moonbit_example(language) {
          out.push({ index: out.length(), code, })
        }
      _ => ()
    }
  }
  out
}

///|
fn trim_end_newlines(text : String) -> String {
  let chars : Array[Char] = []
  for ch in text {
    chars.push(ch)
  }
  let mut end = chars.length()
  while end > 0 && (chars[end - 1] == '\n' || chars[end - 1] == '\r') {
    end = end - 1
  }
  let out = StringBuilder()
  let mut i = 0
  while i < end {
    out.write_char(chars[i])
    i = i + 1
  }
  out.to_string()
}

///|
fn strip_doc_markers(code : String) -> String {
  let out = StringBuilder()
  for raw in code.split("\n") {
    let line = raw.to_owned()
    if !line.trim().to_owned().has_prefix("///|") {
      out.write_string(line)
      out.write_char('\n')
    }
  }
  out.to_string()
}

///|
/// Render extracted examples as MoonBit test source, one `test` block per
/// example.
///
/// MoonBit only accepts imports in `moon.pkg`, so `import_package` is emitted
/// as a comment telling the caller what the target package must import, rather
/// than as a declaration that would fail to compile.
pub fn render_doc_test_file(
  examples : Array[DocExample],
  import_package : String,
) -> String {
  let out = StringBuilder()
  out.write_string(
    "// Generated by MoonDocKit from documented examples. Do not edit.\n",
  )
  if import_package != "" {
    out.write_string(
      "// The target package moon.pkg must import this package:\n",
    )
    out.write_string("//   import { \"")
    out.write_string(import_package)
    out.write_string("\" }\n")
  }
  out.write_char('\n')
  for example in examples {
    out.write_string("///|\n")
    out.write_string("test \"doc example ")
    out.write_string(example.index.to_string())
    out.write_string("\" {\n")
    if example.code != "" {
      let body = trim_end_newlines(strip_doc_markers(example.code))
      if body != "" {
        out.write_string(body)
        out.write_char('\n')
      }
    }
    out.write_string("}\n\n")
  }
  out.to_string()
}

///|
/// Count runnable MoonBit examples in one Markdown document.
pub fn count_doc_examples(markdown : String) -> Int {
  extract_doc_examples(markdown).length()
}
