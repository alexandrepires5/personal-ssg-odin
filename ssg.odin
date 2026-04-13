package ssg_engine 

import "core:os" 
import "core:strings" 
import "core:fmt"
import "core:slice"
import "core:time"

Page :: struct {
    title:    string,
    src_path: string,
    url_path: string,
}

SiteData :: struct {
    home_page: Page,
    cv_page:   Page,
    blog_list: [dynamic]Page,
}



    //SSG ARCHITECTURE OVERVIEW
    //--------------------------------------
    //Goal: Transpile Markdown into a Static HTML Site.
    //Input:  ./content/home/*.md, ./content/cv/*.md, ./content/blog/*.md
    //Output: ./docs/



// dir_exists
// 
// Algorithm:
// Straightforward wrapper executing boolean operations matching Native local states against absolute or relative directories paths natively.
// Evaluates specifically if an immediate file descriptor actively exists AND if that pointer actively mirrors a distinct directory layout, preventing standard OS files from resolving to true mistakenly.
dir_exists :: proc(path: string) -> bool {
    return os.exists(path) && os.is_dir(path)
}

// remove_entire_directory
//
// Algorithm:
// Assesses structural stability of specific absolute output parameters by verifying if an initial directory entity is instantiated.
// If valid, successfully buffers existing sub-inodes querying directory elements.
// To efficiently prevent cache conflicts, dynamically flushes all file components recursively through `os.remove_all` entirely if child variables strictly exist, directly rebuilding an empty clean directory template identically using natively linked `os.make_directory`.
remove_entire_directory :: proc(dir: string) {
    if !dir_exists(dir) {
        fmt.eprintln("Error opening directory: It does not exist")
        return
    }
    f, err := os.open(dir)
    if err != nil {
        fmt.eprintln("Error opening directory:", err)
        return
    }
    defer os.close(f)

    infos, read_err := os.read_dir(f, 1, context.allocator)
    if read_err != nil {
        fmt.eprintln("Error reading directory:", read_err)
        return
    }
    if len(infos) > 0 {
        fmt.println("Directory is not empty")
        os.remove_all(dir)
        os.make_directory(dir)
    }   
}

// main
//
// Algorithm:
// Orchestrates the exact Static Site Generation (SSG) macro architecture from initialization to final benchmarking:
// 1. Cleans and scaffolds out explicit runtime target output directories (`./docs`).
// 2. Transpiles unique static pages (`home`, `cv`) recursively validating and formatting explicit markdown components via predefined unified HTML formatting interfaces. 
// 3. Implements automatic relativity processing mapping HTML local `file://` routing efficiently.
// 4. Handles sub-category looping across `blog/` directories iterating generic components dynamically to construct sub-pages inside specific isolated subdirectories cleanly.
// 5. Outputs a synthesized blog list reference index encapsulating structural routing dynamically to user output parameters.
// Evaluates cycle benchmark dynamically capturing internal loop timings internally. 
main :: proc() {
    // 2. INITIALIZATION
    // - Define paths: content_dir, public_dir
    content_dir := "./content"
    docs_dir := "./docs"
    fmt.println("Content directory: ", content_dir)
    fmt.println("Docs directory: ", docs_dir)
    // - Clean docs_dir (os.remove_all then os.make_directory)
    remove_entire_directory(docs_dir)
    
    // - Ensure output subdirectories exist (docs/cv, docs/blog)
    if !dir_exists("./docs/cv") {
        os.make_directory("./docs/cv")
    }
    if !dir_exists("./docs/blog") {
        os.make_directory("./docs/blog")
    }
    // - Initialize BlogList to track all blog posts (for index page)
    site: SiteData
    site.blog_list = make([dynamic]Page)
    defer delete(site.blog_list)


    start_tick := time.tick_now()
    
    // 4. PROCESS HOME PAGE
    // - Find `.md` file in "./content/home/"
    // - Parse Markdown to HTML
    // - Deduce Title from the first '# Heading' in the markdown
    // - Wrap in Boilerplate and write to "./docs/index.html"
    home_dir, home_err := os.open("./content/home")
    if home_err == nil {
        defer os.close(home_dir)
        fi, _ := os.read_dir(home_dir, -1, context.allocator)
        for info in fi {
            if strings.has_suffix(info.name, ".md") {
                file_path := fmt.aprintf("./content/home/%s", info.name)
                if os.is_dir(file_path) { continue }
                home_md, ok := os.read_entire_file(file_path, context.allocator)
                if ok == nil {
                    html, title := parse_markdown(string(home_md))
                    site.home_page.title = title
                    site.home_page.src_path = file_path
                    site.home_page.url_path = "index.html"
                    
                    root_dir := "."
                    out_html := fmt.aprintf(HTML_BOILERPLATE, title, root_dir, root_dir, root_dir, html)
                    _ = os.write_entire_file("./docs/index.html", transmute([]byte)out_html)
                    break
                }
            }
        }
    }

    // 5. PROCESS CV PAGE
    // - Find `.md` file in "./content/cv/"
    // - Parse Markdown to HTML
    // - Deduce Title from the first '# Heading'
    // - Wrap in Boilerplate and write to "./docs/cv/index.html"
    cv_dir, cv_err := os.open("./content/cv")
    if cv_err == nil {
        defer os.close(cv_dir)
        fi, _ := os.read_dir(cv_dir, -1, context.allocator)
        for info in fi {
            if strings.has_suffix(info.name, ".md") {
                file_path := fmt.aprintf("./content/cv/%s", info.name)
                if os.is_dir(file_path) { continue }
                cv_md, ok := os.read_entire_file(file_path, context.allocator)
                if ok == nil {
                    html, title := parse_markdown(string(cv_md))
                    site.cv_page.title = title
                    site.cv_page.src_path = file_path
                    site.cv_page.url_path = "cv/index.html"
                    
                    root_dir := ".."
                    out_html := fmt.aprintf(HTML_BOILERPLATE, title, root_dir, root_dir, root_dir, html)
                    _ = os.write_entire_file("./docs/cv/index.html", transmute([]byte)out_html)
                    break
                }
            }
        }
    }

    // 6. PROCESS BLOG POSTS
    // - Loop through files in "./content/blog/"
    // - For each *.md file:
    //     - Read file, parse Markdown to HTML
    //     - Deduce Title from the first '# Heading'
    //     - Track Title and relative URL path in BlogList
    //     - Wrap in Boilerplate and write to "./docs/blog/<filename_without_ext>/index.html"
    blog_dir, blog_err := os.open("./content/blog")
    if blog_err == nil {
        defer os.close(blog_dir)
        fi, _ := os.read_dir(blog_dir, -1, context.allocator)
        for info in fi {
            if strings.has_suffix(info.name, ".md") {
                file_path := fmt.aprintf("./content/blog/%s", info.name)
                if os.is_dir(file_path) { continue }
                content, ok := os.read_entire_file(file_path, context.allocator)
                if ok == nil {
                    html, title := parse_markdown(string(content))
                    
                    base_name := info.name[:len(info.name)-3]
                    out_dir := fmt.aprintf("./docs/blog/%s", base_name)
                    if !dir_exists(out_dir) {
                        os.make_directory(out_dir)
                    }
                    
                    p := Page{
                        title = title,
                        src_path = file_path,
                        url_path = fmt.aprintf("%s/index.html", base_name), // relative to /blog/index.html
                    }
                    append(&site.blog_list, p)
                    
                    root_dir := "../.."
                    out_html := fmt.aprintf(HTML_BOILERPLATE, title, root_dir, root_dir, root_dir, html)
                    out_path := fmt.aprintf("%s/index.html", out_dir)
                    _ = os.write_entire_file(out_path, transmute([]byte)out_html)
                }
            }
        }
    }

    // 7. POST-BUILD (Blog Index)
    // - Generate "docs/blog/index.html" listing all posts in BlogList
    // - Log "Build Complete" and total time taken
    b_idx := strings.builder_make()
    strings.write_string(&b_idx, "<h1>Blog Posts</h1>\n<ul>\n")
    for post in site.blog_list {
        fmt.sbprintf(&b_idx, "<li><a href=\"%s\">%s</a></li>\n", post.url_path, post.title)
    }
    strings.write_string(&b_idx, "</ul>\n")
    
    idx_html := strings.to_string(b_idx)
    root_dir := ".."
    out_idx_html := fmt.aprintf(HTML_BOILERPLATE, "Blog", root_dir, root_dir, root_dir, idx_html)
    _ = os.write_entire_file("./docs/blog/index.html", transmute([]byte)out_idx_html)
    
    duration := time.tick_since(start_tick)
    fmt.println("Build Complete in", duration)
}