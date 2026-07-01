# CineBook

CineBook is a Java 17 cinema booking system built with Jakarta Servlets, JSP,
SQL Server, Maven, Tomcat 10.1, Tailwind CSS CDN, and vanilla JavaScript.

## Project status

- [x] Maven WAR project for Java 17, Jakarta Servlets, JSP, and Tomcat 10.1.
- [x] Customer registration, login, logout, BCrypt passwords, role-based access,
      servlet filters, CSRF validation, and protected JSP pages.
- [x] Movie catalog with details, trailers, search, genre and format filters,
      city filtering, and a Lotte Cinema VN movie import.
- [x] Showtime selection, STANDARD/VIP/COUPLE seat maps, and transactional
      seven-minute SQL Server seat holds.
- [x] Food and beverage combo selection, promotion codes, demo tax, and service
      fee calculation.
- [x] Booking history and electronic booking-code tickets.
- [x] Admin navigation and scaffold screens for management workflows.
- [x] SQL Server schema, demo seed data, and setup documentation.

## Use cases

| UC | Use case | Main route |
|---|---|---|
| UC1 | Select theater and showtime by movie | `/booking/showtimes` |
| UC2 | Display and select available, sold, VIP, and couple seats | `/booking/seats` |
| UC3 | Add food and beverage combos to a booking | `/booking/combos` |
| UC4 | Calculate ticket, combo, tax, fee, and promotion totals | `/checkout` |
| UC5 | Hold selected seats temporarily during booking | `/api/seat-holds` |
| UC6 | View Now Showing and Coming Soon movie lists | `/movies` |
| UC7 | View movie summary, director, cast, and trailer | `/movies/{id}` |
| UC8 | Search movies by name | `/movies?q=...` |
| UC9 | Filter movies by genre or format | `/movies?genre=...&format=...` |
| UC10 | Search and filter cinemas by city or region | `/cinemas` |
| UC11 | Add, update, and delete movie information | `/admin/movies` |
| UC12 | Manage cinemas and showrooms | `/admin/cinemas`, `/admin/showrooms` |
| UC13 | Create and allocate showtimes for screening rooms | `/admin/showtimes` |
| UC14 | Manage combo catalog and pricing | `/admin/combos` |
| UC15 | Set up static seat layouts for screening rooms | `/admin/seat-layouts`, `/admin/seats/view` |
| UC16 | View revenue statistics by day, movie, or theater | `/admin`, `/admin/analytics` |
| UC17 | View, lock, and unlock customer accounts | `/admin/accounts` |
| UC18 | Manage discount codes and promotions | `/admin/promotions` |
| UC19 | Moderate review content | `/admin/reviews` |
| UC20 | Manage homepage banner and slider advertisements | `/admin/banners` |
| UC21 | Apply discount codes and complete the current checkout flow | `/checkout` |
| UC22 | View booking history and ticket status | `/profile/bookings` |
| UC23 | Rate and review watched movies | `/reviews`, `/profile/reviews` |
| UC24 | Create and manage a personal watchlist | `/profile/watchlist` |
| UC25 | Display electronic ticket codes for entry | `/tickets/{code}` |

UC21 is limited to the current checkout boundary. A real external payment
gateway is intentionally not required for this milestone.

## Sitemap

### Public pages

- `/` - redirects to the movie catalog.
- `/movies` - movie catalog, Now Showing, Coming Soon, search, and filters.
- `/movies/{id}` - movie details, trailer, showtimes, and reviews.
- `/cinemas` - cinema list and city/region filter.
- `/login` or `/auth/login` - customer and admin sign in.
- `/register` or `/auth/register` - customer registration.
- `/logout` or `/auth/logout` - sign out.

### Booking flow

- `/booking/showtimes` - choose cinema, date, and showtime for a movie.
- `/booking/seats` - choose STANDARD, VIP, or COUPLE seats.
- `/api/seat-holds` - JSON endpoint for creating, updating, and clearing seat holds.
- `/booking/combos` - choose food and beverage combos.
- `/checkout` - review pricing, apply promotion codes, and finalize the booking flow.
- `/tickets/{code}` - electronic ticket / booking code page.

### Customer profile

- `/profile/bookings` - booking history and ticket status.
- `/profile/watchlist` - saved movies.
- `/profile/reviews` - customer review history.
- `/reviews` - review submission endpoint.

### Admin pages

- `/admin` - dashboard.
- `/admin/analytics` - revenue statistics.
- `/admin/movies` - movie management.
- `/admin/cinemas` - cinema management.
- `/admin/showrooms` - showroom management.
- `/admin/showtimes` - showtime management.
- `/admin/combos` - combo management.
- `/admin/seat-layouts` - seat layout list.
- `/admin/seats/view` - seat layout editor.
- `/admin/accounts` - customer account management.
- `/admin/promotions` - promotion management.
- `/admin/reviews` - review moderation.
- `/admin/banners` - homepage banner management.

## Still to do

- [ ] Finish CRUD actions behind the remaining admin screens: movies, cinemas,
      showrooms, showtimes, combos, seat layouts, accounts, analytics,
      promotions, reviews, and banners.
- [ ] Persist customer watchlists, watched-movie ratings, and review
      submissions.
- [ ] Add QR-code ticket generation if the final requirements need it. Booking
      codes already support the current electronic-ticket flow.
- [ ] Run the booking flow in two browsers using the final team database
      credentials.
- [ ] Add more SQL Server integration tests for seat holds, expired checkout,
      and booking-history snapshots.
- [ ] Import real cinemas, rooms, showtimes, prices, and seat availability if
      the project must go beyond the current real movie catalog and demo
      schedule.
- [ ] Set secure production cookies and HTTPS before deployment outside a local
      classroom environment.

## Prerequisites

- [ ] Java JDK 17
- [ ] Maven 3.8 or newer
- [ ] Apache Tomcat 10.1
- [ ] Microsoft SQL Server 2019 or newer
- [ ] SQL Server authentication credentials for the application

NetBeans 17 includes Maven at:

```text
C:\Program Files\NetBeans-17\netbeans\java\maven\bin\mvn.cmd
```

## What each technology does

If this is your first Java web project, this is the basic structure:

| Technology | Purpose in CineBook |
|---|---|
| Java 17 | Application language |
| Servlet | Receives browser requests and decides what the application should do |
| JSP/JSTL | Generates the HTML pages shown to users |
| Maven | Downloads Java libraries, runs tests, and builds the WAR file |
| Tomcat 10.1 | Runs the web application |
| SQL Server | Stores users, movies, seats, holds, bookings, and payments |
| JDBC | Allows Java to communicate with SQL Server |
| Tailwind CSS CDN | Styles the JSP pages in the browser |
| WAR file | The packaged application deployed to Tomcat |

The main request flow is:

```text
Browser
  -> Tomcat
  -> Servlet controller
  -> Service
  -> JDBC DAO
  -> SQL Server
  -> JSP page
  -> Browser
```

## Beginner setup: SSMS 20 + NetBeans 17

Complete these sections in order. Do not open the application in the browser
until the database, connection settings, and Tomcat server are ready.

### Part A — Check Java 17

- [ ] Open Apache NetBeans 17.
- [ ] Select **Tools → Java Platforms**.
- [ ] Confirm that JDK 17 is listed.
- [ ] If it is missing, select **Add Platform**, choose the installed JDK 17
      folder, and finish the wizard.

A common JDK location is:

```text
C:\Program Files\Java\jdk-17
```

Tomcat 10.1 and this project must run on Java 17. Do not use Java 8.

### Part B — Connect to SQL Server in SSMS 20

- [ ] Open **SQL Server Management Studio 20**.
- [ ] In the **Connect to Server** window, select:
  - Server type: `Database Engine`
  - Authentication: `Windows Authentication`
  - Server name: the SQL Server instance installed on your computer
- [ ] Select **Connect**.

Common server names are:

```text
localhost
.
YOUR-COMPUTER-NAME
localhost\SQLEXPRESS
YOUR-COMPUTER-NAME\SQLEXPRESS
```

After connecting, the server name appears at the top of **Object Explorer**.
Remember whether it is a default instance such as `localhost` or a named
instance such as `localhost\SQLEXPRESS`.

### Part C — Enable SQL Server authentication

The application should use its own SQL Server login. If your server already
accepts SQL Server Authentication, you may skip to Part D.

- [ ] In SSMS Object Explorer, right-click the top server node.
- [ ] Select **Properties**.
- [ ] Select the **Security** page.
- [ ] Under **Server authentication**, select:

```text
SQL Server and Windows Authentication mode
```

- [ ] Select **OK**.
- [ ] Restart SQL Server:
  - Right-click the server in Object Explorer and select **Restart**, or
  - Open **SQL Server Configuration Manager**, select
    **SQL Server Services**, right-click the SQL Server service, and select
    **Restart**.

The service is normally named one of:

```text
SQL Server (MSSQLSERVER)
SQL Server (SQLEXPRESS)
```

### Part D — Create the CineBook database

- [ ] In SSMS, select **New Query**.
- [ ] Paste and execute:

```sql
IF DB_ID(N'CineBook') IS NULL
BEGIN
    CREATE DATABASE CineBook;
END;
GO
```

- [ ] In Object Explorer, right-click **Databases** and select **Refresh**.
- [ ] Confirm that `CineBook` appears.

You can also create it through the interface:

1. Right-click **Databases**.
2. Select **New Database**.
3. Enter `CineBook`.
4. Select **OK**.

### Part E — Run the schema

- [ ] In SSMS, select **File → Open → File**.
- [ ] Open:

```text
src\main\resources\db\schema.sql
```

- [ ] In the database dropdown on the query toolbar, select `CineBook`.
- [ ] Select **Execute**, or press `F5`.
- [ ] Wait until the Messages panel reports successful completion.

The schema creates all tables, indexes, constraints, views, and seat-hold
procedures.

If you accidentally run it more than once, that is fine. It is designed to be
additive.

### Part F — Insert the sample data

- [ ] Select **File → Open → File** again.
- [ ] Open:

```text
src\main\resources\db\seed.sql
```

- [ ] Confirm that the database dropdown still says `CineBook`.
- [ ] Select **Execute** or press `F5`.

The seed adds:

- Fictional movies and genres
- Four cinemas in Vietnamese cities
- Auditoriums and 396 seats
- STANDARD, VIP, and COUPLE seat layouts
- Future showtimes
- Food and beverage combos
- Promotions
- Customer and administrator demo accounts
- One historical booking

Verify the setup with:

```sql
USE CineBook;
GO

SELECT COUNT(*) AS Movies FROM dbo.movies;
SELECT COUNT(*) AS Cinemas FROM dbo.cinemas;
SELECT COUNT(*) AS Showtimes FROM dbo.showtimes;
SELECT COUNT(*) AS Seats FROM dbo.seats;
SELECT COUNT(*) AS Combos FROM dbo.combos;
GO
```

Expected minimum results are approximately:

```text
Movies:     8
Cinemas:    4
Showtimes: 13
Seats:    396
Combos:     4
```

### Part G — Import the real Lotte movie catalog

This step replaces the active fictional movie catalog with the real movie
snapshot crawled from Lotte Cinema VN. It keeps the demo cinemas, rooms, seats,
combos, and booking logic so the assignment flow can still be tested.

- [ ] Select **File → Open → File** again.
- [ ] Open:

```text
src\main\resources\db\real-catalog-seed.sql
```

- [ ] Confirm that the database dropdown still says `CineBook`.
- [ ] Select **Execute** or press `F5`.

The real catalog seed adds:

- 51 Lotte movie records from `src\main\resources\data`
- 51 Lotte movie records embedded in `real-catalog-seed.sql`
- real titles, posters, release dates, countries, genres, and synopsis text
- nullable runtimes for coming-soon movies that do not publish a runtime yet
- demo showtimes for the 12 now-showing movies
- seat prices for those generated demo showtimes

Verify the real import with:

```sql
USE CineBook;
GO

SELECT COUNT(*) AS RealMovies
FROM dbo.movies
WHERE source_ref LIKE 'LOTTE-%';

SELECT COUNT(*) AS RealDemoShowtimes
FROM dbo.showtimes
WHERE source_ref LIKE 'LOTTE-DEMO-%';
GO
```

Expected results:

```text
RealMovies:        51
RealDemoShowtimes: 12
```

If Vietnamese text looks broken in SSMS, close the query tab and reopen the SQL
file. The script is saved as UTF-8. If you use `sqlcmd`, include `-f 65001`.

### Part H — Create the application's SQL login

Choose your own strong password in the following script. The example password
is only a placeholder.

- [ ] Open a new query in SSMS.
- [ ] Make sure the query can access both `master` and `CineBook`.
- [ ] Replace `ChangeThis_StrongPassword_123!`.
- [ ] Execute:

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

This gives the application permission to read and modify CineBook data without
making it a database administrator.

Test the login:

1. Select **Connect → Database Engine** in SSMS.
2. Choose **SQL Server Authentication**.
3. Login: `cinebook_app`
4. Enter the password you selected.
5. Select **Connect**.

If the login fails, revisit Part C and confirm that SQL Server was restarted
after enabling mixed authentication.

### Part I — Confirm SQL Server TCP/IP

JDBC normally connects through TCP/IP.

- [ ] Open **SQL Server Configuration Manager**.
- [ ] Expand **SQL Server Network Configuration**.
- [ ] Select **Protocols for MSSQLSERVER** or
      **Protocols for SQLEXPRESS**.
- [ ] Confirm that **TCP/IP** is enabled.
- [ ] If you enable it now, restart the SQL Server service.

For a default SQL Server instance using port 1433, the JDBC URL is:

```text
jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true
```

For a named `SQLEXPRESS` instance, try:

```text
jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=CineBook;encrypt=true;trustServerCertificate=true
```

If the named-instance URL cannot connect, configure a fixed TCP port in SQL
Server Configuration Manager or ask your instructor which port to use.

### Part J — Add database variables to Windows

This is the easiest way to make the same settings available to NetBeans and
Tomcat.

- [ ] Open the Windows Start menu.
- [ ] Search for **Edit environment variables for your account**.
- [ ] Under **User variables**, select **New**.
- [ ] Add these three variables:

```text
Variable name:  CINEBOOK_DB_URL
Variable value: jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true

Variable name:  CINEBOOK_DB_USER
Variable value: cinebook_app

Variable name:  CINEBOOK_DB_PASSWORD
Variable value: the password chosen in Part H
```

- [ ] Select **OK** on every open environment-variable window.
- [ ] Completely close NetBeans.
- [ ] Open NetBeans again.

NetBeans must be restarted because programs only read environment variables
when they start.

Do not write real passwords in Java source, `pom.xml`, Git, screenshots, or
the project wiki.

### Part K — Register Tomcat 10.1 in NetBeans

- [ ] Open NetBeans.
- [ ] Select **Window → Services**, or press `Ctrl+5`.
- [ ] Right-click **Servers**.
- [ ] Select **Add Server**.
- [ ] Choose **Apache Tomcat or TomEE**.
- [ ] Select **Next**.
- [ ] For **Server Location**, browse to:

```text
C:\Program Files\Apache Software Foundation\Tomcat 10.1
```

- [ ] Enter a local Tomcat manager username and password if the wizard requests
      them.
- [ ] Complete the wizard.

In the Services window, expand **Servers** and confirm that Apache Tomcat 10.1
appears.

If Tomcat is already registered, right-click it, select **Properties**, and
confirm that it uses Java 17.

### Part L — Open the Maven project in NetBeans

- [ ] Select **File → Open Project**.
- [ ] Choose the repository root:

```text
C:\Users\rumi\Documents\GitHub\PRJ301-Assignment
```

- [ ] Select **Open Project**.

Select the folder containing `pom.xml`, not `src`, `web`, or `target`.

NetBeans should show a Maven project named `cinebook`. On the first opening,
Maven may download dependencies from the internet. Wait until background tasks
finish.

If the project icon shows an error:

1. Right-click the project.
2. Select **Reload Project** or **Reload POM**.
3. Confirm that Java 17 is selected under **Properties → Sources**.
4. Check the **Notifications** and **Output** windows for the actual error.

### Part M — Assign Tomcat to the project

- [ ] Right-click the CineBook project.
- [ ] Select **Properties**.
- [ ] Open the **Run** category.
- [ ] Select the registered Apache Tomcat 10.1 server.
- [ ] Set the relative URL to `/` if NetBeans asks.
- [ ] Select **OK**.

The application context path is:

```text
/cinebook
```

### Part N — Build in NetBeans

- [ ] Right-click the CineBook project.
- [ ] Select **Clean and Build**.
- [ ] Open the **Output** window if it is hidden.
- [ ] Wait for:

```text
BUILD SUCCESS
```

The generated application is:

```text
target\cinebook.war
```

If dependency downloads fail, confirm that the computer has internet access
and retry **Clean and Build**.

### Part O — Run in NetBeans

- [ ] Right-click the project.
- [ ] Select **Run**.
- [ ] Allow NetBeans to start Tomcat.
- [ ] Wait until the Output window says Tomcat started and CineBook deployed.
- [ ] Open:

```text
http://localhost:8080/cinebook/
```

NetBeans may open the browser automatically.

The first screen should redirect to the movie catalog. If the database
connection is not ready, the application will show a database-operation error;
see the troubleshooting section below.

## Run checklist

### 1. Create and seed the database

- [ ] Open SQL Server Management Studio or `sqlcmd`.
- [ ] Create a database named `CineBook`.
- [ ] Run `src/main/resources/db/schema.sql`.
- [ ] Run `src/main/resources/db/seed.sql`.
- [ ] Run `src/main/resources/db/real-catalog-seed.sql`.

PowerShell example using Windows authentication:

```powershell
sqlcmd -S localhost -E -C -Q "IF DB_ID('CineBook') IS NULL CREATE DATABASE CineBook"
sqlcmd -S localhost -E -C -d CineBook -b -i ".\src\main\resources\db\schema.sql"
sqlcmd -S localhost -E -C -d CineBook -b -i ".\src\main\resources\db\seed.sql"
sqlcmd -S localhost -E -C -d CineBook -b -f 65001 -i ".\src\main\resources\db\real-catalog-seed.sql"
```

The scripts are additive and may be run again in a development database. The
real catalog script imports 51 Lotte movie records and creates 12 generated
demo showtimes for now-showing movies.

### 2. Configure the database connection

- [ ] Create a SQL Server login that has read/write access to `CineBook`.
- [ ] Set the following environment variables before starting Tomcat:

```powershell
$env:CINEBOOK_DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true"
$env:CINEBOOK_DB_USER = "your_sql_login"
$env:CINEBOOK_DB_PASSWORD = "your_sql_password"
```

Alternatively, add JVM properties to Tomcat:

```text
-Dcinebook.db.url=jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true
-Dcinebook.db.user=your_sql_login
-Dcinebook.db.password=your_sql_password
```

Do not commit real database credentials.

### 3. Build and test

- [ ] Run the test suite.
- [ ] Build the WAR.

If Maven is available on `PATH`:

```powershell
mvn test
mvn clean package
```

Using the Maven bundled with NetBeans:

```powershell
& "C:\Program Files\NetBeans-17\netbeans\java\maven\bin\mvn.cmd" test
& "C:\Program Files\NetBeans-17\netbeans\java\maven\bin\mvn.cmd" clean package
```

Expected output:

```text
BUILD SUCCESS
target\cinebook.war
```

The normal suite runs nine unit tests. Two real SQL Server integration tests are
skipped unless their separate credentials are provided.

### 4. Deploy to Tomcat

- [ ] Stop Tomcat if it is running.
- [ ] Copy `target/cinebook.war` into Tomcat's `webapps` directory.
- [ ] Start Tomcat.
- [ ] Open `http://localhost:8080/cinebook/`.

Example:

```powershell
Copy-Item ".\target\cinebook.war" `
  "C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\cinebook.war"

& "C:\Program Files\Apache Software Foundation\Tomcat 10.1\bin\startup.bat"
```

If Tomcat is run by NetBeans, import the repository as a Maven web project,
assign Tomcat 10.1, and run the project.

### 5. Smoke-test the application

- [ ] Sign in using a seeded account.
- [ ] Browse Now Showing and Coming Soon movies.
- [ ] Test movie search and filters.
- [ ] Open a movie and choose tomorrow's showtime.
- [ ] Select seats and confirm the seven-minute countdown appears.
- [ ] Add optional combos.
- [ ] Try promotion code `WELCOME10`, `STUDENT50`, or `WEEKDAY15`.
- [ ] Open booking history and the generated ticket.
- [ ] Sign in as ADMIN and open every admin scaffold.
- [ ] Open the seat map in two browsers and verify only one browser can hold the
      same seat.

## Demo accounts

All seeded accounts use the password:

```text
password
```

Customer:

```text
customer@cinebook.vn
```

Administrator:

```text
admin@cinebook.vn
```

The seed also contains a locked customer account for account-management demos.
Replace all demo passwords outside a classroom environment.

## Common problems

### `Login failed for user 'cinebook_app'`

- Confirm SQL Server and Windows Authentication mode is enabled.
- Restart SQL Server after changing authentication mode.
- Confirm the login exists under **Security → Logins** in SSMS.
- Confirm the login is mapped to a user under
  **CineBook → Security → Users**.
- Re-enter `CINEBOOK_DB_USER` and `CINEBOOK_DB_PASSWORD`.
- Restart NetBeans after changing environment variables.

### `The TCP/IP connection to the host localhost, port 1433 has failed`

- Enable TCP/IP in SQL Server Configuration Manager.
- Confirm SQL Server is running.
- Confirm whether the installation is `MSSQLSERVER` or `SQLEXPRESS`.
- Confirm the actual TCP port.
- Restart SQL Server after network changes.
- Update `CINEBOOK_DB_URL` and restart NetBeans.

### `The database operation could not be completed`

- Check the Tomcat Output window for the underlying SQL exception.
- Confirm that `CineBook` exists.
- Run `schema.sql`, `seed.sql`, and `real-catalog-seed.sql`.
- Confirm the application login has `db_datareader` and `db_datawriter`.
- Confirm the environment variables are visible to the NetBeans process.

### HTTP 404 at `/cinebook`

- Confirm **Clean and Build** produced `target\cinebook.war`.
- Confirm Tomcat 10.1 is assigned under project **Properties → Run**.
- In the Services window, expand Tomcat's deployed applications and confirm
  that `cinebook` is listed.
- Stop Tomcat, clean the project, and run it again.
- Use `/cinebook/`, not the old `/PRJ301-Assignment/` path.

### Tomcat port 8080 is already in use

- Stop another Tomcat or web server using port 8080, or
- Open the Tomcat server properties in NetBeans and change its HTTP port.
- If the port becomes 8081, use:

```text
http://localhost:8081/cinebook/
```

### The page has no styling

Tailwind is loaded from a CDN. The page may be unstyled if the browser cannot
access the internet or blocks `cdn.tailwindcss.com`. Application functionality
can still work without the stylesheet.

### No showtimes appear for today

The development seed intentionally creates future showtimes, usually beginning
tomorrow. Select tomorrow or another available date.

### A form returns HTTP 403

The CSRF token may be missing or the session may be stale:

- Reload the page.
- Make sure browser cookies are enabled.
- Sign out and sign in again.
- Do not submit an old form after restarting Tomcat.

### NetBeans uses the wrong Java version

- Open **Tools → Java Platforms** and add JDK 17.
- Open project **Properties → Sources** and select Java 17.
- Open Tomcat **Properties** in the Services window and select JDK 17.
- Restart NetBeans and rebuild.

## Optional SQL Server integration tests

To enable the credential-gated JDBC and concurrent-seat tests:

```powershell
$env:CINEBOOK_IT_DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true"
$env:CINEBOOK_IT_DB_USER = "your_test_login"
$env:CINEBOOK_IT_DB_PASSWORD = "your_test_password"
mvn test
```

Use a disposable development database or test login.

