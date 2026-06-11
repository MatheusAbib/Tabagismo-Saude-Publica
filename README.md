# 🚭 Desfumo

> **O lugar onde o fumo deixa de existir**

![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-4.x-000000?logo=express&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?logo=javascript&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![DigitalOcean](https://img.shields.io/badge/DigitalOcean-VPS-0080FF?logo=digitalocean&logoColor=white)

---

# 📋 Sobre o Projeto

O **Desfumo** é uma plataforma web desenvolvida para auxiliar pessoas que desejam parar de fumar, oferecendo acompanhamento estruturado, suporte profissional e recursos educacionais.

A plataforma conecta **usuários**, **enfermeiras** e **Unidades de Pronto Atendimento (UPAs)** em um ambiente digital que facilita o monitoramento da evolução dos pacientes durante programas de cessação do tabagismo.

Além do acompanhamento clínico, o sistema oferece ferramentas para registro diário de sintomas, definição de metas, controle de frequência em grupos de apoio, relatórios gerenciais e indicadores estatísticos.

---

# 🎯 Objetivo

Promover o combate ao tabagismo através de uma solução digital capaz de:

* ✅ Facilitar o acompanhamento dos pacientes
* ✅ Auxiliar profissionais de saúde no monitoramento
* ✅ Centralizar informações e históricos
* ✅ Disponibilizar materiais educativos
* ✅ Gerar relatórios e indicadores de desempenho
* ✅ Incentivar a permanência do paciente no tratamento

### 🌎 Alinhamento com os Objetivos de Desenvolvimento Sustentável

Este projeto está alinhado ao **ODS 3 – Saúde e Bem-Estar**, contribuindo para a promoção da saúde e para a redução dos impactos causados pelo tabagismo por meio do uso da tecnologia.
---

# 👥 Perfis de Usuário

## 👤 Usuário Comum (Paciente)

O usuário é a pessoa que deseja abandonar o tabagismo.

### Funcionalidades

* Cadastro completo
* Login e recuperação de acesso
* Teste de Fagerström
* Matrícula em turmas de apoio
* Lista de espera automática
* Registro diário de sintomas
* Definição de metas personalizadas
* Acompanhamento da evolução através de gráficos
* Biblioteca de materiais educativos
* Visualização do cronograma de aulas
* Gerenciamento de matrículas
* Recebimento de notificações

---

## 👩‍⚕️ Enfermeira

Profissional responsável pelo acompanhamento dos pacientes vinculados à sua UPA.

### Funcionalidades

* Dashboard da unidade
* Visualização dos pacientes cadastrados
* Controle de frequência das turmas
* Registro de observações semanais
* Gestão de cronogramas
* Encerramento de turmas
* Emissão de relatórios
* Acompanhamento da evolução dos pacientes

---

## 👨‍💼 Administrador

Responsável pela gestão global da plataforma.

### Funcionalidades

* Dashboard geral do sistema
* Gestão de usuários
* Gestão de enfermeiras
* Gestão de UPAs
* Gestão de turmas
* Controle de matrículas
* Relatórios administrativos
* Estatísticas gerais da plataforma

---

# 🔐 Credenciais para Demonstração

## Administrador

| Campo  | Valor                                     |
| ------ | ----------------------------------------- |
| E-mail | [admin@admin.com](mailto:admin@admin.com) |
| Senha  | Admin123#                                 |

## Enfermeira

| Campo  | Valor                                               |
| ------ | --------------------------------------------------- |
| E-mail | [teste@enfermeira.com](mailto:teste@enfermeira.com) |
| Senha  | Admin123#                                           |

> ℹ️ Para testar o fluxo de paciente, basta realizar um novo cadastro pela tela inicial.

---

# 🛠️ Principais Funcionalidades

## Teste de Fagerström

Avalia o nível de dependência à nicotina e classifica o paciente conforme sua pontuação.

---

## Sistema de Matrículas

* Controle de vagas
* Lista de espera
* Cancelamento de matrícula
* Histórico de participação

---

## Registro Diário de Sintomas

Permite registrar diariamente:

* Ansiedade
* Irritabilidade
* Insônia
* Vontade de fumar
* Dificuldade de concentração
* Outros sintomas relacionados

---

## Metas Personalizadas

O usuário pode definir:

* Data em que parou de fumar
* Quantidade de dias de meta
* Valor gasto mensalmente com cigarros

O sistema calcula automaticamente:

* Tempo sem fumar
* Economia acumulada
* Progresso da meta

---

## Biblioteca de Recursos

Disponibiliza materiais de apoio como:

* PDFs educativos
* Vídeos informativos
* Sites especializados
* Conteúdos produzidos pelo Ministério da Saúde

---

## Notificações

Sistema interno de alertas para:

* Confirmação de matrícula
* Lembretes de registros diários
* Atualizações importantes
* Avisos sobre turmas

---

## Relatórios

Exportação de relatórios em PDF contendo:

* Frequência dos participantes
* Evolução dos sintomas
* Estatísticas das UPAs
* Indicadores gerais do sistema

---

# 📊 Estrutura Geral do Banco de Dados

O banco de dados foi projetado para gerenciar o programa de combate ao tabagismo, permitindo o controle de pacientes, profissionais de saúde, turmas de acompanhamento, frequência, sintomas e notificações ao longo do tratamento.

| Tabela | Descrição |
|---------|------------|
| **usuarios** | Armazena os dados cadastrais e informações dos pacientes participantes do programa. |
| **enfermeiros** | Contém os dados dos profissionais responsáveis pelo acompanhamento dos pacientes. |
| **upas** | Registra as Unidades de Pronto Atendimento (UPAs) vinculadas ao sistema. |
| **turmas** | Representa os grupos de apoio e tratamento disponibilizados pelas UPAs. |
| **matriculas** | Controla a inscrição dos usuários nas turmas disponíveis. |
| **cronograma** | Armazena as datas e informações dos encontros planejados para cada turma. |
| **presencas** | Registra a participação dos pacientes nos encontros e atividades das turmas. |
| **sintomas_diarios** | Permite o acompanhamento diário dos sintomas relatados pelos usuários durante o tratamento. |
| **notificacoes** | Gerencia mensagens, lembretes e comunicados enviados aos pacientes. |
| **turmas_concluidas** | Mantém o histórico das turmas que finalizaram suas atividades. |
| **alunos_concluidos** | Armazena o histórico dos pacientes que concluíram o programa em uma turma encerrada. |

---

## 🔗 Principais Relacionamentos

- Uma **UPA** pode possuir várias **turmas** e **enfermeiros**.
- Um **usuário** pode realizar uma ou mais **matrículas**.
- Uma **turma** pode possuir diversos usuários matriculados.
- Cada **matrícula** pode registrar várias **presenças**.
- Cada **usuário** pode registrar diversos **sintomas diários**.
- Cada **usuário** pode receber múltiplas **notificações**.
- Cada **turma** possui um **cronograma** com seus encontros planejados.
- As tabelas **turmas_concluidas** e **alunos_concluidos** preservam o histórico do programa após seu encerramento.
# 🚀 Tecnologias Utilizadas

---

## Frontend

* Flutter Web
* Dart
* Material Design
* Widgets Personalizados

## Backend

* Node.js
* Express.js
* JWT Authentication
* REST API

## Banco de Dados

* MySQL

## Infraestrutura

* Ubuntu Server
* DigitalOcean VPS
* PM2

---

# 📚 Documentação do Projeto

Todos os artefatos utilizados durante o desenvolvimento estão disponíveis na pasta `/documentos`.

| Documento         | Descrição                      | Arquivo                                      |
| ----------------- | ------------------------------ | -------------------------------------------- |
| Documentação ABNT | Documento principal do projeto | [Abrir PDF](documentos/Desfumo.pdf) |
| BPMN              | Fluxo dos processos do sistema | [Abrir PDF](documentos/BPMN.pdf)             |
| DOD & Board Visual| Quadro visual do projeto       | [Abrir PDF](documentos/DOD_BoardVisual.pdf)  |
| User Stories & Product Backlog| Histórias de usuário e produto | [Abrir PDF](documentos/user_stories_product_backlog.pdf)|
| Métricas de Fluxo | Indicadores de fluxo           | [Abrir PDF](documentos/MetricasFluxo.pdf)    |
| Performance Ágil  | Indicadores ágeis do projeto   | [Abrir PDF](documentos/PerformanceAgil.pdf)  |
| Apresentação Canva| Slides da apresentação final   | [Abrir PDF](documentos/Desfumo_Apresentacao.pdf)|


---

# 📈 Indicadores e Monitoramento

A plataforma disponibiliza dashboards com:

* Quantidade de usuários cadastrados
* Quantidade de enfermeiras
* Total de UPAs
* Matrículas realizadas
* Taxa de comparecimento
* Evolução dos pacientes
* Distribuição demográfica
* Relatórios estatísticos

---

# 👨‍💻 Autor

**Matheus Bilitardo Abib**

Graduado em Análise e Desenvolvimento de Sistemas pela Fatec Mogi das Cruzes.
Cursando Engenharia de Software na Universidade de Mogi das Cruzes (UMC)

Projeto desenvolvido como solução tecnológica para apoio ao tratamento e combate ao tabagismo (ODS-3).

---
