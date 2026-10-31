# Guide de Rédaction des Fiches d'Anomalies Médico-Légales
# Framework Antigravity (`san_*`) — Moteur `san_qa_security_expert`

Chaque constat ou faille de sécurité détectée par `san_qa_security_expert` doit impérativement faire l'objet d'une fiche normalisée selon la structure suivante.

---

## GABARIT DE FICHE D'ANOMALIE MÉDICO-LÉGALE

```markdown
### [SÉVÉRITÉ-CATÉGORIE-NUM] Titre précis et univoque du défaut
- **Statut / Sévérité :** [BLOQUANT | ÉLEVATION_QUALITÉ]
- **Classification :** [OWASP Top 10 / CWE / Core Web Vitals / A11y]
- **Localisation exacte :** `chemin/vers/fichier.ext:ligne`
- **Composant affecté :** [Endpoint API / Écran UI / Script]

#### Scénario de Reproduction :
Commandes exactes ou actions reproductibles pour déclencher l'anomalie :
\`\`\`bash
curl -X GET "https://api.example.com/api/v1/wallets/99/transactions" \
  -H "Authorization: Bearer <token_utilisateur_different>" \
  -H "Accept: application/json"
\`\`\`

#### Comportement Observé :
Description factuelle de la défaillance (fuite de données, écran blanc, crash, régression).

#### Impact Risque / Métier :
Impact sur la sécurité, la disponibilité ou l'expérience utilisateur.

#### Correctif Exigé :
Proposition de solution architecturale ou implémentation attendue (avec exemple de code ciblé).
```
