import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { PDFDocument } from "pdf-lib";

const rootDir = process.cwd();
const inputJsonPath = path.join(rootDir, "resume.json");
const templatePath = path.join(rootDir, "resume.template.html");
const distDir = path.join(rootDir, "dist");
const outputHtmlPath = path.join(distDir, "resume.html");
const outputPdfPath = path.join(distDir, "resume.pdf");

const args = new Set(process.argv.slice(2));
const buildHtmlOnly = args.has("--html");
const buildPdf = args.has("--pdf") || (!args.has("--html") && !args.has("--pdf"));

const RESUME_LIMITS = {
  objectiveMaxLines: 3,
  educationMaxItems: 3,
  skillsMaxItems: 10,
  experienceMaxItems: 2,
  experienceTotalDetailLinesMax: 6,
  experienceDetailsMaxPerItem: 2,
  certificationsMaxItems: 4,
  projectsMaxItems: 4,
  projectTotalLinesMaxPerItem: 4,
  projectDetailsMaxPerItem: 2,
};

function countLines(text) {
  if (typeof text !== "string") {
    return 0;
  }

  const normalized = text.replace(/\r\n/g, "\n").trim();
  if (!normalized) {
    return 0;
  }

  return normalized.split("\n").length;
}

function validateResumeData(data) {
  const errors = [];
  const pushIfExceeded = (label, actual, max) => {
    if (actual > max) {
      errors.push(`${label}: ${actual} (max ${max})`);
    }
  };

  if (typeof data.objective === "string") {
    pushIfExceeded("objective lines", countLines(data.objective), RESUME_LIMITS.objectiveMaxLines);
  }

  if (Array.isArray(data.education)) {
    pushIfExceeded("education items", data.education.length, RESUME_LIMITS.educationMaxItems);
  }

  if (Array.isArray(data.skills)) {
    pushIfExceeded("skills categories", data.skills.length, RESUME_LIMITS.skillsMaxItems);
  }

  if (Array.isArray(data.experience)) {
    pushIfExceeded("experience items", data.experience.length, RESUME_LIMITS.experienceMaxItems);
    const totalDetails = data.experience.reduce(
      (sum, item) => sum + (Array.isArray(item?.details) ? item.details.length : 0),
      0,
    );
    pushIfExceeded(
      "work experience total detail lines",
      totalDetails,
      RESUME_LIMITS.experienceTotalDetailLinesMax,
    );

    data.experience.forEach((item, index) => {
      const detailsCount = Array.isArray(item?.details) ? item.details.length : 0;
      pushIfExceeded(
        `experience[${index + 1}] detail lines`,
        detailsCount,
        RESUME_LIMITS.experienceDetailsMaxPerItem,
      );
    });
  }

  if (Array.isArray(data.certifications)) {
    pushIfExceeded("certification items", data.certifications.length, RESUME_LIMITS.certificationsMaxItems);
  }

  if (Array.isArray(data.projects)) {
    pushIfExceeded("project items", data.projects.length, RESUME_LIMITS.projectsMaxItems);
    data.projects.forEach((item, index) => {
      const detailsCount = Array.isArray(item?.details) ? item.details.length : 0;
      const projectTotalLines = detailsCount + 2;

      pushIfExceeded(
        `project[${index + 1}] total lines (description + technologies + tools)`,
        projectTotalLines,
        RESUME_LIMITS.projectTotalLinesMaxPerItem,
      );
      pushIfExceeded(
        `project[${index + 1}] detail lines`,
        detailsCount,
        RESUME_LIMITS.projectDetailsMaxPerItem,
      );
    });
  }

  if (errors.length > 0) {
    throw new Error(
      [
        "Resume exceeds hard limits. Reduce content in resume.json:",
        ...errors.map((line) => `- ${line}`),
      ].join("\n"),
    );
  }
}

function ensureFileExists(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Missing required file: ${filePath}`);
  }
}

function buildHtml(options = {}) {
  ensureFileExists(inputJsonPath);
  ensureFileExists(templatePath);
  const { hideMoreProjects = false } = options;

  const rawJson = fs.readFileSync(inputJsonPath, "utf8");
  const data = JSON.parse(rawJson);
  if (hideMoreProjects) {
    delete data.moreProjects;
  }
  validateResumeData(data);
  const template = fs.readFileSync(templatePath, "utf8");

  if (!template.includes("__RESUME_DATA__")) {
    throw new Error("Template must contain __RESUME_DATA__ placeholder.");
  }

  const renderedHtml = template.replace("__RESUME_DATA__", JSON.stringify(data));
  fs.mkdirSync(distDir, { recursive: true });
  fs.writeFileSync(outputHtmlPath, renderedHtml, "utf8");

  return outputHtmlPath;
}

async function buildPdfFromHtml(htmlPath) {
  const { default: puppeteer } = await import("puppeteer");

  const browser = await puppeteer.launch({ headless: true });
  try {
    const page = await browser.newPage();
    await page.goto(pathToFileURL(htmlPath).href, { waitUntil: "networkidle0" });
    await page.waitForFunction(() => document.body?.dataset?.rendered === "true", {
      timeout: 10000,
    });

    await page.pdf({
      path: outputPdfPath,
      format: "A4",
      printBackground: true,
      preferCSSPageSize: true,
    });
  } finally {
    await browser.close();
  }
}

async function getPdfPageCount(pdfPath) {
  const pdfBytes = fs.readFileSync(pdfPath);
  const pdfDoc = await PDFDocument.load(pdfBytes);
  return pdfDoc.getPageCount();
}

async function enforceSinglePagePdf(pdfPath) {
  const pageCount = await getPdfPageCount(pdfPath);
  if (pageCount !== 1) {
    throw new Error(
      `PDF page count validation failed: generated ${pageCount} pages (required exactly 1).`,
    );
  }
}

async function buildWithSinglePageFallback() {
  let htmlPath = buildHtml();
  await buildPdfFromHtml(htmlPath);

  const initialPageCount = await getPdfPageCount(outputPdfPath);
  if (initialPageCount === 1) {
    return;
  }

  const rawJson = fs.readFileSync(inputJsonPath, "utf8");
  const data = JSON.parse(rawJson);
  const hasMoreProjectsLine =
    data?.moreProjects &&
    typeof data.moreProjects.label === "string" &&
    data.moreProjects.label.trim().length > 0;

  if (!hasMoreProjectsLine) {
    throw new Error(
      `PDF page count validation failed: generated ${initialPageCount} pages (required exactly 1).`,
    );
  }

  htmlPath = buildHtml({ hideMoreProjects: true });
  await buildPdfFromHtml(htmlPath);
  await enforceSinglePagePdf(outputPdfPath);
}

(async () => {
  if (buildHtmlOnly && !buildPdf) {
    buildHtml();
    console.log("Executed success");
    return;
  }

  await buildWithSinglePageFallback();
  console.log("Executed success");
})().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
