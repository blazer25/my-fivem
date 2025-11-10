-- --------------------------------------------------------
-- Anfitrião:                    127.0.0.1
-- Versão do servidor:           10.4.28-MariaDB - mariadb.org binary distribution
-- SO do servidor:               Win64
-- HeidiSQL Versão:              12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_alarmes
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_alarmes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `horas` varchar(50) DEFAULT NULL,
  `dia` int(11) DEFAULT NULL,
  `nome` varchar(500) DEFAULT NULL,
  `ativado` int(11) DEFAULT 0,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idalarme` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idalarme` (`idalarme`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `jpr_phonesystem_gps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(80) NOT NULL DEFAULT '0',
  `coords` tinytext DEFAULT NULL,
  `name` varchar(80) DEFAULT NULL,
  `color` varchar(80) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_base
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_base` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `numero` varchar(3000) DEFAULT NULL,
  `linguagem` varchar(50) DEFAULT NULL,
  `residencia` varchar(50) DEFAULT NULL,
  `pin` varchar(50) DEFAULT NULL,
  `bateria` int(11) DEFAULT 100,
  `faceid` int(11) DEFAULT NULL,
  `tema` varchar(50) DEFAULT NULL,
  `tutorial` int(1) unsigned zerofill DEFAULT NULL,
  `email` varchar(250) DEFAULT NULL,
  `definicoes` text DEFAULT NULL,
  `apps` text DEFAULT NULL,
  `pCase` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=544 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_cinema
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_cinema` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `titulo` varchar(150) DEFAULT NULL,
  `conteudo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `img` text DEFAULT NULL,
  `time` time DEFAULT current_timestamp(),
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idcinema` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcinema` (`idcinema`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_contactos
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_contactos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `apelido` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  `empresa` varchar(50) NOT NULL DEFAULT 'Desconhecido',
  `perfil` varchar(1500) DEFAULT NULL,
  `favorito` int(1) DEFAULT 0,
  `idcontacto` varchar(100) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontacto` (`idcontacto`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_emails
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(250) DEFAULT NULL,
  `conteudo` longtext DEFAULT NULL,
  `enviadopor` varchar(350) DEFAULT NULL,
  `destinatario` varchar(350) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idemail` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idemail` (`idemail`),
  KEY `destinatario` (`destinatario`)
) ENGINE=InnoDB AUTO_INCREMENT=635 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_faturas
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_faturas` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(350) DEFAULT NULL,
  `senderCitizenID` varchar(350) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `society` tinytext DEFAULT NULL,
  `joblabel` varchar(350) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idfatura` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idfatura` (`idfatura`),
  KEY `idtelemovel` (`citizenid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_galeria
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_galeria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `imagem` text DEFAULT NULL,
  `tumbnail` text DEFAULT NULL,
  `favorito` int(11) DEFAULT 0,
  `tipo` varchar(50) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idfoto` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idfoto` (`idfoto`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_instagram
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_instagram` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `quempostou` varchar(350) DEFAULT NULL,
  `nickname` varchar(350) DEFAULT NULL,
  `conteudo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `filtro` varchar(250) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `video` text DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  `respostas` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idinstagram` varchar(350) DEFAULT NULL,
  `idcontainstagram` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idtweet` (`idinstagram`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_instagram_accounts
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_instagram_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `verificado` int(11) DEFAULT 0,
  `tutorial` int(11) DEFAULT 0,
  `nomeconta` varchar(250) DEFAULT NULL,
  `nickname` varchar(250) DEFAULT NULL,
  `password` varchar(350) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `seguidores` text DEFAULT NULL,
  `aseguir` text DEFAULT NULL,
  `loginativo` text DEFAULT NULL,
  `idcontainstagram` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontatweet` (`idcontainstagram`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_instagram_storys
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_instagram_storys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `media` text DEFAULT NULL,
  `visto` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idcontainstagram` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontainstagram` (`idcontainstagram`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_logs_carteira
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_logs_carteira` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `valor` varchar(350) DEFAULT NULL,
  `atividade` int(11) DEFAULT 0,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_mensagens
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_mensagens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `messages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `idmensagem` varchar(200) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idmensagem` (`idmensagem`),
  KEY `number` (`number`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=2985 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_darknet
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_darknet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dono` varchar(350) DEFAULT NULL,
  `participantes` text DEFAULT '{}',
  `nome` varchar(250) DEFAULT NULL,
  `messages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `password` varchar(350) DEFAULT NULL,
  `idgrupo` varchar(250) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idgrupo` (`idgrupo`),
  KEY `dono` (`dono`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=UTF8_GENERAL_CI;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_news
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `titulo` varchar(150) DEFAULT NULL,
  `conteudo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `img` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idnews` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idnews` (`idnews`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_notas
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_notas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `conteudo` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idnota` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idnota` (`idnota`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_olx
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_olx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `postador` varchar(350) DEFAULT NULL,
  `titulo` varchar(350) DEFAULT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `valor` int(11) DEFAULT 0,
  `categoria` int(11) DEFAULT 0,
  `img` text DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idanuncio` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idanuncio` (`idanuncio`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_recentes
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_recentes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `perdida` int(1) DEFAULT 0,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `recenteid` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `recenteid` (`recenteid`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=952 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_spotify
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_spotify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(250) DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_tiktok
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_tiktok` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `quempostou` varchar(350) DEFAULT NULL,
  `nickname` varchar(350) DEFAULT NULL,
  `conteudo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `musica` varchar(250) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `video` text DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  `respostas` text DEFAULT NULL,
  `guardados` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idtiktok` varchar(350) DEFAULT NULL,
  `idcontatiktok` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idtweet` (`idtiktok`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_tiktok_accounts
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_tiktok_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `verificado` int(11) DEFAULT NULL,
  `tutorial` int(11) DEFAULT 0,
  `nickname` varchar(250) DEFAULT NULL,
  `password` varchar(350) DEFAULT NULL,
  `descricao` varchar(250) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `seguidores` text DEFAULT NULL,
  `aseguir` text DEFAULT NULL,
  `loginativo` text DEFAULT NULL,
  `idcontatiktok` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontatiktok` (`idcontatiktok`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_tweets
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `quempostou` varchar(350) DEFAULT NULL,
  `nickname` varchar(350) DEFAULT NULL,
  `conteudo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `img` text DEFAULT NULL,
  `video` text DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  `retweets` int(11) DEFAULT 0,
  `retweetado` int(11) DEFAULT 0,
  `respostas` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `idtweet` varchar(350) DEFAULT NULL,
  `idcontatweet` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idtweet` (`idtweet`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_tweet_accounts
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_tweet_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `verificado` int(11) DEFAULT 0,
  `tutorial` int(11) DEFAULT 0,
  `nomeconta` varchar(250) DEFAULT NULL,
  `nickname` varchar(250) DEFAULT NULL,
  `password` varchar(350) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `banner` text DEFAULT NULL,
  `descricao` varchar(165) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `seguidores` text DEFAULT NULL,
  `aseguir` text DEFAULT NULL,
  `loginativo` text DEFAULT NULL,
  `idcontatweet` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontatweet` (`idcontatweet`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_ubereats
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_ubereats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(250) DEFAULT NULL,
  `favoritos` text DEFAULT NULL,
  `ultimopedido` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_whatsapp
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_whatsapp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `messages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `idmensagem` varchar(200) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idmensagem` (`idmensagem`),
  KEY `number` (`number`),
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=3085 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Exportação de dados não seleccionada.

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_whatsapp_grupos
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_whatsapp_grupos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dono` varchar(350) DEFAULT NULL,
  `participantes` text DEFAULT '{}',
  `nome` varchar(250) DEFAULT NULL,
  `imagem` text DEFAULT NULL,
  `messages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `idgrupo` varchar(250) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idgrupo` (`idgrupo`),
  KEY `dono` (`dono`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=UTF8_GENERAL_CI;

-- A despejar estrutura para tabela qbcoreframework_988086.jpr_phonesystem_tinder_accounts
CREATE TABLE IF NOT EXISTS `jpr_phonesystem_tinder_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idtelemovel` varchar(350) DEFAULT NULL,
  `numero` varchar(90) DEFAULT NULL,
  `nickname` varchar(250) DEFAULT NULL,
  `password` varchar(350) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `descricao` varchar(165) DEFAULT NULL,
  `gender` varchar(165) DEFAULT NULL,
  `want` varchar(165) DEFAULT NULL,
  `nascimento` date DEFAULT current_timestamp(),
  `date` timestamp NULL DEFAULT current_timestamp(),
  `favoritos` text DEFAULT NULL,
  `idcontatinder` varchar(350) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idcontatinder` (`idcontatinder`) USING BTREE,
  KEY `idtelemovel` (`idtelemovel`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE jpr_phonesystem_whatsapp_grupos MODIFY COLUMN messages TEXT COLLATE utf8mb4_bin;
ALTER TABLE jpr_phonesystem_olx MODIFY COLUMN descricao TEXT COLLATE utf8mb4_bin;

ALTER TABLE players
ADD IF NOT EXISTS crypto TEXT;

-- Exportação de dados não seleccionada.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;