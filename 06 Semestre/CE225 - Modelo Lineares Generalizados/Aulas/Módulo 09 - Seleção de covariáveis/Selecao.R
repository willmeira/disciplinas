### Nesta aplica��o, vamos usar os dados sobre disagn�stico de diabetes
### em uma popula��o de mulheres ind�genas norte-americanas. O objetivo
### � predizer o diagn�stico, resultante do teste de glicemia em jejum
### (type) em fun��o das demais covari�veis. Para maiores informa��es,
### consultar a documenta��o da base.

require(MASS)
require(glmnet)

pima_dat <- rbind(Pima.tr, Pima.te)
### A principio s�o duas bases, uma para ajuste e outra para valida��o.
### Nesta aplica��o, no entanto, vamos concatenar as duas bases e proceder
### uma �nica an�lise.

head(pima_dat, 15)
summary(pima_dat)

### Vamos usar um glm com resposta binomial e liga��o logito (regress�o log�stica) 

### Primeiro, usando todas as covari�veis.
ajuste <- glm(type ~ ., data = pima_dat, family = 'binomial')
logLik(ajuste)
AIC(ajuste)
BIC(ajuste)

### Agora, o modelo nulo, apenas com o intercepto.
ajuste_null <- glm(type ~ 1, data = pima_dat, family = 'binomial')
logLik(ajuste_null)
AIC(ajuste_null)
BIC(ajuste_null)

########################################################################
### M�todos de sele��o de covari�veis
### Sele��o de covari�veis - m�todo backward
s1a <- step(ajuste, direction = 'backward')
summary(s1a) ### Resumo do modelo produzido pelo m�todo backward.
### Cinco covari�veis foram selecionadas para compor o modelo.

### Vamos repetir o algoritmo backward, mas agora trocando a constante de
### penaliza��o de k = 2 para k = log(n) = 6.27.
s1b <- step(ajuste, direction = 'backward', k = log(nrow(pima_dat)))
summary(s1b)
### Neste caso, quatro covari�veis foram selecionadas para compor o modelo.
### A vari�vel age � selecionada quando k = 2, mas n�o para k = log(n).


### Sele��o de covari�veis - m�todo forward. Para o m�todo forward, o modelo
### de partida � o modelo nulo, e precisamos definir o escopo, referente �s
### vari�veis consideradas para inclus�o.
s2a <- step(ajuste_null, scope = formula(ajuste), direction = 'forward')
summary(s2a)

s2b <- step(ajuste_null, scope = formula(ajuste), direction = 'forward', k = log(nrow(pima_dat)))
summary(s2b)
### Novamente, os modelos diferem quanto � inclus�o da vari�vel age.

### Finalmente, o m�todo stepwise combinado.
s3a <- step(ajuste_null, scope = formula(ajuste), direction = 'both')
summary(s3a)

s3b <- step(ajuste_null, scope = formula(ajuste), direction = 'both', k = log(nrow(pima_dat)))
summary(s3b)
### Os resultados coincidem com os produzidos pelos outros algoritmos.

########################################################################
########################################################################
########################################################################
### M�todos de regulariza��o - o conflito entre v�cio e vari�ncia.

### Esta simula��o tem por objetivo ilustrar o tradeoff (conflito) entre
### vi�s e vari�ncia, na estima��o dos par�metros do modelo.

### Vamos simular dados de duas covari�veis (X1,X2) com distribui��o normal,
### vetor de m�dias (0,0), vari�ncias iguais a 1 e covari�ncia (e correla��o)
### igual a 0.5.

### Condicional aos valores das covari�veis, vamos simular valores de uma
### resposta bin�ria, segundo o seguinte glm: y|x1,x2 ~  binomial(1, mu_x),
### com logito(mu_x) = 1 + 0.5*x1 - 0.25*x2 (regress�o log�stica).

### Essa simula��o vai ser repetida 100 vezes. Em cada simula��o, vamos
### extrair as estimativas dos par�metros do modelo ajustado via regress�o
### ridge. Para isso, uma sequ�ncia crescente de valores para o par�metro
### de regulariza��o ser� considerada.

### Ao t�rmino da simula��o, com base nas 100 rodadas vamos calcular o vi�s,
### a vari�ncia e o erro quadr�tico m�dio das estimativas geradas para 
### beta_1 e para beta_2 sob cada valor de lambda.

set.seed(1) ### Fixando a semente, para fins de reprodu��o.
x <- mvrnorm(100, mu = c(0,0), Sigma = matrix(c(1,0.5,0.5,1), nrow = 2))
x
### Valores simulados das covari�veis, a partir da distribui��o normal
### bivariada.

colnames(x) <- c('x1', 'x2')
eta_x <-1 + 0.5*x[,1] - 0.25*x[,2]
eta_x
### Vetor referente ao preditor linear.

log_lambdas <- seq(-5, -0.5, length.out = 30)
### O grid de valores para lambda foi criado na escala de log(lambda).
### Devido ao comportamento dos resultados para diferentes valores desse
### par�metro, a escala logar�tmica � uma escolha apropriada.

beta1 <- matrix(nrow = 100, ncol = length(log_lambdas))
beta2 <- matrix(nrow = 100, ncol = length(log_lambdas))
### <atrizes que v�o armazenar as 100 estimativas de beta_1 e as 100 estimativas
### de beta_2 produzidas para cada valor de lambda.

### O la�o abaixo repete por 100 vezes a simula��o de valores para a resposta
### (y), o ajuste do glm ridge usando o vetor de respostas simuladas e o
### armazenamento, nas matrizes criadas, das estimativas de beta_1 e beta_2
### para cada valor de lambda no grid criado.
for(j in 1:100){
    y <- rbinom(100, 1, exp(eta_x)/(exp(eta_x)+1))
    mod <- glmnet(x, y, family = 'binomial', alpha = 0)
    betas <- coef(mod, s = exp(log_lambdas))
    beta1[j,] <- betas[2,]
    beta2[j,] <- betas[3,]
}

### As fun��es abaixo servem para calcular vi�s, vari�ncia e erro quadr�tico
### m�dio com base nos dados simulados.

bias_beta <- function(vet_beta, beta)
    (mean(vet_beta) - beta)^2

var_beta <- function(vet_beta)
    var(vet_beta)

eqm_beta <- function(vet_beta, beta)
    mean((vet_beta - beta)^2)


### Agora, vamos aplicar as fun��es criadas para calcular as quantidades de
### interesse para cada par�metro do modelo e valor de lambda.

### Para beta_1
bias_b1 <- apply(beta1, 2, bias_beta, beta = 0.5)
var_b1 <- apply(beta1, 2, var_beta)
eqm_beta1 <- apply(beta1, 2, eqm_beta, beta = 0.5)

x11(width = 12, height = 12)    
par(cex = 1.2, las = 1)
plot(log_lambdas, bias_b1, type = 'l', lwd = 2, ylab = '')
lines(log_lambdas, var_b1, type = 'l', col = 'red', lwd = 2)
lines(log_lambdas, eqm_beta1, type = 'l', col = 'blue', lwd = 2)
legend(x = 'topleft', lty = 1, lwd = 2, col = c('black', 'red', 'blue'),
       legend = c('Vi�s', 'Vari�ncia', 'EQM'))

### Para beta_2
bias_b2 <- apply(beta2, 2, bias_beta, beta = -0.25)
var_b2 <- apply(beta2, 2, var_beta)
eqm_beta2 <- apply(beta2, 2, eqm_beta, beta = -0.25)

x11(width = 12, height = 12)    
par(cex = 1.2, las = 1)
plot(log_lambdas, bias_b2, type = 'l', lwd = 2, ylab = '', ylim = c(0,0.085))
lines(log_lambdas, var_b2, type = 'l', col = 'red', lwd = 2)
lines(log_lambdas, eqm_beta2, type = 'l', col = 'blue', lwd = 2)
legend(x = 'topleft', lty = 1, lwd = 2, col = c('black', 'red', 'blue'),
       legend = c('Vi�s', 'Vari�ncia', 'EQM'))
### Observe que o vi�s � m�nimo quando o par�metro de regulariza��o (lambda)
### � pequeno, enquanto a vari�ncia � m�xima nesse cen�rio. � medida que aumentamos
### o valor de lambda, o vi�s aumenta e a vari�ncia vai a zero. Ao analisar o
### comportamento do erro quadr�tico m�dio, observamos que valores intermedi�rios
### de lambda remetem a menores valores de EQM, ainda que as estimativas
### geradas apresentem algum grau de vi�s.

########################################################################
########################################################################
########################################################################
### M�todos de regulariza��o - aplica��o.

### Para a aplica��o dos m�todos de regulariza��o, vamos usar todas as 
### covari�veis, exceto pedigree. 

x <- model.matrix(type ~ npreg + glu + bp + skin + bmi + age, data = pima_dat)[, -1]
### Matriz de covari�veis. Observe a exclus�o da primeira coluna, que corresponde �
### coluna de uns (referente ao intercepto), que n�o deve ser inclu�da.

y <- ifelse(pima_dat$type == 'Yes', 1, 0)
### Convertendo a vari�vel resposta para um vetor num�rico. Ser� necess�rio
### para o processo de valida��o cruzada.

g1 <- glmnet(x, y, family = 'binomial', alpha = 1)
### Lasso regression (penaliza��o de primeira ordem)

x11(width = 12, height = 12)
par(cex = 1.5, las = 1)
plot(g1, las = 1, lwd = 2, label=TRUE)
### As trajet�rias indicam as estimativas dos betas para diferentes valores
### do termo de penaliza��o. Os valores que identificam as linhas se referem
### �s vari�veis, na ordem em que foram declaradas na especifica��o do modelo.
### As vari�veis tr�s e quatro ("bp" e "skin") s�o as primeiras a se igualarem a
### zero, enquanto a vari�vel "glu" � a �ltima. Vamos ver um gr�fico semelhante, 
### mas agora em fun��o de lambda, o par�metro de penaliza��o.

plot(g1, xvar="lambda", label=TRUE, lwd = 2, cex = 20)

### Vamos ver como ficaria o modelo ajustado para diferentes valores de lambda:
coef(g1, s=exp(-7)) ### Lambda = exp(-7) = 0.0009
coef(g1, s=exp(-4)) ### Lambda = exp(-4) = 0.0183
coef(g1, s=exp(-2)) ### Lambda = exp(-2) = 0.1353

### Usando a fun��o glmnet, vamos determinar o valor de lambda que produz
### menor deviance, estimado via valida��o cruzada.
cvfit <- cv.glmnet(x, y, family = 'binomial', alpha = 1, nfolds = 20) 
### Ao especificar nfolds = 532, estamos usando a estrat�gia "leave one out".
plot(cvfit)
cvfit$lambda.min 
### Lambda �timo.

coef(g1, s=cvfit$lambda.min)
### Modelo ajustado com o lambda �timo.

########################################################################
### Agora, regress�o ridge. Para isso, setamos alpha = 0.
g2 <- glmnet(x, y, family = 'binomial', alpha = 0)

x11(width = 12, height = 12)
par(cex = 1.5, las = 1)
plot(g2, las = 1, lwd = 2, label=TRUE)
plot(g2, xvar="lambda", label=TRUE, lwd = 2, cex = 20)

### Valida��o cruzada.
cvfit2 <- cv.glmnet(x, y, family = 'binomial', alpha = 0, nfolds = 20) 
plot(cvfit2)
cvfit2$lambda.min 
### Lambda �timo.

coef(g2, s=cvfit2$lambda.min)
### Modelo ajustado com o lambda �timo.

########################################################################
### Finalizando, para alpha = 0.5.
g3 <- glmnet(x, y, family = 'binomial', alpha = 0.5)

x11(width = 12, height = 12)
par(cex = 1.5, las = 1)
plot(g3, las = 1, lwd = 2, label=TRUE)
plot(g3, xvar="lambda", lwd = 2, label=TRUE, cex = 20)

### Valida��o cruzada.
cvfit3 <- cv.glmnet(x, y, family = 'binomial', alpha = 0.5, nfolds = 20) 
plot(cvfit3)
cvfit3$lambda.min 
### Lambda �timo.

coef(g3, s=cvfit3$lambda.min)
### Modelo ajustado com o lambda �timo.


########################################################################
########################################################################
########################################################################
### Agora, uma aplica��o em dados simulados. Primeiramente, vamos simular
### valores para 20 vari�veis explicativas. Vamos considerar distribui��o
### normal para cada uma delas, com m�dia zero e vari�ncia 1. Adicionalmente,
### vamos fixar covari�ncia igual a 0.5 para cada par de vari�veis (como
### as vari�ncias s�o iguais a um, ent�o isso equivale a covari�ncias 
### iguais a 0.5). A fun��o mvrnorm, do pacote MASS, permite simular amostras
### da distribui��o normal multivariada, como � o caso.

set.seed(225)
### Fixando uma semente, para que os resultados sejam reproduz�veis.

n <- 2018
### Tamanho da amostra.

mat_cov <- matrix(0.5, nrow = 20, ncol = 20)
diag(mat_cov) <- 1
mat_cov
### Matriz de vari�ncias e covari�ncias.

medias <- rep(0, 20)
### Vetor de m�dias.

x <- data.frame(mvrnorm(n, mu = medias, Sigma = mat_cov))
dados_simul <- round(x,3)
names(dados_simul) <- paste('x', 1:20, sep = '')
### Dados simulados para as 20 vari�veis explicativas.

### Agora, condicional aos valores simulados para as vari�veis explicativas,
### vamos simular resultados de uma vari�vel resposta bin�ria, conforme
### a seguinte especifica��o:

### y|x ~ binomial(m = 1, pi = mu_x)
### logito(mu_x) = eta_x = x1 + 0.4*x3 - 0.5*x7 + 0.25*x10 + 0.25*x19,
### de forma que mu_x = exp(eta_x)/(exp(eta_x)+1).

eta_x <- with(dados_simul, 0.5*x1 + 0.3*x3 - 0.5*x7 - 0.5*x10 + 0.3*x19)
mu_x <- exp(eta_x)/(exp(eta_x) + 1)
dados_simul$y <- rbinom(n, 1, mu_x)
dados_simul$y
### Valores simulados para a resposta.

### Nosso objetivo aqui � aplicar os m�todos de sele��o de covari�veis e
### de regulariza��o estudados em sala de aula e avaliar o quanto eles s�o
### capazes, nesta aplica��o, de identificar as vari�veis usadas na simula��o.

### Ajuste do glm com todas as covari�veis.
ajuste <- glm(y~., family = binomial, data = dados_simul)
summary(ajuste)

### Ajuste do modelo nulo.
ajuste_null <- glm(y~1, family = binomial, data = dados_simul)
summary(ajuste_null)

### M�todo 1: Backward com k = 2 (AIC)
mod1a <- step(ajuste, direction = 'backward')
summary(mod1a)

### M�todo 2: Backward com k = log(300) (BIC)
mod1b <- step(ajuste, direction = 'backward', k = log(n))
summary(mod1b)

### M�todo 3: Stepwise com k = 2 (AIC)
mod2a <- step(ajuste, direction = 'both')
summary(mod2a)

### M�todo 4: Stepwise com k = log(300) (BIC)
mod2b <- step(ajuste, direction = 'both', k = log(500))
summary(mod2b)

### M�todo 5: Forward com k = 2 (AIC)
mod3a <- step(ajuste_null, scope = formula(ajuste), direction = 'forward')
summary(mod3a)

### M�todo 6: Forward com k = log(300) (BIC)
mod3b <- step(ajuste_null, scope = formula(ajuste), direction = 'forward', k = log(n))
summary(mod3b)


########################################################################
### Agora, usando o m�todo lasso.

x <- model.matrix(ajuste)[, -1]
### Matriz de covari�veis. Observe a exclus�o da primeira coluna, que corresponde �
### coluna de uns (referente ao intercepto), que n�o deve ser inclu�da.

y <- dados_simul$y

mod4a <- glmnet(x, y, family = 'binomial', alpha = 1)
### Lasso regression (penaliza��o de primeira ordem)

x11(width = 12, height = 12)
par(cex = 1.5, las = 1)

plot(mod4a, las = 1, lwd = 2, label=TRUE)
plot(mod4a, xvar="lambda", label=TRUE, lwd = 2, cex = 20)
### Gr�ficos das estimativas vs termo de penaliza��o e vs lambda.

### Usando valida��o cruzada para determinar o valor de lambda.
cvfit <- cv.glmnet(x, y, family = 'binomial', alpha = 1, nfolds = 20) 
plot(cvfit)
cvfit$lambda.min 
### Lambda �timo.

coef(mod4a, s = cvfit$lambda.min)
### Modelo ajustado usando o lambda indicado pela valida��o cruzada.

coef(mod4a, s = 0.015)
### Solu��o obtida fixando lambda = 0.015.




