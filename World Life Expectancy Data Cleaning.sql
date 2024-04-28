-- Utilisation de la base de données world_life_expectancy
USE world_life_expectancy;

-- Affichage de toutes les données de la table world_life_expectancy
SELECT * FROM world_life_expectancy.world_life_expectancy;

-- Identification des doublons en concaténant les colonnes Country et Year
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Suppression des doublons identifiés précédemment
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

-- Mise à jour du statut à 'Developing' pour les lignes où le statut est manquant
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1. Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

-- Mise à jour du statut à 'Developed' pour les lignes où le statut est manquant et le pays est 'United States of America'
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1. Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

-- Mise à jour de l'espérance de vie en utilisant la moyenne de l'espérance de vie de l'année précédente et de l'année suivante pour le même pays
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';