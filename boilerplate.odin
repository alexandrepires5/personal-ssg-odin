package ssg_engine

// 3. INTERNAL HTML BOILERPLATE
// Define an internal string template to wrap generated HTML:
HTML_BOILERPLATE :: `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<style>
    :root {{
        --primary-color: #2563eb;
        --secondary-color: #1e40af;
        --bg-color: #f8fafc;
        --text-color: #334155;
        --code-bg: #e2e8f0;
    }}
    * {{ box-sizing: border-box; }}
    p {{ text-align: justify; }}
    body {{
        font-family: 'Inter', system-ui, -apple-system, sans-serif;
        line-height: 1.6;
        color: var(--text-color);
        background-color: var(--bg-color);
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem;
    }}
    h1, h2, h3, h4 {{
        color: var(--primary-color);
        margin-top: 2rem;
        margin-bottom: 1rem;
        font-weight: 700;
    }}
    a {{
        color: var(--primary-color);
        text-decoration: none;
        transition: color 0.2s ease;
    }}
    a:hover {{
        color: var(--secondary-color);
        text-decoration: underline;
    }}
    pre {{
        background-color: var(--code-bg);
        padding: 1rem;
        border-radius: 8px;
        overflow-x: auto;
        border-left: 4px solid var(--primary-color);
    }}
    code {{
        font-family: 'Fira Code', 'Consolas', monospace;
        font-size: 0.9em;
    }}
    strong {{
        color: var(--secondary-color);
    }}
    .top-nav {{
        display: flex;
        gap: 1.5rem;
        padding-bottom: 1rem;
        margin-bottom: 2rem;
        border-bottom: 2px solid #cbd5e1;
    }}
    .top-nav a {{
        font-weight: 600;
        font-size: 1.1rem;
    }}
</style>
</head>
<body>
    <nav class="top-nav">
        <a href="%s/index.html">Home</a>
        <a href="%s/cv/index.html">CV</a>
        <a href="%s/blog/index.html">Blog</a>
    </nav>
    <main>
        %s
    </main>
    <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
        mermaid.initialize({{ startOnLoad: true }});
    </script>
</body>
</html>`
