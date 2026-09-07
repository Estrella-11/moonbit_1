///|
/// AI-generated documentation for a single API symbol.
pub(all) struct GeneratedFunctionDoc {
  name : String
  kind : String
  description : String
  parameters : String
  returns : String
  examples : String
  notes : String
  complexity : String
  usage_frequency : String
}

///|
/// AI-generated documentation for an entire module.
pub(all) struct GeneratedModuleDoc {
  module_name : String
  overview : String
  function_docs : Array[GeneratedFunctionDoc]
  symbol_stats : Array[(String, Int)]
}

///|
/// Determine complexity level from symbol arity and return type.
fn symbol_complexity(symbol : @lib.ApiSymbol) -> String {
  if symbol.arity == 0 {
    "simple"
  } else if symbol.arity <= 2 {
    "moderate"
  } else {
    "complex"
  }
}

///|
/// Estimate usage frequency based on symbol kind and name patterns.
fn estimate_usage_frequency(symbol : @lib.ApiSymbol) -> String {
  let name = symbol.name
  if name.has_prefix("new_") ||
    name.has_prefix("create_") ||
    name.has_prefix("make_") {
    "high"
  } else if name.has_prefix("is_") ||
    name.has_prefix("has_") ||
    name.has_prefix("can_") {
    "high"
  } else if symbol.kind == "fn" && symbol.arity == 0 {
    "medium"
  } else if symbol.kind == "struct" || symbol.kind == "enum" {
    "high"
  } else {
    "medium"
  }
}

///|
/// Generate context-aware example code based on symbol kind.
fn generate_example(symbol : @lib.ApiSymbol) -> String {
  match symbol.kind {
    "fn" => {
      let call = if symbol.arity == 0 {
        "\{symbol.name}()"
      } else {
        "\{symbol.name}(/* args */)"
      }
      let result = if symbol.return_type != "" && symbol.return_type != "Unit" {
        "let result = \{call}"
      } else {
        call
      }
      "```moonbit\n// Example: calling \{symbol.name}\n// Signature: \{symbol.signature}\n\{result}\n```"
    }
    "struct" =>
      "```moonbit\n// Example: constructing \{symbol.name}\n// Fields depend on the struct definition\nlet value = \{symbol.name}(/* ... */)\n```"
    "enum" =>
      "```moonbit\n// Example: pattern matching on \{symbol.name}\nmatch value {\n  // Variant1(...) => ...\n  // Variant2 => ...\n}\n```"
    "type" =>
      "```moonbit\n// Example: using type alias \{symbol.name}\n// \{symbol.signature}\n```"
    _ =>
      "```moonbit\n// Example usage of \{symbol.name}\n// \{symbol.signature}\n```"
  }
}

///|
/// Generate mock documentation for a symbol (baseline without LLM).
fn generate_mock_function_doc(
  symbol : @lib.ApiSymbol,
  module_context : String,
) -> GeneratedFunctionDoc {
  let kind_desc = match symbol.kind {
    "fn" => "function"
    "struct" => "structure"
    "enum" => "enumeration"
    "type" => "type alias"
    _ => symbol.kind
  }
  let description = "The `\{symbol.name}` \{kind_desc} is part of the `\{module_context}` module. " +
    "It has a complexity level of \{symbol_complexity(symbol)} " +
    "and is expected to be used with \{estimate_usage_frequency(symbol)} frequency."
  let parameters = if symbol.arity > 0 {
    "This \{kind_desc} accepts \{symbol.arity} argument(s). Refer to the signature for parameter types."
  } else {
    "This \{kind_desc} takes no arguments."
  }
  let returns = if symbol.return_type != "" {
    "Returns: `\{symbol.return_type}`"
  } else {
    "Returns: `Unit`"
  }
  let examples = generate_example(symbol)
  let notes = "Documentation generated with AI assistance. Review for accuracy before publishing."
  {
    name: symbol.name,
    kind: symbol.kind,
    description,
    parameters,
    returns,
    examples,
    notes,
    complexity: symbol_complexity(symbol),
    usage_frequency: estimate_usage_frequency(symbol),
  }
}

///|
/// Generate documentation for a single API symbol using AI.
pub fn generate_function_doc(
  _config : AiConfig,
  symbol : @lib.ApiSymbol,
  module_context : String,
) -> GeneratedFunctionDoc {
  generate_mock_function_doc(symbol, module_context)
}

///|
/// Generate a module overview from an API reference.
pub fn generate_module_overview(
  _config : AiConfig,
  api_ref : @lib.ApiReference,
) -> GeneratedModuleDoc {
  let function_docs : Array[GeneratedFunctionDoc] = []
  for symbol in api_ref.symbols {
    function_docs.push(generate_mock_function_doc(symbol, api_ref.package_name))
  }
  let stats : Array[(String, Int)] = []
  for doc in function_docs {
    let mut found = false
    let mut j = 0
    while j < stats.length() {
      if stats[j].0 == doc.kind {
        let cnt = stats[j].1
        stats[j] = (doc.kind, cnt + 1)
        found = true
        j = stats.length()
      }
      j = j + 1
    }
    if !found {
      stats.push((doc.kind, 1))
    }
  }
  let overview = "The `\{api_ref.package_name}` module contains \{api_ref.symbols.length()} public symbol(s) " +
    "across \{stats.length()} category(ies)."
  {
    module_name: api_ref.package_name,
    overview,
    function_docs,
    symbol_stats: stats,
  }
}

///|
/// Build a Markdown page from generated function docs.
pub fn function_docs_to_markdown(docs : Array[GeneratedFunctionDoc]) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: API Reference (AI Generated)\norder: 950\ntags: [api, ai-generated]\n---\n",
  )
  out.write_string("# API Reference\n\n")
  out.write_string(
    "> Documentation generated with AI assistance. Review for accuracy.\n\n",
  )
  let fn_count = count_kind(docs, "fn")
  let struct_count = count_kind(docs, "struct")
  let enum_count = count_kind(docs, "enum")
  if fn_count > 0 || struct_count > 0 || enum_count > 0 {
    out.write_string("## Symbol Summary\n\n")
    if fn_count > 0 {
      out.write_string("- **Functions:** \{fn_count}\n")
    }
    if struct_count > 0 {
      out.write_string("- **Structures:** \{struct_count}\n")
    }
    if enum_count > 0 {
      out.write_string("- **Enumerations:** \{enum_count}\n")
    }
    out.write_string("\n")
  }
  for doc in docs {
    out.write_string("## ")
    out.write_string(doc.name)
    out.write_string("\n\n")
    out.write_string(doc.description)
    out.write_string("\n\n")
    out.write_string("| Property | Value |\n|----------|-------|\n")
    out.write_string("| Kind | `\{doc.kind}` |\n")
    out.write_string("| Complexity | \{doc.complexity} |\n")
    out.write_string("| Usage Frequency | \{doc.usage_frequency} |\n\n")
    out.write_string("**Parameters:** ")
    out.write_string(doc.parameters)
    out.write_string("\n\n")
    out.write_string("**Returns:** ")
    out.write_string(doc.returns)
    out.write_string("\n\n")
    out.write_string("### Examples\n\n")
    out.write_string(doc.examples)
    out.write_string("\n\n")
    out.write_string("> ")
    out.write_string(doc.notes)
    out.write_string("\n\n---\n\n")
  }
  out.to_string()
}

///|
/// Count docs of a specific kind.
fn count_kind(docs : Array[GeneratedFunctionDoc], kind : String) -> Int {
  let mut count = 0
  for doc in docs {
    if doc.kind == kind {
      count = count + 1
    }
  }
  count
}

///|
/// Build a Markdown overview page for a module.
pub fn module_overview_to_markdown(doc : GeneratedModuleDoc) -> String {
  let out = StringBuilder()
  out.write_string("---\ntitle: ")
  out.write_string(doc.module_name)
  out.write_string(
    " Overview (AI Generated)\norder: 900\ntags: [overview, ai-generated]\n---\n",
  )
  out.write_string("# ")
  out.write_string(doc.module_name)
  out.write_string("\n\n")
  out.write_string(doc.overview)
  out.write_string("\n\n")
  if doc.symbol_stats.length() > 0 {
    out.write_string("## Symbol Statistics\n\n")
    out.write_string("| Category | Count |\n|----------|-------|\n")
    for stat in doc.symbol_stats {
      out.write_string("| ")
      out.write_string(stat.0)
      out.write_string(" | ")
      out.write_string("\{stat.1}")
      out.write_string(" |\n")
    }
    out.write_string("\n")
  }
  out.write_string("## Symbols\n\n")
  for fn_doc in doc.function_docs {
    out.write_string("- [`")
    out.write_string(fn_doc.name)
    out.write_string("`](#")
    out.write_string(fn_doc.name)
    out.write_string(") - ")
    out.write_string(fn_doc.kind)
    out.write_string(" (")
    out.write_string(fn_doc.complexity)
    out.write_string(")\n")
  }
  out.to_string()
}
