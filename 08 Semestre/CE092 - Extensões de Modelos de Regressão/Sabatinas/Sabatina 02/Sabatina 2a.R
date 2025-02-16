#ATEN��O. O Moodle faz corre��o automaticamente. Considere que hajam n senten�as, das quais m est�o corretas e o valor total da quest�o 1. O moodle considera que marcar k alternativas incorretas desconta k/(n???m) na pontua��o acumulada em alternativas corretas. Portanto, evite "chutes". Caso n�o tenha total seguran�a se a afirma��o � verdadeira, deixe-a em branco.

#Considere os dados dispon�veis no objeto tb1 criado com o c�digo R do bloco a seguir.

tb1 <- data.frame(x = seq(0, 2, by = 0.1),
                  y1 = c(5.5, 7.2, 10.4, 7.4, 7.2, 9.1, 15.9, 12.7,
                         11.3, 14.4, 14.8, 17.1, 31.4, 17.5, 27.6, 19.6,
                         27.1, 21, 33.8, 30.2, 45.1),
                  y2 = c(0.8, 1.5, 2.6, 1.5, 1.4, 2.1, 3.9, 3.3, 3, 3.9,
                         4.2, 4.8, 6.9, 5.5, 7.3, 6.7, 8.2, 8.1, 10.2,
                         10.7, 12.8))

library(lattice)
library(latticeExtra)

xyplot(y1 + y2 ~ x, data = tb1, outer = TRUE, scales = "free")

#Digrama de dispers�o.

#Essa tabela de dados cont�m os valores de duas vari�veis respostas, y1 e y2, como fun��o de uma vari�vel quantitativa x. Apesar de estarem na mesma tabela, y1 e y2 n�o s�o medidas observadas juntas mas sim de experimentos diferentes mas coincidentemente observadas sob os mesmos valores da vari�vel independente x.

#Considerando tais vari�veis, ajuste os modelos listados abaixo para assinalar as senten�as adiante.

#Modelo gaussiano para y1 com preditor linear em x e fun��o de liga��o can�nica.
#Modelo gaussiano para y1 com preditor quadr�tico em x e fun��o de liga��o can�nica.
#Modelo gaussiano para log(y1) com preditor linear em x e fun��o de liga��o can�nica.
#Modelo gaussiano para y1????????? com preditor linear em x e fun��o de liga��o can�nica.
#Modelo gaussiano para BoxCox(y1)=y??1???1?? com preditor linear em x e fun��o de liga��o can�nica. O valor de ?? � o que otimiza a log-verossimilhan�a perfilhada. Veja MASS::boxcox().
#Modelo gama para y1 com preditor linear em x e fun��o de liga��o can�nica.
#Modelo gaussiano inverso para y1 com preditor linear em x e fun��o de liga��o can�nica.
#Modelo gaussiano para y1 com preditor linear em x e fun��o de liga��o logar�tmica.
#Para cada modelo dessa lista

#Obtenha o valor da log-verossimilhan�a, fazendo corre��es para considerar a transforma��o da vari�vel resposta quando for o caso.
#Obtenha os valores preditos na escala da vari�vel resposta para a sequ�ncia de valores de x em 0,0.05,0.10,.,2.
#Assinale as senten�as verdadeiras.

#Escolha uma ou mais:

#a. No intervalo x???[0.75,1.5], os valores preditos pelo modelo 7 est�o mais pr�ximas do modelo 1 que o modelo 6 do modelo 1.
#b. O uso da fun��o de liga��o logar�tmica no modelo 8 deu log-verossmilha�a inferior ao modelo 1 que usou fun��o de liga��o identitidade.
#c. A log-verossimilhan�a do modelo 3 foi superior a do 1.
#d. A log-verossimilhan�a do modelo 4 foi superior a do 1.
#e. A log-verossimilhan�a do modelo 3, corrigida para a escala natural da vari�vel resposta, foi -54.70.
#f. A transforma��o da resposta no modelo 3 � mais apropriada que a transforma��o feita no modelo 4.
#g. O modelo 2 com termo quadr�tico no preditor produziu log-verossimilhan�a inferior ao modelo 1.
#h. Dentre os modelos que n�o transformaram a vari�vel resposta, a maior log-verossmilhan�a � a do modelo 8.
#i. No intervalo x???[0.5,1.5], o valor predito, y^, pelo modelo 1 � superior ao valor predito pelo modelo 2.
#j. A distribui��o considerada no modelo 6 � mais apropriada para os dados que a do modelo 7.
#k. Considerando apenas os modelos que n�o fizeram transforma��o da vari�vel resposta, os modelos com valores preditos mais pr�ximos um do outro foram 2 e 8.
#l. Na origem (x=0), o modelo 3 tem valor predito inferior ao do modelo 4
