
CREATE PROCEDURE sp_user_accountvalidate
    @EmailAddress VARCHAR(255),
    @UserID INT OUTPUT
AS
BEGIN
    -- Verificar si el usuario ya existe
SELECT @UserID = UserID FROM Users WHERE EmailAddress = @EmailAddress;
END;
go

