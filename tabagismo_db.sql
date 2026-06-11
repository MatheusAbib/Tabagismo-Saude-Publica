-- phpMyAdmin SQL Dump
-- version 3.4.9
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tempo de Geração: 11/06/2026 às 15h36min
-- Versão do Servidor: 5.5.20
-- Versão do PHP: 5.3.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Banco de Dados: `tabagismo_db`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `alunos_concluidos`
--

CREATE TABLE IF NOT EXISTS `alunos_concluidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `turma_concluida_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `nome_completo` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `percentual_presenca` decimal(5,2) DEFAULT '0.00',
  `total_presencas` int(11) DEFAULT '0',
  `total_faltas` int(11) DEFAULT '0',
  `evolucao` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `turma_concluida_id` (`turma_concluida_id`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=22 ;

--
-- Extraindo dados da tabela `alunos_concluidos`
--

INSERT INTO `alunos_concluidos` (`id`, `turma_concluida_id`, `usuario_id`, `nome_completo`, `email`, `telefone`, `percentual_presenca`, `total_presencas`, `total_faltas`, `evolucao`, `created_at`) VALUES
(1, 1, 3, 'Matheus Abib', 'matheus@gmail.com', '11975072008', 100.00, 2, 0, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"1- Está fumando"}],"total_semanas":1,"semanas_fumando":1,"semanas_sem_fumar":0,"taxa_sucesso":"0.00"}', '2026-04-07 12:58:22'),
(2, 1, 4, 'Luiz Pereira', 'luizaa@gmail.com', '11111111111111131313', 100.00, 1, 0, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":""}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":"0.00"}', '2026-04-07 12:58:22'),
(3, 2, 4, 'Luiz Pereira', 'luizaa@gmail.com', '11111111111111131313', 50.00, 1, 1, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":1,"taxa_sucesso":"100.00"}', '2026-04-07 13:27:41'),
(4, 2, 13, 'Roberto Almeida Santos', 'roberto1@gmail.com', '11990000003', 50.00, 1, 1, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":1,"taxa_sucesso":"100.00"}', '2026-04-07 13:27:41'),
(5, 2, 20, 'Aline Barbosa', 'aline1@gmail.com', '11990000010', 100.00, 2, 0, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":1,"taxa_sucesso":"100.00"}', '2026-04-07 13:27:41'),
(6, 3, 17, 'André Luiz Costa', 'andre1@gmail.com', '11990000007', 100.00, 1, 0, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":1,"taxa_sucesso":"100.00"}', '2026-04-07 13:32:59'),
(7, 4, 3, 'Matheus Abib', 'matheus@gmail.com', '11975072008', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-07 16:17:46'),
(8, 5, 19, 'Ricardo Nunes', 'ricardo1@gmail.com', '11990000009', 0.00, 0, 1, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"}],"total_semanas":1,"semanas_fumando":0,"semanas_sem_fumar":1,"taxa_sucesso":"100.00"}', '2026-04-09 14:26:20'),
(9, 6, 14, 'Juliana Martins', 'juliana1@gmail.com', '11990000004', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-09 14:36:46'),
(10, 7, 18, 'Patrícia Souza Lima', 'patricia1@gmail.com', '11990000008', 100.00, 3, 0, '{"historico":[{"data":"2026-04-07T03:00:00.000Z","status":"2- Sem fumar"},{"data":"2026-04-08T03:00:00.000Z","status":"1- Está fumando"},{"data":"2026-04-09T03:00:00.000Z","status":"1- Está fumando"}],"total_semanas":3,"semanas_fumando":2,"semanas_sem_fumar":1,"taxa_sucesso":"33.33"}', '2026-04-09 14:37:15'),
(11, 8, 3, 'Matheus Bilitardo Abib', 'matheus@gmail.com', '11975072008', 0.00, 0, 1, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-09 15:20:05'),
(12, 9, 3, 'Matheus Bilitardo Abib', 'matheus@gmail.com', '11975072002', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 11:26:17'),
(13, 10, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 1, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 12:55:54'),
(14, 11, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:02:30'),
(15, 12, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:06:45'),
(16, 13, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:07:31'),
(17, 14, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:22:27'),
(18, 15, 3, 'Matheus Bilitardo Abib', 'matheus@gmail.com', '11975072002', 100.00, 1, 0, '{"historico":[{"data":"2026-04-14T03:00:00.000Z","status":"1- Está fumando"}],"total_semanas":1,"semanas_fumando":1,"semanas_sem_fumar":0,"taxa_sucesso":"0.00"}', '2026-04-14 13:26:51'),
(19, 15, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:26:51'),
(20, 16, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:34:17'),
(21, 17, 5, 'Lucia Silva', 'luciasilva@gmail.com', '11111111111', 0.00, 0, 0, '{"historico":[],"total_semanas":0,"semanas_fumando":0,"semanas_sem_fumar":0,"taxa_sucesso":0}', '2026-04-14 13:35:38');

-- --------------------------------------------------------

--
-- Estrutura da tabela `cronograma`
--

CREATE TABLE IF NOT EXISTS `cronograma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `turma_id` int(11) NOT NULL,
  `numero_aula` int(11) NOT NULL,
  `data` date NOT NULL,
  `horario` varchar(50) NOT NULL,
  `mes` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `turma_id` (`turma_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- Extraindo dados da tabela `cronograma`
--

INSERT INTO `cronograma` (`id`, `turma_id`, `numero_aula`, `data`, `horario`, `mes`, `created_at`) VALUES
(6, 29, 1, '2026-04-16', '10:00 - 12:00', 1, '2026-04-08 12:30:17'),
(7, 29, 2, '2026-04-23', '10:00 - 12:00', 1, '2026-04-08 12:30:17'),
(8, 53, 1, '2026-04-17', '16:00 - 18:00', 1, '2026-04-08 12:30:17'),
(9, 101, 1, '2026-04-18', '14:00 - 16:00', 1, '2026-04-08 12:30:17'),
(10, 113, 1, '2026-04-19', '10:00 - 12:00', 1, '2026-04-08 12:30:17'),
(11, 5, 1, '2026-04-21', '08:00 - 10:00', 1, '2026-04-13 15:37:57'),
(12, 5, 2, '2026-04-28', '08:00 - 10:00', 1, '2026-04-13 15:38:12'),
(13, 5, 3, '2026-05-05', '08:00 - 10:00', 2, '2026-04-13 15:38:27'),
(16, 17, 1, '2026-04-21', '08:00 - 10:00', 1, '2026-04-13 15:39:28'),
(17, 17, 2, '2026-04-28', '08:00 - 10:00', 1, '2026-04-13 15:39:36'),
(18, 17, 3, '2026-05-05', '08:00 - 10:00', 2, '2026-04-13 15:39:44');

-- --------------------------------------------------------

--
-- Estrutura da tabela `enfermeiros`
--

CREATE TABLE IF NOT EXISTS `enfermeiros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome_completo` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `tipo_usuario` enum('admin','enfermeira','comum') DEFAULT 'enfermeira',
  `upa_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `upa_id` (`upa_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- Extraindo dados da tabela `enfermeiros`
--

INSERT INTO `enfermeiros` (`id`, `nome_completo`, `email`, `senha`, `telefone`, `tipo_usuario`, `upa_id`, `created_at`) VALUES
(7, 'Lucia', 'lucia@enfermeira.com', '$2a$10$d7jyQxddp/SUm4e0Laaede47tU7lBC7xoAGJs0ngZ.3.FmbWSXuw.', '11111111111', 'enfermeira', 8, '2026-04-02 15:35:40'),
(10, 'teste', 'teste@enfermeira.com', '$2a$10$szgFgWU/Bly9rN.iWrDgRuTGNdNbDzJvhcCGLUkXDTpaPELd7mVJ.', '44444444444', 'enfermeira', 8, '2026-04-02 16:10:51'),
(13, 'Helena', 'helena@enfermeira.com', '$2a$10$LhDEBhpiidetQysTCNbfe.9nDBfgm9Ot6ZbW3UDb9gGVp.GHy7XSO', '33333333333', 'enfermeira', 9, '2026-04-09 12:29:50'),
(14, 'Teste de enfermeira', 'maria@enfermvilavitoria.com', '$2a$10$7A.EBVjwdcd23Jh0Ttg4DuGNVri6t.yfXU89l2mb6naQm1bhuH3JC', '44444444444', 'enfermeira', 9, '2026-04-13 15:35:18'),
(18, 'teste', 'grrg@gmail.com', '$2a$10$c6x/KL9tyVleO97neH895.ymf62CU17AiJcwrQlIx1j5e9UpVOrSi', '77777777777', 'enfermeira', 14, '2026-04-14 12:07:19');

-- --------------------------------------------------------

--
-- Estrutura da tabela `matriculas`
--

CREATE TABLE IF NOT EXISTS `matriculas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `upa_id` int(11) NOT NULL,
  `upa_nome` varchar(255) NOT NULL,
  `turma_horario` varchar(100) NOT NULL,
  `escolaridade` varchar(50) NOT NULL,
  `score_fagestrom` int(11) NOT NULL,
  `medicamento` varchar(100) NOT NULL,
  `comorbidades` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(50) DEFAULT 'em_espera',
  `segunda_opcao_turma` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `upa_id` (`upa_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- Extraindo dados da tabela `matriculas`
--

INSERT INTO `matriculas` (`id`, `usuario_id`, `upa_id`, `upa_nome`, `turma_horario`, `escolaridade`, `score_fagestrom`, `medicamento`, `comorbidades`, `created_at`, `status`, `segunda_opcao_turma`) VALUES
(1, 3, 8, 'Pronto Atendimento Alto Ipiranga', 'Segunda-feira - 08:00 - 10:00', 'Superior', 5, 'Adesivo de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-13 16:58:18', 'cancelada', 'Quarta-feira - 18:00 - 20:00'),
(2, 3, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 08:00 - 10:00', 'Superior', 5, 'Adesivo de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 11:17:09', 'cancelada', 'Quinta-feira - 14:00 - 16:00'),
(7, 5, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 14:00 - 16:00', 'Superior', 6, 'Goma de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:03:55', 'cancelada', 'Terça-feira - 08:00 - 10:00'),
(11, 5, 8, 'Pronto Atendimento Alto Ipiranga', 'Quarta-feira - 08:00 - 10:00', 'Superior', 6, 'Goma de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:23:26', 'cancelada', 'Segunda-feira - 08:00 - 10:00'),
(12, 5, 7, 'Pronto Atendimento Vila Oliveira', 'Sábado - 09:00 - 11:00', 'Pós-graduação', 6, 'Goma de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:25:12', 'cancelada', 'Terça-feira - 10:00 - 12:00'),
(16, 5, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 14:00 - 16:00', 'Superior', 6, 'CUM', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:41:19', 'cancelada', 'Terça-feira - 14:00 - 16:00'),
(17, 5, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 08:00 - 10:00', 'Médio', 6, 'Goma de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:42:10', 'matriculado', 'Terça-feira - 08:00 - 10:00'),
(18, 3, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 14:00 - 16:00', 'Pós-graduação', 5, 'Goma de nicotina', '{"cancer":[],"cardiovascular":[],"metabolico":[],"psiquiatrico":[],"respiratorio":[]}', '2026-04-14 13:59:25', 'matriculado', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `notificacoes`
--

CREATE TABLE IF NOT EXISTS `notificacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `mensagem` text NOT NULL,
  `tipo` enum('sucesso','info','alerta','matricula','sintoma','fagerstrom') DEFAULT 'info',
  `lida` tinyint(1) DEFAULT '0',
  `data_criacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `acao_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=91 ;

--
-- Extraindo dados da tabela `notificacoes`
--

INSERT INTO `notificacoes` (`id`, `usuario_id`, `titulo`, `mensagem`, `tipo`, `lida`, `data_criacao`, `acao_url`) VALUES
(29, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 1, '2026-04-09 16:00:37', '/my-enrollments'),
(30, 3, 'Diário Registrado', 'Registro de hoje salvo!\n\nAcesse o gráfico para acompanhar sua evolução\nContinue assim!', 'sintoma', 1, '2026-04-13 15:22:53', '/home?tab=grafico'),
(31, 3, 'Teste de Fagerström', 'Resultado do seu teste:\n\nNível de dependência: Média\nPontuação: 5 pontos\n\nContinue acompanhando sua evolução.', 'fagerstrom', 1, '2026-04-13 15:23:53', '/fagerstrom-test'),
(32, 4, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso!\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Quinta-feira - 14:00 - 16:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', '', 0, '2026-04-13 15:46:45', '/my-enrollments'),
(33, 4, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Quinta-feira - 14:00 - 16:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-13 15:47:03', '/my-enrollments'),
(34, 4, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso!\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Segunda-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', '', 0, '2026-04-13 15:53:11', '/my-enrollments'),
(35, 4, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-13 15:53:41', '/my-enrollments'),
(36, 4, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso!\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', '', 0, '2026-04-13 15:54:32', '/my-enrollments'),
(37, 4, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-13 15:54:41', '/my-enrollments'),
(46, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Quarta-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-13 16:53:04', '/my-enrollments'),
(47, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Segunda-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-13 16:53:31', '/my-enrollments'),
(48, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Segunda-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-13 16:58:18', '/my-enrollments'),
(49, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Segunda-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-13 16:58:24', '/my-enrollments'),
(50, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 11:17:09', '/my-enrollments'),
(51, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 11:17:19', '/my-enrollments'),
(52, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 10:00 - 12:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 11:24:40', '/my-enrollments'),
(53, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 10:00 - 12:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 11:24:49', '/my-enrollments'),
(54, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 14:00 - 16:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 11:26:39', '/my-enrollments'),
(55, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 14:00 - 16:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 11:26:46', '/my-enrollments'),
(70, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Quarta-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:19:55', '/my-enrollments'),
(71, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Sábado - 09:00 - 11:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:21:22', '/my-enrollments'),
(72, 5, 'Turma Concluída!', 'Parabéns! Você concluiu o programa com sucesso na turma Sábado - 09:00 - 11:00 da Pronto Atendimento Alto Ipiranga. Seu percentual de presença foi de 0%!', 'sucesso', 0, '2026-04-14 13:22:27', '/my-enrollments'),
(73, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Quarta-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:23:26', '/my-enrollments'),
(74, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Quarta-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:23:33', '/my-enrollments'),
(75, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Vila Oliveira\nTurma: Sábado - 09:00 - 11:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:25:12', '/my-enrollments'),
(76, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Sábado - 09:00 - 11:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:26:03', '/my-enrollments'),
(77, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Terça-feira - 14:00 - 16:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:26:11', '/my-enrollments'),
(78, 3, 'Turma Cancelada', 'Infelizmente a turma Terça-feira - 14:00 - 16:00 da Pronto Atendimento Alto Ipiranga foi cancelada. Entre em contato com a UPA para mais informações.', 'alerta', 0, '2026-04-14 13:26:51', '/my-enrollments'),
(79, 5, 'Turma Cancelada', 'Infelizmente a turma Terça-feira - 14:00 - 16:00 da Pronto Atendimento Alto Ipiranga foi cancelada. Entre em contato com a UPA para mais informações.', 'alerta', 0, '2026-04-14 13:26:51', '/my-enrollments'),
(80, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 10:00 - 12:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:29:09', '/my-enrollments'),
(81, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Terça-feira - 10:00 - 12:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:29:15', '/my-enrollments'),
(82, 5, 'Turma Cancelada', 'Infelizmente a turma Terça-feira - 10:00 - 12:00 da Pronto Atendimento Alto Ipiranga foi cancelada. Entre em contato com a UPA para mais informações.', 'alerta', 0, '2026-04-14 13:34:17', '/my-enrollments'),
(83, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 08:00 - 10:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:34:35', '/my-enrollments'),
(84, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Quarta-feira - 18:00 - 20:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:34:43', '/my-enrollments'),
(85, 5, 'Turma Concluída!', 'Parabéns! Você concluiu o programa com sucesso na turma Quarta-feira - 18:00 - 20:00 da Pronto Atendimento Alto Ipiranga. Seu percentual de presença foi de 0%!', 'sucesso', 0, '2026-04-14 13:35:38', '/my-enrollments'),
(86, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 14:00 - 16:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:41:19', '/my-enrollments'),
(87, 5, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 16:00 - 18:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:42:10', '/my-enrollments'),
(88, 5, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Terça-feira - 08:00 - 10:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 13:42:20', '/my-enrollments'),
(89, 3, 'Matrícula Realizada', 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.\n\nUPA: Pronto Atendimento Alto Ipiranga\nTurma: Terça-feira - 14:00 - 16:00\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.', 'matricula', 0, '2026-04-14 13:59:25', '/my-enrollments'),
(90, 3, 'Matrícula Confirmada', 'Parabéns! Sua matrícula foi confirmada.\n\nUPA: Pronto Atendimento Alto Ipiranga\n\nTurma: Terça-feira - 14:00 - 16:00\n\nAcesse "Minhas Matrículas" para mais detalhes.', 'matricula', 0, '2026-04-14 14:00:52', '/my-enrollments');

-- --------------------------------------------------------

--
-- Estrutura da tabela `presencas`
--

CREATE TABLE IF NOT EXISTS `presencas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `matricula_id` int(11) NOT NULL,
  `data` date NOT NULL,
  `status` enum('presente','falta','justificada') DEFAULT 'falta',
  `observacoes` enum('1- Está fumando','2- Sem fumar') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_presenca` (`matricula_id`,`data`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `presencas`
--

INSERT INTO `presencas` (`id`, `matricula_id`, `data`, `status`, `observacoes`, `created_at`) VALUES
(1, 17, '2026-04-29', 'presente', '1- Está fumando', '2026-04-29 12:08:13');

-- --------------------------------------------------------

--
-- Estrutura da tabela `sintomas_diarios`
--

CREATE TABLE IF NOT EXISTS `sintomas_diarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `data` date NOT NULL,
  `ansiedade` int(11) DEFAULT NULL,
  `irritabilidade` int(11) DEFAULT NULL,
  `insonia` int(11) DEFAULT NULL,
  `fome` int(11) DEFAULT NULL,
  `dificuldade_concentracao` int(11) DEFAULT NULL,
  `vontade_fumar` int(11) DEFAULT NULL,
  `observacoes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dia` (`usuario_id`,`data`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Extraindo dados da tabela `sintomas_diarios`
--

INSERT INTO `sintomas_diarios` (`id`, `usuario_id`, `data`, `ansiedade`, `irritabilidade`, `insonia`, `fome`, `dificuldade_concentracao`, `vontade_fumar`, `observacoes`, `created_at`) VALUES
(2, 3, '2026-03-31', 5, 4, 3, 2, 6, 7, NULL, '2026-04-01 16:41:24'),
(3, 3, '2026-03-30', 8, 7, 5, 3, 8, 9, NULL, '2026-04-01 16:41:24'),
(4, 3, '2026-03-25', 9, 8, 6, 4, 9, 10, NULL, '2026-04-01 16:41:24'),
(5, 3, '2026-04-02', 5, 0, 8, 3, 0, 10, '', '2026-04-02 11:19:00'),
(6, 3, '2026-04-08', 6, 3, 9, 2, 8, 6, '', '2026-04-08 14:28:00'),
(7, 3, '2026-04-09', 5, 5, 4, 8, NULL, NULL, NULL, '2026-04-09 12:37:55'),
(8, 3, '2026-04-13', 9, 2, 8, 3, NULL, NULL, 'uaajajja', '2026-04-13 15:22:53');

-- --------------------------------------------------------

--
-- Estrutura da tabela `turmas`
--

CREATE TABLE IF NOT EXISTS `turmas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `upa_id` int(11) NOT NULL,
  `dia_semana` varchar(50) NOT NULL,
  `horario` varchar(50) NOT NULL,
  `vagas_totais` int(11) DEFAULT '4',
  `vagas_ocupadas` int(11) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `upa_id` (`upa_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=278 ;

--
-- Extraindo dados da tabela `turmas`
--

INSERT INTO `turmas` (`id`, `upa_id`, `dia_semana`, `horario`, `vagas_totais`, `vagas_ocupadas`, `created_at`) VALUES
(1, 4, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(2, 5, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(3, 6, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(4, 7, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(5, 8, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(6, 9, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(7, 10, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(8, 11, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(9, 12, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(10, 13, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(11, 14, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(12, 15, 'Segunda-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(13, 4, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(14, 5, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(15, 6, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(16, 7, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(17, 8, 'Terça-feira', '08:00 - 10:00', 4, 1, '2026-04-07 15:26:40'),
(18, 9, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(19, 10, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(20, 11, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(21, 12, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(22, 13, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(23, 14, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(24, 15, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(25, 4, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(26, 5, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(27, 6, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(28, 7, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(29, 8, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(30, 9, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(31, 10, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(32, 11, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(33, 12, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(34, 13, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(35, 14, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(36, 15, 'Terça-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(37, 4, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(38, 5, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(39, 6, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(40, 7, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(41, 8, 'Terça-feira', '14:00 - 16:00', 4, 1, '2026-04-07 15:26:40'),
(42, 9, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(43, 10, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(44, 11, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(45, 12, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(46, 13, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(47, 14, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(48, 15, 'Terça-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(49, 4, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(50, 5, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(51, 6, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(52, 7, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(53, 8, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(54, 9, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(55, 10, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(56, 11, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(57, 12, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(58, 13, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(59, 14, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(60, 15, 'Terça-feira', '16:00 - 18:00', 4, 0, '2026-04-07 15:26:40'),
(61, 4, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(62, 5, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(63, 6, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(64, 7, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(65, 8, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(66, 9, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(67, 10, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(68, 11, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(69, 12, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(70, 13, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(71, 14, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(72, 15, 'Quarta-feira', '08:00 - 10:00', 4, 0, '2026-04-07 15:26:40'),
(73, 4, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(74, 5, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(75, 6, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(76, 7, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(77, 8, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(78, 9, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(79, 10, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(80, 11, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(81, 12, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(82, 13, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(83, 14, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(84, 15, 'Quarta-feira', '18:00 - 20:00', 4, 0, '2026-04-07 15:26:40'),
(85, 4, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(86, 5, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(87, 6, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(88, 7, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(89, 8, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(90, 9, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(91, 10, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(92, 11, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(93, 12, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(94, 13, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(95, 14, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(96, 15, 'Quinta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(97, 4, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(98, 5, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(99, 6, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(100, 7, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(101, 8, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(102, 9, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(103, 10, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(104, 11, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(105, 12, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(106, 13, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(107, 14, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(108, 15, 'Quinta-feira', '14:00 - 16:00', 4, 0, '2026-04-07 15:26:40'),
(109, 4, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(110, 5, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(111, 6, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(112, 7, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(113, 8, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(114, 9, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(115, 10, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(116, 11, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(117, 12, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(118, 13, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(119, 14, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(120, 15, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-07 15:26:40'),
(121, 4, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(122, 5, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(123, 6, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(124, 7, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(125, 8, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(126, 9, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(127, 10, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(128, 11, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(129, 12, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(130, 13, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(131, 14, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(132, 15, 'Sexta-feira', '15:00 - 17:00', 4, 0, '2026-04-07 15:26:40'),
(133, 4, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(134, 5, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(135, 6, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(136, 7, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(137, 8, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(138, 9, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(139, 10, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(140, 11, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(141, 12, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(142, 13, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(143, 14, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(144, 15, 'Sábado', '09:00 - 11:00', 4, 0, '2026-04-07 15:26:40'),
(273, 27, 'Segunda-feira', '14:00 - 16:00', 4, 0, '2026-04-14 11:35:21'),
(274, 27, 'Terça-feira', '08:00 - 10:00', 4, 0, '2026-04-14 11:35:21'),
(275, 27, 'Quarta-feira', '10:00 - 12:00', 4, 0, '2026-04-14 11:35:21'),
(276, 27, 'Quinta-feira', '08:00 - 10:00', 4, 0, '2026-04-14 11:35:21'),
(277, 27, 'Sexta-feira', '10:00 - 12:00', 4, 0, '2026-04-14 11:35:21');

-- --------------------------------------------------------

--
-- Estrutura da tabela `turmas_concluidas`
--

CREATE TABLE IF NOT EXISTS `turmas_concluidas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `upa_id` int(11) NOT NULL,
  `upa_nome` varchar(255) NOT NULL,
  `turma_horario` varchar(100) NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `total_alunos` int(11) DEFAULT '0',
  `total_presencas` int(11) DEFAULT '0',
  `percentual_medio_presenca` decimal(5,2) DEFAULT '0.00',
  `tipo_encerramento` enum('concluida','cancelada') DEFAULT 'concluida',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `upa_id` (`upa_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=18 ;

--
-- Extraindo dados da tabela `turmas_concluidas`
--

INSERT INTO `turmas_concluidas` (`id`, `upa_id`, `upa_nome`, `turma_horario`, `data_inicio`, `data_fim`, `total_alunos`, `total_presencas`, `percentual_medio_presenca`, `tipo_encerramento`, `created_at`) VALUES
(8, 8, 'Pronto Atendimento Alto Ipiranga', 'Segunda-feira - 08:00 - 10:00', '2026-04-09', '2026-04-09', 1, 0, 0.00, 'concluida', '2026-04-09 15:20:05'),
(9, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 10:00 - 12:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'cancelada', '2026-04-14 11:26:17'),
(10, 8, 'Pronto Atendimento Alto Ipiranga', 'Quarta-feira - 08:00 - 10:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'concluida', '2026-04-14 12:55:54'),
(11, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 08:00 - 10:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'concluida', '2026-04-14 13:02:30'),
(12, 8, 'Pronto Atendimento Alto Ipiranga', 'Quarta-feira - 08:00 - 10:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'concluida', '2026-04-14 13:06:45'),
(13, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 08:00 - 10:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'cancelada', '2026-04-14 13:07:31'),
(14, 8, 'Pronto Atendimento Alto Ipiranga', 'Sábado - 09:00 - 11:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'concluida', '2026-04-14 13:22:27'),
(15, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 14:00 - 16:00', '2026-04-14', '2026-04-14', 2, 1, 100.00, 'cancelada', '2026-04-14 13:26:51'),
(16, 8, 'Pronto Atendimento Alto Ipiranga', 'Terça-feira - 10:00 - 12:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'cancelada', '2026-04-14 13:34:17'),
(17, 8, 'Pronto Atendimento Alto Ipiranga', 'Quarta-feira - 18:00 - 20:00', '2026-04-14', '2026-04-14', 1, 0, 0.00, 'concluida', '2026-04-14 13:35:38');

-- --------------------------------------------------------

--
-- Estrutura da tabela `upas`
--

CREATE TABLE IF NOT EXISTS `upas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `endereco` text NOT NULL,
  `cidade` varchar(100) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `horario` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=28 ;

--
-- Extraindo dados da tabela `upas`
--

INSERT INTO `upas` (`id`, `nome`, `endereco`, `cidade`, `telefone`, `horario`, `created_at`) VALUES
(4, 'UPA Jundiapeba', 'Rua Capitão Manoel Soares de Andrade, s/n - Jundiapeba', 'Mogi das Cruzes', '(11) 4790-3400', '24 horas', '2026-03-30 15:24:15'),
(5, 'UPA Braz Cubas', 'Rua Manoel da Cunha, 200 - Braz Cubas', 'Mogi das Cruzes', '(11) 4790-3500', '24 horas', '2026-03-30 15:24:15'),
(6, 'Pronto Atendimento César de Souza', 'Rua Aristeu Machado, s/n - César de Souza', 'Mogi das Cruzes', '(11) 4790-3600', '24 horas', '2026-03-30 15:24:15'),
(7, 'Pronto Atendimento Vila Oliveira', 'Rua Vereador João de Souza, s/n - Vila Oliveira', 'Mogi das Cruzes', '(11) 4790-3700', '24 horas', '2026-03-30 15:24:15'),
(8, 'Pronto Atendimento Alto Ipiranga', 'Rua Dr. Ricardo Vilela, 700 - Alto Ipiranga', 'Mogi das Cruzes', '(11) 4790-3800', '07h às 19h', '2026-03-30 15:24:15'),
(9, 'Pronto Atendimento Vila Vitória', 'Rua Manoel de Oliveira, 250 - Vila Vitória', 'Mogi das Cruzes', '(11) 4790-3900', '07h às 19h', '2026-03-30 15:24:15'),
(10, 'UBS Central', 'Rua Dr. Deodato Wertheimer, 100 - Centro', 'Mogi das Cruzes', '(11) 4790-4000', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(11, 'UBS Vila São Francisco', 'Rua Professor Ismael da Silva, 500 - Vila São Francisco', 'Mogi das Cruzes', '(11) 4790-4100', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(12, 'UBS Jardim Santista', 'Rua Antônio de Barros, 350 - Jardim Santista', 'Mogi das Cruzes', '(11) 4790-4200', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(13, 'UBS Vila Lavínia', 'Rua Voluntário Fernando Pinheiro Franco, 280 - Vila Lavínia', 'Mogi das Cruzes', '(11) 4790-4300', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(14, 'UBS Jardim Armênia', 'Rua Armênia, 200 - Jardim Armênia', 'Mogi das Cruzes', '(11) 4790-4400', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(15, 'UBS Vila Industrial', 'Rua Manoel Alves Ferreira, 101 - Vila Industrial', 'Mogi das Cruzes', '(11) 4790-4500', 'Segunda a Sexta: 07h às 17h', '2026-03-30 15:24:15'),
(27, 'Teste de Upa', 'Rua Professor Jurandyr de Oliveira, 49 - Fazenda Rodeio', 'Mogi das Cruzes', '7777777777', 'Segunda a Sábado: 08h às 17h', '2026-04-13 15:31:36');

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuarios`
--

CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome_completo` varchar(255) NOT NULL,
  `sexo` varchar(20) NOT NULL,
  `data_nascimento` date NOT NULL,
  `idade` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cpf` varchar(20) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `score_fagestrom` int(11) DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `target_days` int(11) DEFAULT NULL,
  `cigarros_por_dia` int(11) DEFAULT NULL,
  `valor_carteira` decimal(10,2) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  `tipo_usuario` enum('admin','enfermeira','comum') DEFAULT 'comum',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- Extraindo dados da tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome_completo`, `sexo`, `data_nascimento`, `idade`, `email`, `senha`, `created_at`, `cpf`, `telefone`, `score_fagestrom`, `stop_date`, `target_days`, `cigarros_por_dia`, `valor_carteira`, `is_admin`, `tipo_usuario`) VALUES
(3, 'Matheus Bilitardo Abib', 'Masculino', '2008-04-24', 17, 'matheus@gmail.com', '$2a$10$nXYBvd0mmHPTwQ.9YvMJseXE5d75vgF2qcpJOZDPrNIGfIQou9.Rq', '0000-00-00 00:00:00', '42211384830', '11975072002', 5, '2026-04-01', 100, 10, 12.00, 0, 'comum'),
(4, 'Luiz Pereira', '', '2008-04-04', 17, 'luizaa@gmail.com', '$2a$10$YADH8UOOc9GauVXsPfVXT.2ziSQHRew8BgsYUJ9G9ae2fWjADlqV2', '2026-03-31 12:22:09', '22222222222', '11111111111111131313', 8, '2026-02-04', 100, 7, 12.00, 0, 'comum'),
(5, 'Lucia Silva', 'Feminino', '1970-04-06', 55, 'luciasilva@gmail.com', '$2a$10$Zu5tvRyVMowz8yCNWoJ6xOgGUZ6PTwPRdX/pPKSZ.Rs3qQuPk0mRy', '2026-04-02 11:21:01', '42211384838', '11111111111', 6, '2026-02-05', 230, 2, 11.00, 0, 'comum'),
(6, 'Administrador', 'Outro', '2008-04-06', 17, 'admin@admin.com', '$2a$10$EkhF2x.9WiAj3QQXOT/XUusgYZqui8ulCC1zzn0s6PdxGREK4D9Iy', '2026-04-02 11:22:00', '42211384838', '33333333333', NULL, NULL, NULL, NULL, NULL, 1, 'admin'),
(11, 'Carlos Henrique Souza', 'Masculino', '1985-03-12', 41, 'carlos1@gmail.com', '123', '2026-04-06 14:11:00', '11111111101', '11990000001', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(12, 'Fernanda Lima Rocha', 'Feminino', '1990-07-22', 35, 'fernanda1@gmail.com', '123', '2026-04-06 14:11:00', '11111111102', '11990000002', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(13, 'Roberto Almeida Santos', 'Masculino', '1978-11-03', 47, 'roberto1@gmail.com', '123', '2026-04-06 14:11:00', '11111111103', '11990000003', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(14, 'Juliana Martins', 'Feminino', '1995-01-18', 31, 'juliana1@gmail.com', '123', '2026-04-06 14:11:00', '11111111104', '11990000004', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(15, 'Paulo Ricardo Mendes', 'Masculino', '1982-09-30', 43, 'paulo1@gmail.com', '123', '2026-04-06 14:11:00', '11111111105', '11990000005', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(16, 'Camila Ferreira Gomes', 'Feminino', '1988-05-14', 37, 'camila1@gmail.com', '123', '2026-04-06 14:11:00', '11111111106', '11990000006', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(17, 'André Luiz Costa', 'Masculino', '1975-02-25', 50, 'andre1@gmail.com', '123', '2026-04-06 14:11:00', '11111111107', '11990000007', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(18, 'Patrícia Souza Lima', 'Feminino', '1992-12-10', 33, 'patricia1@gmail.com', '123', '2026-04-06 14:11:00', '11111111108', '11990000008', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(19, 'Ricardo Nunes', 'Masculino', '1987-06-08', 38, 'ricardo1@gmail.com', '123', '2026-04-06 14:11:00', '11111111109', '11990000009', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(20, 'Aline Barbosa', 'Feminino', '1993-04-27', 32, 'aline1@gmail.com', '123', '2026-04-06 14:11:00', '11111111110', '11990000010', NULL, NULL, NULL, NULL, NULL, 0, 'comum'),
(22, 'Luiza Mel Lee', '', '2008-04-11', 17, 'luiza@gmail.com', '$2a$10$T2hWXAh7QwM4oLGj4Mj5ceqyu65WuGELVFeNTWBsWKyi6i9TJKFdS', '2026-04-06 16:23:45', '42211393939', '33333333333', 8, NULL, NULL, NULL, NULL, 0, 'comum');

--
-- Restrições para as tabelas dumpadas
--

--
-- Restrições para a tabela `cronograma`
--
ALTER TABLE `cronograma`
  ADD CONSTRAINT `cronograma_ibfk_1` FOREIGN KEY (`turma_id`) REFERENCES `turmas` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `enfermeiros`
--
ALTER TABLE `enfermeiros`
  ADD CONSTRAINT `enfermeiros_ibfk_1` FOREIGN KEY (`upa_id`) REFERENCES `upas` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `matriculas`
--
ALTER TABLE `matriculas`
  ADD CONSTRAINT `matriculas_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `matriculas_ibfk_2` FOREIGN KEY (`upa_id`) REFERENCES `upas` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `notificacoes`
--
ALTER TABLE `notificacoes`
  ADD CONSTRAINT `notificacoes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `presencas`
--
ALTER TABLE `presencas`
  ADD CONSTRAINT `presencas_ibfk_1` FOREIGN KEY (`matricula_id`) REFERENCES `matriculas` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `sintomas_diarios`
--
ALTER TABLE `sintomas_diarios`
  ADD CONSTRAINT `sintomas_diarios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `turmas`
--
ALTER TABLE `turmas`
  ADD CONSTRAINT `turmas_ibfk_1` FOREIGN KEY (`upa_id`) REFERENCES `upas` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
