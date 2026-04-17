# Parser Architecture

The custom Odin static site generator features a lightweight, two-pass block-aware parser that transforms raw markdown strictly into boilerplate-wrapped HTML using linear string iteration.

## Features & State Machine

The parser relies on multiple internal state boolean flags (e.g. `in_code`, `in_list`, `in_mermaid`) parsing line-by-line:

- **Headings & Paragraphs**: Dynamically mapped to basic DOM tags.
- **Lists**: `in_list` flag encapsulates unordered items (`- `) with `<ul>` bounds.
- **Inline Properties**: `parse_inline` detects inner nodes sequentially mapping strings linearly replacing links and bold asterisks `**`.
- **Code Blocks**: Handled by flipping an `in_code` flag. Inside these borders, generic syntax receives standard `<` and `>` semantic escaping.

## Mermaid Support 

Special logic handles `` ```mermaid `` initialization to generate active chart rendering dynamically through the `@mermaid-js` esm modules rather than flat code blocks. 
- During `in_mermaid` state detection, `<pre class="mermaid">` HTML bindings encapsulate output. 
- HTML semantic escaping is **actively suppressed** specifically within Mermaid blocks so client-side JavaScript receives raw layout syntax flawlessly.
