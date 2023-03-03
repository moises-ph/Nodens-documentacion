use master;
drop database if exists AuthServiceDB;
create database AuthServiceDB;
use AuthServiceDB;

create table Users(
	id int primary key identity(1,1),
	email varchar(320) unique not null,
	password varchar(max) not null,
	Name varchar(100) not null,
	Lastname varchar(100) not null,
	created_at date not null,
	updated_at date not null,
	Verified bit not null
);

create table Role(
	id int primary key identity(1,1),
	name varchar(50) not null
);

create table UserRoleAssingment(
	users_id int not null,
	role_id int not null,
	constraint fk_users foreign key (users_id) references Users(id),
	constraint fk_role foreign key (role_id) references Role(id)
);

create table Permission(
	id int primary key identity(1,1),
	name varchar(100) not null,
	description varchar(500) not null
);

create table RolePermissions(
	role_id int not null,
	permission_id int not null,
	constraint fk_role_2 foreign key (role_id) references Role(id),
	constraint fk_permission foreign key (permission_id) references Permission(id)
);

--------------------------------------------------------------------------------------------------------


INSERT into Role(name



--------------------------------------------------------------------------------------------------------

go
create procedure SP_CreateUser
	@Email varchar(320),
	@Name varchar(100),
	@Lastname varchar(100),
	@Password varchar(max),
	@Role varchar(50)
as
begin transaction TX_New_User
	BEGIN TRY
		INSERT INTO Users(email,password, Name, Lastname, created_at,updated_at,Verified)
		values (@Email, @Password, @Name, @Lastname,GETDATE(), GETDATE(), 0)

		INSERT INTO UserRoleAssingment(users_id, role_id)
		values ((select id from Users where email = @Email), (select id from Role where name = @Role))
		COMMIT TRANSACTION TX_New_User
		SELECT 'Usuario Creado Correctamente' as Message, 0 as Error
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION TX_New_User
		SELECT ERROR_MESSAGE() as Message, 1 as Error
	END CATCH
go
---------------------------------

execute SP_CreateUser 'email@gmail.com', 'Juan', 'Eduardo', '1234', 'Musician'


go
create procedure SP_ReadUser
	@Email varchar(320)
as
begin
	SELECT Name, Lastname, (select name from Role where UserRoleAssingment.role_id = id) from Users inner join UserRoleAssingment on Users.id = UserRoleAssingment.users_id where email = @Email
end
go

---------------------------------

go
create procedure SP_AuthUser
	@Email varchar(320)
as
begin
	if exists(SELECT id from Users where email = @Email)
		SELECT password from Users where email = @Email
	else
		SELECT null as password
end
go

-----------------------

go
create procedure SP_ChangePassword
	@Email varchar(320),
	@NewPass varchar(max)
as
begin transaction TX_ChangePassword
	BEGIN TRY
		UPDATE Users set password = @NewPass where email = @Email
		COMMIT TRANSACTION TX_ChangePassword
		SELECT 'Contraseña actualizada correctamente' as Message, 0 as Error
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION TX_ChangePassword
		SELECT ERROR_MESSAGE() as Message, 1 as Eror
	END CATCH
go

----------------------

go 
create procedure SP_DeleteUser
	@Email varchar(320)
as
begin transaction TX_DeleteUser
	BEGIN TRY	
		declare @id int
		SELECT @id = id from Users where email = @Email
		
		DELETE FROM UserRoleAssingment where users_id = @id
		DELETE FROM Users where id = @id
		COMMIT TRANSACTION TX_DeleteUser
		SELECT 'Usuario eliminado correctamente' as Message, 0 as Error
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION TX_DeleteUser
		SELECT ERROR_MESSAGE() as Message, 1 as Eror
	END CATCH
go

-------------------