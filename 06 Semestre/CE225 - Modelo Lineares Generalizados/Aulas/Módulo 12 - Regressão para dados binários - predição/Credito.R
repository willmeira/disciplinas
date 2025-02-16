
### Dados sobre concess�o numa institui��o cr�dito alem�.
### Na p�gina da disciplina h� um arquivo com informa��es sobre as vari�veis.

### In�cio da an�lise
dados <- read.table('https://docs.ufpr.br/~taconeli/CE22516/Credito.txt', header = T)
head(dados)
summary(dados)

dados$Status <- factor(dados$Status)
levels(dados$Status) <- c('Good', 'Bad')
dados$Status <- relevel(dados$Status, ref = 'Bad')
### O motivo de redefinir o n�vel de refer�ncia � para modelarmos a probabilidade
### de um bom pagador. Para isso, devemos definir o n�vel de refer�ncia como o
### outro (Bad).

dim(dados)
summary(dados$Status)

### Exerc�cio - Fazer uma an�lise descritiva (uni e bivariada), buscando avaliar, 
### de forma preliminar por meio de gr�ficos e medidas resumo, 
### a rela��o entre as covari�veis e a resposta.

### Vamos separar, aleatoriamente, a base em duas: uma para o ajuste do 
### modelo (com 700 observa��es) e outra para valida��o (com 300 observa��es).

set.seed(898)
indices <- sample(1:1000, size = 700) 
### indices � um vetor com n�meros de 1 a 1000 numa sequ�ncia aleat�ria.

dadosajuste <- dados[indices,]
### dataframe com as 700 linhas para ajuste.

dadosvalid <- dados[-indices,]
### dataframe com 300 linhas, apenas para valida��o.


########################################################################

### Vamos ajustar um modelo de regress�o log�stica, com as covari�veis selecionadas
### via Backward(AIC)

ajuste <- step(glm(Status ~ .,family=binomial,data = dadosajuste), direction = 'backward') 
data.frame(ajuste$y, dadosajuste$Status)
### Apenas para conferir para quais categorias est� atribuindo 0 e 1.

summary(ajuste)
### Resumo do ajuste.

paj2 <- predict(ajuste, type='response', newdata=dadosajuste)
### Probabilidades estimadas para os indiv�duos da base de ajuste;

pval2 <-predict(ajuste, type='response', newdata=dadosvalid) 
### Probabilidades estimadas para os indiv�duos da base de valida��o.

round(pval2 * 1000) ### Escores de cr�dito.

################################################################################
### Usando o modelo ajustado para classifica��o dos clientes da base de valida��o.

### Como fica se usarmos pc=0,5 como ponto de corte para classifica��o, ou seja:
# Classificar como mau pagador se p < 0,5;
# Classificar como bom pagador se p >= 0,5.

### Vamos cruzar realidade e predi��o para diferentes pontos de corte.

classp0.5 <- factor(ifelse(pval2 >= 0.5, 'PredGood', 'PredBad'))
classp0.5 ### Classifica��es usando o ponto de corte 0,5.
data.frame(pval2, classp0.5) ### Probabilidades estimadas e classifica��es.

### Classificando como "Devedores" indiv�duos com p > 0,5.
tabela1 <- table(classp0.5,dadosvalid$Status) 
tabela1

### Vamos estimar a sensibilidade e a especificidade referentes a esta regra de decis�o.
sensp0.5 <- sum(classp0.5 == 'PredGood' & dadosvalid$Status == 'Good')/sum(dadosvalid$Status == 'Good')
sensp0.5
espec0.5 <- sum(classp0.5 == 'PredBad' & dadosvalid$Status == 'Bad')/sum(dadosvalid$Status == 'Bad')
espec0.5

### E se us�ssemos os dados de ajuste para calcular a sensibilidade e a especificidade?

classp0.5aj <- factor(ifelse(paj2 >= 0.5, 'PredGood', 'PredBad'))
sensp0.5aj <- sum(classp0.5aj == 'PredGood' & dadosajuste$Status == 'Good')/sum(dadosajuste$Status == 'Good')
sensp0.5aj
espec0.5aj <- sum(classp0.5aj == 'PredBad' & dadosajuste$Status == 'Bad')/sum(dadosajuste$Status == 'Bad')
espec0.5aj
# Observe que ao usar os dados de ajuste, tanto a sensibilidade quanto a especificidade
# s�o maiores. Isso refor�a a import�ncia de se usar dados de valida��o para
# avaliar adequadamente o desempenho preditivo do modelo.

# Observe que ao usar pc = 0,5, temos uma regra de classifica��o com elevada 
# sensibilidade (0,84), mas baixa especificidade (0,49). Assim, a capacidade
# de se predizer um bom pagador � alta, mas o poder preditivo para maus pagadores
# � baixo (vamos acertar aproximadamente metade das vezes).


### E se relax�ssemos, classificando como pagador (e concedendo empr�stimo a) todo indiv�duo com p>=0,3?
classp0.3 <- factor(ifelse(pval2 >= 0.3,'PredGood', 'PredBad'))
classp0.3
tabela2 <- table(classp0.3 , dadosvalid$Status) 
tabela2 

sensp0.3 <- sum(classp0.3 == 'PredGood' & dadosvalid$Status == 'Good')/sum(dadosvalid$Status == 'Good')
sensp0.3 
espec0.3 <- sum(classp0.3 == 'PredBad' & dadosvalid$Status == 'Bad')/sum(dadosvalid$Status == 'Bad')
espec0.3 

### Ao tomar pc=0,3, a sensibilidade aumenta ainda mais, mas a especificidade
# (probabilidade de classificar corretamente um mau pagador) fica baix�ssima.


### E se fossemos mais rigorosos, classificando como pagador (e concedendo empr�stimo a) apenas indiv�duos com p>=0,7?

classp0.7 <- factor(ifelse(pval2 >= 0.7,'PredGood', 'PredBad'))
classp0.7

### Classificando como "Devedores" indiv�duos com p>0,7.
tabela3 <- table(classp0.7,dadosvalid$Status)
tabela3
sensp0.7 <- sum(classp0.7 == 'PredGood' & dadosvalid$Status == 'Good')/sum(dadosvalid$Status == 'Good')
sensp0.7
espec0.7 <- sum(classp0.7 == 'PredBad' & dadosvalid$Status == 'Bad')/sum(dadosvalid$Status == 'Bad')
espec0.7

### Para essa regra, temos sensibilidade e especificidade aproximadamente iguais.

### Botando num quadro:

datacomp <- data.frame(c(sensp0.3,sensp0.5,sensp0.7),
                       c(espec0.3,espec0.5,espec0.7))
names(datacomp)<-c('Sensibilidade','Especificidade')
rownames(datacomp)<-c('pc=0,3','pc=0,5','pc=0,7')
datacomp

################################################################################

### Vamos usar o pacote ROCR para calcular algumas medidas de qualidade preditiva.

pred <- prediction(pval2, dadosvalid$Status)
help('performance')

### Vamos plotar a curva ROC
perf <- performance(pred, measure = "tpr" , x.measure = "fpr") 
# tpr: True Positive Rate; fpr: False Positive Rate.

plot(perf, colorize=TRUE,  print.cutoffs.at=seq(0.05,0.95,0.05), lwd = 2)
abline(0,1, lty = 2)

performance(pred, 'auc')
# Extraindo a �rea sob a curva.

### Como ficaria a curva ROC se us�ssemos os dados de ajuste para sua constru��o?

predaj <- prediction(paj2, dadosajuste$Status)
perfaj <- performance(predaj, measure = "tpr" , x.measure = "fpr") 
plot(perfaj, col = 'red', lwd = 2, add = T)
performance(predaj, 'auc')

### Agora, vamos supor que o custo de classificar um mau pagador como bom seja
### cinco vezes o de classificar um bom como mau (C(M|B) = 3*C(B|M)). Assim, para
### uma regra de classifica��o com probabilidades de classifica��o incorretas
### P(M|B) e P(B|M), o cusro esperado de m� classifica��o (ECMC) fica dado por:

##ECMC = C(M|B)*P(M|B)*P(B) + C(B|M)*P(B|M)*P(M)##

## Como na base toda h� 30% de maus pagadores, vamos tomar P(B) = 0,3; P(G) = 0,7.

# Assim, ECMC = 0.9*P(M|B) + 0,7*P(B|M). Vamos avaliar ECMC para diferentes regras.

perf2 <- performance(pred, measure = 'fpr', x.measure = 'fnr')
PMB <- perf2@y.values[[1]] ### P(M|B) para os diferentes pontos de corte (pc)
PBM <- perf2@x.values[[1]] ### P(B|M) para os diferentes pontos de corte.
pc <- perf2@alpha.values[[1]] ### pontos de corte.

ECMC <- 0.9*PMB + 0.7*PBM ### Custos esperados de m�-classifica��o.

x11()
plot(pc, ECMC)
### Algum em torno de 0.7 parece satisfat�rio.

### Exerc�cio - Repetir a an�lise considerando outros modelos. Voc� pode tentar
### modelos com preditores e/ou fun��es de liga��o diferentes. Compare os resultados.
### Se poss�vel, use tamb�m outros m�todos preditivos, como �rvores, Random Forests,
### boosting... Compare os resultados.

