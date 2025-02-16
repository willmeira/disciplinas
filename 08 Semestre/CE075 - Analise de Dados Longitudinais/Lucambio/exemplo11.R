#
# Exemplos do pacote HSAUR
#
data("BtheB", package = "HSAUR")
#
# Dados longitudinais de um ensaio cl�nico de um programa interativo, multim�dia 
# conhecido como "Beat the Blues" projetado para oferecer terapia cognitiva 
# comportamental para pacientes com depress�o por meio de um terminal de 
# computador. Os doentes com depress�o recrutados na aten��o prim�ria foram 
# randomizados para o programa "Beating the Blues" ou "Tratamento usual (TAU)".
#
# Vari�veis:
# drug: se o paciente toma antidepressivo (No or Yes).
# length: a dura��o do epis�dio actual de depress�o, um factor com n�veis
#          <6m (less than six months) and >6m (more than six months).
# treatment: fator de n�veis TAU (Tratamento usual) e BtheB (Beat the Blues)
# bdi.pre: Escala de depress�o de Beck II antes do tratamento
# bdi.2m: Escala de depress�o de Beck II depois de dois meses
# bdi.4m: Escala de depress�o de Beck II depois de quatro meses
# bdi.6m: Escala de depress�o de Beck II depois de seis meses
# bdi.8m: Escala de depress�o de Beck II depois de oito meses
#
# Preparando a base de dados para ser interpretada como longitudinal
#
BtheB$subject = factor(rownames(BtheB))
nobs = nrow(BtheB)
BtheB_long = reshape(BtheB, idvar = "subject",
                      varying = c("bdi.2m", "bdi.4m", "bdi.6m", "bdi.8m"), direction = "long")
#
BtheB_long$time = rep(c(2, 4, 6, 8), rep(nobs, 4))
#
# Mostrando os resultados para os tres primeiros individuos (subject's)
#
subset(BtheB_long, subject %in% c("1", "2", "3"))
#
# Estudo descritivo
#
library(lattice)
xyplot(bdi~time |length, groups=subject, xlab="Tempo" ,data=BtheB_long, type='l',
       main="Resultado na escala de depress�o de Beck \n segundo dura��o do epis�dio actual de depress�o")
#
xyplot(bdi~time |treatment, groups=subject, xlab="Tempo" ,data=BtheB_long, type='l',
       main="Resultado na escala de depress�o de Beck \n segundo o tratamento ao qual foram alocados")
#
xyplot(bdi~time |drug, groups=subject, xlab="Tempo" ,data=BtheB_long, type='l',
       main="Resultado na escala de depress�o de Beck \n segundo o paciente tome ou n�o antidepressivos")
#
# Percebe-se que na primeira situa��o, a resposta segundo a dura��o do epis�dio atual de depress�o, os 
# pacientes com epis�dio mais prolongado tiveram respostas superiores durante o estudo. Nas outras duas 
# situa��es n�o foram percebidas diferen�as entre os grupos.
#
# Uma outra forma de apresentar a resposta � atrav�s de gr�ficos de box-plot, para isso organiza-se a 
# base de dados da seguinte forma.
#
ylim = range(BtheB[,grep("bdi", names(BtheB))],na.rm = TRUE)
#
tau = subset(BtheB, treatment == "TAU")[,grep("bdi", names(BtheB))]
#
# Para apresentar os dois gr�ficos na mesma janela fazemos
#
layout(matrix(1:2, nrow = 1))
#
boxplot(tau, main = "Treated as usual", ylab = "BDI",
        xlab = "Time (in months)", names = c(0, 2, 4, 6, 8),ylim = ylim)
#
btheb = subset(BtheB, treatment == "BtheB")[,grep("bdi", names(BtheB))]
#
boxplot(btheb, main = "Beat the Blues", ylab = "BDI",
        xlab = "Time (in months)", names = c(0, 2, 4, 6, 8),lim = ylim)
#
# Utilizaremos modelos de regress�o mistos, isto �, modelos de regress�o normais com efeitos fixos e 
# aleat�rios. A utiliza��o dos efeitos aleat�rios objetiva absorver a variabilidade dos dados para melhor
# estima��o e verifica��o da influ�ncia dos efeitos fixos na resposta.
#
attach(BtheB_long)
library("nlme")
#
# A primeira observ��o � de que a variabilidade ou dispers�o entre as resposta seja causa das pr�prias 
# unidades experimentais (pacientes), por isso consideramos coo efeito aleat�rio cada paciente
#
BtheB.1 = lme(bdi ~ bdi.pre + time + treatment + drug + length, random=~ 1 | subject, na.action = na.omit)
#
# Agora vamos considerar que a dispers�o das respostas dependa do instante de tempo e n�o mais de cada 
# paciente
#
BtheB.2 = lme(bdi ~ bdi.pre + time + treatment + drug + length, random=~ factor(time) | subject,na.action = na.omit)
#
# Vejamos se os modelos diferem
#
anova(BtheB.1, BtheB.2)
#
# Concluimos que os modelos s�o semelhantes, por isso, escolhemos o mais simples
#
AIC(BtheB.1,BtheB.2)
#
# Desta forma escolhemos como mais adequado o modelo em BtheB.1
#
summary(BtheB.1, cor=FALSE)
intervals(BtheB.1, which="fixed")
#
# Observamos que a vari�vel length n�o � significativa, a retiramos do modelo
#
BtheB.3 = update(BtheB.1, ~.-length)
#
summary(BtheB.3, cor=FALSE)
intervals(BtheB.3, which="fixed")
#
# Decidimos que a tratamento (treatment) permane�a no modelo, pelo interesse experimental
#
# Vejamos os res�duos
#
library(car)
#
qqPlot(residuals(BtheB.3), ylab="Res�duos", xlab="Quantis normais")
#
plot(BtheB.3, subject ~ resid(.), cex=0.8)
#
plot(BtheB.3, bdi ~ resid(.), pch=19, cex=0.8)
#
# Aceitamos o modelo em BtheB.3
#
# Coeficientes estimados nos termos fixos
#
fixef(BtheB.3)
#
# Apresentando os resultados
#
linha1 = c(fixef(BtheB.3)%*%c(1,mean(bdi.pre),2,1,1),fixef(BtheB.3)%*%c(1,mean(bdi.pre),4,1,1),
           fixef(BtheB.3)%*%c(1,mean(bdi.pre),6,1,1),fixef(BtheB.3)%*%c(1,mean(bdi.pre),8,1,1))
#
linha2 = c(fixef(BtheB.3)%*%c(1,mean(bdi.pre),2,0,1),fixef(BtheB.3)%*%c(1,mean(bdi.pre),4,0,1),
           fixef(BtheB.3)%*%c(1,mean(bdi.pre),6,0,1),fixef(BtheB.3)%*%c(1,mean(bdi.pre),8,0,1))
#
linha3 = c(fixef(BtheB.3)%*%c(1,mean(bdi.pre),2,1,0),fixef(BtheB.3)%*%c(1,mean(bdi.pre),4,1,0),
           fixef(BtheB.3)%*%c(1,mean(bdi.pre),6,1,0),fixef(BtheB.3)%*%c(1,mean(bdi.pre),8,1,0))
#
linha4 = c(fixef(BtheB.3)%*%c(1,mean(bdi.pre),2,0,0),fixef(BtheB.3)%*%c(1,mean(bdi.pre),4,0,0),
           fixef(BtheB.3)%*%c(1,mean(bdi.pre),6,0,0),fixef(BtheB.3)%*%c(1,mean(bdi.pre),8,0,0))
#
y1 = min(linha1,linha2,linha3,linha4)
y2 = max(linha1,linha2,linha3,linha4)
#
par(mar=c(4,5,1,1))
plot(c(2,4,6,8), linha1, ylim=c(y1-1,y2+1), xlab="Tempos", 
     ylab="Resposta m�dia estimada \n ao teste de depress�o de Beck", type="l")
lines(c(2,4,6,8), linha2, col="red")
lines(c(2,4,6,8), linha3, col="green")
lines(c(2,4,6,8), linha4, col="yellow")
#
legend(4.5,20, legend=c("TAU sem droga","Beat the Blues sem droga"), col=c("yellow","green"), lty=1, cex=0.7)
legend(2,11, legend=c("Beat the Blues com droga","TAU com droga"), col=c("black","red"), lty=1, cex=0.7)
