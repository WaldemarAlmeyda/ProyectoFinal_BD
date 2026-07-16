/*==============================================================
 REPORTE 1: INCIDENTES POR TIPO DE DELITO
 Descripción:
 Muestra la cantidad de incidentes registrados por cada tipo de
 delito, ordenados de mayor a menor frecuencia.
==============================================================*/

USE SistemaDelitosPatrimonioIca;
GO

SELECT
    TD.nombre AS Tipo_Delito,
    COUNT(I.id_incidente) AS Total_Incidentes
FROM Tipo_Delito TD
INNER JOIN Incidente I
    ON TD.id_tipo_delito = I.id_tipo_delito
GROUP BY TD.nombre
ORDER BY Total_Incidentes DESC;
GO


/*==============================================================
 REPORTE 2: INCIDENTES POR DISTRITO
 Descripción:
 Muestra la cantidad de incidentes registrados por distrito,
 ordenados de mayor a menor.
==============================================================*/

USE SistemaDelitosPatrimonioIca;
GO

SELECT
    U.distrito,
    COUNT(I.id_incidente) AS Total
FROM Ubicacion U
INNER JOIN Incidente I
    ON U.id_ubicacion = I.id_ubicacion
GROUP BY U.distrito
ORDER BY Total DESC;
GO


/*==============================================================
 REPORTE 3: INCIDENTES SEGÚN ESTADO
 Descripción:
 Muestra la cantidad de incidentes agrupados por estado.
==============================================================*/

USE SistemaDelitosPatrimonioIca;
GO

SELECT
    E.nombre_estado,
    COUNT(I.id_incidente) AS Total
FROM Estado_Incidente E
INNER JOIN Incidente I
    ON E.id_estado = I.id_estado
GROUP BY E.nombre_estado;
GO


/*==============================================================
 REPORTE 4: CONTROL DE EVIDENCIAS REGISTRADAS
 Descripción:
 Lista todas las evidencias registradas junto con el incidente
 al que pertenecen.
==============================================================*/

USE SistemaDelitosPatrimonioIca;
GO

SELECT
    E.id_evidencia,
    TE.nombre,
    E.descripcion,
    E.ruta_archivo
FROM Evidencia E
INNER JOIN Evidencia_Tipo TE
    ON E.id_tipo_evidencia = TE.id_tipo_evidencia;
GO


/*==============================================================
 REPORTE 5: SEGUIMIENTOS REALIZADOS
 Descripción:
 Muestra el historial de seguimientos realizados para cada
 incidente, indicando la autoridad responsable y el estado.
==============================================================*/

USE SistemaDelitosPatrimonioIca;
GO

SELECT
    S.fecha_hora,
    A.nombre + ' ' + A.apellidos AS Autoridad,
    S.accion,
    E.nombre_estado
FROM Seguimiento S
INNER JOIN Autoridad A
    ON S.id_autoridad = A.id_autoridad
INNER JOIN Incidente I
    ON S.id_incidente = I.id_incidente
INNER JOIN Estado_Incidente E
    ON I.id_estado = E.id_estado;
GO

