# CineBook SQL Server setup

Use this guide when a teammate only needs to get the CineBook database running.
For full NetBeans/Tomcat setup, see the repository root `README.md`.

## What you need

- SQL Server 2019 or newer.
- SQL Server Management Studio, Azure Data Studio, or `sqlcmd`.
- A SQL Server instance you can connect to with Windows Authentication.
- A SQL Server login for the application, usually `cinebook_app`.

Common local server names:

```text
localhost
.
localhost\SQLEXPRESS
YOUR-COMPUTER-NAME\SQLEXPRESS
```

If you are not sure which one is correct, open SSMS and copy the server name
shown at the top of Object Explorer after you connect.

## Fast path with sqlcmd

Run these commands from the repository root. Change `localhost` to your SQL
Server instance name if needed.

```powershell
sqlcmd -S localhost -E -C -Q "IF DB_ID('CineBook') IS NULL CREATE DATABASE CineBook"
sqlcmd -S localhost -E -C -d CineBook -b -i ".\src\main\resources\db\schema.sql"
sqlcmd -S localhost -E -C -d CineBook -b -i ".\src\main\resources\db\seed.sql"
sqlcmd -S localhost -E -C -d CineBook -b -f 65001 -i ".\src\main\resources\db\real-catalog-seed.sql"
```

What the scripts do:

- `schema.sql` creates tables, indexes, constraints, views, and stored
  procedures.
- `seed.sql` inserts demo users, cinemas, rooms, seats, showtimes, combos,
  promotions, banners, reviews, and one historical booking.
- `real-catalog-seed.sql` imports the generated Lotte Cinema VN movie catalog,
  hides the fictional active movies, creates demo showtimes for the imported
  now-showing movies, and replaces homepage banners with real movie promos.

The scripts are additive and safe to run again in a development database.

## SSMS path

1. Connect to SQL Server in SSMS.
2. Create the database:

   ```sql
   IF DB_ID(N'CineBook') IS NULL
   BEGIN
       CREATE DATABASE CineBook;
   END;
   GO
   ```

3. Open `src\main\resources\db\schema.sql`.
4. Set the database dropdown to `CineBook`, then execute.
5. Open `src\main\resources\db\seed.sql`, keep the dropdown on `CineBook`,
   then execute.
6. Open `src\main\resources\db\real-catalog-seed.sql`, keep the dropdown on
   `CineBook`, then execute.

If Vietnamese movie text looks broken, reopen `real-catalog-seed.sql` as UTF-8.
When using `sqlcmd`, the `-f 65001` flag handles this.

## Create the application login

The Java app should not connect as your Windows administrator account. Create a
normal read/write login and choose your own strong password.

```sql
USE master;
GO

IF SUSER_ID(N'cinebook_app') IS NULL
BEGIN
    CREATE LOGIN cinebook_app
    WITH PASSWORD = N'ChangeThis_StrongPassword_123!',
         CHECK_POLICY = ON;
END;
GO

USE CineBook;
GO

IF USER_ID(N'cinebook_app') IS NULL
BEGIN
    CREATE USER cinebook_app FOR LOGIN cinebook_app;
END;
GO

IF IS_ROLEMEMBER(N'db_datareader', N'cinebook_app') <> 1
BEGIN
    ALTER ROLE db_datareader ADD MEMBER cinebook_app;
END;
GO

IF IS_ROLEMEMBER(N'db_datawriter', N'cinebook_app') <> 1
BEGIN
    ALTER ROLE db_datawriter ADD MEMBER cinebook_app;
END;
GO
```

If SQL Server rejects SQL logins, enable mixed authentication:

1. In SSMS, right-click the top server node.
2. Select **Properties**.
3. Open **Security**.
4. Select **SQL Server and Windows Authentication mode**.
5. Restart the SQL Server service.

## Configure the Java connection

The app reads database settings in this order:

1. JVM properties: `cinebook.db.url`, `cinebook.db.user`,
   `cinebook.db.password`.
2. Environment variables: `CINEBOOK_DB_URL`, `CINEBOOK_DB_USER`,
   `CINEBOOK_DB_PASSWORD`.
3. Local classpath file: `src/main/resources/cinebook-local.properties`.

For local development, the properties file is usually easiest:

```powershell
Copy-Item ".\src\main\resources\cinebook-local.properties.example" `
  ".\src\main\resources\cinebook-local.properties"
```

Then edit `src\main\resources\cinebook-local.properties`:

```properties
url=jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true
user=cinebook_app
password=the-password-you-chose
```

For a named `SQLEXPRESS` instance, use:

```properties
url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=CineBook;encrypt=true;trustServerCertificate=true
```

The real `cinebook-local.properties` file is ignored by Git. Do not commit real
database passwords.

## Verify the database

Run this after the three scripts finish:

```sql
USE CineBook;
GO

SELECT COUNT(*) AS Movies FROM dbo.movies;
SELECT COUNT(*) AS Cinemas FROM dbo.cinemas;
SELECT COUNT(*) AS Showtimes FROM dbo.showtimes;
SELECT COUNT(*) AS Seats FROM dbo.seats;
SELECT COUNT(*) AS Combos FROM dbo.combos;

SELECT COUNT(*) AS RealMovies
FROM dbo.movies
WHERE source_ref LIKE 'LOTTE-%'
  AND is_active = 1;

SELECT COUNT(*) AS RealDemoShowtimes
FROM dbo.showtimes
WHERE source_ref LIKE 'LOTTE-DEMO-%'
  AND status = 'SCHEDULED';
GO
```

Expected development results after the real catalog import:

```text
Movies:            59 or more
Cinemas:            4
Showtimes:         43 or more
Seats:            396
Combos:             4
RealMovies:        52
RealDemoShowtimes: 30
```

Demo accounts use the password `password`:

- `customer@cinebook.vn`
- `admin@cinebook.vn`

## Build and run

After the database and connection settings are ready:

```powershell
mvn test
mvn clean package
```

Deploy `target\cinebook.war` to Tomcat 10.1 or run the Maven web project from
NetBeans. Open:

```text
http://localhost:8080/cinebook/
```

## Troubleshooting

### Login failed for user `cinebook_app`

- Confirm mixed authentication is enabled and SQL Server was restarted.
- Confirm `cinebook_app` exists under **Security -> Logins**.
- Confirm `CineBook -> Security -> Users` contains `cinebook_app`.
- Re-enter the password in `cinebook-local.properties` or environment
  variables.
- Restart NetBeans or Tomcat after changing environment variables.

### TCP/IP connection to localhost:1433 failed

- Enable TCP/IP in SQL Server Configuration Manager.
- Restart SQL Server after enabling TCP/IP.
- Check whether your server is a default instance or `SQLEXPRESS`.
- For `SQLEXPRESS`, try the `instanceName=SQLEXPRESS` JDBC URL above.

### The app shows a database-operation error

- Confirm `CineBook` exists.
- Run `schema.sql`, then `seed.sql`, then `real-catalog-seed.sql`.
- Confirm the app login has `db_datareader` and `db_datawriter`.
- Check the Tomcat or NetBeans output for the exact SQL Server message.

### No movies or showtimes appear

- Run the verification queries above.
- If `RealMovies` is `0`, rerun `real-catalog-seed.sql`.
- If `RealDemoShowtimes` is `0`, rerun `real-catalog-seed.sql` after
  `seed.sql`.

### Forms return HTTP 403 after restart

This is usually a stale CSRF token. Reload the page, sign in again, and submit
the form from a fresh page.
