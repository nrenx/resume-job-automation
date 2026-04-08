Task
Update the resume for a given JD to improve ATS relevance while preserving a strict one-page layout.

Project Files
- Source data (immutable): /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/resume.json
- Layout template (immutable): /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/resume.template.html
- Build script: /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/build-resume.mjs
- Output parent folder: /Users/narendrachowdary/BNC/resume/Resume_automation/company-resumes

Primary Goal
- Maximize JD keyword relevance without breaking one-page output.

Non-Negotiable Constraints
- Generated PDF must be exactly 1 page.
- Do not change visual layout settings in resume.template.html (font size, spacing, margins, structure).
- Do not add extra blank lines.
- Do not modify Education or Certifications content.
- Do not change project names.
- Do not change work experience title, company, or period.

Allowed Edits
- Career Objective/Summary
- Development and Technical Skills
- Work Experience bullet text only
- Project bullet text only
- Project ordering based on JD relevance

Strict Section Formatting Rules
- Career Objective: maximum 3 lines.
- Development and Technical Skills:
  - Maximum 10 lines total in the section.
  - Keep category text concise to avoid wrapping.
  - Remove Soft Skills when not required by JD.
- Work Experience:
  - Maximum 6 lines total across the section.
  - Update description text only (do not change titles/company/period).
  - Per role description: maximum 2 lines.
- Projects per project:
  - Reorder projects by JD relevance.
  - Maximum 4 lines per project (do not exceed 4).
  - Keep project names unchanged.

Mandatory Skill Lines
- Keep these lines present (only light punctuation cleanup allowed):
  - Tools and Others: Git, GitHub, FFmpeg, Basic Understanding of Deployment and Hosting
  - Automation and AI Tools: n8n (Workflow Automation, API Pipelines, Scheduling), OpenAI (ChatGPT), Anthropic (Claude), Grok, DeepSeek, Ollama (Local Models), Google AI, Text-to-Speech for Automation Workflows

Fresher Guardrails
- Treat profile as entry-level.
- Keep claims realistic; avoid senior ownership language.
- Prefer practical verbs: built, implemented, assisted, integrated, automated, tested.
- If JD explicitly requires more than 1 year of experience, pause and ask user whether to continue.

Company Folder and Versioning Rules
- Keep base resume immutable by code:
  - Never overwrite resume.json.
  - Always write company-specific JSON files only.
- Use company folders under company-resumes in this format:
  - <Index>.<CompanyName> (example: 1.TCS, 2.Google)
- Add company-folder automation:
  - If folder does not exist: create folder and create <CompanyName>.json by copying base resume.json.
  - If folder exists: scan all resume JSON versions in that folder and compare each version with the incoming JD.
  - If a matching version is found: reuse that version and mark it as latest for output.
  - If no matching version is found: create next version file (<CompanyName>-v1.json, <CompanyName>-v2.json, ...).

PDF Naming Rules
- Unversioned JSON (Company.json) -> Bollineni_Narendra_resume.pdf
- Versioned JSON (Company-v2.json) -> Bollineni_Narendra_resume-v2.pdf
- Never auto-increment PDF version independently from JSON version.

JD Processing Rules
- Clean JD text first if it contains unrelated content.
- Infer company name when not explicitly provided.
- Extract priority keywords (skills, tools, responsibilities).
- Avoid keyword stuffing.

Execution Flow
1. Clean JD and identify company and role requirements.
2. Extract ATS keywords.
3. Check experience requirement (>1 year) and ask user confirmation when needed.
4. Create or reuse company folder and choose JSON version using matching logic.
5. Apply edits only in allowed sections.
6. Reorder projects by JD relevance.
7. Validate all hard constraints and strict formatting rules.
8. Build from json+html=resume folder using npm run resume.
9. For company-specific build, use selected company JSON as input, generate output, and keep base workflow intact.
10. Save final PDF in company folder with JSON-version-matched file name.

Output Requirements
- Return updated JSON content changes only.
- Keep wording concise and professional.
- If constraints conflict, prioritize one-page output and state what was minimized.
- If length exceeds one page, remove Soft Skills first, then shorten other content.
- If still exceeding one page, you may remove this footer line safely:
  - More projects available at github.com/nrenx
- After finishing one JD and confirming the output paths, always ask the user to share the next JD.
- Confirm:
  - Company folder path
  - Selected JSON version (reused or new)
  - Final PDF full path
  - Final PDF exact file name

Post-Edit Save Requirement
- After editing/adding resume content and confirming the PDF is created in the company folder, save all changes through terminal commands (for example, add/commit workflow as required by the user process).

Environment Note
- Development machine is macOS.
- Use macOS terminal commands (for example: cp, mv) for file operations.