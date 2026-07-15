# Morfo

**Génération et transformation de photos par IA** — portraits stylisés, transformations « épiques », effets fun et courtes vidéos. Application mobile Flutter (iOS · iPad · macOS Apple Silicon · visionOS), pensée grand public et virale, monétisée par abonnement + crédits.

> Produit conçu autour d'un moment fort : la **métamorphose avant → après** et la **carte-résultat holographique**, l'élément que l'on screenshot et que l'on partage.

---

## ✨ Points forts

- **Design system dark-first** avec un spectre holographique utilisé avec parcimonie (CTA, anneau de génération, carte-résultat).
- **Carte holographique signature** : foil spectral réactif à l'inclinaison du téléphone (gyroscope) — et au survol de la souris sur le web.
- **Architecture feature-first** propre (Riverpod, go_router), testable et prête à publier.
- **Tourne sans backend** grâce à un service *mock* (18 templates de démo, résultats simulés).
- **Compatible web** pour un aperçu instantané pendant le développement.

---

## 🧱 Stack

| Domaine | Choix |
|---|---|
| Framework | Flutter 3.x · Dart 3 (null-safe) |
| State | Riverpod (`flutter_riverpod`) |
| Navigation | `go_router` (routes typées, deep links prêts) |
| Réseau | `dio` |
| Local | `shared_preferences` (flags, crédits, historique) |
| Média | `image_picker`, `cached_network_image`, `share_plus`, `permission_handler` |
| Capteurs | `sensors_plus` (foil gyroscopique) |
| Animations | `flutter_animate`, `lottie` |
| Config | `flutter_dotenv` |
| Polices | Clash Display + Satoshi (Fontshare, embarquées) |

---

## 🗂️ Architecture

```
lib/
  app/            bootstrap, routeur, état global (app_state), widgets partagés
  core/           env, exceptions, persistance, modèles de domaine
  design_system/  couleurs, typo, spacing, thème + bibliothèque de widgets
  features/
    splash/  onboarding/  paywall/  home/  generation/  result/
    history/  credits/  settings/          (chacun : presentation/…)
  services/       generation (interface + mock + api), purchases, paywall
  data/           demo_templates.dart (18 templates FR)
```

Le **mock** (`services/generation_service_mock.dart`) permet de lancer l'app de bout en bout immédiatement. Un flag `.env` bascule sur l'API réelle.

---

## 🚀 Démarrage

### Prérequis
- Flutter **3.x** (`flutter --version`)
- Un navigateur Chrome/Edge pour l'aperçu web, **ou** un simulateur iOS (macOS) / émulateur Android.

### Installation
```bash
flutter pub get
cp .env.example .env      # puis remplissez si besoin (par défaut : mode mock)
```
> Les polices (Clash Display, Satoshi) sont **déjà embarquées** dans `assets/fonts/`.

### Lancer
```bash
flutter run -d chrome     # aperçu web (le plus simple sous Windows)
flutter run               # sur un appareil/simulateur connecté
```

### Vérifier
```bash
flutter analyze
flutter test
```

---

## ⚙️ Configuration (`.env`)

| Clé | Rôle |
|---|---|
| `MORFO_API_URL` | URL du backend (contrat ci-dessous) |
| `SUPABASE_ANON_KEY` | Clé publique d'auth (header `Bearer`) |
| `MORFO_USE_MOCK` | `true` (défaut) = mock, aucun backend requis · `false` = API réelle |
| `REVENUECAT_PUBLIC_SDK_KEY` | Clé publique RevenueCat (mobile) |
| `SUPERWALL_API_KEY` | Clé publique Superwall (mobile) |

> ⚠️ **Aucune clé secrète de modèle IA ne vit dans l'app.** La logique prompts / crédits / entitlements est côté backend.

---

## 🔌 Contrat backend

L'app est construite contre cette interface (voir `services/generation_service_api.dart`) :

- `GET /templates` → liste de templates
- `POST /generate-image` `{ rc_app_user_id, template_id, image_base64 }` → `{ url, credits_left }` (402 si crédits insuffisants)
- `POST /generate-video` → `{ request_id }`, puis `GET /video-status?id=…` → `{ status, url? }`

L'image est **redimensionnée à 1024 px max + JPEG q≈0.8** avant l'envoi (voir écran d'import).

---

## 💳 Monétisation (à brancher sur mobile)

RevenueCat (`purchases_flutter`) et Superwall (`superwallkit_flutter`) sont des **SDK iOS/Android** qui ne se compilent pas sur le web. Ils ne sont donc **pas encore ajoutés** aux dépendances.

L'app fournit des **interfaces propres** (`PurchasesService`, `PaywallService`) avec des implémentations de démo (`DemoPurchasesService`, `StubPaywallService`). Pour le build mobile :

1. `flutter pub add purchases_flutter superwallkit_flutter`
2. Créer `purchases_service_revenuecat.dart` / `paywall_service_superwall.dart` implémentant les interfaces.
3. Les brancher via un import conditionnel (`if (dart.library.io)`) pour préserver le build web.
4. Renseigner les clés publiques dans `.env`.

Le **paywall natif de secours** est déjà complet (hero, bénéfices, sélecteur d'offres, restauration, liens légaux).

---

## 🧭 Choix d'ingénierie notables

- **Modèles écrits à la main** (immuables, `fromJson`/`toJson`) plutôt que via freezed : la version disponible de freezed était une préversion et la génération de code ajoutait un risque de build fragile. Les paquets de codegen restent dans `pubspec.yaml` pour une migration ultérieure.
- **Persistance via `shared_preferences`** (au lieu de Hive) pour une compatibilité web irréprochable. Migrable vers Hive sur mobile.
- **Aperçu web** : les plugins natifs (capteurs, fichiers) sont gardés derrière des vérifications de plateforme / imports conditionnels.
- **Accessibilité** : sémantique bouton sur les cibles tactiles, respect de `reduce motion` (le foil se fige), contrastes soignés.

---

## 🌍 Localisation

L'app est **entièrement en français** avec une microcopie soignée (voix active, sentence case). La structure est prête à une extraction i18n (`easy_localization`) pour `de` / `en` / `es` / `it`.

---

## ✅ TODO mise en production

- [ ] Build iOS **sur un Mac** (Xcode requis) · bundle id `com.morfo.app`
- [ ] Brancher RevenueCat + Superwall (voir §Monétisation)
- [ ] Brancher le backend réel (`MORFO_USE_MOCK=false`)
- [ ] Enregistrement réel en galerie (ex. `image_gallery_saver` sur mobile)
- [ ] Extraction i18n complète (`easy_localization`)
- [ ] App Icon + splash natif · pages légales (Conditions, Confidentialité)
- [ ] Revue App Store (bouton Restaurer ✔, permissions, liens légaux)

---

## 📄 Licence

Projet privé — tous droits réservés.
