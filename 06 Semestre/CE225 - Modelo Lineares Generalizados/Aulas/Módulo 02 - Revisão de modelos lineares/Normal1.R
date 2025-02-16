require(effects)
require(car)
require(ggplot2)
Age = 150, Number = 6, Start = 3)

x <-(-2.036934)+(0.010930*150)+(0.410601*6)-(0.206510*3)

mi <- (exp((-2.036934)+(0.010930*150)+(0.410601*6)-(0.206510*3))/1+exp((-2.036934)+(0.010930*150)+(0.410601*6)-(0.206510*3)))



### Exemplo - An�lise de rea��o qu�mica (Modelo com erros normais)

### Leitura e descritiva dos dados
dados <- read.table('https://docs.ufpr.br/~taconeli/CE22517/Normal1.txt',header=T)
names(dados) <- c('Viscosidade','Temperatura','Alimenta��o')
summary(dados)
plot(dados, pch=20, cex=1.5)
### Observando os gr�ficos, notamos ind�cios de exist�ncia de uma tend�ncia 
### crescente da viscosidade com rela��o �s outras duas vari�veis 
### (sobretudo quanto � temperatura).

### Ajuste do modelo de regress�o linear com as duas vari�veis explicativas 

ajuste1 <- lm(Viscosidade~Temperatura+Alimenta��o,data=dados) 
### A fun��o lm ajusta modelos lineares (neste caso, um modelo de regress�o 
### linear com duas vari�veis explicativas).
summary(ajuste1) 
model.matrix(ajuste1) ### Matriz do modelo.

### Por meio do summary, obtemos as estimativas (e os respectivos erros) 
### associados a cada par�metro do modelo, suas signific�ncias, al�m de
### indicadores de qualidade do ajuste como os coeficientes de determina��o 
### ajustado e n�o ajustado e o teste F para signific�ncia do modelo. 
### Pode-se atestar, pelo teste F, a signific�ncia do modelo, que � capaz 
### de explicar 92,7% da varia��o dos dados.
### Al�m disso, as evid�ncias de tend�ncias crescentes destacadas na an�lise descritiva 
### s�o aqui confirmadas com base nas signific�ncias
### dos coeficientes do modelo (p<0,001, para a temperatura, e p=0,003, 
### para a taxa de alimenta��o).

pf(82.5,2,13)

 
names(ajuste1) ### Retorna a rela��o dos resultados produzidos pela fun��o lm. 
### Para mais informa��es, consultar a documenta��o - help('lm')

ajuste2 <- lm(Viscosidade ~ scale(Temperatura,scale=F) + scale(Alimenta��o,scale=F), data=dados) 
### Ajuste alternativo, 'centrando' as vari�veis explicativas,
### ou seja, diminuindo de cada observa��o das vari�veis explicativas a respectiva m�dia.

summary(ajuste2)
### O que mudou?

### Diagn�stico do modelo

ajuste1$residuals # Vetor de res�duos ordinarios
residuos <- rstandard(ajuste1);residuos # Vetor de res�duos padronizados
rstudent(ajuste1) # Vetor de res�duos studentizados

preditos <- ajuste1$fitted.values # Vetor de valores ajustados pelo modelo.

plot(preditos, residuos,xlab='Valores ajustados', ylab='Res�duos', pch=20, cex=1.5)
### H� algum ind�cio nos res�duos de vari�ncia n�o constante (a dispers�o 
### aumenta conforme a viscosidade). Como poder�amos remediar (ou melhor avaliar) isso?

par(mfrow=c(1,2))
hist(residuos)
qqnorm(residuos)
qqline(residuos)
### Investigar normalidade.
shapiro.test(residuos) 
### Teste de normalidade para os res�duos. N�o h� evid�ncias de n�o normalidade.

influence.measures(ajuste1)
### Medidas de influ�ncia. As unidades 4 e 7 s�o destacadas como poss�veis observa��es influentes. 

summary(influence.measures(ajuste1))
### Ambas as observa��es s�o destacadas por com rela��o � medida COVR, 
### ou seja, pela altera��o na precis�o das estimativas. 
### Vamos ver como ficariam os resultados eliminando tais observa��es.

summary(ajuste1)
summary(update(ajuste1, subset = -4))
summary(update(ajuste1, subset = -7))
summary(update(ajuste1, subset = -c(4,7)))

### A elimina��o das observa��es 4 e 7 n�o altera de forma substancial as 
### estimativas e n�o muda as infer�ncias do modelo.

### Intervalos de confian�a para os par�metros do modelo.
confint(ajuste1)

### Algumas predi��es

predict(ajuste1) ### Viscosidade estimada para cada observa��o na base.

predict(ajuste1, interval = 'confidence') 
### Viscosidade estimada e intervalo de confian�a (95%) para a viscosidade
### m�dia.

predict(ajuste1, interval = 'prediction')
### Viscosidade estimada e intervalo de predi��o (95%) para a viscosidade
### de uma nova observa��o.

### Agora, vamos repetir os c�digos considerando um par de valores diferente
### dos que aparecem na base.
predict(ajuste1, newdata = data.frame(Temperatura = 95, Alimenta��o = 11))
predict(ajuste1, newdata = data.frame(Temperatura = 95, Alimenta��o = 11),
        interval = 'confidence')
predict(ajuste1, newdata = data.frame(Temperatura = 95, Alimenta��o = 11),
        interval = 'prediction')

### Gr�ficos para a viscosidade estimada com bandas de confian�a. 
plot(effect("Temperatura", ajuste1))
### Viscosidade estimada versus temperatura (alimenta��o fixada na m�dia)

plot(effect("Alimenta��o", ajuste1))
### Viscosidade estimada versus alimenta��o (temperatura fixada na m�dia)

plot(effect("Alimenta��o", given.values = c(Temperatura = 85), ajuste1))
### Viscosidade estimada versus alimenta��o (temperatura fixada em 85)

plot(effect("Temperatura", given.values = c(Alimenta��o = 12), ajuste1))
### Viscosidade estimada versus temperatura (alimenta��o fixada em 12)


########################################################################
### Exemplo 2 - vendas segundo o tipo de embalagem.

Embalagem <- rep(c('E1','E2','E3','E4'), each=3)
Vendas <- c(11,18,13,14,10,12,19,17,21,24,30,27)

# Descri��o dos dados
stripchart(Vendas ~ Embalagem, vertical=T, pch=20) # Gr�fico de vendas vs embalagem.
### H� fortes ind�cios de diferen�a nas vendas conforme o tipo de embalagem.

tapply(Vendas, Embalagem, mean) # Vendas m�dias por tipo de embalagem.
tapply(Vendas, Embalagem, sd) # Desvios padr�es das vendas por tipo de embalagem.

### Ajuste do modelo de an�lise de vari�ncia com um fator

modelo1 <- lm(Vendas ~ Embalagem)
anova(modelo1) 
### A an�lise de vari�ncia confirma as evid�ncias anteriores 
### de que as vendas, em m�dia, variam conforme o tipo de embalagem. 
summary(modelo1) 
### Repare que nessa parametriza��o o intercepro corresponde 
### � m�dia para a embalagem 1 e os demais par�metros �s diferen�as das m�dias
### para as embalagens 2, 3 e 4 em rela��o � m�dia da embalagem 1.

### Os resultados indicam que as embalagens 3 e 4 proporcionam maior venda 
### m�dia do que a embalagem 1, n�o havendo diferen�a entre as 
### vendas m�dias proporcionadas pelas embalagens 1 e 2.
### Nota - se desejado, poderia prosseguir com a execu��o de algum teste 
### de compara��es m�ltiplas.

names(modelo1)
model.matrix(modelo1) # Matriz do modelo (X).

### Ajuste do modelo sem intercepto (parametriza��o alternativa)

modelo2 <- lm(Vendas ~ Embalagem-1)
summary(modelo2) 
### Agora, os quatro par�metros correspondem �s vendas m�dias das quatro embalagens. 
model.matrix(modelo2)

### Diagn�stico do modelo

residuos <- rstandard(modelo1) # Vetor de res�duos
preditos <- modelo1$fitted.values # Vetor de valores ajustados

plot(preditos,residuos,pch=20,xlab='Valores ajustados',ylab='Res�duos',cex=1.2)
### Investigar heterocedasticidade, observa��es mal-ajustadas (outliers, pontos influentes). 
### N�o h� qualquer ind�cio de problemas no ajuste.

par(mfrow=c(1,2))
hist(residuos)
qqnorm(residuos)
qqline(residuos)
### Sem problemas quanto ao pressuposto de normalidade.

shapiro.test(residuos) 
### Teste de normalidade. A hip�tese nula de normalidade n�o � rejeitada.
bartlett.test(residuos~Embalagem) 
### Teste de igualdade de vari�ncias. A hip�tese nula de igualdade n�o � rejeitada.

### Intervalos de confian�a sob as duas parametriza��es.
confint(modelo1)
confint(modelo2)

### Vamos testar algumas hip�teses referentes a combina��es lineares dos par�metros.
linearHypothesis(modelo2, "1*EmbalagemE4 - 1*EmbalagemE3 = 0")
### Testando a igualdade de m�dias das embalagens 3 e 4.

linearHypothesis(modelo2, "1*EmbalagemE3 - 0.5*EmbalagemE4 - 0.5*EmbalagemE2 = 0")
### Testando a igualdade da embalagem 3 e da m�dia das embalagens 4 e 2.







