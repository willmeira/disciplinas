### An�lise dos dados de quedas de idosos, dispon�vel no arquivo geriatra.dat 
### da p�gina do professor Gilberto de Paula e no pacote labestData.

### Objetivo - analisar o efeito de duas diferentes interven��es na preven��o de
### quedas de idosos, ajustando o efeito de outras covari�veis.

### Pacotes necess�rios
require(car)
require(lmtest)
require(effects)
require(statmod)
require(labestData)
require(hnp)
require(coefplot)
require(latticeExtra)


################################################################################

### Carregando os dados e an�lise descritiva.

geriatra <- PaulaEx4.6.5  ### Leitura dos dados.
help(PaulaEx4.6.5)
names(geriatra) ### Listando os nomes das vari�veis
head(geriatra,10) ### Visualizando as 10 primeiras linhas da base.
summary(geriatra) ### Breve sum�rio.

### As pr�ximas linhas de comandos declaram sexo e interven��o como fatores, e renomeiam seus n�veis.
geriatra$interv <- factor(geriatra$interv)
geriatra$sexo <- factor(geriatra$sexo)
levels(geriatra$interv) <- c('Educ','Educ+Exerc')
levels(geriatra$sexo) <- c('Fem','Masc')

### Vamos calcular o n�mero m�dio de quedas e a vari�ncia para os idosos separados por interven��o.
tapply(geriatra$nquedas,geriatra$interv,mean)
tapply(geriatra$nquedas,geriatra$interv,var)

### Gr�ficos para a distribui��o de frequ�ncias para o n�mero de quedas.
par(cex=1.4,las=1)
barplot(table(geriatra$nquedas),col='red',xlab='N�mero de quedas',ylab='Frequ�ncia')

par(cex=1.2,las=1,mfrow=c(1,2))
barplot(table(geriatra$nquedas[which(geriatra$interv=='Educ')]),col='red',
        xlab='N�mero de quedas',ylab='Frequ�ncia',xlim=c(0,11),main='Educa��o')
barplot(table(geriatra$nquedas[which(geriatra$interv=='Educ+Exerc')]),col='blue',
        xlab='N�mero de quedas',ylab='Frequ�ncia',xlim=c(0,11),main='Educa��o + Exerc�cios')

################################################################################

### Antes de ajustar um glm, vamos ver como ficaria um modelo linear normal ajustado a este problema.
ajuste <- lm(nquedas~.,data=geriatra)
par(mfrow=c(2,2))
plot(ajuste)
### Repare, no gr�fico do canto superior direito, a falta de normalidade dos res�duos e, 
### no gr�fico do canto inferior esquerdo, como a dispers�o dos res�duos
### aumenta conforme a m�dia, claro indicativo de que a vari�ncia dos erros n�o � constante. 

################################################################################

### Agora, o ajuste do modelo log-linear Poisson.
ajuste <- glm(nquedas~., family=poisson, data=geriatra) 
### Modelo com todas as covari�veis, sem intera��es.

summary(ajuste)

### Vamos verificar se alguma intera��o envolvendo o efeito de interven��o � necess�ria.

ajusteint1 <- update(ajuste, ~.+interv:balan)
ajusteint2 <- update(ajuste, ~.+interv:forca)
ajusteint3 <- update(ajuste, ~.+interv:sexo)

anova(ajuste, ajusteint1, test='Chisq')
anova(ajuste, ajusteint2, test='Chisq')
anova(ajuste, ajusteint3, test='Chisq')

### O que voc�s dizem?

### Vamos investigar a necessidade de incluir o efeito quadr�tico das covari�veis
# num�ricas.

ajustequad1 <- update(ajuste, ~. + I(balan**2))
ajustequad2 <- update(ajuste, ~. + I(forca**2))

anova(ajuste,ajustequad1,test='Chisq')
anova(ajuste,ajustequad2,test='Chisq')
### N�o h� necessidade de inclus�o dos termos quadr�ticos.


### Assim, vamos optar pelo modelo original, mas excluindo o efeito de sexo,
# que n�o se mostrou significativo.

ajuste2 <- update(ajuste, ~.-sexo)
summary(ajuste2)

### INTERPRETA��ES!!!

################################################################################

### Diagn�stico do ajuste.

### Gr�ficos padr�o para a fun��o glm.
par(mfrow = c(2,2))
plot(ajuste2, which = 1:4)
# N�o h� indicativos s�rios de falta de ajuste. Os res�duos t�m vari�ncia aprox.
# constante, distribui��o pr�xima da Normal, n�o parece haver outliers.

### Gr�fico dos res�duos da deviance com envelope simulado.
hnp(ajuste2)
# No geral, os pontos se distribuem no interior do envelope. 

### An�lise dos res�duos quant�licos aleatorizados.

resquant <- qres.pois(ajuste2)
qqnorm(resquant)
qqline(resquant)
### Aproxima��o satisfat�ria � distribui��o Normal, ligeiro desajuste na cauda
# � direita.

shapiro.test(resquant) 
### N�o se rejeita a hip�tese de normalidade.

influenceIndexPlot(ajuste,vars=c('Studentized','Cook','Hat'),id.n=3)

### Vamos avaliar algumas observa��es destacadas no diagn�stico do modelo.

summary(geriatra)
geriatra[c(52,62,93),]
plot(geriatra$balan, geriatra$forca)

# Os indiv�duos 52 e 93 apresentaram os maiores n�meros de quedas na amostra 
# (11 e 10, respectivamente). O de n�mero 62 se destaca pelo maior escore de balan�o,
# com escore de for�a abaixo do 1� quartil.

### Vamos reajustar o modelo sem esses indiv�duos.

ajuste2alt <- update(ajuste2,subset=-c(52,62,93)) 
### Atualizando o modelo, excluindo as tr�s observa��es.

### Vamos comparar os ajustes.
compareCoefs(ajuste2,ajuste2alt) 
multiplot(ajuste2, ajuste2alt) ### Pacote coefplot
summary(ajuste2alt)

# A �nica mudan�a substancial corresponde ao efeito do escore de for�a que,
# mediante exclus�o das tr�s observa��es, perde sua signific�ncia. O efeito
# da interven��o (e decorrentes conclus�es) n�o s�o alteradas.

########################################################################
### Vamos explorar um pouco mais os resultados.

### Intervalos de confian�a.

confint.default(ajuste2)
exp(confint.default(ajuste2))
### Intervalos de confian�a baseados na normalidade assint�tica dos estimadores.

confint(ajuste2)
exp(confint(ajuste2))
### Intervalos de confian�a baseados nos perfis da verossimilhan�a.

### Explorando um pouco mais os efeitos das vari�veis explicativas 
# (consultar a documenta��o da fun��o effect, pacote effects).
plot(allEffects(ajuste2)) 
plot(allEffects(ajuste2), type = 'response')


########################################################################

### Um pouco de predi��o. Vamos estimar o n�mero m�dio de quedas para
# indiv�duos com dois perfis distintos, submetidos a cada uma das 
# interven��es.

# Perfil 1- Balan�o=30, for�a=50; Perfil 2- Balan�o=70, for�a=80.

novosdados <- data.frame(interv=c('Educ','Educ+Exerc','Educ','Educ+Exerc'),
                         balan=c(30,30,50,50),
                         forca=c(70,70,80,80))
novosdados

estimativas <- predict(ajuste2,novosdados,type='response'); estimativas
data.frame(novosdados,estimativas)

### Vamos olhar para as distribui��es ajustadas para os n�meros de quedas 
# dois perfis, sob cada interven��o.

x11()
par(mfrow=c(2,2),cex=1,2)
plot(0:10,dpois(0:10,estimativas[1]),type='h',xlab='N�mero de quedas',
     ylab='Probabilidade estimada',main='Perfil 1, Educ',lwd=2)

plot(0:10,dpois(0:10,estimativas[2]),type='h',xlab='N�mero de quedas',
     ylab='Probabilidade estimada',main='Perfil 1, Educ + Exerc',lwd=2)

plot(0:10,dpois(0:10,estimativas[3]),type='h',xlab='N�mero de quedas',
     ylab='Probabilidade estimada',main='Perfil 2, Educ',lwd=2)

plot(0:10,dpois(0:10,estimativas[4]),type='h',xlab='N�mero de quedas',
     ylab='Probabilidade estimada',main='Perfil 2, Educ + Exerc',lwd=2)


### Vamos estimar, para cada perfil, a probabilidade de haver alguma queda no per�odo.

ppois(0, estimativas[1], lower.tail=F) # P(Y>1|mu=estimativa[1]).
ppois(0, estimativas[2], lower.tail=F) # P(Y>1|mu=estimativa[2]).
ppois(0, estimativas[3], lower.tail=F) # P(Y>1|mu=estimativa[3]).
ppois(0, estimativas[4], lower.tail=F) # P(Y>1|mu=estimativa[4]).


### Vamos trabalhar um pouco com simula��o.
### Podemos utilizar simula��o (bootstrap) como alternativa ao uso da 
# teoria assint�tica para avalia��o dos erros das estimativas. 
# Vamos usar a fun��o Boot do pacote car. 

ajusteboot <- Boot(ajuste2, R=999)

### Armazenamos em ajusteboot 999 os resultados dos R=999 ajustes do glm
# proposto para 999 re-amostras de tamanho n=100 geradas com reposi��o da base original.

summary(ajusteboot)
### Repare que as estimativas bootstrap (em bootMed) e os erros padr�es (em bootSE) 
# s�o bem similares �s obtidas originalmente, baseadas na teoria assint�tica.
### Al�m disso, o vi�s � bastante pequeno (desprez�vel).

hist(ajusteboot) 
### Podemos verificar que a distribui��o dos estimadores, obtida via 
# simula��o, se aproxima bastante da distribui��o Normal.

confint(ajusteboot)
confint(ajuste2) 
### Intervalos de confian�a obtidos das duas formas s�o bastante pr�ximos. 

### Exerc�cio - testar a qualidade do ajuste com base nas estat�sticas 
# da deviance e X2 de Pearson.

### Exerc�cio - Obter intervalos de confian�a (95%) para o n�mero m�dio 
# de quedas de idosos com os dois perfis apresentados.

### Exerc�cio - Avaliar o efeito das tr�s observa��es destacadas no diagn�stico
# tirando uma a uma do ajuste do modelo e checar a altera��o nos resultados. 
