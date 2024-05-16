
CREATE PROCEDURE sp_list_users_connected
    AS
BEGIN
    -- Listar usuarios que están actualmente conectados
SELECT * FROM Users WHERE Login IS NOT NULL AND Logout IS NULL;
END;
go

