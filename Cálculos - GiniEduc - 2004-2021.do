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

use "$o3/Base_final_2004-2021.dta", clear

/******
* 0. Subir a mata las matrices con variables de nivel educativo, por cohortes (4) y por departamento (25). En total, se obtienen 100 matrices (Nx4)
******/

drop if educpapa ==.

/*
tab educpapa if educpapa == 14 & añonac>= 1987 & añonac<= 1996 & depart == 16
*/

forv j = 1(1)25{
forv i = 1957(10)1987 {

mkmat añonac educpapa educmama educhijo if añonac>=`i' & añonac<=`i'+9 & depart == `j', matrix(MEI_`i'_`j') 
}
}


forv j = 1(1)25{
forv i = 1957(10)1987 {

mata: MEI_`i'_`j' = st_matrix("MEI_`i'_`j'")
}
}

forv j = 1(1)25{
forv i = 1957(10)1987 {
foreach categoria of numlist 0 3 6 9 11 12 13 14 16 {
capture noisily mkmat educpapa if educpapa == `categoria' & añonac>=`i' & añonac<=`i'+9 & depart == `j', matrix(p_1_`i'_`j'_`categoria') 
}
}
}

forv j = 1(1)25{
forv i = 1957(10)1987 {
foreach categoria of numlist 0 3 6 9 11 12 13 14 16 {
mata: p_1_`i'_`j'_`categoria' = st_matrix("p_1_`i'_`j'_`categoria'")
}
}
}




/******
* 1. Vector con la Media de años de educación del PADRE, para cada cohorte y departamento
******/


forv j = 1(1)25{
forv i = 1957(10)1987 {

mata: u_`i'_`j' = mean(MEI_`i'_`j'[.,2])

}
}



/******
* 2. Vector con la proporción de la muestra en cada nivel educativo, para cada cohorte y departamento (11 categorías)
******/
forv j = 1(1)25{
forv i = 1957(10)1987 {
foreach categoria of numlist 0 3 6 9 11 12 13 14 16 {
mata: p_`i'_`j'_`categoria' =  rows(p_1_`i'_`j'_`categoria')/rows(MEI_`i'_`j'[.,2])
}
}
}

/******
* 3. Vector con los años educativos asociados a cada nivel educativo, para cada cohorte y departamento (11 categorías)
******/

mata: niveles = (0,3,6,9,11,12,13,14,16)
mata: niveles = niveles'

forv j = 1(1)25{
forv i = 1957(10)1987{
local k = 1
foreach categoria of numlist 0 3 6 9 11 12 13 14 16 {

mata:  p_`i'_`j'_`k'_ = p_`i'_`j'_`categoria'

local k =`k'+ 1
}
}
}

/******
* 4. Cálculo del GiniEduc, para cada cohorte y departamento
******/

forv j = 1(1)25{
forv i = 1957(10)1987 {
local k=1
mata: GiniEduc_`i'_`j' = J(45,45,.)

forv m = 2(1)9{
forv n = 1(1)`k'{


mata: GiniEduc_`i'_`j'[`m',`n'] = (1/u_`i'_`j')*p_`i'_`j'_`m'_*(niveles[`m',.] - niveles[`n',.])*p_`i'_`j'_`n'_

}
local k=`k'+1
}
}
}


/******
* 4. Exportar los cálculos del GiniEduc, para cada cohorte y departamento
******/
mata: BD_GiniEduc = J(25,31,.)

forv j = 1(1)25{
forv i = 1957(10)1987 {

mata:  BD_GiniEduc[`j',`i'-1956] =  sum(GiniEduc_`i'_`j')

}
}

mata: st_matrix("BD_GiniEduc", BD_GiniEduc)

/*
mata: BD_GiniEduc_1 = BD_GiniEduc[1..25,1..1]

mata: BD_GiniEduc_2 = BD_GiniEduc[1..25,11..11]

mata: BD_GiniEduc_3 = BD_GiniEduc[1..25,21..21]

mata: BD_GiniEduc_4 = BD_GiniEduc[1..25,31..31]

mata: BD_GiniEduc_final = (BD_GiniEduc_1,BD_GiniEduc_2,BD_GiniEduc_3, BD_GiniEduc_4)

mata: st_matrix("BD_GiniEduc_final", BD_GiniEduc_final)

putexcel set "$o3/BD_GiniEduc_final.xlsx", replace
putexcel A1 = matrix(BD_GiniEduc_final)
*/

putexcel set "$o3/BD_GiniEduc.xlsx", replace
putexcel A1 = matrix(BD_GiniEduc)





