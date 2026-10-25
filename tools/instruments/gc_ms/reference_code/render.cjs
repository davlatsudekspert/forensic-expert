// SVG chizmalarni PNG ga aylantiradi (Playwright Chromium).
//   NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs [nom ...]
//   NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --cells [nom ...]
// --sperm: spermogramma kartasi (tool/illustrations/sperm/*.svg) → assets/spermogram/<nom>.png.
// --bloodgroup: qon guruhi kartasi (tool/illustrations/bloodgroup/*.svg) → assets/bloodgroup/<nom>.png.
// --histology: gistologiya kartasi (tool/illustrations/histology/*.svg) → assets/histology/<nom>.png.
// --urinalysis: siydik tahlili kartasi (tool/illustrations/urinalysis/*.svg) → assets/urinalysis/<nom>.png.
// --bloodmorph: qon morfologiyasi kartasi va sxemasi (tool/illustrations/bloodmorph/*.svg) → assets/bloodmorph/<nom>.png.
// --cyto: sitologiya sxemalari (tool/illustrations/cyto/*.svg) → assets/cytology/<nom>.png.
// --schematic: apparat turi chizmalari (tool/illustrations/schematic/*.svg, gen.py bilan
// yaratiladi) → assets/instruments/schematic/<nom>_1200.png va <nom>_480.png (shaffof fon).
// --schematic --quant: PNG lar pngquant bilan siqiladi (o'rnatilgan bo'lsa; sifat 85-98).
// --cells: leykoformula hujayra sxemalari (tool/illustrations/cells/*.svg,
// o'lcham SVG dan) → assets/differential/<nom>.png.
const { chromium } = require('playwright');
const { readFileSync, readdirSync } = require('node:fs');
const { spawnSync } = require('node:child_process');
const { join } = require('node:path');

const here = __dirname;
const args = process.argv.slice(2);
const cyto = args[0] === '--cyto';
const sperm = args[0] === '--sperm';
const blood = args[0] === '--bloodgroup';
const schematic = args[0] === '--schematic';
const histo = args[0] === '--histology';
const urin = args[0] === '--urinalysis';
const morph = args[0] === '--bloodmorph';
const cells = args[0] === '--cells' || cyto || sperm || blood || histo || urin || morph;
const quant = args.includes('--quant');
const rest = (cells || schematic ? args.slice(1) : args).filter((a) => a !== '--quant');
const srcDir = schematic ? join(here, 'schematic') : morph ? join(here, 'bloodmorph') : urin ? join(here, 'urinalysis') : histo ? join(here, 'histology') : blood ? join(here, 'bloodgroup') : sperm ? join(here, 'sperm') : cyto ? join(here, 'cyto') : cells ? join(here, 'cells') : here;
const out = schematic
  ? join(here, '../../assets/instruments/schematic')
  : morph
  ? join(here, '../../assets/bloodmorph')
  : urin
  ? join(here, '../../assets/urinalysis')
  : histo
  ? join(here, '../../assets/histology')
  : blood
  ? join(here, '../../assets/bloodgroup')
  : sperm
  ? join(here, '../../assets/spermogram')
  : cyto
  ? join(here, '../../assets/cytology')
  : cells
    ? join(here, '../../assets/differential')
    : join(here, '../../assets/instruments/img');
const names = rest.length
  ? rest
  : schematic
  ? readdirSync(srcDir).filter((f) => f.endsWith('.svg')).map((f) => f.slice(0, -4))
  : cells
    ? readdirSync(srcDir).filter((f) => f.endsWith('.svg')).map((f) => f.slice(0, -4))
    : ['chemistry', 'hematology', 'immunoassay', 'urinalysis'];
(async () => {
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage({ viewport: { width: 1200, height: 900 }, deviceScaleFactor: 1 });
if (schematic) {
  // Shaffof fon: kartaning neytral foni (kunduzgi/tungi) ko'rinib turadi.
  // Qism belgilaridagi raqamlar (callouts) — ilova shrifti Inter 700.
  const inter = readFileSync(join(here, '../../assets/fonts/Inter-700.ttf')).toString('base64');
  const head = `<style>@font-face{font-family:Inter;font-weight:700;src:url(data:font/ttf;base64,${inter})}</style>`;
  for (const [suffix, scale] of [['1200', 1], ['480', 0.4]]) {
    const pg = await browser.newPage({ viewport: { width: 1200, height: 800 }, deviceScaleFactor: scale });
    for (const n of names) {
      const svg = readFileSync(join(srcDir, `${n}.svg`), 'utf8');
      await pg.setContent(`<html><head>${head}</head><body style="margin:0;background:transparent">${svg}</body></html>`);
      await pg.evaluate(() => document.fonts.ready);
      const file = join(out, `${n}_${suffix}.png`);
      await pg.screenshot({ path: file, omitBackground: true, clip: { x: 0, y: 0, width: 1200, height: 800 } });
      if (quant) {
        const r = spawnSync('pngquant', ['--quality=85-98', '--speed=1', '--force', '--skip-if-larger', '--output', file, file]);
        if (r.error) throw r.error;
      }
      console.log('ok', n, suffix);
    }
  }
  await browser.close();
  return;
}
const font = readFileSync(join(here, '../../assets/fonts/Inter-700.ttf')).toString('base64');
const font6 = readFileSync(join(here, '../../assets/fonts/Inter-600.ttf')).toString('base64');
for (const n of names) {
  const svg = readFileSync(join(srcDir, `${n}.svg`), 'utf8');
  // O'lcham SVG ning width/height atributidan (odatiy — 1200×900).
  const w = Number(/width="(\d+)"/.exec(svg)?.[1] ?? 1200);
  const h = Number(/height="(\d+)"/.exec(svg)?.[1] ?? 900);
  await page.setViewportSize({ width: w, height: h });
  await page.setContent(`<html><head><style>
    @font-face{font-family:Inter;font-weight:700;src:url(data:font/ttf;base64,${font})}
    @font-face{font-family:Inter;font-weight:600;src:url(data:font/ttf;base64,${font6})}
    html,body{margin:0;padding:0}</style></head><body>${svg}</body></html>`);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: join(out, `${n}.png`), clip: { x: 0, y: 0, width: w, height: h } });
  console.log('ok', n);
}
await browser.close();
})();
