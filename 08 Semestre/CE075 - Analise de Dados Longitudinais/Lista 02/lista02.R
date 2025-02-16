sb <- 4
b1 <- -1.6978
sb1 <- 0.3304

exp(b1+1.96*(4.3284))/(1+exp(b1+1.96*(4.3284)))
exp(b1-1.96*(4.3284))/(1+exp(b1-1.96*(4.3284)))

qnorm(p = 0.99)



rm(list = ls())

#install.packages("foreign")
library(foreign)

dados <- read.dta("toenail.dta")
dados$trt <- as.factor(dados$trt)
summary(dados)
str(dados)

##----------------------------------------------------------------------------------------------------
## 12.1.1 - a)
##----------------------------------------------------------------------------------------------------

#install.packages("geepack")
library(geepack)
gee <- geeglm(y~month+month*trt-trt,
              family=binomial(link="logit"), data=dados, id=id,
              corstr ="exchangeable", std.err="san.se")
summary(gee)
1-exp(-0.1713)

##----------------------------------------------------------------------------------------------------
## 12.1.2 - b) Interpreta�??o do par�metro ??2 do modelo (correspondente ao m??s) 
##----------------------------------------------------------------------------------------------------

coef(gee)[2]
1-exp(-0.1713)
1-exp(-0.1713*2)

# Estima-se que para a popula�??o de indiv�duos que est??o sob o tratamento B a chance de a ocon�lise
# evoluir a um estado moderado ou severo diminui em 15.74% (1 ??? exp(??2)) ap�s 1 m??s de tratamento. J�
# para a popula�??o sob mesma condi�??o, por�m, ap�s 2 meses de tratamento, a chance diminui em 29.01%
# (1 ??? exp(??2 ??? 2)).
# J� para a popula�??o que est� submetida sob o tratamento A estima-se que a chance de a ocon�lise evoluir
# a um estado moderado ou severo diminui em 22.04% (1 ??? exp(??2 + ??3)) ap�s 1 m??s de tratamento. J�
# para a popula�??o sob mesma condi�??o, por�m, ap�s 2 meses de tratamento, a chance diminui em 34.32%
# (1 ??? exp(??2 ??? 2 + ??3 * 2)).

1-exp(-0.1713-0.077)
1-exp((-0.1713*2) + (-0.077*2))


##----------------------------------------------------------------------------------------------------
## 12.1.3 - c) Interpreta�??o do par�metro ??3 do modelo (correspondente ?? intera�??o tratamento.m??s)
##----------------------------------------------------------------------------------------------------

coef(gee)[3]

# Estima-se que para a popula�??o de indiv�duos que est??o submetidos ao tratamento A tem-se uma chance de
# 7.48% (1 ??? exp(??3)) de ocorrer onic�lise moderada ou severa menor do que o grupo que est� submetido ao
# tratamento B.

1-exp(-0.077)

##----------------------------------------------------------------------------------------------------
## 12.1.4 - d) Gr�fico de log(Odd) dos tratamentos em fun�??o do m??s.
##----------------------------------------------------------------------------------------------------
# install.packages("lattice")
library(lattice)
tabela1 <- data.frame(grupo=rep(c("A","B"),each=19),
                      m??s=rep(c(0:18),times=2),
                      dimlogodd=c((coef(gee)[1]+coef(gee)[2]*0:18+coef(gee)[3]*0:18),
                                  (coef(gee)[1]+coef(gee)[2]*0:18)))

xyplot(dimlogodd ~ m??s,
       groups=grupo,
       type=c("p","l"),
       ylab=list("Diminui�??o no log odds"),
       grid=T,
       main="Figura 1",
       auto.key=list(columns=2, cex.title=1,
                     title=expression('Grupos')),
       data=tabela1)

# Pela Figura 1 tem-se que h� uma tend??ncia de diminui�??o no logodds para ambos os grupos. Para o grupo
# A a diminui�??o � mais acentuada do que para o grupo B. Assim, para o grupo A tem-se que o efeito do
# tratamento no tempo � maior do que para o grupo B.

##----------------------------------------------------------------------------------------------------
## 12.1.5 - e) Modelo misto com intercepto aleat�rio:
##----------------------------------------------------------------------------------------------------

# install.packages("lme4")
library(lme4)
#  logit(E(Yi ) = (??1 + b_i) + ??2 ??? month_ij + ??3 ??? treatment_i ??? month_ij

m1 <- glmer(y~(1|id)+month+month*trt-trt,
            family=binomial,
            nAGQ=20,
            data=dados)
summary(m1)


##----------------------------------------------------------------------------------------------------
## 12.1.6 - f) Estimativa de ????_b
##----------------------------------------------------------------------------------------------------

VarCorr(m1)

# Verifica-se que a vari�ncia do intercepto aleat�rio � igual a 16, um valor elevado. Assim, h� uma grande
# variabilidade na propens??o de experimentar maior grau de infec�??o de unha do p�. Tem-se o seguinte intervalo
# de 95 % de confian�a para a propens??o:
# 0-1
# Praticamente uma varia�??o de 0 a 100 % de propens??o.


##----------------------------------------------------------------------------------------------------
## 12.1.7 - g) O par�metro ??2 � o seguinte:
##----------------------------------------------------------------------------------------------------

m1@beta[2]

# Estima-se que para um indiv�duo do grupo que est� sob o tratamento B a chance de a ocon�lise evoluir a um
# estado moderado ou severo diminui em 32.18% (1 ??? exp(?? 2 )) ap�s 1 m??s de tratamento. J� ap�s 2 meses de
# tratamento, a chance diminui em 54% (1 ??? exp(?? 2 ??? 2)).
# J� para um indiv�duo que est� submetida sob o tratamento A estima-se que a chance de a ocon�lise evoluir
# a um estado moderado ou severo diminui em NA% (1 ??? exp(?? 2 + ?? 3 )) ap�s 1 m??s de tratamento. J� ap�s
# 2 meses de tratamento, a chance diminui em 60.11% (1 ??? exp(?? 2 ??? 2 + ?? 3 )). Pode interpretar tamb�m em
# fun�??o do log Odds, sendo que para um indiv�duo pertencente ao grupo B estima-se que o log Odds diminui
# linearmente em -0.3883 ap�s 1 m??s e para um indiv�duo pertencente ao grupo A diminui linearmente em
# -0.5307 ap�s 1 m??s.

##----------------------------------------------------------------------------------------------------
## 12.1.8 - h) O par�metro ??3 � o seguinte:
##----------------------------------------------------------------------------------------------------

m1@beta[3]

# Estima-se que para um indiv�duo que est� submetidos ao tratamento A tem-se uma chance de 13.27
# (1 ??? exp(?? 3 )% menor de ocorrer onic�lise moderada ou severa menor do que o grupo que um indiv�duo que
# est� submetido ao tratamento B, sendo que este indiv�duo possui o mesmo risco de experimentar maior grau
# de infec�??o de unha do p� quando da aleatoriza�??o.


##----------------------------------------------------------------------------------------------------
## 12.1.9 - i)  Para os dois modelos as estimativas de ??3 s??o as seguintes:
##----------------------------------------------------------------------------------------------------

coef(gee)[3] # Modelo marginal

m1@beta[3]   # Modelo misto de efeito aleat�rio
  
# Conforme verificado a a chance de a ocon�lise evoluir a um estado moderado ou severo em rela�??o ao grupo
# de tratamento B � de 7.48% menor utilizando o modelo marginal, j� utilizando um modelo misto de efeito
# aleat�rio � de 13.27% menor. Isto ocorreu pois h� uma diferen�a na interpreta�??o do ?? 3 para os dois modelos.
# Para o modelo de efeitos mistos o par�metro se refere ao efeito do tratamento na diminui�??o da chance de
# evolu�??o da ocon�lise em um determinado indiv�duo. J� no caso do modelo marginal refere-se ?? preval??ncia
# de indiv�duos com ocon�lise moderada ou severa na popula�??o em rela�??o ao tratamento B contra o A.

##----------------------------------------------------------------------------------------------------
## 12.1.10 - j)  Variando os pontos de quadratura do modelo:
##----------------------------------------------------------------------------------------------------

# N�mero de pontos de quadratura = 2
m12 <- glmer(y~(1|id)+month+month*trt-trt,
             family=binomial,
             nAGQ=2,
             data=dados)
# N�mero de pontos de quadratura = 5
m15 <- glmer(y~(1|id)+month+month*trt-trt,
             family=binomial,
             nAGQ=5,
             data=dados)
# N�mero de pontos de quadratura = 10
  m110 <- glmer(y~(1|id)+month+month*trt-trt,
                family=binomial,
                nAGQ=10,
                data=dados)
# N�mero de pontos de quadratura = 20
m120 <- glmer(y~(1|id)+month+month*trt-trt,
              family=binomial,
              nAGQ=20,
              data=dados)
# N�mero de pontos de quadratura = 30
m130 <- glmer(y~(1|id)+month+month*trt-trt,
              family=binomial,
              nAGQ=30,
              data=dados)
# N�mero de pontos de quadratura = 50
m150 <- glmer(y~(1|id)+month+month*trt-trt,
              family=binomial,
              nAGQ=30,
              data=dados)
summary(m150)

# Estimativas dos par�metros utilizando o n�mero de pontos de quadratura descritos nas colunas.
t(data.frame("2 pontos"=summary(m12)$coefficients[,1:2],
             "5 pontos"=summary(m15)$coefficients[,1:2],
             "10 pontos"=summary(m110)$coefficients[,1:2],
             "20 pontos"=summary(m120)$coefficients[,1:2],
             "30 pontos"=summary(m130)$coefficients[,1:2],
             "50 pontos"=summary(m150)$coefficients[,1:2],
             check.names=FALSE))

# Verifica-se que para estimar bem os par�metros necessita-se acima de 20 pontos de quadratura, tanto para a
# estimativas do valor pontual quanto para o erro padr??o dos par�metros.

# Estimativa do erro padr??o do intercepto aleat�rio
data.frame("2 pontos"=3.2452,
           "5 pontos"=3.6903,
           "10 pontos"=4.0606,
           "20 pontos"=4.0017,
           "30 pontos"=4.0058,
           "50 pontos"=4.0058,
           check.names=FALSE)

# Para estimar bem o erro padr??o do intercepto aleat�rio � necess�rio uma quadratura acima de 20 pontos de
# quadratura. Conclui-se que os resultados dependem do n�mero de pontos de quadratura.