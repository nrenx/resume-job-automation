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
