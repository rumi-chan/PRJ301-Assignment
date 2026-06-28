# CineBook SQL Server setup

Run the scripts with SQL Server 2019 or newer:

```powershell
sqlcmd -S localhost -E -C -Q "IF DB_ID('CineBook') IS NULL CREATE DATABASE CineBook"
sqlcmd -S localhost -E -C -d CineBook -b -i schema.sql
sqlcmd -S localhost -E -C -d CineBook -b -i seed.sql
```

Both scripts are additive and may be run again in a development database. The
seed creates fictional movies and tomorrow-oriented showtimes so the booking
flow remains immediately demonstrable after a fresh setup.

Demo accounts use the password `password`:

- `customer@cinebook.vn`
- `admin@cinebook.vn`

Application credentials are supplied through `CINEBOOK_DB_URL`,
`CINEBOOK_DB_USER`, and `CINEBOOK_DB_PASSWORD`, or the matching
`cinebook.db.*` JVM properties.

Money uses `DECIMAL(19,2)` and all `DATETIME2` values are UTC. Couple-seat
prices use `PER_PAIR`; the second physical seat receives a zero price snapshot
when a hold is converted to a booking.
