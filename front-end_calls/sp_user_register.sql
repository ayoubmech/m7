CREATE PROCEDURE sp_user_register
    @Username VARCHAR(255),
    @Name VARCHAR(255),
    @PhoneNumber VARCHAR(20),
    @EmailAddress VARCHAR(255),
    @RoleName VARCHAR(50),
    @Password VARCHAR(255)
AS
BEGIN
    DECLARE @RoleID INT

    -- Verificar si el rol ya existe, si no existe, insertarlo
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = @RoleName)
BEGIN
INSERT INTO Roles (RoleName) VALUES (@RoleName)
END

    -- Obtener el ID del rol
SELECT @RoleID = RoleID FROM Roles WHERE RoleName = @RoleName

                                         -- Insertar nuevo usuario
    INSERT INTO Users (Username, Name, PhoneNumber, EmailAddress, RoleID, Register)
VALUES (@Username, @Name, @PhoneNumber, @EmailAddress, @RoleID, GETDATE());

-- Insertar contraseña en la tabla Passwords
DECLARE @UserID INT
SELECT @UserID = SCOPE_IDENTITY() -- Obtener el ID del nuevo usuario insertado

    INSERT INTO Passwords (UserID, PassHash, LastPasswordChange)
VALUES (@UserID, HASHBYTES('SHA2_256', @Password), GETDATE());
END;
go

