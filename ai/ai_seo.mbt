///|
/// SEO and search metadata for a single documentation page.
pub(all) struct PageSeoMeta {
  page_title : String
  meta_description : String
  slug : String
  tags : Array[String]
  og_type : String
  reading_time : Int
  keyword_density : Array[(String, Int)]
  search_boost : Int
}

///|
/// Site-level SEO report.
pub(all) struct SeoReport {
  total_pages : Int
  pages_with_descriptions : Int
  pages_missing_descriptions : Int
  avg_keyword_count : Int
  pages_with_low_search_boost : Array[String]
  page_metas : Array[PageSeoMeta]
  recommendations : Array[String]
}

///|
/// Generate a meta description from page content (max 160 chars).
fn generate_meta_description(
  title : String,
  blocks : Array[@lib.MarkdownBlock],
) -> String {
  let first_para = find_first_paragraph(blocks)
  if first_para == "" {
    let desc = "\{title} documentation page with guides and examples."
    return desc
  }
  if first_para.length() <= 160 {
    first_para
  } else {
    let mut cut = 157
    while cut > 0 && first_para[cut:cut + 1] != " " {
      cut = cut - 1
    }
    if cut == 0 {
      first_para[0:157].to_owned() + "..."
    } else {
      first_para[0:cut].to_owned() + "..."
    }
  }
}

///|
/// Calculate keyword density for a page using shared word frequency utility.
fn calculate_keyword_density(
  content : String,
  max_count : Int,
) -> Array[(String, Int)] {
  word_frequency(content, max_count, 4)
}

///|
/// Determine OpenGraph type for a page based on block types.
fn determine_og_type(blocks : Array[@lib.MarkdownBlock]) -> String {
  let mut has_code = false
  let mut has_headings = false
  for block in blocks {
    match block {
      @lib.MarkdownBlock::CodeBlock(_, _) => has_code = true
      @lib.MarkdownBlock::Heading(_, _) => has_headings = true
      _ => ()
    }
  }
  if has_code && has_headings {
    "article"
  } else if has_headings {
    "article"
  } else {
    "website"
  }
}

///|
/// Calculate a search boost score based on content quality signals.
fn calculate_search_boost(
  metrics : @lib.DocumentMetrics,
  keyword_count : Int,
) -> Int {
  let mut score = 0
  if metrics.word_count >= 100 {
    score = score + 30
  } else if metrics.word_count >= 50 {
    score = score + 15
  }
  if metrics.heading_count >= 2 {
    score = score + 20
  }
  if metrics.code_block_count >= 1 {
    score = score + 20
  }
  if keyword_count >= 3 {
    score = score + 15
  }
  if metrics.list_item_count >= 1 {
    score = score + 15
  }
  if score > 100 {
    score = 100
  }
  score
}

///|
/// Generate SEO metadata for a single page.
pub fn generate_page_seo(page : @lib.DocPage) -> PageSeoMeta {
  let blocks = @lib.parse_blocks(page.source)
  let metrics = @lib.measure_blocks(blocks)
  let density = calculate_keyword_density(page.source, 5)
  let desc = generate_meta_description(page.title, blocks)
  let og_type = determine_og_type(blocks)
  let boost = calculate_search_boost(metrics, density.length())
  let tags : Array[String] = []
  for i in 0..<density.length() {
    if i < 3 {
      tags.push(density[i].0)
    }
  }
  {
    page_title: page.title,
    meta_description: desc,
    slug: page.slug,
    tags,
    og_type,
    reading_time: metrics.reading_minutes,
    keyword_density: density,
    search_boost: boost,
  }
}

///|
/// Generate SEO metadata for all pages in a site.
pub fn generate_site_seo(site : @lib.DocSite) -> SeoReport {
  let metas : Array[PageSeoMeta] = []
  let mut desc_count = 0
  let mut total_keywords = 0
  let low_boost_pages : Array[String] = []
  for page in site.pages {
    let meta = generate_page_seo(page)
    metas.push(meta)
    if meta.meta_description.length() > 0 {
      desc_count = desc_count + 1
    }
    total_keywords = total_keywords + meta.keyword_density.length()
    if meta.search_boost < 30 {
      low_boost_pages.push(page.title)
    }
  }
  let avg_kw = if site.pages.length() > 0 {
    total_keywords / site.pages.length()
  } else {
    0
  }
  let recommendations : Array[String] = []
  if site.pages.length() > 0 && desc_count < site.pages.length() {
    recommendations.push("Add meta descriptions to pages missing them")
  }
  if low_boost_pages.length() > 0 {
    recommendations.push(
      "\{low_boost_pages.length()} page(s) have low search boost scores; add more content and code examples",
    )
  }
  if avg_kw < 3 {
    recommendations.push(
      "Average keyword count is low; enrich pages with more specific terms",
    )
  }
  {
    total_pages: site.pages.length(),
    pages_with_descriptions: desc_count,
    pages_missing_descriptions: site.pages.length() - desc_count,
    avg_keyword_count: avg_kw,
    pages_with_low_search_boost: low_boost_pages,
    page_metas: metas,
    recommendations,
  }
}

///|
/// Convert a site SEO report to a Markdown page.
pub fn seo_to_markdown(report : SeoReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI SEO Report\norder: 880\ntags: [seo, ai-generated]\n---\n",
  )
  out.write_string("# AI SEO Report\n\n")
  out.write_string("> Search optimization metadata and recommendations.\n\n")
  out.write_string("## Summary\n\n")
  out.write_string("- **Total Pages:** \{report.total_pages}\n")
  out.write_string(
    "- **Pages with Descriptions:** \{report.pages_with_descriptions}\n",
  )
  out.write_string(
    "- **Pages Missing Descriptions:** \{report.pages_missing_descriptions}\n",
  )
  out.write_string(
    "- **Average Keywords per Page:** \{report.avg_keyword_count}\n\n",
  )
  if report.pages_with_low_search_boost.length() > 0 {
    out.write_string("## Pages with Low Search Boost\n\n")
    for p in report.pages_with_low_search_boost {
      out.write_string("- ")
      out.write_string(p)
      out.write_string("\n")
    }
    out.write_string("\n")
  }
  out.write_string("## Page Metadata\n\n")
  for meta in report.page_metas {
    out.write_string("### ")
    out.write_string(meta.page_title)
    out.write_string("\n\n")
    out.write_string("- **Description:** ")
    out.write_string(meta.meta_description)
    out.write_string("\n")
    out.write_string("- **Slug:** `")
    out.write_string(meta.slug)
    out.write_string("`\n")
    out.write_string("- **OG Type:** ")
    out.write_string(meta.og_type)
    out.write_string("\n")
    out.write_string("- **Reading Time:** \{meta.reading_time} min\n")
    out.write_string("- **Search Boost:** \{meta.search_boost}/100\n")
    out.write_string("- **Keywords:** ")
    let mut i = 0
    while i < meta.keyword_density.length() {
      if i > 0 {
        out.write_string(", ")
      }
      out.write_string("`")
      out.write_string(meta.keyword_density[i].0)
      out.write_string("` (\{meta.keyword_density[i].1})")
      i = i + 1
    }
    out.write_string("\n\n")
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
