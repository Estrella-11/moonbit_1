///|
/// AI-detected cross-reference between two documentation pages.
pub(all) struct CrossReference {
  source_page : String
  target_page : String
  relevance_score : Int
  reason : String
  shared_keywords : Array[String]
}

///|
/// Site-level cross-reference map.
pub(all) struct XrefReport {
  total_references : Int
  references : Array[CrossReference]
  orphan_pages : Array[String]
  most_referenced : Array[(String, Int)]
}

///|
/// Extract significant keywords from page content for matching.
fn page_keywords(title : String, content : String) -> Array[String] {
  let keywords : Array[String] = []
  let title_words = title.split(" ").collect()
  for w in title_words {
    let word = w.trim().to_owned().to_lower()
    if word.length() >= 3 {
      let mut found = false
      for k in keywords {
        if k == word {
          found = true
        }
      }
      if !found {
        keywords.push(word)
      }
    }
  }
  let blocks = @lib.parse_blocks(content)
  for block in blocks {
    match block {
      @lib.MarkdownBlock::Heading(_, text) => {
        let words = text.split(" ").collect()
        for w in words {
          let word = w.trim().to_owned().to_lower()
          if word.length() >= 4 {
            let mut found = false
            for k in keywords {
              if k == word {
                found = true
              }
            }
            if !found {
              keywords.push(word)
            }
          }
        }
      }
      @lib.MarkdownBlock::Paragraph(text) => {
        let words = text.split(" ").collect()
        for w in words {
          let word = w.trim().to_owned().to_lower()
          if word.length() >= 5 {
            let mut found = false
            for k in keywords {
              if k == word {
                found = true
              }
            }
            if !found {
              keywords.push(word)
            }
          }
        }
      }
      _ => ()
    }
  }
  keywords
}

///|
/// Calculate keyword overlap between two pages.
fn keyword_overlap(a : Array[String], b : Array[String]) -> Array[String] {
  let shared : Array[String] = []
  for kw in a {
    let mut found = false
    for other in b {
      if kw == other {
        found = true
      }
    }
    if found {
      let mut already = false
      for s in shared {
        if s == kw {
          already = true
        }
      }
      if !already {
        shared.push(kw)
      }
    }
  }
  shared
}

///|
/// Detect cross-references for all pages in a documentation site.
pub fn detect_cross_references(site : @lib.DocSite) -> XrefReport {
  let page_data : Array[(String, Array[String])] = []
  for page in site.pages {
    page_data.push((page.title, page_keywords(page.title, page.source)))
  }
  let references : Array[CrossReference] = []
  let referenced_targets : Array[String] = []
  for i in 0..<page_data.length() {
    let source_title = page_data[i].0
    let source_kw = page_data[i].1
    for j in 0..<page_data.length() {
      if i == j {
        continue
      }
      let target_title = page_data[j].0
      let target_kw = page_data[j].1
      let shared = keyword_overlap(source_kw, target_kw)
      if shared.length() >= 1 {
        let score = shared.length() * 20
        let final_score = if score > 100 { 100 } else { score }
        references.push({
          source_page: source_title,
          target_page: target_title,
          relevance_score: final_score,
          reason: "Shares \{shared.length()} keywords with this page",
          shared_keywords: shared,
        })
        referenced_targets.push(target_title)
      }
    }
  }
  let all_pages : Array[String] = []
  for page in site.pages {
    all_pages.push(page.title)
  }
  let orphans : Array[String] = []
  for page in all_pages {
    let mut found = false
    for target in referenced_targets {
      if target == page {
        found = true
      }
    }
    if !found {
      orphans.push(page)
    }
  }
  let ref_counts : Array[(String, Int)] = []
  for page in all_pages {
    let mut count = 0
    for target in referenced_targets {
      if target == page {
        count = count + 1
      }
    }
    if count > 0 {
      ref_counts.push((page, count))
    }
  }
  let mut idx = 0
  while idx < ref_counts.length() {
    let mut max_idx = idx
    let mut k = idx + 1
    while k < ref_counts.length() {
      if ref_counts[k].1 > ref_counts[max_idx].1 {
        max_idx = k
      }
      k = k + 1
    }
    if max_idx != idx {
      let tmp = ref_counts[idx]
      ref_counts[idx] = ref_counts[max_idx]
      ref_counts[max_idx] = tmp
    }
    idx = idx + 1
  }
  let top_referenced : Array[(String, Int)] = []
  let limit = if ref_counts.length() < 5 { ref_counts.length() } else { 5 }
  let mut i = 0
  while i < limit {
    top_referenced.push(ref_counts[i])
    i = i + 1
  }
  {
    total_references: references.length(),
    references,
    orphan_pages: orphans,
    most_referenced: top_referenced,
  }
}

///|
/// Convert a cross-reference report to a Markdown page.
pub fn xref_to_markdown(report : XrefReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI Cross-Reference Map\norder: 850\ntags: [xref, ai-generated]\n---\n",
  )
  out.write_string("# AI Cross-Reference Map\n\n")
  out.write_string(
    "> AI-detected relationships between documentation pages.\n\n",
  )
  out.write_string("## Overview\n\n")
  out.write_string("- **Total References:** \{report.total_references}\n")
  out.write_string("- **Orphan Pages:** \{report.orphan_pages.length()}\n\n")
  if report.orphan_pages.length() > 0 {
    out.write_string("## Orphan Pages (No Incoming References)\n\n")
    for p in report.orphan_pages {
      out.write_string("- ")
      out.write_string(p)
      out.write_string("\n")
    }
    out.write_string("\n")
  }
  if report.most_referenced.length() > 0 {
    out.write_string("## Most Referenced Pages\n\n")
    out.write_string(
      "| Page | Incoming References |\n|------|--------------------|\n",
    )
    for pair in report.most_referenced {
      out.write_string("| ")
      out.write_string(pair.0)
      out.write_string(" | ")
      out.write_string("\{pair.1}")
      out.write_string(" |\n")
    }
    out.write_string("\n")
  }
  out.write_string("## Detected References\n\n")
  for xref in report.references {
    out.write_string("- **")
    out.write_string(xref.source_page)
    out.write_string("** → **")
    out.write_string(xref.target_page)
    out.write_string("** (relevance: \{xref.relevance_score}/100)\n  - ")
    out.write_string(xref.reason)
    out.write_string("; shared: ")
    let mut i = 0
    while i < xref.shared_keywords.length() {
      if i > 0 {
        out.write_string(", ")
      }
      out.write_string("`")
      out.write_string(xref.shared_keywords[i])
      out.write_string("`")
      i = i + 1
    }
    out.write_string("\n")
  }
  out.to_string()
}
