package ssg_engine

import "core:strings"
import "core:fmt"

// parse_inline
//
// Algorithm:
// Iterates sequentially over the provided UTF-8 string linearly byte-by-byte. 
// Uses a simple state machine (`in_bold` boolean flag) matching consecutive astronomical character sequences (`**`).
// As sequences are found, it toggles the HTML format tags (`<strong>` / `</strong>`) appended to a temporary strings builder dynamically.
// Remaining regular string characters are concatenated verbatim, generating a complete DOM node output for inline properties.
parse_inline :: proc(s: string) -> string {
    b := strings.builder_make()
    in_bold := false
    i := 0
    for i < len(s) {
        if i + 1 < len(s) && s[i] == '*' && s[i+1] == '*' {
            if in_bold {
                strings.write_string(&b, "</strong>")
            } else {
                strings.write_string(&b, "<strong>")
            }
            in_bold = !in_bold
            i += 2
        } else if s[i] == '[' {
            close_bracket := strings.index(s[i:], "]")
            if close_bracket != -1 {
                if i + close_bracket + 1 < len(s) && s[i+close_bracket+1] == '(' {
                    close_paren := strings.index(s[i+close_bracket+1:], ")")
                    if close_paren != -1 {
                        text := s[i+1 : i+close_bracket]
                        url := s[i+close_bracket+2 : i+close_bracket+1+close_paren]
                        
                        fmt.sbprintf(&b, "<a href=\"%s\">%s</a>", url, text)
                        
                        i += close_bracket + 1 + close_paren + 1
                        continue
                    }
                }
            }
            strings.write_byte(&b, s[i])
            i += 1
        } else {
            strings.write_byte(&b, s[i])
            i += 1
        }
    }
    return strings.to_string(b)
}

// parse_markdown
//
// Algorithm:
// Implements a strict two-pass execution strategy converting raw Markdown text into usable HTML code.
// Pass 1: Deduplication Phase - splits the raw file by newline parameters sweeping the lines linearly to extract the first level 1 heading (`# `), immediately returning it as the primary page `title`.
// Pass 2: Block Generation - loops over each identified line using an internal context boolean switch evaluating if the parser is actively inside a `code` or `list` boundary safely.
//  - Code Blocks (` ` ` `): Toggle `<pre><code>` encapsulation dynamically, sanitizing inner components ( `<` and `>` encoded securely).
//  - Line Headers (`# `, `## `, `### `): Generates HTML heading tokens structurally.
//  - Unordered Lists (`- `): Replaces prefixes with `<li>` wrapping, generating logical bounding `<ul>` context tags seamlessly.
// Continually executes nested `parse_inline` hooks automatically across all standard `<p>` nodes guaranteeing inline character conversion locally.
parse_markdown :: proc(md: string) -> (html: string, title: string) {
    title = "Untitled"
    lines := strings.split(md, "\n")
    // find title
    for line in lines {
        t := strings.trim_space(line)
        if strings.has_prefix(t, "# ") {
            title = strings.trim_space(t[2:])
            break
        }
    }
    
    b := strings.builder_make()
    in_list := false
    in_code := false
    
    for line in lines {
        trimmed_right := line
        if len(trimmed_right) > 0 && trimmed_right[len(trimmed_right)-1] == '\r' {
            trimmed_right = trimmed_right[:len(trimmed_right)-1]
        }
        
        trimmed := strings.trim_space(trimmed_right)
        
        if strings.has_prefix(trimmed, "```") {
            if in_code {
                strings.write_string(&b, "</code></pre>\n")
                in_code = false
            } else {
                strings.write_string(&b, "<pre><code>\n")
                in_code = true
            }
            continue
        }
        
        if in_code {
            escaped, _ := strings.replace_all(trimmed_right, "<", "&lt;")
            escaped2, _ := strings.replace_all(escaped, ">", "&gt;")
            strings.write_string(&b, escaped2)
            strings.write_string(&b, "\n")
            continue
        }
        
        if len(trimmed) == 0 {
            if in_list {
                strings.write_string(&b, "</ul>\n")
                in_list = false
            }
            continue
        }
        
        line_html := parse_inline(trimmed)
        
        if strings.has_prefix(trimmed, "# ") {
            if in_list { strings.write_string(&b, "</ul>\n"); in_list = false }
            fmt.sbprintf(&b, "<h1>%s</h1>\n", line_html[2:])
        } else if strings.has_prefix(trimmed, "## ") {
            if in_list { strings.write_string(&b, "</ul>\n"); in_list = false }
            fmt.sbprintf(&b, "<h2>%s</h2>\n", line_html[3:])
        } else if strings.has_prefix(trimmed, "### ") {
            if in_list { strings.write_string(&b, "</ul>\n"); in_list = false }
            fmt.sbprintf(&b, "<h3>%s</h3>\n", line_html[4:])
        } else if strings.has_prefix(trimmed, "- ") {
            if !in_list {
                strings.write_string(&b, "<ul>\n")
                in_list = true
            }
            fmt.sbprintf(&b, "<li>%s</li>\n", line_html[2:])
        } else {
            if in_list { strings.write_string(&b, "</ul>\n"); in_list = false }
            fmt.sbprintf(&b, "<p>%s</p>\n", line_html)
        }
    }
    
    if in_list {
        strings.write_string(&b, "</ul>\n")
    }
    if in_code {
        strings.write_string(&b, "</code></pre>\n")
    }
    
    html = strings.to_string(b)
    return html, title
}
