require(faraway)
require(car)
require(multcomp)

data(dicentric)
head(dicentric)
summary(dicentric)
names(dicentric) <- c('C�lulas','Anormais','Dose','Taxalib')


round(xtabs(Anormais/C�lulas ~ Dose+Taxalib,dicentric),2) 
### Taxa de cromossomos anormais segundo dose aplicada e taxa de libera��o da dose.

x11()
with(dicentric,interaction.plot(Taxalib, Dose,Anormais/C�lulas)) 
### Representa��o gr�fica da tabela cruzada.


### Vamos tratar a dose administrada como um fator (compararemos as diferen�as 
# nas taxas de anormalidade sob as tr�s doses consideradas) 
# e a taxa de libera��o como num�rico.

dicentric$Dose <- as.factor(dicentric$Dose)


### Vamos ajustar modelos de regress�o Poisson considerando a (log) contagem
### de c�lulas como termo offset.

### Inicialmente, vamos considerar modelos com efeitos aditivos de dose
### e taxa de libera��o (sem intera��o). Vamos avaliar a melhor forma de
### inserir a taxa de libera��o.

### Ajuste 1 - apenas o termo linear.
ajuste1 <- glm(Anormais ~ Dose + Taxalib + offset(log(C�lulas)), family = poisson, data = dicentric) 
summary(ajuste1)

### Ajuste 2: incluindo o termo quadr�tico.
ajuste2 <- glm(Anormais ~ Dose + Taxalib + I(Taxalib^2) + offset(log(C�lulas)), family = poisson, data = dicentric) 
summary(ajuste2)

### Ajuste 3: considerando o logaritmo da taxa de libera��o.
ajuste3 <- glm(Anormais ~ Dose + log(Taxalib) + offset(log(C�lulas)), family = poisson, data = dicentric) 
summary(ajuste3)

### A terceira op��o produziu melhor ajuste (repare os valores das deviances e AICs)

### Agora, vamos avaliar se h� efeito de intera��o.
ajuste4 <- glm(Anormais ~ log(Taxalib) * Dose + offset(log(C�lulas)), family = poisson, data = dicentric) 
summary(ajuste4)
anova(ajuste3, ajuste4, test = 'Chisq')


dicentric$logx2 <- log(dicentric$Taxalib)^2
ajuste5 <- glm(Anormais ~ logx2 + log(Taxalib) * Dose + offset(log(C�lulas)), family = poisson, data = dicentric) 
summary(ajuste5)

  
### O efeito de intera��o � altamente significativo. Vamos mant�-lo no modelo.

plot(allEffects(ajuste4))
plot(allEffects(ajuste4), type = 'response')

### Vamos estimar se a varia��o na taxa de cromossomos anormais � diferente
### sob as doses 2.5 e 5.

summary(glht(ajuste4, "log(Taxalib):Dose5 - log(Taxalib):Dose2.5 = 0"))
### A diferen�a � n�o significativa.

### Exerc�cio - Realizar o diagn�stico do ajuste com base na an�lise de 
# res�duos, gr�fico qqplot com envelope simulado,... 

### Uma forma de checar a adequa��o da distribui��o Poisson � incorporar 
### o offset ao preditor como covari�vel, associando a ele um par�metro a ser estimado,
# e comparar os ajustes (testando beta(c�lulas)=1). Pergunta: Por que?

ajuste5 <- glm(Anormais~Dose*log(Taxalib)+log(C�lulas),family=poisson,data=dicentric) 
### Modelo com intera��o entre dose e taxa de libera��o, o (log) n�mero de c�lulas
# n�o entra como offset, mas sim com um par�metro adicional a ser estimado.

anova(ajuste4, ajuste5, test='Chisq')

### O resultado n�o significativo para o teste indica que n�o h� evid�ncias 
# contra a hip�tese nula (beta(log(c�lulas))=1), ou seja, � pertinente incorporar o (log) n�mero de c�lulas
# como termo offset. Ponto para a distribui��o Poisson!