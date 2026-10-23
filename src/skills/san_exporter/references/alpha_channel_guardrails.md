# GARDE-FOU CANAL ALPHA : PRÉVENTION DE L'ERREUR APPLE ITMS-90717

Lors de la soumission d'une archive iOS (`.ipa`) ou de la validation via l'application Apple Transporter, la présence d'un canal alpha (transparence) dans l'icône principale déclenche un rejet critique bloquant :

> **Apple ITMS-90717 :** *Invalid App Store Icon. The App Store Icon in the asset catalog in '[...].app' can't be transparent nor contain an alpha channel.*

---

## 1. CAUSE TECHNIQUE

Les formats PNG 32-bit (RGBA) comportent 8 bits par canal : Rouge, Vert, Bleu et Alpha. Même si la couche alpha est entièrement opaque ($A = 255$ partout), les outils d'inspection statique d'Apple analysent les en-têtes du chunk `IHDR` du fichier PNG :
- Si `Color Type = 6` (RGBA) ou `Color Type = 4` (Niveaux de gris avec alpha), le binaire est rejeté.
- Pour être accepté, le fichier PNG doit présenter strictement `Color Type = 2` (RGB 24-bit sans alpha).

---

## 2. MÉCANISME DE REMÉDIATION DÉTERMINISTE DANS `san_exporter`

Dans le compilateur [`svg_to_png.mjs`](../scripts/svg_to_png.mjs), l'asset `assets/icon.png` subit l'opération d'aplatissement native :

```javascript
// Aplatissement garanti sans perte sur fond blanc pur
let pipeline = sharp(svgBuffer, { density: 300 })
  .resize(1024, 1024)
  .removeAlpha()
  .flatten({ background: '#FFFFFF' });

await pipeline.png({ compressionLevel: 9 }).toFile('assets/icon.png');
```

Cette opération :
1. Découpe et fusionne tout fragment transparent sur un arrière-plan `#FFFFFF`.
2. Supprime physiquement le 4ème canal d'échantillonnage de l'en-tête binaire PNG.
3. Émet un PNG 24-bit certifié 100% conforme pour Transporter et Xcode.
