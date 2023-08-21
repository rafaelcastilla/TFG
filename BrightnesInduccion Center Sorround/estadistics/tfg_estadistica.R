setwd("C:/Users/rafael/Desktop/tfg")
library("readxl")
library("dplyr")
library(ggplot2)


################################################


Brigtness_induccion<-read_excel("BRIGTNESS INDUCCION_ALL.xlsx")
head(Brigtness_induccion)
#cojemos las 10 ultimas series
Brigtness_induccion<-data.frame(Brigtness_induccion)
aux_BI<-data.frame()

#cojer los 10 ultimos

for(x in unique(Brigtness_induccion$Subject)){
    for (i in 1:9){
      aux_BI<-rbind(aux_BI,tail(Brigtness_induccion[Brigtness_induccion$Subject==x & Brigtness_induccion$Index==i,],10))
  }
}



head(aux_BI)
aux_BI$diff<-aux_BI$Comparison.value.results. - aux_BI$Test.value
aux_BI$Amplitud<- aux_BI$First.inductor - aux_BI$Second.inductor

aux <- aux_BI %>% dplyr::group_by(Subject, Amplitud) %>%
  dplyr::summarise(MeanDiff=mean(`diff`))



#####analisys descriptivo##########

for (i in unique(aux$Subject)) {
  for(j in unique(aux$Amplitud)){
aux$var[aux$Subject==i & aux$Amplitud==j]=var(aux_BI$diff[aux_BI$Subject==i & aux_BI$Amplitud==j])
  }
}
aux$sd=sqrt(aux$var)

aux[aux$sd==max(aux$sd),]

names(aux_BI)

model<-lm(data = aux_BI, formula = diff~ORDEN+Seconds+EDAD+SEXO+Comparison.value.Initial.+Test.value+Amplitud)
summary(model)


# Call:
#   lm(formula = Comparison.value.results. ~ ORDEN + Seconds + EDAD + 
#        SEXO + Comparison.value.Initial. + Test.value + Amplitud, 
#      data = aux_BI)
# 
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -10.3760  -1.1421   0.0575   1.4251   9.5994 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)                6.055097   0.868799   6.970 4.45e-12 ***
#   ORDEN                      0.019064   0.013616   1.400  0.16164    
# Seconds                   -0.004669   0.007220  -0.647  0.51791    
# EDAD                      -0.020047   0.016257  -1.233  0.21768    
# SEXOH                     -0.140987   0.165577  -0.851  0.39461    
# SEXOM                     -0.731594   0.225647  -3.242  0.00121 ** 
#   Comparison.value.Initial.  0.027833   0.005391   5.163 2.70e-07 ***
#   Test.value                 0.609040   0.038150  15.965  < 2e-16 ***
#   Amplitud                   0.153981   0.002319  66.391  < 2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 2.538 on 1791 degrees of freedom
# (360 observations deleted due to missingness)
# Multiple R-squared:  0.7246,	Adjusted R-squared:  0.7234 
# F-statistic:   589 on 8 and 1791 DF,  p-value: < 2.2e-16


#para ver lo que puede esta causando estas discrepancias usaremos linear regresion para ver que variables son significantes
#podemos ver que el adjusted r-square es de 0.7234 ajustandose bastante bien probamos ha hacer un modelo eliminando las variables que no son significantes 



model2<-lm(data = aux_BI, formula = diff~SEXO+Comparison.value.Initial.+Test.value+Amplitud)
summary(model2)
# 
# Call:
#   lm(formula = Comparison.value.results. ~ SEXO + Comparison.value.Initial. + 
#        Test.value + Amplitud, data = aux_BI)
# 
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -10.2876  -1.1548   0.0888   1.4412   9.5636 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)                5.826965   0.670130   8.695  < 2e-16 ***
#   SEXOH                     -0.025180   0.144277  -0.175    0.861    
# SEXOM                     -0.939779   0.182510  -5.149 2.85e-07 ***
#   Comparison.value.Initial.  0.023186   0.004754   4.877 1.15e-06 ***
#   Test.value                 0.612624   0.033522  18.275  < 2e-16 ***
#   Amplitud                   0.153488   0.002040  75.236  < 2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 2.448 on 2154 degrees of freedom
# Multiple R-squared:  0.7377,	Adjusted R-squared:  0.7371 
# F-statistic:  1212 on 5 and 2154 DF,  p-value: < 2.2e-16

#Vemos que el este modelo se ajusta algo mejor, ya que podemos ver que la Multiple r-square es mayor y F-statistic es mayor

predicted<-data.frame( pred = predict(model2,aux_BI) , amplitud = aux_BI$Amplitud )  

aux3 <- predicted %>% dplyr::group_by(amplitud) %>%
  dplyr::summarise(MeanDiff=mean(pred))





ggplot(aux_BI,aes(x=Amplitud, y=diff,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Diff (Cd/m^2)")+
  ggtitle("Brigtness Induccion ")+
geom_hline(yintercept = 0)
ggsave("Brigness_induccion_diff.png")

#lo primero que podemos ver es que hay una especie de repulcion en el 0 donde la amplitud es positiva
#otra cos que se pude ver es que en la franja negativa en la amplitud si hay supresion, el off(cuando el inductor es menor al test) en todos los casos
#pero en cambio en el on si podemor ver que hay casos en el que no se ha producido producido induccion si no supresion
#la linea roja es la linea de prediccion que obtenemos con el modelo 2 




ggplot(aux,aes(x=Amplitud, y=MeanDiff,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Diff (Cd/m^2)")+
  ggtitle("Brigtness Induccion Mean")+
  geom_hline(yintercept = 0)
ggsave("Brigness_induccion_diff_means.png")

#si miramos la medias podemos ver mas claro como hay una repulsion en el 0 en las amplitudes positivas


  ggplot(aux_BI,aes(x=Amplitud, y=diff,color=Comparison.value.Initial.))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Diff (Cd/m^2)")+
  labs(color="Initial Value")+
  ggtitle("Brigtness Induccion by subjects ")+
  geom_hline(yintercept = 0)+
  facet_wrap(vars(Subject))
  ggsave("Brigness_induccion_diff_bysubjects.png")
  #si lo separamos por sujetos podemos claramente los sujetos que son anomoalos ,
  #DP por ejemplo podemos ver en amplitudes positivas que hay tanto en positivos
  #como negativos cosa que no es lo esperable, pero se puede ver con un vistazo que el valor inicial 
  #si influye en lo que acaba poniendo el sujeto eso tambien lo demuestra el modelo 1 y2
  #si hacemos un linear regreseon podemos ver que la variable Comparison.value.Initial. que es la que nos indica cual es la luminancia con la que empieza dicha medicion
  



  ggplot(aux,aes(x=Amplitud, y=MeanDiff))+
    geom_point()+
    geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
    xlab("Amplitud (Cd/m^2)")+
    ylab("Diff (Cd/m^2)")+
    labs(color="Initial Value")+
    ggtitle("Brigtness Induccion Mean by subjects")+
    geom_hline(yintercept = 0)+
    facet_wrap(vars(Subject))
  ggsave("Brigness_induccion_diff_means_bysubjects.png")
  
  #si miramos las medias podemos ver de forma mas sencilla los sujetos que se debian 
  #de la norma


######################################################################
center_surround<-read_excel("Center surround _all.xlsx")

head(center_surround)

names(center_surround)


head(aux_BI)

aux_CS<-data.frame()

#cojer los 10 ultimos

for(x in unique(center_surround$Subject)){
  for (i in 1:5){
    aux_CS<-rbind(aux_CS,tail(center_surround[center_surround$Subject==x & center_surround$Index==i,],10))
  }
}

aux <- aux_CS %>% dplyr::group_by(Subject, Amplitud) %>%
  dplyr::summarise(MeanAmplitude=mean(`Result (final amplitude)`))

model<-lm(data = aux_CS, formula = `Result (final amplitude)`~Amplitud+Seconds+`Initial diff position`+SEXO)
summary(model)

model2<-lm(data = aux_CS, formula = `Result (final amplitude)`~Amplitud)
summary(model2)

#los modelos que obtenemos tienen un multiplpe r-square muy pequeño no que podemos ver que se agusta miu mal
  

aux_CS$diff<- aux_CS$`Inside amplitud`-aux_CS$`Result (final amplitude)`

ggplot(data= aux_CS, aes(x=factor(Amplitud),y=`Result (final amplitude)`))+
  geom_boxplot()+
  xlab("Amplitud(Cd/m^2)")+
  ylab("Diff (Cd/m^2)")+
  ggtitle("Centre-surround diff ")
ggsave("CS_Boxplot.png")
#es este plot podemos ver como hhay mucha variabilidad en cuando la amplitud es 20 osea que llega a los 2 extremos 40Cd y 0 Cd 
#y es cuando se ve que hay mucha dispersion 



ggplot(data= aux_CS, aes(x=factor(Amplitud),y=`Result (final amplitude)`))+
geom_boxplot()+
  xlab("Amplitud(Cd/m^2)")+
  ylab("results Amplitud (Cd/m^2)")+
  ggtitle("Centre-surround diff by Subject ")+
  facet_wrap(vars(Subject))
ggsave("CS_Boxplot_Bysubject.png")

#podemos ver un par de cosas, hay quente que le aumenta la dispersion cuando aumenta la amplitud
#lo esperado es cuando la amplitud es mayor al fondo lo esperado es que la aplitud sea mayor o igual a la amplitud (10) pero vemos que no es asi hay sujetos como LM o AM que tienen tiene la amplitud menos al central 
#sujetos como DG que si hay durrounding, y lugo sujetos como XO que no hay surrounding tambien si contamos que el 10 es que todo este parejo cuando el surrounding es tiene una ampliud menor al center no se produce efecto o aun un efecto pequeño de induccion 
#cuando el surrounding tiene una amplitud mayor al center se puede ver que si hay enn persoas donde hay momentos que le produce una supresion y otras veces que e produce una induccion como DS o BM luego sujetos como RJ que o RM que le produce una supresion y luejo XO qO AF que no le produce apenas ninguna induccion 






##############################################################

predicted<-data.frame( pred = predict(model2,aux_CS) , amplitud = aux_CS$Amplitud )  

aux3 <- predicted %>% dplyr::group_by(amplitud) %>%
  dplyr::summarise(MeanAmplitud=mean(pred))



head(aux_CS)

ggplot(data= aux_CS, aes(x=Amplitud,y=`Result (final amplitude)`,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Amplitud Results(Cd/m^2)")+
  ggtitle("Centre-surround Amplitud")
ggsave("Center-surround_amplitud.png")

#en este plot podemos ver que como a medida que se aumenta la amplitud la hay mas variacion entre los sujetos y en ellos mismos

ggplot(data= aux_CS, aes(x=Amplitud,y=`Result (final amplitude)`,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Amplitud Results(Cd/m^2)")+
  ggtitle("Centre-surround Amplitud")+
  facet_wrap(vars(Subject))
ggsave("Center-surround_amplitud_by subject.png")

#si lo vemos por sujeto podemos ver como hay sujetos como af que siguen lo predecido y luego sujetos como DS o XO que no lo siguen


ggplot(data= aux, aes(x=Amplitud,y=MeanAmplitude,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Amplitud Results(Cd/m^2)")+
  ggtitle("Centre-surround Amplitud Mean")
ggsave("Center-surround_amplitud_mean.png")


#Viendo la medias en un point plot podemos ver que cuando la amplitud del surroundes menor a al center aunque se produce supresion y en algunos se produce infuccion
#pero cuando la amplitud del surround es mayor al center a diferencia de lo esperado  hay genete en la que no se produce supresion si no que hay gente a la que se produce induccion 
#cosa completamente a la esperada 

ggplot(data= aux, aes(x=Amplitud,y=MeanAmplitude,color=Subject))+
  geom_point()+
  geom_line(color="red", data=predicted,aes(y=pred, x=amplitud))+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Amplitud Results(Cd/m^2)")+
  ggtitle("Centre-surround Amplitud Mean By subject")+
  facet_wrap(vars(Subject))
ggsave("Center-surround_amplitud_mean.png")

#si vemos las medias por sujetos podemos ver aun mas claro las divergencias entre los sujetos 

#podemos ver que la amplitud inicial podemos ver que si hay alguna relacion en donde espieza a el resultado final
#en amplitud bajas podemos ver que si la amplitud inicial en baja la hay una tendencia la induccion mientras que en amplitudes altas es al contrario

ggplot(data= aux_CS, aes(x=factor(Amplitud),y=`Result (final amplitude)`,color=`Initial diff position`))+
  geom_point()+
  xlab("Amplitud (Cd/m^2)")+
  ylab("Amplitud Results(Cd/m^2)")+
  geom_hline(yintercept = 10)+
  labs(color="Initial Amplitud")+
  ggtitle("Amplitud results")+
  facet_wrap(vars(Subject))
ggsave("Center-surround_amplitud_initial_Amplitude.png")
#podemos ver que la amplitud inicial podemos ver que si hay alguna relacion en donde espieza a el resultado final
#en amplitud bajas podemos ver que si la amplitud inicial en baja la hay una tendencia la induccion mientras que en amplitudes altas es al contrario
#si miramos por sujetos podemos ver que hay sujetos en el que sucede lo esperado como ap 
#sujetos que hay no se produce supresion como XO, o sujetos como DS en la que se produce una induccion




##############################################################################
