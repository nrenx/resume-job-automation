Task
Update my JSON/HTML resume for a given job description (JD) to improve ATS match while keeping the same one-page layout.

Project Files
- Source data (immutable): /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/resume.json
- Layout template (immutable): /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/resume.template.html
- Build script: /Users/narendrachowdary/BNC/resume/Resume_automation/json+html=resume/build-resume.mjs
- Output parent folder: /Users/narendrachowdary/BNC/resume/Resume_automation/company-resumes

Primary Goal
- Maximize keyword relevance to the JD without breaking one-page output.

Hard Constraints
- Keep generated PDF to exactly one page.
- Do not change visual layout settings in resume.template.html (font size, spacing, margins, overall format).
- Do not add extra blank lines.
- Do not change these resume sections:
	- Education
	- Certifications
- Do not change project names.
- Do not change work experience title, company, or period.

Allowed Edits
- Career Objective/Summary
- Development & Technical Skills
- Work Experience bullet text only
- Project bullet text only
- Project order by JD relevance

Section Formatting Rules (Strict)
- Career Objective: exactly 3 lines.
- Development & Technical Skills:
	- maximum 7 categories (head points)
	- each category text should be 1 line, maximum 2 lines
	- remove Soft Skills category if not required by JD
- Work Experience per role:
	- either 1 bullet with max 2 lines
	- or 2 bullets where each bullet is a single line
- Projects per project: exactly 3 bullets/lines:
	1) project impact/feature
	2) Technologies
	3) Tools/Platforms

Mandatory Skill Lines
- Keep these lines present (only light punctuation cleanup allowed):
	- Tools & Others: Git, GitHub, FFmpeg, Basic Understanding of Deployment and Hosting
	- Automation & AI Tools: n8n (Workflow Automation, API Pipelines, Scheduling), OpenAI (ChatGPT), Anthropic (Claude), Grok, DeepSeek, Ollama (Local Models), Google AI, Text-to-Speech for Automation Workflows

Fresher Guardrails
- Treat profile as entry-level/fresher.
- Keep claims realistic; avoid senior-level ownership language.
- Use practical verbs: built, implemented, assisted, integrated, automated, tested.
- If JD explicitly asks for more than 1 year of experience, pause and ask user whether to continue.

Company Folder and Versioning Rules
- Never edit base resume.json directly.
- For each company, work inside a numbered folder under company-resumes:
	- <Index>.<CompanyName> (examples: 1.TCS, 2.Google)
- First version for a company:
	- copy resume.json to <Index>.<CompanyName>/<CompanyName>.json
- Repeat JD handling:
	- if meaning matches existing company version, reuse it
	- if different, create next version in same folder:
		- <CompanyName>-v1.json, <CompanyName>-v2.json, ...

PDF Naming Rules
- Unversioned JSON (Company.json) -> Bollineni_Narendra_resume.pdf
- Versioned JSON (Company-v2.json) -> Bollineni_Narendra_resume-v2.pdf
- Never auto-increment PDF versions independently from JSON version.

JD Processing Rules
- Clean JD text first if it contains unrelated content.
- Infer company name if not explicitly provided.
- Extract priority keywords (skills, tools, responsibilities).
- Avoid keyword stuffing.

Execution Flow
1. Clean JD and identify company + role requirements.
2. Extract ATS keywords.
3. Check experience requirement (>1 year) and ask user confirmation if needed.
4. Create/reuse proper company folder and JSON version in company-resumes.
5. Apply edits only in allowed sections.
6. Reorder projects by relevance.
7. Validate all hard constraints and strict section rules.
8. Build from json+html=resume folder:
	 npm run resume
9. If building a company-specific JSON version, swap selected JSON into build input, generate, then restore base workflow.
10. Copy/save final PDF in company folder with JSON-version-matched PDF name.

Output Requirements
- Return updated JSON content changes only.
- Keep wording concise and professional.
- If constraints conflict, prioritize one-page layout and state what was minimized.
- If length exceeds one page, remove Soft Skills first, then shorten other content.
- Confirm:
	- company folder path
	- selected JSON version (reused/new)
	- final PDF full path
	- final PDF exact file name