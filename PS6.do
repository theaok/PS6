*______________________________________________________________________
*Data Management in Stata
*Kate Cruz, Fall 2017
*Problem Set 5 due: November 28 
*Stata Version 15/IC 


/* For Problem Set 5 I began to work on my final project by organizing and simpliying my exisiting work. 
I also began to see a clearer picture about the impact of environment (food access, poverty) on health in NJ emerge through descriptive statistics. 
______________________________________________________________________

Research questions include the following: 
1- Does inaccces to healthy food impact behavior and mental health?
2- Does increased green space decrease poverty and mental health ?
3- Who is most impacted by pollution (by race, gender, income)? 
4- Do counties with higher pollution experience worse health outcomes (physical and mental)? 
______________________________________________________________________

My completed dataset includes data from the following sources: 
1- NJ County Health Rankings Data (http://www.countyhealthrankings.org/rankings/data/nj)
2- New Jersey Behavioral Risk Factor Survey, Center for Health Statistics, New Jersey Department of Health Statistics, New Jersey State Health Assessment Data (NJSHAD) (http://nj.gov/health/shad) 
3- U.S. Census Bureau, 2016 American Community Survey 1-Year Estimates
4- Center for Disease Control and Prevention. Environmental Public Health Tracking Network. Acute Toxic Substance Releases (www.cdc.gov/ephtracking) note: I would love to have data from 2015 since most of my other datasets are from this year but this was the most recent I could find. This would be good to research further. 
5- EPA Outdoor Air Quality Report (https://www.epa.gov/outdoor-air-quality-data/air-quality-statistics-report)
6- Food Access and Research Center (FARC) and it is County SNAP (food stamp) usage from 2011-2015 and simply shows the use of the Supplemental Nutrition Assistance Program. 
7- U.S. Census Bureau population counts by County for 2010-2016 (https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk) 

Note: Regions are defined as North, Central and South as defined by the State of New Jersey http://www.state.nj.us/transportation/about/directory/images/regionmapc150.gif
*/ 

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                
								
								        1
										
								CLEANING DATASETS  
				   Loop, Drop, rename, Keep, Destring, Generate, Replace
			 
								
								
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/ 
local worDir "/tmp/"
capture mkdir ps6
cd ps6

//-----------------------------------------------------------------------------

//PART 1: NJ County Health Rankings Data 

//Programming a Global Macro for Uploading Data
cap program drop kateGoogle
program define kateGoogle
global gooPre 
global gooSuf 
local goohealth= "https://docs.google.com/uc?id=" + "`1'" + "&export=download"
import excel "`goohealth'" ,clear 
end

kateGoogle "0B1opnkI-LLCiZFZKbzhlOFN4Sm8"

//Drop 
drop D H L P W AA AE AR BF BK CA CF CK CL CT DC DM DC EG EM ER E I M Q S X AB AK AL AF AX AQ AW BF BG BK BL CA CB CF CG CK CM CT CU DC DD DM DN DX DY EG EH EM EN ER ES Y AU AY BH CZ EO AZ-BB BV BW BX CE-CH CJ EA EB EJ-EL EP EQ ET
drop in 1/2

//Rename 
rename (A-AO) (County deaths yearslost zyearslost perfairpoorhealth zfairpoor puhdays zpuhdays muhdays zmuhdays lowbirth livebirth perlowbirth persmoke zsmoke perobese zobese foodindex zfood perinactive zinactive perwaccess zwaccess)
rename (AP-BZ) (perdrink zdrink aldrivedeath peraldrivedeath teenbirth teenpop teenbirthrate uninsured peruninsured zuninsured PCP PCPrate zPCP dentist dentistrate zdentist MHproviders MHPrate medicaidenrolled prevhosprate)
rename (CC-DG) (zprevhosprate diabetics zmedicareenrolled cohortsize gradrate zgradrate somecollege population persomecollege zsomecollege unemployed laborforce perunemployed childpov perchildpov zchildpov eightyincome twentyincome)
rename (DH-EI) (incomeratio zincome singleparent households persingleparent zhouseholds associations associationrate zassociations violentcrimerate zviolentcrime violentcrime injurydeath injurydeathrate zinjurydeath violation zviolation severeproblems persevereproblems zsevereproblems)  

//Recode & Create Program //Separated each county into region and created a program to use throughout datasets 
cap program drop kate1
program define kate1
//Recode- region variables 
generate region=0
//region==0 means north region==1 means south 
replace region=1 if County=="Burlington" | County=="Camden" | County=="Gloucester" | County=="Salem" | County=="Cumberland" | County=="Atlantic" | County=="Cape May" 
//region==2 means central
replace region=2 if County=="Hunterdon" | County=="Somerset" | County=="Middlesex" | County=="Monmouth" | County=="Ocean" | County=="Mercer" 
recode region (0/1=0 Non-Central) (1.1/2=1 Central), gen(region_2) //this allowed me to create a new level of comaprison looking at Central NJ in particular 
end
kate1 
drop in 22/23 

//Destring 
destring *, replace 

//violations for regressions- because violations would not destring because the obersvations were "yes" and "no" I created a new variable and assigned numeric values 
generate violations_r=0
replace violations_r=1 if violation=="Yes"
move violations_r violation
save health, replace 

//------------------------------------------------------------------------------

//PART 2: NJ Behavioral Health Risk Factor Survey  
//Loop 
kateGoogle "0B1opnkI-LLCiWk1BYUc3R3FFWkE"

//Rename 
rename (A-E) (County Countyid responses samplesize perstressdays)  

//Drop
drop F G 
drop Countyid
drop in 1/11 
drop in 22/66 

//Destring
destring responses, gen(responses_n)
destring samplesize, gen(samplesize_n)
destring perstressdays, gen(perstressdays_n) 

//Recode
kate1  

save behealth, replace 
//------------------------------------------------------------------------------

//PART 3: 2016 U.S. Census American Community Survey 1-Year Estimates 
//Loop 
kateGoogle "0B1opnkI-LLCiZHRMT3BWNEZjNW8"

//Keep
keep C D H J L N P R T V AR AJ AB AN AP CB CD EN EP GZ HB IH IF JF LD LF QB QD QF QH QN QP RD RF RL RN 

//Rename
rename (C-AB)(County households families perfamilies familieswchildren perfamilieswchildren marcouplefam permarcouplefam marcouplewchildren permarcouplewchildren singledad) 
rename (AJ-LD) (singlemom nonfamily pernonfamily livealone children perchildren givebirthpastyr pergivebirthpastyr inschool perinschool nodiploma pernodiploma perhsabove samehouse)
rename (LF-RN) (persamehouse englishonly perenglishonly notenglish pernotenglish spanish perspanish api perapi otherlang perotherlang) 

//Replace 
foreach c in "Atlantic" "Bergen" "Burlington" "Camden" "Cape May" "Cumberland" "Essex" "Gloucester" "Hudson" "Hunterdon" "Mercer" "Middlesex" "Monmouth" "Morris" "Ocean" "Passaic" "Salem" "Somerset" "Sussex" "Union" "Warren" {
replace County = "`c'"  if County == "`c' County, New Jersey"
}
//Drop
drop in 1/4

//Destring
destring households families perfamilies familieswchildren perfamilieswchildren marcouplefam permarcouplefam marcouplewchildren permarcouplewchildren livealone singlemom singledad nonfamily, replace 
destring pernonfamily children perchildren givebirthpastyr pergivebirthpastyr inschool perinschool nodiploma pernodiploma perhsabove samehouse persamehouse englishonly perenglishonly, replace 
destring notenglish pernotenglish spanish perspanish api perapi otherlang perotherlang, replace 

//Recode
kate1
save census16, replace 

//------------------------------------------------------------------------------

//PART 4: Center for Disease Control and Prevention: Acute Toxic Substance Releases 
//Loop 
kateGoogle "0B1opnkI-LLCianducmRLbl84dzQ"

//Drop
drop A B C E G 

//Rename 
rename (D-F) (County Value) 

//Recode
kate1 

save toxic, replace 
//------------------------------------------------------------------------------
 
//PART 5: EPA Outdoor Air Quality Report
//Programming a Global Macro for Uploading Data with First Row Clear 
cap program drop kateGoogleFR
program define kateGoogleFR 
global gooPre 
global gooSuf 
local goohealth= "https://docs.google.com/uc?id=" + "`1'" + "&export=download"
import excel "`goohealth'" , firstrow clear 
end

kateGoogleFR "0B1opnkI-LLCic1lHUUxUZHhvZGs"

//Drop
drop CountyCode  

//Replace 
foreach c in "Atlantic" "Bergen" "Burlington" "Camden" "Cape May" "Cumberland" "Essex" "Gloucester" "Hudson" "Hunterdon" "Mercer" "Middlesex" "Monmouth" "Morris" "Ocean" "Passaic" "Salem" "Somerset" "Sussex" "Union" "Warren" {
replace County = "`c'"  if County == "`c' County, NJ"
}

//Recode
kate1 
move region County 

save EPAair, replace 
//------------------------------------------------------------------------------

//PART 6: Food Access and Research Center: SNAP Usage 
//Loop
kateGoogleFR "0B1opnkI-LLCicWZRS3c2MFhianM"

//Replace 
foreach c in "Atlantic" "Bergen" "Burlington" "Camden" "Cape May" "Cumberland" "Essex" "Gloucester" "Hudson" "Hunterdon" "Mercer" "Middlesex" "Monmouth" "Morris" "Ocean" "Passaic" "Salem" "Somerset" "Sussex" "Union" "Warren" {
replace County = "`c'"  if County == "`c' County"
}

//Drop 
drop State MetroSmallTownRuralStatus PercentMarginofError

//Recode
kate1
move region County 

save SNAP, replace 

//------------------------------------------------------------------------------

//PART 7: U.S. Census Bureau population counts by County for 2010-2016
//Loop 
kateGoogleFR "0B1opnkI-LLCiV2tGMjhfTTZjWkE"
 
//Drop
drop GEOid GEOid2 rescen42010 resbase42010 
drop in 1/1

//Rename
rename GEOdisplaylabel County

//Replace 
foreach c in "Atlantic" "Bergen" "Burlington" "Camden" "Cape May" "Cumberland" "Essex" "Gloucester" "Hudson" "Hunterdon" "Mercer" "Middlesex" "Monmouth" "Morris" "Ocean" "Passaic" "Salem" "Somerset" "Sussex" "Union" "Warren" {
replace County = "`c'"  if County == "`c' County, New Jersey"
}

//Recode
kate1
move region County 

save census2010, replace 
//------------------------------------------------------------------------------
 

 
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                              
							      2
								 
							   MERGING  
							  
							  
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/ 
use health
merge 1:1 County using behealth
save kate_ps6, replace 

use kate_ps6
drop _merge 
merge 1:1 County using census16
save kate_ps6, replace 

use kate_ps6 
drop _merge
merge 1:1 County using toxic
save kate_ps6, replace 

use kate_ps6
drop _merge
merge 1:1 County using EPAair
drop in 6 
//the merge creates a new County observation that throws off the data so I deleted it 
save kate_ps6, replace 
//note: EPA air quality data is only for 17 counties, therefore 5 do not match 

use kate_ps6
drop _merge 
merge 1:1 County using SNAP
save kate_ps6, replace 

use kate_ps6
drop _merge
merge 1:1 County using census2010
save merged, replace 
//------------------------------------------------------------------------------


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                                     3
							Descriptive Statistics  
                          Egen, Collapse, Macro, Loop   
								   
								   
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/ 
//Egen
use merged 

egen unhealthy=rowmean(muhdays puhdays) //I combined mental and physical health to create a measurement of overall poor health or "unhealthy" based on the means pulled by this code I see that Atlantic, Hudson, Ocean and Salem have the poorest overall health (with Camden following right behind) 
move unhealthy deaths 

egen av_deaths=mean(deaths), by(region) // this code produced the mean number of deaths for each region and shows that Central NJ has the largest average of deaths 
move av_deaths deaths 

egen singlemomdad=rowmean(singledad singlemom) //combining the count of single mom and single dads from the 2016 census 
move singlemomdad deaths 

bys region: egen avgStress=mean(perstressdays_n) //shows the average percentage of stressful days per county. South Jersey has the highest average (15%), Central Jersey (10%) and North (9%) 
move avgStress deaths 

save clean, replace 

//Collapse 
collapse childpov, by(region) //North Jersey has the largest population of children in poverty(20,441) followed by Central (13,627)and South Jersey (9,824)
clear
use clean 
collapse perchildpov, by(region) //When accounting for population size South Jersey has the highest rate of child poverty (18.7%), North Jersey with 15.7 and Central with 11.8 
clear 
use clean
collapse muhdays, by(region) //There is not a lot of variation, however South Jersey (1) has the highest rate of mentally unhealthy days at 3.6% while North Jersey (0)has 3.3 and Central (2) is 3.2 
clear
use clean
collapse PercentwithSNAP, by(region) //South Jersey (1) has the highest percent of food stamp usage (.1%) followed by North (.09)and then Central (.05).  
clear
use clean
collapse unhealthy, by(region) // North Jersey has by far the largest number of single parents (8,267) while Central has 5,643 and South has 4,588 this could be due to population size
clear 

//Loops
use clean, clear  
foreach v of varlist perchildpov nodiploma persevereproblems violentcrime muhdays puhdays{
 ta `v', p
}
/*I learned that the most common percentage of physically unhealthy days was 3.7 and 2.9
Similarly I found that mentally unhealthy days were most commonly reported at 3.2, 3.6 and 3.7 days 
19 percent was the most common for severe housing problems and 11% for child poverty*/  
 
//Scatterplots 
 //scatterplot graph of health and food access by County
foreach v of varlist foodindex {

  scatter `v' perfairpoorhe, mlab(County)
 
gr export `v'.pdf
}
//what we see is a correlation between access to healthy food and health- the higher the food access the lower the level of poor health 

//to better understand the relationship between food access and mentally unhealthy days 
foreach v of varlist foodindex {

scatter `v' unhealthy, mlab(County)

gr export `v'.pdf 
}
//the better access to food, the less mentally unhealthy days 

foreach v of varlist foodindex {

scatter `v' avgStress, mlab(County)

gr export `v'.pdf
}
//there does seem to be some correlation between stress level and access to food - high stress areas also have low food index scores 

//Bar Graphs 
//bar graph of the percentage of poor and fair health by County- this makes it very easy to compare quickly  
hist perfairpoorhe, freq
gr hbar perfairpoorhe, over(County, sort(perfairpoorhe))
//Hudson has the poorest reported levels of health with Cumberland following right behind 

//bar graph of the percentage of obesity by County 
hist perobese, freq
gr hbar perobese, over(County, sort(perobese)) 
//the highest rate of obesity is Cumberland County. I am seeing a pattern that Cumberland County scores very low in health rankings and has many social issues. 

hist avgStress, freq
gr hbar avgStress, over(County, sort(avgStress)) 
//helpful for displaying stress levels in order of lowest to highest: South being highest, Central and then North  

//-----------------------------------------------------------------------------

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                                4
								
                       GRAPHS & REGRESSIONS 
						 outreg2, estout 
								   
								   
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/ 

twoway (scatter foodindex yearslost), ytitle(Loss of Life (in years)) xtitle(Food Index (Access to Healthy Food)) title(Food Access and Loss of Life) //as access to food increases, life expectancy increases 
graph save lossoflife, replace 

twoway (scatter perlowbirth foodindex), ytitle(Percentage of Low Birth Rates) xtitle(Food Index (Access to Healthy Food)) title(Healthy Food Access and Low Birth Rates) //higher percetange of low birth rates in areas with lower food access 
graph save lowbirth, replace 

graph bar avgStress, over(region)
graph save stress, replace 

twoway (scatter perobese PercentwithSNAP), ytitle(Percentage of Obesity) xtitle(SNAP Use (percentage)) title(Obesity and Poverty) subtitle(SNAP Usage and Rates of Obesity) //not sure if this is a great correlation but it does seem to me that rates of obesity are higher with higher SNAP usage
graph save obeseSNAP, replace 

twoway (scatter yearslost perobese), ytitle(Obesitty (percentage)) xtitle(Years of Life Lost) title(Obesity and Loss of Life) //clear correlation between obesity and loss of life, because SNAP beneficiaries are also more likely to be obese, they are at risk of greater loss of life as well. 
graph save obeseyearslost, replace  

graph hbar foodindex unhealthy, over(County, sort(unhealthy)) //Cape May and Passaic Counties are outliers in the sense that they have moderate levels of unhealthy but low food access, otherwise it is clear that in areas of low food access, health declines 
graph save countyunhealthFI, replace 

/* Correlations & Regressions 
DV: health, obesity, stress, poverty, race, gender 
IV:food access
*/

corr foodindex  unhealthy 
/* Results show a strong, negative correlation. As healthy food access increases
days of poor physical and mental health decreases */ 

reg  unhealthy foodindex
outreg2 using reg1.xls,  bdec(2) st(coef) excel replace ct(A1)  lab
/* Results show that for every increase in healthy food access there is a .4 decrease in
days of mental or physical illness per month. */

reg  unhealthy foodindex PercentwithSNAP  
outreg2 using reg1.xls,  bdec(2) st(coef) excel append ct(A2)  lab
/*Results show that helathy food access alone does not determine health. When taking SNAP 
usage or poverty into account, for each increase in food access there is a decrease 
of only .2 in mental/physically unhealthy days per month. For each increase in 
the percentage of SNAP usage, there is an increase of 4 physically and mentally
unhealthy days per month holding all over variables constant. */ 	

corr foodindex PercentwithSNAP
/* Results show a strong, negative correlation. For each increase in food access
there is a .7 percent decrease in foodstamp usage. */

corr PercentwithSNAP perobese  
/* Results show a moderate positive relationship between SNAP usage and obesity. 
For each increase in the percentage of SNAP useage, the percentage of obesisty 
increases by .5 percent. */ 

reg perobese PercentwithSNAP perwaccess 
/* Results here are striking and show that for each percentage increase in SNAP
usage, there is a 34% increase in obesity holding all other variables constant. 
We also see that for each percentage increase in access to phyisical activity,
obesisty decreases by .2 percent. */ 

reg unhealthy foodindex PercentwithSNAP MHPrate peruninsured 
/*To test for other potential correlations I added the rate of mental health
providers, the percent of uninsured individuals as well as SNAP usage as a proxy
for poverty. Interestingly, food access remains an important variable however 
with each increase in food access there is only a .2 decrease in days of mental 
and physical health holding all other variables constant. With each percentage 
increase in SNAP usage there is a 6 % increase in days of mental or physical 
poor health. For each in increase in the rate of mental health providers there 
is a decrease in unhealthy days of .001, however this is not statistically 
significant. Similiarly, the number of uninsured individuals did not have 
a statistically significant impact on the data.*/ 

reg unhealthy foodindex PercentwithSNAP MHPrate peruninsured perwaccess
/*By adding in access to physical activity, there is little change from the 
previous regress. Access to physical activity does not impact health in a 
statistically significant way.*/ 

corr foodindex perlowbirth PercentwithSNAP
/*There is a moderate, negative correlation between low birth weights and access
to healthy food. For each percentage increase in access to healthy food, the 
percentage of low birth weights falls by .45 percent.*/ 

reg perlowbirth foodindex PercentwithSNAP peruninsured 
/* Low birth rates may be connected to SNAP usage/poverty as well. Regression
results show that for each percent increase in SNAP usage, the percent of 
low birth rates rises by 20% holding all other variables constant. Other variables
considered in this regression (food access, insurance) were not significant.*/

corr perlowbirth PercentwithSNAP
/*There is a strong positive correlation between low birth rates and SNAP usage.
For each increase in the percent of SNAP usage there is a .7% increase in low
birth rates.*/ 


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                                5
								
                              SUMMARY 
				  Prelimiarly discussion of findings 
								   
								   
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/*At this stage in my research I can see that my data confirms popular research 
about food access and health. While food access is just one of the compounding 
variables that impact a person's health (physical and mental) this is important
to look into more closely. Initial regressions show that access to food does not
mean the same for people in poverty as opposed to the general population. For
those on foodstamps, food access only improves their health at half the rate. 
And those who utilize food stamps have increased instances of physically 
and mentally unhealthy days per month as well as lower birth weights, and higher 
rates of obesity. 
 
When looking at New Jersey at the county level it is clear that South Jersey 
(while smaller in population) does face a substantial burden in terms of social 
ills. Stress levels are high, food insecurity, child poverty,obesity, loss of 
life are all increased for counties such as Cumberland, Salem, Ocean and Atlantic.
Important to note, the data shows that food inaccess can lead to decreased life 
expectancy, low birth rates, and lower rates of health. 

Therefore it is important to think about what is currently being done to 
address issues of hunger and health and to further analyze the usefulness of 
the food stamp program since even increases in access to healthy food and the
vouchers for food are not leading to increased health outcomes. 
There are many social programs in place such as farmers markets that accept 
food stamps, cooking classes and health eating programming, but the question 
remains- are they working and what else can be done to counter these negative 
health outcomes?

I will continue to look into how this data intersects with race and if time 
permits- pollution. In the future I will also try to incorporate SNAP data in 
regards to programming/education and attitudes towards food.*/ 

