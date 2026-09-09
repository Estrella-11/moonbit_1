///|
/// Shared utility functions used across AI modules to eliminate duplication.

///|
/// Increment the count for a key in an Array[(String, Int)].
/// If the key doesn't exist, a new entry is pushed.
pub fn increment_count(arr : Array[(String, Int)], key : String) -> Unit {
  let mut j = 0
  while j < arr.length() {
    if arr[j].0 == key {
      let cnt = arr[j].1
      arr[j] = (key, cnt + 1)
      return
    }
    j = j + 1
  }
  arr.push((key, 1))
}

///|
/// Sort an Array[(String, Int)] in descending order by count (selection sort).
pub fn sort_by_count(arr : Array[(String, Int)]) -> Array[(String, Int)] {
  let result : Array[(String, Int)] = []
  for item in arr {
    result.push(item)
  }
  let mut i = 0
  while i < result.length() {
    let mut max_idx = i
    let mut k = i + 1
    while k < result.length() {
      if result[k].1 > result[max_idx].1 {
        max_idx = k
      }
      k = k + 1
    }
    if max_idx != i {
      let tmp = result[i]
      result[i] = result[max_idx]
      result[max_idx] = tmp
    }
    i = i + 1
  }
  result
}

///|
/// Take the first n elements from a (String, Int) array.
pub fn take_top_n_pairs(
  arr : Array[(String, Int)],
  n : Int,
) -> Array[(String, Int)] {
  let result : Array[(String, Int)] = []
  let limit = if arr.length() < n { arr.length() } else { n }
  let mut i = 0
  while i < limit {
    result.push(arr[i])
    i = i + 1
  }
  result
}

///|
/// Take the first n String elements from an array.
pub fn take_top_n_strings(arr : Array[String], n : Int) -> Array[String] {
  let result : Array[String] = []
  let limit = if arr.length() < n { arr.length() } else { n }
  let mut i = 0
  while i < limit {
    result.push(arr[i])
    i = i + 1
  }
  result
}

///|
/// Compute word frequency from content, returning sorted (word, count) pairs.
/// Words shorter than min_word_len characters are ignored.
/// The result is sorted by count descending and limited to max_count entries.
pub fn word_frequency(
  content : String,
  max_count : Int,
  min_word_len : Int,
) -> Array[(String, Int)] {
  let words = content.split(" ").collect()
  let unique_words : Array[String] = []
  let counts : Array[Int] = []
  for word in words {
    let w = word.trim().to_owned().to_lower()
    if w.length() < min_word_len {
      continue
    }
    let mut found = false
    let mut j = 0
    while j < unique_words.length() {
      if unique_words[j] == w {
        counts[j] = counts[j] + 1
        found = true
        j = unique_words.length()
      }
      j = j + 1
    }
    if !found {
      unique_words.push(w)
      counts.push(1)
    }
  }
  let pairs : Array[(String, Int)] = []
  let mut idx = 0
  while idx < unique_words.length() {
    pairs.push((unique_words[idx], counts[idx]))
    idx = idx + 1
  }
  let sorted = sort_by_count(pairs)
  take_top_n_pairs(sorted, max_count)
}

///|
/// Find the first paragraph text from parsed Markdown blocks.
pub fn find_first_paragraph(blocks : Array[@lib.MarkdownBlock]) -> String {
  for block in blocks {
    match block {
      @lib.MarkdownBlock::Paragraph(text) => return text.trim().to_owned()
      _ => ()
    }
  }
  ""
}

///|
/// Write a Markdown list to a StringBuilder.
pub fn write_markdown_list(out : StringBuilder, items : Array[String]) -> Unit {
  for item in items {
    out.write_string("- ")
    out.write_string(item)
    out.write_string("\n")
  }
}
