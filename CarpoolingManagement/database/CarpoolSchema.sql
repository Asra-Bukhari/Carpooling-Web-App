create database carpoolingManagementSystem
use carpoolingManagementSystem

select * from areas
select * from users
select * from Vehicles
select * from Drivers
select * from ScheduledTrips
select * from TripRequests
delete from users where userID>8
delete from ScheduledTrips
delete from Vehicles where vehicleID>5
delete from Drivers where driverID>5
/***********************
  1. Areas Table
***********************/
CREATE TABLE Areas(
    AreaCode int PRIMARY KEY,
    City varchar(500) NOT NULL,
    Town varchar(500) ,
    Road varchar(500) DEFAULT NULL,
    Block int DEFAULT NULL,
    sector varchar(500) DEFAULT NULL,
    Place varchar(500) ,
    NearbyAreas Text,
	latitude float,
    longitude float,
	 UNIQUE(AreaCode)
);
GO



/***********************
  2. Vehicles Table
***********************/
CREATE TABLE Vehicles(
    vehicleID int IDENTITY(1,1) PRIMARY KEY,
    Name varchar(20) NOT NULL,
    Color varchar(10) NOT NULL,
    Company varchar(15) NOT NULL,
    Typee varchar(10) CHECK (Typee IN ('Mini','Luxury','Comfort','Rickshaw','Bike')),
    Capacity int NOT NULL 
);
GO

/***********************
  3. Users Table
***********************/
CREATE TABLE Users(
    userID int IDENTITY(1,1) constraint userID_pk PRIMARY KEY,
    Name varchar(150) DEFAULT 'Unknown',
    Email varchar(255) UNIQUE NOT NULL check(Email like '%@email.com' or Email like '%@gmail.com'),
	Password varchar(255) NOT NULL,
    Gender varchar(7) CHECK (Gender IN ('Male','Female')),
    Age int CHECK (Age >= 18),
    City varchar(20) NOT NULL,
    UserStatus varchar(10) CHECK (UserStatus IN ('Driver','Non-Driver')),
    Contact varchar(12) NOT NULL,
    EmergencyContact varchar(12) NOT NULL,
    CurrentArea int,
    Preference1 int,
    Preference2 int,
    Preference3 int,
    RecentTrip int,
	IsActive bit DEFAULT 1,
	isAdmin int default 0 ,--for users
    CONSTRAINT CA_Fk FOREIGN KEY (CurrentArea) REFERENCES Areas(AreaCode) ON DELETE CASCADE,
    CONSTRAINT p1_Fk FOREIGN KEY (Preference1) REFERENCES Areas(AreaCode) ON DELETE NO ACTION,
    CONSTRAINT p2_Fk FOREIGN KEY (Preference2) REFERENCES Areas(AreaCode) ON DELETE NO ACTION,
    CONSTRAINT p3_Fk FOREIGN KEY (Preference3) REFERENCES Areas(AreaCode) ON DELETE NO ACTION,
    CONSTRAINT Rt_Fk FOREIGN KEY (RecentTrip) REFERENCES Areas(AreaCode) ON DELETE NO ACTION
);
GO

/***********************
  4. Drivers Table
***********************/
CREATE TABLE Drivers(
    driverID int PRIMARY KEY 
         CONSTRAINT driverID_fk FOREIGN KEY REFERENCES Users(userID) ON DELETE CASCADE,
    vehicleID int,
    DriverStatus varchar(12) CHECK (DriverStatus IN ('Hired','Collaborator')),
    Availability varchar(3) NOT NULL CHECK (Availability IN ('Yes','No')),
   
    CONSTRAINT vehID_Fk FOREIGN KEY (vehicleID) REFERENCES Vehicles(vehicleID) ON DELETE CASCADE
);
GO

/**************************
  5. Scheduled Trips Table
**************************/
CREATE TABLE ScheduledTrips(
    TripID int IDENTITY(1,1) constraint tripID_pk PRIMARY KEY,
    RequesterID int,
    AvailableSeats int DEFAULT -1,  -- if requester is not a driver 
    DriverID int DEFAULT NULL,
    StartLocation int,
    Destination int,
    Statuss varchar(12) CHECK (Statuss IN ('Ongoing','Cancelled','Completed')),
    Routee text,
    CurrentLocation int,
    ExpectedDuration int,
    DepartureTime date,
    Travelers text,
    CONSTRAINT requesterID_fk FOREIGN KEY (RequesterID) REFERENCES Users(userID) ON DELETE CASCADE,
    CONSTRAINT dID_fk FOREIGN KEY (DriverID) REFERENCES Drivers(driverID) ON DELETE No action,
    CONSTRAINT start_fk FOREIGN KEY (StartLocation) REFERENCES Areas(AreaCode) ON DELETE no action,
    CONSTRAINT dest_fk FOREIGN KEY (Destination) REFERENCES Areas(AreaCode) ON delete no action,
    CONSTRAINT curr_fk FOREIGN KEY (CurrentLocation) REFERENCES Areas(AreaCode) ON DELETE no action
);
GO
select * from ScheduledTrips
delete from ScheduledTrips where TripID>5
/***********************
  6. Payments Table
***********************/
CREATE TABLE Payments(
    PaymentID int IDENTITY(1,1) constraint paymentID_pk PRIMARY KEY,
    TripID int,
    DriverID int,
    EarnedAmount int,
    Statuss varchar(6) CHECK (Statuss IN ('Paid','Unpaid')),
    PaymentDate date DEFAULT NULL,
    CONSTRAINT tripID_fk FOREIGN KEY (TripID) REFERENCES ScheduledTrips(TripID) ON DELETE CASCADE,
    CONSTRAINT driverID_fk2 FOREIGN KEY (DriverID) REFERENCES Drivers(driverID) ON DELETE no action
);
GO

/*************************
  7. Friends Group Table
*************************/
CREATE TABLE FriendsGroup(
    GroupNo int IDENTITY(1,1) constraint group_pk PRIMARY KEY,
    groupAdmin int,
    TotalMembers int CHECK (TotalMembers <= 4),
    TripsCompleted int DEFAULT NULL,
    OtherMembers text,
    CONSTRAINT admin_fk FOREIGN KEY (groupAdmin) REFERENCES Users(userID) ON DELETE CASCADE
);
GO

/*************************
  8. Trips Requests Table
*************************/
CREATE TABLE TripRequests (
    RequestID int IDENTITY(1,1) constraint tr_pk PRIMARY KEY,
    PassengerID int NOT NULL,
    PickupLocation int NOT NULL,
    DropoffLocation int NOT NULL,
    TripDateTime datetime NOT NULL,
    Statuss varchar(50) DEFAULT 'Pending' CHECK (Statuss IN ('approved','Pending')),
    CreatedAt datetime DEFAULT GETDATE(),
    CONSTRAINT tr_fk FOREIGN KEY (PassengerID) REFERENCES Users(userID) ON DELETE CASCADE,
	CONSTRAINT tr_pick_fk FOREIGN KEY (PickupLocation) REFERENCES Areas(AreaCode) ,
	CONSTRAINT tr_drop_fk FOREIGN KEY (DropoffLocation) REFERENCES Areas(AreaCode)
);
GO


/*************************
 11. Join Request Table
*************************/
CREATE TABLE JoinRequests (
    JoinRequestID int IDENTITY(1,1) PRIMARY KEY,
    TripRequestID int FOREIGN KEY REFERENCES TripRequests(RequestID),
    PassengerID int FOREIGN KEY REFERENCES Users(UserID),
    Status varchar(50) DEFAULT 'Pending' CHECK (Status IN ('Approved','Pending','Rejected')),  
);

/*************************
  9. Ratings Table
*************************/
CREATE TABLE Ratings (
    RatingID int IDENTITY(1,1) PRIMARY KEY,
    TripID int NOT NULL,
	PassengerID int NOT NULL,
    DriverID int NOT NULL,
    Rating int CHECK (Rating BETWEEN 1 AND 5),
    Review text NULL,
    RatedAt datetime DEFAULT GETDATE(),
    CONSTRAINT trip_fk FOREIGN KEY (TripID) REFERENCES ScheduledTrips(TripID) ON DELETE CASCADE,
	CONSTRAINT rating_pass_fk FOREIGN KEY (PassengerID) REFERENCES Users(userID) ON DELETE no action,
    CONSTRAINT rating_driver_fk FOREIGN KEY (DriverID) REFERENCES Users(userID) ON DELETE no action
);
GO

/*************************
 10. Notifications Table
*************************/
CREATE TABLE Notifications (
    NotificationID int IDENTITY(1,1) PRIMARY KEY,
    UserID int NOT NULL,
    TripID int NULL,
    Message varchar(500) NOT NULL,
    IsRead bit DEFAULT 0,
    CreatedAt datetime DEFAULT GETDATE(),
    CONSTRAINT notif_user_fk FOREIGN KEY (UserID) REFERENCES Users(userID) ON DELETE CASCADE,
    CONSTRAINT notif_trip_fk FOREIGN KEY (TripID) REFERENCES ScheduledTrips(TripID) ON DELETE NO ACTION
);




Go


/*****************************
  Triggers for Cascade Deletes
*****************************/

-- Trigger on Areas: Cascade delete to Users and ScheduledTrips that reference deleted Areas.
CREATE TRIGGER trg_Areas_DeleteCascade
ON Areas
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Users
    WHERE CurrentArea IN (SELECT AreaCode FROM deleted)
       OR Preference1 IN (SELECT AreaCode FROM deleted)
       OR Preference2 IN (SELECT AreaCode FROM deleted)
       OR Preference3 IN (SELECT AreaCode FROM deleted)
       OR RecentTrip IN (SELECT AreaCode FROM deleted);

    DELETE FROM ScheduledTrips
    WHERE StartLocation IN (SELECT AreaCode FROM deleted)
       OR Destination IN (SELECT AreaCode FROM deleted)
       OR CurrentLocation IN (SELECT AreaCode FROM deleted);
END;
GO

-- Trigger on Users: Cascade delete to Drivers, ScheduledTrips, TripRequests, Ratings, FriendsGroup, and Notifications.
CREATE TRIGGER trg_Users_DeleteCascade
ON Users
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Drivers
    WHERE driverID IN (SELECT userID FROM deleted);

    DELETE FROM ScheduledTrips
    WHERE DriverID IN (SELECT userID FROM deleted);

    DELETE FROM TripRequests
    WHERE PassengerID IN (SELECT userID FROM deleted);

    DELETE FROM Ratings
    WHERE DriverID IN (SELECT userID FROM deleted);

    DELETE FROM FriendsGroup
    WHERE groupAdmin IN (SELECT userID FROM deleted);

    DELETE FROM Notifications
    WHERE UserID IN (SELECT userID FROM deleted);
END;
GO

-- Trigger on Drivers: Cascade delete to ScheduledTrips, Payments, and Ratings that reference the deleted driver.
CREATE TRIGGER trg_Drivers_DeleteCascade
ON Drivers
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM ScheduledTrips
    WHERE DriverID IN (SELECT driverID FROM deleted);


    DELETE FROM Ratings
    WHERE DriverID IN (SELECT driverID FROM deleted);
END;
GO

-- Trigger on ScheduledTrips: Cascade delete to Payments, Ratings, and Notifications.
CREATE TRIGGER trg_ScheduledTrips_DeleteCascade
ON ScheduledTrips
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Payments
    WHERE TripID IN (SELECT TripID FROM deleted);

    DELETE FROM Ratings
    WHERE TripID IN (SELECT TripID FROM deleted);

    DELETE FROM Notifications
    WHERE TripID IN (SELECT TripID FROM deleted);
END;



Go



/***********************
  Dummy inserts
***********************/



-- Reset identity counter for Vehicles table
DBCC CHECKIDENT ('Vehicles', RESEED, 1);

-- Reset identity counter for Users table
DBCC CHECKIDENT ('Users', RESEED, 1);

-- Reset identity counter for ScheduledTrips table
DBCC CHECKIDENT ('ScheduledTrips', RESEED, 1);

-- Reset identity counter for Payments table
DBCC CHECKIDENT ('Payments', RESEED, 1);

-- Reset identity counter for FriendsGroup table
DBCC CHECKIDENT ('FriendsGroup', RESEED, 1);

-- Reset identity counter for TripRequests table
DBCC CHECKIDENT ('TripRequests', RESEED, 1);



-- Reset identity counter for Notifications table
DBCC CHECKIDENT ('Notifications', RESEED, 1);


Go



INSERT INTO Areas (AreaCode, City, Town, Road, Block, sector, Place, latitude, longitude) VALUES
(1, 'Lahore', 'Model Town', 'Main Blvd', 1, 'A', 'House #123', 31.5204, 74.3587),
(2, 'Lahore', 'DHA', 'Phase 5', 5, 'B', 'Office #456', 31.4700, 74.4100),
(3, 'Karachi', 'Gulshan', 'University Rd', 3, 'C', 'Flat #789', 24.8607, 67.0011),
(4, 'Islamabad', 'F-10', 'Blue Area', 2, 'D', 'Apartment #101', 33.6844, 73.0479),
(5, 'Karachi', 'Korangi', 'Main Rd', 4, 'E', 'Shop #789', 24.8295, 67.1292);
Go

INSERT INTO Vehicles (Name, Color, Company, Typee, Capacity) VALUES
('Mehran', 'White', 'Suzuki', 'Mini', 4),
('Civic', 'Black', 'Honda', 'Comfort', 5),
('Changan', 'Blue', 'Karak', 'Rickshaw', 3),  
('Fortuner', 'Silver', 'Toyota', 'Luxury', 7),
('Honda Bike', 'Red', 'Honda', 'Bike', 2);
Go

INSERT INTO Users (Name, Email, Password, Gender, Age, City, UserStatus, Contact, EmergencyContact, CurrentArea, Preference1, Preference2, Preference3, RecentTrip) VALUES
('Ali Raza', 'ali@email.com', 'pass123', 'Male', 25, 'Lahore', 'Driver', '03001234567', '03111234567', 1, 2, 3, NULL, NULL),
('Fatima Noor', 'fatima@gmail.com', 'pass456', 'Female', 30, 'Lahore', 'Non-Driver', '03007654321', '03117654321', 2, 1, 3, NULL, NULL),
('Zain Ali', 'zain@email.com', 'password', 'Male', 22, 'Karachi', 'Driver', '03123456789', '03012345678', 3, 2, 4, NULL, NULL),
('Sarah Ahmed', 'sarah@gmail.com', 'mypassword', 'Female', 28, 'Islamabad', 'Non-Driver', '03087654321', '03123456789', 4, 1, 3, NULL, NULL),
('Usman Khokhar', 'usman@email.com', 'usman123', 'Male', 35, 'Karachi', 'Driver', '03010987654', '03111223344', 5, 2, 3, NULL, NULL);
Go
--admins
INSERT INTO Users (Name, Email, Password, Gender, Age, City, UserStatus, Contact, EmergencyContact, CurrentArea, Preference1, Preference2, Preference3, RecentTrip,isAdmin) VALUES
('Asra', 'asra@gmail.com', 'asra123', 'female', 25, 'Lahore', 'Non-Driver', '030275493290', '0356789324', 1, 2, 3, NULL, NULL,1),
('Harmain', 'harmain@gmail.com', 'har456', 'Male', 30, 'Lahore', 'Non-Driver', '03012569408', '03456378902', 2, 1, 3, NULL, NULL,1),
('Shizza', 'shizza@gmail.com', 'shizza123', 'female', 22, 'Lahore', 'Non-Driver', '03123869032', '03261879456', 3, 2, 4, NULL, NULL,1);
Go
select * from users
INSERT INTO Drivers (driverID, vehicleID, DriverStatus, Availability) VALUES
(1, 1, 'Hired', 'Yes'),
(2, 2, 'Collaborator', 'Yes'),
(3, 3, 'Hired', 'No'),
(4, 4, 'Collaborator', 'Yes'),
(5, 5, 'Hired', 'No');
Go

INSERT INTO ScheduledTrips (RequesterID, AvailableSeats, DriverID, StartLocation, Destination, Statuss, Routee, CurrentLocation, ExpectedDuration, DepartureTime, Travelers) VALUES
(2, -1, 1, 1, 2, 'Ongoing', 'Route via Kalma', 1, 45, '2025-04-05', 'Fatima, Ali'),
(1, 2, 2, 2, 3, 'Completed', 'Route DHA to Model Town', 3, 35, '2025-04-01', 'Ali'),
(3, -1, 1, 3, 4, 'Ongoing', 'Route Gulshan to F-10', 2, 60, '2025-04-10', 'Zain, Sarah'),
(4, 1, 4, 4, 5, 'Completed', 'Route F-10 to Korangi', 5, 50, '2025-04-15', 'Sarah, Usman'),
(5, -1, 3, 5, 1, 'Ongoing', 'Route Korangi to Model Town', 1, 40, '2025-04-20', 'Fatima, Usman');
Go

INSERT INTO Payments (TripID, DriverID, EarnedAmount, Statuss, PaymentDate) VALUES
(2, 1, 500, 'Paid', '2025-04-02'),
(4, 2, 600, 'Paid', '2025-04-05'),
(1, 3, 450, 'Unpaid', '2025-04-10'),
(5, 4, 550, 'Paid', '2025-04-15'),
(3, 5, 400, 'Unpaid', '2025-04-20');
Go


INSERT INTO FriendsGroup (groupAdmin, TotalMembers, TripsCompleted, OtherMembers) VALUES
(1, 2, 3, 'Ali, Fatima'),
(2, 3, 2, 'Zain, Sarah, Usman'),
(3, 2, 4, 'Zain, Sarah'),
(4, 4, 1, 'Usman, Fatima, Ali, Sarah'),
(5, 2, 3, 'Usman, Zain');
Go

INSERT INTO TripRequests (PassengerID, PickupLocation, DropoffLocation, TripDateTime, Statuss) VALUES
(2, 1, 3, GETDATE(), 'Pending'),
(1, 2, 3, GETDATE(), 'Approved'),
(3, 5, 4, GETDATE(), 'Pending'),
(4, 3, 5, GETDATE(), 'Approved'),
(5, 1, 4, GETDATE(), 'Pending');
Go


INSERT INTO Ratings (TripID, PassengerID, DriverID, Rating, Review) VALUES
(2, 2, 1, 5, 'Great ride!'),
(4, 4, 2, 4, 'Smooth but a bit slow.'),
(1, 1, 3, 3, 'Okay experience, but could be better.'),
(5, 5, 4, 5, 'Loved the trip, great driver!'),
(3, 3, 1, 4, 'Nice and comfortable, could improve route knowledge.');
Go


INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt) VALUES
(1, 1, 'Your trip has started!', 0, DATEADD(DAY, -2, GETDATE())),
(2, 2, 'Your trip has completed.', 0, DATEADD(DAY, -40, GETDATE())),
(3, 3, 'Your trip is about to start soon!', 1, DATEADD(DAY, -1, GETDATE())),
(4, 4, 'Your trip has been canceled.', 1, DATEADD(DAY, -5, GETDATE())),
(5, 5, 'Driver has been assigned to your trip.', 0, DATEADD(DAY, -10, GETDATE()));





Go




/***********************
 update queries
***********************/

CREATE TRIGGER trg_UserStatusChange
ON Users
AFTER UPDATE
AS
BEGIN
    --status changes from Driver to Non-Driver
    DELETE FROM Drivers
    WHERE DriverID IN (
        SELECT i.UserID
        FROM inserted i
        JOIN deleted d ON i.UserID = d.UserID
        WHERE d.UserStatus = 'Driver' AND i.UserStatus = 'Non-Driver'
    );

    --status changes from Non-Driver to Driver
    INSERT INTO Drivers (DriverID, VehicleID, DriverStatus, Availability)
    SELECT i.UserID, NULL, 'Collaborator', 'No'
    FROM inserted i
    JOIN deleted d ON i.UserID = d.UserID
    WHERE d.UserStatus = 'Non-Driver' AND i.UserStatus = 'Driver'
    AND NOT EXISTS (SELECT 1 FROM Drivers WHERE DriverID = i.UserID);
END;
Go

--to update user (all or specific attribute - works for both)
CREATE PROCEDURE UpdateUser
    @UserID INT,
    @Name VARCHAR(150) = NULL,
    @Email VARCHAR(255) = NULL,
    @Password VARCHAR(255) = NULL,
    @Gender VARCHAR(7) = NULL,
    @Age INT = NULL,
    @City VARCHAR(20) = NULL,
    @UserStatus VARCHAR(10) = NULL,
    @Contact VARCHAR(12) = NULL,
    @EmergencyContact VARCHAR(12) = NULL,
    @CurrentArea INT = NULL,
    @Preference1 INT = NULL,
    @Preference2 INT = NULL,
    @Preference3 INT = NULL,
    @RecentTrip INT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    -- Check if the email already exists
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND UserID <> @UserID)
    BEGIN
        PRINT 'Email already exists!';
        RETURN;
    END

    UPDATE Users
    SET Name = COALESCE(@Name, Name),
        Email = COALESCE(@Email, Email),
        Password = COALESCE(@Password, Password),
        Gender = COALESCE(@Gender, Gender),
        Age = COALESCE(@Age, Age),
        City = COALESCE(@City, City),
        UserStatus = COALESCE(@UserStatus, UserStatus),
        Contact = COALESCE(@Contact, Contact),
        EmergencyContact = COALESCE(@EmergencyContact, EmergencyContact),
        CurrentArea = COALESCE(@CurrentArea, CurrentArea),
        Preference1 = COALESCE(@Preference1, Preference1),
        Preference2 = COALESCE(@Preference2, Preference2),
        Preference3 = COALESCE(@Preference3, Preference3),
        RecentTrip = COALESCE(@RecentTrip, RecentTrip),
        IsActive = COALESCE(@IsActive, IsActive)
    WHERE UserID = @UserID;
END;
Go

-- Update procedure for Drivers
CREATE PROCEDURE UpdateDriver
    @DriverID INT,
    @VehicleID INT = NULL,
    @DriverStatus VARCHAR(12) = NULL,
    @Availability VARCHAR(3) = NULL
AS
BEGIN
    -- Check if VehicleID exists
    IF @VehicleID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Vehicles WHERE VehicleID = @VehicleID)
    BEGIN
        RAISERROR ('Vehicle ID does not exist', 16, 1);
        RETURN;
    END

    UPDATE Drivers
    SET VehicleID = COALESCE(@VehicleID, VehicleID),
        DriverStatus = COALESCE(@DriverStatus, DriverStatus),
        Availability = COALESCE(@Availability, Availability)
    WHERE DriverID = @DriverID;
END;
Go


-- Update procedure for area
CREATE PROCEDURE UpdateArea
    @AreaCode INT,
    @City VARCHAR(500) = NULL,
    @Town VARCHAR(500) = NULL,
    @Road VARCHAR(500) = NULL,
    @Block INT = NULL,
    @Sector VARCHAR(500) = NULL,
    @Place VARCHAR(500) = NULL
    
AS
BEGIN
    UPDATE Areas
    SET City = COALESCE(@City, City),
        Town = COALESCE(@Town, Town),
        Road = COALESCE(@Road, Road),
        Block = COALESCE(@Block, Block),
        Sector = COALESCE(@Sector, Sector),
        Place = COALESCE(@Place, Place)
        
    WHERE AreaCode = @AreaCode;
END;
Go

-- Update procedure for vehicles
CREATE PROCEDURE UpdateVehicle
    @VehicleID INT,
    @Name VARCHAR(20) = NULL,
    @Color VARCHAR(10) = NULL,
    @Company VARCHAR(15) = NULL,
    @Typee VARCHAR(7) = NULL,
    @Capacity INT = NULL  
AS
BEGIN
    UPDATE Vehicles
    SET Name = COALESCE(@Name, Name),
        Color = COALESCE(@Color, Color),
        Company = COALESCE(@Company, Company),
        Typee = COALESCE(@Typee, Typee),
        Capacity = COALESCE(@Capacity, Capacity)       
    WHERE VehicleID = @VehicleID;
END;
Go


-- Update procedure for ScheduledTrips
CREATE PROCEDURE UpdateScheduledTrip
    @TripID INT,
    @DriverID INT = NULL,
    @Statuss VARCHAR(12) = NULL,
    @CurrentLocation INT = NULL,
    @ExpectedDuration INT = NULL
AS
BEGIN
     DECLARE @OldtripStatus VARCHAR(12);
     SELECT @OldtripStatus = Statuss FROM ScheduledTrips WHERE TripID = @TripID;

    UPDATE ScheduledTrips
    SET 
        
        DriverID = COALESCE(@DriverID, DriverID),
        Statuss = COALESCE(@Statuss, Statuss),
        CurrentLocation = COALESCE(@CurrentLocation, CurrentLocation),
        ExpectedDuration = COALESCE(@ExpectedDuration, ExpectedDuration)
    WHERE TripID = @TripID;
    
    -- If status is changed to 'Completed', insert into Ratings and Payments
    IF @Statuss = 'Completed' and @OldtripStatus <> 'Completed'
    BEGIN
        INSERT INTO Ratings (TripID, DriverID)
        VALUES (@TripID, @DriverID);
        
        INSERT INTO Payments (TripID,  Statuss)
        VALUES (@TripID, 'Pending');
    END
END;
Go

-- Update procedure for TripRequests
CREATE PROCEDURE UpdateTripRequest
    @RequestID INT,
    @PickupLocation int = NULL,
    @DropoffLocation int = NULL,
    @TripDateTime DATETIME = NULL,
    @Statuss VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @PreviousStatus VARCHAR(50);
    SELECT @PreviousStatus = Statuss FROM TripRequests WHERE RequestID = @RequestID;
    
    UPDATE TripRequests
    SET 
        PickupLocation = COALESCE(@PickupLocation, PickupLocation),
        DropoffLocation = COALESCE(@DropoffLocation, DropoffLocation),
        TripDateTime = COALESCE(@TripDateTime, TripDateTime),
        Statuss = COALESCE(@Statuss, Statuss)
    WHERE RequestID = @RequestID;
    
    -- If status changed to 'Approved' and was not previously 'Approved', insert into ScheduledTrips
    IF @Statuss = 'Approved' AND @PreviousStatus <> 'Approved'
    BEGIN
        INSERT INTO ScheduledTrips (DriverID, StartLocation, Destination, DepartureTime)
        SELECT PassengerID, PickupLocation, DropoffLocation, TripDateTime
        FROM TripRequests WHERE RequestID = @RequestID;
    END
END;
Go

-- Update procedure for Payments
CREATE PROCEDURE UpdatePayment
    @PaymentID INT,
    @EarnedAmount INT = NULL,
    @Statuss VARCHAR(6) = NULL,
    @PaymentDate DATE = NULL
AS
BEGIN
    UPDATE Payments
    SET 
        EarnedAmount = COALESCE(@EarnedAmount, EarnedAmount),
        Statuss = COALESCE(@Statuss, Statuss),
        PaymentDate = COALESCE(@PaymentDate, PaymentDate)
    WHERE PaymentID = @PaymentID;
END;
Go

-- Update procedure for FriendsGroup
CREATE PROCEDURE UpdateFriendsGroup
    @GroupNo INT,
    @GroupAdmin INT = NULL,
    
    @TripsCompleted INT = NULL
   
AS
BEGIN
    UPDATE FriendsGroup
    SET GroupAdmin = COALESCE(@GroupAdmin, GroupAdmin),
        
        TripsCompleted = COALESCE(@TripsCompleted, TripsCompleted)
    WHERE GroupNo = @GroupNo;
END;
Go


-- Update procedure for Ratings
CREATE PROCEDURE UpdateRating
   @TripID int ,@PassengerID int,
    @Rating INT = NULL,
    @Review TEXT = NULL,
    @RatedAt DATETIME = NULL
AS
BEGIN
    UPDATE Ratings
    SET 
        Rating = COALESCE(@Rating, Rating),
        Review = COALESCE(@Review, Review),
        RatedAt = COALESCE(@RatedAt, RatedAt)
    WHERE TripID = @TripID and PassengerID=@PassengerID;
END;
Go

-- Update procedure for Notifications
CREATE PROCEDURE UpdateNotification
    @NotificationID INT,
	@TripID INT,
    @Message VARCHAR(500) = NULL,
    @IsRead BIT = NULL
AS
BEGIN
    UPDATE Notifications
    SET 
	   TripID=COALESCE(@TripID, TripID),
        Message = COALESCE(@Message, Message),
        IsRead = COALESCE(@IsRead, IsRead)
    WHERE NotificationID = @NotificationID;
END;




Go


/***********************
   Insert Queries
***********************/


CREATE PROCEDURE InsertArea
    @AreaCode int,
    @City varchar(20),
    @Town varchar(100) = NULL,
    @Road varchar(100) = NULL,
    @Block int = NULL,
    @sector varchar(4) = NULL,
    @Place varchar(100),
    @latitude float = NULL,
    @longitude float = NULL
AS
BEGIN
    INSERT INTO Areas (AreaCode, City,Town, Road, Block, sector, Place, latitude, longitude)
    VALUES (@AreaCode, @City, @Town, @Road, @Block, @sector, @Place, @latitude, @longitude);
END
GO


CREATE PROCEDURE InsertVehicle
    @Name varchar(20),
    @Color varchar(10),
    @Company varchar(15),
    @Typee varchar(7),
    @Capacity int
AS
BEGIN
    INSERT INTO Vehicles (Name, Color, Company, Typee, Capacity)
    VALUES (@Name, @Color, @Company, @Typee, @Capacity);
END
GO


CREATE PROCEDURE InsertUser
    @Name varchar(150) = 'Unknown',
    @Email varchar(255),
    @Password varchar(255),
    @Gender varchar(7),
    @Age int,
    @City varchar(20),
    @UserStatus varchar(10),
    @Contact varchar(12),
    @EmergencyContact varchar(12),
    @CurrentArea int = NULL,
    @Preference1 int = NULL,
    @Preference2 int = NULL,
    @Preference3 int = NULL,
    @RecentTrip int = NULL,
    @vehicleID int = NULL, 
    @DriverStatus varchar(12) = NULL,
    @Availability varchar(3) = NULL
AS
BEGIN
    DECLARE @InsertedUserID int;

   
    INSERT INTO Users (Name, Email, Password, Gender, Age, City, UserStatus, Contact, EmergencyContact, CurrentArea, Preference1, Preference2, Preference3, RecentTrip)
    VALUES (@Name, @Email, @Password, @Gender, @Age, @City, @UserStatus, @Contact, @EmergencyContact, @CurrentArea, @Preference1, @Preference2, @Preference3, @RecentTrip);

    -- Get the inserted user's ID
    SET @InsertedUserID = SCOPE_IDENTITY();

    -- If UserStatus is 'Driver' and they are not already in Drivers table, insert them
    IF @UserStatus = 'Driver'
    BEGIN
       
        IF @vehicleID IS NULL OR @DriverStatus IS NULL OR @Availability IS NULL
        BEGIN
            PRINT 'Driver details missing: VehicleID, DriverStatus, or Availability is required';
            RETURN;
        END

        INSERT INTO Drivers (driverID, vehicleID, DriverStatus, Availability)
        VALUES (@InsertedUserID, @vehicleID, @DriverStatus, @Availability);
    END
END
GO


CREATE PROCEDURE InsertDriver
    @userID int,
    @vehicleID int,
    @DriverStatus varchar(12),
    @Availability varchar(3)
AS
BEGIN
    INSERT INTO Drivers (driverID, vehicleID, DriverStatus, Availability)
    VALUES (@userID, @vehicleID, @DriverStatus, @Availability);
END
GO


CREATE PROCEDURE InsertScheduledTrip
    @DriverID int,

    @StartLocation int,
    @Destination int,
    @Statuss varchar(12),
 
    @CurrentLocation int = NULL,
    @ExpectedDuration int,
    @DepartureTime date
   
AS
BEGIN
    DECLARE @InsertedTripID int;

   
    INSERT INTO ScheduledTrips (DriverID, StartLocation, Destination, Statuss, CurrentLocation, ExpectedDuration, DepartureTime)
    VALUES (@DriverID, @StartLocation, @Destination, @Statuss, @CurrentLocation, @ExpectedDuration, @DepartureTime );

    -- Get the ID of the inserted trip
    SET @InsertedTripID = SCOPE_IDENTITY();

    
    IF @Statuss = 'Completed' AND @DriverID IS NOT NULL
    BEGIN
        
        INSERT INTO Ratings (TripID, PassengerID, DriverID, Rating, Review)
        VALUES (@InsertedTripID, @DriverID, @DriverID, NULL, NULL);

       
        INSERT INTO Payments (TripID, EarnedAmount, Statuss, PaymentDate)
        VALUES (@InsertedTripID, 0, 'Unpaid', NULL);
    END
END
GO


CREATE PROCEDURE InsertPayment
    @TripID int,
    
    @EarnedAmount int,
    @Statuss varchar(6),
    @PaymentDate date = NULL
AS
BEGIN
    INSERT INTO Payments (TripID, EarnedAmount, Statuss, PaymentDate)
    VALUES (@TripID, @EarnedAmount, @Statuss, @PaymentDate);
END
GO


CREATE PROCEDURE InsertFriendsGroup
    @groupAdmin int,
   
    @TripsCompleted int = NULL
    
AS
BEGIN
    INSERT INTO FriendsGroup (groupAdmin, TripsCompleted)
    VALUES (@groupAdmin, @TripsCompleted);
END
GO


CREATE PROCEDURE InsertTripRequest
    @PassengerID int,
    @PickupLocation int,
    @DropoffLocation int,
    @TripDateTime datetime,
    @Statuss varchar(50) = 'Pending'
AS
BEGIN
    INSERT INTO TripRequests (PassengerID, PickupLocation, DropoffLocation, TripDateTime, Statuss)
    VALUES (@PassengerID, @PickupLocation, @DropoffLocation, @TripDateTime, @Statuss);
END
GO


CREATE PROCEDURE InsertRating
    @TripID int,
    @PassengerID int,
    @DriverID int,
    @Rating int,
    @Review text = NULL
AS
BEGIN
    INSERT INTO Ratings (TripID, PassengerID, DriverID, Rating, Review)
    VALUES (@TripID, @PassengerID, @DriverID, @Rating, @Review);
END
GO


CREATE PROCEDURE InsertNotification
    @UserID int,
    @TripID int = NULL,
    @Message varchar(500),
    @IsRead bit = 0
AS
BEGIN
    INSERT INTO Notifications (UserID, TripID, Message, IsRead)
    VALUES (@UserID, @TripID, @Message, @IsRead);
END
GO



/***********************
  Delete Queries
***********************/
CREATE PROCEDURE DeleteArea
    @AreaCode int
AS
BEGIN
    DELETE FROM Areas WHERE AreaCode = @AreaCode;
END
GO

CREATE PROCEDURE DeleteVehicle
    @vehicleID int
AS
BEGIN
    DELETE FROM Vehicles WHERE vehicleID = @vehicleID;
END
GO

CREATE PROCEDURE DeleteUser
    @userID int
AS
BEGIN
    DELETE FROM Users WHERE userID = @userID;
END
GO

CREATE PROCEDURE DeleteDriver
    @driverID int
AS
BEGIN
    DELETE FROM Drivers WHERE driverID = @driverID;
END
GO

CREATE PROCEDURE DeleteScheduledTrip
    @TripID int
AS
BEGIN
    DELETE FROM ScheduledTrips WHERE TripID = @TripID;
END
GO

CREATE PROCEDURE DeletePayment
    @PaymentID int
AS
BEGIN
    DELETE FROM Payments WHERE PaymentID = @PaymentID;
END
GO

CREATE PROCEDURE DeleteFriendsGroup
    @GroupNo int
AS
BEGIN
    DELETE FROM FriendsGroup WHERE GroupNo = @GroupNo;
END
GO

CREATE PROCEDURE DeleteTripRequest
    @RequestID int
AS
BEGIN
    DELETE FROM TripRequests WHERE RequestID = @RequestID;
END
GO

CREATE PROCEDURE DeleteRating
    @TripID int,@PassengerID int
AS
BEGIN
    DELETE FROM Ratings WHERE TripID = @TripID and PassengerID=@PassengerID;
END
GO

CREATE PROCEDURE DeleteNotification
    @NotificationID int
AS
BEGIN
    DELETE FROM Notifications WHERE NotificationID = @NotificationID;
END
GO



/**************************************
   Some Other Delete Procedures
***************************************/

-- Delete unmapped areas 
CREATE PROCEDURE DeleteUnmappedAreas
AS
BEGIN
    
    DELETE FROM Areas
    WHERE latitude IS NULL OR longitude IS NULL;
END
GO


-- Delete vehicles by a specific type 
CREATE PROCEDURE DeleteVehiclesByType
    @Typee varchar(7)
AS
BEGIN
    
    DELETE FROM Vehicles
    WHERE Typee = @Typee;
END
GO


-- Delete inactive users who are not admins
CREATE PROCEDURE DeleteInactiveUsers
AS
BEGIN
    
    DELETE FROM Users
    WHERE IsActive = 0 AND isAdmin = 0;
END
GO


-- Delete drivers whose availability is set to 'No'
CREATE PROCEDURE DeleteUnavailableDrivers
AS
BEGIN
    
    DELETE FROM Drivers
    WHERE Availability = 'No';
END
GO


-- Delete cancelled trips that are older than today
CREATE PROCEDURE DeleteOldCancelledTrips
AS
BEGIN
    
    DELETE FROM ScheduledTrips
    WHERE Statuss = 'Cancelled' AND DepartureTime < CAST(GETDATE() AS date);
END
GO


-- Delete unpaid payments that are older than a given date
CREATE PROCEDURE DeleteStaleUnpaidPayments
    @BeforeDate date
AS
BEGIN
    
    DELETE FROM Payments
    WHERE Statuss = 'Unpaid' AND PaymentDate IS NOT NULL AND PaymentDate < @BeforeDate;
END
GO


-- Delete friends groups with no trips completed
CREATE PROCEDURE DeleteInactiveGroups
AS
BEGIN
   
    DELETE FROM FriendsGroup
    WHERE TripsCompleted IS NULL OR TripsCompleted = 0;
END
GO


-- Delete pending trip requests older than 3 days
CREATE PROCEDURE DeleteOldPendingRequests
AS
BEGIN
    -- Deletes trip requests in pending state that are older than 3 days
    DELETE FROM TripRequests
    WHERE Statuss = 'Pending' AND TripDateTime < DATEADD(DAY, -3, GETDATE());
END
GO


-- Delete ratings where both rating and review are null
CREATE PROCEDURE DeleteEmptyRatings
AS
BEGIN
    
    DELETE FROM Ratings
    WHERE Rating IS NULL AND Review IS NULL;
END
GO


-- Delete notifications that are read and older than 7 days
CREATE PROCEDURE DeleteOldReadNotifications
AS
BEGIN
    -- Deletes read notifications older than one week
    DELETE FROM Notifications
    WHERE IsRead = 1 AND CreatedAt < DATEADD(DAY, -7, GETDATE());
END
GO


-- Delete scheduled trips that have no assigned driver and are in the past
CREATE PROCEDURE DeleteUnassignedOldTrips
AS
BEGIN
   
    DELETE FROM ScheduledTrips
    WHERE DriverID IS NULL AND DepartureTime < CAST(GETDATE() AS date);
END
GO

-- Delete payments that have zero earned amount
CREATE PROCEDURE DeleteZeroAmountPayments
AS
BEGIN
  
    DELETE FROM Payments
    WHERE EarnedAmount = 0;
END
GO

-- Delete drivers not associated with any vehicle 
CREATE PROCEDURE DeleteDriversWithoutVehicles
AS
BEGIN
    
    DELETE FROM Drivers
    WHERE vehicleID IS NULL;
END
GO

-- Delete notifications linked to trips that are marked as 'Completed'
CREATE PROCEDURE DeleteCompletedTripNotifications
AS
BEGIN
    
    DELETE FROM Notifications
    WHERE TripID IN (
        SELECT TripID FROM ScheduledTrips WHERE Statuss = 'Completed'
    );
END
GO



-- Delete areas with no users living there (unlinked areas)
CREATE PROCEDURE DeleteUnusedAreas
AS
BEGIN
    -- Deletes areas not referenced by any user
    DELETE FROM Areas
    WHERE AreaCode NOT IN (
        SELECT CurrentArea FROM Users WHERE CurrentArea IS NOT NULL
        UNION
        SELECT Preference1 FROM Users WHERE Preference1 IS NOT NULL
        UNION
        SELECT Preference2 FROM Users WHERE Preference2 IS NOT NULL
        UNION
        SELECT Preference3 FROM Users WHERE Preference3 IS NOT NULL
    );
END
GO





/**************************************
                Views
***************************************/

--Shows complete trip info: requester, driver, route, status, departure, and passengers.
CREATE VIEW vw_TripDetails AS
SELECT 
    t.TripID,
    u.Name AS RequesterName,
    d.DriverID,
    du.Name AS DriverName,
    a1.Town AS StartLocation,
    a2.Town AS Destination,
    t.Statuss,
    t.DepartureTime
FROM ScheduledTrips t
LEFT JOIN Users u ON t.DriverID = u.UserID
LEFT JOIN Drivers d ON t.DriverID = d.DriverID
LEFT JOIN Users du ON d.DriverID = du.UserID
LEFT JOIN Areas a1 ON t.StartLocation = a1.AreaCode
LEFT JOIN Areas a2 ON t.Destination = a2.AreaCode;
GO

--Provides a cleaner public-facing version of users without passwords or sensitive info.
CREATE VIEW vw_UsersBasicInfo AS
SELECT 
    UserID,
    Name,
    Email,
    Gender,
    Age,
    City,
    UserStatus,
    Contact,
    IsActive,
    isAdmin
FROM Users;
GO

--Shows driver profiles with associated vehicle data.
CREATE VIEW vw_DriverProfiles AS
SELECT 
    d.DriverID,
    u.Name AS DriverName,
    u.Email,
    v.Name AS VehicleName,
    v.Typee,
    v.Capacity,
    d.DriverStatus,
    d.Availability
FROM Drivers d
JOIN Users u ON d.DriverID = u.UserID
LEFT JOIN Vehicles v ON d.VehicleID = v.VehicleID;
Go

--Payments made for completed trips along with driver names and amounts.
CREATE VIEW vw_TripPayments AS
SELECT 
    p.PaymentID,
    p.TripID,
    u.Name AS DriverName,
    p.EarnedAmount,
    p.Statuss,
    p.PaymentDate
FROM Payments p
JOIN Drivers d ON p.DriverID = d.DriverID
JOIN Users u ON d.DriverID = u.UserID;
Go

--View all unapproved trip requests with passenger names.
CREATE VIEW vw_TripRequestsPending AS
SELECT 
    r.RequestID,
    u.Name AS PassengerName,
    r.PickupLocation,
    r.DropoffLocation,
    r.TripDateTime,
    r.Statuss
FROM TripRequests r
JOIN Users u ON r.PassengerID = u.UserID
WHERE r.Statuss = 'Pending';
GO


--Shows reviews and ratings for each trip with both driver and passenger names.
CREATE VIEW vw_RatingsSummary AS
SELECT 
  
    r.TripID,
    ru.Name AS PassengerName,
    du.Name AS DriverName,
    r.Rating,
    r.Review,
    r.RatedAt
FROM Ratings r
JOIN Users ru ON r.PassengerID = ru.UserID
JOIN Users du ON r.DriverID = du.UserID;
Go

--View of unread notifications with user names and trip info (if any).
CREATE VIEW vw_NotificationsUnread AS
SELECT 
    n.NotificationID,
    u.Name AS UserName,
    n.TripID,
    n.Message,
    n.CreatedAt
FROM Notifications n
JOIN Users u ON n.UserID = u.UserID
WHERE n.IsRead = 0;
GO

SELECT * FROM vw_TripDetails;
SELECT * FROM vw_UsersBasicInfo;
SELECT * FROM vw_DriverProfiles;
SELECT * FROM vw_TripPayments;

SELECT * FROM vw_TripRequestsPending;
SELECT * FROM vw_RatingsSummary;
SELECT * FROM vw_NotificationsUnread;



-- Drop tables in order from dependent to independent

--DROP TABLE IF EXISTS Notifications;
--DROP TABLE IF EXISTS Ratings;
--DROP TABLE IF EXISTS TripRequests;
--DROP TABLE IF EXISTS FriendsGroup;
--DROP TABLE IF EXISTS Payments;
--DROP TABLE IF EXISTS ScheduledTrips;
--DROP TABLE IF EXISTS Drivers;
--DROP TABLE IF EXISTS Vehicles;
--DROP TABLE IF EXISTS Users;
--DROP TABLE IF EXISTS Areas;


CREATE PROCEDURE GetFilteredTrips
    @start INT = NULL,
    @dest INT = NULL,
    @seats INT = 1
AS
BEGIN
    SELECT * FROM ScheduledTrips
    WHERE Statuss = 'Ongoing'
      AND (@start IS NULL OR StartLocation = @start)
      AND (@dest IS NULL OR Destination = @dest)
      AND  @seats<= (select v.capacity from ScheduledTrips st join Drivers d on st.DriverID=d.driverID
	  join Vehicles v on d.vehicleID=v.vehicleID)
END
GO


CREATE PROCEDURE GetUserLocation
    @userID INT
AS
BEGIN
    SELECT a.latitude, a.longitude
    FROM Users u
    JOIN Areas a ON u.CurrentArea = a.AreaCode
    WHERE u.userID = @userID;
END
GO


CREATE PROCEDURE GetUserProfile
    @userID INT
AS
BEGIN
    SELECT * FROM Users WHERE UserID = @userID;
END
GO




CREATE PROCEDURE GetTripsByUserLocation
    @userLocation INT
AS
BEGIN
    SELECT * 
    FROM ScheduledTrips
    WHERE Statuss = 'Ongoing' or Statuss='Scheduled'
      AND CurrentLocation = @userLocation
END
GO


CREATE PROCEDURE GetSameGenderTrips
@userGender VARCHAR(10),
@userLocation INT
AS
BEGIN
SELECT ST.*
FROM ScheduledTrips ST
JOIN Users U ON ST.DriverID = U.UserID
WHERE ST.Statuss = 'Ongoing'
AND ST.CurrentLocation = @userLocation
AND U.Gender = @userGender
END
GO

CREATE PROCEDURE GetDriverAverageRating @driverID INT 
AS 
BEGIN 
SELECT AVG(CAST(Rating AS FLOAT)) AS AverageRating, COUNT(*) AS TotalRatings FROM Ratings WHERE DriverID = @driverID; 
END
Go

CREATE PROCEDURE GetFriendGroup @userName VARCHAR(255)
AS
BEGIN
    SELECT groupAdmin, TripsCompleted
    FROM FriendsGroup
    WHERE groupAdmin = @userName;
END;
Go

CREATE PROCEDURE GetRecentTrips @userID INT
AS
BEGIN
    SELECT TripID, Statuss, StartLocation, Destination, DepartureTime
    FROM ScheduledTrips
    WHERE DriverID = @userID
    ORDER BY DepartureTime DESC;
END;
GO

CREATE PROCEDURE GetPreferredAreas @userID INT
AS
BEGIN
    SELECT Name, Preference1, Preference2, Preference3
    FROM users
    WHERE userID = @userID;
END;


--Tables
select * from Users;
select * from Drivers;
select * from Areas;
select * from Vehicles;
select * from ScheduledTrips;
select * from Payments;
select * from FriendsGroup;
select * from TripRequests;
select * from Ratings;
select * from Notifications;


-----------------------------------------------------------------------------------

--When a new payment is inserted into the Payments table

CREATE TRIGGER trg_PaymentNotification
ON Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        (select st.DriverID from ScheduledTrips st join Payments p on st.TripID=p.TripID),
        i.TripID,
        CONCAT('💸 You earned PKR ', i.EarnedAmount, ' for Trip #', i.TripID),
        0,
        GETDATE()
    FROM inserted i;
END;
GO


--Trigger when a new trip is inserted into ScheduledTrips with a DriverID.
CREATE TRIGGER trg_TripAssignedNotification
ON ScheduledTrips
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.DriverID,
        i.TripID,
        '🚗 You have been assigned a new trip.',
        0,
        GETDATE()
    FROM inserted i
    WHERE i.DriverID IS NOT NULL;
END;
GO


--When a trip request’s Status becomes 'Approved':
CREATE TRIGGER trg_TripRequestApprovedNotification
ON TripRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.PassengerID,
        NULL,
        '✅ Your trip request has been approved!',
        0,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.RequestID = d.RequestID
    WHERE i.Statuss = 'approved' AND d.Statuss <> 'approved';
END;
GO


CREATE TRIGGER trg_TripCancelledNotification
ON ScheduledTrips
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Notify Driver
    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.DriverID,
        i.TripID,
        CONCAT('❌ Trip #', i.TripID, ' has been cancelled.'),
        0,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.TripID = d.TripID
    WHERE i.Statuss = 'Cancelled' AND d.Statuss <> 'Cancelled' AND i.DriverID IS NOT NULL;

    -- Notify Requester
    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.DriverID,
        i.TripID,
        CONCAT('❌ Your trip #', i.TripID, ' has been cancelled.'),
        0,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.TripID = d.TripID
    WHERE i.Statuss = 'Cancelled' AND d.Statuss <> 'Cancelled' AND i.DriverID IS NOT NULL;
END;
GO


CREATE OR ALTER TRIGGER trg_EnforceOneOngoingTripPerUser
ON ScheduledTrips
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT UserID
        FROM (
            SELECT DriverID AS UserID
            FROM ScheduledTrips
            WHERE Statuss = 'Ongoing'
            UNION ALL
            SELECT DriverID AS UserID
            FROM ScheduledTrips
            WHERE Statuss = 'Ongoing'
        ) combined
        GROUP BY UserID
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR ('A user cannot be involved in more than one ongoing trip (as requester or driver).', 16, 1);
        ROLLBACK;
    END
END;
GO





CREATE TRIGGER trg_RestrictPaymentToCompletedTrips
ON Payments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ScheduledTrips st ON i.TripID = st.TripID
        WHERE st.Statuss != 'Completed'
    )
    BEGIN
        RAISERROR ('Payments can only be logged for trips that are marked as Completed.', 16, 1);
        ROLLBACK;
        RETURN;
    END

    -- If all trips are completed, proceed with the insert
    INSERT INTO Payments (TripID, EarnedAmount, Statuss, PaymentDate)
    SELECT TripID, EarnedAmount, Statuss, PaymentDate FROM inserted;
END;


go

CREATE TRIGGER trg_RatingGivenNotification
ON Ratings
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.DriverID,
        i.TripID,
        CONCAT('🌟 You received a new rating: ', i.Rating, '/5. Check your feedback!'),
        0,
        GETDATE()
    FROM inserted i
    WHERE i.Rating IS NOT NULL;
END;

go

CREATE or alter TRIGGER trg_TripCompletedNotification
ON ScheduledTrips
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserID, TripID, Message, IsRead, CreatedAt)
    SELECT 
        i.DriverID,
        i.TripID,
        CONCAT('🎉 Your trip #', i.TripID, ' has been completed. You have a new trip to rate! '),
        0,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.TripID = d.TripID
    WHERE i.Statuss = 'Completed' AND d.Statuss <> 'Completed'
          AND i.DriverID IS NOT NULL AND i.DriverID IS NOT NULL;
END;
GO


CREATE TRIGGER trg_OnlyAllowDriversInDriversTable
ON Drivers
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Only allow insert if the user has UserStatus = 'Driver'
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Users u ON i.driverID = u.userID
        WHERE u.UserStatus != 'Driver'
    )
    BEGIN
        RAISERROR('❌ Cannot insert into Drivers: The user is not marked as a Driver in Users table.', 16, 1);
        ROLLBACK;
        RETURN;
    END

    -- If valid, insert into Drivers table
    INSERT INTO Drivers (driverID, vehicleID, DriverStatus, Availability)
    SELECT driverID, vehicleID, DriverStatus, Availability
    FROM inserted;
END;
GO







-- Step 1: Insert Areas
INSERT INTO Areas (AreaCode, City, Town, Road, Block, sector, Place, NearbyAreas, latitude, longitude) VALUES
(1, 'Lahore', 'Model Town', 'Main Blvd', 1, 'A', 'Home', 'Near Kalma Chowk', 31.5204, 74.3587),
(2, 'Lahore', 'DHA', 'Phase 5', 5, 'B', 'Office', 'Near LUMS', 31.4700, 74.4100);

-- Step 2: Insert Vehicles
INSERT INTO Vehicles (Name, Color, Company, Typee, Capacity) VALUES
('Civic', 'White', 'Honda', 'Comfort', 4),
('Fortuner', 'Black', 'Toyota', 'Luxury', 7);

-- Step 3: Insert Users (only 2 drivers, 3 non-drivers)
INSERT INTO Users (Name, Email, Password, Gender, Age, City, UserStatus, Contact, EmergencyContact, CurrentArea, Preference1, Preference2, Preference3) VALUES
-- Drivers
('Ali Driver', 'ali.driver@email.com', 'pass123', 'Male', 30, 'Lahore', 'Driver', '03000000001', '03110000001', 1, 2, 1, 2),
('Sara Driver', 'sara.driver@email.com', 'pass123', 'Female', 29, 'Lahore', 'Driver', '03000000002', '03110000002', 2, 1, 2, 1),
-- Non-drivers
('Usman Passenger', 'usman@email.com', 'pass123', 'Male', 26, 'Lahore', 'Non-Driver', '03000000003', '03110000003', 1, 2, 1, 2),
('Fatima Passenger', 'fatima@email.com', 'pass123', 'Female', 28, 'Lahore', 'Non-Driver', '03000000004', '03110000004', 2, 1, 2, 1),
('Hassan Passenger', 'hassan@email.com', 'pass123', 'Male', 24, 'Lahore', 'Non-Driver', '03000000005', '03110000005', 1, 2, 1, 2);

-- Step 4: Insert Drivers (map to correct users and vehicles)
INSERT INTO Drivers (driverID, vehicleID, DriverStatus, Availability) VALUES
(1, 1, 'Hired', 'Yes'),
(2, 2, 'Collaborator', 'Yes');

-- Step 5: Insert Scheduled Trips (drivers ≠ requesters)
-- Passenger Usman (UserID = 3), Driver = Ali (UserID = 1)
INSERT INTO ScheduledTrips (RequesterID, AvailableSeats, DriverID, StartLocation, Destination, Statuss, Routee, CurrentLocation, ExpectedDuration, DepartureTime, Travelers)
VALUES
(3, 2, 1, 1, 2, 'Ongoing', 'Via Kalma', 1, 30, GETDATE(), 'Usman, Ali');

-- Passenger Fatima (UserID = 4), Driver = Sara (UserID = 2)
INSERT INTO ScheduledTrips (RequesterID, AvailableSeats, DriverID, StartLocation, Destination, Statuss, Routee, CurrentLocation, ExpectedDuration, DepartureTime, Travelers)
VALUES
(4, 3, 2, 2, 1, 'Completed', 'Via DHA', 2, 35, GETDATE(), 'Fatima, Sara');

-- Passenger Hassan (UserID = 5), Driver = Ali (UserID = 1)
INSERT INTO ScheduledTrips (RequesterID, AvailableSeats, DriverID, StartLocation, Destination, Statuss, Routee, CurrentLocation, ExpectedDuration, DepartureTime, Travelers)
VALUES
(5, 2, 1, 1, 2, 'Ongoing', 'Alternate Route', 1, 40, GETDATE(), 'Hassan, Ali');

GO






ALTER TRIGGER trg_EnforceOneOngoingTripPerUser
ON ScheduledTrips
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only perform this logic if the new row is still marked as 'Ongoing'
    IF EXISTS (SELECT 1 FROM inserted WHERE Statuss = 'Ongoing')
    BEGIN
        -- Check for duplicate ongoing trip as Requester
        IF EXISTS (
            SELECT 1
            FROM ScheduledTrips st
            JOIN inserted i ON i.DriverID = st.DriverID
            WHERE 
                st.Statuss = 'Ongoing' 
                AND st.TripID <> i.TripID
        )
        BEGIN
            RAISERROR('❌ A user cannot be involved in more than one ongoing trip as requester.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Check for duplicate ongoing trip as Driver
        IF EXISTS (
            SELECT 1
            FROM ScheduledTrips st
            JOIN inserted i ON i.DriverID = st.DriverID
            WHERE 
                st.Statuss = 'Ongoing'
                AND st.TripID <> i.TripID
        )
        BEGIN
            RAISERROR('❌ A user cannot be involved in more than one ongoing trip as driver.', 16, 1);
            ROLLBACK;
            RETURN;
        END
    END
END;
GO








CREATE PROCEDURE AddFriendToGroup
  @groupNo INT,
  @friendID INT
AS
BEGIN
  DECLARE @members VARCHAR(MAX), @newMembers VARCHAR(MAX), @memberCount INT;

  SELECT @members = OtherMembers, @memberCount = TotalMembers
  FROM FriendsGroup
  WHERE GroupNo = @groupNo;

  IF @memberCount >= 4
  BEGIN
    RAISERROR('Group already has maximum number of members.', 16, 1);
    RETURN;
  END

  IF CHARINDEX(',' + CAST(@friendID AS VARCHAR) + ',', ',' + ISNULL(@members, '') + ',') > 0
  BEGIN
    RAISERROR('Friend already in the group.', 16, 1);
    RETURN;
  END

  SET @newMembers = CASE 
    WHEN @members IS NULL OR LTRIM(RTRIM(@members)) = '' THEN CAST(@friendID AS VARCHAR)
    ELSE @members + ',' + CAST(@friendID AS VARCHAR)
  END;

  UPDATE FriendsGroup
  SET OtherMembers = @newMembers,
      TotalMembers = TotalMembers + 1
  WHERE GroupNo = @groupNo;
END;


go

CREATE PROCEDURE RemoveFriendFromGroup
  @groupNo INT,
  @friendID INT
AS
BEGIN
  DECLARE @members VARCHAR(MAX), @newMembers VARCHAR(MAX);

  SELECT @members = OtherMembers
  FROM FriendsGroup
  WHERE GroupNo = @groupNo;

  IF @members IS NULL
  BEGIN
    RAISERROR('Group has no members.', 16, 1);
    RETURN;
  END

  -- Wrap and remove the ID
  SET @members = ',' + @members + ',';
  SET @newMembers = REPLACE(@members, ',' + CAST(@friendID AS VARCHAR) + ',', ',');

  -- Trim leading and trailing comma
  SET @newMembers = LTRIM(RTRIM(
    CASE 
      WHEN LEFT(@newMembers, 1) = ',' THEN SUBSTRING(@newMembers, 2, LEN(@newMembers))
      ELSE @newMembers
    END
  ));

  SET @newMembers = 
    CASE 
      WHEN RIGHT(@newMembers, 1) = ',' THEN LEFT(@newMembers, LEN(@newMembers) - 1)
      ELSE @newMembers
    END;

	GO

CREATE PROCEDURE RemoveFriendFromGroup
  @groupNo INT,
  @friendID INT
AS
BEGIN
  DECLARE @members VARCHAR(MAX), @newMembers VARCHAR(MAX), @admin INT;

  SELECT @members = OtherMembers, @admin = groupAdmin
  FROM FriendsGroup
  WHERE GroupNo = @groupNo;

  IF @members IS NULL
  BEGIN
    RAISERROR('Group has no members.', 16, 1);
    RETURN;
  END

  -- ⛔ Prevent removing the admin
  IF @admin = @friendID
  BEGIN
    RAISERROR('Cannot remove the group admin.', 16, 1);
    RETURN;
  END

  -- Wrap and remove the ID
  SET @members = ',' + @members + ',';
  SET @newMembers = REPLACE(@members, ',' + CAST(@friendID AS VARCHAR) + ',', ',');

  -- Trim commas
  SET @newMembers = LTRIM(RTRIM(CASE 
    WHEN LEFT(@newMembers, 1) = ',' THEN SUBSTRING(@newMembers, 2, LEN(@newMembers))
    ELSE @newMembers
  END));
  SET @newMembers = CASE 
    WHEN RIGHT(@newMembers, 1) = ',' THEN LEFT(@newMembers, LEN(@newMembers) - 1)
    ELSE @newMembers
  END;

  -- Update group
  UPDATE FriendsGroup
  SET OtherMembers = @newMembers,
      TotalMembers = TotalMembers - 1
  WHERE GroupNo = @groupNo;
END;
GO



CREATE OR ALTER PROCEDURE AddFriendToGroup
  @groupNo INT,
  @friendID INT
AS
BEGIN
  DECLARE @members VARCHAR(MAX), 
          @newMembers VARCHAR(MAX), 
          @memberCount INT,
          @admin INT;

  -- Check if the user exists in Users table
  IF NOT EXISTS (SELECT 1 FROM Users WHERE userID = @friendID)
  BEGIN
    RAISERROR('❌ This user does not exist.', 16, 1);
    RETURN;
  END

  -- Get group data
  SELECT @members = OtherMembers, 
         @memberCount = TotalMembers,
         @admin = groupAdmin
  FROM FriendsGroup
  WHERE GroupNo = @groupNo;

  -- Group not found
  IF @admin IS NULL
  BEGIN
    RAISERROR('❌ Group not found.', 16, 1);
    RETURN;
  END

  -- Prevent adding admin to group again
  IF @friendID = @admin
  BEGIN
    RAISERROR('❌ Cannot add the admin again.', 16, 1);
    RETURN;
  END

  -- Prevent duplicate friend addition
  IF CHARINDEX(',' + CAST(@friendID AS VARCHAR) + ',', ',' + ISNULL(@members, '') + ',') > 0
  BEGIN
    RAISERROR('❌ Friend is already in the group.', 16, 1);
    RETURN;
  END

  -- Limit to 4 total members (admin + 3 friends)
  IF @memberCount >= 4
  BEGIN
    RAISERROR('❌ Group already has maximum members (4).', 16, 1);
    RETURN;
  END

  -- Append friend ID
  SET @newMembers = CASE 
    WHEN @members IS NULL OR LTRIM(RTRIM(@members)) = '' 
      THEN CAST(@friendID AS VARCHAR)
    ELSE @members + ',' + CAST(@friendID AS VARCHAR)
  END;

  -- Update group
  UPDATE FriendsGroup
  SET OtherMembers = @newMembers,
      TotalMembers = TotalMembers + 1
  WHERE GroupNo = @groupNo;

  PRINT '✅ Friend successfully added.';
END;
GO