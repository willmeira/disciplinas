### Regress�o para dados bin�rios
require(ggplot2)

### Exemplo 2
### Dados de mum experimento do tipo dose-resposta, referente � mortalidade 
### de besouros sob tr�s tratamentos (DDT, BHC e DDT+BHC), sob seis diferentes
### doses. 

ldose <- log(rep(c(2, 2.64, 3.48, 4.59, 6.06, 8), 3)) ### log-dose

Trat <- rep(c('DDT', 'BHC', 'DDT+BHC'), each = 6) ### tratamento

Resposta <- c(3, 5, 19, 19, 24, 35, 2, 14, 20, 27, 41, 40, 28, 37, 46, 48, 48, 50)
### N�mero de insetos mortos sob cada condi��o experimental.

n <- c(50, 49, 47, 50, 49, 50, 50, 49, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50)
### N�mero de insetos submetidos a cada condi��o experimental.

dados <- data.frame(ldose,Trat,Resposta,n)

### An�lise descritiva.
x11()
g0 <- ggplot(dados, aes(x = ldose, y = Resposta/n, color=Trat)) +
  geom_point(size = 4) + theme_bw(base_size = 18) + 
  labs(x = 'Dose(log)', y = 'Propor��o de insetos mortos') +
  theme(legend.position="top")
g0

################################################################################
### Parte 1 - Vamos come�ar ajustando um modelo apenas para os insetos 
### tratados com BHC. 

data_BCH <- subset(dados, Trat=='BHC')

g1 <- ggplot(data_BCH, aes(x = ldose, y = Resposta/n)) +
  geom_point(size = 4) + theme_bw(base_size = 18) + 
  labs(x = 'Dose(log)', y = 'Propor��o de insetos mortos') +
  theme(legend.position="top")
g1

### Modelo com fun��o de liga��o logito.
ajuste1 <- glm(cbind(Resposta, n-Resposta) ~ ldose, family = binomial, 
               subset = Trat=='BHC') 
### A primeira forma de declarar a resposta quando temos um glm binomial 
### com dados grupados � por umja matriz com duas colunas, cada uma delas
### com as contagens de um dos desfechos bin�rios (insetos mortos e n�o
### mortos, no caso).

### Forma alternativa:
ajuste1_2 <- glm(Resposta/n ~ ldose, family = binomial, data = data_BCH, 
                 weights = n) 
### Neste caso, declaramos a resposta como a fra��o de insetos mortos, e
### o n�mero de insetos mortos � declarado em weights.

summary(ajuste1)
summary(ajuste1_2)
### Os modelos ajustados s�o rigorosamente os mesmos. Muda apenas a forma de 
### declara��o.

### Exerc�cio: Escreva a equa��o do modelo ajustado e calcule a estimativa 
### da probabilidade de morte para insetos submetidos a uma dose de 7 unidades.
### Adicionalmente, interprete (se couber) os par�metros do modelo.

### Agora, vamos adicionar ao gr�fico a curva referente ao modelo ajustado.
grid_ldose <- seq(log(2), log(8), 0.01) ### grid de valores para a (log) dose.
preditos <- predict(ajuste1, newdata=data.frame(ldose = grid_ldose), type='response')

### Probabilidades estimadas para as doses no grid que criamos.
new.data <- data.frame(grid_ldose, preditos)

g2 <- g1 + geom_line(data = new.data, aes(x = grid_ldose, y = preditos),  
                     size = 1.2, color = 'black')
g2

################################################################################
### Modelo com fun��o de liga��o probito
ajuste2 <- glm(Resposta/n ~ ldose, family = binomial(link = 'probit'), 
               subset = Trat == 'BHC', weights = n)
summary(ajuste2) 
### Exerc�cio: Escreva a equa��o do modelo ajustado e calcule a estimativa 
### da probabilidade de morte para insetos submetidos a uma dose de 7 unidades.

### Adicionando ao gr�fico a curva referente ao odelo ajustado.
preditos2 <- predict(ajuste2, newdata=data.frame(ldose = grid_ldose), type='response')
new.data2 <- data.frame(grid_ldose, preditos2)

g3 <- g2 + geom_line(data = new.data2, aes(x = grid_ldose, y = preditos2),  
                     size = 1.2, color = 'blue')
g3

################################################################################
### Modelo com fun��o de liga��o complemento log-log
ajuste3 <- glm(Resposta/n ~ ldose, family = binomial(link = 'cloglog'), 
               subset = Trat == 'BHC', weights = n)
summary(ajuste3) 
### Exerc�cio: Escreva a equa��o do modelo ajustado e calcule a estimativa 
### da probabilidade de morte para insetos submetidos a uma dose de 7 unidades.

### Adicionando ao gr�fico a curva referente ao odelo ajustado.
preditos3 <- predict(ajuste3, newdata = data.frame(ldose = grid_ldose), type='response')
new.data3 <- data.frame(grid_ldose, preditos3)

g4 <- g3 + geom_line(data = new.data3, aes(x = grid_ldose, y = preditos3),  
                     size = 1.2, color = 'green')
g4



################################################################################
### Vamos comparar os ajustes dos tr�s modelos calculando os respectivos AICs.

AIC(ajuste1, ajuste2, ajuste3)
c(logLik(ajuste1), logLik(ajuste2), logLik(ajuste3)) 
### Log-verossimilhan�as maximizadas.

### Exerc�cio - Avaliar a qualidade dos ajustes com base nas deviances 
### (teste ao n�vel de signific�ncia de 5%). Fa�a tamb�m qqplots com envelopes simulados.

################################################################################
################################################################################
################################################################################
### Parte 2 - Agora, vamos analisar os tr�s tratamentos conjuntamente. Nesta  
### etapa, vamos usar apenas a fun��o de liga��o logito

### Gr�fico de dispers�o.
x11()
h0 <- ggplot(dados, aes(x = ldose, y = Resposta/n, color=Trat)) +
     geom_point(size = 4) + theme_bw(base_size = 18) + 
     labs(x = 'Dose(log)', y = 'Propor��o de insetos mortos') +
     theme(legend.position="top")
h0
### Conforme discutido em aula, vamos considerar tr�s modelos, conforme descrito na sequ�ncia:

### ajuste4 - Modelo de retas coincidentes - Sem considerar o efeito de tratamento. 
### ajuste5 - Modelo de retas paralelas - Considerando o efeito de tratamento apenas 
### no intercepto (modelo aditivo). 
### ajuste6 - Modelo de retas concorrentes - Sem considerar o efeito de tratamento 
### no intercepto e associado � dose (modelo multiplicativo - com efeito de intera��o).. 

################################################################################
### Modelo de retas coincidentes.

ajuste4 <- glm(cbind(Resposta,n-Resposta) ~ ldose, family = binomial, data = dados)
### Este � o modelo mais simples, em que ajustamos uma �nica reta (na escala do 
### preditor, curva na escala da resposta) para os tr�s tratamentos.
summary(ajuste4)

### Adicionando o modelo ajustado ao gr�fico.
preditos4 <- predict(ajuste4, newdata=data.frame(ldose = grid_ldose), type='response')
new.data4 <- data.frame(grid_ldose, preditos4)

h1 <- h0 + geom_line(data = new.data4, aes(x = grid_ldose, y = preditos4),  
                     size = 1.2, color = 'black')
h1

################################################################################
### Modelo de retas paralelas.

ajuste5 <- glm(cbind(Resposta,n-Resposta) ~ ldose + Trat, family = binomial, data = dados)
### Este � o modelo intermedi�rio (aditivo), em que ajustamos retas paralelas 
### (na escala do preditor) para os tr�s tratamentos.
summary(ajuste5)

### Agora, para predi��o precisamos de um grid de valores para cada inseticida.
### Vamos usar a fun��o expand.grid para isso.

trat <- levels(dados$Trat)
grid_trat <- expand.grid(grid_ldose, trat)
names(grid_trat) <- c("grid_ldose", "trat")
preditos5 <- predict(ajuste5, newdata = data.frame(ldose = grid_trat[,1], Trat = grid_trat[,2]), 
                     type='response')
new.data5 <- data.frame(grid_trat, preditos5)

h0 + geom_line(data = subset(new.data5, trat == 'BHC'), aes(x = grid_ldose, y = preditos5),  
               size = 1.2, color = 'red') +
     geom_line(data = subset(new.data5, trat == 'DDT'), aes(x = grid_ldose, y = preditos5),  
               size = 1.2, color = 'green') +
     geom_line(data = subset(new.data5, trat == 'DDT+BHC'), aes(x = grid_ldose, y = preditos5),  
               size = 1.2, color = 'blue')
### Adicionando as curvas de mortalidade vs dose para cada inseticida. 

################################################################################
### Modelo de retas concorrentes.

ajuste6 <- glm(cbind(Resposta, n-Resposta) ~ ldose * Trat, family = binomial, data = dados)
### Este � o modelo mais completo (multiplicativo - com intera��o), em que ajustamos 
### retas concorrentes (na escala do preditor) para os tr�s tratamentos.
summary(ajuste6)

preditos6 <- predict(ajuste6, newdata = data.frame(ldose = grid_trat[,1], Trat = grid_trat[,2]), type='response')
new.data6 <- data.frame(grid_trat, preditos6)

h0 + geom_line(data = subset(new.data6, trat == 'BHC'), aes(x = grid_ldose, y = preditos6),  
               size = 1.2, color = 'red') +
     geom_line(data = subset(new.data6, trat == 'DDT'), aes(x = grid_ldose, y = preditos6),  
               size = 1.2, color = 'green') +
     geom_line(data = subset(new.data6, trat == 'DDT+BHC'), aes(x = grid_ldose, y = preditos6),  
               size = 1.2, color = 'blue')

################################################################################
### Compara��o dos ajustes dos tr�s modelos.

### Pelo fato dos tr�s modelos serem encaixados, vamos compar�-los usando o TRV.
anova(ajuste4, ajuste5, ajuste6, test = 'Chisq')

### Repare, olhando para as duas primeiras linhas, que os modelos de retas coincidentes 
### e retas paralelas produzem desvios significativamente diferentes.
### Nesse caso, dentre os dois modelos, optamos pelo n�o restrito (retas paralelas). 
### No entanto, ao observar as duas �ltimas linhas, verificamos que os
### dois ajustes produzem desvios que n�o apresentam diferen�a significativa. 
### Nesse caso, podemos optar pelo modelo restrito (retas paralelas).
### Pela an�lise dos desvios, baseado nos TRVs, o modelo de retas paralelas 
### (efeito de tratamento no intercepto) � prefer�vel.

AIC(ajuste4,ajuste5,ajuste6)
### Repare que tamb�m atrav�s dos AICs tem-se indicativo de melhor ajuste para o 
### modelo de retas paralelas.

### Observando os resultados do summary, verifica-se que o modelo de retas paralelas 
### tem deviance 21,282, associado a 14 graus de liberdade. Vamos testar a qualidade do ajuste.

pchisq(21.282, 14, lower.tail = F) 
### Ao n�vel de signific�ncia de 5% n�o se tem evid�ncia significativa de falta de ajuste.

### Exerc�cio - Para o modelo escolhido:

# 1- Escrever o modelo ajustado na escala do preditor, da chance e da probabilidade de resposta;
# 2- Interpretar as estimativas dos par�metros do modelo;
# 3- Obter ICs 95% para os par�metros do modelo;
# 4- Estimar a probabilidade de morte para doses de 3 e 7 unidades para cada tratamento.
# 5- Obter ICs 95% para as probabilidades mencionadas no item anterior;
# 6- Estimar, para cada tratamento, as doses letais 50% e 90%;
# 7- Fazer uma an�lise de diagn�stico, baseada na avalia��o dos res�duos e de medidas de influ�ncia.