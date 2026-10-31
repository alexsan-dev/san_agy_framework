#!/usr/bin/env python3
"""
==============================================================================
SCRIPT : score_idea.py
FRAMEWORK : Antigravity (san_*)
AUTEUR : Alexsan.pro
DESCRIPTION : Calculateur déterministe de la matrice 40 points pour san_brainstorming.
              Évalue 4 piliers fondamentaux avec pondérations mathématiques et
              clauses éliminatoires adaptées au profil du projet.
USAGE :
  python3 score_idea.py --profile global_saas --impact 8.5 --effort 8.0 --terrain 9.0 --risques 8.0
  python3 score_idea.py --profile cli_devtools --impact 9.0 --effort 8.5 --terrain 8.0 --risques 8.5 --json
  python3 score_idea.py --profile emerging_market --impact 8.5 --effort 8.0 --terrain 3.0 --risques 8.0
==============================================================================
"""

import argparse
import json
import sys

VALID_PROFILES = [
    "emerging_market",
    "global_saas",
    "mobile_consumer",
    "cli_devtools",
    "api_platform"
]


def calculate_score(impact: float, effort: float, terrain: float, risques: float, profile: str = "global_saas"):
    """
    Calcule le score pondéré sur 40 points et évalue les clauses éliminatoires
    en adaptant le pilier 3 selon le profil du projet.
    """
    if profile not in VALID_PROFILES:
        raise ValueError(
            f"Profil inconnu '{profile}'. Profils acceptés : {', '.join(VALID_PROFILES)}"
        )

    # Définition contextuelle du Pilier 3 selon le profil
    if profile == "emerging_market":
        pillar3_label = "Réalité Terrain (Afrique / Marchés Émergents 3G / MoMo)"
        pillar3_short = "Réalité Terrain 3G/MoMo"
        veto_pillar3_msg = (
            f"VETO TERRAIN DÉCLENCHÉ : Note Terrain de {terrain:.1f}/10 inférieure au seuil éliminatoire (4.0). "
            "Inadapté aux contraintes réseau 3G, paiement Mobile Money ou terminaux modestes réels."
        )
        action_veto = (
            "Piste éliminée sans appel. Revoir radicalement l'adéquation au terrain "
            "(mode offline, frugalité bande passante, intégration MoMo) ou assainir les risques légaux/techniques."
        )
    else:
        pillar3_label = "Adéquation Workflow, Friction d'Adoption & Résilience Opérationnelle"
        pillar3_short = "Adéquation Workflow & Ops"
        veto_pillar3_msg = (
            f"VETO WORKFLOW/ADOPTION DÉCLENCHÉ : Note Adéquation Workflow de {terrain:.1f}/10 "
            "inférieure au seuil éliminatoire (4.0). Friction d'onboarding excessive, temps d'intégration trop lourd, "
            "dépendances superflues ou inadaptation au flux de travail des utilisateurs cibles."
        )
        action_veto = (
            "Piste éliminée sans appel. Réduire drastiquement la friction d'adoption, simplifier "
            "la stack ou éliminer les dépendances superflues avant réévaluation."
        )

    # Validation stricte des plages de notation (1.0 à 10.0)
    for name, val in [("Impact Business", impact), ("Faisabilité/Effort", effort),
                      (pillar3_short, terrain), ("Risques & Dépendances", risques)]:
        if not (1.0 <= val <= 10.0):
            raise ValueError(f"La note '{name}' ({val}) doit être comprise entre 1.0 et 10.0.")

    # Application des coefficients contractuels
    weighted_impact = impact * 1.0
    weighted_effort = effort * 1.0
    weighted_terrain = terrain * 1.2
    weighted_risques = risques * 0.8

    total_score = weighted_impact + weighted_effort + weighted_terrain + weighted_risques
    percentage = (total_score / 40.0) * 100.0

    # Analyse des clauses d'élimination directe (Vetos absolus)
    exclusions = []
    if terrain < 4.0:
        exclusions.append(veto_pillar3_msg)
    if risques < 3.0:
        exclusions.append(
            f"VETO RISQUES DÉCLENCHÉ : Note Risques de {risques:.1f}/10 inférieure au seuil éliminatoire (3.0). "
            "Vulnérabilité légale, dépendance toxique ou risque de blocage critique."
        )

    # Attribution du verdict selon les seuils contractuels
    if exclusions:
        verdict = "REJETÉ (NO-GO ABSOLU)"
        statut = "NO_GO_VETO"
        action = action_veto
    elif total_score >= 32.0:
        verdict = "GO MVP VALIDÉ (PRIORITÉ HAUTE)"
        statut = "GO_MVP_PRIORITAIRE"
        action = "Transmission immédiate à san_planner pour initialisation de la roadmap /roadmaps/MVP_*.md."
    elif total_score >= 28.0:
        verdict = "GO MVP CONDITIONNEL (ITÉRATION TECHNIQUE)"
        statut = "GO_MVP_CONDITIONNEL"
        action = "Admissible sous réserve. Réduire le périmètre fonctionnel ou sécuriser les dépendances avant planification."
    else:
        verdict = "REJETÉ (SCORE INSUFFISANT < 28/40)"
        statut = "REJET_RATIONNEL"
        action = "Piste non rentable dans le contexte actuel. Consommation de ressources disproportionnée par rapport au ROI."

    return {
        "profile": profile,
        "pillar3_name": pillar3_label,
        "impact": round(impact, 2),
        "effort": round(effort, 2),
        "terrain": round(terrain, 2),
        "workflow_adoption": round(terrain, 2),
        "risques": round(risques, 2),
        "weighted_impact": round(weighted_impact, 2),
        "weighted_effort": round(weighted_effort, 2),
        "weighted_terrain": round(weighted_terrain, 2),
        "weighted_risques": round(weighted_risques, 2),
        "total_score": round(total_score, 2),
        "percentage": round(percentage, 1),
        "statut": statut,
        "verdict": verdict,
        "exclusions": exclusions,
        "action": action
    }


def main():
    parser = argparse.ArgumentParser(
        description="Calculateur déterministe de score 40 points san_brainstorming (Antigravity Framework v2.0)"
    )
    parser.add_argument(
        "--profile",
        type=str,
        default="global_saas",
        choices=VALID_PROFILES,
        help="Profil contextuel du projet (défaut: global_saas). Adapte le Pilier 3 pour éliminer les faux vetos."
    )
    parser.add_argument(
        "--impact",
        type=float,
        required=True,
        help="Impact Business & Valeur Utilisateur (1.0 à 10.0)"
    )
    parser.add_argument(
        "--effort",
        type=float,
        required=True,
        help="Faisabilité & Simplicité Technique [Échelle Inversée] (1.0 = lourd, 10.0 = MVP 24-48h)"
    )
    parser.add_argument(
        "--terrain",
        "--workflow",
        "--adoption",
        dest="terrain",
        type=float,
        required=True,
        help="Pilier 3 : Réalité Terrain (si emerging_market) ou Adéquation Workflow / Adoption (autres profils) (1.0 à 10.0)"
    )
    parser.add_argument(
        "--risques",
        type=float,
        required=True,
        help="Maîtrise des Risques & Réglementation [Échelle Inversée] (1.0 = risqué/bloquant, 10.0 = souverain/sûr)"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Formater la sortie en JSON pur pour intégration programmatique"
    )

    args = parser.parse_args()

    try:
        res = calculate_score(args.impact, args.effort, args.terrain, args.risques, profile=args.profile)

        if args.json:
            print(json.dumps(res, indent=2, ensure_ascii=False))
            sys.exit(0 if not res["exclusions"] and res["total_score"] >= 28.0 else 1)

        # Affichage terminal standard
        print("=" * 72)
        print(" RAPPORT D'ÉVALUATION STRATÉGIQUE DÉTERMINISTE (san_brainstorming)")
        print(f" Profil contextuel actif : {res['profile']}")
        print("=" * 72)
        print(f"1. Impact Business (/10)             : {res['impact']:>4.1f}  (Poids 1.0 -> {res['weighted_impact']:>5.2f} pts)")
        print(f"2. Faisabilité & Simplicité (/10)    : {res['effort']:>4.1f}  (Poids 1.0 -> {res['weighted_effort']:>5.2f} pts)")
        p3_short = "3. Réalité Terrain 3G/MoMo (/10)    " if res['profile'] == 'emerging_market' else "3. Adéquation Workflow & Ops (/10)   "
        print(f"{p3_short}: {res['terrain']:>4.1f}  (Poids 1.2 -> {res['weighted_terrain']:>5.2f} pts)")
        print(f"4. Risques & Dépendances (/10)       : {res['risques']:>4.1f}  (Poids 0.8 -> {res['weighted_risques']:>5.2f} pts)")
        print("-" * 72)
        print(f"SCORE GLOBAL TOTAL                   : {res['total_score']:>4.2f} / 40.00 ({res['percentage']} %)")
        print(f"VERDICT FORMEL                       : {res['verdict']}")
        print(f"ACTION PRÉCONISÉE                    : {res['action']}")

        if res["exclusions"]:
            print("-" * 72)
            print("ALERTES DE VETO ÉLIMINATOIRE :")
            for alert in res["exclusions"]:
                print(f" [!] {alert}")

        print("=" * 72)

        # Code de sortie : 0 si admissible (>=28 sans veto), 1 sinon
        if res["exclusions"] or res["total_score"] < 28.0:
            sys.exit(1)
        sys.exit(0)

    except ValueError as e:
        print(f"[ERREUR DE VALIDATION] {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"[ERREUR SYSTÈME] {e}", file=sys.stderr)
        sys.exit(3)


if __name__ == "__main__":
    main()
