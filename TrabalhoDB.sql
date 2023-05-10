
	USE Universidade;
	
	CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(3) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA,
							CURSO,
							PROFESSOR
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO


----PROCEDURE CADASTRAR NOTAS

CREATE PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT 
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4,
                    MEDIAFINAL = (@NOTA + N1 + N2 + N3) / 4,
                    PERCFREQ = 100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100)

                    --RESULTADO
                    ,RESULTADO = 
                    CASE 
                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 7 
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75
                        THEN 'APROVADO'
                        
                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 3 
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75 
                        THEN 'EXAME' 
                        
                        ELSE 'REPROVADO'
                    
                    END

                        WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;


            END
        ELSE 
        
        IF @BIMESTRE = 5

            BEGIN

                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA,
				RESULTADO=
				CASE 
					WHEN((NOTAEXAME + MEDIAFINAL) >= 10)
					THEN 'APROVADO'
					ELSE 'REPROVADO'
				END

                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
				
            END

		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END



--PROCEDURE DE CADASTRAR ALUNO
	CREATE PROCEDURE cadastraAlunos(
		@nome char(30)
	)
	AS
	INSERT ALUNOS 
	(
		NOME
	)
	VALUES
	(@nome)




--PROCEDURE DE CADASTRAR CURSOS
	CREATE PROCEDURE cadastracurso(
	@sigla char(3),
	@nome char(20)
	) AS
	INSERT CURSOS
	( 
	CURSO,
	NOME
	)
	VALUES (@sigla, @nome)

--PROCEDURE DE CADASTRAR PROFESSOR 
	CREATE PROCEDURE cadastraProfessor(
		@nome char(30)
	)
	AS
	INSERT PROFESSOR 
	(
		NOME
	)
	VALUES
	(@nome)



--PROCEDURE DE CADASTRAR MATERIAS

	CREATE PROCEDURE cadastrarMaterias(
		@SIGLA VARCHAR(3),
		@NOME VARCHAR(50),
		@CARGAHORARIA INT,
		@CURSO CHAR(3),
		@PROFESSOR INT
	 )
	 AS
	INSERT MATERIAS
	(
		SIGLA,
		NOME,
		CARGAHORARIA,
		CURSO,
		PROFESSOR
	)
	VALUES
	(@SIGLA, @NOME, @CARGAHORARIA, @CURSO, @PROFESSOR)



-------PROCEDURE CADASTRAR ALUNO COM CURSO

CREATE PROCEDURE cadastraAlunoCurso(
	@NOME VARCHAR(50),
	@SIGLA VARCHAR(3))
	AS
		INSERT ALUNOS 
	(
		NOME
	)
	VALUES
	(@nome)

	declare @numeroAluno int;

	set @numeroAluno = (SELECT @@identity)

	INSERT MATRICULA
	(MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO)

	SELECT @numeroAluno AS MATRICULA,CURSO,SIGLA,PROFESSOR,
						YEAR(GETDATE()) AS PERPLETIVO
						FROM MATERIAS WHERE CURSO= @SIGLA;
----------------------------------------------------

	

	CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(3),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	
ALTER TABLE MATRICULA ADD MEDIAFINAL FLOAT
GO
ALTER TABLE MATRICULA ADD NOTAEXAME FLOAT
GO

    INSERT MATRICULA
    (
            MATRICULA,
            CURSO,
            MATERIA,
            PROFESSOR,
            PERLETIVO

    )
    SELECT 1 AS MATRICULA, CURSO, SIGLA,PROFESSOR, 
		YEAR(GETDATE()) FROM MATERIAS WHERE CURSO ='ENG';
GO
SELECT * FROM MATERIAS
GO



------TESTE DA PROCEDURE CADASTRA NOTAS APROVADO

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,          -- int
                      @BIMESTRE = 1;      -- int
GO

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int  
                      @BIMESTRE = 2;      -- int
GO
EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int 
                      @BIMESTRE = 3;      -- int
GO
EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,          -- int
                      @BIMESTRE = 4;      -- int             

------TESTE DA PROCEDURE REPROVADO POR FALTA

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRG',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 10,          -- int
                      @BIMESTRE = 1;      -- int
GO

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRG',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int  
                      @BIMESTRE = 2;      -- int
GO
EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRG',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,         -- int 
                      @BIMESTRE = 3;      -- int
GO
EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRG',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 6,          -- int
                      @BIMESTRE = 4;      -- int           