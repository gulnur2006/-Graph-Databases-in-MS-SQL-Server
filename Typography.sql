USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Typography')
BEGIN
    ALTER DATABASE Typography SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Typography;
END;
GO

CREATE DATABASE Typography;
GO

USE Typography;
GO

-- ============================================================
-- 1. Таблицы узлов (NODE)
-- ============================================================

-- Узел: Бумага
CREATE TABLE Paper
(
    PaperId     INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    DensityGsm  INT           NOT NULL,
    Format      NVARCHAR(20)  NOT NULL,
    Color       NVARCHAR(50)  NOT NULL,
    IsCoated    BIT           NOT NULL
) AS NODE;
GO

-- Узел: Краска
CREATE TABLE Ink
(
    InkId       INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Color       NVARCHAR(50)  NOT NULL,
    InkType     NVARCHAR(50)  NOT NULL,
    PricePerMl  DECIMAL(10,2) NOT NULL
) AS NODE;
GO

-- Узел: Заказчик
CREATE TABLE Customer
(
    CustomerId  INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(100) NOT NULL,
    Phone       NVARCHAR(20)  NOT NULL,
    Email       NVARCHAR(100) NOT NULL
) AS NODE;
GO


-- ============================================================
-- 2. Таблицы рёбер (EDGE)
-- ============================================================

-- Ребро: Заказчик использует бумагу
CREATE TABLE CustomerUsesPaper
(
    UsageDate   DATETIME2     NOT NULL,
    Purpose     NVARCHAR(100) NOT NULL
) AS EDGE;

ALTER TABLE CustomerUsesPaper
ADD CONSTRAINT EC_CustomerUsesPaper
    CONNECTION (Customer TO Paper);
GO


-- Ребро: Заказчик использует краску
CREATE TABLE CustomerUsesInk
(
    UsageDate   DATETIME2     NOT NULL,
    AmountMl    DECIMAL(10,2) NOT NULL
) AS EDGE;

ALTER TABLE CustomerUsesInk
ADD CONSTRAINT EC_CustomerUsesInk
    CONNECTION (Customer TO Ink);
GO


-- Ребро: Бумага совместима с краской
CREATE TABLE PaperCompatibleWithInk
(
    Note        NVARCHAR(200) NULL
) AS EDGE;

ALTER TABLE PaperCompatibleWithInk
ADD CONSTRAINT EC_PaperCompatibleWithInk
    CONNECTION (Paper TO Ink);
GO

-- ============================================================
-- 3. Заполнение таблиц узлов (Id автоматически)
-- ============================================================
INSERT INTO Paper (Name, DensityGsm, Format, Color, IsCoated) VALUES
('Office A4', 80, 'A4', 'White', 0),
('Premium A4', 100, 'A4', 'White', 1),
('Color A4 Blue', 90, 'A4', 'Blue', 0),
('Color A4 Red', 90, 'A4', 'Red', 0),
('Glossy Photo', 200, 'A4', 'White', 1),
('Matte Photo', 180, 'A4', 'White', 1),
('Book Paper', 70, 'A5', 'Cream', 0),
('Poster Paper', 150, 'A3', 'White', 1),
('Cardboard', 250, 'A4', 'White', 1),
('Newspaper', 55, 'A3', 'Gray', 0);

INSERT INTO Ink (Name, Color, InkType, PricePerMl) VALUES
('Black Standard', 'Black', 'Pigment', 0.10),
('Cyan Standard', 'Cyan', 'Pigment', 0.12),
('Magenta Standard', 'Magenta', 'Pigment', 0.12),
('Yellow Standard', 'Yellow', 'Pigment', 0.12),
('Photo Black', 'Black', 'Dye', 0.15),
('Photo Cyan', 'Cyan', 'Dye', 0.15),
('Photo Magenta', 'Magenta', 'Dye', 0.15),
('Red Special', 'Red', 'Pigment', 0.20),
('Blue Special', 'Blue', 'Pigment', 0.20),
('Gold Metallic', 'Gold', 'Special', 0.50);

INSERT INTO Customer (FullName, Phone, Email) VALUES
('Ivan Petrov', '+375291111111', 'ivan@example.com'),
('Anna Smirnova', '+375292222222', 'anna@example.com'),
('Pavel Ivanov', '+375293333333', 'pavel@example.com'),
('Olga Kozlova', '+375294444444', 'olga@example.com'),
('Sergey Orlov', '+375295555555', 'sergey@example.com'),
('Maria Volkova', '+375296666666', 'maria@example.com'),
('Dmitry Egorov', '+375297777777', 'dmitry@example.com'),
('Elena Petrova', '+375298888888', 'elena@example.com'),
('Nikolay Sidorov', '+375299999999', 'nikolay@example.com'),
('Svetlana Ivanova', '+375291010101', 'sveta@example.com');

-- ============================================================
-- 4. Заполнение таблиц рёбер 
-- ============================================================
INSERT INTO CustomerUsesPaper ($from_id, $to_id, UsageDate, Purpose)
SELECT c.$node_id, p.$node_id, '2024-01-10', 'Business documents'
FROM Customer c CROSS JOIN Paper p
WHERE c.CustomerId = 1 AND p.PaperId IN (1,2);

INSERT INTO CustomerUsesPaper ($from_id, $to_id, UsageDate, Purpose)
SELECT c.$node_id, p.$node_id, '2024-02-05', 'Photo printing'
FROM Customer c CROSS JOIN Paper p
WHERE c.CustomerId = 2 AND p.PaperId IN (5,6);

INSERT INTO CustomerUsesPaper ($from_id, $to_id, UsageDate, Purpose)
SELECT c.$node_id, p.$node_id, '2024-03-12', 'Book layout'
FROM Customer c CROSS JOIN Paper p
WHERE c.CustomerId = 3 AND p.PaperId IN (7);

INSERT INTO CustomerUsesPaper ($from_id, $to_id, UsageDate, Purpose)
SELECT c.$node_id, p.$node_id, '2024-04-01', 'Posters'
FROM Customer c CROSS JOIN Paper p
WHERE c.CustomerId = 4 AND p.PaperId IN (8,9);


INSERT INTO CustomerUsesInk ($from_id, $to_id, UsageDate, AmountMl)
SELECT c.$node_id, i.$node_id, '2024-01-10', 50
FROM Customer c CROSS JOIN Ink i
WHERE c.CustomerId = 1 AND i.InkId IN (1,2);

INSERT INTO CustomerUsesInk ($from_id, $to_id, UsageDate, AmountMl)
SELECT c.$node_id, i.$node_id, '2024-02-05', 80
FROM Customer c CROSS JOIN Ink i
WHERE c.CustomerId = 2 AND i.InkId IN (5,6,7);

INSERT INTO CustomerUsesInk ($from_id, $to_id, UsageDate, AmountMl)
SELECT c.$node_id, i.$node_id, '2024-03-12', 30
FROM Customer c CROSS JOIN Ink i
WHERE c.CustomerId = 3 AND i.InkId IN (1);

INSERT INTO CustomerUsesInk ($from_id, $to_id, UsageDate, AmountMl)
SELECT c.$node_id, i.$node_id, '2024-04-01', 120
FROM Customer c CROSS JOIN Ink i
WHERE c.CustomerId = 4 AND i.InkId IN (8,9);


INSERT INTO PaperCompatibleWithInk ($from_id, $to_id, Note)
SELECT p.$node_id, i.$node_id, 'Standard pigment compatible'
FROM Paper p CROSS JOIN Ink i
WHERE p.PaperId IN (1,2,3,4) AND i.InkId IN (1,2,3,4);

INSERT INTO PaperCompatibleWithInk ($from_id, $to_id, Note)
SELECT p.$node_id, i.$node_id, 'Photo dye recommended'
FROM Paper p CROSS JOIN Ink i
WHERE p.PaperId IN (5,6) AND i.InkId IN (5,6,7);

INSERT INTO PaperCompatibleWithInk ($from_id, $to_id, Note)
SELECT p.$node_id, i.$node_id, 'Special ink for posters'
FROM Paper p CROSS JOIN Ink i
WHERE p.PaperId IN (8,9) AND i.InkId IN (8,9,10);

-- ============================================================
-- 5. Запросы с MATCH 
-- ============================================================

-- Найти заказчиков, которые используют бумагу, совместимую с золотой металлической краской
SELECT 
    c.FullName AS CustomerName,
    p.Name AS PaperName,
    i.Name AS InkName,
    cup.Purpose AS UsagePurpose,
    pci.Note AS CompatibilityNote
FROM 
    Customer c,
    CustomerUsesPaper cup,
    Paper p,
    PaperCompatibleWithInk pci,
    Ink i
WHERE 
    MATCH(c-(cup)->p-(pci)->i)
    AND i.Name = 'Gold Metallic'
ORDER BY c.FullName;

-- Найти заказчиков, которые используют бумагу и краску, и эта бумага совместима с используемой краской
SELECT 
    c.FullName AS CustomerName,
    p.Name AS PaperName,
    i.Name AS InkName,
    cup.Purpose AS PaperPurpose,
    cui.AmountMl AS InkAmount,
    pci.Note AS CompatibilityNote
FROM 
    Customer c,
    CustomerUsesPaper cup,
    Paper p,
    PaperCompatibleWithInk pci,
    Ink i,
    CustomerUsesInk cui
WHERE 
    MATCH(c-(cup)->p-(pci)->i AND c-(cui)->i)
    AND pci.Note IS NOT NULL
ORDER BY c.FullName, p.Name;

-- Для каждого заказчика показать, какие краски совместимы с используемой им бумагой
SELECT 
    c.FullName AS CustomerName,
    c.Phone AS CustomerPhone,
    p.Name AS UsedPaper,
    STRING_AGG(i.Name, ', ') AS CompatibleInks,
    COUNT(i.InkId) AS CompatibleInkCount
FROM 
    Customer c,
    CustomerUsesPaper cup,
    Paper p,
    PaperCompatibleWithInk pci,
    Ink i
WHERE 
    MATCH(c-(cup)->p-(pci)->i)
GROUP BY 
    c.FullName, c.Phone, p.Name, p.PaperId
ORDER BY CompatibleInkCount DESC;

--Найти заказчиков, использующих краски, цена которых выше средней, и бумагу подходящую для специальных красок

SELECT 
    c.FullName,
    p.Name AS PaperName,
    i.Name AS ExpensiveInk,
    i.PricePerMl AS InkPrice,
    cup.UsageDate,
    cui.AmountMl
FROM 
    Customer c,
    CustomerUsesPaper cup,
    Paper p,
    PaperCompatibleWithInk pci,
    Ink i,
    CustomerUsesInk cui
WHERE 
    MATCH(c-(cup)->p-(pci)->i AND c-(cui)->i)
    AND p.IsCoated = 1
    AND i.PricePerMl > (SELECT AVG(PricePerMl) FROM Ink)
ORDER BY i.PricePerMl DESC;

--Найти трёхшаговый путь через все узлы графа: Найти все возможные пути: Заказчик → Бумага → Краска → другой Заказчик (через совместимость)
SELECT 
    c1.FullName AS CustomerFrom,
    p.Name AS PaperUsed,
    i.Name AS InkCompatible,
    c2.FullName AS CustomerWhoCanAlsoUse,
    cup.Purpose,
    pci.Note
FROM 
    Customer c1,
    CustomerUsesPaper cup,
    Paper p,
    PaperCompatibleWithInk pci,
    Ink i,
    CustomerUsesInk cui,
    Customer c2
WHERE 
    MATCH(c1-(cup)->p-(pci)->i<-(cui)-c2)
    AND c1.CustomerId != c2.CustomerId
    AND c2.CustomerId IN (SELECT CustomerId FROM Customer);  

-- ============================================================
-- 6. Запросы с SHORTEST_PATH (включая Id узлов)
-- ============================================================
SELECT 
    Клиент,
    CustomerId,
    Путь_бумаги,
    Количество_бумаг
FROM (
    SELECT
        c.FullName AS Клиент,
        c.CustomerId AS CustomerId,

        STRING_AGG(p.Name, ' -> ') 
            WITHIN GROUP (GRAPH PATH) AS Путь_бумаги,

        COUNT(cup.$edge_id) 
            WITHIN GROUP (GRAPH PATH) AS Количество_бумаг

    FROM
        Customer AS c,
        CustomerUsesPaper FOR PATH AS cup,
        Paper FOR PATH AS p

    WHERE MATCH(
            SHORTEST_PATH(
                c(-(cup)->p){1,3}
            )
        )
      AND c.FullName = 'Ivan Petrov'
) AS Q
WHERE Q.Количество_бумаг = 1;



SELECT 
    Клиент,
    CustomerId,
    Бумага,
    PaperId,
    Краска,
    InkId,
    Длина_пути
FROM (
    SELECT
        c.FullName AS Клиент,
        c.CustomerId AS CustomerId,

        STRING_AGG(p.Name, ' -> ') 
            WITHIN GROUP (GRAPH PATH) AS Бумага,

        STRING_AGG(CAST(p.PaperId AS NVARCHAR(10)), ',') 
            WITHIN GROUP (GRAPH PATH) AS PaperId,

        STRING_AGG(i.Name, ' | ') 
            WITHIN GROUP (GRAPH PATH) AS Краска,

        STRING_AGG(CAST(i.InkId AS NVARCHAR(10)), ',') 
            WITHIN GROUP (GRAPH PATH) AS InkId,

        COUNT(pci.$edge_id) 
            WITHIN GROUP (GRAPH PATH) AS Длина_пути

    FROM
        Customer AS c,
        CustomerUsesPaper FOR PATH AS cup,
        Paper FOR PATH AS p,
        PaperCompatibleWithInk FOR PATH AS pci,
        Ink FOR PATH AS i

    WHERE MATCH(
            SHORTEST_PATH(
                c(-(cup)->p-(pci)->i){1,3}
            )
        )
      AND c.FullName = 'Anna Smirnova'
) AS Q;

