require(effects)
require(leaps) 
require(car)

### Exemplo - Regress�o Linear M�ltipla para os dados de vendas de cosm�ticos.
### O objetivo � propor e ajustar um modelo de regress�o para explicar o 
### total em vendas em fun��o do tempo de servi�o, idade, anos de estudo 
### e popula��o atendida pelas vendedoras.

vendas <- read.csv2("https://docs.ufpr.br//~taconeli//CE22517//Normal2.csv")

names(vendas) <- c('Tempo', 'Idade', 'Estudo', 'Popula��o', 'Venda')

summary(vendas) ### Resumo num�rico dos valores das cinco vari�veis dispon�veis na amostra.

options(digits = 5, scipen = 5)

x11()
require(car)
par(cex=1.2)
scatterplotMatrix(vendas, pch = 20, cex.labels = 1.25) 
### Matriz de gr�ficos de dispers�o 
### (com gr�ficos das densidades estimadas na diagonal).
### Os gr�ficos de dispers�o fornecem um primeiro indicativo de tend�ncia 
### crescente entre popula��o atendida e total de vendas e, com menor 
### intensidade, entre total de vendas e tempo de servi�o.

ajuste1 <- lm(Venda ~ Tempo+Estudo+Popula��o+Idade, data=vendas) 
### Ajuste da regress�o linear m�ltipla, considerando as quatro covari�veis.
### Nota: uma forma equivalente de ajustar o modelo acima seria ajuste1=lm(Venda~.,data=vendas)

print(ajuste1) 
### Extraindo as estimativas dos par�metros da regress�o.

summary(ajuste1)
### Os resultados do ajuste indicam que o total em vendas aumenta conforme 
### o tempo de experi�ncia e a popula��o atendida.
### Para as demais vari�veis, n�o h� evid�ncia significativa de que estejam 
### relacionadas ao total em vendas.
### Estima-se que o total em vendas aumente, em m�dia, R$174,37 para um ano 
### a mais de experi�ncia, mantendo-se fixas as demais covari�veis.
### Quanto � popula��o atendida, estima-se, em m�dia, R$0,628 a mais por pessoa. 
### Assim, para 1000 pessoas a mais na popula��o, estima-se, em m�dia, R$628 
### a mais no total de vendas, mantendo-se fixas as demais covari�veis.

ajuste1sc <- lm(Venda ~ scale(Tempo)+scale(Idade)+scale(Estudo)+scale(Popula��o), data=vendas)
summary(ajuste1sc)
### Neste novo modelo, todas as vari�veis explicativas foram padronizadas
### (subtra�mos, de cada valor, a m�dia da vari�vel e dividimos pelo
### respectivo desvio padr�o). Assim, as vari�veis agora t�m mesma 
### escala e seus efeitos s�o diretamente compar�veis.

fitted(ajuste1) 
### Valores ajustados pelo modelo de regress�o linear m�ltipla para as 200 vendedoras.

plot(fitted(ajuste1), vendas$Venda,pch=20, xlab='Vendas ajustadas', ylab='Vendas observadas',las=1,cex = 1.2) 
abline(0,1,col='red',lwd = 2)
### Gr�fico de valores observados pelos valores ajustados.

confint(ajuste1) 
### Intervalos de confian�a (95%) para os par�metros do modelo.


### Agora, algumas predi��es.

dnovos <- data.frame(Tempo=c(3,15), Idade=c(30,30), Estudo=c(10,10), Popula��o=c(1000,10000)) 
dnovos
### Dois perfis de vendedoras para estimarmos o total m�dio de vendas e predizer o total de vendas

predict(ajuste1, newdata=dnovos) ### Estimativas pontuais.

predict(ajuste1, interval='confidence', newdata=dnovos) 
### Intervalos de confian�a (95%) para o total m�dio de vendas.

predict(ajuste1, interval='prediction', newdata=dnovos) 
### Intervalos de predi��o (95%) para a predi��o do total de vendas.

### Agora, vamos fazer estimativas e predi��es "no atacado", usando todos 
### os vetores de covari�veis (perfis de vendedoras) da base.

p1 <- predict(ajuste1, interval='confidence', newdata=vendas)
vendas2 <- cbind(vendas[,1:4], p1); head(vendas2, 10) 
### Em vendas2 armazenamos os dados e os correspondentes ICs (95%) para 
### o total m�dio de vendas.

p2 <- predict(ajuste1, interval='prediction', newdata=vendas)
vendas3 <- cbind(vendas[,1:4], p2) ;head(vendas3, 10) 
### Em vendas3 armazenamos os dados e os correspondentes IPs (95%) para o 
### total de vendas de novas vendedoras.

### Vamos usar o teste F, baseado na extra soma de quadrados para testar algumas hip�teses.
# H0: Beta(idade)=0 vs H1: Beta(idade)!=0 (testando a signific�ncia do efeito da idade)

ajuste2 <- lm(Venda~.-Idade,data=vendas) 
### Modelo de regress�o linear m�ltipla sem considerar a covari�vel idade.

anova(ajuste2,ajuste1) 
### Repare que o acr�scimo na soma de quadrados (vamos chamar de ASQ) de 
### regress�o associado � inclus�o do efeito de idade � de 2363660, ao qual 
### temos um grau de liberdade associado.

### A estat�stica do teste � F=(ASQ/1)/QMRes, onde QMRes � o quadrado m�dio 
### de res�duos do modelo "maior", que pode ser verificado batendo anova(ajuste1). 

### Sob H0, F~F(1,195) (fa�a o teste � m�o, para um n�vel de signific�ncia de 5%).

### Algumas considera��es:
# 1 - O efeito de idade � n�o significativo, o que poderia 
# justificar a exclus�o dessa vari�vel do modelo.

# 2 - O teste F � equivalente ao teste t apresentado no summary.
# Isso n�o � coincid�ncia, e sempre ocorrer� quando houver apenas um 
# par�metro do modelo sob teste.

# 3 - Repare a sa�da da fun��o anova() aplicada a um �nico modelo. 
# Ela apresenta a seguinte sequ�ncia de testes:

anova(ajuste1)

# I-  Linha 1 - Testa a inclus�o do efeito de Tempo ao modelo nulo 
# (sem covari�veis) - significativa.

# II-  Linha 2 - Testa a inclus�o do efeito de Idade ao modelo com a 
# covari�vel tempo - n�o significativa. 

# III-  Linha 3 - Testa a inclus�o do efeito de Anos de estudo ao modelo 
# com as covari�veis tempo e idade - n�o significativa. 

# IV-  Linha 4 - Testa a inclus�o do efeito de popula��o ao modelo com as 
# covari�veis tempo, idade e anos de estudo - significativa. 

# Nota - Em todos os testes, usa-se QMRes produzida pelo modelo ajustado 
# com mais par�metros (no caso, o modelo com as quatro covari�veis).
# Repare que os testes n�o s�o equivalentes aos do summary (exceto o �ltimo). 
# Por que?

# Pergunta - o que aconteceria com a sequ�ncia de testes se voc� mudasse 
# a ordem de entrada das vari�veis na fun��o lm? 

ajuste2 <- lm(Venda~Popula��o+Estudo+Idade+Tempo, data=vendas) 
### Ajuste da regress�o linear m�ltipla, considerando as quatro covari�veis, 
### com elas inseridas em ordem invertida.
anova(ajuste2)

# Agora, vamos dar uma olhada no resultado da fun��o Anova (com A mai�sculo), 
# dispon�vel no pacote car.

Anova(ajuste1) ### A sequ�ncia de testes agora � a seguinte:
# I-  Linha 1 - Testa a inclus�o do efeito de Tempo ao modelo ajustado 
# com as outras tr�s covari�veis - significativa. 

# II-  Linha 2 - Testa a inclus�o do efeito de Idade ao modelo ajustado 
# com as outras tr�s covari�veis - n�o significativa. 

# III-  Linha 3 - Testa a inclus�o do efeito de Anos de estudo ao modelo 
# ajustado com as outras tr�s covari�veis - n�o significativa. 

# IV-  Linha 4 - Testa a inclus�o do efeito de popula��o ao modelo ajustado 
# com as outras tr�s covari�veis - significativa. 

# Repare que os testes fornecidos por essa fun��o s�o equivalentes aos do summary. Por que?

Anova(ajuste2) ### Com as vari�veis inseridas em ordem diferente... Mesmo resultado.

### Agora, vamos usar o teste F para testar a hip�tese de nulidade conjunta 
### H0:Beta(Idade)=Beta(Estudo)=0. Esse teste permite verificar a contribui��o 
##conjunta das duas vari�veis ao modelo.

ajuste3 <- lm(Venda ~ Popula��o+Tempo,data=vendas)  
### ajuste3 armazena o modelo ajustado sob H0, ou seja, n�o incluindo as 
### covari�veis para as quais estamos postulando que o correspondente par�metro � nulo.

anova(ajuste3,ajuste1) ### Repare que a extra-soma de quadrados (10399916, 
###com 2 graus de liberdade) n�o � significativa (p=0,2421), o que pode 
### justificar a exclus�o das duas covari�veis (Estudo e Idade) do modelo.

### O teste � obtido por (ASQ/2)/QMRes, sendo QMRes=3639505 extra�da do 
### modelo ajustado com mais par�metros.

### Nota: Ao observar que duas covari�veis n�o s�o marginalmente significativas 
### no ajuste de um modelo, isso n�o implica que elas sejam n�o significativas 
### conjuntamente. A n�o signific�ncia conjunta deve ser testada com base 
### no teste F da extra-soma de quadrados.

### Agora, vamos explorar o efeito das covari�veis usando gr�ficos.
plot(allEffects(ajuste1))
### Cada gr�fico apresenta a estimativa do total de vendas (e bandas de 
### confian�a 95%) para os valores de uma vari�vel (representados no eixo
### horizontal) fixando as demais vari�veis na m�dia.


##########################################################################################################################################################

### Diagn�stico - primeiramente vamos extrair os diferentes tipos de res�duos.

e1 <- resid(ajuste1);e1 #
## Res�duos ordin�rios.

sigma <- summary(ajuste1)$sigma;qmres 
### Extraindo (a raiz do) quadrado m�dio de res�duos produzido pelo ajuste.

d1 <- e1/sigma;d1 
### Res�duos padronizados.

r1 <- rstandard(ajuste1);r1 
### Res�duos studentizados (internamente).

r2 <- rstudent(ajuste1);r2 
### Res�duos studentizados (externamente).

### Veja a documenta��o da fun��o rstudent para relembrar a diferen�a desses
### dois tipos de res�duos.

plot(r1,r2) 
### Repare que h� pouca diferen�a nos valores dos dois tipos de res�duos.

fit <- fitted(ajuste1)

### Daqui por diante, vamos usar apenas os res�duos studentizados internamente.

par(mfrow=c(2,2))
plot(ajuste1, which = 1:4, cex = 1.2, pch = 20) 
### Conjunto de gr�ficos de diagn�stico padr�o do R.
### O gr�fico do canto superior esquerdo � de res�duos ordin�rios versus 
### valores ajustados. Repare que os res�duos est�o dispersos aleatoriamente,
### sem valores extremos ou padr�es n�o aleat�rios. 
### Vamos fazer um gr�fico semelhante, mas baseado nos res�duos studentizados:

par(cex=1.4,las=1)

plot(fit, r1, xlab='Valores ajustados', ylab='Res�duos studentizados', pch=20)
### Repare que uma das observa��es gerou res�duo superior a 3. Vamos identific�-la.

### Vamos identificar a observa��o com res�duo superior a 3.
identify(fit,r1,rownames(vendas))
### A observa��o com res�duo superior a 3 est� na linha 195. Vamos avali�-la:

vendas[195,]
summary(vendas)
### Essa � a vendedora com maior total em vendas. Repare que, embora ela
### tenha 14 anos de experi�ncia em vendas, atende uma popula��o pequena, de tamanho 11995. 
### Logo, seu desempenho real foi bem superior ao esperado.

### Voltando aos gr�ficos do R. O gr�fico do canto superior direito � o 
### gr�fico probabil�stico normal. Repare um leve afastamento da distribui��o normal
### � esquerda (para valores negativos). Isso n�o � preocupante, mas vamos 
### fazer um teste para checar a suposi��o de normalidade.

shapiro.test(r1) 
### A hip�tese nula do teste de Shapiro-Wilks � a hip�tese de normalidade. 
### Repare que n�o se tem evid�ncia significativa contra essa hip�tese.
### Logo, a normalidade dos res�duos est� verificada.

 
### O gr�fico do canto inferior esquerdo � o gr�fico da raiz quadrada dos 
### res�duos studentizados (em m�dulo) versus valores ajustados. 
### Serve para avaliar a suposi��o de vari�ncia constante (dentre outros).

### N�o h� ind�cios de heterocedasticidade (vari�ncia n�o constante). 
### Repare que no gr�fico s�o assinalados os maiores res�duos, o que j� 
### hav�amos identificado anteriormente. 

### Podemos usar o teste de Breusch-Pagan para testar a hip�tese de vari�ncia 
### constante para os erros. A hip�tese nula � a de vari�ncia constante e o teste
### baseia-se na distribui��o qui-quadrado. Pode-se testar a homogeneidade de 
### vari�ncias quanto � m�dia ou a algum termo espec�fico do modelo.

# No R - fun��o ncvTest, pacote car.

ncvTest(ajuste1) 
### N�o h� evid�ncia de que a vari�ncia dos erros varie conforme a m�dia (p=0,608)

ncvTest(ajuste1,~'Popula��o') 
### N�o h� evid�ncia de que a vari�ncia dos erros varie conforme o tamanho 
### da popula��o atendida (p=0,564) 

### Falaremos sobre o gr�fico do canto inferior direito mais adiante. 
### Vamos construir mais alguns gr�ficos.

x11()
qqPlot(ajuste1, main="QQ Plot",id.n=3) 
### Gr�fico quantil-quantil dos res�duos studentizados vs quantis te�ricos 
### da distribui��o t-Student com envelopes simulados.
### Nesse tipo de gr�fico, espera-se que os pontos, que correspondem aos res�duos, 
### estejam dispersos em torno da reta identidade, entre os limites do envelope.
### Nota-se um pequeno afastamento na cauda inferior, com um ponto externo ao envelope.

### Gr�fico de res�duos versus vari�vel adicionada no modelo.
par(cex=1.2,las=1)
plot(vendas$Popula��o, r1, xlab='Popula��o atendida', ylab='Res�duos studentizados', pch=20)
plot(vendas$Estudo, r1, xlab='Anos de estudo', ylab='Res�duos studentizados', pch=20)

### A aus�ncia de padr�es nos dois gr�ficos indica que n�o h� a necessidade 
### de considerar a inclus�o dessas vari�veis ao modelo em alguma outra escala.

### Gr�fico de res�duos versus vari�veis n�o inseridas ao modelo.

ajuste12 <- update(ajuste1,~ .-Popula��o) 
### Ajustando o modelo sem o efeito de popula��o.

plot(vendas$Popula��o, rstudent(ajuste12),xlab='Popula��o atendida',
     ylab='Res�duos studentizados',pch=20)

lines(lowess(vendas$Popula��o, rstudent(ajuste12)),col='red',lwd=2)
### A rela��o linear entre res�duos e popula��o atendida indica a necessidade 
### da inclus�o dessa vari�vel ao modelo. Adicionalmente, indica o efeito
### linear dessa vari�vel no total de vendas.


ajuste13=update(ajuste1,~.-Estudo) 
### Ajustando o modelo sem o efeito de estudo.
plot(vendas$Estudo,rstudent(ajuste12),xlab='Anos de estudo',
     ylab='Res�duos studentizados',pch=20)
lines(lowess(vendas$Estudo,rstudent(ajuste12)),col='red',lwd=2)
### A aus�ncia de rela��o entre os res�duos e anos de estudo fornece evidencia  
### de n�o ser necess�ria a inclus�o dessa vari�vel ao modelo.

require(car)
crPlots(ajuste1) 
### Os gr�ficos de res�duos parciais indicam a rela��o entre res�duos 
### parciais e as vari�veis "anos de estudo" e "popula��o atendida". Aparentemente,
### as rela��es s�o lineares, indicando a forma como as vari�veis devem 
### ser inseridas no modelo.

### Agora, vamos calcular medidas de influ�ncia com o objetivo de identificar poss�veis outliers.

matinf <- influence.measures(ajuste1) 
### matinf armazena os valores de diversas medidas de influ�ncia vistas 
### em aula, como DFBETAs, DFFIT, leverage. 

summary(matinf) ### Aplicando o summary, o R destaca as observa��es com 
### valores que ultrapassam o ponto de corte para ao menos uma das medidas.
### Repare que exceto uma das observa��es destacadas, todas as demais tem 
### valor acima do ponto de corte para a estat�stica COVRATIO.
### Repare que a observa��o que produz menor valor do COVRATIO � a 195 que, 
### se voc� lembrar, � a vendedora com maior total de vendas (volte alguns c�digos atr�s).

### A observa��o 69 � marcada como tendo elevado leverage, configurando 
### um ponto de alavancagem. Vamos ver quem � ela.

summary(vendas)
vendas[69,] 
### Repare que essa vendedora atende � regi�o com maior popula��o. 
### Adicionalmente, � uma das vendedoras com maior idade e com menor tempo de estudo.

### Vamos verificar o impacto (conjunto) das observa��es 69 e 195 no modelo, 
### ajustando um novo modelo sem essas observa��es.

ajuste2 <- update(ajuste1, subset=-c(69,195)) 
### A fun��o update permite o ajuste de um novo modelo, atualizando o anterior.
### Repare que a atualiza��o corresponde a defini��o de um subconjunto dos dados. 

compareCoefs(ajuste1, ajuste2) 
### A fun��o compareCoefs, do pacote car, 
### disp�e lado a lado as estimativas e erros padr�es de dois modelos.
### Repare que a altera��o mais substancial nos dois ajustes se refere � 
### estimativa do efeito de ajuste (de 67,8 para 52,8). No entanto, nos dois ajustes
### o efeito de anos de estudo � n�o significativo. Portanto, as conclus�es 
### para os dois modelos s�o semelhantes.

### Mais um pouco de diagn�stico. 
influenceIndexPlot(ajuste1, vars=c('Studentized','Cook','Hat'), id.n=3, cex = 1.4)


### Sele��o de covari�veis.

allsub <- regsubsets(Venda~., data=vendas) 
### A fun��o regsubsets determina, para cada tamanho de modelo (n�mero de 
### vari�veis inclu�das), o melhor modelo.
plot(allsub)

s1 <- summary(allsub) 
s1
### Resumo do processo. Verifique que o melhor modelo com uma vari�vel 
### tem a vari�vel Popula��o, com duas Popula��o e Tempo...

### Agora, vamos extrair algumas medidas de qualidade de ajuste desses modelos:

s1$rsq ### Coeficientes de determina��o;
s1$adjr2 ### Coeficientes de determina��o ajustados;
s1$cp ### CP de Mallows;
s1$bic ### Crit�rio de informa��o de Schwartz. 

### Vamos observar os resultados num gr�fico:

subsets(allsub, statistic='adjr2')
### Repare que os melhores modelos com duas, tr�s e quatro vari�veis t�m 
### coeficientes de determina��o bastante pr�ximos. Nesse caso, a op��o 
### poderia ser pelo modelo mais simples, no caso o modelo com duas vari�veis 
### (Tempo de experi�ncia e Popula��o atendida).

### Agora, s� para praticar, usando algoritmos do tipo stepwise.

### Usando o m�todo backward.
selb <- step(ajuste1, direction = 'backward')
summary(selb)

### Usando o m�todo forward
self <- step(ajuste1, direction = 'forward')
summary(self)

### Usando o m�todo forward
selbf <- step(ajuste1, direction = 'both')
summary(selbf)

# Avalie os modelos resultantes das aplica��es dos tr�s m�todos.