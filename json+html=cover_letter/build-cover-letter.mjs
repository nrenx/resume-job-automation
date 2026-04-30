import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { PDFDocument } from "pdf-lib";

const rootDir = process.cwd();
const inputJsonPath = path.join(rootDir, "cover_letter.json");
const templatePath = path.join(rootDir, "cover_letter.template.html");
const distDir = path.join(rootDir, "dist");
const outputHtmlPath = path.join(distDir, "cover_letter.html");
const outputPdfPath = path.join(distDir, "cover_letter.pdf");

const args = new Set(process.argv.slice(2));
const buildHtmlOnly = args.has("--html");
const buildPdf = args.has("--pdf") || (!args.has("--html") && !args.has("--pdf"));

function ensureFileExists(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Missing required file: ${filePath}`);
  }
}

function normalizeCoverLetterData(data) {
  const normalized = { ...data };

  if (Array.isArray(normalized.paragraphs)) {
    normalized.paragraphs = normalized.paragraphs
      .map((paragraph) => String(paragraph).trim())
      .filter(Boolean);
  }

  if (normalized.signature?.imagePath) {
    const signaturePath = path.isAbsolute(normalized.signature.imagePath)
      ? normalized.signature.imagePath
      : path.join(rootDir, normalized.signature.imagePath);

    if (!fs.existsSync(signaturePath)) {
      throw new Error(`Missing signature image: ${signaturePath}`);
    }

    normalized.signature = {
      ...normalized.signature,
      imageUrl: pathToFileURL(signaturePath).href,
    };
  }

  return normalized;
}

function buildHtml() {
  ensureFileExists(inputJsonPath);
  ensureFileExists(templatePath);

  const rawJson = fs.readFileSync(inputJsonPath, "utf8");
  const data = normalizeCoverLetterData(JSON.parse(rawJson));

  if (!Array.isArray(data.paragraphs) || data.paragraphs.length === 0) {
    throw new Error("Cover letter must include at least one paragraph.");
  }

  const template = fs.readFileSync(templatePath, "utf8");

  if (!template.includes("__COVER_LETTER_DATA__")) {
    throw new Error("Template must contain __COVER_LETTER_DATA__ placeholder.");
  }

  const renderedHtml = template.replace("__COVER_LETTER_DATA__", JSON.stringify(data));
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

(async () => {
  if (buildHtmlOnly && !buildPdf) {
    buildHtml();
    console.log("Executed success");
    return;
  }

  const htmlPath = buildHtml();
  await buildPdfFromHtml(htmlPath);
  await enforceSinglePagePdf(outputPdfPath);
  console.log("Executed success");
})();
