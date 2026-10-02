# O Impacto da Guerra Russo-Ucraniana na Importação de Fertilizantes no Brasil

Trabalho aplicado da disciplina de Econometria I, Universidade Federal de Pelotas (UFPel).

- **Autor:** Giordano Bueno Freitas de Souza
- **Docente:** Prof. André Carraro

📄 [Acesse o relatório completo em PDF](./relatorio_econometria.pdf)

---

## Sobre o trabalho

O estudo analisa se a Guerra Rússia–Ucrânia, iniciada em fevereiro de 2022, teve efeito estatisticamente significativo sobre as importações brasileiras de fertilizantes NPK (NCM 3105.20.00) originários da Rússia, entre 2004 e 2024.

## Metodologia

- Regressão linear múltipla em escala log-log, com um termo defasado da variável dependente.
- Variável dependente: toneladas importadas (COMEXStat/MDIC).
- Variáveis explicativas: preço médio de commodities agrícolas (soja, milho, café e açúcar), câmbio médio anual USD/BRL, uma dummy para o período da guerra (a partir de 2022) e as importações do período anterior.
- Testes de diagnóstico: VIF, Breusch-Pagan, Durbin-Watson, CUSUM e Teste de Chow.

## Principais resultados

- Os preços das commodities agrícolas tiveram efeito positivo e significativo sobre as importações.
- As importações do período anterior foram altamente significativas, indicando persistência no comércio.
- A dummy da guerra e o câmbio não foram estatisticamente significativos.
- Os testes de diagnóstico não indicaram problemas, e não houve evidência de quebra estrutural.

Conclusão: no período analisado, não foi encontrado impacto estatisticamente significativo da guerra sobre o volume importado. O estudo aponta como limitação o tamanho reduzido da série temporal.

## Ferramentas

Análise desenvolvida em **R**, com coleta de dados via COMEXStat (MDIC), API do Banco Central do Brasil (SGS) e Yahoo Finance (pacote `tidyquant`).
