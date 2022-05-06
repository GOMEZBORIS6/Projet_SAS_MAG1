LIBNAME MALIB "C:\Users\gomez\OneDrive\Documents\Mescours Mag sem2\technique_d_enqueteTD\Projet";
run;

data MALIB.impactbase;
	set MALIB.impactbase;------------------------------------------------------
	if Repondants = 'Répondants' then delete; run;
proc contents  data= MALIB.impactbase; run;
/* encodage */
/*proc format;
;value $ impact_recode
			"0"="Non, pas du tout"
			"1"="Plutôt non"
			"2"="Oui, tout à fait"
			"3"="Plutôt oui"	
run;
proc freq data = MALIB.impactbase;
tables impact_contact_inexistants;*/
/*format impact_contact_inexistants $impact_recode.;*/ /* pour le format numérique on mets pas de $*/
/*run;*/

data MALIB.indiv;
set MALIB.impactbase;
impact = impact_contact_inexistants;
if impact_contact_inexistants = "Non, pas du tout" then impact =0;
else if impact_contact_inexistants="Plutôt non" then impact=1;
else if impact_contact_inexistants="Plutôt oui" then impact=2;
else if impact_contact_inexistants="Oui, tout à fait" then impact=3;

if missing(impact_contact_inexistants) then reponse = 1 ;
else reponse = 0 ;

if Boursier = "Normal" then statut = 0;
else if Boursier = "En attente" then statut = 1;
else if Boursier = "Boursier" then statut = 2;

if Nationalite_R = "FRANCAIS(E)" then nation = 0;
else if Nationalite_R = "ETRNAGER(E)" then nation = 1;

if Bac ="Professionnel" then Bac_a = 0;
else if Bac = "Technologique" then Bac_a =1;
else if Bac ="Général" then Bac_a =2;
else if Bac = "Autre" then Bac_a =3;

if Composante ="ALLSH" then compos =0;
else if Composante ="Sciences" then compos =1;

if Genre ="M" then sex =0;
else if Genre="F" then sex=1; 
run;
proc contents data= MALIB.indiv;run;
proc freq data= MALIB.indiv;
tables impact_contact_inexistants*impact /list; run;
/*l'ampleur de la non reponse partielle*/
proc freq data= MALIB.indiv;
tables impact / missing ;
run ;
/* Estimation a faire*/
/* recodage en variable indicatrice pour modelisation*/
data MALIB.echantillon;
set MALIB.indiv;
nonrep =reponse;

iimpact1=(impact=0);
iimpact2=(impact=1);
iimpact3=(impact=2);
iimpact4=(impact=3);

ibourse1=(statut=0);
ibourse2=(statut=1);
ibourse3=(regio=2);

ination1 = (nation=0);
ination2 = (nation=1);

iBac_a1 = (Bac_a = 0);
iBac_a2 = (Bac_a= 1);
iBac_a3 = (Bac_a = 2);
iBac_a4 = (Bac_a = 3);

icompos1 = (compos=0);
icompos2 = (compos=1);

isex1 = (sex=0);
isex2 = (sex=1);
run;
proc freq data= MALIB.echantillon;
tables nonrep;run;
proc means data=MALIB.echantillon;
var nonrep;
run;
/* on estime la probabilité de non répondre */
proc logistic data=MALIB.echantillon;
model nonrep= iimpact1 iimpact2 iimpact3 iimpact4 ibourse1 ibourse2
ibourse3 ination1 ination2 iBac_a1 iBac_a2 iBac_a3 iBac_a4 
icompos1 icompos2 isex1 isex2
/ link=probit;
run;
proc contents data= MALIB.echantillon;run;
proc corr data = MALIB.echantillon;
	Var nonrep ;
	with iimpact1 iimpact2 iimpact3 iimpact4; run;
/*Donc il y à la présence de biais car la non réponse est 
	correlé avec toutes les modalités de notre variable impact*/

/*Proposez une méthode de correction de la non réponse 
(repondération par calage sur marges, imputation déterministe par 
la régression, imputation aléatoire par hot deck).*/
/* l'approche par hypothèse sur le comportement de réponse */

proc surveyimpute data = MALIB.indiv method= hotdeck(selection= srswor)
seed=3200 ;
   var impact ;
   output out= MALIB.echantillonHD donorid;
run; 

data MALIB.echantillonfin;
set MALIB.echantillonHD;
nonrep =reponse;
iimpact1=(impact=0);
iimpact2=(impact=1);
iimpact3=(impact=2);
iimpact4=(impact=3);

run;
proc means data=MALIB.echantillonfin;
var nonrep iimpact1 iimpact2 iimpact3 iimpact4;
run;


