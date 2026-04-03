-- ----------------------------------------------------------------------------
-- Select Role, Warehouse and Schema
-- ----------------------------------------------------------------------------
USE ROLE ROLE_LOADER;
USE WAREHOUSE MODERN_INSURANCE_PLATFORM_WH;

USE DATABASE DEV_MODERN_INSURANCE_PLATFORM;
USE SCHEMA RAW;

-- ----------------------------------------------------------------------------
-- 1) CUSTOMERS (messy: duplicates, inconsistent email casing, mixed DOB formats)
-- ----------------------------------------------------------------------------
INSERT INTO CUSTOMERS
  (CUSTOMER_ID, FIRST_NAME, LAST_NAME, DOB, EMAIL, CREATED_AT, SOURCE_SYSTEM)
VALUES
  ('C0001','Gareth','Whitnell','1980-01-14','gareth.whitnell@example.com','2024-01-01T09:01:00Z','CRM'),
  ('C0002','Asha','Patel','02/11/1976','asha.patel@example.com','2024/01/03 11:15','CRM'),
  ('C0003','Tom','Evans','1972/07/09','tom.evans@example.com','2024-01-05 08:02:11','CRM'),
  ('C0004','Sara','O''Neill','1990-12-01','sara.oneill@example.com','2024-01-07T14:33:00+00:00','CRM'),
  ('C0005','Mohammed','Khan','1985-03-22','m.khan@example.com','2024-01-10','CRM'),
  ('C0006','Emily','Jones','01-09-1988','emily.jones@example.com','2024-01-12T10:00:00Z','CRM'),
  ('C0007','Liam','Murphy','1979-05-03','liam.murphy@example.com','2024-01-13 09:00','CRM'),
  ('C0008','Chloe','Smith','1995-08-30','Chloe.Smith@Example.com','2024-01-14T09:45:00Z','CRM'),
  ('C0009','Priya','Sharma','1992/04/18','priya.sharma@example.com','2024-01-15T12:10:00Z','CRM'),
  ('C0010','Daniel','Brown','1983-02-27','dan.brown@example.com','2024-01-16 16:20:00','CRM'),
  ('C0011','Hannah','Taylor','1987-06-16','hannah.taylor@example.com','2024/01/18 09:05','CRM'),
  ('C0012','George','Wilson','1970-10-10','george.wilson@example.com','2024-01-20T07:50:00Z','CRM'),
  ('C0013','Sophie','Davies','1991-01-09','sophie.davies@example.com','2024-01-21','CRM'),
  ('C0014','Ben','Thomas','1989-11-30','ben.thomas@example.com','2024-01-22T18:00:00Z','CRM'),
  ('C0015','Alicia','Clark','1994-07-25','alicia.clark@example.com','2024-01-25 08:30','CRM'),
  ('C0016','Owen','Roberts','1977-09-14','owen.roberts@example.com','2024-01-27T13:15:00Z','CRM'),
  ('C0017','Nia','Lewis','1996-02-11','nia.lewis@example.com','2024-01-28T09:40:00Z','CRM'),
  ('C0018','Jack','Hughes','1981-04-05','jack.hughes@example.com','2024-01-30T10:10:00Z','CRM'),
  ('C0019','Ella','Price','1986-12-19','ella.price@example.com','2024-02-01T11:00:00Z','CRM'),
  ('C0020','Rhys','Morgan','1990-03-03','rhys.morgan@example.com','2024-02-02T15:22:00Z','CRM'),

  -- messy duplicates / variations
  ('C0021','Chloe','Smith','1995-08-30','chloe.smith@example.com','2024-02-03 09:45','CRM'), -- dup person/email case
  ('C0022','Sara','O''Neill','1990-12-01','sara.oneill@example.com','2024-02-04T14:33:00Z','CRM'); -- dup email same


-- ----------------------------------------------------------------------------
-- 2) POLICIES (>= 20 policies, messy premiums/dates/status)
-- ----------------------------------------------------------------------------
INSERT INTO POLICIES
  (POLICY_ID, CUSTOMER_ID, PRODUCT_CODE, INCEPTION_DATE, EXPIRY_DATE, STATUS, ANNUAL_PREMIUM, SOURCE_SYSTEM)
VALUES
  ('P10001','C0001','MOTOR','2024-02-01','2025-02-01','ACTIVE','650.25','POLICY_ADMIN'),
  ('P10002','C0002','HOME','2024-03-01','2025-03-01','ACTIVE','£420.00','POLICY_ADMIN'),
  ('P10003','C0003','MOTOR','01/04/2024','31/03/2025','ACTIVE',' 510 ','POLICY_ADMIN'),
  ('P10004','C0004','PET','2024/04/15','2025/04/14','ACTIVE','192.99','POLICY_ADMIN'),
  ('P10005','C0005','MOTOR','2024-05-01','2025-05-01','ACTIVE','£1,120.50','POLICY_ADMIN'),
  ('P10006','C0006','TRAVEL','2024-06-10','2025-06-09','ACTIVE','89.00','POLICY_ADMIN'),
  ('P10007','C0007','HOME','2024-06-01','2025-05-31','ACTIVE','375.5','POLICY_ADMIN'),
  ('P10008','C0008','MOTOR','2024-07-01','2025-07-01','ACTIVE','700','POLICY_ADMIN'),
  ('P10009','C0009','LIFE','2024-07-15','2025-07-14','ACTIVE',' 35.99','POLICY_ADMIN'),
  ('P10010','C0010','MOTOR','2024-08-01','2025-08-01','ACTIVE','£845.00','POLICY_ADMIN'),
  ('P10011','C0011','HOME','2024-08-20','2025-08-19','ACTIVE','399.00','POLICY_ADMIN'),
  ('P10012','C0012','PET','2024-09-05','2025-09-04','ACTIVE','210.00','POLICY_ADMIN'),
  ('P10013','C0013','MOTOR','2024-09-15','2025-09-15','ACTIVE','-20.00','POLICY_ADMIN'), -- messy negative
  ('P10014','C0014','HOME','2024-10-01','2025-10-01','ACTIVE','0','POLICY_ADMIN'), -- messy zero premium
  ('P10015','C0015','TRAVEL','2024-10-10','2025-10-09','CANCELLED','120.00','POLICY_ADMIN'),
  ('P10016','C0016','MOTOR','2024-11-01','2025-11-01','ACTIVE',' 999.99 ','POLICY_ADMIN'),
  ('P10017','C0017','HOME','2024-11-15','2025-11-14','ACTIVE','£450','POLICY_ADMIN'),
  ('P10018','C0018','MOTOR','2024-12-01','2025-12-01','ACTIVE','610.10','POLICY_ADMIN'),
  ('P10019','C0019','PET','2025-01-01','2026-01-01','ACTIVE','215','POLICY_ADMIN'),
  ('P10020','C0020','MOTOR','2025-01-15','2026-01-15','LAPSED','780.00','POLICY_ADMIN'),

  -- a couple more to make it richer
  ('P10021','C0021','HOME','2025/02/01','2026/01/31','ACTIVE','£525.25','POLICY_ADMIN'),
  ('P10022','C0022','MOTOR','2025-02-10','2026-02-10','ACTIVE','830.75','POLICY_ADMIN');

-- ----------------------------------------------------------------------------
-- 3) CLAIMS (mix of open/closed, messy amounts)
-- ----------------------------------------------------------------------------
INSERT INTO CLAIMS
  (CLAIM_ID, POLICY_ID, LOSS_DATE, REPORTED_DATE, CLAIM_STATUS, PAID_AMOUNT, SOURCE_SYSTEM)
VALUES
  ('CL90001','P10001','2024-06-10','2024-06-11','OPEN','0','CLAIMS_SYS'),
  ('CL90002','P10003','10/09/2024','2024-09-12','CLOSED','£1,250.00','CLAIMS_SYS'),
  ('CL90003','P10005','2024/11/02','2024/11/03','CLOSED',' 350.5 ','CLAIMS_SYS'),
  ('CL90004','P10008','2025-01-15','2025-01-16','REJECTED','0.00','CLAIMS_SYS'),
  ('CL90005','P10010','2025-02-05','2025-02-06','OPEN','£0','CLAIMS_SYS'),
  ('CL90006','P10012','2025-03-01','2025-03-01','CLOSED','89','CLAIMS_SYS'),
  ('CL90007','P10016','2025-05-20','2025-05-21','CLOSED','£2,010.75','CLAIMS_SYS'),
  ('CL90008','P10018','2025-06-11','2025-06-12','OPEN','  ','CLAIMS_SYS'); -- blank amount

-- ----------------------------------------------------------------------------
-- 4) BUSINESS_EVENTS (messy: duplicates, mixed timestamp formats, versions)
-- ----------------------------------------------------------------------------
INSERT INTO BUSINESS_EVENTS
  (EVENT_ID, POLICY_ID, EVENT_TS, EVENT_TYPE, CHANNEL, GROSS_PREMIUM_CHANGE, EVENT_VERSION, SOURCE_SYSTEM)
VALUES
  -- P10001: quote -> NB -> MTA -> renewal
  ('E000001','P10001','2024-01-20T10:00:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000002','P10001','2024-01-20T10:00:05Z','quote','web','0','2','BROKER_PORTAL'), -- dup-ish quote
  ('E000003','P10001','2024-02-01T09:00:00Z','new_business','web','650.25','1','POLICY_ADMIN'),
  ('E000004','P10001','2024-08-01 09:00','mta','call_centre','25.00','1','POLICY_ADMIN'),
  ('E000005','P10001','2025-02-01T09:00:00Z','renewal','web','15.00','1','POLICY_ADMIN'),

  -- P10002: quote -> NB -> cancellation
  ('E000006','P10002','2024/02/15 12:00','quote','web','0','1','BROKER_PORTAL'),
  ('E000007','P10002','2024-03-01T10:30:00Z','new_business','web','£420.00','1','POLICY_ADMIN'),
  ('E000008','P10002','2024-04-10T09:00:00Z','cancellation','call_centre','0','1','POLICY_ADMIN'),

  -- P10003: quote -> NB -> claim event doesn't exist in events (fine)
  ('E000009','P10003','15/03/2024 09:12','quote','broker','0','1','BROKER_PORTAL'),
  ('E000010','P10003','01/04/2024 00:00','new_business','broker','510','1','POLICY_ADMIN'),

  -- P10004: NB only
  ('E000011','P10004','2024-04-15T08:00:00Z','new_business','web','192.99','1','POLICY_ADMIN'),

  -- P10005: quote -> NB -> MTA x2
  ('E000012','P10005','2024-04-20T18:22:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000013','P10005','2024-05-01T00:00:00Z','new_business','web','£1,120.50','1','POLICY_ADMIN'),
  ('E000014','P10005','2024-09-01T09:00:00Z','mta','call_centre','-10.00','1','POLICY_ADMIN'), -- negative change
  ('E000015','P10005','2024-10-01T09:00:00Z','mta','call_centre',' 20 ','2','POLICY_ADMIN'),

  -- P10006: NB -> lapse
  ('E000016','P10006','2024-06-10T10:00:00Z','new_business','web','89.00','1','POLICY_ADMIN'),
  ('E000017','P10006','2024-07-10T10:00:00Z','lapse','web','0','1','POLICY_ADMIN'),

  -- P10007: quote -> NB -> renewal
  ('E000018','P10007','2024-05-20 11:00','quote','web','0','1','BROKER_PORTAL'),
  ('E000019','P10007','2024-06-01T00:00:00Z','new_business','web','375.50','1','POLICY_ADMIN'),
  ('E000020','P10007','2025-06-01T00:00:00Z','renewal','web','10.00','1','POLICY_ADMIN'),

  -- P10008: quote -> NB -> cancellation
  ('E000021','P10008','2024-06-15T13:00:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000022','P10008','2024-07-01T00:00:00Z','new_business','web','700','1','POLICY_ADMIN'),
  ('E000023','P10008','2024-12-20T09:00:00Z','cancellation','call_centre','0','1','POLICY_ADMIN'),

  -- P10009: NB only
  ('E000024','P10009','2024-07-15T00:00:00Z','new_business','web','35.99','1','POLICY_ADMIN'),

  -- P10010: quote -> NB -> MTA -> renewal (messy premium string)
  ('E000025','P10010','2024-07-20T08:00:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000026','P10010','2024-08-01T00:00:00Z','new_business','web','£845.00','1','POLICY_ADMIN'),
  ('E000027','P10010','2024-11-01T09:00:00Z','mta','call_centre','5','1','POLICY_ADMIN'),
  ('E000028','P10010','2025-08-01T00:00:00Z','renewal','web','12.00','1','POLICY_ADMIN'),

  -- P10011: NB -> renewal
  ('E000029','P10011','2024-08-20T00:00:00Z','new_business','web','399.00','1','POLICY_ADMIN'),
  ('E000030','P10011','2025-08-20T00:00:00Z','renewal','web','0','1','POLICY_ADMIN'),

  -- P10012: NB -> claim exists
  ('E000031','P10012','2024-09-05T00:00:00Z','new_business','web','210.00','1','POLICY_ADMIN'),

  -- P10013: NB with negative premium (messy)
  ('E000032','P10013','2024-09-15T00:00:00Z','new_business','web','-20.00','1','POLICY_ADMIN'),

  -- P10014: NB with zero premium
  ('E000033','P10014','2024-10-01T00:00:00Z','new_business','web','0','1','POLICY_ADMIN'),

  -- P10015: quote -> NB -> cancellation
  ('E000034','P10015','2024-10-01T10:00:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000035','P10015','2024-10-10T00:00:00Z','new_business','web','120.00','1','POLICY_ADMIN'),
  ('E000036','P10015','2024-10-20T09:00:00Z','cancellation','call_centre','0','1','POLICY_ADMIN'),

  -- P10016: NB -> MTA
  ('E000037','P10016','2024-11-01T00:00:00Z','new_business','broker','999.99','1','POLICY_ADMIN'),
  ('E000038','P10016','2025-02-01T09:00:00Z','mta','broker','-15.00','1','POLICY_ADMIN'),

  -- P10017: NB
  ('E000039','P10017','2024-11-15T00:00:00Z','new_business','web','£450','1','POLICY_ADMIN'),

  -- P10018: quote -> NB -> renewal
  ('E000040','P10018','2024-11-20T10:00:00Z','quote','web','0','1','BROKER_PORTAL'),
  ('E000041','P10018','2024-12-01T00:00:00Z','new_business','web','610.10','1','POLICY_ADMIN'),
  ('E000042','P10018','2025-12-01T00:00:00Z','renewal','web','9.90','1','POLICY_ADMIN'),

  -- P10019: NB
  ('E000043','P10019','2025-01-01T00:00:00Z','new_business','web','215','1','POLICY_ADMIN'),

  -- P10020: quote -> NB -> lapse
  ('E000044','P10020','2024-12-20 08:30','quote','web','0','1','BROKER_PORTAL'),
  ('E000045','P10020','2025-01-15T00:00:00Z','new_business','web','780.00','1','POLICY_ADMIN'),
  ('E000046','P10020','2025-03-01T00:00:00Z','lapse','web','0','1','POLICY_ADMIN'),

  -- P10021: NB -> renewal
  ('E000047','P10021','2025/02/01 00:00','new_business','web','£525.25','1','POLICY_ADMIN'),
  ('E000048','P10021','2026-02-01T00:00:00Z','renewal','web','20.00','1','POLICY_ADMIN'),

  -- P10022: NB -> MTA -> cancellation
  ('E000049','P10022','2025-02-10T00:00:00Z','new_business','call_centre','830.75','1','POLICY_ADMIN'),
  ('E000050','P10022','2025-04-01T09:00:00Z','mta','call_centre',' 30.00','1','POLICY_ADMIN'),
  ('E000051','P10022','2025-05-01T09:00:00Z','cancellation','call_centre','0','1','POLICY_ADMIN');