# CineBook SQL Server setup

Run the scripts with SQL Server 2019 or newer:

```powershell
sqlcmd -S localhost -E -C -Q "IF DB_ID('CineBook') IS NULL CREATE DATABASE CineBook"
sqlcmd -S localhost -E -C -d CineBook -b -i schema.sql
sqlcmd -S localhost -E -C -d CineBook -b -i seed.sql
sqlcmd -S localhost -E -C -d CineBook -b -f 65001 -i real-catalog-seed.sql
```

The scripts are additive and may be run again in a development database. The
base seed creates demo users, cinemas, rooms, seats, combos, promotions, and
fictional fallback movies. `real-catalog-seed.sql` imports the Lotte Cinema VN
movie catalog snapshots from `src/main/resources/data`, hides the fictional
catalog movies from active listings, and creates demo showtimes for imported
now-showing movies so the booking flow remains demonstrable.

Demo accounts use the password `password`:

- `customer@cinebook.vn`
- `admin@cinebook.vn`

Application credentials are supplied through `CINEBOOK_DB_URL`,
`CINEBOOK_DB_USER`, and `CINEBOOK_DB_PASSWORD`, or the matching
`cinebook.db.*` JVM properties.

Money uses `DECIMAL(19,2)` and all `DATETIME2` values are UTC. Couple-seat
prices use `PER_PAIR`; the second physical seat receives a zero price snapshot
when a hold is converted to a booking.
