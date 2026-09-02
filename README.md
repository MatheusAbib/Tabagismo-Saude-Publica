# 🚭 Desfumo

> **O lugar onde o fumo deixa de existir**

![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-4.x-000000?logo=express&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?logo=javascript&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![DigitalOcean](https://img.shields.io/badge/DigitalOcean-VPS-0080FF?logo=digitalocean&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-Deploy-000000?logo=vercel&logoColor=white)

---

## 📋 Sobre o Projeto

O **Desfumo** é uma plataforma web desenvolvida para auxiliar pessoas que desejam parar de fumar, oferecendo acompanhamento estruturado, suporte profissional e recursos educacionais.

A plataforma conecta **usuários**, **enfermeiras** e **Unidades de Pronto Atendimento (UPAs)** em um ambiente digital que facilita o monitoramento da evolução dos pacientes durante programas de cessação do tabagismo.

Além do acompanhamento clínico, o sistema oferece ferramentas para registro diário de sintomas, definição de metas, controle de frequência em grupos de apoio, relatórios gerenciais e indicadores estatísticos.

> Acesse o projeto online: (https://desfumo.vercel.app/)
---

## 📚 Documentação do Projeto

Todos os artefatos utilizados durante o desenvolvimento estão disponíveis na pasta [`/documentos`](./documentos).

| Documento | Descrição | Arquivo |
|---|---|---|
| **Documentação ABNT** | Documento principal do projeto | [Abrir PDF](./documentos/Desfumo.pdf) |
| **BPMN** | Fluxo dos processos do sistema | [Abrir PDF](./documentos/BPMN.pdf) |
| **DOD & Board Visual** | Quadro visual do projeto | [Abrir PDF](./documentos/DOD_BoardVisual.pdf) |
| **User Stories & Product Backlog** | Histórias de usuário e backlog do produto | [Abrir PDF](./documentos/user_stories_product_backlog.pdf) |
| **Métricas de Fluxo** | Indicadores de fluxo | [Abrir PDF](./documentos/MetricasFluxo.pdf) |
| **Performance Ágil** | Indicadores ágeis do projeto | [Abrir PDF](./documentos/PerformanceAgil.pdf) |
| **Apresentação Canva** | Slides da apresentação final | [Abrir PDF](./documentos/Desfumo_Apresentacao.pdf) |

## 🎯 Objetivo

Promover o combate ao tabagismo através de uma solução digital capaz de:

- ✅ Facilitar o acompanhamento dos pacientes
- ✅ Auxiliar profissionais de saúde no monitoramento
- ✅ Centralizar informações e históricos
- ✅ Disponibilizar materiais educativos
- ✅ Gerar relatórios e indicadores de desempenho
- ✅ Incentivar a permanência do paciente no tratamento

### 🌎 Alinhamento com os Objetivos de Desenvolvimento Sustentável

Este projeto está alinhado ao **ODS 3 – Saúde e Bem-Estar**, contribuindo para a promoção da saúde e para a redução dos impactos causados pelo tabagismo por meio do uso da tecnologia.

---

## 🌐 Demonstração

- **Frontend (Vercel):** [https://desfumo.vercel.app](https://desfumo.vercel.app)
- **Backend (DigitalOcean):** `http://64.227.6.51:3000`

---

## 👥 Perfis de Usuário

### 👤 Usuário Comum (Paciente)

O usuário é a pessoa que deseja abandonar o tabagismo.

**Funcionalidades:**
- Cadastro completo com validação de CPF e email
- Login e recuperação de acesso
- Teste de Fagerström com salvamento do resultado
- Matrícula em turmas de apoio com lista de espera automática
- Registro diário de sintomas (ansiedade, irritabilidade, insônia, etc.)
- Definição de metas personalizadas (data de parada, dias meta, valor da carteira)
- Acompanhamento da evolução através de gráficos interativos
- Biblioteca de materiais educativos (PDFs, vídeos e links)
- Visualização do cronograma de aulas
- Gerenciamento de matrículas com histórico completo
- Recebimento de notificações em tempo real
- Dashboard com estatísticas pessoais

---

### 👩‍⚕️ Enfermeira

Profissional responsável pelo acompanhamento dos pacientes vinculados à sua UPA.

**Funcionalidades:**
- Dashboard da unidade com indicadores de desempenho
- Visualização dos pacientes cadastrados com filtros por status
- Controle de frequência das turmas com registro de presenças em lote
- Registro de observações semanais dos pacientes
- Gestão de cronogramas de aulas
- Encerramento de turmas com geração de histórico
- Emissão de relatórios em PDF
- Acompanhamento da evolução dos pacientes com gráficos
- Ficha do paciente com histórico completo

---

### 👨‍💼 Administrador

Responsável pela gestão global da plataforma.

**Funcionalidades:**
- Dashboard geral do sistema com métricas e indicadores
- Gestão de usuários (visualização, edição e detalhes)
- Gestão de enfermeiras (criação, edição e exclusão)
- Gestão de UPAs (criação, edição e exclusão com turmas)
- Gestão de turmas e cronogramas
- Controle de matrículas
- Relatórios administrativos em PDF
- Estatísticas gerais da plataforma

---

## 🔐 Credenciais para Demonstração

### Administrador

| Campo  | Valor                                     |
| ------ | ----------------------------------------- |
| E-mail | [admin@admin.com](mailto:admin@admin.com) |
| Senha  | Admin123#                                 |

### Enfermeira

| Campo  | Valor                                               |
| ------ | --------------------------------------------------- |
| E-mail | [teste@enfermeira.com](mailto:teste@enfermeira.com) |
| Senha  | Admin123#                                           |

> ℹ️ Para testar o fluxo de paciente, basta realizar um novo cadastro pela tela inicial.

---

## 🛠️ Principais Funcionalidades

### Teste de Fagerström
Avalia o nível de dependência à nicotina e classifica o paciente conforme sua pontuação (Muito Baixa a Muito Elevada).

### Sistema de Matrículas
- Controle de vagas disponíveis
- Lista de espera automática
- Cancelamento de matrícula
- Histórico de participação
- Confirmação de matrícula por enfermeira

### Registro Diário de Sintomas
Permite registrar diariamente:
- Ansiedade
- Irritabilidade
- Insônia
- Fome
- Vontade de fumar
- Dificuldade de concentração
- Observações adicionais
- Gráfico de evolução dos sintomas

### Metas Personalizadas
O usuário pode definir:
- Data em que parou de fumar
- Quantidade de dias de meta
- Valor gasto mensalmente com cigarros

O sistema calcula automaticamente:
- Tempo sem fumar
- Economia acumulada
- Progresso da meta

### Biblioteca de Recursos
Disponibiliza materiais de apoio como:
- PDFs educativos (Guia Prático)
- Vídeos informativos
- Sites especializados
- Conteúdos produzidos pelo Ministério da Saúde

### Notificações
Sistema interno de alertas para:
- Confirmação de matrícula
- Lembretes de registros diários
- Atualizações importantes
- Avisos sobre turmas
- Marcação de todas como lidas

### Relatórios
Exportação de relatórios em PDF contendo:
- Frequência dos participantes
- Evolução dos sintomas
- Estatísticas das UPAs
- Indicadores gerais do sistema
- Dashboard completo da enfermeira
- Dashboard administrativo

---

## 📊 Estrutura Geral do Banco de Dados

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

---

## 🚀 Tecnologias Utilizadas

### Frontend
- Flutter Web 3.19
- Dart 3.x
- Material Design
- Widgets Personalizados
- Provider (Gerenciamento de estado)
- Shared Preferences (Armazenamento local)
- fl_chart (Gráficos interativos)
- pdf & printing (Geração de PDFs)

### Backend
- Node.js 20.x
- Express.js 4.x
- JWT Authentication
- REST API
- Bcryptjs (Hash de senhas)
- MySQL2 (Driver MySQL)
- Dotenv (Variáveis de ambiente)

### Banco de Dados
- MySQL 8.0

### Infraestrutura
- Ubuntu Server
- DigitalOcean VPS
- PM2 (Gerenciamento de processos)
- Vercel (Deploy do Frontend)

---

## 📈 Indicadores e Monitoramento

A plataforma disponibiliza dashboards para acompanhamento e monitoramento dos principais indicadores do sistema:

- Quantidade de usuários cadastrados
- Quantidade de enfermeiras
- Total de UPAs
- Matrículas realizadas
- Taxa de comparecimento
- Evolução dos pacientes
- Distribuição demográfica
- Relatórios estatísticos
- Indicadores de desempenho por UPA

---

