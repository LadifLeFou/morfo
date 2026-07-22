"""Crée l'essai gratuit de 3 jours sur tous les territoires.

Apple exige une offre d'introduction **par territoire** : il n'existe pas de
réglage global. Sans essai, le paywall affiche « Continue » au lieu de
« Start my 3 free days » — le principal levier de conversion disparaît.

Idempotent : un territoire déjà couvert est ignoré, on peut relancer sans
risque après une coupure.

Lancer : .venv-asc/bin/python tools/asc_essais.py
"""

import sys
import time
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parent))

from asc import appel, get  # noqa: E402

ABONNEMENTS = {"6793321113": "weekly", "6793321196": "annual"}
DUREE = "THREE_DAYS"


def _avec_reprises(fn, *a, tentatives: int = 4, **kw):
    """Réessaie sur coupure réseau.

    Sur 350 requêtes, un timeout finit toujours par arriver : sans cela une
    seule coupure interrompt tout le déploiement.
    """
    for essai in range(tentatives):
        try:
            return fn(*a, **kw)
        except (requests.exceptions.ConnectionError,
                requests.exceptions.Timeout):
            if essai == tentatives - 1:
                raise
            time.sleep(2 ** essai)


def _territoires() -> list:
    url, tous = "/territories?limit=200", []
    while url:
        d = get(url)
        tous += [t["id"] for t in d["data"]]
        url = (d.get("links") or {}).get("next")
    return tous


def _deja_couverts(sub_id: str) -> set:
    url = f"/subscriptions/{sub_id}/introductoryOffers?include=territory&limit=200"
    couverts = set()
    while url:
        d = get(url)
        for inc in d.get("included", []):
            if inc["type"] == "territories":
                couverts.add(inc["id"])
        url = (d.get("links") or {}).get("next")
    return couverts


def main() -> None:
    territoires = _territoires()
    print(f"{len(territoires)} territoires\n")

    for sub_id, nom in ABONNEMENTS.items():
        couverts = _deja_couverts(sub_id)
        manquants = [t for t in territoires if t not in couverts]
        print(f"{nom} : {len(couverts)} déjà couverts, {len(manquants)} à créer")

        ok, echecs = 0, []
        for terr in manquants:
            r = _avec_reprises(
                appel, "POST", "/subscriptionIntroductoryOffers",
                      json={"data": {
                          "type": "subscriptionIntroductoryOffers",
                          "attributes": {"duration": DUREE,
                                         "offerMode": "FREE_TRIAL",
                                         "numberOfPeriods": 1},
                          "relationships": {
                              "subscription": {"data": {"type": "subscriptions",
                                                        "id": sub_id}},
                              "territory": {"data": {"type": "territories",
                                                     "id": terr}}}}},
                headers={"Content-Type": "application/json"})
            if r.status_code < 300:
                ok += 1
                if ok % 25 == 0:
                    print(f"    {ok}/{len(manquants)}…", flush=True)
            else:
                echecs.append((terr, r.status_code))

        print(f"  {ok} créés")
        if echecs:
            print(f"  {len(echecs)} échecs : {echecs[:5]}")
        print(f"  total couvert : {len(_deja_couverts(sub_id))}/{len(territoires)}\n")


if __name__ == "__main__":
    main()
