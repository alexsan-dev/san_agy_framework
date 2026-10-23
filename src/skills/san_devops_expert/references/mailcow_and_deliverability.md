# Guide d'Alignement DNS & Délivrabilité E-mail Mailcow (10/10)

Ce document détaille les règles cryptographiques, configurations DNS et procédures de diagnostic pour atteindre et maintenir une réputation irréprochable (**10/10 sur Mail-Tester**) avec un serveur **Mailcow:dockerized** sous la gouvernance de `san_devops_expert`.

---

## 1. ARCHITECTURE MAILCOW & ENJEUX DE DÉLIVRABILITÉ

Mailcow encapsule l'ensemble de la chaîne de messagerie dans des conteneurs Docker orchestrés :
- **Postfix :** Agent de transfert de courrier (MTA) pour l'émission et la réception SMTP.
- **Dovecot :** Serveur IMAP/POP3 sécurisé.
- **Rspamd :** Moteur d'analyse antispam, signature DKIM et réputation IP.
- **Unbound :** Résolveur DNS local validant DNSSEC pour interdire le cache poisoning.

La moindre erreur de configuration DNS ou un alignement flou entraîne la relégation immédiate des e-mails en boîte de courrier indésirable (*Spam*) chez les grands fournisseurs (Gmail, Microsoft Outlook, Yahoo, Apple iCloud).

---

## 2. LES 4 PILIERS DE L'ALIGNEMENT DNS STRICT

Pour chaque domaine émetteur (`alexsan.pro`), les enregistrements DNS suivants doivent être rigoureusement appliqués :

```txt
Domaine Principal : alexsan.pro
Serveur de Mail FQDN : mail.alexsan.pro
Adresse IP Publique VPS : 198.51.100.25 (Exemple)
```

### 1. Reverse DNS (Enregistrement PTR)
* **Définition :** L'adresse IP publique du VPS doit résoudre en sens inverse vers le nom d'hôte de la machine Mailcow.
* **Configuration :** S'effectue dans la console du fournisseur VPS (Hetzner, OVH, DigitalOcean, Contabo).
* **Vérification CLI :**
  ```bash
  dig -x 198.51.100.25 +short
  # Doit retourner strictement :
  # mail.alexsan.pro.
  ```

### 2. Enregistrement SPF (Sender Policy Framework) Stricte
* **Règle d'or Antigravity :** L'usage du tilde `~all` (SoftFail) est banni en production. Seul le tiret `-all` (HardFail) est toléré.
* **Enregistrement DNS TXT (sur `@` / racine de `alexsan.pro`) :**
  ```txt
  v=spf1 mx ip4:198.51.100.25 -all
  ```
* **Vérification CLI :**
  ```bash
  dig TXT alexsan.pro +short | grep "v=spf1"
  ```

### 3. Signature DKIM 2048 Bits (DomainKeys Identified Mail)
* **Génération de la Clé :**
  Dans Mailcow UI > **Configuration > ARC/DKIM** :
  - Domaine : `alexsan.pro`
  - Sélecteur : `mail` (ou `dkim`)
  - Longueur de clé : **2048 bits** (interdiction formelle des clés 1024 bits obsolètes).
* **Enregistrement DNS TXT (sous `mail._domainkey.alexsan.pro`) :**
  ```txt
  v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
  ```
* **Vérification CLI :**
  ```bash
  dig TXT mail._domainkey.alexsan.pro +short
  ```

### 4. Politique DMARC Stricte avec Alignement Renforcé (`p=reject`)
* **Enregistrement DNS TXT (sous `_dmarc.alexsan.pro`) :**
  ```txt
  v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; rua=mailto:dmarc-reports@alexsan.pro; pct=100
  ```
* **Signification des balises d'excellence :**
  - `p=reject` : Rejet catégorique de tout e-mail non authentifié.
  - `sp=reject` : Application stricte identique sur tous les sous-domaines.
  - `adkim=s` : Alignement strict DKIM (le domaine de signature `d=` doit correspondre exactement au domaine de l'en-tête `From:`).
  - `aspf=s` : Alignement strict SPF (le domaine de l'enveloppe SMTP doit correspondre à `From:`).
  - `rua=mailto:...` : Boîte de réception des rapports d'agrégation d'authentification XML.

### 5. Enregistrement MX (Mail Exchanger)
* **Enregistrement DNS MX (sur `@`) :**
  ```txt
  alexsan.pro.   3600   IN   MX   10 mail.alexsan.pro.
  ```

---

## 3. TABLEAU SYNTHÉTIQUE DE LA ZONE DNS OFFICIELLE

| Type | Nom d'Hôte / Sous-Domaine | Valeur Cible | Priorité / TTL |
| :--- | :--- | :--- | :---: |
| **A** | `mail` | `198.51.100.25` (IP VPS) | 3600 |
| **MX** | `@` | `mail.alexsan.pro.` | Priorité 10 |
| **TXT** | `@` | `v=spf1 mx ip4:198.51.100.25 -all` | 3600 |
| **TXT** | `mail._domainkey` | `v=DKIM1; k=rsa; p=MIIBI...` | 3600 |
| **TXT** | `_dmarc` | `v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; rua=mailto:dmarc@alexsan.pro; pct=100` | 3600 |
| **PTR** | `25.100.51.198.in-addr.arpa` | `mail.alexsan.pro.` | (Config FAI/VPS) |

---

## 4. CHIFFREMENT EN TRANSIT (TLS / STARTTLS)

Le serveur Postfix de Mailcow doit imposer le chiffrement lors des échanges SMTP :

```bash
# Vérification du support STARTTLS sur le port SMTP de soumission 587
openssl s_client -starttls smtp -connect mail.alexsan.pro:587 -tls1_3
```

- Vérifier que le certificat présenté est valide et couvre le FQDN `mail.alexsan.pro`.
- S'assurer que les chiffrements faibles (SSLv3, TLS 1.0, TLS 1.1) sont totalement désactivés.

---

## 5. SURVEILLANCE DES LISTES NOIRES (RBL / BLACKLISTS)

Une IP blacklistée entraîne le blocage immédiat des flux transactionnels. Contrôle périodique via requêtes DNS inversées :

```bash
# Script rapide de test RBL sur Spamhaus ZEN
REVERSED_IP="25.100.51.198"
RBL_HOST="${REVERSED_IP}.zen.spamhaus.org"

if dig +short "$RBL_HOST" | grep -q "^127\."; then
    echo "ALERTE CRITIQUE : IP listée chez Spamhaus ($RBL_HOST) !"
else
    echo "✔ IP saine : Aucune inscription chez Spamhaus."
fi
```

### Principales listes RBL surveillées :
- `zen.spamhaus.org`
- `b.barracudacentral.org`
- `bl.spamcop.net`
- `dnsbl.sorbs.net`

---

## 6. PROCÉDURE DE CERTIFICATION MAIL-TESTER (10/10)

1. Ouvrir le service d'évaluation : [https://www.mail-tester.com](https://www.mail-tester.com).
2. Récupérer l'adresse de test temporaire (ex: `test-xyz123@mail-tester.com`).
3. Envoyer un e-mail transactionnel type depuis l'application via le relais SMTP Mailcow :
   - Présence d'un objet clair.
   - Présence d'une version HTML et d'une version texte brut (*multipart/alternative*).
   - Liens HTTPS fonctionnels.
   - Pas de balises cachées ni de texte de couleur identique au fond.
4. Consulter le résultat :
   - Note visée : **10 / 10**.
   - Si la note est $\le 9.5$, examiner le rapport Rspamd / SpamAssassin et corriger immédiatement le paramètre incriminé.
