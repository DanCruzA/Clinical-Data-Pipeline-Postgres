-- Tabla Médicos
CREATE TABLE Medicos (
    id_medico SERIAL PRIMARY KEY,  -- SERIAL es el autoincremental en Postgres
    nombre VARCHAR(100),
    especialidad VARCHAR(100),
    sede VARCHAR(50)
);

-- Tabla Pacientes
CREATE TABLE Pacientes (
    id_paciente INTEGER PRIMARY KEY,
    nombre VARCHAR(100),
    edad INTEGER,
    distrito VARCHAR(50)
);

-- Tabla Citas
CREATE TABLE Citas (
    id_cita SERIAL PRIMARY KEY,
    id_medico INTEGER,
    id_paciente INTEGER,
    fecha DATE,
    costo DECIMAL(10,2),
    CONSTRAINT fk_medico FOREIGN KEY(id_medico) REFERENCES Medicos(id_medico),
    CONSTRAINT fk_paciente FOREIGN KEY(id_paciente) REFERENCES Pacientes(id_paciente)
);


-- Insertamos MÉDICOS (7 doctores en total)
INSERT INTO Medicos (nombre, especialidad, sede) VALUES 
    ('Dr. Perez', 'Cardiología', 'Surco'),         -- ID 1
    ('Dra. Gomez', 'Pediatría', 'Surco'),           -- ID 2
    ('Dr. Soto', 'Ginecología', 'San Borja'),       -- ID 3
    ('Dra. Ruiz', 'Dermatología', 'Miraflores'),    -- ID 4
    ('Dr. Quispe', 'Medicina General', 'Surco'),    -- ID 5
    ('Dra. Mendoza', 'Neurología', 'San Borja'),    -- ID 6
    ('Dr. Castillo', 'Pediatría', 'Miraflores');    -- ID 7

    
-- Insertamos PACIENTES (10 pacientes)
INSERT INTO Pacientes (id_paciente, nombre, edad, distrito) VALUES 
    (100, 'Juan Silva', 30, 'Surco'),
    (101, 'Maria Lopez', 25, 'Miraflores'),
    (102, 'Carlos Ruiz', 50, 'Surco'),
    (103, 'Ana Diaz', 7, 'San Borja'),
    (104, 'Luis Vera', 45, 'Surco'),
    (105, 'Elena Torres', 28, 'San Isidro'),
    (106, 'Pedro Castillo', 60, 'Lima'),
    (107, 'Sofia Vargas', 5, 'Miraflores'),
    (108, 'Jorge Lima', 35, 'Surco'),
    (109, 'Valeria Maza', 22, 'San Borja');


-- C. Insertamos CITAS (Datos transaccionales - ¡Aquí está la riqueza!)
-- Diseñado para que:
-- - Juan Silva (100) tenga 3 visitas.
-- - Maria Lopez (101) tenga 3 visitas.
-- - Dr. Perez (1) tenga mucha demanda.
INSERT INTO Citas (id_medico, id_paciente, fecha, costo) VALUES 
    -- Enero
    (1, 100, '2024-01-10', 150.00), -- Juan visita Cardiología
    (2, 103, '2024-01-11', 100.00), -- Ana (niña) visita Pediatría
    (1, 102, '2024-01-12', 150.00),
    (3, 101, '2024-01-15', 200.00), -- Maria visita Ginecología
    (5, 104, '2024-01-16', 80.00),
    (4, 105, '2024-01-18', 120.00),
    (1, 106, '2024-01-20', 150.00),
    
    -- Febrero (Retornos y nuevos pacientes)
    (1, 100, '2024-02-05', 150.00), -- Juan REGRESA a Cardiología (2da visita)
    (3, 101, '2024-02-10', 200.00), -- Maria REGRESA a Ginecología (2da visita)
    (7, 107, '2024-02-12', 100.00), -- Sofia visita Pediatría en Miraflores
    (6, 108, '2024-02-15', 180.00),
    (5, 109, '2024-02-20', 80.00),
    
    -- Marzo (Más retornos para el Window Function)
    (5, 100, '2024-03-01', 80.00),  -- Juan va a Medicina General (3ra visita total)
    (4, 101, '2024-03-05', 120.00), -- Maria va a Dermatología (3ra visita total)
    (2, 103, '2024-03-10', 100.00), -- Ana regresa al pediatra
    (1, 104, '2024-03-15', 150.00),
    (6, 102, '2024-03-20', 180.00);


-- Consulta de citas
SELECT * FROM Citas


-- CONSULTA 1: EL JOIN CLÁSICO
-- Pregunta: "Dame una lista de citas con el nombre del médico y del paciente."
-- Demuestra: Uso de INNER JOIN para cruzar 3 tablas.
SELECT 
    C.fecha,
    M.nombre AS Doctor,
    M.especialidad,
    P.nombre AS Paciente
FROM Citas C
INNER JOIN Medicos M ON C.id_medico = M.id_medico
INNER JOIN Pacientes P ON C.id_paciente = P.id_paciente
ORDER BY C.fecha DESC;


-- CONSULTA 2: AGREGACIONES Y GROUP BY
-- Pregunta: "¿Qué médico ha generado más ingresos para la clínica?"
-- Demuestra: SUM, GROUP BY y ORDER BY (Esencial para dashboards).
SELECT 
    M.nombre,
    COUNT(C.id_cita) as Total_Citas,
    SUM(C.costo) as Ingresos_Totales
FROM Medicos M
JOIN Citas C ON M.id_medico = C.id_medico
GROUP BY M.nombre
ORDER BY Ingresos_Totales DESC;


-- CONSULTA 3: WINDOW FUNCTIONS (EL "PLUS" DE LA OFERTA)
-- Pregunta: "Enumera las citas de cada paciente ordenadas por fecha."
-- Demuestra: ROW_NUMBER().
-- Significa: "Créame un ranking (row_number) reiniciando la cuenta (partition) por cada paciente".
SELECT 
    P.nombre AS Paciente,
    C.fecha,
    M.especialidad,
    ROW_NUMBER() OVER(PARTITION BY P.id_paciente ORDER BY C.fecha) as Nro_Visita
FROM Citas C
JOIN Pacientes P ON C.id_paciente = P.id_paciente
JOIN Medicos M ON C.id_medico = M.id_medico;