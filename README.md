# O Impacto da Guerra Russo-Ucraniana na Importação de Fertilizantes no Brasil (2004–2024)

> **Trabalho Aplicado de Econometria I**  
> **Departamento de Economia — Programa de Pós-Graduação em Organizações e Mercados (PPGOM)**  
> **Universidade Federal de Pelotas (UFPel)**  
> **Docente:** Prof. André Carraro  
> **Autor:** Giordano Bueno Freitas de Souza  

---

## 📄 Acesso ao Trabalho

[📄 Clique aqui para acessar o Relatório Completo em PDF](./relatorio_econometria.pdf)

---

## 📌 Resumo do Trabalho

Este estudo tem como objetivo investigar empiricamente os efeitos da eclosão da Guerra Russo-Ucraniana (fevereiro de 2022) sobre o fluxo de importações brasileiras de fertilizantes NPK (NCM 3105.20.00) originários da Rússia no período compreendido entre 2004 e 2024. Por meio de um modelo de **regressão linear múltipla em escala log-log com defasagem temporal ($AR(1)$)**, busca-se estimar as elasticidades da demanda derivada de fertilizantes e avaliar formalmente se o conflito geopolítico e as sanções internacionais decorrentes provocaram uma quebra estrutural ou redução estatisticamente significativa no volume importado (em toneladas) pelo Brasil.

---

## 📐 Metodologia & Especificação Econométrica

A especificação log-log permite interpretar diretamente os coeficientes angulares como elasticidades. O modelo econométrico estimado é dado por:

$$\ln(\text{Toneladas}_t) = \beta_0 + \beta_1 \ln(\text{Commodity}_t) + \beta_2 \text{DummyGuerra}_t + \beta_3 \ln(\text{CambioMedio}_t) + \beta_4 \ln(\text{Toneladas}_{t-1}) + \varepsilon_t$$

Onde:
- $\ln(\text{Toneladas}_t)$: Volume de fertilizantes NPK importados da Rússia (em toneladas), extraído do portal **COMEXstat / MDIC**;
- $\ln(\text{Commodity}_t)$: Índice médio de preços internacionais das principais commodities agrícolas consumidoras de NPK no Brasil (soja, milho, café e açúcar), coletados via Yahoo Finance (**tidyquant**);
- $\text{DummyGuerra}_t$: Variável binária de intervenção que assume valor 1 a partir de 2022 (início do conflito) e 0 para os anos anteriores;
- $\ln(\text{CambioMedio}_t)$: Taxa de câmbio média anual USD/BRL, obtida via API do **Banco Central do Brasil (SGS)**;
- $\ln(\text{Toneladas}_{t-1})$: Termo autorregressivo de defasagem de um período ($AR(1)$), controlando custos de ajustamento, contratos prévios e inércia do comércio exterior;
- $\varepsilon_t$: Termo de erro estocástico.

### Testes de Diagnóstico e Robustez

Para validação dos pressupostos clássicos do Modelo Linear Clássico e garantia da robustez das inferências:
1. **Multicolinearidade**: Fator de Inflação da Variância (**VIF**), com todos os valores entre 1,70 e 3,48 (ausência de multicolinearidade severa);
2. **Heterocedasticidade**: Teste de **Breusch-Pagan** ($BP = 3,2794; p = 0,5122$), indicando homocedasticidade residual;
3. **Autocorrelação Residual**: Teste de **Durbin-Watson** ($DW = 2,4178; p = 0,8920$), confirmando ausência de autocorrelação de primeira ordem após inclusão do termo defasado;
4. **Estabilidade e Quebra Estrutural**:
   - Flutuação empírica via **CUSUM Recursivo**, sem violação das faixas de confiança;
   - **Teste de Chow** com ponto de quebra em 2022 ($F = 0,9464; p = 0,8669$), refutando quebra estrutural na relação comercial.

---

## 📊 Principais Achados

- **Demanda Elástica às Commodities Agrícolas:** O coeficiente de ln(commodity) foi positivo e estatisticamente significante a 5% (β̂₁ = 1,645; p = 0,025), em linha com a teoria da demanda derivada. Um aumento de 1% nos preços das commodities agrícolas está associado a um incremento de aproximadamente 1,65% nas importações brasileiras de NPK russo.
- **Persistência Temporal (Inércia):** A defasagem das importações apresentou alta significância estatística a 1% (β̂₄ = 0,782; p = 0,002), indicando forte persistência explicada por custos de ajustamento, contratos de longo prazo e estoques de suprimentos.
- **Impacto da Guerra Não Significante:** O coeficiente da variável dummy de intervenção não apresentou significância estatística (β̂₂ = -0,396; p = 0,496), indicando que o conflito não gerou redução estatisticamente significativa ou impacto estrutural sobre o volume importado no curto prazo.
- **Fatores Explicativos:** A estabilidade observada ampara-se na rápida adaptação do mercado, na continuidade de contratos preexistentes, nas exceções comerciais concedidas pela União Europeia aos fertilizantes e na postura pragmática/neutra do Brasil frente ao conflito.

---

## 💻 Tecnologias & Pacotes Utilizados

O projeto foi integralmente desenvolvido na linguagem **R** (versão $\ge 4.0$):

- **Manipulação e Visualização de Dados**: `tidyverse`, `dplyr`, `ggplot2`, `scales`
- **Coleta Automatizada de Dados**: `rbcb` (API do Banco Central do Brasil), `tidyquant` (Yahoo Finance API), `readxl`
- **Modelagem Econométrica & Testes de Diagnóstico**: `car`, `lmtest`, `sandwich`, `strucchange`
- **Estatísticas Descritivas & Apresentação**: `summarytools`, `descr`, `corrplot`, `stargazer`

---

## 📁 Estrutura do Repositório

```text
├── data/
│   ├── importacao_npk_russia_2004_2024.csv    # Base de dados original COMEXstat (MDIC)
│   └── Importação NPK Rússia (2004 - 2024)... # Cópia original com nomenclatura de consulta
├── doc/                                       # (Opcional) Documentação complementar
├── scripts/
│   └── analise_fertilizantes.R                # Script R completo e reprodutível
├── .gitignore                                 # Padrão para projetos em R
├── README.md                                  # Descrição detalhada do projeto
└── relatorio_econometria.pdf                  # Relatório acadêmico completo em formato PDF
```

---

## 🚀 Como Reproduzir a Análise

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/giordanobueno/impacto-guerra-fertilizantes-brasil.git
   cd impacto-guerra-fertilizantes-brasil
   ```

2. **Abra o R ou RStudio** e instale os pacotes requeridos caso ainda não os possua:
   ```r
   install.packages(c(
     "tidyverse", "ggplot2", "rbcb", "tidyquant",
     "car", "lmtest", "strucchange", "sandwich",
     "corrplot", "summarytools", "descr", "stargazer"
   ))
   ```

3. **Execute o script:**
   ```r
   source("scripts/analise_fertilizantes.R")
   ```

---

## 👤 Autor

**Giordano Bueno Freitas de Souza**  
Graduando em Ciências Econômicas — Universidade Federal de Pelotas (UFPel)  
- GitHub: [@giordanobueno](https://github.com/giordanobueno)
