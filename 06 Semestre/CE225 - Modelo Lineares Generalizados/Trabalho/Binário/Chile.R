require(car)
require(MASS)
require(faraway)
require(effects)
help(Chile)

options(scipen = 5)
### Preparando os dados.

head(Chile)
summary(Chile)

Chile2 <- Chile[which(Chile$vote%in%c('N','Y')),] 
### Excluindo indecisos e eleitores que pretendem se abster. 

Chile2$vote <- factor(Chile2$vote) 
### Eliminando n�veis de 'vote' que n�o aparecem na nova amostra.

summary(Chile2)
Chile2$education <- factor(Chile2$education,levels=c('P','S','PS'))

### Uma breve an�lise descritiva
round(prop.table(table(Chile2$vote,Chile2$region),2),2) 
### Tabela de frequ�ncias de inten��o de voto segundo a regi�o do eleitor.

x11()
barplot(table(Chile2$vote,Chile2$region), beside=T, ylim=c(0,350), las = 1,
        xlab = 'Regi�o', ylab = 'N� de Eleitores', legend = c('N�o','Sim')) 
### Gr�fico de barras - inten��o de voto vs regi�o. 

barplot(table(Chile2$vote, Chile2$sex), beside = T, las = 1, xlab = 'Sexo',
        ylab = 'N� de Eleitores', legend = c('N�o','Sim'))
### Gr�fico de barras - inten��o de voto vs sexo 

barplot(table(Chile2$vote, Chile2$education), beside = T, las = 1, xlab = 'Escolaridade',
        ylab = 'N� de Eleitores', legend = c('N�o','Sim'))
### Gr�fico de barras - inten��o de voto vs Educa��o 

boxplot(Chile2$age ~ Chile2$vote, xlab = 'Voto', ylab = 'Idade de eleitores',
        names = c('N�o','Sim')) 
### Boxplot de idade versus inten��o de voto.

boxplot(Chile2$income ~ Chile2$vote, ylab = 'Renda')
### Boxplot de renda versus inten��o de voto.

boxplot(Chile2$statusquo ~ Chile2$vote, ylab = 'Status quo')
### Boxplot de statusquo versus inten��o de voto.

### Vamos ajustar um glm para a inten��o de voto, considerando distribui��o 
### binomial com fun��o de liga��o logito.

Chile3 <- na.omit(Chile2) ### Eliminando da base as linhas com NA's.
intvoto <- glm(vote ~ ., family = binomial(link = 'logit'), data = Chile3)
summary(intvoto) ### Resumo do modelo ajustado. 
### Nota-se menor inten��o de votos favor�veis ao regime dentre os homens, 
### dentre os eleitores com maior escolaridade e maior inten��o quanto maior o status-quo.

### � evidente (e at� mesmo previs�vel) que a vari�vel statusquo seja extremamente 
### relacionada � inten��o de voto (no caso, ao voto favor�vel), 
### sendo os efeitos das demais covari�veis bastante modestos
### se comparados a ela. O que aconteceria se tir�ssemos ela do modelo?

intvoto2 <- update(intvoto, ~. -statusquo)
summary(intvoto2) ### Observe que alguns efeitos que anteriormente n�o 
### apresentavam signific�ncia estat�stica agora apresentam.
### Vamos optar pelo modelo sem a inclus�o de statusquo.

Anova(intvoto2, test = 'LR') 
### Os testes das raz�es de verossimilhan�as indicam a signific�ncia estat�stica 
### das vari�veis inclu�das no modelo.

anova(intvoto2, test = 'LR') 
### Qual a diferen�a com rela��o ao comando acima mesmo?

### Vamos avaliar poss�vel efeito de intera��o entre sexo e educa��o:
intvoto4 <- update(intvoto2, ~ . +sex:education)
anova(intvoto2, intvoto4, test='LR')

### Repare no efeito n�o significativo da intera��o. Deixo como exerc�cio verificar 
### o efeito de alguma intera��o de interesse e, caso verificada a signific�ncia,
### inclu�-la no modelo e analisar os resultados.

### Exerc�cio 1 - escrever a equa��o do modelo ajustado. Interpretar cada um dos 
### coeficientes estimados.

### Vamos calcular a probabilidade de inten��o de voto pr�-Pinochet para eleitores 
### com os seguintes perfis:

# Regi�o C, Popula��o 25.000, Sexo masculino, idade 35 anos, com ensino superior, renda 120.000.
# Regi�o M, Popula��o 50.000, Sexo feminino, idade 55 anos, com ensino prim�rio, renda 15.000.

datapred <- data.frame(region = c('C','M'), population = c(25000,50000),
                       sex = c('M','F'), age = c(35,55), education = c('S','P'),
                       income = c(120000,15000))
### Criando um data frame para os dados que vamos predizer.

predict(intvoto2, newdata=datapred, type='response') 
### estimativas pontuais para as probabilidades de voto para os dois perfis.

### Agora, vamos obter ICs 95% para as probabilidades correspondentes aos dois perfis de eleitores. 
p1 <- predict(intvoto2,newdata=datapred,type='link',se.fit=T); p1 
### Estimativas na escla do preditor, pedindo ao R os erros padr�es.

### Agora, vamos calcular os intervalos de confian�a para as probabilidades estimadas.
# Para o perfil 1:
ic1 <- p1$fit[1]+c(-1.96,1.96)*p1$se.fit[1] ### Intervalo de confian�a 95% para o preditor.
ilogit(ic1) ### Convertendo os limites para a escala de pi. 
### A fun��o ilogit(x) calcula (exp(x)/(exp(x)+1)

# Para o perfil 2:
ic2 <- p1$fit[2]+c(-1.96,1.96)*p1$se.fit[2] ### Intervalo de confian�a 95% para o preditor.
ilogit(ic2) 
### Convertendo os limites para a escala de pi.

# O pacote effects disp�e de gr�ficos que permitem visualizar o efeito das covari�veis na resposta.

plot(effect("income", intvoto2), type = 'response') 
### Nesse gr�fico, temos as probabilidades estimadas de votos pr�-Pinochet 
### (com ICs 95%) segundo a renda. Os valores das demais covari�veis s�o fixados
### na m�dia (consultar a documenta��o da fun��o para maiores detalhes).

plot(effect("income", intvoto2), type = 'link') 
### Gr�fico do efeito de renda na escala do preditor.

plot(effect("age", intvoto2), type = 'response')
### Gr�fico para o efeito de idade.

### Um pouco de diagn�stico.

par(mfrow=c(2,2))
plot(intvoto2, 1:4) ### Gr�ficos de diagn�stico padr�o para a fun��o glm 
### (baseados nos res�duos componentes da deviance). Complicado avaliar.

require(car)
influenceIndexPlot(intvoto4, vars = c('Studentized','Cook','Hat'), id.n = 3, cex = 1.4)
### N�o h� indicativos fortes de out-liers ou observa��es influentes. 
### Apenas como exerc�cio, vamos verificar o indiv�duo com identifica��o 2669,
### que produziu maior valor para a dist�ncia de Cook.

Chile3['2669',]
### Repare que � uma pessoa com caracter�sticas pr�-Pinochet (mulher, 67 anos...), 
### mas que vota n�o. Como a base � bastante grande, dificilmente essa observa��o
### tenha, sozinha, muita influ�ncia no ajuste. Mas, a t�tulo de eserc�cio, 
### vamos ajustar um novo modelo sem ela e comparar os resultados.

intvoto22 <- update(intvoto2, data = Chile3[-which(rownames(Chile3) == '2669'),])
compareCoefs(intvoto2, intvoto22) ### Sem grandes mudan�as.

### Agora, vamos avaliar a qualidade do ajuste com base nos res�duos quant�licos 
### aleatorizados e no gr�fico do res�duo da deviance com envelope simulado.

## Usando os res�duos quant�licos:
require(statmod)
residuos<-qresiduals(intvoto2)
qqnorm(residuos)
qqline(residuos)
### Os res�duos apresentam boa ader�ncia � distribui��o Normal, indicativo
### de bom ajuste.

## Agora o gr�fico de res�duos com envelopes simulados.
require(hnp)
hnp(intvoto2) ### Res�duos dispersos no interior dos envelopes simulados,
### sem qualquer padr�o sistem�tico. Modelo bem ajustado.

### Para finalizar, vamos testar a qualidade do ajuste com base na estat�stica C 
### de Hosmer e Lemeshow.

### Fun��o para o c�lculo da Estat�stica (e teste) de qualidade de ajuste 
### proposta por Hosmer e Lemeshow.
### Voc� deve entrar com o vetor de predi��es (na escala da resposta), 
### o vetor de valores observados (zeros e uns) e o n�mero de grupos (g) a serem formados.

CHosmer <- function(modelo,g){
respostas <- modelo$y
preditos <- predict(modelo, type = 'response')

dpred <- data.frame(preditos, respostas) 
### Dataframe com probabilidades estimadas e respostas para cada indiv�duo.

dpred <- dpred[order(dpred[,1]),] 
### Ordenando as linhas do dataframe da menor para a maior probabilidade estimada.

cortes <- quantile(dpred[,1], probs=seq(0,1, 1/g), include.lowest=TRUE) 
### Calculando os quantis para as probabilidades estimadas, para posterior forma��o dos grupos.

c1 <- cut(dpred[,1],breaks=cortes,include.lowest=T) 
### Formando g grupos, de tamanhos (aproximadamente) iguais, com probabilidades 
### estimadas semelhantes.

Obs <- tapply(dpred[,2], c1, sum) 
### Obs � um vetor com o n�mero observado de respostas em cada um dos g grupos.

pi <- tapply(dpred[,1], c1, mean) 
### pi � um vetor com as m�dias das probabilidades estimadas em cada um dos g grupos.

n <- tapply(dpred[,1], c1, length) 
### n � um vetor com os tamanhos de amostras em cada grupo.

Cchap <- sum(((Obs-n*pi)**2)/(n*pi*(1-pi))) 
### Estat�stica do teste de qualidade proposto por Hosmer e Lemeshow e

pv <- 1 - pchisq(Cchap, g-2) ### p-valor correspondente.
return(list(Cchap=Cchap, pvalue=pv))
}

CHosmer(intvoto2,g=10)
### C=4,37 que, com p-valor=0,822. Assim, n�o se tem evid�ncia significativa de falta de ajuste.