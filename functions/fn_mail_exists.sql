CREATE FUNCTION fn_mail_exists
(
    @EmailAddress VARCHAR(255)
)
    RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT

    IF EXISTS (SELECT 1 FROM Users WHERE EmailAddress = @EmailAddress)
        SET @Result = 1;
ELSE
        SET @Result = 0;

RETURN @Result;
END
go

EXEC sp_exec_fn_mail_exists 'usuario1@example.com';