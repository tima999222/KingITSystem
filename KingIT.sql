USE master
GO

IF EXISTS (SELECT * FROM SYS.DATABASES WHERE name = 'KingIT')
	DROP DATABASE KingIT

CREATE DATABASE KingIT
	ON PRIMARY (
		NAME = KingITData, 
		FILENAME = 'C:\Users\Public\KingIT.mdf', SIZE = 10 MB, MAXSIZE = 100, FILEGROWTH = 10)
		LOG ON 
		(
			NAME = StudentsLog,
			FILENAME = 'C:\Users\Public\KingIT.ldf', SIZE = 10 MB, MAXSIZE = 100, FILEGROWTH = 10
		)
GO

USE KingIT
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'Roles')
	DROP TABLE Roles
GO

CREATE TABLE Roles (
	RoleId INT PRIMARY KEY IDENTITY(1,1),
	RoleName NVARCHAR(50) NOT NULL
)

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'Users')
	DROP TABLE Users
GO

CREATE TABLE Users (
	UserId INT PRIMARY KEY IDENTITY(1,1),
	Login NVARCHAR(75) NOT NULL,
	Password NVARCHAR(75) NOT NULL,
	Surname NVARCHAR(50) NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	Patronymic NVARCHAR(50) NOT NULL,
	RoleId INT NOT NULL,
	FOREIGN KEY (RoleId) REFERENCES Roles(RoleId) ON DELETE CASCADE ON UPDATE CASCADE
)

IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'Cities')
	DROP TABLE Cities
GO

CREATE TABLE Cities (
	CityId INT PRIMARY KEY IDENTITY(1,1),
	CityName NVARCHAR(50) NOT NULL
)

IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'MallStatuses')
	DROP TABLE MallStatuses
GO

CREATE TABLE MallStatuses (
	MallStatusId INT PRIMARY KEY IDENTITY(1,1),
	MallStatus NVARCHAR(50) NOT NULL
)

IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'Malls')
	DROP TABLE Malls
GO

CREATE TABLE Malls (
	MallId INT PRIMARY KEY IDENTITY(1,1),
	MallName NVARCHAR(50) NOT NULL, 
	MallStatusId INT NOT NULL,
	CityId INT NOT NULL,
	BuildingCost MONEY NOT NULL,
	LevelsCount INT NOT NULL,
	ValueAddedFactor DECIMAL NOT NULL
	FOREIGN KEY (MallStatusId) REFERENCES MallStatuses(MallStatusId) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (CityId) REFERENCES Cities(CityId) ON DELETE CASCADE ON UPDATE CASCADE
)

IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'PavilionStatuses')
	DROP TABLE PavilionStatuses
GO

CREATE TABLE PavilionStatuses (
	PavilionStatusId INT PRIMARY KEY IDENTITY(1,1),
	PavilionStatus NVARCHAR(50) NOT NULL
)

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'Pavilions')
	DROP TABLE Pavilions
GO

CREATE TABLE Pavilions (
	PavilionId NVARCHAR(10) PRIMARY KEY,
	Area DECIMAL NOT NULL,
	LevelNumber INT NOT NULL,
	ValueAddedFactor DECIMAL NOT NULL,
	SquareMeterCost MONEY NOT NULL,
	MallId INT NOT NULL,
	PavilionStatusId INT NOT NULL,
	FOREIGN KEY (MallId) REFERENCES Malls(MallId) ON DELETE CASCADE ON UPDATE CASCADE,
)

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'PavilionsLease')
	DROP TABLE PavilionsLease
GO

CREATE TABLE PavilionsLease (
	LeaseId INT PRIMARY KEY IDENTITY(1,1),
	PavilionId NVARCHAR(10) NOT NULL,
	LeaseStart DATE,
	LeaseEnd DATE,
	PavilionStatusId INT NOT NULL,
	FOREIGN KEY (PavilionStatusId) REFERENCES PavilionStatuses(PavilionStatusId) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (PavilionId) REFERENCES Pavilions(PavilionId) ON DELETE CASCADE ON UPDATE CASCADE
)

GO

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'RescheduleLease') 
	DROP PROCEDURE RescheduleLease
GO

CREATE PROCEDURE RescheduleLease 
AS
BEGIN
	UPDATE PavilionsLease
	SET LeaseEnd = DATEADD(YEAR, 1, LeaseEnd), PavilionStatusId = 3
	WHERE LeaseStart IS NOT NULL
END

GO

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'PreventStatusChange') 
	DROP PROCEDURE PreventStatusChange
GO

CREATE TRIGGER PreventStatusChange
ON Malls
FOR UPDATE
AS
BEGIN
    IF UPDATE(MallStatusId)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN Pavilions p ON i.MallId = p.MallId
			INNER JOIN MallStatuses ms ON ms.MallStatusId = i.MallStatusId
			INNER JOIN PavilionsLease pl ON pl.PavilionId = p.PavilionId 
			INNER JOIN PavilionStatuses ps ON ps.PavilionStatusId = pl.PavilionStatusId
            WHERE i.MallStatusId = 'план' AND ps.PavilionStatus = 'забронирован'
        )
        BEGIN
            RAISERROR ('Cannot change Mall status to "план" due to reserved pavilions.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    END
END

GO

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'PreventDeleteUpdate')
	DROP TRIGGER PreventDeleteUpdate
GO

CREATE TRIGGER PreventDeleteUpdate
ON Pavilions
FOR DELETE, UPDATE
AS
BEGIN
    -- Проверяем, есть ли павильоны со статусом "забронирован" или "арендован"
    IF EXISTS (
        SELECT 1
        FROM Pavilions AS p
		INNER JOIN PavilionsLease AS pl ON pl.PavilionId = p.PavilionId 
        INNER JOIN PavilionStatuses AS ps ON pl.PavilionStatusId = ps.PavilionStatusId
        WHERE ps.PavilionStatus IN ('забронирован', 'арендован')  
    )
    BEGIN
        -- Отменяем операцию DELETE или UPDATE
        ROLLBACK;
        RAISERROR('Нельзя удалить или изменить павильон с статусом "забронирован" или "арендован".', 16, 1);
    END
END

GO

IF EXISTS (SELECT * FROM SYS.objects WHERE NAME = 'RentOrReservePavilion')
	DROP PROCEDURE RentOrReservePavilion
GO

CREATE PROCEDURE RentOrReservePavilion
    @PavilionId NVARCHAR(10),
    @LeaseStart DATE,
    @LeaseEnd DATE,
    @StatusId INT
AS
BEGIN
    -- Проверка наличия павильона
    IF NOT EXISTS (SELECT * FROM Pavilions WHERE PavilionId = @PavilionId)
    BEGIN
        RAISERROR('Павильон с указанным идентификатором не существует.', 16, 1)
        RETURN
    END

    -- Проверка статуса павильона
    IF EXISTS (SELECT * FROM PavilionsLease WHERE PavilionId = @PavilionId AND PavilionStatusId IN (2, 3))
    BEGIN
        RAISERROR('Невозможно изменить статус павильона, так как он уже забронирован или арендован.', 16, 1)
        RETURN
    END

    -- Добавление записи в таблицу PavilionsLease
    INSERT INTO PavilionsLease (PavilionId, LeaseStart, LeaseEnd, PavilionStatusId)
    VALUES (@PavilionId, @LeaseStart, @LeaseEnd, @StatusId)
END

GO 

INSERT INTO Roles (RoleName)
VALUES ('Администратор'), ('Менеджер С'), ('Менеджер А'), ('Удален')

INSERT INTO Users (Login, Password, Surname, Name, Patronymic, RoleId)
VALUES 
    ('john.doe', 'pass123', 'Doe', 'John', 'Michael', 1),
    ('jane.smith', 'abc456', 'Smith', 'Jane', 'Elizabeth', 2),
    ('mike.jackson', 'qwerty', 'Jackson', 'Mike', 'Thomas', 3),
    ('emma.watson', 'harrypotter', 'Watson', 'Emma', 'Charlotte', 4),
    ('alex.rodriguez', 'baseball1', 'Rodriguez', 'Alex', 'Gabriel', 1),
    ('laura.perez', 'password123', 'Perez', 'Laura', 'Isabella', 2),
    ('mark.williams', 'letmein', 'Williams', 'Mark', 'Andrew', 3),
    ('sarah.johnson', 'sunnyday', 'Johnson', 'Sarah', 'Grace', 4),
    ('max.garcia', '12345678', 'Garcia', 'Max', 'Benjamin', 1),
    ('natalie.harris', 'ilovecats', 'Harris', 'Natalie', 'Olivia', 2),
    ('tom.brown', 'football', 'Brown', 'Tom', 'Jacob', 3),
    ('lily.miller', 'flowerpower', 'Miller', 'Lily', 'Sophia', 4),
    ('adam.wilson', 'passw0rd', 'Wilson', 'Adam', 'James', 1),
    ('olivia.clark', 'hello123', 'Clark', 'Olivia', 'Ava', 2),
    ('david.green', 'welcome', 'Green', 'David', 'Daniel', 3),
    ('sophie.anderson', 'p@ssw0rd', 'Anderson', 'Sophie', 'Emily', 4);

INSERT INTO Cities (CityName)
VALUES ('Москва'), ('Дмитров'), ('Лобня');

INSERT INTO MallStatuses (MallStatus)
VALUES ('план'), ('строительство'), ('реализация');

INSERT INTO Malls (MallName, MallStatusId, CityId, BuildingCost, LevelsCount, ValueAddedFactor)
VALUES
    ('ТЦ1', 2, 1, 1000000, 3, 0.05),
    ('ТЦ2', 1, 2, 2000000, 4, 0.1),
    ('ТЦ3', 3, 1, 1500000, 2, 0.08);

INSERT INTO PavilionStatuses (PavilionStatus)
VALUES ('свободен'), ('забронирован'), ('арендован');

INSERT INTO Pavilions (PavilionId, Area, LevelNumber, ValueAddedFactor, SquareMeterCost, MallId)
VALUES
    ('ГП-1', 50, 1, 0.05, 500, 1),
    ('ГП-2', 40, 2, 0.08, 600, 1),
    ('ГП-3', 60, 1, 0.06, 550, 2);

INSERT INTO PavilionsLease (PavilionId, LeaseStart, LeaseEnd, PavilionStatusId)
VALUES
    ('ГП-1', '2023-06-01', '2024-06-01', 2),
    ('ГП-2', '2023-06-15', '2024-06-15', 3),
    ('ГП-3', '2023-07-01', '2024-07-01', 1);