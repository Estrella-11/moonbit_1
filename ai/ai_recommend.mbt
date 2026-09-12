///|
/// A content recommendation linking pages in a learning path.
pub(all) struct Recommendation {
  from_page : String
  to_page : String
  reason : String
  confidence : Int
}

///|
/// A structured learning path through the documentation.
pub(all) struct LearningPath {
  steps : Array[String]
  description : String
  difficulty : String
  estimated_time : Int
}

///|
/// Site-level recommendation report.
pub(all) struct RecommendationReport {
  next_steps : Array[Recommendation]
  related_pages : Array[Recommendation]
  learning_paths : Array[LearningPath]
  top_hub_pages : Array[(String, Int)]
  recommendations_count : Int
}

///|
/// Determine difficulty level from content analysis.
fn estimate_difficulty(page : @lib.DocPage) -> String {
  let metrics = @lib.measure_document(page.source)
  if metrics.word_count < 50 {
    "beginner"
  } else if metrics.code_block_count >= 3 && metrics.word_count >= 150 {
    "advanced"
  } else if metrics.word_count >= 100 {
    "intermediate"
  } else {
    "beginner"
  }
}

///|
/// Check if page A is a prerequisite for page B.
fn is_prerequisite(page_a : @lib.DocPage, page_b : @lib.DocPage) -> (Bool, Int) {
  let title_a = page_a.title.to_lower()
  let title_b = page_b.title.to_lower()
  let mut confidence = 0
  if title_a.contains("start") ||
    title_a.contains("intro") ||
    title_a.contains("getting") {
    if title_b.contains("advanced") ||
      title_b.contains("api") ||
      title_b.contains("reference") {
      confidence = 80
    } else if title_b.contains("guide") || title_b.contains("tutorial") {
      confidence = 60
    }
  }
  if title_a.contains("install") &&
    (title_b.contains("start") || title_b.contains("setup")) {
    confidence = 75
  }
  if title_a.contains("guide") && title_b.contains("api") {
    confidence = 50
  }
  if title_a.contains("basic") && title_b.contains("advanced") {
    confidence = 70
  }
  (confidence > 0, confidence)
}

///|
/// Find pages that share significant keywords for related content.
fn find_related(
  page : @lib.DocPage,
  all_pages : Array[@lib.DocPage],
  cached_blocks : Array[(String, Array[@lib.MarkdownBlock])],
) -> Array[(String, Int)] {
  let related : Array[(String, Int)] = []
  let page_blocks = @lib.parse_blocks(page.source)
  let page_keywords : Array[String] = []
  for block in page_blocks {
    match block {
      @lib.MarkdownBlock::Heading(_, text) => {
        let words = text.split(" ").collect()
        for w in words {
          let word = w.trim().to_owned().to_lower()
          if word.length() >= 4 {
            let mut found = false
            for k in page_keywords {
              if k == word {
                found = true
              }
            }
            if !found {
              page_keywords.push(word)
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
            for k in page_keywords {
              if k == word {
                found = true
              }
            }
            if !found {
              page_keywords.push(word)
            }
          }
        }
      }
      _ => ()
    }
  }
  for other in all_pages {
    if other.title == page.title {
      continue
    }
    let mut other_blocks : Array[@lib.MarkdownBlock] = []
    let mut found_cache = false
    for cache in cached_blocks {
      if cache.0 == other.title {
        other_blocks = cache.1
        found_cache = true
      }
    }
    if !found_cache {
      other_blocks = @lib.parse_blocks(other.source)
    }
    let mut shared = 0
    for block in other_blocks {
      match block {
        @lib.MarkdownBlock::Heading(_, text) => {
          let words = text.split(" ").collect()
          for w in words {
            let word = w.trim().to_owned().to_lower()
            if word.length() >= 4 {
              for k in page_keywords {
                if k == word {
                  shared = shared + 1
                }
              }
            }
          }
        }
        @lib.MarkdownBlock::Paragraph(text) => {
          let words = text.split(" ").collect()
          for w in words {
            let word = w.trim().to_owned().to_lower()
            if word.length() >= 5 {
              for k in page_keywords {
                if k == word {
                  shared = shared + 1
                }
              }
            }
          }
        }
        _ => ()
      }
    }
    if shared >= 2 {
      related.push((other.title, shared * 15))
    }
  }
  sort_by_count(related)
}

///|
/// Build a learning path from a starting page.
fn build_learning_path(
  start : @lib.DocPage,
  all_pages : Array[@lib.DocPage],
) -> LearningPath {
  let steps : Array[String] = [start.title]
  let mut current = start
  let mut i = 0
  while i < all_pages.length() {
    let mut best_next : @lib.DocPage? = None
    let mut best_confidence = 0
    for candidate in all_pages {
      let mut already = false
      for s in steps {
        if s == candidate.title {
          already = true
        }
      }
      if already {
        continue
      }
      let (is_pre, conf) = is_prerequisite(current, candidate)
      if is_pre && conf > best_confidence {
        best_confidence = conf
        best_next = Some(candidate)
      }
    }
    match best_next {
      Some(next_page) => {
        steps.push(next_page.title)
        current = next_page
      }
      None => ()
    }
    i = i + 1
  }
  let mut total_time = 0
  let reading_cache : Array[(String, Int)] = []
  for p in all_pages {
    let metrics = @lib.measure_document(p.source)
    reading_cache.push((p.title, metrics.reading_minutes))
  }
  for s in steps {
    for pair in reading_cache {
      if pair.0 == s {
        total_time = total_time + pair.1
      }
    }
  }
  let difficulty = estimate_difficulty(start)
  let desc = if steps.length() > 1 {
    "Start with \{steps[0]}, then progress through \{steps.length() - 1} related page(s)."
  } else {
    "Single-page path starting with \{steps[0]}."
  }
  { steps, description: desc, difficulty, estimated_time: total_time, }
}

///|
/// Generate content recommendations for a documentation site.
pub fn generate_recommendations(site : @lib.DocSite) -> RecommendationReport {
  let next_steps : Array[Recommendation] = []
  let related : Array[Recommendation] = []
  let hub_counts : Array[(String, Int)] = []
  let cached_blocks : Array[(String, Array[@lib.MarkdownBlock])] = []
  for page in site.pages {
    cached_blocks.push((page.title, @lib.parse_blocks(page.source)))
  }
  let mut i = 0
  while i < site.pages.length() {
    let page = site.pages[i]
    let mut j = 0
    while j < site.pages.length() {
      if i != j {
        let candidate = site.pages[j]
        let (is_pre, conf) = is_prerequisite(page, candidate)
        if is_pre {
          next_steps.push({
            from_page: page.title,
            to_page: candidate.title,
            reason: "Natural progression from \{page.title} to \{candidate.title}",
            confidence: conf,
          })
          increment_count(hub_counts, candidate.title)
        }
      }
      j = j + 1
    }
    let related_pages = find_related(page, site.pages, cached_blocks)
    for pair in related_pages {
      let mut already = false
      for r in related {
        if r.from_page == page.title && r.to_page == pair.0 {
          already = true
        }
      }
      if !already {
        related.push({
          from_page: page.title,
          to_page: pair.0,
          reason: "Shares significant keywords and topic overlap",
          confidence: if pair.1 > 100 {
            100
          } else {
            pair.1
          },
        })
      }
    }
    i = i + 1
  }
  let paths : Array[LearningPath] = []
  for page in site.pages {
    let title_lower = page.title.to_lower()
    if title_lower.contains("start") ||
      title_lower.contains("intro") ||
      title_lower.contains("getting") ||
      title_lower.contains("install") {
      paths.push(build_learning_path(page, site.pages))
    }
  }
  let sorted_hubs = sort_by_count(hub_counts)
  let top_hubs = take_top_n_pairs(sorted_hubs, 5)
  {
    next_steps,
    related_pages: related,
    learning_paths: paths,
    top_hub_pages: top_hubs,
    recommendations_count: next_steps.length() + related.length(),
  }
}

///|
/// Convert a recommendation report to a Markdown page.
pub fn recommendations_to_markdown(report : RecommendationReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI Content Recommendations\norder: 890\ntags: [recommendations, ai-generated]\n---\n",
  )
  out.write_string("# AI Content Recommendations\n\n")
  out.write_string(
    "> AI-generated learning paths and related content suggestions.\n\n",
  )
  out.write_string("## Summary\n\n")
  out.write_string("- **Next Steps:** \{report.next_steps.length()}\n")
  out.write_string("- **Related Pages:** \{report.related_pages.length()}\n")
  out.write_string("- **Learning Paths:** \{report.learning_paths.length()}\n")
  out.write_string(
    "- **Total Recommendations:** \{report.recommendations_count}\n\n",
  )
  if report.learning_paths.length() > 0 {
    out.write_string("## Learning Paths\n\n")
    let mut i = 0
    for path in report.learning_paths {
      i = i + 1
      out.write_string("### Path \{i}: ")
      out.write_string(path.difficulty)
      out.write_string(" (\{path.estimated_time} min)\n\n")
      out.write_string(path.description)
      out.write_string("\n\n")
      let mut step = 0
      while step < path.steps.length() {
        out.write_string("\{step + 1}. ")
        out.write_string(path.steps[step])
        out.write_string("\n")
        step = step + 1
      }
      out.write_string("\n")
    }
  }
  if report.next_steps.length() > 0 {
    out.write_string("## Next Steps\n\n")
    for rec in report.next_steps {
      out.write_string("- **")
      out.write_string(rec.from_page)
      out.write_string("** → **")
      out.write_string(rec.to_page)
      out.write_string("** (confidence: \{rec.confidence}%)\n  - ")
      out.write_string(rec.reason)
      out.write_string("\n")
    }
    out.write_string("\n")
  }
  if report.related_pages.length() > 0 {
    out.write_string("## Related Pages\n\n")
    for rec in report.related_pages {
      out.write_string("- **")
      out.write_string(rec.from_page)
      out.write_string("** ↔ **")
      out.write_string(rec.to_page)
      out.write_string("** (confidence: \{rec.confidence}%)\n  - ")
      out.write_string(rec.reason)
      out.write_string("\n")
    }
    out.write_string("\n")
  }
  if report.top_hub_pages.length() > 0 {
    out.write_string("## Hub Pages (Most Recommended Destinations)\n\n")
    out.write_string(
      "| Page | Incoming Recommendations |\n|------|------------------------|\n",
    )
    for pair in report.top_hub_pages {
      out.write_string("| ")
      out.write_string(pair.0)
      out.write_string(" | ")
      out.write_string("\{pair.1}")
      out.write_string(" |\n")
    }
  }
  out.to_string()
}
