# upslide-case

Pour diagnostiquer la sous-performance Q1 2026, j'ai structuré l'analyse autour de 4 dimensions clés de performance :
1. Métriques de Volume
- Mesure la quantité d'opportunités générées
- Total d'opportunités closes
- Nombre de deals Won vs Lost
Diagnostic : Générons-nous assez de pipeline ?

2. Métriques de Conversion
- Mesure l'efficacité de conversion des opportunités en ventes
- Win Rate (%)
- Win Rate par segment (source, type)
Diagnostic : Closons-nous efficacement ?

3. Métriques de Vélocité
- Mesure la vitesse du processus de vente
- Cycle de vente moyen (Won vs Lost)
- Distribution des durées de cycle
Diagnostic : Les deals avancent-ils assez rapidement ?

4. Métriques de Valeur
- Mesure la taille des deals
- Taille moyenne de deal
- ARR total
Diagnostic : Ciblons-nous les bonnes tailles de deals ?

Pourquoi c'est important : Un commercial peut sous-performer à cause d'un faible volume (pas assez d'oppos), d'une mauvaise conversion (win rate faible), d'une vélocité lente (cycles longs), ou de deals trop petits. Chaque problème nécessite une solution différente.


## Ce que je n'ai pas eu le temps de faire / améliorer : 

Pour la partie data eng : créer table externe avec définition du type (ex VARCHAR etc) pour meilleur définition du stockage.
J'ai du exporter en csv pour brancher mon PBI aux datamarts de la couche gold

Evidemment la partie test pour vérifier les jointures et la cohérence et complétude des données entre les différentes couches

Analyser beaucoup plus en profondeur le détails des sales person pour identifier les problèmes si'ls sont géographiques ou individuel.
Croiser également la performance de closing entre les zones géographiques et le type / source des opportunités

Quel canal marche t il mieux que les autres ? pourquoi ? 

Identifier les zones / personnes qui mettent le plus de temps à closer une opportunités (qu'elle soit gagnée ou perdue)