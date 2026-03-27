Task: Update my LaTeX resume to match a given job description for ATS optimization.

Codebase Architecture (Required Files):
- `Bollineni_Narendra_original.tex` (path: `/Users/narendrachowdary/BNC/resume/Resume_automation/Bollineni_Narendra_original.tex`) is the immutable source resume file.
- `push_and_download_pdf.sh` (path: `/Users/narendrachowdary/BNC/resume/Resume_automation/.github/push_and_download_pdf.sh`) is the automation script used to push and download the latest PDF into the target company folder.

Primary Goal:
- Improve keyword alignment and relevance for the target role while preserving the existing one-page layout.

Non-Negotiable Constraints:
- Keep the resume to exactly one page in Overleaf.
- Do not change font size, margins, spacing settings, or overall visual format.
- Do not add extra blank lines or increase section spacing.
- Do not modify these sections:
	- Education
	- Certifications
	- Work Experience
- Do not change project titles (names).

Allowed Changes:
- Career Objective (or Summary)
- Development & Technical Skills
- Project descriptions/bullets (content only, not project names)
- Project order (reorder by role relevance)

File Handling Rule:
- Before making any modifications, use Bollineni_Narendra_original.tex as the source file.
- For every new JD, create a numbered company folder in sequence using this format: <Index>.<CompanyName> (examples: 1.TCS, 2.Google, 3.Infosys).
- Inside that folder, copy Bollineni_Narendra_original.tex and rename it to <CompanyName>.tex.
- Perform all JD-based edits only in that company-specific .tex file.
- Never overwrite or edit Bollineni_Narendra_original.tex directly.
- If the same company JD is shared again, first check whether that company's folder already exists.
- If the folder exists, compare the new JD against existing company-specific .tex/.pdf version context.
- If JD meaning matches an existing version, reuse that version instead of creating a duplicate.
- If JD does not match existing versions, create a new version in the same folder using numbered naming: 1.<CompanyName>.tex, 2.<CompanyName>.tex, 3.<CompanyName>.tex.
- Ensure version numbering always increases so the latest file for that company is obvious.
- Save generated PDF files using this naming rule inside the company folder: Bollineni_Narendra_resume.pdf.
- If Bollineni_Narendra_resume.pdf already exists in that company folder, save new files as Bollineni_Narendra_resume-v1.pdf, Bollineni_Narendra_resume-v2.pdf, and so on.

ATS Optimization Rules:
- Tailor content to the exact job description keywords (skills, tools, responsibilities).
- Use concise, impact-oriented bullet points with role-relevant terms.
- Avoid keyword stuffing; keep language natural and specific.
- Keep bullets short to preserve one-page fit.

Fresher Profile Rules:
- Treat this resume as a fresher/entry-level profile.
- Keep wording realistic for a fresher; do not use senior/lead/architect-style claims.
- Do not add complex achievements, large-scale ownership claims, or advanced metrics unless clearly supported by existing resume content or verifiable project/work details.
- Prefer practical contribution language such as built, implemented, assisted, integrated, automated, and tested.
- Keep project impact statements grounded, simple, and credible.
- If the JD explicitly asks for more than 1 year of experience, pause and ask the user whether to continue or stop, since the target is entry-level jobs.

Skills Section Rules:
- Trim skills to core role-matching items.
- Group skills by proficiency (for example: Advanced, Intermediate, Basic) if space allows without changing layout.
- Keep the following lines present (can be lightly punctuation-normalized, but meaning must remain unchanged):
	- Tools & Others: Git, GitHub, FFmpeg, Basic Understanding of Deployment and Hosting
	- Soft Skills: Problem solving, time management, team collaboration, fast learner, adaptability, communication.
	- Automation & AI Tools: n8n (Workflow Automation, API Pipelines, Scheduling), OpenAI (ChatGPT), Anthropic (Claude), Grok, DeepSeek, Ollama (Local Models), Google AI, Text-to-Speech for Automation Workflows

Research Guidance:
- If company context is needed, use web search to collect only relevant public details (tech stack, role expectations, product domain).
- Use researched context only to improve keyword relevance; do not invent unverifiable claims.
- User may provide the full JD text with extra/unrelated content; first clean and extract only relevant JD requirements before optimization.
- User input may not clearly label company name; infer company name from the JD text/context before folder creation.

Execution Process:
1. Clean user-provided JD text if it contains extra/unrelated data and extract the actual role requirements.
2. Identify CompanyName from the cleaned JD text/context.
3. Analyze the JD and extract high-priority ATS keywords.
4. If the JD explicitly asks for more than 1 year of experience, ask user confirmation to proceed; stop if user asks to stop.
5. Create the next numbered folder: <Index>.<CompanyName>.
6. If the company folder already exists, check whether the JD matches an existing company version.
7. If matched, reuse the latest matching .tex file; if not matched, create a new incremented version by copying Bollineni_Narendra_original.tex (example: 2.Google.tex, 3.Google.tex).
8. Map keywords to existing resume content.
9. Rewrite only allowed sections to increase keyword match and clarity.
10. Reorder projects by job relevance.
11. Verify all non-negotiable constraints are still satisfied.
12. Run push_and_download_pdf.sh with the company folder as input (example: bash push_and_download_pdf.sh 1.Google) to push latest changes and download the latest resume PDF directly into that folder.
13. Save the resulting company PDF as Bollineni_Narendra_resume.pdf, or as Bollineni_Narendra_resume-v<NextNumber>.pdf if the base PDF already exists.

Output Requirements:
- Return the updated .tex content changes only.
- Keep wording concise and professional.
- Do not include internal reasoning steps.
- If any requested optimization conflicts with one-page constraints, prioritize one-page layout and state what was minimized.
- Confirm the created company folder path and final PDF path after each run.
- Ensure the final PDF is saved inside the same numbered company folder used for that JD.
- For repeated company JDs, report whether an existing version was reused or a new version number was created.
- Confirm the exact saved PDF name (Bollineni_Narendra_resume.pdf or versioned -vN form) in the final output.