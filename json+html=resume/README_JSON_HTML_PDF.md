Resume Automation (JSON -> HTML -> PDF)

This project helps you generate your resume PDF from structured JSON data.

Quick start (simple)
1. First time only:
   npm install
2. Generate resume (one command):
   npm run resume

Output files
- dist/resume.html
- dist/resume.pdf

How to update your resume
1. Edit content in resume.json
2. Run:
   npm run resume

That is it. The command generates both HTML and PDF.

Hard limits (to keep resume one-page and controlled)
- The build now validates resume.json and throws an error if content exceeds limits.
- Example checks include objective length, number of projects, certifications, and detail lines.
- If you get a limit error, reduce content in resume.json.
- To change these limits, edit RESUME_LIMITS in build-resume.mjs.

Project files
- resume.json: Your resume content
- resume.template.html: Resume design/template
- build-resume.mjs: Build script

Optional commands
- HTML only:
  npm run build:html
- PDF (also creates HTML):
  npm run build:pdf

Why this setup is useful
- Easy content updates in one JSON file
- ATS-friendly HTML/PDF output
- Consistent PDF export using Puppeteer

Working procedure (what happens when you run npm run resume)
1. npm run resume executes node build-resume.mjs --pdf.
2. The script reads resume.json and checks hard limits in RESUME_LIMITS.
3. If any limit is exceeded, build stops with a clear error message.
4. If valid, resume.template.html is loaded and __RESUME_DATA__ is replaced with JSON content.
5. Generated HTML is written to dist/resume.html.
6. Puppeteer opens the HTML in a headless browser and waits until rendering is complete.
7. The page is exported as dist/resume.pdf using A4 print settings.
8. The script checks PDF page count using pdf-lib.
9. If page count is not exactly 1, build fails.
10. If all checks pass, final HTML and PDF are ready in dist.
