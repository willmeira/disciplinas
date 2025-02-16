### Exemplo - M�nimos quadrados ponderados. Vamos utilizar o data frame 
# cars, dispon�vel na base do R.

require(car) 
### Deste pacote vamos usar a fun��o ncvTest, que permite 
# testar a hip�tese de vari�ncia constante para o erro.  
require(nlme) 
### Desse pacote vamos utilizar a fun��o gls, para ajustar 
# um modelo alternativo baseado em m�nimos quadrados ponderados.

help(cars) 
### Consultando a documenta��o dos dados, para entender as vari�veis.

head(cars,10) 
### Visualizando as dez primeiras linhas da base.

summary(cars) 
### Extraindo algumas descritivas.

par(cex=1.4, las=1)
plot(cars, pch=20, xlab='Velociadade (mph)', ylab='Dist�ncia de frenagem (m)') 
### Gr�fico de dispers�o da dist�ncia de frenagem em rela��o � velocidade do ve�culo.

with(cars, lines(lowess(dist~speed), col='red', lwd=2)) 
### Ajustando uma curva de regress�o n�o param�trica 
### (apenas para verificar melhor a rela��o entre as vari�veis. N�o entraremos em 
### detalhes sobre este procedimento agora).


### Claramente h� uma rela��o entre as vari�veis (a dist�ncia de frenagem 
### aumenta conforme a velocidade do ve�culo). Vamos assumir que a rela��o 
### entre as vari�veis � linear. Fica como exerc�cio para o aluno tentar 
### outras possibilidades, como ajustar um modelo polinomial ou transformar 
### uma das vari�veis (ou ambas). 


########################################################################
###1� Ajuste

ajuste <- lm(dist ~ speed, data = cars) 
### ajuste armazena o modelo de regress�o linear ajustado para as duas vari�veis.

summary(ajuste) 
### Estima-se que a dist�ncia de frenagem  aumente, em m�dia, aproximadamente 
### 4 metros (3,93) a cada aumento de 1 mph na velocidade do ve�culo. 
### Na pr�tica, o intercepto n�o tem interpreta��o. Por que?

residuos <- rstandard(ajuste) 
### Extraindo os res�duos (padronizados) do ajuste.

par(cex=1.4, las=1, mfrow=c(1,2))
plot(cars$speed, residuos, xlab='Velociadade (mph)', ylab='Res�duos', 
     pch=20,cex=1.5,ylim=c(-2,3))
### Gr�fico de res�duos vs velocidade. H� claros indicativos de que a 
# vari�ncia dos res�duos aumenta com a velocidade

par(mfrow = c(2,2))
plot(ajuste, which = 1:4)

ncvTest(lm(dist~speed, data=cars)) 
### A hip�tese nula do teste � que a vari�ncia dos res�duos � constante 
### em rela��o � velocidade. O teste fornece evid�ncia significativa de 
### que a vari�ncia n�o � constante (p=0,03).


########################################################################
###2� Ajuste

### Vamos considerar que a vari�ncia dos res�duos aumente linearmente com 
### a velocidade do ve�culo, o que nos motiva a usar como pesos 1/velocidade.

ajuste2 <- lm(dist ~ speed, weights=1/speed, data=cars) 
### Incorporamos os pesos por meio do argumento "weights".

residuos2 <- rstandard(ajuste2)
plot(cars$speed, residuos2, xlab='Velociadade (mph)', ylab='Res�duos', 
     pch=20,cex=1.5,ylim=c(-2,3))
### Repare que o padr�o verificado nesse gr�fico (de varia��o n�o constante 
### para os res�duos) n�o � evidente se comparado ao primeiro ajuste.

ncvTest(lm(dist~speed, weights=1/speed, data=cars)) 
### O teste de Breusch-Pagan n�o indica a rejei��o da hip�tese de vari�ncia 
### constante (p=0,32).

summary(ajuste2) 
compareCoefs(ajuste,ajuste2) 
### A fun��o compareCoefs disp�e lado a lado estimativas e erros padr�es 
### de dois ou mais modelos ajustados.

### Observe que a estimativa do efeito da velocidade na dist�ncia de 
### frenagem � menor (3.63, contra 3.93 no ajuste1), mas seu erro padr�o
### tamb�m � menor (0.34, contra 0.41 no ajuste1). De qualquer forma, novamente 
### se verifica rela��o significativa entre as vari�veis.


############################ 3� Ajuste 
### Vamos considerar agora que a rela��o entre a varia��o dos erros e a 
### velocidade seja desconhecida, mas desejamos estim�-la. Uma maneira de 
### fazer isso � assumir uma forma n�o completamente especificada para essa 
### rela��o, envolvendo par�metros, e estimar esses par�metros juntamente 
### com os demais par�metros do modelo.

### Poder�amos especificar varias fun��es. Vamos considerar uma, implementada 
# no pacote nlme: DP(Erros)=alpha+velocidade^beta, ou seja, estamos assumindo 
# uma rela��o do tipo pot�ncia, onde alpha e beta s�o par�metros a serem estimados.

ajuste3 <- gls(dist ~ speed, data=cars, weight = varConstPower(form =~ speed))
residuos3 <- residuals(ajuste3, type='normalized')

plot(cars$speed,residuos3, xlab='Velociadade (mph)', ylab='Res�duos', pch=20,
     cex=1.5, ylim=c(-2,3))
compareCoefs(ajuste, ajuste2, ajuste3)
summary(ajuste3)

### Observe que a estimativa da pot�ncia (power=1,022) indica rela��o 
### (aproximandamente) linear entre o desvio padr�o dos res�duos e a velocidade, e,
### consequentemente, quadr�tica entre a vari�ncia dos erros e a velocidade.

