---
layout: page
title: Politique de confidentialité
permalink: /fr/privacy/
lang: fr
page_key: privacy
description: "Comment Alike traite vos photos : analyse sur l'appareil, aucun envoi, aucune analyse d'usage, et une suppression qui n'a jamais lieu sans votre confirmation."
---

Dernière mise à jour : 5 août 2026

Alike est une app iOS qui trouve et regroupe les photos visuellement similaires de votre photothèque afin que vous puissiez les passer en revue et libérer de l'espace. Alike est exploitée par Oleksandr Solokha, développeur indépendant établi en Ukraine.

Cette politique de confidentialité explique ce qu'Alike collecte et ne collecte pas, où vivent vos données et quel contrôle vous avez dessus.

**En résumé : Alike n'a ni compte, ni connexion, ni serveur. Vos photos et tout ce qu'Alike en apprend restent sur votre appareil.**

## Contact

Pour l'assistance, les rapports de bugs, les questions de confidentialité ou les problèmes d'achat :

[oleksandr.solokha@gmail.com](mailto:oleksandr.solokha@gmail.com)

## Ce à quoi Alike accède

### Votre photothèque

Alike demande l'accès à la photothèque une seule fois, au début. Cet accès est nécessaire à l'unique finalité de l'app : comparer des photos pour trouver celles qui se ressemblent.

Vous pouvez accorder un accès complet, ou un accès limité et choisir les photos qu'Alike peut voir. Vous pouvez modifier ou révoquer ce choix à tout moment dans les Réglages iOS, sous Confidentialité et sécurité → Photos → Alike.

Alike lit les données d'image et les métadonnées qu'iOS fournit pour chaque élément, comme la date de création, la localisation approximative de prise de vue lorsqu'elle existe, la taille du fichier, et le fait qu'il s'agisse ou non d'une capture d'écran ou d'un favori. Ces informations servent à présélectionner les photos qui méritent une comparaison et à vous montrer le détail des groupes.

### Notifications

Alike ne demande l'autorisation de notification que si vous activez le rappel de nettoyage hebdomadaire dans les Réglages, et jamais autrement. Si vous n'activez jamais ce rappel, Alike ne demande jamais rien.

Si vous l'activez, le rappel est programmé localement sur votre appareil par iOS. Alike n'utilise pas de notifications push et ne s'enregistre ni ne reçoit aucun jeton de notification distante.

## Ce qu'Alike fait de vos photos

### L'analyse s'exécute entièrement sur votre appareil

Alike compare les photos avec le framework Vision d'Apple, qui s'exécute localement sur votre iPhone. Chaque photo est réduite à une empreinte numérique de caractéristiques, et les photos sont regroupées lorsque ces empreintes sont suffisamment proches selon le niveau de sensibilité que vous avez choisi.

**Vos photos ne sont jamais envoyées.** Aucune photo, vignette, empreinte de caractéristiques ni résultat d'analyse n'est transmis hors de votre appareil par Alike. Il n'existe aucun serveur Alike auquel les envoyer.

### Les résultats sont stockés localement

Alike met ses résultats en cache sur votre appareil au moyen de Core Data et de fichiers locaux, pour que vous n'ayez pas à relancer une analyse à chaque ouverture. Ce stockage local comprend des identifiants de photos, des empreintes de caractéristiques, l'appartenance aux groupes, des tailles estimées, votre progression et vos sélections, l'historique de nettoyage et vos préférences.

Tout cela réside dans l'espace de stockage cloisonné d'Alike sur votre appareil et se trouve inclus dans vos sauvegardes si vous sauvegardez votre appareil.

## Ce qu'Alike ne collecte pas

Alike ne contient aucune analyse d'usage, aucun rapport de plantage, aucune publicité et aucun pistage d'aucune sorte. En particulier, Alike ne fait pas ce qui suit :

- envoyer vos photos ou des données qui en sont dérivées ;
- collecter des statistiques ou des événements d'utilisation ;
- utiliser des identifiants publicitaires (IDFA) ou demander une autorisation de pistage ;
- constituer un profil vous concernant ;
- partager, vendre ou louer des informations personnelles, puisqu'elle n'en collecte aucune à partager ;
- utiliser des cookies ou des pixels espions.

Alike n'effectue aucune requête réseau de son propre fait. La seule activité sortante est gérée par Apple : les achats d'abonnement via StoreKit, et l'ouverture de liens App Store ou e-mail lorsque vous les touchez.

## Suppression de photos

La suppression est toujours votre décision et exige toujours une confirmation explicite.

Lorsque vous confirmez un nettoyage, Alike demande à iOS de supprimer les photos que vous avez sélectionnées. iOS affiche sa propre confirmation système avant que quoi que ce soit ne soit retiré. Les photos supprimées vont dans votre album **« Supprimés récemment »**, où iOS les conserve environ 30 jours et où vous pouvez les restaurer.

Alike ne supprime jamais de photos en silence, ne supprime jamais de photos que vous n'avez pas sélectionnées, et ne peut pas contourner la confirmation d'iOS.

## Abonnements et achats

Alike Pro est un abonnement à renouvellement automatique vendu par Apple. Les achats sont intégralement traités par Apple via StoreKit.

Alike ne reçoit d'Apple que ce qui lui est nécessaire pour débloquer les fonctionnalités payantes et restaurer les achats : votre statut de droits, l'identifiant produit de votre formule et l'état de la transaction. **Alike ne reçoit jamais les données de votre carte de paiement, votre adresse de facturation ni vos identifiants de compte Apple.**

Le traitement de vos informations d'achat par Apple est régi par [la politique de confidentialité d'Apple](https://www.apple.com/legal/privacy/). Les abonnements, les résiliations et les remboursements sont gérés via Apple et l'App Store.

## Vos contrôles

| Ce que vous voulez | Comment faire |
| --- | --- |
| Modifier ou limiter l'accès aux photos | Réglages iOS → Confidentialité et sécurité → Photos → Alike |
| Arrêter les notifications | Désactiver le rappel de nettoyage hebdomadaire dans les réglages d'Alike, ou Réglages iOS → Notifications |
| Effacer tout ce qu'Alike stocke | Réglages d'Alike → Données et confidentialité → Supprimer les données d'Alike |
| Supprimer complètement toutes les données | Supprimer l'app Alike de votre appareil |

### Supprimer les données d'Alike

Réglages → Données et confidentialité → **Supprimer les données d'Alike** efface tout ce qu'Alike a stocké sur votre appareil : résultats d'analyse et caches, progression et historique de nettoyage, et vos préférences Alike. Cette action est irréversible.

Elle ne touche **pas** vos photos, votre album « Supprimés récemment », votre autorisation d'accès aux photos ni votre abonnement Alike Pro. Après la suppression, Alike affiche de nouveau son introduction sans redemander l'accès aux photos.

Supprimer l'app retire avec elle toutes les données locales d'Alike.

## Base légale et vos droits

Comme Alike ne collecte ni ne transmet de données personnelles, le développeur ne détient aucune donnée personnelle à consulter, rectifier, exporter ou effacer, et aucune donnée n'est traitée sur une base légale telle que le consentement ou l'intérêt légitime.

Tout le traitement a lieu localement sur votre appareil, sous votre contrôle, et vous pouvez l'effacer vous-même à tout moment via « Supprimer les données d'Alike » ou en supprimant l'app.

Si vous vous trouvez dans l'UE, au Royaume-Uni, en Ukraine, en Californie ou dans une autre région reconnaissant des droits en matière de protection des données, ces droits s'appliquent toujours — il n'existe simplement aucun jeu de données côté serveur sur lequel les exercer. Si vous pensez le contraire, écrivez-nous à l'adresse ci-dessus et nous vous répondrons.

## Enfants

Alike ne s'adresse pas aux enfants de moins de 13 ans et ne collecte pas sciemment d'informations les concernant. L'app n'a ni système de compte, ni contenu généré par les utilisateurs, ni fonctionnalité de communication.

## Modifications de cette politique

Si cette politique change, la version mise à jour sera publiée sur cette page avec une nouvelle date de « Dernière mise à jour ». Les changements substantiels affectant la façon dont l'app traite vos données seront également signalés dans les notes de version de l'App Store.

## Droit applicable

Cette politique de confidentialité est régie par le droit ukrainien, sans préjudice des droits impératifs de protection des données dont vous disposez en tant que consommateur selon le droit de votre pays de résidence.
