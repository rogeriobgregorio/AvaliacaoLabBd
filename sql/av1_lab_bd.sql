USE MASTER
GO
DROP DATABASE IF EXISTS av1_lab_bd
GO
CREATE DATABASE av1_lab_bd
GO
USE av1_lab_bd
GO

/* Atividade:
Fazer uma aplicação em Java Web (Maven + Servlets + JSP + CSS + JSTL) com SQL Server para 
resolver os problemas, da seguinte maneira: O sistema deve ter 3 tabelas principais:

Times (Com todos os times)(Não é necessário CRUD para ela)
Times (CodigoTime | NomeTime | Cidade | Estadio | MaterialEsportivo */

CREATE TABLE times (
	codigo_time		    INT				NOT NULL,
	nome_time		    VARCHAR(100)	NOT NULL,
	cidade				VARCHAR(100)	NOT NULL,
	estadio				VARCHAR(100)	NOT NULL,
	material_esportivo	VARCHAR(100)	NOT NULL,

	PRIMARY KEY(codigo_time)
);
GO
---------------------------------------------------------------------------------------

/* Grupos (Coritnthians, Palmeiras, Santos e São Paulo 
NÃO PODEM estar no mesmo grupo) 
(A coluna Grupo não pode aceitar nenhum valor diferente de A, B, C, D)
Grupos (Grupo | CodigoTime) */

CREATE TABLE grupos (
    grupo CHAR(1) NOT NULL CHECK(grupo IN ('A', 'B', 'C', 'D')),
    codigo_time INT NOT NULL,
    PRIMARY KEY(grupo, codigo_time),
    FOREIGN KEY(codigo_time) REFERENCES times(codigo_time)
);
GO
-------------------------------------------------------------------------

/* A primeira fase ocorrerá em 12 datas seguidas, 
sempre rodada cheia (Todos os jogos), aos domingos e quartas.
Jogos (CodigoTimeA | CodigoTimeB | GolsTimeA | GolsTimeB | Data) */

CREATE TABLE jogos (
	codigo_time_A	 INT	NOT NULL,
	codigo_time_B	 INT	NOT NULL,
	gols_time_A		 INT,
	gols_time_B		 INT,
	dia				 DATE CHECK (Dia >= '27/02/2022' and Dia <= '23/05/2022' )

	PRIMARY KEY(codigo_time_A, codigo_time_B),
	FOREIGN KEY(codigo_time_A) REFERENCES times(codigo_time),
	FOREIGN KEY(codigo_time_B) REFERENCES times(codigo_time)
);
GO

-----------------------------------------------------------------------------------
INSERT INTO times (codigo_time, nome_time, cidade, estadio, material_esportivo)
VALUES 
	(1, 'Água Santa', 'Diadema', 'Distrital do Inamar', 'Karilu'),
	(2, 'Botafogo', 'Ribeirão Preto', 'Santa Cruz', 'Volt Sports'),
	(3, 'Corinthians', 'São Paulo', 'Neo Química Arena', 'Nike'),
	(4, 'Ferroviária', 'Araraquara', 'Fonte Luminosa', 'Lupo'),
	(5, 'Guarani', 'Campinas', 'Brinco de Ouro', 'Kappa'),
	(6, 'Inter de Limeira', 'Limeira', 'Limeirão', 'Alluri Sports'),
	(7, 'Ituano', 'Itu', 'Novelli Júnior', 'Kanxa'),
	(8, 'Mirassol', 'Mirassol', 'José Maria de Campos Maia', 'Super Bolla'),
	(9, 'Novorizontino', 'Novo Horizonte', 'Jorge Ismael de Biasi', 'Physicus'),
	(10, 'Palmeiras', 'São Paulo', 'Allianz Parque', 'Puma'),
	(11, 'Ponte Preta', 'Campinas', 'Moisés Lucarelli', '1900'),
	(12, 'Red Bull Bragantino', 'Bragança Paulista', 'Nabi Abi Chedid', 'Nike'),
	(13, 'Santo André', 'Santo André', 'Bruno José Daniel', 'Icone Sports'),
	(14, 'Santos', 'Santos', 'Vila Belmiro', 'Umbro'),
	(15, 'São Bernardo', 'São Bernardo do Campo', 'Primeiro de Maio', 'Magnum Group'),
	(16, 'São Paulo', 'São Paulo', 'Estádio do Morumbi', 'Adidas');
GO
SELECT * FROM times
GO
--------------------------------------------------------------------------------

/* O sistema deve se comportar da seguinte maneira:
Uma tela deve chamar uma procedure que divide os times nos quatro grupos, 
preenchendo aleatoriamente (com exceção da regra já exposta em Grupos). */

-- Insere os 4 grandes, cada um em um grupo de forma aleatória
CREATE PROCEDURE sp_insere_times_grandes
AS
BEGIN
INSERT INTO grupos
SELECT TOP 4 SUBSTRING('ABCD', ROW_NUMBER() 
OVER (ORDER BY NEWID()), 1), times.codigo_time
FROM times
WHERE times.codigo_time IN (3, 10, 14, 16)
AND times.codigo_time NOT IN (SELECT codigo_time FROM grupos)
ORDER BY NEWID()
END;
GO
---------------------------------------------------------------

-- Insere os demais times cada um em um grupo de forma aleatória
CREATE PROCEDURE sp_insere_times
AS
BEGIN	
	-- Associação dos times a números aleatórios de 1 a 12
	WITH numeros_aleatorios AS (
		SELECT ROW_NUMBER() OVER (ORDER BY NEWID()) 
		AS numero_aleatorio, codigo_time 
		FROM times
		WHERE codigo_time NOT IN (3, 10, 14, 16)
	), 
		
	-- Distribuição dos times nos grupos de acordo com a correspondência com os números
	numeros_grupo AS (
		SELECT 
			codigo_time,
			CASE 
				WHEN numero_aleatorio IN (1, 2, 3) THEN 'A' 
				WHEN numero_aleatorio IN (4, 5, 6) THEN 'B' 
				WHEN numero_aleatorio IN (7, 8, 9) THEN 'C' 
				ELSE 'D' 
			END AS grupo
		FROM numeros_aleatorios
	)

	-- Inserção dos times nos grupos correspondentes
	INSERT INTO grupos (grupo, codigo_time)
	SELECT grupo, codigo_time FROM numeros_grupo

END;
GO
-----------------------------------------------------------------

-- Chama as duas procedures anteriores realizando o sorteio 
CREATE PROCEDURE sp_sorteia_grupos
AS
BEGIN
	DELETE FROM grupos
    EXECUTE sp_insere_times_grandes
    EXECUTE sp_insere_times
END;
GO
-----------------------------------------------------------------

--DROP PROCEDURE sp_insere_times
--DROP PROCEDURE sp_sorteia_grupos
--DELETE FROM grupos
--EXEC sp_insere_times_grandes
--EXEC sp_insere_times
EXEC sp_sorteia_grupos
SELECT * FROM grupos
GO
-----------------------------------------------------------------------

/*
Uma tela deve gerar as rodadas dos jogos, de acordo com as regras do
campeonato, preenchendo a tabela jogos.
Lembre-se, cada rodada tem 8 jogos (todos os 16 times). Lembre-se também que, as rodadas
vão acontecer de quarta e domingo, sucessivamente, sem pausas.
• Um jogo não pode ocorrer 2 vezes, mesmo em rodadas diferentes
• Um time não pode aparecer 2 vezes na mesma rodada
• A fase de grupos vai terminar antes da data final do campeonato, uma vez que o
campeonato prevê datas das fase eliminatórias também
*/

CREATE PROCEDURE sp_gera_jogos
AS
	DECLARE @dia_de_hoje AS DATE, 
			@dia_final AS DATE,
			@contador AS INT,
			@codigo AS INT,
			@codigoAdv AS INT,
			@times_jogados AS INT,
			@adversario AS INT,
			@jogou AS INT,
			@id_time AS INT, 
			@mesmoGrupo AS INT 

	-- Escolhe o dia de inicio e do fim de campeonato
	SET @dia_de_hoje = '2022-02-27'
	SET @dia_final = '2022-05-23'
	
	-- Enquanto o campeonato estiver rolando 
	WHILE (@dia_de_hoje < @dia_final)
	BEGIN

	-- Verifica se é dia de Jogo (Quarta ou Domingo)
	IF ((DATEPART(WEEKDAY, @dia_de_hoje) = 1) OR (DATEPART(WEEKDAY, @dia_de_hoje) = 4))
	BEGIN 
		SET @times_jogados = 1

	-- Enquanto os 16 times não tiverem jogado
	WHILE (@times_jogados <= 16 )
	BEGIN

	-- Escolhe o time A que ira jogar 
	SET @id_time = @times_jogados

	-- Verifica se o time A jogou no dia de hoje
	SET @codigo = NULL
	SET @codigo = (SELECT j.codigo_time_A
				   FROM jogos AS j
				   WHERE ((@id_time = j.codigo_time_A OR @id_time = j.codigo_time_B) 
									  AND @dia_de_hoje = j.dia))

	-- Caso ainda não tenha jogado 
	IF (@codigo IS NULL)
	BEGIN
		SET @jogou = 0
		SET @contador = 1
		SET @adversario = 0

	-- Em quanto ainda não jogou e ainda tem adversários para serem enfrentados
	WHILE ((@jogou = 0) AND (@contador < 16))
	BEGIN
	
	-- Escolhe o adversário
	SET @adversario = @id_time + @contador 
	IF (@adversario > 16)
	BEGIN
		SET @adversario = @adversario - 16
	END

	-- Verifica se adversario já jogou no dia de hoje
	SET @codigoAdv = NULL
	SET @codigoAdv = (SELECT j.codigo_time_A 
					  FROM jogos j
					  WHERE ((@adversario = j.codigo_time_A OR @adversario 
					                      = j.codigo_time_B) AND @dia_de_hoje = j.dia))

	-- Verfica se ambos os times já jogaram um contra o outro				
	SET @codigo = NULL
	SET @codigo = (SELECT j.codigo_time_A
				   FROM jogos AS j 
				   WHERE (j.codigo_time_A = @id_time AND j.codigo_time_B = @adversario) OR 
						 (j.codigo_time_A = @adversario AND j.codigo_time_B = @id_time))
	
	-- Verifica se ambos os times estão no mesmo Grupo					
	SET @mesmoGrupo = NULL
	SET @mesmoGrupo = (SELECT g1.codigo_time
					   FROM Grupos g1, Grupos g2
					   WHERE g1.Grupo != g2.Grupo
							 AND g1.codigo_time = @id_time
							 AND g2.codigo_time = @adversario)
	
	-- Se alguma das condições forem Verdadeiras, ira se decidir um novo adversario.
	IF ((@codigo IS NOT NULL) OR (@codigoAdv IS NOT NULL) or (@id_time = @adversario) OR (@mesmoGrupo IS NULL))
	BEGIN 
		SET @contador = @contador + 1
	END 

	-- Senão eles irão se enfrentar 
	ELSE 
	BEGIN 
		SET @jogou = 1; 
		INSERT INTO jogos VALUES (@id_time, @adversario, NULL, NULL, @dia_de_hoje)
	END 
	END 
	END
	SET @times_jogados = @times_jogados + 1 	
	END 
	END 

	SET @dia_de_hoje = DATEADD(DAY, 1, @dia_de_hoje)

	END 
GO
----------------------------------------------------------------------------------------------------------------

--DROP PROCEDURE sp_gera_jogos
EXEC sp_gera_jogos
SELECT * FROM jogos;
GO
-----------------------------------------------------------------

-- Uma tela deve mostrar 4 Tabelas com os 4 grupos formados.
CREATE FUNCTION fn_gerarTabelaGrupo(@grupo AS CHAR(1))
RETURNS @table TABLE (
cod_time	INT,
nome_time	VARCHAR(100)
)
AS
BEGIN
	INSERT INTO @table 
	SELECT t.codigo_time, t.nome_time
	FROM grupos g, times t
	WHERE t.codigo_time = g.codigo_time AND Grupo = @grupo
	RETURN 
END 
GO
-------------------------------------------------------------------------------------------------

-- Uma tela deve mostrar um Campo, onde o usuário digite a data e, em caso de ser uma data com
-- rodada, mostre uma tabela com todos os jogos daquela rodada.
CREATE FUNCTION fn_consultarData (@verfData DATE)
RETURNS @table TABLE (
nome_timeA	VARCHAR(100),
nome_timeB	VARCHAR(100)
)
AS
BEGIN 
	INSERT INTO @table 
		SELECT ta.nome_time, tb.nome_time
		FROM jogos j, times ta, times tb
		WHERE ta.codigo_time = j.codigo_time_A
			AND tb.codigo_time = j.codigo_time_B
			AND j.dia = @verfData
	RETURN 
END 
GO
----------------------------------------------------------------------------------------------------

-- SELECTS -- 
-- Todos os Grupos
SELECT g.grupo, t.nome_time
FROM grupos g
INNER JOIN Times t
ON t.codigo_time = g.codigo_time

-- Todos os Jogos
SELECT j.Dia, ta.codigo_time AS CodigoTimeA, ta.nome_time AS NomeTimeA, 
	   tb.codigo_time AS CodigoTimeB, tb.nome_time AS NomeTimeB
FROM Jogos j, Times ta, Times tb
WHERE ta.codigo_time = j.codigo_time_A
	AND tb.codigo_time = j.codigo_time_B
	ORDER BY j.dia

-- Todos os Times 
SELECT * FROM times 
SELECT * FROM jogos
-- PROCEDURES -- 
EXEC sp_sorteia_grupos
EXEC sp_gera_jogos

-- FUNCTIONs -- 
SELECT * FROM fn_gerarTabelaGrupo('A')
SELECT * FROM fn_gerarTabelaGrupo('B')
SELECT * FROM fn_gerarTabelaGrupo('C')
SELECT * FROM fn_gerarTabelaGrupo('D')

SELECT * FROM fn_consultarData('2022-03-23')

-- Truncate -- 
--TRUNCATE TABLE Jogos 
--TRUNCATE TABLE Grupos