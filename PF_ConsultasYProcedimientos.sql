USE SistemaDelitosPatrimonioIca;
GO

/* LISTADO GENERAL DE CIUDADANOS */
SELECT * FROM Ciudadano;

/* BUSQUEDA SIMPLE POR DNI */
SELECT * FROM Ciudadano
WHERE dni = '45123456'

/* BUSCAR AL CIUDADANO POR SU ESTADO ACTIVO */
SELECT * FROM Ciudadano
WHERE estado = '1';

/* INSIDENTES REGISTRADOS */
SELECT * FROM Incidente;

/* MOSTRAR LOS INCIDENTES CON CADA TIPO DE DELITO */
SELECT I.id_incidente,
TD.nombre AS TipoDelito,
I.fecha_ocurrencia,
I.descripcion
FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito = TD.id_tipo_delito;

/* MOSTRAR LOS INCIDENTES CON LA UBICACIÓN Y ESTADO */
SELECT
I.id_incidente,
TD.nombre AS Delito,
U.distrito,
U.direccion,
EI.nombre_estado
FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito = TD.id_tipo_delito INNER JOIN Ubicacion U
ON I.id_ubicacion = U.id_ubicacion INNER JOIN Estado_Incidente EI
ON I.id_estado = EI.id_estado;

/* CONSULTA COMPLETA */
SELECT
I.id_incidente,
TD.nombre AS Delito,
C.nombres + ' ' + C.apellidos AS Ciudadano,
U.distrito,
EI.nombre_estado
FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito = TD.id_tipo_delito INNER JOIN Ciudadano_Incidente CI
ON I.id_incidente = CI.id_incidente INNER JOIN Ciudadano C
ON CI.id_ciudadano = C.id_ciudadano INNER JOIN Ubicacion U
ON I.id_ubicacion = U.id_ubicacion INNER JOIN Estado_Incidente EI
ON I.id_estado = EI.id_estado;

/* TOTAL DE INCIDENTES POR DELITO */
SELECT TD.nombre,
COUNT(*) AS TotalIncidentes
FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito = TD.id_tipo_delito
GROUP BY TD.nombre;

/* CONTEO DE INCIDENTES POR DISTRITO */
SELECT U.distrito,
COUNT(*) AS Total
FROM Incidente I INNER JOIN Ubicacion U
ON I.id_ubicacion = U.id_ubicacion
GROUP BY U.distrito;

/* AGRUPACIONES POR ESTADO */
SELECT EI.nombre_estado,
COUNT(*) AS Cantidad
FROM Incidente I INNER JOIN Estado_Incidente EI
ON I.id_estado = EI.id_estado
GROUP BY EI.nombre_estado;

/* FILTRAR DELITOS CON MÁS DE 2 INCIDENTES */
SELECT TD.nombre,
COUNT(*) AS Total
FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito = TD.id_tipo_delito
GROUP BY TD.nombre
HAVING COUNT(*) > 2;

/* INCIDENTES DEL DELITO MAS REGISTRADO */
SELECT * FROM Incidente
WHERE id_tipo_delito =
(
SELECT TOP 1 id_tipo_delito FROM Incidente
GROUP BY id_tipo_delito
ORDER BY COUNT(*) DESC
);

/* CIUDADANOS QUE TIENE INCIDENTES REGISTRADOS */
SELECT * FROM Ciudadano
WHERE id_ciudadano IN
(
SELECT id_ciudadano FROM Ciudadano_Incidente
);

/* VALIDACIÓN DE CIUDADANOS SIN INCIDENTES */
SELECT * FROM Ciudadano
WHERE id_ciudadano NOT IN
(
SELECT id_ciudadano FROM Ciudadano_Incidente
);

/* LISTAR CIUDADANOS */
GO
CREATE PROCEDURE sp_ListarCiudadanos
AS
BEGIN
    SELECT * FROM Ciudadano;
END;
GO

EXEC sp_ListarCiudadanos

/* BUSCAR AL CIUDADANO POR EL DNI */
GO
CREATE PROCEDURE sp_BuscarCiudadano
@dni CHAR(8)
AS
BEGIN
    SELECT * FROM Ciudadano
    WHERE dni=@dni;
END;
GO

EXEC sp_BuscarCiudadano @dni = '40112233'

/* FILTRAR CIUDADANOS ACTIVOS */
GO
CREATE PROCEDURE sp_CiudadanosActivos
AS
BEGIN
    SELECT * FROM Ciudadano
    WHERE estado=1;
END;
GO

EXEC sp_CiudadanosActivos

/* REGISTRAR NUEVOS CIUDADANOS */
GO
CREATE PROCEDURE sp_InsertarCiudadano
@dni CHAR(8),
@nombres VARCHAR(100),
@apellidos VARCHAR(100),
@telefono VARCHAR(15),
@direccion VARCHAR(200),
@correo VARCHAR(100)
AS
BEGIN
INSERT INTO Ciudadano
(
dni,
nombres,
apellidos,
telefono,
direccion,
correo
)
VALUES
(
@dni,
@nombres,
@apellidos,
@telefono,
@direccion,
@correo
);
END;
GO
EXEC sp_InsertarCiudadano 
    '63643744', 
    'Juan Carlos', 
    'Pérez Quispe', 
    '987654321', 
    'Av. Larco 123, Miraflores', 
    'juan.perez@email.com';

/* ACTUALIZAR TELEFONO Y CORREO DE CUALQUIER CIUDADANO */
GO
CREATE PROCEDURE sp_ActualizarCiudadano
@id INT,
@telefono VARCHAR(15),
@correo VARCHAR(100)
AS
BEGIN

UPDATE Ciudadano
SET telefono=@telefono,
    correo=@correo
WHERE id_ciudadano=@id;

END;
GO

EXEC sp_ActualizarCiudadano
    @id = 35, 
    @telefono = '966327372', 
    @correo = 'emilio.actualizado@email.com';

/* ELIMINACION DE CUALQUIER CIUDADANO */
GO
CREATE PROCEDURE sp_EliminarCiudadano
@id INT
AS
BEGIN
DELETE FROM Ciudadano
WHERE id_ciudadano=@id;
END;
GO

SELECT * FROM Ciudadano

EXEC sp_EliminarCiudadano @id = 35

/* DESACTIVACION DEL ESTADO DE CAULQUIER CIUDADANO */
GO
CREATE PROCEDURE sp_DesactivarCiudadano
@id INT
AS
BEGIN

UPDATE Ciudadano
SET estado=0
WHERE id_ciudadano=@id;

END;
GO

SELECT * FROM Ciudadano
EXEC sp_DesactivarCiudadano @id = 3

/* BUSCAR CIUDADANOS */
GO
CREATE PROCEDURE sp_BusquedaCiudadano
@nombre VARCHAR(100)=NULL
AS
BEGIN

SELECT * FROM Ciudadano
WHERE @nombre IS NULL
OR nombres LIKE '%'+@nombre+'%';

END;
GO

EXEC sp_BusquedaCiudadano 'Ana'

/* REGISTRAR NUEVOS CIUDADANOS */
GO
CREATE PROCEDURE sp_RegistrarCiudadanoValidado
@dni CHAR(8),
@nombres VARCHAR(100),
@apellidos VARCHAR(100)
AS
BEGIN

IF EXISTS
(
SELECT * FROM Ciudadano
WHERE dni=@dni
)
BEGIN
    PRINT 'El DNI ya existe';
END
ELSE
BEGIN

INSERT INTO Ciudadano(dni,nombres,apellidos)
VALUES(@dni,@nombres,@apellidos);

END

END;
GO

EXEC sp_RegistrarCiudadanoValidado 
    '5646454',
    'Ana Marcela',
    'Lamena Aspas';

/* REPORTAR NUEVOS INCIDENTES */
GO
CREATE PROCEDURE sp_ReporteIncidentes
AS
BEGIN

SELECT
TD.nombre AS Delito,
COUNT(*) AS Total FROM Incidente I INNER JOIN Tipo_Delito TD
ON I.id_tipo_delito=TD.id_tipo_delito
GROUP BY TD.nombre;

END;
GO

EXEC sp_ReporteIncidentes 

/* INSERTAR NUEVOS DELITOS */
GO
CREATE PROCEDURE sp_InsertarTipoDelito
@nombre VARCHAR(80),
@descripcion VARCHAR(250)
AS
BEGIN

BEGIN TRY

INSERT INTO Tipo_Delito(nombre,descripcion)
VALUES(@nombre,@descripcion);

END TRY

BEGIN CATCH

SELECT ERROR_MESSAGE() AS Error;

END CATCH

END;
GO
SELECT * FROM Tipo_Delito
EXEC sp_InsertarTipoDelito
    @nombre = 'Estafa', 
    @descripcion = 'Engaño económico para obtener un beneficio ilícito.';

/* REGISTRAR NUEVOS INCIDENTES */
GO
CREATE PROCEDURE sp_RegistrarIncidente
@fecha DATE,
@hora TIME,
@descripcion VARCHAR(500),
@tipo INT,
@ubicacion INT,
@estado INT
AS
BEGIN

BEGIN TRY

BEGIN TRANSACTION;

INSERT INTO Incidente
(
fecha_ocurrencia,
hora_ocurrencia,
descripcion,
id_tipo_delito,
id_ubicacion,
id_estado
)

VALUES
(
@fecha,
@hora,
@descripcion,
@tipo,
@ubicacion,
@estado
);

COMMIT TRANSACTION;

END TRY

BEGIN CATCH

ROLLBACK TRANSACTION;

SELECT ERROR_MESSAGE() AS Error;

END CATCH

END;
GO

SELECT * FROM Incidente
EXEC sp_RegistrarIncidente
    @fecha = '2026-07-14',                    -- Formato YYYY-MM-DD
    @hora = '01:05:00',                       -- Formato HH:MM:SS
    @descripcion = 'Robo de celular en transporte público con réplica de arma.', 
    @tipo = 1,                                -- ID numérico existente en Tipo_Delito
    @ubicacion = 3,                           -- ID numérico existente en tu tabla Ubicacion
    @estado = 1;