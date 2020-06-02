LIBNAME KatiMehr "C:\Users\Rayan\Desktop\Kati\Data Science\SAS Project";


PROC IMPORT OUT= WORK.Happiness 
            DATAFILE= "C:\Users\Rayan\Desktop\Kati\Data Science\SAS Proj
ect\My Project\happinessAll.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

ODS PDF FILE='C:\Users\Rayan\Desktop\Kati\Data Science\SAS Project\Happiness_Result.pdf';
PROC CONTENTS DATA = Happiness;
RUN;


TITLE 'Histogram of Happiness score in 2019';
PROC SGPLOT DATA = Happiness;
	HISTOGRAM happiness_score;
	DENSITY happiness_score;
    DENSITY happiness_score / TYPE=kernel;
    keylegend / location=inside position=topright;
	WHERE Year = 2019;
RUN;
TITLE;

PROC MEANS DATA = Happiness MIN MAX MEAN MEDIAN MODE;
VAR happiness_score;
WHERE Year = 2015;
RUN;

PROC MEANS DATA = Happiness MIN MAX MEAN MEDIAN MODE;
VAR happiness_score;
WHERE Year = 2019;
RUN;

PROC MEANS DATA = Happiness MIN MAX MEAN MEDIAN MODE STD;
VAR happiness_score;
RUN;


TITLE 'Vertical Box Plot of Happiness score for 2015 to 2019';
PROC SGPLOT DATA = Happiness;
VBOX happiness_score / GROUP = Year;
RUN;
TITLE;


TITLE 'Scatter plot population and Happiness score in 2019';
PROC SGPLOT DATA = Happiness;
	SCATTER X=population Y=happiness_score;
	WHERE Year = 2019;
RUN;
TITLE;

TITLE "Pie Chart of Region Distribution";
PROC GCHART DATA = Happiness;
 PIE Region;
 WHERE Year = 2019;
RUN;
TITLE;

TITLE "Bar Chart of Region Distribution";
PROC GCHART DATA = Happiness;
 VBAR Region;
RUN;
TITLE;

TITLE "Bar Chart of Region Distribution";
PROC SGPLOT DATA = Happiness;
	VBAR Region / RESPONSE = happiness_score STAT=mean
    CATEGORYORDER=RespAsc FILLATTRS=(COLOR=Orange);
RUN;
TITLE;

PROC MEANS DATA = Happiness MEAN MAXDEC=2;
VAR happiness_score;
CLASS Region;
RUN;

PROC SQL;
  SELECT Region, MEAN(happiness_score) as Mean_H
    FROM Happiness
      GROUP BY Region
        ORDER BY Mean_H descending
  ;
QUIT;


PROC SQL;
  SELECT Year, Region, MEAN(happiness_score) as Mean_H
    FROM Happiness
      GROUP BY Year, Region
        ORDER BY Region, Year, Mean_H descending
  ;
QUIT;


TITLE "Change in happiness score between 2015-2019 in different Regions";
PROC SGPLOT DATA = Happiness;
VLINE Year / RESPONSE = happiness_score STAT=mean GROUP = Region;
RUN;
TITLE;


PROC ANOVA DATA = Happiness;
 CLASS Region;
 MODEL happiness_score = Region;
 MEANS Region/Scheffe;
 WHERE Year = 2019;
 TITLE "Hapinness_score based on Region in 2019";
RUN;
TITLE;


PROC CORR DATA = Happiness PEARSON PLOTS = (SCATTER MATRIX);
VAR Economy	Social_Support Health Life_Expectancy Freedom;
WITH Trust Generosity;
WHERE Year = 2017;
RUN;



PROC CORR DATA = Happiness PEARSON;
VAR Area Population; 
WITH Density;
WHERE Year = 2019;
RUN;


PROC FORMAT;
VALUE RegionF
1 = 'Australia and New Zealand'
2 = 'Central and Eastern Europe'
3 = 'Eastern Asia'
4 = 'Latin America and Caribbean'
5 = 'Middle East and Northern Africa'
6 = 'North America'
7 = 'Southeastern Asia'
8 = 'Southern Asia'
9 = 'Sub-Saharan Africa'
10 = 'Western Europe'
;
RUN;

PROC FORMAT;
VALUE HappinessF
0-4 = 'Low'
4-7 = 'Medium'
7-10 = 'High'
;
RUN;


PROC FREQ DATA = Happiness;
FORMAT happiness_score HappinessF.;
TABLE Region * happiness_score / MISSING CHISQ;
WHERE Year = 2019;
RUN;


PROC UNIVARIATE DATA = Happiness;
VAR Population Economy Social_Support Health Life_Expectancy Freedom Trust Generosity;
WHERE Year = 2019;
HISTOGRAM;
RUN; 

PROC MEANS DATA = Happiness;
 VAR Trust;
 CLASS Country;
RUN;


PROC SQL;
SELECT Country, MEAN(Trust) AS Avg_Trust, MEAN(Life_Expectancy) AS Avg_Life
	FROM Happiness
		GROUP BY Country
			ORDER BY Avg_Trust DESCENDING
			;
QUIT;

PROC MEANS DATA = Happiness;
 VAR Life_Expectancy;
 BY Region;
RUN;

/* Dealing with missing values */

PROC MEANS DATA = Happiness N NMISS MEAN MAX MIN MEDIAN MODE P1 P25 P75 QRANGE MAXDEC=2;
VAR Trust Life_Expectancy;
WHERE Year = 2015;
RUN;



PROC SQL;
CREATE TABLE HappinessSQL AS
SELECT * , COALESCE (TRUST , 0.14) AS TRUST_N
FROM Happiness
;
QUIT;

PROC MEANS DATA = HappinessSQL N NMISS MEAN MAX MIN MEDIAN MODE;
VAR TRUST_N;
RUN;

/*
2019 - 73.06
2018 - 72.96
2017 - 72.76
2016 - 72.83
2015 - 72.27
*/


DATA Happiness_Life;
SET HappinessSQL;
IF (Life_Expectancy EQ . & Year = 2019) THEN LE_N = 73.06;
ELSE IF (Life_Expectancy EQ . & Year = 2018) THEN LE_N = 72.96;
ELSE IF (Life_Expectancy EQ . & Year = 2017) THEN LE_N = 72.76;
ELSE IF (Life_Expectancy EQ . & Year = 2016) THEN LE_N = 72.83;
ELSE IF (Life_Expectancy EQ . & Year = 2015) THEN LE_N = 72.27;
ELSE LE_N = Life_Expectancy;
RUN;

DATA Happiness_NMiss;
SET Happiness_Life;
IF Density EQ . THEN Density_N = Population/Area;
ELSE Density_N = Density;
RUN;



PROC MEANS DATA = Happiness_NMiss N NMISS MEAN MAX MIN MAXDEC=2;
VAR Life_Expectancy LE_N Trust Trust_N Density Density_N;
RUN;


DATA Happiness_Country;
SET Happiness;
IF Country = 'Afghanistan' & Year = 2019) THEN Trust = Mean(Trust);

PROC MEANS DATA = Happiness;
VAR Trust;
WHERE Country = 'Afghanistan';
RUN;

/*
%MACRO Trust_Rep(Country= , Year=);
DATA Happiness_Life;
SET Happiness;
IF (Country = &Coountry & Year = 2019) THEN Trust = Mean(Trust);

%MEND;
*/

PROC FREQ DATA = HappinessSQL;
TABLE _CHARACTER_ /MISSING;
RUN;


PROC ANOVA DATA = Happiness_NMISS;
 CLASS Year Region;
 MODEL happiness_score = Year Region Year*Region;
 MEANS Year/Scheffe;
 TITLE "Hapinness_score based on Years and Region";
RUN;
TITLE;

PROC REG DATA = Happiness_NMISS;
TITLE "Linear regression model on Happiness score";
MODEL Happiness_score = Area Density Economy Social_Support Health Freedom Trust Generosity;
RUN;

PROC CORR DATA = Happiness_NMISS;
VAR Happiness_score; 
WITH Year;
WHERE Region = 'Southern Asia';
RUN;


/*
1 = 'Australia and New Zealand'
2 = 'Central and Eastern Europe'
3 = 'Eastern Asia'
4 = 'Latin America and Caribbean'
5 = 'Middle East and Northern Africa'
6 = 'North America'
7 = 'Southeastern Asia'
8 = 'Southern Asia'
9 = 'Sub-Saharan Africa'
10 = 'Western Europe'
*/

ODS PDF CLOSE;
