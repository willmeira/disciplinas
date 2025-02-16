### Vamos utilizar uma aplica��o bastante simples de glm, com apenas n=15 observa��es, 
### para ilustrar o uso de simula��o (bootstrap n�o param�trico) para
### estimar o vi�s e o erro padr�o das estimativas, bem como obter intervalos 
### de confian�a para os par�metros do modelo. 

### Vamos usar a fun��o Boot do pacote car para realiza��o das simula��es. 
### Antes de usar a fun��o, vamos usar o R para fazer "na m�o" um ou 
### dois passos do algoritmo, para que voc� entenda o que � feito.

########################################################################
### Passo 1 - Entrada dos dados e ajuste de um MLG Poisson.

x <- c(1.0, 1.1,1.4, 0.9, 1.6, 0.6, 0.5, 0.6, 0.4, 0.4, 1.4, 0.6, 1.9, 1.0, 0.8)
### Vari�vel explicativa.

y <- c(2, 3, 5, 6, 11,  2,  4,  0,  2,  0,  4,  4,  5, 3, 4) 
### Vari�vel resposta, discreta com valores positivos. Vamos usar o modelo
### de Poisson.

plot(x, y, pch = 20)

dados <- data.frame(x,y)

ajuste <- glm(y ~ x, family = 'poisson', data = dados)
summary(ajuste) 
### Observe as estimativas, os erros padr�es assint�ticos 
### e os testes para as hip�teses de nulidade dos par�metros do modelo.

confint(ajuste) ### Intervalos com n�vel (assint�tico) de 95% de confian�a.

########################################################################
### Passo 2 - Primeiros passos do bootstrap n�o param�trico (� m�o, para ilustra��o)

indices <- sample(1:15, replace = T); indices 
### Armazenamos em indices os �ndices das observa��es que v�o compor a 
### primeira re-amostra. Observe que algumas observa��es v�o aparecer 
### mais de uma vez,outras n�o aparecer�o na reamostra.

dadosb1 <- dados[indices,]; dadosb1 
### dadosb1 � a base de dados correspondente � primeira reamostra. Vamos 
### ajustar o modelo de Poisson para essa primeira reamostra.

ajusteb1 <- glm(y ~ x,family = 'poisson', data = dadosb1)
coef(ajuste) 
### Estimativas dos betas geradas pelo modelo ajustado com a amostra original...
coef(ajusteb1) 
### Estimativas dos betas geradas pelo modelo ajustado 

### Com a primeira reamostra bootstrap. Voc� pode observar que as estimativas 
### s�o diferentes daquelas obtidas no primeiro ajuste, o que j� era de 
### se esperar (a base � outra).

summary(ajusteb1) ### Resumo do modelo ajustado com a primeira amostra bootstrap.

### Fazendo uma segunda vez:

indices2 <- sample(1:15, replace = T); indices2 ### Outro conjunto de �ndices.
dadosb2 <- dados[indices2,]; dadosb2 
### A base correspondente aos �ndices selecionados (nossa segunda reamostra).
ajusteb2 <- glm(y ~ x, family = 'poisson', data = dadosb2)
coef(ajusteb2) ### E as estimativas dos par�metros geradas pela segunda reamostra.

### A ideia � repetir esses passos um grande n�mero de vezes (gerando um 
### grande n�mero de estimativas) e estimar os par�metros com base na distribui��o
### das estimativas geradas pelas reamostras, conforme discutido em sala de aula.
### Fica como exerc�cio para os alunos programar esse procedimento sem usar alguma 
### fun��o espec�fica do R.

########################################################################
### Passo 3 - Vamos usar a fun��o Boot, do pacote car, para a execu��o do bootstrap.

require(car)
require(boot)
help(Boot)
b1 <- Boot(ajuste, R = 999) ### Vamos utilizar 999 reamostragens.
head(boot.array(b1)) 
### Com a fun��o boot.array podemos verificar a composi��o (os �ndices)  
### em cada reamostra. Observar que cada linha se refere a uma reamostra.

hist(b1) ### Histogramas para as estimativas dos dois par�metros.
summary(b1) ### Por colunas: N�mero de reamostragens; 
### Estimativas geradas pelo modelo inicial (com a base original);
### Estimativas bootstrap para o v�cio; Estimativas bootstrap para
### o erro padr�o; Mediana das estimativas bootstrap.
### Comparar as duas �ltimas colunas com os resultados correspondentes 
### no summary do modelo original.

round(summary(ajuste)$coefficients[,1:2],4)

confint(b1)
confint(b1, type='perc')
confint(ajuste) 
### Intervalos de confian�a usando bootstrap (de duas formas diferentes)  
### e os intervalos assint�ticos. Repare que os intervalos assint�ticos s�o, 
### indevidamente, mais precisos.

### Agora, usando Bootstrap para estimar a resposta esperada para x = 1,5.
### exp(beta0 + beta1 * 1,5).

coef(ajuste)
f <- function(obj) exp(coef(obj)[1] + coef(obj)[2] * 1.5)
bpred <- Boot(ajuste,f , R=999)
confint(bpred, type = 'perc')

p1 <- predict(ajuste, newdata = data.frame(x = 1.5), type = 'link', se.fit = T)
intLink <- c(p1$fit - 1.96 * p1$se.fit, p1$fit + 1.96 * p1$se.fit)
intResp <- exp(intLink)
intResp

### Exerc�cio - Usar bootstrap para produzir infer�ncias para o problema dos
### sinistros (estimar os erros padr�es, calcular ICs). Comparar com os 
### correspondentes resultados assint�ticos.




