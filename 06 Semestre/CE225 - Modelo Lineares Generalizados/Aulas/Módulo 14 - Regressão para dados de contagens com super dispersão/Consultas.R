########################################################################
########################################################################
### Modelos para dados com excesso de zeros.

require("faraway")
require("gamlss")
help(dvisits)

### Vamos modelar o n�mero de visitas ao m�dico nas duas �ltimas semanas 
### (doctorco) em fun��o de algumas das covari�veis da base.

dvisits <- dvisits[sample(1:nrow(dvisits)),]
### Apenas ordenando as linhas da base de forma aleat�ria (estavam dispostas
### de forma sistem�tica).

dvisits$sex <- as.factor(dvisits$sex)
levels(dvisits$sex) <- c('Masculino', 'Feminino')
dvisits$levyplus <- factor(dvisits$levyplus)
levels(dvisits$levyplus) <- c('Publico', 'Particular')
dvisits$chcond1 <- factor(dvisits$chcond1)
levels(dvisits$chcond1) <- c('Nao cronico', 'Cronico')
### Convertendo algumas das vari�veis para fator e renomeando os n�veis.

tabela <- table(dvisits$doctorco)
barplot(tabela)
### O gr�fico de barras evidencia uma grande freq�ncia de indiv�duos com 
### zero consultas.

### Todos os ajustes na sequ�ncia foram realizados usando a biblioteca
### gamlss (mesmo aqueles que poderiam ser feitos usando a fun��o glm, 
### para fins de padroniza��o).

### Vamos avaliar os ajustes de seis modelos distintos:

### Modelo 1: Poisson (sem infla��o de zeros)

modelo1 <- gamlss(doctorco ~ sex + age + agesq 
                  + income + levyplus + illness + actdays + chcond1 + hospadmi 
                  + medicine, family = PO, data = dvisits)
x11()
plot(modelo1) 
### A biblioteca gamlss tem como padr�o os res�duos quant�licos aleatorizados.
### O qqplot indica a n�o normalidade dos res�duos e, consequentemente,
### o desajuste do modelo.

### Modelo 2: Binomial negativa (sem infla��o de zeros)
modelo2 <- gamlss(doctorco ~ sex + age + agesq + income + levyplus + illness + 
                      actdays + chcond1 + hospadmi + medicine, family = NBI, 
                  data = dvisits)
x11()
plot(modelo2)
### A an�lise de res�duos indica melhor ajuste em rela��o ao modelo de Poisson.
### Mas ainda se observa algum desajuste.

### Modelo 3: Poisson com infla��o de zeros (mas sem covari�veis para o componente
### do excesso de zeros)

modelo3 <- gamlss(doctorco ~ sex + age + agesq + income + levyplus + illness + 
                      actdays + chcond1 + hospadmi + medicine,
                  family = ZIP, data = dvisits) 
plot(modelo3)
### Problemas de ajuste semelhantes ao modelo de Poisson sem infla��o.

### Modelo 4: Binomial negativa com infla��o de zeros (mas sem covari�veis para o componente
### do excesso de zeros)

modelo4 <- gamlss(doctorco ~ sex + age + agesq + income + levyplus + illness + 
                      actdays + chcond1 + hospadmi + medicine,
                  family = ZINBI, data = dvisits) 
plot(modelo4)

### Modelo 5: Poisson com infla��o de zeros (incluindo as covari�veis tamb�m na modelagem 
### do componente do excesso de zeros)

modelo5 <- gamlss(doctorco ~ sex + age + agesq + income + levyplus + illness + 
                      actdays + chcond1 + hospadmi + medicine,
                     sigma.formula = ~ sex + age + agesq + income + levyplus + 
                      illness + actdays + chcond1 + hospadmi + medicine, 
                     family = ZIP, data = dvisits) 
plot(modelo5)
### Observe que para incluir covari�veis na modelagem do par�metro do excesso
### de zeros, tivemos que declarar uma segunda f�rmula em "sigma.formula = ~ ..."

### Modelo 6: Binomial negativa com infla��o de zeros (incluindo as covari�veis 
### tamb�m na modelagem do componente do excesso de zeros)

modelo6 <- gamlss(doctorco ~ sex + age + agesq + income + levyplus + illness + 
                      actdays + chcond1 + hospadmi + medicine,
                  nu.formula = ~ sex + age + agesq + income + levyplus + 
                      illness + actdays + chcond1 + hospadmi + medicine,
                  family = ZINBI, data = dvisits) 
plot(modelo6)
### No caso da binomial negativa, para incluir covari�veis na modelagem do par�metro do excesso
### de zeros, tivemos que declarar uma segunda f�rmula em "nu.formula = ~ ...".
### Isso porque, para a ZINB, o gamlss identifica sigma como o par�metro de dispers�o.

### Vamos comparar os modelos pelos respectivos AICs.

AIC(modelo1, modelo2, modelo3, modelo4, modelo5, modelo6)

### Observe que o modelo 6 (ZIBN com covari�veis para o excesso de zeros)
### foi aquele que produziu menor AIC. Pelos gr�ficos de res�duos, adicionalmente,
### fica claro que � o que proporciona melhor ajuste. Vamos explorar
### um pouco mais ele.

summary(modelo6)

### Observe que o resumo do modelo � separado em duas partes: a primeira para
### a m�dia da binomial negativa e a segunda para a probabilidade de zeros excedentes.

### Podemos observar que a probabilidade associada ao excesso de zeros �
### menor para pacientes do sexo feminino; diminui conforme o n�mero de enfermidades
### nas �ltimas duas semanas (illness); diminui conforme o n�mero de dias inativos 
### nas �ltimas duas semanas (actdays); diminui conforme o n�mero de medica��es
### prescritas nas �ltimas duas semanas (medicine).

### Ao olhar para a parte da binomial negativa, verificamos que a frequ�ncia de consultas,
### em m�dia, aumenta conforme o n�mero de dias inativos (actdays);
### aumenta conforme o n�mero de noites internado (hospadmi) e aumenta
### conforme o n�mero de medica��es prescritas (medicine).

### Deixo como tarefa escrever as express�es dos modelos ajustados e explorar os efeitos.

### Apenas para fins de ilustra��o, vamos ajustar um modelo apenas com as vari�veis
### com efeito marginalmente significativo ao n�vel de 5% (al�m da idade, para o
### componente do excesso de zeros).

modelo7 <- gamlss(doctorco ~ actdays + hospadmi + medicine,
                  nu.formula = ~ sex + age + agesq +illness + actdays + medicine,
                  family = ZINBI, data = dvisits)

LR.test(modelo7, modelo6) ### Comparando os modelos via teste da raz�o de verossimilhan�as.
### Os ajustes n�o diferem significativamente. Podemos adotar o modelo 7, portanto.

plot(modelo7)
summary(modelo7)
### Embora as estimativas, numericamente, tenham sido alteradas, as conclus�es
### apresentadas anteriormente se mant�m.

confint(modelo7, what = 'mu')
confint(modelo7, what = 'nu')
### Intervalos de confian�a.

pmu <- predict(modelo7, what = 'mu', type = 'response')
### Valores ajustados para a m�dia da binomial negativa para cada linha da base.

pnu <- predict(modelo7, what = 'nu', type = 'response')
### Valores ajustados para a probabilidade de zero excedente para cada linha da base.

pmu * (1-pnu)
### Valores ajustados para o n�mero esperado de consultas para cada linha da base.