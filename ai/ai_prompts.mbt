///|
/// A prompt template with system and user message components.
pub(all) struct PromptTemplate {
  name : String
  version : String
  system : String
  user : String
}

///|
fn function_doc_system() -> String {
  "You are an expert technical writer specializing in MoonBit documentation.\nGenerate clear, accurate, and comprehensive documentation for MoonBit API symbols.\nFollow MoonBit naming conventions and provide practical examples.\nOutput structured Markdown with sections for description, parameters, returns, examples, and notes."
}

///|
fn function_doc_user() -> String {
  "Generate documentation for the following MoonBit API symbol:\n\nModule: {{module}}\nSymbol name: {{name}}\nSymbol kind: {{kind}}\nSignature: {{signature}}\nArity: {{arity}}\nReturn type: {{return_type}}\n\nPlease provide:\n1. A concise description of what this symbol does\n2. Parameter descriptions (if applicable)\n3. Return value description\n4. A practical usage example\n5. Any important notes or caveats"
}

///|
/// Return the function documentation prompt template.
pub fn function_doc_template() -> PromptTemplate {
  {
    name: "function-doc-generator",
    version: "1.0.0",
    system: function_doc_system(),
    user: function_doc_user(),
  }
}

///|
fn quality_system() -> String {
  "You are a documentation quality expert. Assess the given documentation page\nfor completeness, readability, and example coverage.\nProvide specific, actionable suggestions for improvement."
}

///|
fn quality_user() -> String {
  "Assess the quality of the following documentation page:\n\nTitle: {{title}}\n\nContent:\n{{content}}\n\nEvaluate:\n1. Completeness (0-100): Are all key topics covered?\n2. Readability (0-100): Is the writing clear and well-structured?\n3. Example coverage (0-100): Are there sufficient code examples?\n4. List specific strengths\n5. List specific improvement suggestions"
}

///|
/// Return the quality assessment prompt template.
pub fn quality_template() -> PromptTemplate {
  {
    name: "quality-assessor",
    version: "1.0.0",
    system: quality_system(),
    user: quality_user(),
  }
}

///|
fn test_gen_system() -> String {
  "You are a MoonBit testing expert. Generate comprehensive test cases\nfor the given MoonBit API symbols. Follow MoonBit test conventions\nusing the 'test' block syntax with assert_eq and assert_true."
}

///|
fn test_gen_user() -> String {
  "Generate test cases for the following MoonBit API symbol:\n\nModule: {{module}}\nSymbol name: {{name}}\nSymbol kind: {{kind}}\nSignature: {{signature}}\nArity: {{arity}}\nReturn type: {{return_type}}\n\nGenerate:\n1. A basic test case verifying core functionality\n2. An edge case test\n3. A test for error handling (if applicable)"
}

///|
/// Return the test generation prompt template.
pub fn test_gen_template() -> PromptTemplate {
  {
    name: "test-generator",
    version: "1.0.0",
    system: test_gen_system(),
    user: test_gen_user(),
  }
}

///|
/// Fill variables into a template string by replacing {{key}} placeholders.
pub fn fill_prompt(
  template : String,
  variables : Array[(String, String)],
) -> String {
  let mut result = template
  let mut i = 0
  while i < variables.length() {
    let pair = variables[i]
    let key = pair.0
    let value = pair.1
    let placeholder = "{{" + key + "}}"
    result = replace_all(result, placeholder, value)
    i = i + 1
  }
  result
}
