create database conn;
use conn;

CREATE TABLE Users (
    ID INT PRIMARY KEY,
    Username VARCHAR(255),
    Name VARCHAR(255),
    EmailAddress VARCHAR(255),
    Role VARCHAR(50),
    AccountGUID VARCHAR(255), -- Añadir columna para GUID de activación
    Status VARCHAR(20) -- Añadir columna para el estado del usuario
);

CREATE TABLE Admin (
    ID_user INT PRIMARY KEY,
    Role VARCHAR(50),
    FOREIGN KEY (ID_user) REFERENCES Users(ID)
);

CREATE TABLE Manager (
    ID_user INT PRIMARY KEY,
    Role VARCHAR(50),
    FOREIGN KEY (ID_user) REFERENCES Users(ID)
);

CREATE TABLE Session (
    ID_user INT,
    ID_session INT PRIMARY KEY,
    Status VARCHAR(20),
    FOREIGN KEY (ID_user) REFERENCES Users(ID)
);

CREATE TABLE Password (
    ID_user INT,
    Password VARCHAR(255),
    LastHistoricDateChange DATETIME,
    FOREIGN KEY (ID_user) REFERENCES Users(ID)
);

CREATE TABLE Errors (
    id_error INT PRIMARY KEY,
    description VARCHAR(555)
);
-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_insert_user 
    @user_id INT,
    @username VARCHAR(255),
    @name VARCHAR(255),
    @email VARCHAR(255),
    @role VARCHAR(50),
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Users (ID, Username, Name, EmailAddress, Role, AccountGUID, Status) 
        VALUES (@user_id, @username, @name, @email, @role, NEWID(), 'Inactive'); -- Generar un nuevo GUID y establecer estado inactivo
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

go
CREATE PROCEDURE sp_insert_password 
    @user_id INT,
    @password VARCHAR(255),
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Password (ID_user, Password, LastHistoricDateChange) 
        VALUES (@user_id, @password, GETDATE());
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_user_register 
    @user_id INT,
    @name VARCHAR(255),
    @surname VARCHAR(255),
    @pwd VARCHAR(255),
    @mail VARCHAR(255),
    @gender VARCHAR(10),
    @def_lang VARCHAR(10),
    @ret INT OUTPUT
AS
BEGIN
    DECLARE @ret_insert INT;
    DECLARE @ret_pwd INT;
    DECLARE @username VARCHAR(255);

    -- Concatenar el nombre y apellido para formar el nombre de usuario
    SET @username = @name + ' ' + @surname;

    BEGIN TRY
        -- Llamar al procedimiento para insertar el usuario
        EXEC sp_insert_user @user_id = @user_id, @username = @username, 
                            @name = @name, @email = @mail, @role = 'User', @ret = @ret_insert;

        IF @ret_insert = 0
        BEGIN
            -- Llamar al procedimiento para insertar la contraseña
            EXEC sp_insert_password @user_id = @user_id, @password = @pwd, @ret = @ret_pwd;

            IF @ret_pwd != 0
            BEGIN
                SET @ret = -1;
            END
            ELSE
            BEGIN
                SET @ret = 0;
            END
        END
        ELSE
        BEGIN
            SET @ret = -1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_user_login 
    @mail VARCHAR(255),
    @pwd VARCHAR(255),
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @user_id INT;
        DECLARE @user_pwd VARCHAR(255);

        SELECT @user_id = ID, @user_pwd = P.Password
        FROM Users U
        JOIN Password P ON U.ID = P.ID_user
        WHERE U.EmailAddress = @mail;

        IF @user_pwd = @pwd
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

go
CREATE PROCEDURE sp_user_accountactivate 
    @guid VARCHAR(255),
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE Users
        SET Status = 'Active'
        WHERE AccountGUID = @guid;

        IF @@ROWCOUNT > 0 
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

go
CREATE PROCEDURE sp_user_logout 
    @user_id INT,
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE Session
        SET Status = 'Inactive'
        WHERE ID_user = @user_id;

        IF @@ROWCOUNT > 0 
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

go
CREATE PROCEDURE sp_user_change_password 
    @user_id INT,
    @new_pwd VARCHAR(255),
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE Password
        SET Password = @new_pwd, LastHistoricDateChange = GETDATE()
        WHERE ID_user = @user_id;

        IF @@ROWCOUNT > 0 
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

go
CREATE PROCEDURE sp_user_get_accountdata 
    @ssid INT,
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT ID, Username, Name, EmailAddress, Role, Status
        FROM Users
        WHERE ID = @ssid;

        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_adm_user_kill 
    @user_id INT,
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DELETE FROM Users WHERE ID = @user_id;

        IF @@ROWCOUNT > 0 
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_adm_system_setusertimeout 
    @timeout_value INT,
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        UPDATE SystemSettings
        SET UserTimeout = @timeout_value;

        IF @@ROWCOUNT > 0 
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = 1;
        END
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_adm_view_system_settings 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM SystemSettings;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_system_status 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM SystemStatus;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_users 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM Users;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_connections 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM Connections;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_historic_connections 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM HistoricConnections;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_historic_user_connections 
    @user_id INT,
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM HistoricConnections WHERE ID_user = @user_id;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_list_errors 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT * FROM Errors;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_wdev_deletealldata 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        EXEC sp_delete_alldata @ret = @ret;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_wdev_inserttestdata 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        EXEC sp_insert_user @user_id = 1, @username = 'testuser1', @name = 'Test User 1', @email = 'test1@example.com', @role = 'User', @ret = @ret;
        EXEC sp_insert_password @user_id = 1, @password = 'password1', @ret = @ret;

        EXEC sp_insert_user @user_id = 2, @username = 'testuser2', @name = 'Test User 2', @email = 'test2@example.com', @role = 'Admin', @ret = @ret;
        EXEC sp_insert_password @user_id = 2, @password = 'password2', @ret = @ret;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_wdev_systemtest 
    @ret INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT 1;
        SET @ret = 0;
    END TRY
    BEGIN CATCH
        SET @ret = -1;
    END CATCH
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_wdev_user_insert 
    @user_id INT,
    @username VARCHAR(255),
    @name VARCHAR(255),
    @email VARCHAR(255),
    @role VARCHAR(50),
    @password VARCHAR(255),
    @ret INT OUTPUT
AS
BEGIN
    DECLARE @ret_insert INT;
    DECLARE @ret_pwd INT;

    EXEC sp_insert_user @user_id, @username, @name, @role, @email, @ret_insert;

    IF @ret_insert = 0
    BEGIN
        EXEC sp_insert_password @user_id, @password, @ret_pwd;

        IF @ret_pwd = 0
        BEGIN
            SET @ret = 0;
        END
        ELSE
        BEGIN
            SET @ret = -1;
        END
    END
    ELSE
    BEGIN
        SET @ret = -1;
    END
END;

-- ----------------------------------------------------------------------------------------
go
CREATE PROCEDURE sp_wdev_select_alldata 
    @ret INT OUTPUT
AS
BEGIN
    EXEC sp_select_alldata @ret = @ret;
END;

-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_user_exists (@user_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT;

    IF EXISTS (SELECT 1 FROM Users WHERE ID = @user_id)
    BEGIN
        SET @exists = 1;
    END
    ELSE
    BEGIN
        SET @exists = 0;
    END

    RETURN @exists;
END;

-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_user_state (@user_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @state VARCHAR(20);

    SELECT @state = Status FROM Users WHERE ID = @user_id;

    RETURN @state;
END;

-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_pwd_isvalid (@user_id INT, @password VARCHAR(255))
RETURNS BIT
AS
BEGIN
    DECLARE @isvalid BIT;

    IF EXISTS (SELECT 1 FROM Password WHERE ID_user = @user_id AND Password = @password)
    BEGIN
        SET @isvalid = 1;
    END
    ELSE
    BEGIN
        SET @isvalid = 0;
    END

    RETURN @isvalid;
END;

-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_pwd_checkpolicy (@password VARCHAR(255))
RETURNS BIT
AS
BEGIN
    DECLARE @isvalid BIT;

    -- Aquí se puede implementar la lógica de validación de la política de contraseña
    IF LEN(@password) >= 8
    BEGIN
        SET @isvalid = 1;
    END
    ELSE
    BEGIN
        SET @isvalid = 0;
    END

    RETURN @isvalid;
END;
-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_mail_isvalid (@mail VARCHAR(255))
RETURNS BIT
AS
BEGIN
    DECLARE @isvalid BIT;

    -- Aquí se puede implementar la lógica de validación del formato del correo electrónico
    IF @mail LIKE '%_@__%.__%'
    BEGIN
        SET @isvalid = 1;
    END
    ELSE
    BEGIN
        SET @isvalid = 0;
    END

    RETURN @isvalid;
END;
-- ----------------------------------------------------------------------------------------
go
CREATE FUNCTION fn_mail_exists (@mail VARCHAR(255))
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT;

    IF EXISTS (SELECT 1 FROM Users WHERE EmailAddress = @mail)
    BEGIN
        SET @exists = 1;
    END
    ELSE
    BEGIN
        SET @exists = 0;
    END

    RETURN @exists;
END;
