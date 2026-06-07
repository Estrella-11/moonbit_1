///|
/// Run with `moon run cmd/main` from the project root.
fn main {
  let guide : @moondockit.DocPage = {
    title: "Quick Start",
    slug: "quick-start",
    source: "---\norder: 1\ntags: [guide, moonbit]\n---\n# Quick Start\n\nMoonDocKit turns MoonBit package notes into a small documentation site.\n\n- build pages\n- escape HTML\n- generate navigation\n",
  }
  let api : @moondockit.DocPage = {
    title: "API Reference",
    slug: "api",
    source: "---\norder: 2\ntags: [reference]\n---\n# API Reference\n\nUse `build_site_manifest` to generate static output files.\n",
  }
  let site : @moondockit.DocSite = { title: "MoonDocKit Demo", pages: [guide, api] }
  let summary = @moondockit.summarize_site(site)
  let report = @moondockit.validate_site(site)
  println("MoonDocKit Demo")
  println("pages: \{summary.page_count}, outputs: \{summary.output_count}, search entries: \{summary.search_entry_count}, tags: \{summary.tag_count}")
  println("diagnostics: \{report.diagnostics.length()}, has errors: \{@moondockit.has_validation_errors(report)}")
  println("files:")
  for file in @moondockit.build_site_manifest(site) {
    println("- \{file.path} (\{file.content.length()} bytes)")
  }
}
