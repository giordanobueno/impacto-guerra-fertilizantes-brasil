# O Impacto da Guerra Russo-Ucraniana na Importação de Fertilizantes no Brasil (2004–2024)

> **Trabalho Aplicado de Econometria I**  
> **Departamento de Economia — Programa de Pós-Graduação em Organizações e Mercados (PPGOM)**  
> **Universidade Federal de Pelotas (UFPel)**  
> **Docente:** Prof. André Carraro | **Monitoria:** Wandson Rafael dos Santos  
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

- **Demanda Elástica às Commodities Agrícolas**: O coeficiente de $\ln(\text{Commodity})$ foi positivo e estatisticamente significante a 5% ($\hat{\beta}_1 = 1,645; p = 0,025$), confirmando que a demanda por fertilizantes NPK no Brasil é fortemente elástica em relação aos preços internacionais das commodities (demanda derivada). Um aumento de 1% nos preços das commodities agrícolas correlaciona-se com elevação de aproximadamente 1,65% nas importações de NPK russo;
- **Persistência Temporal (Inércia)**: A defasagem temporal foi altamente significante a 1% ($\hat{\beta}_4 = 0,782; p = 0,002$), refletindo contratos de fornecimento prévios, planejamento de safra e dependência estrutural do setor;
- **Dummy de Guerra Não Significante**: O coeficiente da variável de intervenção não apresentou significância estatística ($\hat{\beta}_2 = -0,396; p = 0,496$), demonstrando que, no curto e médio prazo, não houve retração estrutural das importações russas de NPK;
- **Conclusão Econômica**: Os resultados empíricos evidenciam a continuidade do fornecimento e a célere adaptação comercial e logística entre importadores brasileiros e fornecedores russos, além do pragmatismo diplomático brasileiro e das exceções internacionais concedidas ao comércio global de fertilizantes.

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
