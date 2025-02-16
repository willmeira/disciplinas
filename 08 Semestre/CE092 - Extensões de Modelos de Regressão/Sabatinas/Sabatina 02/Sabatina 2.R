rm(list=ls())
##
#Considere os dados dispon�veis no objeto tb1 criado com o c�digo R do bloco a seguir.
tb1 <- data.frame(x = seq(0, 2, by = 0.1),
                  y1 = c(5.5, 7.2, 10.4, 7.4, 7.2, 9.1, 15.9, 12.7,
                         11.3, 14.4, 14.8, 17.1, 31.4, 17.5, 27.6, 19.6,
                         27.1, 21, 33.8, 30.2, 45.1),
                  y2 = c(0.8, 1.5, 2.6, 1.5, 1.4, 2.1, 3.9, 3.3, 3, 3.9,
                         4.2, 4.8, 6.9, 5.5, 7.3, 6.7, 8.2, 8.1, 10.2,
                         10.7, 12.8))

library(lattice)
library(latticeExtra)

#Digrama de dispers�o.
xyplot(y1 + y2 ~ x, data = tb1, outer = TRUE, scales = "free")

# Essa tabela de dados cont�m os valores de duas vari�veis respostas, y1 e y2, como fun��o de uma vari�vel quantitativa x. Apesar de estarem na 
# mesma tabela, y1 e y2 n�o s�o medidas observadas juntas mas sim de experimentos diferentes mas coincidentemente observadas sob os mesmos 
# valores da vari�vel independente x.

# 01 - Modelo gaussiano para y1 com preditor linear em x e fun��o de liga��o can�nica.
m1 <- lm(y1 ~ x, data = tb1)
lm1 <- logLik(m1)
grid1 <- predict(m1, newdata = data.frame(x = seq(0, 2, 0.05)))                      # lm(y ~ x)

# 02 - Modelo gaussiano para y1 com preditor quadr�tico em x e fun��o de liga��o can�nica.
m2 <- lm(y1 ~ x + I(x^2), data = tb1)
lm2 <- logLik(m2)
grid2 <- predict(m2, newdata = data.frame(x = seq(0, 2, 0.05)))                      # lm(y ~ x + x�)


# 03 - Modelo gaussiano para log(y1) com preditor linear em x e fun��o de liga��o can�nica.
m3 <- lm(log(y1) ~ x, data = tb1)
lm3 <- logLik(m3) - sum(log(tb1$y1))
grid3 <- predict(m3, newdata = data.frame(x = seq(0, 2, 0.05)))                      # lm(log(y) ~ x)

# 04 - Modelo gaussiano para sqrt^y1 com preditor linear em x e fun��o de liga��o can�nica.
m4 <- lm(sqrt(y1) ~ x, data = tb1)
lm4 <- logLik(m4) - sum(log(2 * sqrt(tb1$y1)))
grid4 <- predict(m4, newdata = data.frame(x = seq(0, 2, 0.05)))                      # lm(sqrt(y) ~ x)

# 05 - Modelo gaussiano para BoxCox(y1)=(y1^L-1)/L com preditor linear em x e fun��o de liga��o can�nica. O valor de L � o que otimiza 
# a log-verossimilhan�a perfilhada.
l <- MASS::boxcox(tb1$y1 ~ tb1$x)
l <- l$x[which.max(l$y)]
abline(v = 0.5)
m5 <- lm((y1^l - 1)/l ~ x, data = tb1)
lm5 <- logLik(m5) - (1/l - 1) * sum(log(tb1$y1^l))
grid5 <- predict(m5, newdata = data.frame(x = seq(0, 2, 0.05)))                      # lm(BC(y) ~ x)

# 06 - Modelo gama para y1 com preditor linear em x e fun��o de liga��o can�nica.
m6 <- glm(y1 ~ x, data = tb1, family = Gamma)
lm6 <- logLik(m6)
grid6 <- predict(m6, newdata = data.frame(x = seq(0, 2, 0.05)), type = "response")   # glm(y ~ Gamma(x))

# 07 - Modelo gaussiano inverso para y1 com preditor linear em x e fun��o de liga��o can�nica.
m7 <- glm(y1 ~ x, data = tb1, family = inverse.gaussian)
lm7 <- logLik(m7)
grid7 <- predict(m7, newdata = data.frame(x = seq(0, 2, 0.05)), type = "response")   # glm(y ~ NormInv(x))

# 08 - Modelo gaussiano para y1 com preditor linear em x e fun��o de liga��o logar�tmica.
m8 <- glm(y1 ~ x, data = tb1, family = gaussian(link=log))
lm8 <- logLik(m8)
grid8 <- predict(m8, newdata = data.frame(x = seq(0, 2, 0.05)), type = "response")   # glm(y ~ LogNorm(x))

# Comparando Verossimilhan�as
veros <- c(lm1, lm2, lm3, lm4, lm5, lm6, lm7, lm8)
modelo <- c("M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8")
df.vero <- data.frame(modelo, veros) 
df.vero

###################################################################################################################
#Obtenha os valores preditos na escala da vari�vel resposta para a sequ�ncia de valores de x em 0,0.05,0.10,.,2.

######a. A log-verossimilhan�a do modelo 3 foi superior a do 1.
lm3>lm1 
#true

#b. A log-verossimilhan�a do modelo 4 foi superior a do 1.
lm4>lm1
#true

#######c. A distribui��o considerada no modelo 6 � mais apropriada para os dados que a do modelo 7.
AIC(m6) < AIC(m7)
lm6 > lm7
#true

#######d. O uso da fun��o de liga��o logar�tmica no modelo 8 deu log-verossmilha�a inferior ao modelo 1 que usou fun��o de liga��o identitidade.
lm8<lm1
#false

#e. Dentre os modelos que n�o transformaram a vari�vel resposta, a maior log-verossmilhan�a � a do modelo 8.
# ********* 1,2,6,7,8 *********
veros <- c(lm1, lm2, lm6, lm7, lm8)
modelo <- c("M1", "M2", "M6", "M7", "M8")
df.vero <- data.frame(modelo, veros) 
df.vero
max(df.vero$veros)
#false, a maior � M6

#f. O modelo 2 com termo quadr�tico no preditor produziu log-verossimilhan�a inferior ao modelo 1.
lm2<lm1
#false

#g. No intervalo x???[0.5,1.5], o valor predito, y^, pelo modelo 1 � superior ao valor predito pelo modelo 2.
all(predict(m1, newdata = data.frame(x = seq(0.5, 1.5, 0.05))) > predict(m2, newdata = data.frame(x = seq(0.5, 1.5, 0.05))))
# avaliando a soma
sum(grid1) > sum(grid2)
# avaliando M1 - M2
df.1x2 <-c(predict(m1, newdata = data.frame(x = seq(0.5, 1.5, 0.05))) - predict(m2, newdata = data.frame(x = seq(0.5, 1.5, 0.05))))
df.1x2
# avaliando graficamente
plot(y1 ~ x, data = tb1)
lines(seq(0, 2, 0.05), grid1, col = 1)
lines(seq(0, 2, 0.05), grid2, col = "red")
abline(v = c(0.5, 1.5), lty = 2, col = "green")

#TRUE

######h. Na origem (x=0), o modelo 3 tem valor predito inferior ao do modelo 4.
predict(m3, newdata = data.frame(x = 0)) < predict(m4, newdata = data.frame(x = 0))
x03 <- predict(m3, newdata = data.frame(x = 0)) 
x04 <- predict(m4, newdata = data.frame(x = 0))
plot(y1 ~ x, data = tb1)
lines(seq(0, 2, 0.05), grid3)
lines(seq(0, 2, 0.05), grid4, col = "red")
abline(v = c(0, 1.5), lty = 2, col = "green")
#true

##
ndf <- data.frame(seq(0, 2, 0.05), grid3, grid4)
ndf


#######i. No intervalo x???[0.75,1.5], os valores preditos pelo modelo 7 est�o mais pr�ximas do modelo 1 que o modelo 6 do modelo 1.
# avaliando distancia quadratica
sum(grid7 - grid1)^2 < sum(grid6 - grid1)^2

# avaliando graficamente
plot(y1 ~ x, data = tb1)
lines(seq(0, 2, 0.05), grid1)
lines(seq(0, 2, 0.05), grid6, col = "red")
lines(seq(0, 2, 0.05), grid7, col = "blue")
abline(v = c(0.75, 1.5), lty = 2, col = "green")

# FALSE

#j. A transforma��o da resposta no modelo 3 � mais apropriada que a transforma��o feita no modelo 4.
lm3>lm4
AIC(lm3)<AIC(lm4)
#TRUE

#k. A log-verossimilhan�a do modelo 3, corrigida para a escala natural da vari�vel resposta, foi -54.70.
lm3
#TRUE

#l. Considerando apenas os modelos que n�o fizeram transforma��o da vari�vel resposta, os modelos com valores preditos mais 
#pr�ximos um do outro foram 2 e 8. 
# ********* 1,2,6,7,8 *********
plot(y1 ~ x, data = tb1)
lines(seq(0, 2, 0.05), grid1)
lines(seq(0, 2, 0.05), grid2, col = "red")
lines(seq(0, 2, 0.05), grid6, col = "blue")
lines(seq(0, 2, 0.05), grid7, col = "purple")
lines(seq(0, 2, 0.05), grid8, col = "yellow")
abline(v = c(0.75, 1.5), lty = 2, col = "green")
#TRUE