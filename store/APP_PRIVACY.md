# App Privacy — réponses pour App Store Connect

Réponses au questionnaire **App Privacy**, établies par audit du code (app +
backend) le 21 juillet 2026. Une déclaration inexacte est un motif de rejet, et
Apple recoupe avec le comportement réel de l'app.

> À refaire si tu ajoutes un SDK d'analytics, de crash reporting ou de publicité.

---

## Ce que fait réellement l'app

| | |
|---|---|
| **Photos** | Envoyées au backend, transmises à Replicate, **jamais écrites sur disque**. Vérifié : aucune écriture d'image côté serveur. |
| **Identifiant** | `rc_app_user_id` — identifiant RevenueCat, pseudonyme. Aucun nom, email ni téléphone n'est collecté. |
| **Achats** | Gérés par Apple ; RevenueCat conserve l'historique d'abonnement. |
| **Stockage local** | Onboarding, solde de crédits, historique, favoris, langue — **sur l'appareil uniquement**, jamais transmis. |
| **Analytics / tracking** | **Aucun.** Ni Firebase, ni Sentry, ni Crashlytics, ni régie publicitaire. |
| **Notifications** | Locales, planifiées sur l'appareil. Aucun serveur de push. |

---

## Réponses au questionnaire

### 1. « Do you or your third-party partners collect data from this app? »

→ **Yes**

### 2. Types de données à cocher

Ne coche **que ces trois** :

#### ☑️ User Content → **Photos or Videos**
- **Utilisation** : *App Functionality* uniquement
- **Lié à l'identité** : **Oui** — la photo est transmise avec l'identifiant utilisateur
- **Utilisé pour le suivi publicitaire** : **Non**

> On déclare la collecte bien que rien ne soit conservé : Apple raisonne sur la
> transmission, pas seulement sur le stockage.

#### ☑️ Identifiers → **User ID**
- **Utilisation** : *App Functionality* (rattacher l'abonnement et le solde de crédits)
- **Lié à l'identité** : **Oui**
- **Utilisé pour le suivi publicitaire** : **Non**

#### ☑️ Purchases → **Purchase History**
- **Utilisation** : *App Functionality*
- **Lié à l'identité** : **Oui**
- **Utilisé pour le suivi publicitaire** : **Non**

### 3. Types à NE PAS cocher

Contact Info · Health & Fitness · Financial Info · Location · Sensitive Info ·
Contacts · Browsing History · Search History · Usage Data · Diagnostics

> **Usage Data** et **Diagnostics** se déclarent uniquement si un SDK d'analytics
> ou de crash reporting est présent. Il n'y en a aucun.

### 4. « Is this app used to track users? »

→ **No**

Aucune donnée n'est croisée avec des données tierces à des fins publicitaires,
et aucune régie n'est intégrée. Répondre *Yes* déclencherait l'obligation
d'afficher la fenêtre **ATT** — inutile ici, et pénalisante pour la conversion.

---

## Points à revoir selon tes choix

**« Lié à l'identité » pour les photos.** J'ai retenu *Oui*, la réponse
prudente : la requête porte l'identifiant utilisateur. Un argument existe pour
*Non* — cet identifiant est pseudonyme et ton système ne connaît ni nom ni
email. En cas de doute, garde *Oui* : surdéclarer ne fait jamais rejeter une
app, sousdéclarer si.

**Si tu ajoutes Superwall** (le stub existe dans `integration/`), il collecte
des données d'usage et de performance de paywall. Il faudra alors cocher
**Usage Data** et refaire ce document.

---

## Autres champs de confidentialité

- **Privacy Policy URL** — obligatoire. Héberge `store/legal/privacy.html` et
  renseigne l'adresse publique.
- **Data Retention** — les photos ne sont pas conservées au-delà du traitement,
  comme l'indique la politique de confidentialité in-app.
- **Account Deletion** — pas de compte au sens Apple (aucune inscription), donc
  pas de parcours de suppression exigé. Si tu ajoutes une authentification,
  Apple imposera une suppression de compte accessible depuis l'app.
