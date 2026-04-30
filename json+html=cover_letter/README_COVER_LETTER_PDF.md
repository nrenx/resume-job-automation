Cover Letter Automation (JSON -> HTML -> PDF)

This project generates a one-page cover letter PDF from structured JSON data.

Quick start
1. First time only:
   npm install
2. Generate cover letter PDF:
   npm run cv

Output files
- dist/cover_letter.html
- dist/cover_letter.pdf

Project files
- cover_letter.json: Cover letter content
- cover_letter.template.html: Cover letter design/template
- build-cover-letter.mjs: Build script

Optional commands
- HTML only:
  npm run build:html
- PDF (also creates HTML):
  npm run build:pdf

Notes
- The build enforces exactly one page. Reduce content if it exceeds one page.
- The signature image is loaded from json+html=cover_letter/NARENDRA-SIGNATURE.jpg.
