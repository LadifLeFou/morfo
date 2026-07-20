# Intégrations monétisation — RevenueCat & Superwall

L'app est **déjà câblée** pour ces SDK via des interfaces et des factories à
imports conditionnels. Sur **web/desktop**, les stubs de démo sont utilisés (le
build web ne casse jamais). Sur **mobile**, il reste à déposer les
implémentations réelles et à ajouter les dépendances.

## Architecture (déjà en place)

```
services/
  purchases_service.dart            interface PurchasesService + DemoPurchasesService + provider
  purchases_service_factory.dart    import conditionnel stub/io
  purchases_service_stub.dart       web/desktop → démo
  purchases_service_io.dart         mobile → point de branchement RevenueCat

  paywall_service.dart              interface PaywallService + StubPaywallService + provider
  paywall_service_factory.dart      import conditionnel stub/io
  paywall_service_stub_platform.dart web/desktop → stub
  paywall_service_io.dart           mobile → point de branchement Superwall
```

- Les providers `purchasesServiceProvider` / `paywallServiceProvider` lisent les
  clés publiques depuis `.env` (`Env.revenueCatKey`, `Env.superwallKey`).
- `init()` des achats est déjà appelé au démarrage (voir `splash_screen.dart`).
- Le flux « génération teasée → paywall → génération réelle » est déjà en place
  (voir `generation_screen.dart` + `paywall_screen.dart`).

---

## 1. RevenueCat (achats / abonnements)

> ✅ **Étapes 1 à 4 déjà faites.** `purchases_flutter ^10.4.2` est dans
> `pubspec.yaml`, `lib/services/purchases_service_revenuecat.dart` existe et
> compile (API 10.x : `purchasePackage` → `purchase(PurchaseParams.package(…))`),
> et `purchases_service_io.dart` bascule automatiquement dessus dès que
> `REVENUECAT_PUBLIC_SDK_KEY` est renseignée. Sans clé → démo.
> Builds vérifiés : iOS ✅ et web ✅.
>
> **Il ne reste que l'étape 5** (configuration RevenueCat + App Store Connect).

<details><summary>Étapes historiques (déjà appliquées)</summary>

1. Ajouter la dépendance (sur une machine avec le toolchain mobile) :
   ```bash
   flutter pub add purchases_flutter
   ```
2. Copier le template :
   ```
   integration/purchases_service_revenuecat.dart.example
   → lib/services/purchases_service_revenuecat.dart
   ```
   (retirer l'extension `.example`, garder l'en-tête ⚠️ le temps de vérifier l'API).
3. Dans `lib/services/purchases_service_io.dart`, remplacer le corps par :
   ```dart
   import 'purchases_service.dart';
   import 'purchases_service_revenuecat.dart';

   PurchasesService createPurchasesService(String revenueCatApiKey) {
     if (revenueCatApiKey.isEmpty) return DemoPurchasesService();
     return RevenueCatPurchasesService(revenueCatApiKey);
   }
   ```
4. Renseigner `.env` : `REVENUECAT_PUBLIC_SDK_KEY=appl_xxx`.

</details>

5. Côté **RevenueCat + App Store Connect** :
   - Entitlement `pro` (adapter `_entitlementId` si besoin).
   - Offering `current` avec les packages abonnement (hebdo/annuel).
   - Offering `credits` avec les packs (`pack_50`, `pack_150`, `pack_500`) —
     aligner `_creditsForProduct`.
   - **Essai gratuit 3 jours** : configure une **offre d'introduction** (free
     trial de 3 jours) sur le produit annuel dans App Store Connect. Le paywall
     l'affiche automatiquement (badge « 3 JOURS GRATUITS » + CTA « Commencer mes
     3 jours gratuits ») via `SubscriptionOffer.trialDays` mappé dans le template.
     En démo (web), l'essai est simulé sur l'offre annuelle.

## 2. Superwall (paywall distant A/B testé)

1. `flutter pub add superwallkit_flutter`
2. Copier `integration/paywall_service_superwall.dart.example`
   → `lib/services/paywall_service_superwall.dart`.
3. Dans `lib/services/paywall_service_io.dart`, remplacer le corps par :
   ```dart
   import 'paywall_service.dart';
   import 'paywall_service_superwall.dart';

   PaywallService createPaywallService(String superwallApiKey) {
     if (superwallApiKey.isEmpty) return const StubPaywallService();
     return SuperwallPaywallService(superwallApiKey);
   }
   ```
4. Renseigner `.env` : `SUPERWALL_API_KEY=pk_xxx`.
5. **(Optionnel) présenter Superwall avant le paywall natif.** Dans le flux de
   tease (`generation_screen.dart#_goPaywall`), tenter d'abord le distant :
   ```dart
   final handled = await ref.read(paywallServiceProvider)
       .presentRemotePaywall(placement: 'post_generation');
   await ref.read(subscriptionProvider.notifier).refresh();
   if (ref.read(subscriptionProvider)) {
     // abonné via Superwall → reprendre la génération
     context.pushReplacement('/generate', extra: widget.args);
   } else if (!handled) {
     context.pushReplacement('/paywall', extra: widget.args); // natif de secours
   }
   ```
   Tant que Superwall n'est pas actif, `presentRemotePaywall` renvoie `false`
   → le paywall natif s'affiche (comportement actuel inchangé).

---

## 3. Notifications de reconquête (conversion)

La **logique de campagnes est déjà active** (`features/notifications/
conversion_notifications.dart`) et branchée sur le parcours :

| Déclencheur | Notifs programmées |
|---|---|
| Génération lancée mais **paywall non payé** | +1 h « Ta métamorphose t’attend » · +24 h « Tu y étais presque » |
| **Abonnement souscrit** | annule les relances de vente (abandon, -50 %, crédits) |
| **Fin d’onboarding** | +3 h « Prêt pour ta 1re métamorphose ? » |
| **Inactivité** | +48 h « De nouveaux styles t’attendent » (repoussée à chaque ouverture du home) |
| **Inactivité 3 j** (non-abonné) | +72 h « -50 % rien que pour toi » |
| **Crédits épuisés** | +2 h « Plus de crédits ? Recharge » |
| **Après un partage** | +6 h « On remet ça ? » |

> ⚠️ **Offre -50 %** : la notification est du marketing. Pour l’honorer sans
> induire en erreur (règles Apple), configure une vraie **offre promotionnelle**
> (introductory/promotional offer) dans App Store Connect + RevenueCat, et fais
> pointer le tap de la notif vers le paywall correspondant. Sinon, retire cette
> campagne (`_discount`) de `conversion_notifications.dart`.

Sur web/desktop, l’envoi est un no-op (les logs `[notif#…]` en debug permettent
de vérifier la logique). Pour l’activer sur mobile :

1. `flutter pub add flutter_local_notifications timezone`
2. Copier `integration/notification_service_local.dart.example`
   → `lib/services/notification_service_local.dart`.
3. Dans `lib/services/notification_service_io.dart`, renvoyer
   `LocalNotificationService()`.
4. **iOS** : ajouter la capability *Push*/*Background* si besoin ; les permissions
   d’alerte sont demandées via `requestPermission()` (déjà appelé au bon moment).
5. Ajuster les délais/copy dans `conversion_notifications.dart` selon tes tests A/B.

## 4. Backend réel (rappel)

Indépendant des SDK ci-dessus : passer `MORFO_USE_MOCK=false` et renseigner
`MORFO_API_URL` + `SUPABASE_ANON_KEY`. Le sélecteur est déjà en place
(`service_providers.dart`).

## Notes
- Ne jamais committer `.env` (clés). Seules des clés **publiques** vivent côté app.
- Après ajout des SDK natifs, le **build web** doit rester vert grâce aux imports
  conditionnels : ne jamais importer `purchases_flutter` / `superwallkit_flutter`
  en dehors des fichiers `*_io.dart` ou `*_revenuecat/superwall.dart`.
- Vérifier l'API exacte des SDK selon la version installée (les templates ciblent
  purchases_flutter v8+ et superwallkit_flutter récent).
```
