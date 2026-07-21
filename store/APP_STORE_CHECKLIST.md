# Checklist soumission App Store — Morfo

Statut au 21 juillet 2026. ✅ = fait dans le repo · ⬜ = à faire par toi (hors code).

## Fait dans le code
- ✅ Nom de marque unifié partout : **Morfo** (plus de « Morpho »).
- ✅ `CFBundleDisplayName = Morfo`, `ITSAppUsesNonExemptEncryption = false`.
- ✅ Descriptions de permissions dans `Info.plist` (photos, ajout photo, caméra).
  Sans elles → **rejet automatique**.
- ✅ Pages **Conditions** et **Confidentialité** in-app (`/terms`, `/privacy`),
  liées depuis les Réglages et le paywall.
- ✅ Mention d'abonnement (renouvellement auto, prix/période, gestion) sur le
  paywall — exigée par la règle 3.1.2.
- ✅ Liens légaux du paywall fonctionnels.
- ✅ SEO web (`index.html`, `manifest.json`) + fiche ASO (`store/ASO.md`).
- ✅ Versions hébergeables des documents légaux (`store/legal/*.html`),
  synchronisées avec les versions in-app (droit français, CNIL, médiateur de
  la consommation, mentions légales LCEN).
- ✅ Réponses au questionnaire **App Privacy** d'Apple : `store/APP_PRIVACY.md`.
- ✅ Interface bilingue FR/EN avec sélecteur dans les Réglages.
- ✅ SDK RevenueCat intégré (inerte tant que `REVENUECAT_PUBLIC_SDK_KEY` est
  vide → service de démo).

## À faire dans App Store Connect (hors code)
- ✅ **Bundle ID** `com.morfo.app` + signature automatique configurée.
- ⏳ **Compte développeur Apple** (99 €/an) : payé le 21/07/2026, en attente de
  validation par Apple. Tant que le profil expire en 7 jours, ce n'est pas actif.
- ⬜ **Mentions légales** : compléter le n° et la rue à Vénissieux, plus le SIRET
  (`legal_screen.dart` et `store/legal/*.html`).
- ⬜ **Icône 1024×1024** sans transparence ni coins arrondis (le papillon Morfo).
- ⬜ **Captures d'écran** aux tailles requises (6.7", 6.5", 5.5", iPad 12.9").
  → Mets l'**avant/après** en 1re capture (meilleur taux de conversion).
- ⬜ **App Privacy (nutrition labels)** : déclare les données collectées —
  Photos (contenu utilisateur), Achats, Identifiants, Données d'usage/diagnostic.
- ⬜ **URL de confidentialité** (obligatoire) + **URL des conditions/EULA** :
  héberge `store/legal/privacy.html` et `terms.html` (ex. https://morfo.app/privacy).
- ⬜ **URL de support** + e-mail : crée la boîte `support@morfo.app`.
- ⬜ **Abonnements** : crée le groupe d'abonnement, les produits (hebdo/annuel),
  leurs **noms d'affichage localisés** (voir `store/ASO.md`) et une **capture de
  review** du paywall. Sinon rejet 2.3.x / 3.1.2.
- ⬜ **Classification d'âge** (questionnaire) + **conformité export** (déjà exemté).
- ⬜ **Catégories** : Photo et vidéo (principale), Style de vie (secondaire).

## Reste à brancher (technique, avant prod) — voir README
- ⬜ **Backend réel** : `MORFO_USE_MOCK=false` (actuellement en mock).
- ⬜ **RevenueCat** (`purchases_flutter`) + **Superwall** — non ajoutés (cassent le
  build web) ; à intégrer côté mobile via import conditionnel.
- ⬜ **Enregistrement en galerie** réel sur mobile (ex. `image_gallery_saver`).
- ⬜ **Splash natif** + LaunchScreen aux couleurs de la marque (fond #07060D).
- ⬜ Suppression de compte / des données si tu ajoutes un jour un login (règle 5.1.1).

## Rappels règles Apple sensibles pour cette app
- **3.1.1** : les biens numériques (générations, abonnement) doivent passer par
  l'achat intégré Apple. Ne pas rediriger vers un paiement web.
- **Paywall « teasé »** : le pattern « aperçu de génération → paywall → génération
  réelle après paiement » est autorisé tant que l'utilisateur voit clairement
  l'écran d'abonnement et son prix avant tout débit (c'est le cas). Évite toute
  formulation laissant croire que le résultat est déjà prêt et « offert ».
- **5.1.1** : n'exige pas de compte pour des fonctions qui n'en ont pas besoin.

> ⚠️ Les textes légaux sont des **modèles**. Fais-les relire par un juriste et
> renseigne [RAISON SOCIALE] et [PAYS/JURIDICTION].
