clear all
set more off
capture log close

******
* 1. Carpetas de trabajo
******

global o1 "C:/Users/Diego/OneDrive/Escritorio/Investigación/MEI"

global o2 "$o1/1 Bases de Datos/"

global o3 "$o1/2 Resultados/"

global bases1 enaho01a300 enaho01b2

global bases2 enaho01200

******
* 2. Juntar Bases 
******

******
* 2.1. Destring key variables 
******

forv i=2004(1)2021{
foreach j of global bases2{
local base1 = substr("`j'",1,7)
local base2 = substr("`j'",8,3)
use "$o2/`i'/`base1'-`i'-`base2'.dta", clear

quietly: rename a?o a_o
if (`i'>2017) destring conglome vivienda hogar ubigeo codperso, replace

else destring conglome vivienda hogar ubigeo codperso p208a2, replace

save "$o2/`i'/`base1'-`i'-`base2'.dta", replace
}
}

forv i=2004(1)2021{
foreach j of global bases1{
local base1 = substr("`j'",1,8)
local base2 = substr("`j'",9,3)
use "$o2/`i'/`base1'-`i'-`base2'.dta", clear

quietly: rename a?o a_o


quietly: destring conglome vivienda hogar ubigeo codperso, replace

save "$o2/`i'/`base1'-`i'-`base2'.dta", replace
}
}



******
* 2.2. Merge y append
******
clear all

forv i=2004(1)2021{
	
	use "$o2/`i'/enaho01-`i'-200.dta", clear

rename a?o a_o

if (`i' > 2017) keep a_o conglome vivienda hogar codperso ubigeo dominio estrato p203 p207 p208a p209 facpob07
else keep a_o conglome vivienda hogar codperso ubigeo dominio estrato p203 p207 p208a p208a2 p209 facpob07 
**Nota1: no hay p208a2 desde ENAHO 2018-2021** (Correcto)


merge 1:1 conglome vivienda hogar codperso using "$o2/`i'/enaho01a-`i'-300.dta", keepus(p301a p301b p301c p301d) 

drop if _merge==1

drop _merge

if (`i' > 2011) merge 1:1 conglome vivienda hogar codperso using "$o2/`i'/enaho01b-`i'-2.dta", keepus(p45_1 p45_2)
else merge 1:1 conglome vivienda hogar codperso using "$o2/`i'/enaho01b-`i'-2.dta", keepus(p45_1 p45_2 p46 p47)
**Nota1: en las preguntas p46 y p47 no hay información desde ENAHO 2012-2021. Nota2: se cambió el nombre de los .dta del 2004-2006 de "enaho01b-i-3" a "enaho01b-i-2"**
drop if _merge==1
drop _merge
save "$o3/Base_`i'.dta", replace
clear all
if (`i' > 2004) append using "$o3/Base_2004.dta" "$o3/Base_`i'.dta", force

if (`i' > 2004) save "$o3/Base_2004.dta", replace
}


******
* 3. Crear variables de interes 
******
clear all
use "$o3/Base_2004.dta", clear
*Generar variable "Departamento de Residencia"
gen depart = .
replace depart=ubigeo/10000
replace depart=round(depart)
label variable depart "depa"
label define depart 1 "Amazonas"
label define depart 2 "Ancash", add
label define depart 3 "Apurimac", add
label define depart 4 "Arequipa", add
label define depart 5 "Ayacucho", add
label define depart 6 "Cajamarca", add
label define depart 7 "Callao", add
label define depart 8 "Cusco", add
label define depart 9 "Huancavelica", add
label define depart 10 "Huanuco", add
label define depart 11 "Ica", add
label define depart 12 "Junin", add
label define depart 13 "La_Libertad", add
label define depart 14 "Lambayeque", add
label define depart 15 "Lima", add
label define depart 16 "Loreto", add
label define depart 17 "Madre_de_Dios", add
label define depart 18 "Moquegua", add
label define depart 19 "Pasco", add
label define depart 20 "Piura", add
label define depart 21 "Puno", add
label define depart 22 "San_Martin", add
label define depart 23 "Tacna", add
label define depart 24 "Tumbes", add
label define depart 25 "Ucayali", add
label values depart depart
label var depart "Departamento de residencia"

*Generar variable "Departamento de Nacimiento"
gen depanac = .
replace depanac=p208a2/10000
replace depanac=round(depanac)
label variable depanac "depa"
label define depanac 1 "Amazonas"
label define depanac 2 "Ancash", add
label define depanac 3 "Apurimac", add
label define depanac 4 "Arequipa", add
label define depanac 5 "Ayacucho", add
label define depanac 6 "Cajamarca", add
label define depanac 7 "Callao", add
label define depanac 8 "Cusco", add
label define depanac 9 "Huancavelica", add
label define depanac 10 "Huanuco", add
label define depanac 11 "Ica", add
label define depanac 12 "Junin", add
label define depanac 13 "La_Libertad", add
label define depanac 14 "Lambayeque", add
label define depanac 15 "Lima", add
label define depanac 16 "Loreto", add
label define depanac 17 "Madre_de_Dios", add
label define depanac 18 "Moquegua", add
label define depanac 19 "Pasco", add
label define depanac 20 "Piura", add
label define depanac 21 "Puno", add
label define depanac 22 "San_Martin", add
label define depanac 23 "Tacna", add
label define depanac 24 "Tumbes", add
label define depanac 25 "Ucayali", add
label values depanac depanac
label var depanac "Departamento de nacimiento"


*Generar variable "Área urbano/rural" (usar la variable estrato)
gen     area=1 if estrato<=5
replace area=2 if estrato>=6 & estrato<=8
lab var area "Area de residencia"
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*Generar variable  "Regiones naturales" (usar la variable dominio)
gen     regnat=1 if dominio<=3 | dominio==8
replace regnat=2 if dominio>=4 & dominio<=6
replace regnat=3 if dominio==7
lab var regnat "Region natural"
lab def regnat 1 "Costa" 2 "Sierra" 3 "Selva"
lab val regnat regnat

*Generar variable "Regiones naturales - lugar de NACIMIENTO" (usar la variable depanac)

gen regnatnac=.
replace regnatnac=1 if depanac== 15
replace regnatnac=1 if depanac== 13
replace regnatnac=1 if depanac== 20
replace regnatnac=1 if depanac==11
replace regnatnac=1 if depanac==14
replace regnatnac=1 if depanac==7
replace regnatnac=1 if depanac==24
replace regnatnac=1 if depanac==23
replace regnatnac=1 if depanac==18

replace regnatnac=2 if depanac==8
replace regnatnac=2 if depanac==19
replace regnatnac=2 if depanac==5
replace regnatnac=2 if depanac==10
replace regnatnac=2 if depanac==12
replace regnatnac=2 if depanac==6
replace regnatnac=2 if depanac==4
replace regnatnac=2 if depanac==2
replace regnatnac=2 if depanac==3
replace regnatnac=2 if depanac==9
replace regnatnac=2 if depanac==21

replace regnatnac=3 if depanac==22
replace regnatnac=3 if depanac==25
replace regnatnac=3 if depanac==16
replace regnatnac=3 if depanac==17
replace regnatnac=3 if depanac==1
lab var regnatnac "Region natural de Nacimiento"
lab def regnatnac 1 "Costa" 2 "Sierra" 3 "Selva"
lab val regnatnac regnatnac



/*Años de educacion jefe y conyuge del hogar (METODOLOGÍA LUIS GARCIA)
recode p301a (1/4 = 0) (5/6 = 6) (7/10 = 11) (11 = 16) (.=.), gen(nivelprevio)
egen suma=rowtotal(p301b p301c)

gen educacion = suma + nivelprevio
*/

*Generar variable "Años de educacion jefe y conyuge del hogar" (METODOLOGÍA TORRES ET AL.)

gen educhijo = .
replace educhijo=0 if p301a==1
replace educhijo=0 if p301a==2
replace educhijo=p301b if p301a==3
replace educhijo=6 if p301a==4
replace educhijo=6+p301b if p301a==5
replace educhijo=11 if p301a==6
replace educhijo=12 if p301a==7
replace educhijo=13 if p301a==8
replace educhijo=11+p301b if p301a==9 & p301b<5
replace educhijo=11+4 if p301a==9 & p301b>4 & p301b<6
replace educhijo=16 if p301a==10
replace educhijo=16+p301b if p301a==11

*Generar variable "Años de educacion padres" (METODOLOGÍA TORRES ET AL.)

recode p45_1 (1 = 0) (2 = 3) (3 = 6) (4 = 9) (5 = 11) (6 = 12) (7 = 13) (8 = 14) (9 = 16) (10=.) (.=.), gen(educpapa)

recode p45_2 (1 = 0) (2 = 3) (3 = 6) (4 = 9) (5 = 11) (6 = 12) (7 = 13) (8 = 14) (9 = 16) (10=.) (.=.), gen(educmama)

*Generar variable "Año de nacimiento"
destring a_o,replace
gen añonac = .
forv i=2004(1)2021{
replace añonac = `i' - p208a if a_o ==`i'
}

*Eliminar datos que no son del jefe del hogar y del conyuge
drop if codperso>1

*Eliminar datos de personas con edad fuera del intervalo de 25-64 años
drop if p208a<25
drop if p208a>64

*Eliminar datos de personas con fecha de nacimiento fuera del intervalo 1957-1996
drop if añonac<1957
drop if añonac>1996
*drop if codperso==2
drop if educhijo==.
tab educhijo


save "$o3/Base_final_2004-2021.dta",replace