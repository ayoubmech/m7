
CREATE PROCEDURE sp_user_logout
    @EmailAddress VARCHAR(255),
    @Logout DATETIME
AS
BEGIN
    -- Actualizar la hora de cierre de sesión
UPDATE Users SET Logout = @Logout WHERE EmailAddress = @EmailAddress;
END;
go

