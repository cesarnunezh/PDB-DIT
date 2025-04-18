################################################################################
# Objetivo: Replica
# Proyecto: PdB-DIT
# 
# Estructura:
# 0. Librerías y direcciones
# 1. Append de bases 2019-2023
# 2. Unión de bases a nivel de hogar y personas
# 3. Creación de variables de interés

################################################################################
# 0. Librerías y direcciones ----
bdEndes <- "C:/Users/Jennifer Prado/OneDrive - VIDENZA/Proyectos activos/1. PDB - DIT/2. Data/ENDES/0. Original"
#bdEndes <- "C:/Users/User/OneDrive - MIGRACIÓN VIDENZA/1. Proyectos/1. Proyectos actuales/23. Artículos PDB/1. PDB - DIT/2. Data/ENDES/0. Original"
bdTrabajo <- "C:/Users/Jennifer Prado/OneDrive - VIDENZA/Proyectos activos/1. PDB - DIT/2. Data/ENDES/1. Bases"
#bdTrabajo <- "C:/Users/User/OneDrive - MIGRACIÓN VIDENZA/1. Proyectos/1. Proyectos actuales/23. Artículos PDB/1. PDB - DIT/2. Data/ENDES/1. Bases"
dirOutput <-"C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output"
#dirOutput <-"C:/Users/User/Documents/GitHub/PDB-DIT/Output"
library(dplyr)  
library(haven)
library(ggplot2)

# 1. Append de bases 2019-2023 ----

data19_23 <- c("dit", "rec44" ,"rec43" , "rec42", "rec41", "rec21", "re758081", "re516171",
               "re223132", "programas_sociales_x_hogar", "rec82", "rec83", "rec84dv",
               "rec91", "rec94", "rec95", "rec0111", "rech0", "rech1", "rech4", 
               "rech5", "rech6", "rech23")

# Set working directory
setwd(bdEndes)

# Function
convert_labeled_to_numeric <- function(df) {
  for (col in names(df)) {
    if (inherits(df[[col]], "haven_labelled")) {
      df[[col]] <- as.numeric(df[[col]])
    }
  }
  return(df)
}

# Loop through each dataset and year
for (mod in data19_23) {
  for (x in 2019:2023) {
    # Read data
    data <- read_dta(paste0(mod, "_", x, ".dta"))
    colnames(data) <- tolower(colnames(data))
    data$id1 <- x
    data <- convert_labeled_to_numeric(data)
    
    # Store the combined data frame in the list
    if (x == 2019) {
      df <- data
    }
    else {
      dataNames <- colnames(data)
      dfNames <- colnames(df)
      common_cols <- intersect(dataNames, dfNames)
      df <- rbind(df[common_cols], data[common_cols])
      
    }
  }
  assign(paste0(mod), df)
  
}

rm(data, df)

# 2. Unión de bases a nivel de hogar y personas ----------
# Base hogares----
baseHogaresENDES <- rech0 %>% 
  left_join(rech23, by = c("id1", "hhid")) %>% 
  rename(mieperho = hv013,
         nMujeres = hv010,
         nHombres = hv011,
         nNinos = hv014,
         estrato = hv022,
         dominio = hv023,
         region = hv024,
         area = hv025,
         altitud = hv040,
         quintil = hv270,
         riqueza = hv271,
         tvCable = sh61j,
         licuadora = sh61k,
         cocinaGas = sh61l,
         microndas = sh61n,
         lavadora = sh61o,
         computadora = sh61p,
         internet = sh61q,
         cortinas = sh76e,
         celular = hv243a) %>% 
  mutate(agua = case_when(hv201 == 11 | hv201 == 12 ~ 1,
                          hv201 == 99 ~ NA,
                          is.na(hv201) ~ NA,
                          TRUE ~ 0),
         tiempoAgua = case_when(hv204 == 996 | hv204 == 998 | hv204 == 999 ~ NA,
                                TRUE ~ hv204),
         desague = case_when(hv205 == 11 | hv205 == 12 ~ 1,
                             hv205 == 99 ~ NA,
                             is.na(hv205) ~ NA,
                             TRUE ~ 0),
         electricidad = case_when(hv206 == 1  ~ 1,
                                  hv206 == 9 ~ NA,
                                  is.na(hv206) ~ NA,
                                  TRUE ~ 0),
         radio = case_when(hv207 == 1  ~ 1,
                           hv207 == 9 ~ NA,
                           is.na(hv207) ~ NA,
                           TRUE ~ 0),
         tv = case_when(hv208 == 1  ~ 1,
                        hv208 == 9 ~ NA,
                        is.na(hv208) ~ NA,
                        TRUE ~ 0),
         refrigerador = case_when(hv209 == 1  ~ 1,
                                  hv209 == 9 ~ NA,
                                  is.na(hv209) ~ NA,
                                  TRUE ~ 0),
         bicicleta = case_when(hv210 == 1  ~ 1,
                               hv210 == 9 ~ NA,
                               is.na(hv210) ~ NA,
                               TRUE ~ 0),
         moto = case_when(hv211 == 1  ~ 1,
                          hv211 == 9 ~ NA,
                          is.na(hv211) ~ NA,
                          TRUE ~ 0),
         carro = case_when(hv212 == 1  ~ 1,
                           hv212 == 9 ~ NA,
                           is.na(hv212) ~ NA,
                           TRUE ~ 0),
         pisoBajaCalidad = case_when(hv213 == 11 | hv213 == 21 | hv213 == 96 ~ 1,
                                     is.na(hv213) ~ NA,
                                     TRUE ~ 0),
         paredBajaCalidad = case_when(hv214 < 29 | hv214 == 41 | hv214 == 96 ~ 1,
                                      is.na(hv214) ~ NA,
                                      TRUE ~ 0),
         techoBajaCalidad = case_when(hv215 < 29 | hv215 == 41 | hv215 == 96 ~ 1,
                                      is.na(hv215) ~ NA,
                                      TRUE ~ 0),
         hacinamiento = case_when(hv216 == 0 ~ 0,
                                  TRUE ~ mieperho / hv216),
         mujerJH = case_when(hv219 == 2 ~ 1,
                             is.na(hv219) ~ NA, 
                             TRUE ~ 0),
         edadJH = case_when(hv220 == 98 | hv220 == 99 ~ NA,
                            is.na(hv220) ~ NA, 
                            TRUE ~ hv220),
         combustibleCocina = case_when(hv226 >= 6 & hv226 < 95 ~ 1 ,
                                       is.na(hv226) ~ NA,
                                       TRUE ~ 0))

baseHogaresENDES <- baseHogaresENDES %>%
  mutate(nActivosPrioritarios = rowSums(select(., computadora, radio, lavadora, licuadora, microndas, refrigerador, tv)))

# Base personas----
basePersonasENDES <- rech4 %>% 
  rename(hvidx = idxh4) %>% 
  left_join(rech1, by = c("id1", "hhid", "hvidx")) %>% 
  left_join(rech0, by = c( "id1", "hhid")) %>% ##falta para poner los pesos
  rename(estadoCivil = hv115,
         estudia = hv110) %>% 
  mutate(mujer = case_when(hv104 == 2 ~ 1,
                           is.na(hv104) ~ NA,
                           TRUE ~ 0),
         edad = case_when(hv105 == 98 | hv105 == 99 | is.na(hv105) ~ NA,
                          TRUE ~ hv105),
         educ = case_when(hv109 == 8 | is.na(hv109) ~ NA,
                          TRUE ~ hv109),
         aniosEduc = case_when(hv108 == 97 | hv108 == 98 | is.na(hv108) ~ NA,
                               TRUE ~ hv108),
         noEstudia = case_when(hv129 == 0 | hv129 == 4 | hv129 == 5 ~ 1,
                               is.na(hv129) | hv129 == 9 ~ NA,
                               TRUE ~ 0),
         algunSeguro = case_when(sh11a ==1 | sh11b ==1 | sh11c ==1 | sh11d ==1 | sh11e ~ 1,
                                 TRUE ~ 0),
         pea = case_when(sh13 == 1 | sh13 == 2 | sh13 == 3 | sh13 == 4 | sh13 == 5 ~ 1,
                         TRUE ~ 0),
         pesoP = hv005/1000000)

### Base Niños - creación de variables ###

baseNinosENDES <- rech6 %>%
  rename(hvidx = hc0) %>%
  left_join(basePersonasENDES, by = c("id1", "hhid", "hvidx")) %>%
  left_join(rech23, by = c("id1", "hhid")) %>% ##para hacer el merge de quintiles de riqueza
  mutate(edad = hc1,
         edad_5 = ifelse(hc1 < 5, NA_real_, hc1),  ##edad para todos los que son mayor de 5 meses 
         edad_6 = ifelse(hc1 < 6, NA_real_, hc1),  ##edad para todos los que son mayor de 6 meses 
         peso = case_when(is.na(hc2) ~ NA_real_,
                          TRUE ~ hc2),
         talla = case_when(is.na(hc3) ~ NA_real_,
                           TRUE ~ hc3),
         tallaEdad = case_when(is.na(hc5) ~ NA_real_,
                               TRUE ~ hc5),
         pesoEdad = case_when(is.na(hc8) ~ NA_real_,
                              TRUE ~ hc8),
         pesoTalla = case_when(is.na(hc11) ~ NA_real_,
                               TRUE ~ hc11),
         mujer = case_when(hc27 == 2 ~ 1,
                           hc27 == 1 ~ 0),
         anemiaNinos = case_when(hc57 < 4 & edad <= 60 ~ 1,
                                 is.na(hc57) ~ NA_real_,
                                 TRUE ~ 0),
         anemiaNivelNinos = case_when(hc57 == 1 ~ 4,
                                      hc57 == 2 ~ 3,
                                      hc57 == 3 ~ 2,
                                      hc57 == 4 ~ 1,
                                      is.na(hc57) ~ NA_real_,
                                      TRUE ~ 0),
         anemiaSevNinos = case_when(anemiaNivelNinos == 4 ~ 1,
                                    anemiaNivelNinos < 4 ~ 0,
                                    TRUE ~ NA_real_), 
         educMadre = case_when(hc61 == 8 | hc61 == 9 ~ NA_integer_,
                               is.na(hc61) ~ NA_integer_,
                               TRUE ~ hc61),
         desnCrOms = case_when((hc70 < -200 & hv103 == 1) ~ 1,
                               (hc70 >= -200 & hc70 < 601 & hv103 == 1) ~ 0,
                               TRUE ~ NA_integer_),
         desnCrSev = case_when((hc70 < -300  & hv103 == 1) ~ 1,
                               (hc70 >= -300 & hc70 < 601 & hv103 == 1) ~ 0)) %>%
  group_by(edad,edad_5,edad_6,hv270) %>% ## hv270 es índice de riqueza, donde 5 es quintil más rico y 1 más pobre
  summarize(porcentaje_anemia = weighted.mean(anemiaNinos, w = pesoP, na.rm = TRUE) * 100, #porcentaje para prevalencia anemia
         porcentaje_DCI = mean(desnCrOms, w = pesoP, na.rm = TRUE) * 100, #porcentaje prevalencia DCI
         n = n(),
         se = sqrt(weighted.mean(anemiaNinos, w = pesoP, na.rm = TRUE) * 
                     (1 - weighted.mean(anemiaNinos, w = pesoP, na.rm = TRUE)) / n()) * 100,
         seDCI = sqrt(weighted.mean(desnCrOms, w = pesoP, na.rm = TRUE) * 
                        (1 - weighted.mean(desnCrOms, w = pesoP, na.rm = TRUE)) / n()) * 100,
         .groups = 'drop') %>%
  mutate(lower = porcentaje_anemia - 1.96 * se,
         upper = porcentaje_anemia + 1.96 * se,
         lowerDCI = porcentaje_DCI - 1.96 * seDCI,
         upperDCI = porcentaje_DCI + 1.96 * seDCI)


# Replica de graficos
####ANEMIA###
  library(ggplot2)
  anemia<- ggplot(data = baseNinosENDES, aes(x = edad , y = porcentaje_anemia))+ 
    geom_point(size = 1, color = "black") +
    geom_smooth(method = "loess", se = FALSE, color = "red", linewidth = 1) +  # Línea suavizada
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2, color = "black") +
    labs(
      title = "Prevalencia de la anemia según edad. Perú 2019-2023",
      x = "Edad en meses",
      y = "95% CI Prevalencia de Anemia"
    ) +
    theme_minimal() +
    geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
    scale_x_continuous(breaks = seq(5, 60, by = 5)) 
    
    output_file <- file.path(dirOutput, "Prevalencia de anemia.png")
    ggsave(filename = output_file, plot = anemia, width = 10, height = 6, dpi = 300)
    
### Anemia - por quintiles ### usar esta forma para los demás resultados!! 
    
    base_NinosEndesf <- baseNinosENDES %>% filter(hv270 %in% c(1, 5))
    anemiaq <-ggplot(data = base_NinosEndesf, aes(x = edad_6, y = porcentaje_anemia, color = as.factor(hv270))) + 
      geom_point(size = 1) +
      geom_smooth(aes(group = hv270), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
      geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) + 
      labs(
        title = "Prevalencia de la anemia según edad y quintil de riqueza. Perú 2019-2023",
        x = "Edad en meses",
        y = "95% CI Prevalencia de Anemia",
        color = "Quintil de Riqueza"
      ) +
      theme_minimal() +
      theme(text = element_text(family = "Arial")) +  # Cambiar la fuente a Arial
      geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
      scale_x_continuous(breaks = seq(6, 60, by = 6)) +
      scale_color_manual(
        values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde agua
                   "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo oscuro
        labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
      )
    
    output_file <- file.path(dirOutput, "Prevalencia de anemia por quintiles.png")
    ggsave(filename = output_file, plot = anemiaq, width = 10, height = 6, dpi = 300, bg ="white")
    
####DCI###

    library(ggplot2)
    DCI<-
      ggplot(data = baseNinosENDES, aes(x = edad , y =  porcentaje_DCI))+ 
      geom_point(size = 1, color = "black") +
      geom_smooth(method = "loess", se = FALSE, color = "red", size = 1) +  # Línea suavizada
      geom_errorbar(aes(ymin = lowerDCI, ymax = upperDCI), width = 0.2, color = "black") +
      labs(
        title = "Prevalencia de la DCI según edad. Perú 2019-2023",
        x = "Edad en meses",
        y = "95% CI Prevalencia de DCI"
      ) +
      theme_minimal() +
      geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red")   # Líneas verticales
    scale_x_continuous(breaks = seq(5, 60, by = 5))   

    output_file <- file.path(dirOutput, "Prevalencia de la DCI.png")
    ggsave(filename = output_file, plot = DCI, width = 10, height = 6, dpi = 300 )
    
    ### DCI - por quintiles ### 
    base_NinosEndesf <- baseNinosENDES %>% filter(hv270 %in% c(1, 5))
    DCIq <-ggplot(data = base_NinosEndesf, aes(x = edad, y = porcentaje_DCI, color = as.factor(hv270))) + 
      geom_point(size = 1) +
      geom_line(aes(group = interaction(hv270, edad)), size = 1) +  # Línea suavizada para cada quintil
      geom_errorbar(aes(ymin = lowerDCI, ymax = upperDCI), width = 0.2) + 
      geom_smooth(method = "loess", se = FALSE, aes(group = hv270), linetype = "solid") +  # Línea de tendencia para cada quintil
      labs(
        title = "Prevalencia de desnutrición crónica infantil, según edad y quintil de riqueza. Perú 2019-2023",
        x = "Edad en meses",
        y = "95% CI Prevalencia de DCI",
        color = "Quintil de Riqueza"
      ) +
      theme_minimal() +
      theme(text = element_text(family = "Arial")) +  
      geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
      scale_x_continuous(breaks = seq(0, 60, by = 5)) +
      scale_color_manual(
        values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                   "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
        labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
      )
  
    output_file <- file.path(dirOutput, "Prevalencia de DCI por quintiles.png")
    ggsave(filename = output_file, plot = DCIq, width = 10, height = 6, dpi = 300, bg ="white")

  
# Resultados DIT ## ----
###Base DIT ### 
###Variables Regulación de emociones, Apego seguro, comunicación, Función simbólica, Camina solo###
#Desarrollo infantil --- Resultados DIT ---
    baseNinosDITENDES <- dit %>%
      left_join(rec21 %>% select("id1", "caseid", "bidx", "b4"), by = c("id1", "caseid", "bidx")) %>%
      left_join(rec0111 %>% select("id1", "caseid", "v001", "v005", "v012", "v022", "v024", "v025", "v149", "v190"), by = c("id1", "caseid")) %>% ##v190: indice de riqueza
      left_join(rec91 %>% select("id1", "caseid", "sregion", "s119", "s108n"), by = c("id1", "caseid")) %>%
      mutate(e3conv = case_when(qi478e3 == 1 ~ 1,
                                qi478e3 == 2 ~ 0,
                                TRUE ~ NA),
             e4conv = case_when(qi478e4 == 1 ~ 1,
                                qi478e4 == 2 ~ 0,
                                TRUE ~ NA),
             e5conv = case_when(qi478e5 == 1 ~ 1,
                                qi478e5 == 2 ~ 0,
                                TRUE ~ NA),
             e7conv = case_when(qi478e7 == 1 ~ 1,
                                qi478e7 == 2 ~ 0,
                                TRUE ~ NA),
             e8conv = case_when(qi478e8 == 1 ~ 1,
                                qi478e8 == 2 ~ 0,
                                TRUE ~ NA),
             e9conv = case_when(qi478e9 == 1 ~ 1,
                                qi478e9 == 2 ~ 0,
                                TRUE ~ NA),
             e10conv = case_when(qi478e10 == 1 | qi478e10 == 3 | qi478e10 == 4 ~ 1,
                                 qi478e10 == 2 | qi478e10 == 5 ~ 0,
                                 TRUE ~ NA),
             e345 = case_when(qi478a == 0 & (qi478 >= 9 & qi478 <= 12) ~ e3conv + e4conv + e5conv,
                              TRUE ~ NA),
             r2 = case_when(qi478a == 0 & (qi478 >= 9 & qi478 <= 12) ~ e7conv + e8conv + e9conv,
                            TRUE ~ NA),
             r4_9_12m = case_when(e345 < 3 ~ 0,
                                  e345 == 3 ~ 1,
                                  TRUE ~ NA),
             f3conv = case_when(qi478f3 == 1 ~ 1,
                                qi478f3 == 2 ~ 0,
                                TRUE ~ NA),
             f4conv = case_when(qi478f4 == 1 ~ 1,
                                qi478f4 == 2 ~ 0,
                                TRUE ~ NA),
             f5conv = case_when(qi478f5 == 1 ~ 1,
                                qi478f5 == 2 ~ 0,
                                TRUE ~ NA),
             f345 = case_when(qi478a == 0 & (qi478 >= 13 & qi478 <= 18) ~ f3conv + f4conv + f5conv,
                              TRUE ~ NA),
             r4_13_18m = case_when(f345 < 3 ~ 0,
                                   f345 == 3 ~ 1,
                                   TRUE ~ NA),
             g1conv = case_when(qi478g1 == 1 ~ 1,
                                qi478g1 == 2 ~ 0,
                                TRUE ~ NA),
             g2aconv = case_when(qi478g2_a == 1 ~ 1,
                                 qi478g2_a == 2 ~ 0,
                                 TRUE ~ NA),
             g2bconv = case_when(qi478g2_b == 1 ~ 1,
                                 qi478g2_b == 2 ~ 0,
                                 TRUE ~ NA),
             g2cconv = case_when(qi478g2_c == 1 ~ 1,
                                 qi478g2_c == 2 ~ 0,
                                 TRUE ~ NA),
             g3conv = case_when(qi478g3 == 1 ~ 1,
                                qi478g3 == 2 ~ 0,
                                TRUE ~ NA),
             g2abc = (g2aconv + g2bconv + g2cconv) / 3,
             g345 = case_when(qi478a == 0 & (qi478 >= 19 & qi478 <= 23) ~ g1conv + g2abc + g3conv,
                              TRUE ~ NA),
             r4_19_23m = case_when(g345 < 3 ~ 0,
                                   g345 == 3 ~ 1,
                                   TRUE ~ NA),
             h1conv = case_when(qi478h1 == 1 ~ 1,
                                qi478h1 == 2 ~ 0,
                                TRUE ~ NA),
             h2conv = case_when(qi478h2 == 1 ~ 1,
                                qi478h2 == 2 ~ 0,
                                TRUE ~ NA),
             h3conv = case_when(qi478h3 == 1 ~ 1,
                                qi478h3 == 2 ~ 0,
                                TRUE ~ NA),
             h345 = case_when(qi478a == 0 & (qi478 >= 24 & qi478 <= 36) ~ h1conv + h2conv + h3conv,
                              TRUE ~ NA),
             r4_24_36m = case_when(h345 < 3 ~ 0,
                                   h345 == 3 ~ 1,
                                   TRUE ~ NA),
             f2aconv = case_when(qi478f2_a == 1 ~ 1,
                                 qi478f2_a == 2 ~ 0,
                                 TRUE ~ NA),
             f2bconv = case_when(qi478f2_b == 1 ~ 1,
                                 qi478f2_b == 2 ~ 0,
                                 TRUE ~ NA),
             f2cconv = case_when(qi478f2_c == 1 ~ 1,
                                 qi478f2_c == 2 ~ 0,
                                 TRUE ~ NA),
             f2dconv = case_when(qi478f2_d == 1 ~ 1,
                                 qi478f2_d == 2 ~ 0,
                                 TRUE ~ NA),
             f2econv = case_when(qi478f2_e == 1 ~ 1,
                                 qi478f2_e == 2 ~ 0,
                                 TRUE ~ NA),
             e6f6conv = case_when(qi478e6 == 1 | qi478f6 == 1 ~ 1,
                                  qi478e6 == 2 & qi478f6 == 2 ~ 0,
                                  TRUE ~ NA),
             g4h4conv = case_when(qi478h4 == 1 | qi478g4 == 1 ~ 1,
                                  qi478h4 == 2 | qi478g4 == 2 ~ 0,
                                  TRUE ~ NA),
             f1camina_solo = case_when(qi478f1 == 5 | qi478f1 == 6 ~ 1,
                                       qi478f1 == 1 | qi478f1 == 2| qi478f1 == 3 | qi478f1 == 4 ~ 0,
                                       TRUE ~ NA),
             e1camina_solo = case_when(qi478e1 == 5 | qi478e1 == 6 ~ 1, #SE PONE DE PIE SIN AGARRARSE DE NADA y CAMINA SOLA /O CON SOLTURA
                                       qi478e1 == 1 | qi478e1 == 2| qi478e1 == 3 | qi478e1 == 4 ~ 0,
                                       TRUE ~ NA)) %>% 
      mutate(desInfCom = rowSums(select(., starts_with("r4_")), na.rm = TRUE),
             indEntorno2 = rowSums(select(., starts_with("f2")), na.rm = TRUE))
    
    ##Calculo de variables
    baseNinosDITENDES <- baseNinosDITENDES %>%
      mutate(desInfEmo = case_when(qi478a == 0 & (qi478 >= 24 & qi478 <= 36) ~ case_when(qi478h9 == 1 ~ 0,
                                                                                          qi478h9 == 2 ~ 1,
                                                                                          qi478h10 == 1 ~ 1,
                                                                                          qi478h10 == 2 ~ 0,
                                                                                          qi478h10 == 3 ~ 0,
                                                                                          qi478h11 == 1 ~ 0,
                                                                                          qi478h11 == 2 ~ 1,
                                                                                          TRUE ~ NA),
                                    qi478a == 0 & (qi478 >= 37 & qi478 <= 54) ~ case_when(qi478i5 == 1 ~ 0,
                                                                                          qi478i5 == 2 ~ 1,
                                                                                          qi478i6 == 1 ~ 1,
                                                                                          qi478i6 == 2 ~ 1,
                                                                                          qi478i6 == 3 ~ 0,
                                                                                          qi478i7 == 1 ~ 0,
                                                                                          qi478i7 == 2 ~ 1,
                                                                                          TRUE ~ NA),
                                    qi478a == 0 & (qi478 >= 55 & qi478 <= 71) ~ case_when(qi478j5 == 1 ~ 0,
                                                                                          qi478j5 == 2 ~ 1,
                                                                                          qi478j6 == 1 ~ 1,
                                                                                          qi478j6 == 2 ~ 0,
                                                                                          qi478j6 == 3 ~ 0,
                                                                                          qi478j7 == 1 ~ 0,
                                                                                          qi478j7 == 2 ~ 1,
                                                                                          TRUE ~ NA),
                                    TRUE ~ NA),
             r2conv = case_when(r2 == 0  ~ 0,## convetir a dummy variables categoricas de apego seguro
                                r2 == 1 | r2 == 2 | r2 == 3 ~ 1,
                                TRUE ~ NA),
             r5conv = case_when(r4_9_12m == 1 | r4_13_18m == 1 | r4_19_23m == 1 | r4_24_36m == 1 ~ 1,
                                r4_9_12m == 0 | r4_13_18m == 0 | r4_19_23m == 0 | r4_24_36m == 0 ~ 0,
                                TRUE ~ NA),
             h5conv = case_when(qi478h5 == 1 ~ 1,
                                qi478h5 == 2 ~ 0,
                                TRUE ~ NA),
             h6conv = case_when(qi478h6 == 1 ~ 1,
                                qi478h6 == 2 ~ 0,
                                TRUE ~ NA),
             h7conv = case_when(qi478h7 == 1 ~ 1,
                                qi478h7 == 2 ~ 0,
                                TRUE ~ NA),
             h567 = case_when(qi478a == 0 & (qi478 >= 24 & qi478 <= 36) ~ h5conv + h6conv + h7conv,
                              TRUE ~ NA),
             desInfJue = case_when(h567 %in% 0:2 ~ 0,
                                   h567 == 3 ~ 1,
                                   TRUE ~ NA),
             i1conv = case_when(qi478i1 == 1 | qi478i1 == 2 | qi478i1 == 3 | qi478i1 == 4  ~ 0, ##Dibujo a detalles
                                qi478i1 == 5 ~ 1,
                                TRUE ~ NA),
             r7conv = case_when(desInfJue == 1 | i1conv == 1 ~ 1,
                                desInfJue == 0 | i1conv == 0 ~ 0,
                                TRUE ~ NA),
             r4conv = case_when(e1camina_solo == 1 | f1camina_solo == 1 ~ 1,
                                e1camina_solo == 0 | f1camina_solo == 0 ~ 0,
                                TRUE ~ NA),
             pesoP = v005/1000000)  %>%
      group_by(qi478,v190) %>%
      summarize(porcentaje_emociones = weighted.mean(desInfEmo, w = pesoP, na.rm = TRUE) * 100, #porcentaje para prevalencia anemia
                porcentaje_apego = weighted.mean(r2conv, w = pesoP, na.rm = TRUE) * 100, #porcentaje prevalencia DCI
                porcentaje_com = weighted.mean(r5conv, w = pesoP, na.rm = TRUE) * 100,
                porcentaje_fun= weighted.mean(r7conv, w = pesoP, na.rm = TRUE) * 100,
                porcentaje_cam= weighted.mean(r4conv, w = pesoP, na.rm = TRUE) * 100,
                n = n(),
                n_apego = sum(!is.na(r2conv) & qi478a == 0 & (qi478 >= 9 & qi478 <= 12)),
                n_COM = sum(!is.na(r5conv) & qi478a == 0 & (qi478 >= 9 & qi478 <= 36)),
                n_FUN = sum(!is.na(r7conv) & qi478a == 0 & (qi478 >= 24 & qi478 <= 55)),
                n_CAM = sum(!is.na(r4conv) & qi478a == 0 & (qi478 >= 9 & qi478 <= 18)),
                seEMO = sqrt(weighted.mean(desInfEmo, w = pesoP, na.rm = TRUE) * 
                            (1 - weighted.mean(desInfEmo, w = pesoP, na.rm = TRUE)) / n()) * 100,
                seAPE = sqrt(weighted.mean(r2conv, w = pesoP, na.rm = TRUE) * 
                               (1 - weighted.mean(r2conv, w = pesoP, na.rm = TRUE)) / n()) * 100,
                seCOM = sqrt(weighted.mean(r5conv, w = pesoP, na.rm = TRUE) * 
                               (1 - weighted.mean(r5conv, w = pesoP, na.rm = TRUE)) / n()) * 100,
                seFUN = sqrt(weighted.mean(r7conv, w = pesoP, na.rm = TRUE) * 
                               (1 - weighted.mean(r7conv, w = pesoP, na.rm = TRUE)) / n()) * 100,
                seCAM = sqrt(weighted.mean(r4conv, w = pesoP, na.rm = TRUE) * 
                               (1 - weighted.mean(r4conv, w = pesoP, na.rm = TRUE)) / n()) * 100,
                .groups = 'drop') %>%
      mutate(lowerEMO = porcentaje_emociones - 1.96 * seEMO,
             upperEMO = porcentaje_emociones + 1.96 * seEMO,
             lowerAPE = porcentaje_apego - 1.96 * seAPE,
             upperAPE = porcentaje_apego + 1.96 * seAPE,
             lowerCOM = porcentaje_com  - 1.96 * seCOM,
             upperCOM = porcentaje_com + 1.96 * seCOM,
             lowerFUN = porcentaje_fun  - 1.96 * seFUN,
             upperFUN = porcentaje_fun + 1.96 * seFUN,
             lowerCAM = porcentaje_cam  - 1.96 * seCAM,
             upperCAM = porcentaje_cam + 1.96 * seCAM) %>%
      ungroup()
    
        

# Replica de graficos
####Regulación de emociones###
      reg_emociones <- ggplot(data = baseNinosDITENDES, aes(x = qi478, y = porcentaje_emociones))+ 
        geom_point(size = 1, color = "black") +
        geom_smooth(method = "loess", se = FALSE, color = "red", size = 1) +  # Línea suavizada
        geom_errorbar(aes(ymin = lowerEMO, ymax = upperEMO ), width = 0.2, color = "black") +
        labs(
          title = "Regulación de emociones según edad. Perú 2019-2023",
          x = "Edad en meses",
          y = "95% CI Regulación de emociones"
        ) +
        theme_minimal() +
        geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
      scale_x_continuous(breaks = seq(5, 60, by = 5))   
      
      output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Regulación de emociones.png")
      ggsave(filename = output_file, plot = reg_emociones, width = 10, height = 6, dpi = 300)
      
  
  ####Regulación de emociones por quintiles###
      
      base_NinosDITEndesf <- baseNinosDITENDES %>% filter(v190 %in% c(1, 5))
      emoq <- ggplot(data = base_NinosDITEndesf, aes(x = qi478, y = porcentaje_emociones, color = as.factor(v190))) + 
        geom_point(size = 1, aes(color = as.factor(v190)), show.legend = FALSE) +
        geom_smooth(aes(group = v190), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
        geom_errorbar(aes(ymin =lowerEMO, ymax = upperEMO), width = 0.2) + 
        labs(
          title = "Regulación de emociones, según edad y quintil de riqueza. Perú 2019-2023",
          x = "Edad en meses",
          y = "95% CI Regulación de emociones",
          color = "Quintil de Riqueza"
        ) +
        theme_minimal() +
        theme(text = element_text(family = "Arial")) +  
        geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60,66), linetype = "dashed", color = "red") +  # Líneas verticales
        scale_x_continuous(breaks = seq(24, 71, by = 6), limits = c(24, 71)) +
        scale_color_manual(
          values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                     "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
          labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
        )
      output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Regulación de emociones por quintiles.png")
      ggsave(filename = output_file, plot = emoq, width = 10, height = 6, dpi = 300,bg ="white")
      

### Apego seguro según quintiles ### 
        apegoq <- ggplot(data = base_NinosDITEndesf, aes(x = qi478, y = porcentaje_apego, color = as.factor(v190))) + 
          geom_point(size = 1, show.legend = FALSE) +
          geom_smooth(aes(group = v190), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
          geom_errorbar(aes(ymin = lowerAPE, ymax = upperAPE), width = 0.2) + 
          labs(
            title = "Apego seguro, según edad y quintil de riqueza. Perú 2019-2023",
            x = "Edad en meses",
            y = "95% CI Apego seguro",
            color = "Quintil de Riqueza"
          ) +
          theme_minimal() +
          theme(text = element_text(family = "Arial")) +  
          geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66), linetype = "dashed", color = "red") +  # Líneas verticales
          scale_x_continuous(breaks = seq(9, 12, by = 1)) +  # Ajustar los intervalos de los ticks en el eje x
          coord_cartesian(xlim = c(9, 12)) +  # Ajustar el límite del eje x
          scale_color_manual(
            values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                       "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
            labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
          )
        output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Apego seguro por quintiles.png")
        ggsave(filename = output_file, plot = apegoq, width = 10, height = 6, dpi = 300, bg ="white")

### Comunicación verbal efectiva, por quintiles ### 
        base_NinosDITEndesf <- baseNinosDITENDES %>% filter(v190 %in% c(1, 5))
        comq <- ggplot(data = base_NinosDITEndesf, aes(x = qi478, y = porcentaje_com, color = as.factor(v190))) + 
          geom_point(size = 1, aes(color = as.factor(v190)), show.legend = FALSE) +
          geom_smooth(aes(group = v190), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
          geom_errorbar(aes(ymin =lowerCOM, ymax = upperCOM), width = 0.2) + 
          labs(
            title = "Porcentaje de niñas y niños de 9 a 36 meses de edad con comunicación verbal efectiva a nivel comprensivo y expresivo apropiado para su edad. Perú 2019-2023",
            x = "Edad en meses",
            y = "95% CI Comunicación verbal efectiva",
            color = "Quintil de Riqueza"
          ) +
          theme_minimal() +
          theme(text = element_text(family = "Arial")) +  
          geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60,66), linetype = "dashed", color = "red") +  # Líneas verticales
          scale_x_continuous(breaks = seq(9, 36, by = 3), limits = c(9, 36)) +
          scale_color_manual(
            values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                       "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
            labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
          )
        output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Comunicación verbal efectiva por quintiles.png")
        ggsave(filename = output_file, plot =  comq, width = 10, height = 6, dpi = 300,bg ="white")
        
      
### Función simbólica por quintiles ### 
        funq <- ggplot(data = base_NinosDITEndesf, aes(x = qi478, y = porcentaje_fun, color = as.factor(v190))) + 
          geom_point(size = 1, aes(color = as.factor(v190)), show.legend = FALSE) +
          geom_smooth(aes(group = v190), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
          geom_errorbar(aes(ymin =lowerFUN, ymax = upperFUN), width = 0.2) + 
          labs(
            title = "Porcentaje de niñas y niños de 24 a 55 meses de edad que representan sus vivencias a través del juego y el dibujo. Perú 2019-2023",
            x = "Edad en meses",
            y = "95% CI Función simbólica",
            color = "Quintil de Riqueza"
          ) +
          theme_minimal() +
          theme(text = element_text(family = "Arial")) +  
          geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
          scale_x_continuous(breaks = seq(24, 55, by = 5), limits = c(24, 55)) +
          scale_color_manual(
            values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                       "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
            labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
          )
        output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Función simbólica por quintiles.png")
        ggsave(filename = output_file, plot =  funq, width = 10, height = 6, dpi = 300,bg ="white")
      

### Marcha estable y autonoma por quintiles ### 
        
        CAMq <- ggplot(data = base_NinosDITEndesf, aes(x = qi478, y = porcentaje_cam, color = as.factor(v190))) + 
          geom_point(size = 1, aes(color = as.factor(v190)), show.legend = FALSE) +
          geom_smooth(aes(group = v190), method = "loess", se = FALSE, size = 1) +  # Línea suavizada para cada quintil
          geom_errorbar(aes(ymin =lowerCAM, ymax = upperCAM), width = 0.2) + 
          labs(
            title = "Porcentaje de niños que caminan por iniciativa propia sin necesidad de detenerse para lograr el equilibrio.Perú 2019-2023",
            x = "Edad en meses",
            y = "95% CI Camina Solo",
            color = "Quintil de Riqueza"
          ) +
          theme_minimal() +
          theme(text = element_text(family = "Arial")) +  
          geom_vline(xintercept = c(6, 12, 18, 24, 30, 36, 42, 48, 54, 60), linetype = "dashed", color = "red") +  # Líneas verticales
          scale_x_continuous(breaks = seq(9, 18, by = 3), limits = c(9, 18)) +
          scale_color_manual(
            values = c("5" = rgb(17, 99, 97, maxColorValue = 255),  # Verde videnza
                       "1" = rgb(200, 70, 60, maxColorValue = 255)), # Rojo videnza
            labels = c("1" = "Quintil Inferior", "5" = "Quintil Superior")
          )
        output_file <- file.path("C:/Users/Jennifer Prado/Documents/GitHub/PDB-DIT/Output", "Camina solo por quintiles.png")
        ggsave(filename = output_file, plot =  CAMq, width = 10, height = 6, dpi = 300,bg ="white")
        