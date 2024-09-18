create database veterinaria;

use veterinaria;

create table paciente(
id_paciente int primary key auto_increment,
nome varchar (45) not null,
sobrenome varchar (45) not null,
Idade int not null,
especie varchar (50) not null);

CREATE TABLE Log_Consultas (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    custo_antigo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2),
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
);


create table veterinario(
id_veterinario int primary key auto_increment,
nome varchar (50) not null,
especialidade varchar (50) not null);

create table consultas(
id_consulta int primary key auto_increment,
id_paciente int,
id_veterinario int,
data_consulta date not null,
custo decimal (10,2) not null,
foreign key (id_paciente) references paciente(id_paciente),
foreign key (id_veterinario) references veterinario (id_veterinario));

insert into paciente values (3, 'Luna', 'Julia', -3, 'cachorro');

insert into veterinario values(1,'Enrico', 'vacina');

insert into consultas values(1,2,1,2024-10-23,25.00);
select * from  consultas;

select * from paciente

DELIMITER //

CREATE PROCEDURE agendar_consulta(
     id_paciente INT,
     id_veterinario INT,
     data_consulta DATE,
     custo DECIMAL(10, 2)
)
BEGIN
    -- Insere uma nova linha na tabela 'consultas'
    INSERT INTO consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (id_paciente, id_veterinario, data_consulta, custo);
END //

DELIMITER ;

CALL agendar_consulta(1, 1, '2024-10-01', 20.00);


DELIMITER //

CREATE PROCEDURE atualizar_paciente(
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR(45),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INT
)
BEGIN
    -- Atualiza o nome, a espécie e a idade do paciente com o id_paciente especificado
    UPDATE paciente
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

CALL atualizar_paciente(1, 'Antonia Silva', 'cachorro', 4);

DELIMITER //

CREATE PROCEDURE remover_consulta(
    IN p_id_consulta INT
)
BEGIN
    -- Remove a consulta com o id_consulta especificado
    DELETE FROM consultas
    WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

CALL remover_consulta(4);


DELIMITER //

CREATE FUNCTION total_gasto_paciente(
    p_id_paciente INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10, 2);

    -- Calcula o total gasto pelo paciente em consultas
    SELECT COALESCE(SUM(custo), 0) INTO v_total
    FROM consultas
    WHERE id_paciente = p_id_paciente;

    RETURN v_total;
END //

DELIMITER ;

SELECT total_gasto_paciente(2);

DELIMITER //

CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
    -- Verifica se a idade do paciente é um número positivo
    IF NEW.Idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Idade do paciente deve ser um número positivo.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    -- Verifica se o custo foi alterado
    IF OLD.custo <> NEW.custo THEN
        -- Insere um registro na tabela de log com os detalhes da mudança
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //

DELIMITER ;


UPDATE consultas
SET custo = 30.00
WHERE id_consulta = 1;

SELECT * FROM Log_Consultas;
