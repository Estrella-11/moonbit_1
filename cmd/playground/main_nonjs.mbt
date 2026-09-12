///|
/// The playground only produces a browser bundle, so non-JavaScript targets get
/// a no-op entry point that still type-checks and builds.
fn main {
  println(
    "MoonDocKit playground: build with --target js to produce the browser bundle.",
  )
}
