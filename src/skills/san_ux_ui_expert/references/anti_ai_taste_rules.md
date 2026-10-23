# Matrice Négative Anti-AI Taste : L'Artisanat Vivant vs Les Clichés IA

Ce document constitue la charte de proscription absolue des tics visuels, réflexes paresseux et architectures génériques couramment produits par les modèles d'IA générative non contraints. Chaque règle oppose au cliché artificiel une directive d'artisanat numérique vivant (*Craft UI*).

---

## 1. LES 8 TICS GRAPHIQUES ET ERGONOMIQUES MAJEURS TRAQUÉS

### 1. Le Dégradé Néon Violet / Bleu Cyan sur Fond Noir Absolu
* **Le Cliché IA (PROSCRIT ❌) :**
  Plaquer systématiquement un dégradé violet électrique vers bleu cyan (`from-purple-600 via-indigo-600 to-cyan-400`) sur un fond noir OLED absolu (`#000000`). Ce motif donne immédiatement une signature « template cyberpunk générique généré par IA ».
* **Dommage Utilisateur :**
  Fatigue visuelle rapide, déconnexion avec l'identité réelle de marque, contraste criard et illisible en plein soleil.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Palette ancrée dans `.agents/rules/BRAND.md`. Nuances de fond organiques et riches (`bg-slate-900`, `bg-slate-950`, teintes chaudes), accents identitaires distinctifs (ex: ambre doré chaleureux, vert émeraude sobre), bordures subtilement teintées (`border-slate-800/80`).
  ```tsx
  // INTERDIT :
  <div className="bg-gradient-to-r from-purple-500 to-indigo-600 text-white shadow-purple-500/50">

  // RECOMMANDÉ :
  <div className="bg-amber-500 hover:bg-amber-400 active:scale-[0.98] text-slate-950 font-black shadow-lg shadow-amber-500/20">
  ```

---

### 2. Le Triptyque Monotone des 3 Cartes Grises Uniformes
* **Le Cliché IA (PROSCRIT ❌) :**
  Présenter chaque fonctionnalité, plan ou argument sous la forme de 3 cartes strictement identiques alignées en grille (`grid-cols-3`), sur fond gris pâle `#f3f4f6` ou cartes grises `#1e293b` avec une petite icône ronde pastel centrée au sommet.
* **Dommage Utilisateur :**
  Monotonie léthargique, incapacité pour le cerveau de hiérarchiser l'information importante, effet catalogue sans âme.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Composition asymétrique, cartes modulées selon l'importance de l'élément (carte héroïque large pour l'action principale, cartes compactes horizontales pour les détails secondaires), séparateurs francs, typographie affirmée.

---

### 3. Le Spinner Plein Écran Aveugle
* **Le Cliché IA (PROSCRIT ❌) :**
  Bloquer l'intégralité de l'écran avec un fond semi-opaque et un spinner circulaire tournoyant au milieu (`<div className="fixed inset-0 flex items-center justify-center"><Spinner /></div>`).
* **Dommage Utilisateur :**
  Sensation de lenteur et d'inactivité anxiogène, écran masqué, décalage cumulatif de layout massif (*CLS*) au déblocage.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  **Squelettes géométriques synchronisés (*Skeletons* anti-CLS)**. Le skeleton reproduit fidèlement la hauteur, la largeur et les arrondis des futures cartes de contenu avec une impulsion douce (`animate-pulse`). Les conteneurs conservent leur espace réservé. CLS $\approx 0$.

---

### 4. Le Bouton Flottant Parasite (Floating Action Button - FAB)
* **Le Cliché IA (PROSCRIT ❌) :**
  Ajouter un gros bouton rond flottant `fixed bottom-6 right-6` avec une icône « + » ou « Chat » qui masque le contenu textuel sous-jacent, les totaux de paiement ou les barres de navigation.
* **Dommage Utilisateur :**
  Obstruction du défilement, clics involontaires au pouce, interférence avec le Home Indicator d'iOS ou la gesture bar d'Android.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Barre d'action inférieure fixe et ancrée (`sticky bottom-0` ou `footer` dédié) avec zone de sécurité (*Safe Area bottom padding*), boutons d'action intégrés dans le flux naturel de lecture.

---

### 5. Les Textes Secondaires Pâles et Illisibles
* **Le Cliché IA (PROSCRIT ❌) :**
  Utiliser des niveaux de gris trop clairs ou trop foncés sans vérifier le contraste (`text-gray-400` sur fond blanc ou `text-slate-600` sur fond sombre), descendant à des ratios $< 3:1$.
* **Dommage Utilisateur :**
  Illisibilité complète dès que la luminosité ambiante dépasse 5 000 lux (conditions extérieures tropicales).
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Contraste certifié mathématiquement : **$CR \ge 4.5:1$ (WCAG AA)** pour les textes secondaires, et **$CR \ge 7:1$ (WCAG AAA)** pour les informations critiques (montants en FCFA, statuts d'expédition, coordonnées).
  ```tsx
  // INTERDIT en extérieur :
  <p className="text-slate-500">Montant : 25 000 FCFA</p>

  // RECOMMANDÉ :
  <p className="text-slate-200 font-bold">Montant : <span className="text-amber-400">25 000 FCFA</span></p>
  ```

---

### 6. Les Modales Surgissantes au Centre de l'Écran Mobile
* **Le Cliché IA (PROSCRIT ❌) :**
  Faire apparaître des boîtes de dialogue modales centrées au milieu de l'écran tactile sur mobile (`fixed inset-0 m-auto max-w-sm`), avec une petite croix de fermeture miniature en haut à droite.
* **Dommage Utilisateur :**
  Inaccessibilité totale au pouce à une main : l'utilisateur doit déplacer sa prise en main pour atteindre le haut de la modale.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  **Feuille coulissante inférieure (*Bottom Sheet*)** ancrée en bas de l'écran, glissant depuis le bas avec une poignée de tirage tactile (*Drag Handle* $\ge 36\text{px}$), directement accessible dans les 40% inférieurs de l'écran.

---

### 7. Formulaires avec Validation Tardive Punitive
* **Le Cliché IA (PROSCRIT ❌) :**
  Attendre le clic final sur « Valider » pour bloquer la soumission et afficher une liste d'erreurs en texte rouge vif tout en haut de la page, forçant l'utilisateur à scroller vers le haut pour comprendre ce qui a échoué.
* **Dommage Utilisateur :**
  Frustration intense, désorientation, sentiment de blâme.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Validation contextuelle au fil de l'eau (*Inline Validation* bienveillante sur `onBlur`), masquage préventif des erreurs tant que le champ n'a pas été touché, formatage automatique des espaces téléphoniques locaux (`+242 06 912 34 56`), indicateurs visuels clairs à côté du champ concerné.

---

### 8. L'Absence Complète de Retour Physique (Micro-Haptique)
* **Le Cliché IA (PROSCRIT ❌) :**
  Des boutons totalement inertes : au clic ou tapotement sur smartphone, rien ne bouge, aucun retour tactile n'est transmis. L'utilisateur clique 3 fois de suite en croyant que l'application est gelée.
* **Dommage Utilisateur :**
  Double débit bancaire, transactions en doublon, sensation de bug.
* **Artisanat Vivant (OBLIGATOIRE ✅) :**
  Feedback biomécanique double immédiat :
  1. Micro-compression visuelle immédiate via `active:scale-[0.98]` ou `active:opacity-85`.
  2. Vibration sensorielle haptique physique calibrée via `expo-haptics` (`selectionAsync` ou `impactAsync(Light)`).

---

## 2. CHECKLIST RAPIDE ANTI-AI TASTE AVANT VALIDATION

Avant d'approuver un écran frontend :
- [ ] Aucun dégradé violet/cyan générique sur fond noir OLED.
- [ ] Aucune répétition mécanique de 3 cartes uniformes sans hiérarchie.
- [ ] Zéro spinner plein écran aveugle (présence de skeletons dédiés anti-CLS).
- [ ] Zéro modale centrée sur mobile (Bottom Sheets systématiques).
- [ ] Retours haptiques `expo-haptics` branchés sur les actions critiques.
- [ ] Contraste calculé $\ge 4.5:1$ en nominal et $\ge 7:1$ pour les montants plein soleil.
- [ ] Boutons primaires dimensionnés $\ge 44\times 44\text{px}$ avec `active:scale-[0.98]`.
