########################################################################
########################################################################
########################################################################
### Regress�o para dados bin�rios
### Exemplo 1

### Dados sobre auditoria na presta��o de contas de 3000 indiv�duos. 
### As vari�veis s�o as segintes:
### rest: �  a restitui��o financeira solicitada (em milhares de d�lares) 
### audit: e a resposta � o resultado da auditoria (1, o valor
### da restitui��o estava calculado incorretamente e 0, se estava
### correto). O objetivo � modelar o resultado da auditoria em fun��o
### do valor requisitado para restitui��o.

auditoria <- read.csv2('https://docs.ufpr.br/~taconeli/CE22518/auditoria.csv')

x11(width = 10, height = 10)
par(las = 1, mar = c(5,4,2,2), cex = 1.4)
plot(audit ~ rest, data = auditoria, pch = "|", ylim = c(-0.5, 1.5), col = 'blue',
     xlab = 'Valor para restitui��o', ylab = 'Resultado da auditoria')
### Aparentemente, presta��es de contas com maiores valores requeridos
### est�o mais propensas a erros.

################################################################################
### Vamos ajustar um modelo de regress�o linear. 
ajuste <- lm(audit ~ rest, data = auditoria)
abline(coef(ajuste), col = 'red', lwd = 2)
lines(sort(auditoria$rest), fitted(ajuste)[order(auditoria$rest)], col = 'red', lwd = 2)
### O modelo ajustado claramente n�o � apropriado. Observe que para determinados
### valores da vari�vel explicativa, temos valor ajustado inferior a zero
### ou superior a 1.

################################################################################
### Vamos contornar isso ajustando um modelo com resposta binomial, o que
### permitir� modelar a probabilidade de uma conta apresentar erros condicional
### ao valor requerido para restitui��o. Vamos avaliar diferentes fun��es de
### liga��o que podem ser usadas na modelagem de dados bin�rios.

x11(width = 10, height = 10)
par(las = 1, mar = c(5,4,2,2), cex = 1.4)
plot(audit ~ rest, data = auditoria, pch = "|", ylim = c(0,1), col = 'lightblue',
     xlab = 'Valor para restitui��o', ylab = 'Resultado da auditoria')

### Fun��o de liga��o logito.
ajuste2 <- glm(audit ~ rest, family = binomial(link = logit), data = auditoria)
summary(ajuste2)
lines(sort(auditoria$rest), predict(ajuste2, type = 'response')[order(auditoria$rest)], 
      col = 'black', lwd = 2)
### Adicionando a regress�o ajustada ao gr�fico.

### Fun��o de liga��o probito.
ajuste3 <- glm(audit ~ rest, family = binomial(link = probit), data = auditoria)
summary(ajuste3)
lines(sort(auditoria$rest), predict(ajuste3, type = 'response')[order(auditoria$rest)], 
      col = 'red', lwd = 2)

### Fun��o de liga��o complemento log-log.
ajuste4 <- glm(audit ~ rest, family = binomial(link = cloglog), data = auditoria)
summary(ajuste4)
lines(sort(auditoria$rest), predict(ajuste4, type = 'response')[order(auditoria$rest)], 
      col = 'blue', lwd = 2)

### Fun��o de liga��o Cauchy.
ajuste5 <- glm(audit ~ rest, family = binomial(link = cauchit), data = auditoria)
summary(ajuste5)
lines(sort(auditoria$rest), predict(ajuste5, type = 'response')[order(auditoria$rest)], 
      col = 'orange', lwd = 2)

legend(x = 'bottomright', lwd = 2, col = c('black', 'red', 'blue', 'orange'),
       legend = c('Logito', 'Probito', 'Cloglog', 'Cauchy'))

### Aparentemente, os modelos com liga��o logito e probito proporcionam melhor
### ajuste que os demais. Al�m disso, os ajustes desses dois modelos s�o
### bastante semelhantes. Vamos comparar os modelos com base nos respectivos
### AICs.

AIC(ajuste2, ajuste3, ajuste4, ajuste5)
### O ajuste 2 (modelo com liga��o logito) produziu menor AIC, sendo prefer�vel.
