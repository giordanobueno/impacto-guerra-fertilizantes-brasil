# ==============================================================================#
# UNIVERSIDADE FEDERAL DE PELOTAS (UFPel)                                       #
# Departamento de Economia — PPGOM                                              #
# Disciplina: Econometria I - 2025/01                                           #
# Docente responsável: Prof. André Carraro                                      #
# Monitoria: Wandson Rafael dos Santos                                          #
# Aluno: Giordano Bueno Freitas de Souza                                        #
#                                                                               #
# Projeto: O Impacto da Guerra Russo-Ucraniana na Importação de Fertilizantes   #
#          no Brasil (2004–2024)                                                #
# ==============================================================================#

# Configuração dinâmica do diretório de trabalho (se necessário)
# Permite execução tanto a partir da raiz do repositório quanto da pasta 'scripts/'
if (dir.exists("scripts")) {
  # Executando a partir da raiz do repositório
} else if (file.exists("analise_fertilizantes.R") && file.exists("../data/importacao_npk_russia_2004_2024.csv")) {
  setwd("..")
}

# ------------------------------------------------------------------------------
# 1. Carregamento de Pacotes
# ------------------------------------------------------------------------------
library("readxl")
library("ggplot2")
library("tidyverse")
library("dplyr")
library("summarytools")
library("ipeadatar")
library("rbcb")
library("car")
library("stargazer")
library("strucchange")
library("tidyquant")
library("corrplot")
library("sandwich")
library("lmtest")
library("descr")

# ------------------------------------------------------------------------------
# 2. Importação e Preparação da Base de Dados da COMEXstat
# ------------------------------------------------------------------------------
# Fertilizantes NPK Importados da Rússia (Valor US$ CIF e Quilograma Líquido)
# Fonte primária: COMEXstat / MDIC (https://comexstat.mdic.gov.br/)

data_file <- if (file.exists("data/importacao_npk_russia_2004_2024.csv")) {
  "data/importacao_npk_russia_2004_2024.csv"
} else if (file.exists("data/Importação NPK Rússia (2004 - 2024) Valor CIF.csv")) {
  "data/Importação NPK Rússia (2004 - 2024) Valor CIF.csv"
} else if (file.exists("../data/importacao_npk_russia_2004_2024.csv")) {
  "../data/importacao_npk_russia_2004_2024.csv"
} else {
  "Importação NPK Rússia (2004 - 2024) Valor CIF.csv"
}

df <- read.csv(data_file, sep = ";")
head(df, 10)
dim(df)
colnames(df)

# Tratamento dos dados importados
df$Código.NCM <- NULL
df$Descrição.NCM <- NULL
df$Países <- NULL
df <- mutate(df, toneladas = Quilograma.Líquido / 1000)
df$Quilograma.Líquido <- NULL
colnames(df)[2] <- "valor"

df$preco <- (df$valor / df$toneladas)

# ------------------------------------------------------------------------------
# 3. Coleta e Tratamento da Taxa de Câmbio (USD/BRL) via API do Banco Central
# ------------------------------------------------------------------------------
# Série SGS 3695: Taxa de câmbio - Livre - Dólar americano (venda) - média de período
cambio <- get_series(3695, start_date = "2004-01-01", end_date = "2024-12-31")
colnames(cambio)[2] <- "cambio"

# Cálculo da média anual do Câmbio
cambio <- cambio %>%
  mutate(Ano = format(date, "%Y")) %>%
  group_by(Ano) %>%
  summarise(cambio_medio = mean(cambio, na.rm = TRUE)) %>%
  mutate(Ano = as.numeric(Ano))

# Unindo ao DataFrame principal
df <- df %>%
  left_join(cambio, by = "Ano")

# Conversão dos valores para Moeda Nacional (BRL)
df$valorBRL <- df$valor * df$cambio_medio
df$precoBRL <- (df$valorBRL / df$toneladas)

# Dummy para o início do conflito Rússia x Ucrânia (a partir de 2022)
df$dummy_guerra <- ifelse(df$Ano >= 2022, 1, 0)

# ------------------------------------------------------------------------------
# 4. Coleta de Preços de Commodities Agrícolas via Yahoo Finance (tidyquant)
# ------------------------------------------------------------------------------
# Soja, milho, açúcar e café: principais culturas consumidoras de NPK no Brasil

get_media_anual <- function(ticker, var_name) {
  tq_get(ticker, get = "stock.prices", from = "2004-01-01", to = "2024-12-31") %>%
    mutate(Ano = format(date, "%Y")) %>%
    group_by(Ano) %>%
    summarise(media = mean(close, na.rm = TRUE)) %>%
    mutate(Ano = as.numeric(Ano)) %>%
    rename(!!var_name := media)
}

# Coleta dos preços anuais médios dos contratos futuros
soja   <- get_media_anual("ZS=F", "soja")
milho  <- get_media_anual("ZC=F", "milho")
acucar <- get_media_anual("SB=F", "acucar")
cafe   <- get_media_anual("KC=F", "cafe")

# Consolidação no painel temporal
df <- df %>%
  left_join(soja, by = "Ano") %>%
  left_join(milho, by = "Ano") %>%
  left_join(acucar, by = "Ano") %>%
  left_join(cafe, by = "Ano")

# Criação do índice sintético médio das commodities analisadas
df$commodity <- ((df$cafe + df$acucar + df$milho + df$soja) / 4)

# ------------------------------------------------------------------------------
# 5. Estatísticas Descritivas e Correlações
# ------------------------------------------------------------------------------
head(df, 21)
summary(df)
glimpse(df)

desc <- descr(df[, c(
  "valor", "toneladas", "preco", "cambio_medio",
  "soja", "acucar", "cafe", "milho", "commodity"
)])

corr <- cor(df)
corrplot(corr,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  tl.col = "darkblue",
  tl.srt = 45,
  diag = FALSE
)

# ------------------------------------------------------------------------------
# 6. Visualizações Gráficas (ggplot2)
# ------------------------------------------------------------------------------

# 6.1. Série temporal do valor das importações de fertilizantes (US$ FOB)
ggplot(df, aes(x = Ano, y = valor)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Importações de Fertilizantes NPK da Rússia (2004–2024) de USD",
    x = "Ano",
    y = "Valor importado (US$ FOB)"
  ) +
  theme_minimal()

# 6.2. Evolução da taxa de câmbio USD/BRL
ggplot(df, aes(x = Ano, y = cambio_medio)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Evolução do câmbio USD/BRL no período (2004 - 2024)",
    x = "Ano",
    y = "Taxa Cambial"
  ) +
  theme_minimal()

# 6.3. Preço médio dos fertilizantes em BRL
ggplot(df, aes(x = Ano, y = precoBRL)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Preço Médio dos Fertilizantes Importados em BRL",
    x = "Ano",
    y = "Valor importado (BRL FOB)"
  ) +
  theme_minimal()

# 6.4. Série de toneladas importadas de fertilizantes NPK
ggplot(df, aes(x = Ano, y = toneladas)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Importações de Fertilizantes NPK da Rússia (2004–2024)",
    x = "Ano",
    y = "Toneladas Importadas"
  ) +
  theme_minimal()

# 6.5. Preço médio unitário dos fertilizantes (USD/tonelada)
ggplot(df, aes(x = Ano, y = preco)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Preço Médio dos Fertilizantes Importados (USD)",
    x = "Ano",
    y = "Preço Médio"
  ) +
  theme_minimal()

# 6.6. Séries individuais de preços de commodities agrícolas
ggplot(df, aes(x = Ano, y = soja)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(title = "Preço médio da Soja", x = "Ano", y = "Preço") +
  theme_minimal()

ggplot(df, aes(x = Ano, y = acucar)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(title = "Preço médio do Açúcar", x = "Ano", y = "Preço") +
  theme_minimal()

ggplot(df, aes(x = Ano, y = milho)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(title = "Preço médio do Milho", x = "Ano", y = "Preço") +
  theme_minimal()

ggplot(df, aes(x = Ano, y = cafe)) +
  geom_line(color = "blue", linewidth = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(title = "Preço médio do Café", x = "Ano", y = "Preço") +
  theme_minimal()

ggplot(df, aes(x = Ano, y = commodity)) +
  geom_line(color = "blue", linewidth = 1.2) +
  geom_point(color = "black", size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 1)) +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(title = "Preço médio das Commodities analisadas", x = "Ano", y = "Preço") +
  theme_minimal()

# 6.7. Comparativo conjunto de preços de commodities agrícolas
df_long <- df %>%
  select(Ano, soja, milho, cafe, acucar, commodity) %>%
  pivot_longer(cols = -Ano, names_to = "Variavel", values_to = "Preco")

ggplot(df_long, aes(x = Ano, y = Preco, color = Variavel)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(min(df$Ano), max(df$Ano), by = 2)) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "red") +
  labs(
    title = "Evolução dos preços das commodities",
    x = "Ano",
    y = "Preço",
    color = "Variável"
  ) +
  theme_minimal()

# ------------------------------------------------------------------------------
# 7. Modelo Econométrico e Diagnósticos de Robustez
# ------------------------------------------------------------------------------

# 7.1. Estimação do Modelo Log-Log com Defasagem Temporal (AR(1))
# ln(Toneladas) = β0 + β1*ln(Commodity) + β2*DummyGuerra + β3*ln(CambioMedio) + β4*ln(Toneladas)t-1 + ε
reg <- lm(
  log(toneladas) ~
    log(commodity) +
    dummy_guerra +
    log(cambio_medio) +
    lag(log(toneladas), 1),
  data = df
)

summary(reg)

# 7.2. Diagnóstico de Multicolinearidade: Variance Inflation Factor (VIF)
vif(reg)

# 7.3. Teste de Heterocedasticidade: Breusch-Pagan
lmtest::bptest(reg)

# 7.4. Teste de Autocorrelação Residual: Durbin-Watson
car::durbinWatsonTest(reg)

# 7.5. Exportação da Tabela de Resultados (Stargazer)
stargazer(reg,
  type = "html",
  title = "Resultados da Regressão",
  digits = 3,
  dep.var.labels = "log(toneladas)",
  covariate.labels = c(
    "log(commodity)",
    "Dummy Guerra",
    "log(Cambio Medio)",
    "Lag log(toneladas)"
  ),
  out = "regressao_log_toneladas.html"
)

# 7.6. Teste de Estabilidade dos Coeficientes: CUSUM Recursivo
cusum_reg <- efp(
  log(toneladas) ~
    log(commodity) +
    dummy_guerra +
    log(cambio_medio) +
    lag(log(toneladas), 1),
  data = df,
  type = "Rec-CUSUM"
)

plot(cusum_reg,
  main = "CUSUM Recursivo - Estabilidade do Modelo",
  ylab = "Processo de Flutuação Empírica"
)

# 7.7. Teste de Quebra Estrutural de Chow (Ano de 2022)
chow <- lm(
  log(toneladas) ~
    log(commodity) +
    dummy_guerra +
    log(cambio_medio) +
    lag(log(toneladas), 1),
  data = df
)

# Identificação do ponto de quebra correspondente ao início do conflito em 2022
breakpoint_2022 <- which(df$Ano == 2022)

chow_result <- sctest(chow,
  type = "Chow",
  point = breakpoint_2022,
  data = df
)

print(chow_result)
