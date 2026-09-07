///|
/// AI provider configuration for LLM integration.
pub(all) struct AiConfig {
  provider : String
  api_key : String
  api_base : String
  model : String
  temperature : Double
  max_tokens : Int
  timeout_ms : Int
}

///|
/// A single chat message in an LLM conversation.
pub(all) struct ChatMessage {
  role : String
  content : String
}

///|
/// Response from an LLM chat completion request.
pub(all) struct ChatResponse {
  content : String
  tokens_used : Int
  success : Bool
  error : String
}

///|
/// Default AI configuration with safe fallback values.
pub fn default_ai_config() -> AiConfig {
  {
    provider: "mock",
    api_key: "",
    api_base: "",
    model: "moondockit-mock",
    temperature: 0.7,
    max_tokens: 2048,
    timeout_ms: 30000,
  }
}

///|
/// Escape a string for safe JSON string value embedding.
fn json_escape_str(input : String) -> String {
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
/// Build a JSON request body for OpenAI-compatible chat completions.
pub fn build_chat_request_json(
  config : AiConfig,
  messages : Array[ChatMessage],
) -> String {
  let out = StringBuilder()
  out.write_string("{\"model\":\"")
  out.write_string(json_escape_str(config.model))
  out.write_string("\",\"temperature\":")
  out.write_string("\{config.temperature}")
  out.write_string(",\"max_tokens\":")
  out.write_string("\{config.max_tokens}")
  out.write_string(",\"messages\":[")
  let mut i = 0
  while i < messages.length() {
    if i > 0 {
      out.write_string(",")
    }
    let msg = messages[i]
    out.write_string("{\"role\":\"")
    out.write_string(json_escape_str(msg.role))
    out.write_string("\",\"content\":\"")
    out.write_string(json_escape_str(msg.content))
    out.write_string("\"}")
    i = i + 1
  }
  out.write_string("]}")
  out.to_string()
}

///|
/// Replace all occurrences of target with replacement in a string.
fn replace_all(input : String, target : String, replacement : String) -> String {
  if target.length() == 0 {
    return input
  }
  let out = StringBuilder(size_hint=input.length())
  let mut i = 0
  while i < input.length() {
    if i + target.length() <= input.length() &&
      input[i:i + target.length()] == target {
      out.write_string(replacement)
      i = i + target.length()
    } else {
      out.write_string(input[i:i + 1].to_owned())
      i = i + 1
    }
  }
  out.to_string()
}

///|
/// Find the position of a substring, or -1 if not found.
fn find_substring(haystack : String, needle : String) -> Int {
  if needle.length() == 0 {
    return 0
  }
  let mut i = 0
  while i + needle.length() <= haystack.length() {
    if haystack[i:i + needle.length()] == needle {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// Parse a JSON response field by extracting the value between quotes.
pub fn extract_json_field(json : String, field : String) -> String {
  let key = "\"" + field + "\":\""
  let pos = find_substring(json, key)
  if pos < 0 {
    return ""
  }
  let value_start = pos + key.length()
  let mut end = value_start
  while end < json.length() {
    let ch = json[end:end + 1]
    if ch == "\"" {
      return json[value_start:end].to_owned()
    }
    if ch == "\\" && end + 1 < json.length() {
      end = end + 2
    } else {
      end = end + 1
    }
  }
  ""
}
