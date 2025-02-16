########################################################################
########################################################################
########################################################################
### An�lise de res�duos - uma ilustra��o.

set.seed(188)
options(device = 'x11')
require(hnp)
require(statmod)

### Simulando dados para um GLM poisson.
x <- runif(200, 0, 5)
y <- rpois(200, lambda = exp(1.5- 2*x + 0.4*x^2))

### Gr�fico dos valores simulados e da fun��o de regress�o.
plot(y ~ x, pch = 20, cex = 1.25, col = 'blue')
med_x <- function(x) exp(1.5- 2*x + 0.4*x^2)
curve(med_x, from = 0, to = 5, col = 'red', add = TRUE, lwd = 2)


########################################################################
### Primeiro, vamos ajustar um modelo com resposta normal.
ajuste1 <- glm(y ~ poly(x,2), family = gaussian)
par(mfrow = c(2,2))
plot(ajuste1)
### Os dois gr�ficos � esquerda evidenciam que os res�duos n�o t�m vari�ncia
### constante. Al�m disso, o qqplot aponta distribui��o fortemente assim�trica,
### bem diferente da normal. Vamos proceder com o gr�fico meio normal com
### envelope simulado, para uma melhor aprecia��o dos resultados.

hnp(ajuste1, pch = 20, cex = 1.2)
### O comportamento dos res�duos, oscilando, em boa parte, fora do envelope
### simulado, evidencia que o modelo n�o est� bem ajustado. Na sequ�ncia, 
### vamos extrair e produzir gr�ficos para os res�duos quant�licos aleatorizados.

residuos <- qresid(ajuste1)
ajustados <- predict(ajuste1)


par(mfrow = c(1,2))
plot(residuos ~ ajustados, pch = 20, cex = 1.4, col = 'blue')
### Gr�fico de res�duos versus valores ajustados.

qqnorm(residuos, pch = 20, cex = 1.4, col = 'blue')
qqline(residuos)
### Gr�fico quantil-quantil normal. Novamente observamos o padr�o de vari�ncia
### n�o constante e n�o normalidade, indicando o mau ajuste do modelo.

########################################################################
### Agora, vamos considerar distribui��o Poisson para a resposta, mas
### com especifica��es incorretas para o preditor.

ajuste2 <- glm(y ~ x, family = poisson)
### Modelo apenas com termo linear, desconsiderando o termo quadr�tico de x.

par(mfrow = c(2,2))
plot(ajuste2, cex = 1.25)
### O gr�fico de res�duos ### versus valores ajustados (canto superior � esquerda), 
### indica a necessidade de se incluir o efeito quadr�tico da covari�vel.

hnp(ajuste2, pch = 20, cex = 1.2)
### O modelo claramente n�o est� bem ajustado, uma vez diversos 
### res�duos se encontram acima da parte superior do envelope simulado.
### Vamos ver o comportamento dos res�duos quant�licos aleatorizados:

residuos <- qresid(ajuste2)
ajustados <- predict(ajuste2)

par(mfrow = c(1,2))
plot(residuos ~ ajustados, pch = 20, cex = 1.4, col = 'blue')
### Gr�fico de res�duos versus valores ajustados.

qqnorm(residuos, pch = 20, cex = 1.4, col = 'blue')
qqline(residuos)
### Gr�fico quantil-quantil normal. Novamente observamos a falta de ajuste
### do modelo, indicando a necessidade de se incluir o esfeito
### quadr�tico.

########################################################################
### Finalmente, o modelo de Poisson com efeito quadr�tico de x.

ajuste3 <- glm(y ~ poly(x,2), family = poisson)
### Modelo apenas com termo linear, desconsiderando o termo quadr�tico de x.

par(mfrow = c(2,2))
plot(ajuste3, cex = 1.25)
### Os res�duos apresentam vari�ncia constante, conforme o gr�fico do canto
### inferior � direita, e n�o apresenta qualquer padr�o sistem�tico no gr�fico
### do canto superior � direita O gr�fico quantil-quantil pode ser melhor
### avaliado usando os envelopes simulados.

hnp(ajuste3, pch = 20, cex = 1.2)
### Os res�duos est�o dispersos, praticamente em sua totalidade, no interior
### do envelope, que � o comportamento esperado para um bom ajuste. Para
### os res�duos quant�licos aleatorizados, temos:

residuos <- qresid(ajuste3)
ajustados <- predict(ajuste3)

par(mfrow = c(1,2))
plot(residuos ~ ajustados, pch = 20, cex = 1.4, col = 'blue')
### Gr�fico de res�duos versus valores ajustados.

qqnorm(residuos, pch = 20, cex = 1.4, col = 'blue')
qqline(residuos)

########################################################################
########################################################################
########################################################################
### Simula��o - distribui��o dos res�duos componentes da deviance.

### Vamos considerar um glm com resposta binomial, liga��o logito. Seguem
### os dados.

x <- c(5.4, 5.5, 6.2, 4.5, 6.5, 6.8, 5.2, 4.9, 5.9, 4.6,
       6.2, 3.3, 6.4, 5.3, 5.1, 5.6, 3.8, 5.3, 5.1, 5.8,
       4.5, 4.2, 5.8, 3.6, 4.2, 6.0, 7.1, 4.9, 4.8, 4.0,
       6.3, 6.9, 5.6, 6.0, 4.1, 3.9, 6.2, 3.5, 5.1, 2.5,
       5.2, 5.3, 3.1, 3.6, 5.8, 5.4, 5.1, 3.8, 6.1, 4.9)

y <- c(1, 1, 0, 0, 0, 0, 0, 0, 1, 0,
       0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
       1, 1, 0, 1, 0, 0, 0, 0, 0, 0,
       0, 1, 0, 1, 0, 1, 0, 0, 1, 0)

plot(x, jitter(y, amount = 0.05), pch = 20, xlab = 'x', ylab = 'y', cex = 1.25)

ajuste <- glm(y ~x, family = binomial)
qqnorm(resid(ajuste), pch = 20, cex = 1.5)
qqline(resid(ajuste))
### A distribui��o dos res�duos claramente n�o tem boa ader�ncia � distribui��o
### normal. Mas ser� que isso implica que o modelo n�o se ajusta bem aos dados?

### Para investigar a adequa��o do ajuste, com base nesse gr�fico de res�duos,
### vamos analisar a distribui��o dos res�duos, nesta aplica��o, no cen�rio
### em que o modelo est� corretamente especificado. Como? Usando simula��o, oras!

novoy <- simulate(ajuste)$sim_1
novoy
### O vetor novoy armazena um vetor de respostas simulado a partir do modelo.
### O m�todo de simula��o � id�ntico ao que usamos anteriormente, para analisar
### a distribui��o da deviance, usando a fun��o predict. Vamos substituir o
### vetor resposta original por este simulado e analisar os res�duos.

ajustesim <- glm(novoy ~x, family = binomial)
qqnorm(resid(ajustesim), pch = 20, col = 'grey70', cex = 1, ylim = c(-3,3))
qqline(resid(ajustesim))
### Os res�duos, novamente, n�o apresentam distribui��o normal. S� que neste
### caso n�o temos d�vidas que o modelo tenha sido corretamente especificado,
### uma vez que os dados foram simulados a partir do modelo. Agora, vamos repetir
### a simula��o um grande n�mero de vezes (no caso 100) e plotar, num �nico
### gr�fico, os res�duos produzidos por cada ajuste.

for(i in 1:100){
    novoy <- simulate(ajuste)$sim_1
    ajustesim <- glm(novoy ~x, family = binomial)
    q1 <- qqnorm(resid(ajustesim), pch = 20, col = 'red', plot.it = FALSE, cex = 0.05)
    points(q1$x, q1$y, col = 'grey70')
}

### Sobre esta base de res�duos simulados, vamos plotar os res�duos originais,
### produzidos pelos modelo ajustado que est� sob investiga��o.

qorig <- qqnorm(resid(ajuste), pch = 20, cex = 1.5, plot.it = FALSE)
points(qorig$x, qorig$y, pch = 20, cex = 1.5)

### Observe que os res�duos produzidos pelo modelo s�o absolutamente compat�veis
### com os res�duos simulados. Assim, temos forte evid�ncia de que o modelo
### est� corretamente especificado, se ajustando bem aos dados.

########################################################################
########################################################################
########################################################################
### Ilustra��o - res�duo quant�lico aleatorizado.

### Vamos simular dados de um GLM com resposta Gamma e fun��o de liga��o
### logar�tmica. Vamos usar a implementa��o da distribui��o Gamma dispon�vel
### no pacote gamlss (bater ?GA, no pacote gamlss). 

require(gamlss)
x <- runif(1000, 0, 2)
y <- rGA(1000, mu = exp(3-x), sigma = 0.5)
plot(x,y)

ajuste <- glm(y~x, family = Gamma(link = 'log'))

### Passo 1: Vamos avaliar a fun��o distribui��o acumulada da Gamma em 
### cada par y_i, mu_i.
fgamma <- pGA(y[order(x)], mu = fitted(ajuste)[order(x)], sigma = 0.5)
hist(fgamma)
### Como era de se esperar, a vari�vel resultante tem distribui��o uniforme.

### Agora, aplicamos a inversa da fda Normal (fun��o quantil) aos valores 
### de fgamma.

hist(qnorm(fgamma))
### Res�duos com distribui��o normal.



