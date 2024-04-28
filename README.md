# Présentation de l'étude de cas : Nettoyage des données de l'espérance de vie mondiale
Dans cette étude de cas, nous avons travaillé sur la base de données __world_life_expectancy__ qui contient des informations sur l'espérance de vie dans différents pays à travers les années. Notre objectif principal était d'identifier et de nettoyer les données en double et de compléter les données manquantes. Cette étape de nettoyage des données est cruciale avant de pouvoir effectuer toute analyse ou modélisation, car la qualité des données d'entrée a un impact direct sur la qualité des résultats obtenus.

## Commentaires sur le code et explications

1. Nous avons commencé par identifier les doublons dans notre base de données. Pour ce faire, nous avons concaténé les colonnes __Country__ et __Year__ et compté le nombre de fois que chaque combinaison apparaît. Les combinaisons qui apparaissent plus d'une fois sont considérées comme des doublons.
```sql
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;
```

2. Après avoir identifié les doublons, nous avons supprimé les lignes en double en se basant sur les colonnes __Country__ et __Year__. Nous avons utilisé la fonction __ROW_NUMBER()__ pour attribuer un numéro unique à chaque ligne pour chaque combinaison unique de __Country__ et __Year__.
```sql
DELETE FROM world_life_expectancy
WHERE 
    Row_ID IN (
    SELECT Row_ID
FROM (
    SELECT Row_ID,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
    ) AS Row_table
WHERE Row_num > 1
);
```

3. Ensuite, nous avons identifié les lignes où le statut est manquant. Nous avons mis à jour ces lignes en attribuant le statut _'Developing'_ si le même pays a ce statut dans une autre ligne.
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1. Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';
```

4. Pour le pays _'United States of America'_ qui restait sans statut, nous avons attribué le statut _'Developed'_.
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1. Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';
```

5. Enfin, nous avons ajouté des données pour la colonne __Life expectancy__ lorsque celle-ci était vide. Nous avons utilisé la moyenne de l'espérance de vie de l'année précédente et de l'année suivante pour le même pays.
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';
```
