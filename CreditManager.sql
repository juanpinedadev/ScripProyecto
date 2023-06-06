CREATE DATABASE CreditManager
GO

USE CreditManager
GO

---------------------------------------------------------------------------------------------------
-- Tablas
---------------------------------------------------------------------------------------------------

CREATE TABLE TiposDocumento (
    IdTipoDocumento INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE Roles (
    IdRol INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE ModulosAcceso (
    IdModuloAcceso INT PRIMARY KEY IDENTITY(1,1),
    IdRol INT FOREIGN KEY REFERENCES Roles(IdRol),
    Nombre VARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE Cargos (
    IdCargo INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE Personas (
    IdPersona INT PRIMARY KEY IDENTITY(1,1),
    IdTipoDocumento INT FOREIGN KEY REFERENCES TiposDocumento(IdTipoDocumento),
    PrimerNombre VARCHAR(15) NOT NULL,
    SegundoNombre VARCHAR(15),
    PrimerApellido VARCHAR(15) NOT NULL,
    SegundoApellido VARCHAR(15),
    NumeroDocumento VARCHAR(15) NOT NULL,
    CorreoElectronico VARCHAR(100),
    Telefono VARCHAR(10),
	Direccion VARCHAR(255) NOT NULL,
    FechaCreacion DATE DEFAULT GETDATE()
);
GO

CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY IDENTITY(1,1),
    IdPersona INT FOREIGN KEY REFERENCES Personas(IdPersona),
    IdRol INT FOREIGN KEY REFERENCES Roles(IdRol),
    Nombre VARCHAR(50) NOT NULL,
    Contraseña VARCHAR(255) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL,
    FechaCreacion DATE DEFAULT GETDATE()
);
GO

CREATE TABLE Empleados (
    IdEmpleado INT PRIMARY KEY IDENTITY(1,1),
    IdPersona INT FOREIGN KEY REFERENCES Personas(IdPersona),
    IdCargo INT FOREIGN KEY REFERENCES Cargos(IdCargo),
    Estado BIT DEFAULT 1 NOT NULL,
    FechaCreacion DATE DEFAULT GETDATE()
);
GO

CREATE TABLE Clientes (
    IdCliente INT PRIMARY KEY IDENTITY(1,1),
    IdPersona INT FOREIGN KEY REFERENCES Personas(IdPersona),
    Estado BIT DEFAULT 1 NOT NULL,
    FechaCreacion DATE DEFAULT GETDATE()
);
GO

CREATE TABLE FrecuenciasPago (
    IdFrecuenciaPago INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE Prestamos (
    IdPrestamo INT PRIMARY KEY IDENTITY(1,1),
    IdFrecuenciaPago INT FOREIGN KEY REFERENCES FrecuenciasPago(IdFrecuenciaPago),
    IdCliente INT FOREIGN KEY REFERENCES Clientes(IdCliente),
	IdEmpleado INT FOREIGN KEY REFERENCES Empleados(IdEmpleado),
	TasaInteres DECIMAL(5, 2) NOT NULL,
    MontoSolicitado DECIMAL(12, 2) NOT NULL,
    TotalIntereses DECIMAL(12, 2) NOT NULL,
    TotalPagar DECIMAL(12, 2) NOT NULL,
	NumeroCuotas INT NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo',
    FechaPrestamo DATE DEFAULT GETDATE(),
    FechaVencimiento DATE,
);
GO

CREATE TABLE Cuotas (
    IdCuota INT PRIMARY KEY IDENTITY(1,1),
    IdPrestamo INT FOREIGN KEY REFERENCES Prestamos(IdPrestamo),
    MontoCuota DECIMAL(12, 2) NOT NULL,
    FechaVencimiento DATE NOT NULL,
    EstadoCuota VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    FechaPago DATE,
    Pagada BIT DEFAULT 0
);
GO

CREATE TABLE Pagos (
    IdPago INT PRIMARY KEY IDENTITY(1,1),
    IdCuota INT FOREIGN KEY REFERENCES Cuotas(IdCuota),
    Monto DECIMAL(12, 2) NOT NULL,
    FechaPago DATE NOT NULL
);
GO

CREATE TABLE HistorialPrestamos (
    IdHistorialPrestamo INT PRIMARY KEY IDENTITY(1,1),
    IdPrestamo INT FOREIGN KEY REFERENCES Prestamos(IdPrestamo),
    FechaInicio DATE NOT NULL,
    FechaFin DATE,
    EstadoPrestamo VARCHAR(20) NOT NULL
);
GO

CREATE TABLE HistorialPagos (
    IdHistorialPago INT PRIMARY KEY IDENTITY(1,1),
    IdPago INT FOREIGN KEY REFERENCES Pagos(IdPago),
    IdCuota INT FOREIGN KEY REFERENCES Cuotas(IdCuota),
    Monto DECIMAL(12, 2) NOT NULL,
    FechaPago DATE NOT NULL,
    EstadoPrestamo VARCHAR(20) NOT NULL,
    EstadoPago VARCHAR(20) NOT NULL
);
GO

---------------------------------------------------------------------------------------------------
-- Vistas
---------------------------------------------------------------------------------------------------

CREATE VIEW VistaTiposDocumentoActivos
AS
SELECT IdTipoDocumento, Nombre, Estado
FROM TiposDocumento
WHERE Estado = 1;
GO

CREATE VIEW VistaRolesActivos
AS
SELECT IdRol, Nombre, Estado
FROM Roles
WHERE Estado = 1;
GO

CREATE VIEW VistaFrecuenciasPagosActivos
AS
SELECT IdFrecuenciaPago, Nombre, Estado
FROM FrecuenciasPago
WHERE Estado = 1;
GO

CREATE VIEW VistaCargosActivos
AS
SELECT IdCargo, Nombre, Estado
FROM Cargos
WHERE Estado = 1;
GO

CREATE VIEW VistaUsuariosActivos
AS
SELECT P.IdPersona, P.IdTipoDocumento, TD.Nombre AS TipoDocumento, P.PrimerNombre, P.SegundoNombre, P.PrimerApellido, P.SegundoApellido,
       P.NumeroDocumento, P.CorreoElectronico, P.Telefono, P.Direccion, P.FechaCreacion AS FechaCreacionPersona,
       U.IdUsuario, U.IdRol, R.Nombre AS Rol, U.Nombre AS NombreUsuario, U.Contraseña, U.Estado, U.FechaCreacion AS FechaCreacionUsuario
FROM Personas P
INNER JOIN TiposDocumento TD ON P.IdTipoDocumento = TD.IdTipoDocumento
INNER JOIN Usuarios U ON P.IdPersona = U.IdPersona
INNER JOIN Roles R ON U.IdRol = R.IdRol WHERE U.Estado = 1;
GO

CREATE VIEW VistaEmpleadosActivos
AS
SELECT P.IdPersona, P.IdTipoDocumento, TD.Nombre AS TipoDocumento, P.PrimerNombre, P.SegundoNombre, P.PrimerApellido, P.SegundoApellido,
       P.NumeroDocumento, P.CorreoElectronico, P.Telefono, P.Direccion, P.FechaCreacion AS FechaCreacionPersona,
       E.IdEmpleado, E.IdCargo, C.Nombre AS Cargo, E.Estado, E.FechaCreacion AS FechaCreacionEmpleado
FROM Personas P
INNER JOIN TiposDocumento TD ON P.IdTipoDocumento = TD.IdTipoDocumento
INNER JOIN Empleados E ON P.IdPersona = E.IdPersona
INNER JOIN Cargos C ON E.IdCargo = C.IdCargo WHERE E.Estado = 1;
GO

CREATE VIEW VistaClientesActivos
AS
SELECT p.IdPersona, c.IdCliente, td.IdTipoDocumento, td.Nombre AS TipoDocumento, p.PrimerNombre, p.SegundoNombre, p.PrimerApellido,
p.SegundoApellido, p.NumeroDocumento, p.CorreoElectronico, p.Telefono, P.Direccion, c.Estado
FROM Personas p
INNER JOIN Clientes c ON c.IdPersona = p.IdPersona
INNER JOIN TiposDocumento td ON td.IdTipoDocumento = p.IdTipoDocumento
WHERE c.Estado = 1;
GO

CREATE VIEW VistaPrestamosActivos
AS
SELECT *
FROM Prestamos
WHERE Estado = 'Activo';
GO

CREATE VIEW VistaPagosPorCuota
AS
SELECT P.IdPago, P.IdCuota, C.IdPrestamo, P.Monto, P.FechaPago
FROM Pagos P
JOIN Cuotas C ON P.IdCuota = C.IdCuota;
GO
---------------------------------------------------------------------------------------------------
-- Funciones
---------------------------------------------------------------------------------------------------

CREATE FUNCTION ObtenerModulosUsuarioActivos (@IdUsuario INT)
RETURNS TABLE
AS
RETURN
(
    SELECT m.IdRol, m.Nombre
    FROM ModulosAcceso m
    INNER JOIN Roles r ON r.IdRol = m.IdRol
    INNER JOIN Usuarios u ON u.IdRol = r.IdRol
    WHERE u.IdUsuario = @IdUsuario AND m.Estado = 1
);
GO

---------------------------------------------------------------------------------------------------
-- Registros obligatorios
---------------------------------------------------------------------------------------------------
-- Tipo de documentos
INSERT INTO TiposDocumento (Nombre, Estado) VALUES ('Cédula de Ciudadanía', 1);
INSERT INTO TiposDocumento (Nombre, Estado) VALUES ('Cédula de Extranjería', 1);
GO

-- Frecuencias de pago
INSERT INTO FrecuenciasPago (Nombre, Estado) VALUES ('Diario', 1);
INSERT INTO FrecuenciasPago (Nombre, Estado) VALUES ('Semanal', 1);
INSERT INTO FrecuenciasPago(Nombre, Estado) VALUES ('Quincenal', 1);
GO

-- Roles de usuario
INSERT INTO Roles (Nombre, Estado) VALUES ('Administrador', 1);
INSERT INTO Roles (Nombre, Estado) VALUES ('Basico', 1);
GO

-- Cargos de empleados
INSERT INTO Cargos (Nombre, Estado) VALUES ('Supervisor', 1);
INSERT INTO Cargos (Nombre, Estado) VALUES ('Cobrador', 1);
GO

-- Modulos de accesos relacionados a los roles
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'inicio', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'prestamos', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'pagos', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'clientes', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'empleados', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'usuarios', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (1, 'reportes', 1);

INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (2, 'inicio', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (2, 'pagos', 1);
INSERT INTO ModulosAcceso (IdRol, Nombre, Estado) VALUES (2, 'clientes', 1);
GO

INSERT INTO Personas (IdTipoDocumento,PrimerNombre,SegundoNombre, PrimerApellido,SegundoApellido,NumeroDocumento,CorreoElectronico,Telefono,Direccion) 
			  VALUES (1,'Juan','Esteban','Pineda','Carmona','1003315522','Juanpi2009@gmail.com','3003646099','Calle 5 # 45-21');

INSERT INTO Usuarios (IdPersona,IdRol,Nombre,Contraseña) VALUES (1,1,'admin','8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918');

UPDATE Usuarios
SET Contraseña = '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'
WHERE IdPersona = 1;

SELECT * FROM Usuarios;

---------------------------------------------------------------------------------------------------
-- Procemidientos
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE ObtenerCuotaDelDia
    @IdPrestamo INT
AS
BEGIN
    SELECT IdCuota, IdPrestamo, MontoCuota, FechaVencimiento, EstadoCuota, FechaPago, Pagada
    FROM Cuotas
    WHERE (FechaVencimiento = CONVERT(date, GETDATE()) OR EstadoCuota = 'Atrasada')
        AND (IdPrestamo = @IdPrestamo OR @IdPrestamo IS NULL)
        AND Pagada = 0;
END;
GO

-- Procedimientos de usuarios
CREATE PROCEDURE CrearUsuario
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdRol INT,
	@IdTipoDocumento INT,
    @Nombre VARCHAR(50),
    @Contraseña VARCHAR(255),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable para almacenar el IdPersona generado
    DECLARE @IdPersona INT;

    -- Verificar si el usuario ya existe
    IF EXISTS (SELECT * FROM Usuarios WHERE Nombre = @Nombre)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'Este usuario ya se encuentra registrado.';
        RETURN;
    END;

    BEGIN TRY
        -- Insertar en la tabla Personas
        INSERT INTO Personas (PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, NumeroDocumento, IdTipoDocumento, CorreoElectronico, Telefono, Direccion)
        VALUES (@PrimerNombre, @SegundoNombre, @PrimerApellido, @SegundoApellido, @NumeroDocumento,@IdTipoDocumento, @CorreoElectronico, @Telefono, @Direccion);

        -- Obtener el IdPersona insertado
        SET @IdPersona = SCOPE_IDENTITY();

        -- Insertar en la tabla Usuarios
        INSERT INTO Usuarios (IdPersona, IdRol, Nombre, Contraseña)
        VALUES (@IdPersona, @IdRol, @Nombre, @Contraseña);

        -- Obtener el IdUsuario generado
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Usuario creado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al crear el usuario. Por favor, inténtelo nuevamente.';
    END CATCH;
END;
GO

CREATE PROCEDURE EliminarUsuario
    @IdUsuario INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET @Resultado = 0

    -- Verificar si el usuario existe
    IF EXISTS (SELECT * FROM Usuarios WHERE IdUsuario = @IdUsuario)
    BEGIN
        -- Actualizar el estado del usuario a 0
        UPDATE Usuarios SET Estado = 0 WHERE IdUsuario = @IdUsuario
        SET @Resultado = 1
        SET @Mensaje = 'El usuario ha sido eliminado correctamente.'
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El usuario no existe.'
    END
END
GO

CREATE PROCEDURE ActualizarUsuario
(
    @IdUsuario INT,
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdTipoDocumento INT,
    @NombreUsuario VARCHAR(50),
    @Clave VARCHAR(255),
    @IdRol INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si la cédula ya existe para otro usuario
        IF EXISTS (SELECT * FROM Personas WHERE NumeroDocumento = @NumeroDocumento AND IdPersona <> @IdUsuario)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'Ya existe una persona con la misma cédula para otro usuario.';
        END
        ELSE
        BEGIN
            -- Actualizar los datos de la persona
            UPDATE Personas
            SET PrimerNombre = @PrimerNombre,
                SegundoNombre = @SegundoNombre,
                PrimerApellido = @PrimerApellido,
                SegundoApellido = @SegundoApellido,
                NumeroDocumento = @NumeroDocumento,
                CorreoElectronico = @CorreoElectronico,
                Telefono = @Telefono,
				Direccion = @Direccion,
                IdTipoDocumento = @IdTipoDocumento
            WHERE IdPersona = (SELECT IdPersona FROM Usuarios WHERE IdUsuario = @IdUsuario);

            -- Actualizar los datos del usuario
            UPDATE Usuarios
            SET Nombre = @NombreUsuario,
                Contraseña = @Clave,
                IdRol = @IdRol
            WHERE IdUsuario = @IdUsuario;

            SET @Resultado = 1;
            SET @Mensaje = 'Usuario actualizado correctamente.';
        END;
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Procedimientos de empleados
CREATE PROCEDURE CrearEmpleado
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdCargo INT,
    @IdTipoDocumento INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable para almacenar el IdPersona generado
    DECLARE @IdPersona INT;

    -- Verificar si el empleado ya existe por el número de documento
    IF EXISTS (SELECT * FROM Personas WHERE NumeroDocumento = @NumeroDocumento)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'Este empleado ya se encuentra registrado.';
        RETURN;
    END;

    BEGIN TRY
        -- Insertar en la tabla Personas
        INSERT INTO Personas (PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, NumeroDocumento, IdTipoDocumento, CorreoElectronico, Telefono, Direccion)
        VALUES (@PrimerNombre, @SegundoNombre, @PrimerApellido, @SegundoApellido, @NumeroDocumento, @IdTipoDocumento, @CorreoElectronico, @Telefono, @Direccion);

        -- Obtener el IdPersona insertado
        SET @IdPersona = SCOPE_IDENTITY();

        -- Insertar en la tabla Empleados
        INSERT INTO Empleados (IdPersona, IdCargo)
        VALUES (@IdPersona, @IdCargo);

        -- Obtener el IdEmpleado generado
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Empleado creado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al crear el empleado. Por favor, inténtelo nuevamente.';
    END CATCH;
END;
GO

CREATE PROCEDURE EliminarEmpleado
    @IdEmpleado INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET @Resultado = 0

    -- Verificar si el empleado existe
    IF EXISTS (SELECT * FROM Empleados WHERE IdEmpleado = @IdEmpleado)
    BEGIN
        -- Actualizar el estado del usuario a 0
        UPDATE Empleados SET Estado = 0 WHERE IdEmpleado = @IdEmpleado
        SET @Resultado = 1
        SET @Mensaje = 'El empleado ha sido eliminado correctamente.'
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El empleado no existe.'
    END
END
GO

CREATE PROCEDURE ActualizarEmpleado
(
    @IdEmpleado INT,
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdTipoDocumento INT,
    @IdCargo INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si la cédula ya existe para otro usuario
        IF EXISTS (SELECT * FROM Personas WHERE NumeroDocumento = @NumeroDocumento AND IdPersona <> @IdEmpleado)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'Ya existe una persona con la misma cédula para otro empleado.';
        END
        ELSE
        BEGIN
            -- Actualizar los datos de la persona
            UPDATE Personas
            SET PrimerNombre = @PrimerNombre,
                SegundoNombre = @SegundoNombre,
                PrimerApellido = @PrimerApellido,
                SegundoApellido = @SegundoApellido,
                NumeroDocumento = @NumeroDocumento,
                CorreoElectronico = @CorreoElectronico,
                Telefono = @Telefono,
				Direccion = @Direccion,
                IdTipoDocumento = @IdTipoDocumento
            WHERE IdPersona = (SELECT IdPersona FROM Empleados WHERE IdEmpleado = @IdEmpleado);

            -- Actualizar los datos del empleado
            UPDATE Empleados
            SET IdCargo = @IdCargo
            WHERE IdEmpleado = @IdEmpleado;

            SET @Resultado = 1;
            SET @Mensaje = 'Empleado actualizado correctamente.';
        END;
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Procedimientos de clientes
CREATE PROCEDURE CrearCliente
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdTipoDocumento INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable para almacenar el IdPersona generado
    DECLARE @IdPersona INT;

    -- Verificar si el cliente ya existe por el número de documento
    IF EXISTS (SELECT * FROM Personas WHERE NumeroDocumento = @NumeroDocumento)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'Este cliente ya se encuentra registrado.';
        RETURN;
    END;

    BEGIN TRY
        -- Insertar en la tabla Personas
        INSERT INTO Personas (PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, NumeroDocumento, IdTipoDocumento, CorreoElectronico, Telefono, Direccion)
        VALUES (@PrimerNombre, @SegundoNombre, @PrimerApellido, @SegundoApellido, @NumeroDocumento, @IdTipoDocumento, @CorreoElectronico, @Telefono, @Direccion);

        -- Obtener el IdPersona insertado
        SET @IdPersona = SCOPE_IDENTITY();

        -- Insertar en la tabla Clientes
        INSERT INTO Clientes (IdPersona)
        VALUES (@IdPersona);

        -- Obtener el IdEmpleado generado
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Cliente creado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = 'Error al crear el cliente. Por favor, inténtelo nuevamente.';
    END CATCH;
END;
GO

CREATE PROCEDURE EliminarCliente
    @IdCliente INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET @Resultado = 0

    -- Verificar si el empleado existe
    IF EXISTS (SELECT * FROM Clientes WHERE IdCliente = @IdCliente)
    BEGIN
        -- Actualizar el estado del usuario a 0
        UPDATE Clientes SET Estado = 0 WHERE IdCliente = @IdCliente
        SET @Resultado = 1
        SET @Mensaje = 'El cliente ha sido eliminado correctamente.'
    END
    ELSE
    BEGIN
        SET @Mensaje = 'El cliente no existe.'
    END
END
GO

CREATE PROCEDURE ActualizarCliente
(
    @IdCliente INT,
    @PrimerNombre VARCHAR(15),
    @SegundoNombre VARCHAR(15),
    @PrimerApellido VARCHAR(15),
    @SegundoApellido VARCHAR(15),
    @NumeroDocumento VARCHAR(15),
    @CorreoElectronico VARCHAR(100),
    @Telefono VARCHAR(10),
	@Direccion VARCHAR(255),
    @IdTipoDocumento INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si la cédula ya existe para otro usuario
        IF EXISTS (SELECT * FROM Personas WHERE NumeroDocumento = @NumeroDocumento AND IdPersona <> @IdCliente)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'Ya existe una persona con la misma cédula para otro cliente.';
        END
        ELSE
        BEGIN
            -- Actualizar los datos de la persona
            UPDATE Personas
            SET PrimerNombre = @PrimerNombre,
                SegundoNombre = @SegundoNombre,
                PrimerApellido = @PrimerApellido,
                SegundoApellido = @SegundoApellido,
                NumeroDocumento = @NumeroDocumento,
                CorreoElectronico = @CorreoElectronico,
                Telefono = @Telefono,
				Direccion = @Direccion,
                IdTipoDocumento = @IdTipoDocumento
            WHERE IdPersona = (SELECT IdPersona FROM Clientes WHERE IdCliente = @IdCliente);

            SET @Resultado = 1;
            SET @Mensaje = 'Cliente actualizado correctamente.';
        END;
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE PROCEDURE InsertarPrestamoConCuotas
    @IdCliente INT,
    @IdEmpleado INT,
    @IdFrecuenciaPago INT,
    @Monto DECIMAL(12, 2),
    @NumeroCuotas INT,
    @TasaInteres DECIMAL(5, 2),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    -- Declarar variables
    DECLARE @IdPrestamo INT, @FechaVencimiento DATE;
    DECLARE @MontoSolicitado DECIMAL(12, 2), @TotalIntereses DECIMAL(12, 2), @TotalPagar DECIMAL(12, 2);
    DECLARE @DiasFrecuencia INT;
    
    -- Obtener los días de la frecuencia de pago
    SELECT @DiasFrecuencia = CASE
                                WHEN Nombre = 'Diario' THEN 1
                                WHEN Nombre = 'Semanal' THEN 7
                                WHEN Nombre = 'Quincenal' THEN 15
                                ELSE 30 -- Mensual por defecto
                            END
    FROM FrecuenciasPago
    WHERE IdFrecuenciaPago = @IdFrecuenciaPago;
    
    -- Calcular los valores
    SET @MontoSolicitado = @Monto;
    SET @TotalIntereses = (@MontoSolicitado * @TasaInteres) / 100;
    SET @TotalPagar = @MontoSolicitado + @TotalIntereses;
    
    -- Insertar registro en la tabla Prestamos
    INSERT INTO Prestamos (IdFrecuenciaPago, IdCliente, IdEmpleado, MontoSolicitado, TotalIntereses, TotalPagar, NumeroCuotas, TasaInteres, Estado, FechaPrestamo, FechaVencimiento)
    VALUES (@IdFrecuenciaPago, @IdCliente, @IdEmpleado, @MontoSolicitado, @TotalIntereses, @TotalPagar, @NumeroCuotas, @TasaInteres, 'Activo', GETDATE(), @FechaVencimiento);
    
    -- Obtener el IdPrestamo del registro insertado
    SET @IdPrestamo = SCOPE_IDENTITY();
    
    -- Generar las cuotas
    DECLARE @CuotaInicial DECIMAL(12, 2), @FechaInicio DATE;
    SET @CuotaInicial = @TotalPagar / @NumeroCuotas;
    SET @FechaInicio = GETDATE();
    
    WHILE @NumeroCuotas > 0
    BEGIN
        INSERT INTO Cuotas (IdPrestamo, MontoCuota, FechaVencimiento, EstadoCuota)
        VALUES (@IdPrestamo, @CuotaInicial, @FechaInicio, 'Pendiente');
        
        SET @NumeroCuotas -= 1;
        SET @FechaInicio = DATEADD(DAY, @DiasFrecuencia, @FechaInicio);
    END;
    
    -- Actualizar el campo FechaVencimiento en la tabla Prestamos
    UPDATE Prestamos SET FechaVencimiento = @FechaInicio WHERE IdPrestamo = @IdPrestamo;

    -- Insertar registro en la tabla HistorialPrestamos
    INSERT INTO HistorialPrestamos (IdPrestamo, FechaInicio, EstadoPrestamo)
    VALUES (@IdPrestamo, GETDATE(), 'Activo');
    
    -- Establecer el resultado y mensaje de salida
    SET @Resultado = 1;
    SET @Mensaje = 'El préstamo se ha insertado correctamente.';
END;
GO


CREATE PROCEDURE RegistrarPago
    @IdCuota INT,
    @Monto DECIMAL(12, 2),
    @FechaPago DATE,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    -- Declarar variables
    DECLARE @IdPago INT, @EstadoPrestamo VARCHAR(20), @EstadoPago VARCHAR(20);
    DECLARE @IdPrestamo INT, @MontoCuota DECIMAL(12, 2), @FechaVencimiento DATE, @EstadoCuota VARCHAR(20);
    
    -- Obtener información de la cuota
    SELECT @IdPrestamo = IdPrestamo, @MontoCuota = MontoCuota, @FechaVencimiento = FechaVencimiento, @EstadoCuota = EstadoCuota
    FROM Cuotas
    WHERE IdCuota = @IdCuota;
    
    -- Verificar si la cuota existe
    IF (@IdPrestamo IS NULL)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje = 'La cuota especificada no existe.';
        RETURN;
    END;
    
    -- Insertar registro en la tabla Pagos
    INSERT INTO Pagos (IdCuota, Monto, FechaPago)
    VALUES (@IdCuota, @Monto, @FechaPago);
    
    -- Obtener el IdPago del registro insertado
    SET @IdPago = SCOPE_IDENTITY();
    
    -- Actualizar el estado de la cuota
    UPDATE Cuotas SET EstadoCuota = 'Pagada', FechaPago = @FechaPago, Pagada = 1
    WHERE IdCuota = @IdCuota;
    
    -- Verificar si todas las cuotas del préstamo han sido pagadas
    IF NOT EXISTS (SELECT 1 FROM Cuotas WHERE IdPrestamo = @IdPrestamo AND EstadoCuota IN ('Pendiente', 'Atrasada'))
    BEGIN
        SET @EstadoPrestamo = 'Pagado';
    END
    ELSE
    BEGIN
        SET @EstadoPrestamo = 'Activo';
    END;
    
    -- Actualizar el estado del préstamo en la tabla Prestamos
    UPDATE Prestamos SET Estado = @EstadoPrestamo
    WHERE IdPrestamo = @IdPrestamo;
    
    -- Obtener el estado del préstamo y el estado del pago
    SET @EstadoPago = @EstadoPrestamo;
    
    -- Insertar registro en el historial de pagos
    INSERT INTO HistorialPagos (IdPago, IdCuota, Monto, FechaPago, EstadoPrestamo, EstadoPago)
    VALUES (@IdPago, @IdCuota, @Monto, @FechaPago, @EstadoPrestamo, @EstadoPago);
    
    -- Establecer el resultado y mensaje de salida
    SET @Resultado = 1;
    SET @Mensaje = 'El pago se ha registrado correctamente.';
END;
GO

CREATE PROCEDURE ObtenerPagoClientePorCuota
    @IdCuota INT
AS
BEGIN
    SELECT P.IdPago, P.IdCuota, C.IdPrestamo, C.MontoCuota, C.FechaVencimiento, C.EstadoCuota, C.FechaPago AS FechaPagoCuota,
           PR.IdCliente, PR.IdFrecuenciaPago, PR.TasaInteres, PR.MontoSolicitado, PR.TotalIntereses, PR.TotalPagar,
           PR.NumeroCuotas, PR.Estado AS EstadoPrestamo, PR.FechaPrestamo, PR.FechaVencimiento AS FechaVencimientoPrestamo,
           CL.IdPersona, CL.Estado AS EstadoCliente, CL.FechaCreacion,
           FR.Nombre AS FrecuenciaPagoNombre, FR.Estado AS FrecuenciaPagoEstado
    FROM Pagos P
    JOIN Cuotas C ON P.IdCuota = C.IdCuota
    JOIN Prestamos PR ON C.IdPrestamo = PR.IdPrestamo
    JOIN Clientes CL ON PR.IdCliente = CL.IdCliente
    JOIN FrecuenciasPago FR ON PR.IdFrecuenciaPago = FR.IdFrecuenciaPago
    WHERE C.IdCuota = @IdCuota;
END;
GO

---------------------------------------------------------------------------------------------------
-- Triggers
---------------------------------------------------------------------------------------------------

CREATE TRIGGER ActualizarEstadoCuota
ON Cuotas
AFTER INSERT, UPDATE
AS
BEGIN
    -- Actualizar el estado de las cuotas atrasadas
    UPDATE Cuotas
    SET EstadoCuota = 'Atrasada'
    WHERE IdCuota IN (
        SELECT IdCuota
        FROM inserted
        WHERE FechaPago > FechaVencimiento AND EstadoCuota = 'Pendiente'
    );
END;
GO
