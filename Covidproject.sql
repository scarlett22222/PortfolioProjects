--a. Datewise likelihood of dying due to covid-Totalcases vs TotalDeath-in China
select date,total_cases,total_deaths from "CovidDeaths" where location like '%China%';
--b. Total % of deaths out of entire population in China 
select max(total_deaths)/avg(cast(population as integer))*100 from "CovidDeaths" where location like '%China%';
--c verify b by getting info separately
-- select total_deaths, population from "CovidDeaths" where location like '%China%'
--d. country with highest death as % of population
select location,(max(total_deaths))/avg(cast(population as bigint))*100 as percentage from "CovidDeaths" group by location order by percentage desc;
--e. total % of covid + ve case in China
select max(total_cases)/avg(cast(population as bigint))*100 as percentagepositive from "CovidDeaths" where location like '%China%';
--e. total % of covid + ve case in world
select location, max(total_cases)/avg(cast(population as bigint))*100 as percentagepositive from "CovidDeaths" group by location order by percentagepositive desc;
--g.continentwise+ve cases
select location, max(total_cases) as total_cases from "CovidDeaths" where continent is null group by location order by total_cases desc;
--h.continentwise deaths
select location, max(total_deaths) as total_deaths from "CovidDeaths" where continent is null group by location order by total_deaths desc;
--i.Daily newcases vs hospitalization vs icu_patients-China
select date, new_cases,hosp_patients,icu_patients from "CovidDeaths" where location like '%China%';
--j. countrywise age 65>
select "CovidDeaths".location,"CovidDeaths".date, "covidvaccinations_3".aged_65_older from "CovidDeaths" join "covidvaccinations_3" on "CovidDeaths".iso_code ="covidvaccinations_3".iso_code and "CovidDeaths".date ="covidvaccinations_3".date;
--k.countrywise total vaccinated persons
select "CovidDeaths".location as country,(max("covidvaccinations_3".people_fully_vaccinated)) as Fully_vaccinated from "CovidDeaths" join "covidvaccinations_3" on "CovidDeaths".iso_code ="covidvaccinations_3".iso_code and "CovidDeaths".date ="covidvaccinations_3".date where "CovidDeaths".continent is not null group by country order by Fully_vaccinated;
