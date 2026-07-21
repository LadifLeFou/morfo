# Morfo — Fiche App Store (ASO)

> **Le point le plus important, et le plus souvent ignoré :** sur l'App Store,
> **la description n'est PAS indexée**. Contrairement à Google Play, Apple ne
> lit que trois champs pour la recherche :
>
> | Champ | Poids | Limite |
> |---|---|---|
> | **Nom de l'app** | le plus fort | 30 car. |
> | **Sous-titre** | fort | 30 car. |
> | **Mots-clés** (invisible) | moyen | 100 car. |
>
> Écrire une description bourrée de mots-clés ne sert donc **à rien** pour être
> trouvé. Elle sert uniquement à **convertir** celui qui est déjà sur ta fiche.
> Ces 160 caractères de titre + sous-titre + mots-clés sont tout ton référencement :
> aucun ne doit être gaspillé.
>
> Corollaire : ne répète jamais dans les mots-clés un terme déjà présent dans le
> nom ou le sous-titre — Apple les indexe une seule fois, la répétition est du
> caractère perdu.

---

## 🇺🇸 Cible principale : les États-Unis

Le marché US prime sur la France. Trois conséquences concrètes :

1. **La langue principale d'App Store Connect doit être `English (U.S.)`**, pas
   le français. C'est elle qui sert de repli sur tous les territoires où tu n'as
   pas de localisation — donc la quasi-totalité du monde.
2. **Optimise l'anglais en premier.** Le français devient une localisation
   secondaire, utile mais pas prioritaire.
3. **Raisonne tes prix en USD.** Apple applique des paliers ; 3,99 € correspond
   au palier $4.99 aux États-Unis, pas $3.99. Vérifie chaque produit.

> Ce choix se fait **à la création de l'app** dans App Store Connect et se
> change ensuite difficilement. Ne te trompe pas au moment du formulaire.

---

## ⚠️ Deux corrections à ne pas perdre de vue

**Le domaine `morfo.app` appartient à quelqu'un d'autre** (« MORFO — AK
Nutrition »). Les URL légales ci-dessous sont donc des placeholders : héberge
`store/legal/*.html` sur un domaine à toi et remplace-les. Une *Privacy Policy
URL* qui n'est pas la tienne = rejet.

**Ne promets jamais « illimité ».** L'abonnement donne 650 crédits/semaine, soit
**~14 images par semaine** (45 crédits l'image). Apple rejette les métadonnées
trompeuses (2.3.1) et c'est la première cause de demandes de remboursement.

---

## 🇫🇷 Français — localisation secondaire

### Nom de l'app (≤ 30)
```
Morfo: Photo IA & Avant-Après
```
`29 car.` — indexe *morfo, photo, ia, avant, après*

### Sous-titre (≤ 30)
```
Selfie en portrait de rêve
```
`26 car.` — indexe *selfie, portrait, rêve*

> Choisi pour l'intention de recherche : « selfie » est bien plus tapé que
> « portraits ». Le mot dit aussi ce que l'app fait, ce qui aide la conversion.

### Mots-clés (≤ 100, virgules sans espaces)
```
filtre,retouche,avatar,visage,transformation,generateur,art,cartoon,effet,viral,tendance,montage
```
`96 car.` — aucun doublon avec le nom ni le sous-titre.

### Texte promotionnel (≤ 170, modifiable sans review)
```
Nouveaux styles chaque semaine. Transforme ton selfie en portrait de cinéma, en héros de jeu vidéo ou en personnage cubique. Résultat en quelques secondes.
```

### Description (≤ 4000) — pour convertir, pas pour référencer
```
Transforme tes photos en véritables métamorphoses grâce à l'IA.

Importe un selfie, choisis un style, et laisse Morfo faire le reste. En quelques secondes, ton portrait devient épique, cinématographique, rétro ou glamour — puis se transforme en carte holographique unique que tu auras envie de partager.

▸ 14 STYLES, ET DE NOUVEAUX CHAQUE SEMAINE
Photo de classe années 90, peinture de la Renaissance, affiche de blockbuster, lumière dorée, élégance discrète, soirée au flash, bal de promo, vie de luxe, univers cubique en blocs, style jeu vidéo open-world…

▸ ÉCRIS TON PROPRE STYLE
Le mode prompt libre comprend ce que tu demandes et l'enrichit : « en roi médiéval sur son trône » suffit à obtenir couronne, fourrure et bannières héraldiques.

▸ AVANT / APRÈS BLUFFANT
Glisse pour comparer ta photo d'origine et ta transformation. L'effet « waouh » à chaque rendu.

▸ CARTE HOLOGRAPHIQUE À COLLECTIONNER
Chaque résultat devient une carte au foil spectral qui réagit à l'inclinaison de ton téléphone. Parfaite pour ta story.

▸ TES PHOTOS RESTENT LES TIENNES
Elles servent uniquement à produire ton rendu. Elles ne sont ni conservées, ni revendues, ni utilisées pour de la publicité.

ABONNEMENT
L'abonnement débloque tous les styles sans filigrane, les rendus haute résolution, et recharge 650 crédits chaque semaine — de quoi générer une quinzaine d'images hebdomadaires. Il se renouvelle automatiquement ; annulable à tout moment dans les réglages de ton compte App Store.

Conditions : https://[TON-DOMAINE]/terms
Confidentialité : https://[TON-DOMAINE]/privacy
Support : support@morfo.app
```

### Catégories
- **Principale :** Photo et vidéo
- **Secondaire :** Divertissement

---

## 🇺🇸 English (U.S.) — LOCALISATION PRINCIPALE

### App name (≤ 30)
```
Morfo: AI Selfie & Avatars
```
`26 car.` — indexe *morfo, ai, selfie, avatars*

> L'ancien nom, « Morfo: AI Photo & Before-After », gaspillait 14 caractères du
> champ le plus lourd. **« Before-After » n'est pas une requête** : personne ne
> cherche ça. *Selfie* et *avatar* sont au contraire deux des intentions les plus
> tapées de la catégorie.

### Subtitle (≤ 30)
```
AI headshots & photo styles
```
`27 car.` — indexe *headshots, photo, styles*

> *Headshot* est une requête à forte intention aux États-Unis (LinkedIn,
> profils pro) et tu as exactement ce style. *Photo* est récupéré ici puisqu'il
> a quitté le nom.

### Keywords (≤ 100)
```
yearbook,filter,face,editor,generator,makeover,glow up,art,retro,aesthetic,prom,luxury,transform
```
`96 car.` — aucun doublon avec le nom ni le sous-titre.

> **`yearbook` est le mot-clé le plus rentable de la liste.** La mode des photos
> de yearbook années 90 par IA a explosé aux États-Unis, la demande est
> installée, et c'est littéralement un de tes 14 styles. `prom` et `luxury`
> suivent la même logique : des styles que tu livres vraiment.
>
> Règle absolue : **ne référence jamais un style que tu n'as pas.** Apple
> sanctionne les mots-clés hors sujet, et un utilisateur déçu se désabonne.

### Promotional text (≤ 170)
```
New styles every week. Turn your selfie into a 90s yearbook photo, a movie poster or a luxury lifestyle shot. Results in seconds.
```

### Description (≤ 4000)
```
Turn your photos into real transformations with AI.

Upload a selfie, pick a style, and let Morfo do the rest. In seconds your portrait becomes epic, cinematic, retro or glamorous — then turns into a unique holographic card you'll actually want to share.

▸ 14 STYLES, MORE EVERY WEEK
90s yearbook photo, Renaissance oil painting, blockbuster movie poster, golden hour light, quiet luxury, flash party shot, prom night, luxury lifestyle, blocky cube world, open-world game art…

▸ WRITE YOUR OWN STYLE
Free prompt mode understands what you ask and fills in the rest: "as a medieval king on his throne" is enough to get the crown, the fur, the heraldic banners.

▸ STUNNING BEFORE / AFTER
Slide to compare your original photo with the result. The wow moment, every time.

▸ A HOLOGRAPHIC CARD TO COLLECT
Every result becomes a spectral foil card that reacts as you tilt your phone. Made for your story.

▸ YOUR PHOTOS STAY YOURS
They are used only to produce your result. Never stored, never sold, never used for advertising.

SUBSCRIPTION
The subscription unlocks every style watermark-free, high-resolution renders, and tops up 650 credits every week — around fifteen images. It renews automatically and can be cancelled anytime in your App Store account settings.

Terms: https://[YOUR-DOMAIN]/terms
Privacy: https://[YOUR-DOMAIN]/privacy
Support: support@morfo.app
```

### Categories
- **Primary:** Photo & Video
- **Secondary:** Entertainment

---

## 🚨 Marques déposées — à lire avant de rédiger

Tes deux styles les plus attractifs s'appellent **GTA V** et **Minecraft**. Ce
sont des **marques déposées** de Rockstar Games et Mojang/Microsoft.

- **Dans le nom, le sous-titre ou les mots-clés → rejet quasi certain.** Apple
  refuse l'usage de marques tierces dans les métadonnées indexées.
- **Dans la description ou les captures → risque réel.** Toléré si aucune
  affiliation n'est suggérée, mais le titulaire de la marque peut demander le
  retrait à tout moment.

**Ma recommandation :** décris-les génériquement dans les métadonnées — « style
jeu vidéo open-world », « univers cubique en blocs » — comme je l'ai fait dans
la description ci-dessus. Garde les noms exacts **dans l'app uniquement**, où
l'exposition est bien moindre.

C'est frustrant, parce que ce sont précisément les termes que les gens
recherchent. Mais un rejet coûte une semaine, et un retrait après publication
coûte bien plus.

---

## Noms d'affichage des achats intégrés

Ils s'affichent dans la confirmation d'achat Apple. Un nom vague vaut un rejet
(2.3.x), et « illimité » serait mensonger :

- `Abonnement Morfo — Hebdomadaire`
- `Abonnement Morfo — Annuel`
- `100 crédits Morfo`
- `300 crédits Morfo`
- `1000 crédits Morfo`

---

## Captures d'écran

Apple exige le format **iPhone 6,9"**. Elles ne jouent pas sur le
référencement, mais sur le **taux de conversion** — qui, lui, influence le
classement.

1. **Un avant/après**, le plus spectaculaire possible. C'est la seule que
   beaucoup regarderont.
2. La grille de styles, pour montrer le choix.
3. La carte holographique.
4. Le mode prompt libre, avec un exemple de demande et son rendu.
5. Un rendu de groupe, pour montrer que plusieurs visages sont gérés.

---

## Pour aller plus loin

- **Ajoute des localisations** (de, es, it, pt-BR) : chaque langue apporte son
  propre pool de 100 caractères de mots-clés indexés. C'est le levier le plus
  rentable une fois le lancement fait.
- **Le texte promotionnel se change sans review.** Sers-t'en pour annoncer un
  nouveau style sans repasser par la validation d'Apple.
- **Teste le sous-titre**, pas le nom. Le nom porte ta marque ; le sous-titre
  est l'endroit où expérimenter des intentions de recherche différentes.
