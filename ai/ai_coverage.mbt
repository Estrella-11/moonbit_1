///|
/// Coverage status for a single API symbol.
pub(all) struct SymbolCoverage {
  symbol_name : String
  kind : String
  is_documented : Bool
  coverage_level : String
  found_in_pages : Array[String]
  missing_fields : Array[String]
}

///|
/// Site-level documentation coverage report.
pub(all) struct CoverageReport {
  total_symbols : Int
  documented_symbols : Int
  undocumented_symbols : Int
  coverage_percentage : Int
  by_kind : Array[(String, Int, Int)]
  undocumented_list : Array[SymbolCoverage]
  recommendations : Array[String]
}

///|
/// Check if a symbol name is mentioned in any page's content.
fn find_symbol_in_pages(
  symbol_name : String,
  site : @lib.DocSite,
) -> Array[String] {
  let found_in : Array[String] = []
  for page in site.pages {
    if page.source.contains(symbol_name) {
      found_in.push(page.title)
    }
  }
  found_in
}

///|
/// Determine coverage level based on where and how a symbol appears.
fn coverage_level(_symbol_name : String, found_pages : Array[String]) -> String {
  if found_pages.length() == 0 {
    "none"
  } else if found_pages.length() >= 3 {
    "comprehensive"
  } else if found_pages.length() == 2 {
    "adequate"
  } else {
    "minimal"
  }
}

///|
/// Determine missing documentation fields for a symbol.
fn missing_fields(
  _symbol : @lib.ApiSymbol,
  found_pages : Array[String],
) -> Array[String] {
  let missing : Array[String] = []
  if found_pages.length() == 0 {
    missing.push("No documentation page references this symbol")
    return missing
  }
  let mut has_examples = false
  let mut has_description = false
  let mut has_usage = false
  for page_title in found_pages {
    if page_title.contains("example") || page_title.contains("tutorial") {
      has_examples = true
    }
    if page_title.contains("guide") || page_title.contains("overview") {
      has_description = true
    }
    if page_title.contains("reference") || page_title.contains("api") {
      has_usage = true
    }
  }
  if !has_examples {
    missing.push("Missing usage examples")
  }
  if !has_description {
    missing.push("Missing conceptual description")
  }
  if !has_usage {
    missing.push("Missing API reference entry")
  }
  missing
}

///|
/// Analyze documentation coverage for all API symbols.
pub fn analyze_coverage(
  api_ref : @lib.ApiReference,
  site : @lib.DocSite,
) -> CoverageReport {
  let coverage_list : Array[SymbolCoverage] = []
  let undocumented : Array[SymbolCoverage] = []
  let kind_total : Array[(String, Int)] = []
  let kind_documented : Array[(String, Int)] = []
  for symbol in api_ref.symbols {
    let found_pages = find_symbol_in_pages(symbol.name, site)
    let level = coverage_level(symbol.name, found_pages)
    let missing = missing_fields(symbol, found_pages)
    let entry : SymbolCoverage = {
      symbol_name: symbol.name,
      kind: symbol.kind,
      is_documented: found_pages.length() > 0,
      coverage_level: level,
      found_in_pages: found_pages,
      missing_fields: missing,
    }
    coverage_list.push(entry)
    if found_pages.length() == 0 {
      undocumented.push(entry)
    }
    let mut kind_found = false
    let mut j = 0
    while j < kind_total.length() {
      if kind_total[j].0 == symbol.kind {
        let cnt = kind_total[j].1
        kind_total[j] = (symbol.kind, cnt + 1)
        if found_pages.length() > 0 {
          let doc_cnt = kind_documented[j].1
          kind_documented[j] = (symbol.kind, doc_cnt + 1)
        }
        kind_found = true
        j = kind_total.length()
      }
      j = j + 1
    }
    if !kind_found {
      kind_total.push((symbol.kind, 1))
      if found_pages.length() > 0 {
        kind_documented.push((symbol.kind, 1))
      } else {
        kind_documented.push((symbol.kind, 0))
      }
    }
  }
  let total = api_ref.symbols.length()
  let documented = total - undocumented.length()
  let pct = if total == 0 { 100 } else { documented * 100 / total }
  let by_kind : Array[(String, Int, Int)] = []
  for i in 0..<kind_total.length() {
    by_kind.push((kind_total[i].0, kind_documented[i].1, kind_total[i].1))
  }
  let recommendations : Array[String] = []
  if undocumented.length() > 0 {
    recommendations.push(
      "Add documentation for \{undocumented.length()} undocumented symbol(s)",
    )
  }
  if pct < 50 {
    recommendations.push(
      "Coverage is below 50% - prioritize documenting core API symbols",
    )
  } else if pct < 80 {
    recommendations.push(
      "Coverage is moderate - consider adding more usage examples",
    )
  } else if pct == 100 {
    recommendations.push("Excellent! All API symbols are documented")
  }
  let mut has_missing_examples = false
  for c in coverage_list {
    for m in c.missing_fields {
      if m.contains("examples") {
        has_missing_examples = true
      }
    }
  }
  if has_missing_examples {
    recommendations.push(
      "Some symbols lack usage examples - add tutorial pages",
    )
  }
  {
    total_symbols: total,
    documented_symbols: documented,
    undocumented_symbols: undocumented.length(),
    coverage_percentage: pct,
    by_kind,
    undocumented_list: undocumented,
    recommendations,
  }
}

///|
/// Convert a coverage report to a Markdown page.
pub fn coverage_to_markdown(report : CoverageReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI Documentation Coverage\norder: 870\ntags: [coverage, ai-generated]\n---\n",
  )
  out.write_string("# AI Documentation Coverage Report\n\n")
  out.write_string("> Analysis of API symbol documentation coverage.\n\n")
  out.write_string("## Summary\n\n")
  out.write_string("- **Total Symbols:** \{report.total_symbols}\n")
  out.write_string("- **Documented:** \{report.documented_symbols}\n")
  out.write_string("- **Undocumented:** \{report.undocumented_symbols}\n")
  out.write_string("- **Coverage:** \{report.coverage_percentage}%\n\n")
  if report.by_kind.length() > 0 {
    out.write_string("## Coverage by Symbol Kind\n\n")
    out.write_string(
      "| Kind | Documented | Total | Coverage |\n|------|-----------|-------|----------|\n",
    )
    for kind in report.by_kind {
      let pct = if kind.2 == 0 { 100 } else { kind.1 * 100 / kind.2 }
      out.write_string("| `")
      out.write_string(kind.0)
      out.write_string("` | ")
      out.write_string("\{kind.1}")
      out.write_string(" | ")
      out.write_string("\{kind.2}")
      out.write_string(" | ")
      out.write_string("\{pct}%")
      out.write_string(" |\n")
    }
    out.write_string("\n")
  }
  if report.undocumented_list.length() > 0 {
    out.write_string("## Undocumented Symbols\n\n")
    for sym in report.undocumented_list {
      out.write_string("- **")
      out.write_string(sym.symbol_name)
      out.write_string("** (`")
      out.write_string(sym.kind)
      out.write_string("`) - ")
      if sym.missing_fields.length() > 0 {
        out.write_string(sym.missing_fields[0])
      } else {
        out.write_string("Not referenced in any documentation page")
      }
      out.write_string("\n")
    }
    out.write_string("\n")
  }
  if report.recommendations.length() > 0 {
    out.write_string("## Recommendations\n\n")
    for r in report.recommendations {
      out.write_string("- ")
      out.write_string(r)
      out.write_string("\n")
    }
  }
  out.to_string()
}
