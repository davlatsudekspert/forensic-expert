// Logo prototiplarini 1024 / 180 / 64 / 32 px ga rasterlab, readability va
// silhouette test varag‘ini yaratadi. Ishga tushirish:
//   NODE_PATH=$(npm root -g) node design/logo/tools/render_previews.mjs
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Playwright global o‘rnatilgan (NODE_PATH orqali topiladi).
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const protoDir = path.join(root, 'prototypes');
const outDir = path.join(root, 'previews');
fs.mkdirSync(outDir, { recursive: true });

const variants = ['A1-loop-spectrum', 'A2-ridge-core-peak', 'A3-nested-peaks'];
const sizes = [1024, 180, 64, 32];
// 64 va 32 px da optik soddalashtirilgan "small" versiyasi ishlatiladi.
const fileFor = (v, kind, size) =>
  path.join(protoDir, `${v}-${kind}${size <= 64 ? '-small' : ''}.svg`);

const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 1 });

async function rasterize(svgPath, size, out, extraCss = '') {
  const svg = fs.readFileSync(svgPath, 'utf8').replace(/width="\d+" height="\d+"/, `width="${size}" height="${size}"`);
  await page.setViewportSize({ width: size, height: size });
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body><style>${extraCss} svg{display:block}</style></html>`);
  await page.locator('svg').screenshot({ path: out, omitBackground: true });
}

for (const v of variants) {
  for (const s of sizes) {
    await rasterize(fileFor(v, 'icon', s), s, path.join(outDir, `${v}-icon-${s}.png`));
    await rasterize(fileFor(v, 'mono', s), s, path.join(outDir, `${v}-silhouette-${s}.png`));
  }
}

// Kontakt varag‘i: har variant uchun ikonkalar haqiqiy o‘lchamda (1:1),
// 32 px 8× kattalashtirilgan (pikselli), light/dark/mono va silhouette.
const img = (f, w, extra = '') => `<img src="${f}" width="${w}" height="${w}" style="${extra}">`;
const rows = variants.map((v) => `
  <section>
    <h2>${v}</h2>
    <div class="row">
      ${img(`${v}-icon-1024.png`, 256)}
      <div class="col"><span>180 px (1:1)</span>${img(`${v}-icon-180.png`, 180, 'border-radius:40px')}</div>
      <div class="col"><span>64 px (1:1)</span>${img(`${v}-icon-64.png`, 64, 'border-radius:14px')}</div>
      <div class="col"><span>32 px (1:1)</span>${img(`${v}-icon-32.png`, 32, 'border-radius:7px')}</div>
      <div class="col"><span>32 px ×8</span>${img(`${v}-icon-32.png`, 256, 'image-rendering:pixelated;border-radius:56px')}</div>
    </div>
    <div class="row">
      <div class="col"><span>light</span><img src="../prototypes/${v}-light.svg" width="120"></div>
      <div class="col dark"><span>dark</span><img src="../prototypes/${v}-dark.svg" width="120"></div>
      <div class="col"><span>mono</span><img src="../prototypes/${v}-mono.svg" width="120"></div>
      <div class="col"><span>silhouette 64</span>${img(`${v}-silhouette-64.png`, 64)}</div>
      <div class="col"><span>silhouette 32</span>${img(`${v}-silhouette-32.png`, 32)}</div>
      <div class="col"><span>silhouette 32 ×8</span>${img(`${v}-silhouette-32.png`, 256, 'image-rendering:pixelated')}</div>
    </div>
  </section>`).join('');
const html = `<!doctype html><meta charset="utf-8"><title>Ridge Spectrum prototypes</title>
<style>
 body{font:14px system-ui, sans-serif;margin:24px;background:#F4F6F9;color:#0B1220}
 h1{font-size:18px} h2{font-size:15px;margin:24px 0 8px}
 .row{display:flex;gap:24px;align-items:flex-end;flex-wrap:wrap;margin-bottom:12px}
 .col{display:flex;flex-direction:column;gap:6px;align-items:center}
 .col span{font-size:11px;color:#4A5568}
 .dark{background:#0A101C;padding:8px;border-radius:8px} .dark span{color:#A3AEC0}
 section{background:#fff;border:1px solid #D9DFE7;border-radius:12px;padding:16px;margin-bottom:16px}
</style>
<h1>FORENSIC EXPERT — «Ridge Spectrum» PROTOTYPES (not final, not locked)</h1>${rows}`;
fs.writeFileSync(path.join(outDir, 'contact-sheet.html'), html);
await page.setViewportSize({ width: 1400, height: 900 });
await page.goto('file://' + path.join(outDir, 'contact-sheet.html'));
await page.screenshot({ path: path.join(outDir, 'contact-sheet.png'), fullPage: true });
await browser.close();
console.log('previews written to', outDir);
