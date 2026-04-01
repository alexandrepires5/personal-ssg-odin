/*
    SSG ARCHITECTURE OVERVIEW (Odin-flavored Pseudo-code)
    -----------------------------------------------------
    Goal: Transpile Markdown + Data + SGML Templates into a Static HTML Site.
    Input:  ./content/*.md, ./templates/*.sgml, ./assets/*
    Output: ./public/
*/

package ssg_engine

import "core:os"
import "core:strings"
import "core:fmt"
// ... other core modules

// 1. DATA STRUCTURES
// Define structs to hold page state during the build pipeline
Page_Context :: struct {
    metadata:      map[string]string, // Title, Date, Template, etc.
    html_body:     strings.Builder,   // The processed prose
    raw_references: strings.Builder,   // Buffer for embedded JSON data
    has_graph:     bool,              // Flag to trigger Mermaid.js scripts
}

main :: proc() {
    // 2. INITIALIZATION
    // - Define paths: content_dir, template_dir, public_dir
    // - Clean public_dir (os.remove_all then os.make_directory)
    // - Initialize a Global_Site_Context to track all posts (for index pages)

    // 3. CONTENT DISCOVERY (The "Walk")
    // Use core:os.walk or a recursive procedure to find every file in content_dir
    // For each entry found:
    //    if entry is_directory: 
    //        mirror_directory_in_public()
    //    else if entry.ext == ".md":
    //        add_to_process_list(entry)
    //    else:
    //        copy_static_asset_to_public(entry)

    // 4. TRANSFORMATION PIPELINE
    // Loop through the process list (ideally using an Arena Allocator per page)
    /*
        for page_path in process_list {
            // A. LOAD & SPLIT
            // - Read entire file into memory buffer
            // - Find the "---" delimiters for Front Matter
            // - Extract Metadata string vs. Markdown Body string

            // B. PARSE METADATA
            // - Split Metadata string by lines, then by ':'
            // - Populate Page_Context.metadata (e.g., "template" -> "post.sgml")

            // C. THE BLOCK-AWARE MARKDOWN PARSER (State Machine)
            // Initialize State = PROSE
            // For each line in Markdown Body:
            
                // State Transition Logic:
                if line starts with "```mermaid":
                    State = GRAPH
                    context.has_graph = true
                    append(context.html_body, "<div class='mermaid'>")
                    continue
                
                else if line starts with "```json":
                    State = DATA
                    continue
                
                else if line starts with "```" (Closing block):
                    if State == GRAPH: append(context.html_body, "</div>")
                    State = PROSE
                    continue

                // Content Processing Logic:
                switch State {
                case PROSE:
                    // 1. Handle Inline: Replace **text** with <b>, etc.
                    // 2. Handle Block: If line starts with '#', wrap in <hX>
                    // 3. Append resulting HTML string to context.html_body
                
                case GRAPH:
                    // Append raw text to html_body (Mermaid needs raw text inside the div)
                    append(context.html_body, line)
                
                case DATA:
                    // Append raw text to context.raw_references buffer for later parsing
                    append(context.raw_references, line)
                }

            // D. REFERENCE RESOLUTION
            // - If context.raw_references is not empty:
            //   - Parse JSON buffer into an Odin struct/map
            //   - Generate an HTML snippet (e.g., <ul><li>...) representing the references
            //   - Store this snippet in a variable "formatted_refs"

            // E. SGML TEMPLATE INJECTION
            // - Load the template file (e.g., templates/cv.sgml)
            // - Perform SGML Entity Substitution:
            //   - replace "&title;"    with context.metadata["title"]
            //   - replace "&content;"  with context.html_body
            //   - replace "&refs;"     with formatted_refs
            // - If context.has_graph:
            //   - Append <script> tags for Mermaid.js before the </body> tag

            // F. OUTPUT GENERATION
            // - Construct output path: "public/my-post/index.html"
            // - Write the final resolved string to disk
        }
    */

    // 5. POST-BUILD
    // - Generate index.html if needed (listing all posts found in Global_Site_Context)
    // - Log "Build Complete" and total time taken
}