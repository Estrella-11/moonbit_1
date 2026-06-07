///|
/// Run with `moon run cmd/main` from the project root.
fn main {
  let guide : @moondockit.DocPage = {
    title: "Quick Start",
    slug: "quick-start",
    source: "# Quick Start\n\nMoonDocKit turns MoonBit package notes into a small documentation site.\n\n- build pages\n- escape HTML\n- generate navigation\n",
  }
  let site : @moondockit.DocSite = { title: "MoonDocKit Demo", pages: [guide] }
  let pages = @moondockit.render_site(site)
  println(pages[0].html)
}
