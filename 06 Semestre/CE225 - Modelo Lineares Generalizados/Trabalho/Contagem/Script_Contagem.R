library(ggplot2)
library(gridExtra)
library(corrplot)
library(readxl)

dados <- read_xls('Base_fim.xls',
                  col_types = c("text", "numeric", "numeric","numeric", "numeric",
                                "numeric","numeric", "numeric", "numeric"))

###################
# An�lise Descritiva
###################

str(dados)
summary(dados)
head(dados)

# Quantidade de munic�pios por total de incid�ncia
tabobt <- table(dados$obit)
tabpobt <- table(round(dados$obit/sum(dados$obit)*100, digits = 2))
X11()
par(mfrow=c(1,2))
barplot(tabobt)
barplot(tabpobt)

###################
# Boxplots
###################
x11()
par(mfrow=c(3,3))
boxplot(dados$obit, xlab = '', ylab = '', main = '�bitos no Tr�nsito', las=1)
boxplot(dados$vphab, xlab = '', ylab = '', main = 'Ve�culos a cada 100 Habit', las=1)
boxplot(dados$dens, xlab = '', ylab = '', main = 'Densidade Demogr�fica', las=1)
boxplot(dados$purb, xlab = '', ylab = '', main = '% Pop Urbana', las=1)
boxplot(dados$palf, xlab = '', ylab = '', main = '% Alfabetizados', las=1)
boxplot(dados$pdes, xlab = '', ylab = '', main = '% Desmpregados', las=1)
boxplot(dados$rmed, xlab = '', ylab = '', main = '% Pop Baixa Renda', las=1)
boxplot(dados$idh, xlab = '', ylab = '', main = 'IDH', las=1)

###################
# Histogramas
###################
x11()
g1 <- ggplot(dados, aes(x=obit)) + geom_histogram()+ xlab('�bitos no Tr�nsito')+ ylab('')
g2 <- ggplot(dados, aes(x=vphab)) + geom_histogram()+ xlab('Ve�culos a cada 100 Habit')+ ylab('')
g3 <- ggplot(dados, aes(x=dens)) + geom_histogram()+ xlab('Densidade Demogr�fica')+ ylab('')
g4 <- ggplot(dados, aes(x=purb)) + geom_histogram()+ xlab('% Pop Urbana')+ ylab('')
g5 <- ggplot(dados, aes(x=palf)) + geom_histogram()+ xlab('% Alfabetizados')+ ylab('')
g6 <- ggplot(dados, aes(x=pdes)) + geom_histogram()+ xlab('% Desmpregados')+ ylab('')
g7 <- ggplot(dados, aes(x=rmed)) + geom_histogram()+ xlab('Renda M�dia')+ ylab('')
g8 <- ggplot(dados, aes(x=idh)) + geom_histogram()+ xlab('IDH')+ ylab('')
grid.arrange(g1, g2, g3, g4, g5, g6, g7, g8, ncol=3, nrow=3)

# Pelos boxplots e histogramas verificamos uma grande assimetria na covari�vel
# Densidade demografica. Vale a pena fazer uma transforma��o nesta vari�vel, para 
# melhorar a assimetria aplicando log.

###################
# Aplicando Log
###################
dados$ldens  <- log(dados$dens)
x11()
par(mfrow = c(1,2))
hist(log(dados$dens), main = 'log(Densidade)', xlab = '', ylab = '')
boxplot(log(dados$dens), xlab = '', ylab = '', main = 'log(Densidade)')

# Aplicando log, verificamos uma melhora consider�vel na assimetria dos dados da vari�vel

###################
# Correla��o
###################

# Vamos verificar a correla��o entre as vari�veis em estudo, substituino a var�avel densidade 
# demogr�fica pela log densidade.

library(corrplot)
cor <- cor(dados[ , c(2,3,10,5,6,7,8,9)])
x11()
corrplot.mixed(cor, upper = "ellipse")

# O correlograma aponta tr�s vari�veis como mais correlacionadas com a resposta: 
# o log da densidade demogr�fica, renda m�dia e percetual de popula��o urbana. 
# Nota-se tamb�m que as var�aveis IDH e Renda M�dia s�o altamente relacionadas. Outras
# correla��es que merecem destaque s�o log da Densidade com Renda M�dia, Log Densidade com IDH
##
## Testar VA'S OFFSET ****************


###################
# Gr�ficos de Dispers�o
###################

library(car)
x11()
scatterplotMatrix(dados[ , c(2,3,10,5,6,7,8,9)], 
                  smooth = list(smoother=loessLine, spread=TRUE,
                                col.smooth = 2, # Cor da m�dia do smooth
                                col.spread = 2, # Cor do ic do smooth
                                lty.smooth=1, lwd.smooth=1.5,
                                lty.spread=3, lwd.spread=1),
                  regLine = list(method=lm, col = 1), # Cor da regress�o
                  col = 3) # Cor dos pontos

## >>> MELHORAR A INTERPRETA��O <<<< Copia lineu
# A matriz de gr�ficos de dispers�o evidencia ainda alta rela��o entre as vari�veis 
# log da frota de ve�culos e o log da popula��o; quanto � vari�vel resposta nota-se 
# a presen�a de valores altos at�picos, distantes da nuvem de pontos.

###################
# Ajuste dos Modelos de Regress�o
###################
library(gamlss)

# GLM com resposta Poisson

# Modelo Glm Poisson
m1.1<-glm(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, family=poisson(link='log'),data=dados)
summary(m1.1)
x11()
par(mfrow = c(2,2))
plot(m1.1)

# Modelo Gamlss Poisson
m1.2<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, family=PO, data=dados)
summary(m1.2) 
x11()
par(mfrow = c(2,2))
plot(m1.2)

# Modelo Poisson com infla��o de zeros (mas sem covari�veis para o componente do excesso de zeros)
m1.3 <- gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh,family = ZIP, data = dados) 
summary(m1.3)
x11()
par(mfrow = c(2,2))
plot(m1.3)

# Modelo Poisson com infla��o de zeros (incluindo as covari�veis tamb�m na modelagem 
# do componente do excesso de zeros)
m1.4<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh,
             sigma.formula = ~ vphab+log(dens)+purb+palf+pdes+rmed+idh, 
             family = ZIP, data = dados) 
summary(m1.4)
x11()
par(mfrow = c(2,2))
plot(m1.4)

# GLM com resposta Binomial Negativa

# Modelo Glm.nb
m2.1<-glm.nb(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, data=dados) ## n�o utilizar
summary(m2.1)
x11()
par(mfrow = c(2,2))
plot(m2.1)

# Modelo Gamlss Binomial Negativa tipo I
m2.2<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, family=NBI, data=dados)
summary(m2.2)
x11()
par(mfrow = c(2,2))
plot(m2.2)

coef(m2.1)
coef(m2.2)

# Modelo Gamlss Binomial Negativa tipo II
m2.3<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, family=NBII, data=dados)
summary(m2.3)
x11()
par(mfrow = c(2,2))
plot(m2.3)

# Modelo Gamlss Familia Binomial Negativa
m2.4<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh, family=NBF, data=dados)
summary(m2.4)
x11()
par(mfrow = c(2,2))
plot(m2.4)

# Modelo Binomial negativa com infla��o de zeros (mas sem covari�veis para o componente do excesso de zeros)
m2.5<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh,family = ZINBI, data = dados) 
summary(m2.5)
x11()
par(mfrow = c(2,2))
plot(m2.5) #ajuste interessante

# Modelo Binomial negativa com infla��o de zeros (incluindo as covari�veis 
# tamb�m na modelagem do componente do excesso de zeros)
m2.6<-gamlss(obit~vphab+log(dens)+purb+palf+pdes+rmed+idh,
             nu.formula = ~ vphab+log(dens)+purb+palf+pdes+rmed+idh,
             family = ZINBI, data = dados) 
summary(m2.6)
x11()
par(mfrow = c(2,2))
plot(m2.6)


###################
# Escolha do Modelo
###################

### Vamos comparar os modelos pela deviance, AIC's e Log-verossimilhan�a.
Ajuste = c('Po_Glm-1.1','Po_Gaml-1.2','Po_Zip-1.3','Po_ZipIPCov-1.4',
           'Bn_Glm-2.1','Bn_TpI-2.2','Bn_TpII-2.3','Bn_Fam-2.4','Bn_Zinbi-2.5','Bn_ZinbiCOv-2.6')
Dev    = c(deviance(m1.1),deviance(m1.2),deviance(m1.3),deviance(m1.4),
           deviance(m2.1),deviance(m2.2),deviance(m2.3),
           deviance(m2.4),deviance(m2.5),deviance(m2.6))
AIC    = c(AIC(m1.1),AIC(m1.2),AIC(m1.3),AIC(m1.4),
           AIC(m2.1),AIC(m2.2),AIC(m2.3),
           AIC(m2.4),AIC(m2.5),AIC(m2.6))
LVeros = c(logLik(m1.1),logLik(m1.2),logLik(m1.3),logLik(m1.4),
           logLik(m2.1),logLik(m2.2),logLik(m2.3),
           logLik(m2.4),logLik(m2.5),logLik(m2.6))

data.frame(Ajuste, Dev, AIC, LVeros)

# O modelo que apresentou menor AIC e maior verossimilhan�a foi o modelo Binomial Negativo 
# da fun��o Glm.bn

library(hnp)

# Avaliando os modelos Poisson



X11()
par(mfrow = c(1,2))
hnp(m1.1, xlab = 'Percentil da N(0,1)', ylab = 'Res�duos', main = 'Gr�fico Normal de Probabilidades')
hnp(m2.1, xlab = 'Percentil da N(0,1)', ylab = 'Res�duos', main = 'Gr�fico Normal de Probabilidades')

# Nota-se pelas medidas de qualidade de ajuste e o comportamento dos res�duos no gr�fico
# a total falta de ader�ncia � distribui��o de Poison; alterando a distribui��o da
# resposta para Binomial Negativa obteve-se um ajuste satisfat�rio.

###################
# Modelo Escolhido
###################

### Vamos seguir as an�lises fazendo uso do modelo Binomial Negativo.

###################
# Resumo do Modelo
###################

# O modelo original foi ajustado usando todas as covari�veis dispon�veis. 
# Vamos verificar no resumo do modelo selecionado quais covari�veis s�o 
# apontadas como significativas:

summary(m2.1)

# O resumo do modelo ajustado indica que as vari�veis Log da Densidade Demogr�fica,
# Percentual de Popula��o Urbana, Percentual de Alfabetizados e IDH foram significativas. 
# No resumo � mostrado tamb�m o valor do par�metro de dispers�o (neste caso vale 1,001), 
# bem pr�ximo de 1, >>>> o que explica a falta de ajuste � distribui��o de Poisson.<<<<<

###################
# Reajuste do Modelo
###################

# Como h� um par de covari�veis altamente correlacionadas (log da frota e 
# log da popula��o), � v�lido inserir as covari�veis uma a uma no modelo 
# para verificar sua signific�ncia na presen�a das outras; tal como o realizado
# pelo algoritmo stepwise. Notou-se que ao retirar a vari�vel log da frota, 
# o log da popula��o se mostra significativo

m1.1.1 <- step(m1.1, direction = "both")
summary(m1.1.1)
m1.4.1 <- step(m1.4, direction = "both")
summary(m1.4.1)

m2.1.1 <- step(m2.1, direction = "both")
m2.2.1 <- step(m2.2, direction = "both")
# O resumo do novo modelo ajustado:
summary(m2.1.1)
summary(m2.2.1)

coef(m2.1.1)
coef(m2.2.1)


# O algoritmo indica que as vari�veis >>> grau de urbaniza��o e log da frota <<< 
# s�o significativas e tem rela��o positiva com o n�mero de acidentes de tr�nsito.

# Agora, vamos realizar o teste da raz�o de verossimilhan�a do modelo inicial e do reduzido:
  
anova(m2.1, m2.1.1)

# O p-valor do teste foi relativamente alto, portanto pode-se concluir 
# que o modelo restrito se ajusta aos dados amostrais t�o bem quanto 
# o modelo considerando todas as covari�veis. Portanto o modelo final 
# fica expresso por:

# y_i|x_i ~ Binomial Negativa

# log(�i)= XXXXXXXXXXXX


# Medidas de Influ�ncia 
# Uma alternativa para verifica��o de medidas influentes est� implementada no pacote car:

influenceIndexPlot(m2.1.1, vars=c("Cook", "Studentized", "hat"), main="Medidas de Influ�ncia")

# O primeiro gr�fico apresenta os valores da dist�ncia de Cook para cada observa��o. 
# A dist�ncia de Cook � uma medida de diferen�a das estimativas dos par�metros do 
# modelo ao considerar e ao desconsiderar uma particular observa��o no ajuste.

# O segundo gr�fico mostra os res�duos studentizados; um modelo bem ajustado 
# apresenta estes res�duos dispersos aleat�riamente em torno de 0, entre -3 e 3 desvios.

# O terceiro gr�fico mostra os valores da matriz chap�u (H). Valores elevados
# s�o considerados potencialmente influentes. Os valores da matriz chap�u 
# est�o entre 0 e 1. A soma dos elementos da diagonal da matriz H equivale ao 
# posto da matriz X de delineamento.

# Com base nesses 3 gr�ficos, n�o h� indicativos fortes de outliers ou observa��es influentes

###################
# Res�duos Quant�licos Aleatorizados
###################

# Outra alternativa para avaliar a qualidade do ajuste � baseada nos res�duos
# quant�licos aleatorizados. A fun��o qresiduals do pacote statmod extrai este 
# tipo de res�duos do modelo

library(statmod)

res <- qresiduals(m2.1.1)
X11()
par(mfrow=c(1,2))
plot(res)

residuos <- qresiduals(m2.1.1)
qqnorm(residuos)
qqline(residuos, col = 2)

# No gr�fico da esquerda nota-se que os res�duos est�o dispersos predominantemente 
# em torno de 0 entre -2 e 2. Al�m disso, no gr�fico a direita verifica-se que os 
# res�duos apresentam razo�vel ader�ncia � distribui��o Normal. H� um leve ind�cio 
# de caudas pesadas; por�m, no geral, parece que h� um ajuste plaus�vel.

###################
# Gr�fico Normal de Probabilidades com Envelope Simulado
###################

# Vamos verificar o comportamento do gr�fico Normal de probabilidades com envelope 
# simulado para o modelo reajustado:
x11()
hnp(m2.1.1, xlab = 'Percentil da N(0,1)', ylab = 'Res�duos', main = 'Gr�fico Normal de Probabilidades')
## Negative binomial model (using MASS package)

# Os res�duos est�o dispersos no interior dos envelopes simulados, 
# sem aparente padr�o sistem�tico dando ind�cio de que o modelo est� bem ajustado.

###################
# Gr�ficos de Efeitos
###################

# A fun��o effects, do pacote de mesmo nome, devolve os efeitos marginais de 
# cada vari�vel de um modelo ajustado; os gr�ficos de efeitos nos fornecem 
# uma forma visual de observar como cada vari�vel explicativa afeta a resposta, 
# com as demais vari�veis fixadas na m�dia.

library(effects)
plot(allEffects(m2.1.1), type = 'response', main = '')


###################
# Predi��o
###################

#*****************************************************************************************
#*****************************************************************************************







