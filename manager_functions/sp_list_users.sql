CREATE PROCEDURE sp_list_users
    AS
BEGIN
    -- Listar todos los usuarios
SELECT * FROM Users;
END;
go