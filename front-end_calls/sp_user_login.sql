CREATE PROCEDURE sp_user_login
    @EmailAddress VARCHAR(255),
    @Password VARCHAR(255),
    @Login DATETIME
AS
BEGIN
    DECLARE @UserID INT

    -- Verificar si el usuario y la contraseña son correctos
SELECT @UserID = u.UserID
FROM Users u
         INNER JOIN Passwords p ON u.UserID = p.UserID
WHERE u.EmailAddress = @EmailAddress AND p.PassHash = HASHBYTES('SHA2_256', @Password)

    IF @UserID IS NOT NULL
BEGIN
        -- Actualizar la hora de inicio de sesión
UPDATE Users SET Login = @Login WHERE UserID = @UserID;
END
ELSE
BEGIN
        -- Mostrar mensaje de error si el usuario o la contraseña son incorrectos
        PRINT 'El usuario o la contraseña son incorrectos';
END;
END;
go

