CREATE DATABASE CineBook;
GO
USE CineBook;
GO
/*
 * CineBook - SQL Server schema
 * Target: SQL Server 2019+ / Azure SQL Database
 *
 * Run in an existing application database. Creation is additive and rerunnable:
 * tables/indexes/types are created when absent; procedures/views are refreshed.
 * Every DATETIME2 value is UTC even where the Java-friendly column omits "_utc".
 */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.users
    (
        user_id           BIGINT IDENTITY(1,1) NOT NULL,
        email             NVARCHAR(255) NOT NULL,
        password_hash     NVARCHAR(100) NOT NULL,
        full_name         NVARCHAR(150) NOT NULL,
        phone             NVARCHAR(30) NULL,
        role              VARCHAR(20) NOT NULL CONSTRAINT DF_users_role DEFAULT ('CUSTOMER'),
        is_active         BIT NOT NULL CONSTRAINT DF_users_is_active DEFAULT (1),
        is_locked         BIT NOT NULL CONSTRAINT DF_users_is_locked DEFAULT (0),
        email_verified    BIT NOT NULL CONSTRAINT DF_users_email_verified DEFAULT (0),
        locked_at         DATETIME2(3) NULL,
        last_login_at     DATETIME2(3) NULL,
        created_at        DATETIME2(3) NOT NULL CONSTRAINT DF_users_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at        DATETIME2(3) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version       ROWVERSION NOT NULL,
        CONSTRAINT PK_users PRIMARY KEY CLUSTERED (user_id),
        CONSTRAINT UQ_users_email UNIQUE (email),
        CONSTRAINT CK_users_role CHECK (role IN ('CUSTOMER', 'ADMIN')),
        CONSTRAINT CK_users_lock_state CHECK
        (
            (is_locked = 0 AND locked_at IS NULL)
            OR (is_locked = 1 AND locked_at IS NOT NULL)
        )
    );
END;
GO

IF OBJECT_ID(N'dbo.genres', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.genres
    (
        genre_id    INT IDENTITY(1,1) NOT NULL,
        name        NVARCHAR(80) NOT NULL,
        slug        VARCHAR(80) NOT NULL,
        created_at  DATETIME2(3) NOT NULL CONSTRAINT DF_genres_created_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_genres PRIMARY KEY CLUSTERED (genre_id),
        CONSTRAINT UQ_genres_name UNIQUE (name),
        CONSTRAINT UQ_genres_slug UNIQUE (slug)
    );
END;
GO

IF OBJECT_ID(N'dbo.movies', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.movies
    (
        movie_id           BIGINT IDENTITY(1,1) NOT NULL,
        title              NVARCHAR(200) NOT NULL,
        slug               VARCHAR(220) NOT NULL,
        synopsis           NVARCHAR(MAX) NOT NULL,
        director           NVARCHAR(200) NOT NULL,
        cast_text          NVARCHAR(1000) NULL,
        duration_minutes   SMALLINT NOT NULL,
        age_rating         VARCHAR(20) NOT NULL,
        release_date       DATE NOT NULL,
        end_date           DATE NULL,
        original_language  NVARCHAR(80) NOT NULL,
        country            NVARCHAR(100) NOT NULL,
        poster_url         NVARCHAR(1000) NULL,
        backdrop_url       NVARCHAR(1000) NULL,
        trailer_url        NVARCHAR(1000) NULL,
        status             VARCHAR(20) NOT NULL,
        is_active          BIT NOT NULL CONSTRAINT DF_movies_is_active DEFAULT (1),
        created_at         DATETIME2(3) NOT NULL CONSTRAINT DF_movies_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at         DATETIME2(3) NOT NULL CONSTRAINT DF_movies_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version        ROWVERSION NOT NULL,
        CONSTRAINT PK_movies PRIMARY KEY CLUSTERED (movie_id),
        CONSTRAINT UQ_movies_slug UNIQUE (slug),
        CONSTRAINT CK_movies_duration CHECK (duration_minutes BETWEEN 1 AND 600),
        CONSTRAINT CK_movies_dates CHECK (end_date IS NULL OR end_date >= release_date),
        CONSTRAINT CK_movies_status CHECK (status IN ('NOW_SHOWING', 'COMING_SOON', 'ARCHIVED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.movie_genres', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.movie_genres
    (
        movie_id  BIGINT NOT NULL,
        genre_id  INT NOT NULL,
        CONSTRAINT PK_movie_genres PRIMARY KEY CLUSTERED (movie_id, genre_id),
        CONSTRAINT FK_movie_genres_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies(movie_id) ON DELETE CASCADE,
        CONSTRAINT FK_movie_genres_genre FOREIGN KEY (genre_id) REFERENCES dbo.genres(genre_id)
    );
END;
GO

IF OBJECT_ID(N'dbo.movie_formats', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.movie_formats
    (
        movie_id  BIGINT NOT NULL,
        format    VARCHAR(10) NOT NULL,
        CONSTRAINT PK_movie_formats PRIMARY KEY CLUSTERED (movie_id, format),
        CONSTRAINT FK_movie_formats_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies(movie_id) ON DELETE CASCADE,
        CONSTRAINT CK_movie_formats_format CHECK (format IN ('2D', '3D', 'IMAX', '4DX'))
    );
END;
GO

IF OBJECT_ID(N'dbo.cinemas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.cinemas
    (
        cinema_id    BIGINT IDENTITY(1,1) NOT NULL,
        name         NVARCHAR(200) NOT NULL,
        slug         VARCHAR(220) NOT NULL,
        city         NVARCHAR(100) NOT NULL,
        district     NVARCHAR(100) NULL,
        address      NVARCHAR(300) NOT NULL,
        phone        NVARCHAR(30) NULL,
        latitude     DECIMAL(9,6) NULL,
        longitude    DECIMAL(9,6) NULL,
        is_active    BIT NOT NULL CONSTRAINT DF_cinemas_is_active DEFAULT (1),
        created_at   DATETIME2(3) NOT NULL CONSTRAINT DF_cinemas_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at   DATETIME2(3) NOT NULL CONSTRAINT DF_cinemas_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version  ROWVERSION NOT NULL,
        CONSTRAINT PK_cinemas PRIMARY KEY CLUSTERED (cinema_id),
        CONSTRAINT UQ_cinemas_slug UNIQUE (slug),
        CONSTRAINT CK_cinemas_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
        CONSTRAINT CK_cinemas_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
    );
END;
GO

IF OBJECT_ID(N'dbo.auditoriums', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.auditoriums
    (
        auditorium_id    BIGINT IDENTITY(1,1) NOT NULL,
        cinema_id        BIGINT NOT NULL,
        name             NVARCHAR(100) NOT NULL,
        auditorium_type  VARCHAR(20) NOT NULL,
        capacity         SMALLINT NOT NULL,
        is_active        BIT NOT NULL CONSTRAINT DF_auditoriums_is_active DEFAULT (1),
        created_at       DATETIME2(3) NOT NULL CONSTRAINT DF_auditoriums_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at       DATETIME2(3) NOT NULL CONSTRAINT DF_auditoriums_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version      ROWVERSION NOT NULL,
        CONSTRAINT PK_auditoriums PRIMARY KEY CLUSTERED (auditorium_id),
        CONSTRAINT UQ_auditoriums_cinema_name UNIQUE (cinema_id, name),
        CONSTRAINT FK_auditoriums_cinema FOREIGN KEY (cinema_id) REFERENCES dbo.cinemas(cinema_id),
        CONSTRAINT CK_auditoriums_type CHECK (auditorium_type IN ('STANDARD', 'IMAX', 'PREMIUM')),
        CONSTRAINT CK_auditoriums_capacity CHECK (capacity > 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.seats', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.seats
    (
        seat_id        BIGINT IDENTITY(1,1) NOT NULL,
        auditorium_id  BIGINT NOT NULL,
        row_label      VARCHAR(5) NOT NULL,
        seat_number    SMALLINT NOT NULL,
        seat_label     VARCHAR(12) NOT NULL,
        seat_type      VARCHAR(20) NOT NULL,
        pair_seat_id   BIGINT NULL,
        is_accessible  BIT NOT NULL CONSTRAINT DF_seats_is_accessible DEFAULT (0),
        is_active      BIT NOT NULL CONSTRAINT DF_seats_is_active DEFAULT (1),
        created_at     DATETIME2(3) NOT NULL CONSTRAINT DF_seats_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at     DATETIME2(3) NOT NULL CONSTRAINT DF_seats_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version    ROWVERSION NOT NULL,
        CONSTRAINT PK_seats PRIMARY KEY CLUSTERED (seat_id),
        CONSTRAINT UQ_seats_auditorium_label UNIQUE (auditorium_id, seat_label),
        CONSTRAINT UQ_seats_auditorium_position UNIQUE (auditorium_id, row_label, seat_number),
        CONSTRAINT FK_seats_auditorium FOREIGN KEY (auditorium_id) REFERENCES dbo.auditoriums(auditorium_id),
        CONSTRAINT FK_seats_pair FOREIGN KEY (pair_seat_id) REFERENCES dbo.seats(seat_id),
        CONSTRAINT CK_seats_number CHECK (seat_number > 0),
        CONSTRAINT CK_seats_type CHECK (seat_type IN ('STANDARD', 'VIP', 'COUPLE')),
        CONSTRAINT CK_seats_pair CHECK
        (
            (seat_type = 'COUPLE' AND (pair_seat_id IS NULL OR pair_seat_id <> seat_id))
            OR (seat_type <> 'COUPLE' AND pair_seat_id IS NULL)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.seats') AND name = N'UX_seats_pair_seat_id'
)
BEGIN
    CREATE UNIQUE INDEX UX_seats_pair_seat_id
        ON dbo.seats(pair_seat_id)
        WHERE pair_seat_id IS NOT NULL;
END;
GO

IF OBJECT_ID(N'dbo.showtimes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.showtimes
    (
        showtime_id       BIGINT IDENTITY(1,1) NOT NULL,
        movie_id          BIGINT NOT NULL,
        auditorium_id     BIGINT NOT NULL,
        starts_at         DATETIME2(3) NOT NULL,
        ends_at           DATETIME2(3) NOT NULL,
        sales_open_at     DATETIME2(3) NOT NULL,
        format            VARCHAR(10) NOT NULL,
        base_price        DECIMAL(19,2) NOT NULL,
        audio_language    NVARCHAR(80) NOT NULL,
        subtitle_language NVARCHAR(80) NULL,
        status            VARCHAR(20) NOT NULL CONSTRAINT DF_showtimes_status DEFAULT ('SCHEDULED'),
        source_ref        VARCHAR(80) NULL,
        created_at        DATETIME2(3) NOT NULL CONSTRAINT DF_showtimes_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at        DATETIME2(3) NOT NULL CONSTRAINT DF_showtimes_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version       ROWVERSION NOT NULL,
        CONSTRAINT PK_showtimes PRIMARY KEY CLUSTERED (showtime_id),
        CONSTRAINT UQ_showtimes_auditorium_start UNIQUE (auditorium_id, starts_at),
        CONSTRAINT FK_showtimes_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies(movie_id),
        CONSTRAINT FK_showtimes_auditorium FOREIGN KEY (auditorium_id) REFERENCES dbo.auditoriums(auditorium_id),
        CONSTRAINT CK_showtimes_format CHECK (format IN ('2D', '3D', 'IMAX', '4DX')),
        CONSTRAINT CK_showtimes_status CHECK (status IN ('SCHEDULED', 'CANCELLED', 'COMPLETED')),
        CONSTRAINT CK_showtimes_window CHECK (ends_at > starts_at),
        CONSTRAINT CK_showtimes_sales_open CHECK (sales_open_at < starts_at),
        CONSTRAINT CK_showtimes_base_price CHECK (base_price >= 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.showtimes') AND name = N'UX_showtimes_source_ref'
)
BEGIN
    CREATE UNIQUE INDEX UX_showtimes_source_ref
        ON dbo.showtimes(source_ref)
        WHERE source_ref IS NOT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.showtimes') AND name = N'IX_showtimes_movie_starts_at'
)
BEGIN
    CREATE INDEX IX_showtimes_movie_starts_at
        ON dbo.showtimes(movie_id, starts_at)
        INCLUDE (auditorium_id, format, base_price, status);
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.showtimes') AND name = N'IX_showtimes_status_starts_at'
)
BEGIN
    CREATE INDEX IX_showtimes_status_starts_at
        ON dbo.showtimes(status, starts_at)
        INCLUDE (movie_id, auditorium_id, format);
END;
GO

IF OBJECT_ID(N'dbo.seat_prices', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.seat_prices
    (
        seat_price_id  BIGINT IDENTITY(1,1) NOT NULL,
        showtime_id    BIGINT NOT NULL,
        seat_type      VARCHAR(20) NOT NULL,
        price          DECIMAL(19,2) NOT NULL,
        price_mode     VARCHAR(20) NOT NULL CONSTRAINT DF_seat_prices_price_mode DEFAULT ('PER_SEAT'),
        currency       CHAR(3) NOT NULL CONSTRAINT DF_seat_prices_currency DEFAULT ('VND'),
        created_at     DATETIME2(3) NOT NULL CONSTRAINT DF_seat_prices_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at     DATETIME2(3) NOT NULL CONSTRAINT DF_seat_prices_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_seat_prices PRIMARY KEY CLUSTERED (seat_price_id),
        CONSTRAINT UQ_seat_prices_showtime_type UNIQUE (showtime_id, seat_type),
        CONSTRAINT FK_seat_prices_showtime FOREIGN KEY (showtime_id) REFERENCES dbo.showtimes(showtime_id) ON DELETE CASCADE,
        CONSTRAINT CK_seat_prices_type CHECK (seat_type IN ('STANDARD', 'VIP', 'COUPLE')),
        CONSTRAINT CK_seat_prices_price CHECK (price >= 0),
        CONSTRAINT CK_seat_prices_mode CHECK
        (
            (seat_type = 'COUPLE' AND price_mode = 'PER_PAIR')
            OR (seat_type <> 'COUPLE' AND price_mode = 'PER_SEAT')
        ),
        CONSTRAINT CK_seat_prices_currency CHECK (currency = 'VND')
    );
END;
GO

IF OBJECT_ID(N'dbo.combos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.combos
    (
        combo_id      BIGINT IDENTITY(1,1) NOT NULL,
        sku           VARCHAR(40) NOT NULL,
        name          NVARCHAR(150) NOT NULL,
        description   NVARCHAR(500) NULL,
        price         DECIMAL(19,2) NOT NULL,
        currency      CHAR(3) NOT NULL CONSTRAINT DF_combos_currency DEFAULT ('VND'),
        image_url     NVARCHAR(1000) NULL,
        is_active     BIT NOT NULL CONSTRAINT DF_combos_is_active DEFAULT (1),
        display_order INT NOT NULL CONSTRAINT DF_combos_display_order DEFAULT (0),
        created_at    DATETIME2(3) NOT NULL CONSTRAINT DF_combos_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at    DATETIME2(3) NOT NULL CONSTRAINT DF_combos_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version   ROWVERSION NOT NULL,
        CONSTRAINT PK_combos PRIMARY KEY CLUSTERED (combo_id),
        CONSTRAINT UQ_combos_sku UNIQUE (sku),
        CONSTRAINT CK_combos_price CHECK (price >= 0),
        CONSTRAINT CK_combos_currency CHECK (currency = 'VND')
    );
END;
GO

IF OBJECT_ID(N'dbo.promotions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.promotions
    (
        promotion_id       BIGINT IDENTITY(1,1) NOT NULL,
        code               VARCHAR(40) NOT NULL,
        name               NVARCHAR(150) NOT NULL,
        description        NVARCHAR(500) NULL,
        discount_type      VARCHAR(20) NOT NULL,
        discount_value     DECIMAL(19,2) NOT NULL,
        minimum_order      DECIMAL(19,2) NOT NULL CONSTRAINT DF_promotions_minimum_order DEFAULT (0),
        maximum_discount   DECIMAL(19,2) NULL,
        starts_at          DATETIME2(3) NOT NULL,
        ends_at            DATETIME2(3) NOT NULL,
        usage_limit        INT NULL,
        per_user_limit     INT NULL,
        times_redeemed     INT NOT NULL CONSTRAINT DF_promotions_times_redeemed DEFAULT (0),
        is_active          BIT NOT NULL CONSTRAINT DF_promotions_is_active DEFAULT (1),
        created_at         DATETIME2(3) NOT NULL CONSTRAINT DF_promotions_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at         DATETIME2(3) NOT NULL CONSTRAINT DF_promotions_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version        ROWVERSION NOT NULL,
        CONSTRAINT PK_promotions PRIMARY KEY CLUSTERED (promotion_id),
        CONSTRAINT UQ_promotions_code UNIQUE (code),
        CONSTRAINT CK_promotions_type CHECK (discount_type IN ('PERCENT', 'FIXED')),
        CONSTRAINT CK_promotions_value CHECK
        (
            (discount_type = 'PERCENT' AND discount_value > 0 AND discount_value <= 100)
            OR (discount_type = 'FIXED' AND discount_value > 0)
        ),
        CONSTRAINT CK_promotions_amounts CHECK
        (
            minimum_order >= 0 AND (maximum_discount IS NULL OR maximum_discount > 0)
        ),
        CONSTRAINT CK_promotions_window CHECK (ends_at > starts_at),
        CONSTRAINT CK_promotions_limits CHECK
        (
            (usage_limit IS NULL OR usage_limit > 0)
            AND (per_user_limit IS NULL OR per_user_limit > 0)
            AND times_redeemed >= 0
            AND (usage_limit IS NULL OR times_redeemed <= usage_limit)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.promotions') AND name = N'IX_promotions_active_window'
)
BEGIN
    CREATE INDEX IX_promotions_active_window
        ON dbo.promotions(is_active, starts_at, ends_at)
        INCLUDE (code, discount_type, discount_value, minimum_order, maximum_discount);
END;
GO

/*
 * One row per held seat. Rows sharing hold_token are one customer selection.
 * Expiration/release changes status away from ACTIVE; the filtered unique index
 * is the final guard against concurrent holds for the same showtime and seat.
 */
IF OBJECT_ID(N'dbo.seat_holds', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.seat_holds
    (
        seat_hold_id    BIGINT IDENTITY(1,1) NOT NULL,
        hold_token      UNIQUEIDENTIFIER NOT NULL,
        showtime_id     BIGINT NOT NULL,
        seat_id         BIGINT NOT NULL,
        user_id         BIGINT NULL,
        session_key     VARCHAR(128) NULL,
        status          VARCHAR(20) NOT NULL CONSTRAINT DF_seat_holds_status DEFAULT ('ACTIVE'),
        price_snapshot  DECIMAL(19,2) NOT NULL,
        expires_at      DATETIME2(3) NOT NULL,
        converted_at    DATETIME2(3) NULL,
        released_at     DATETIME2(3) NULL,
        created_at      DATETIME2(3) NOT NULL CONSTRAINT DF_seat_holds_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at      DATETIME2(3) NOT NULL CONSTRAINT DF_seat_holds_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version     ROWVERSION NOT NULL,
        CONSTRAINT PK_seat_holds PRIMARY KEY CLUSTERED (seat_hold_id),
        CONSTRAINT UQ_seat_holds_token_seat UNIQUE (hold_token, seat_id),
        CONSTRAINT FK_seat_holds_showtime FOREIGN KEY (showtime_id) REFERENCES dbo.showtimes(showtime_id),
        CONSTRAINT FK_seat_holds_seat FOREIGN KEY (seat_id) REFERENCES dbo.seats(seat_id),
        CONSTRAINT FK_seat_holds_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_seat_holds_owner CHECK (user_id IS NOT NULL OR session_key IS NOT NULL),
        CONSTRAINT CK_seat_holds_status CHECK (status IN ('ACTIVE', 'CONVERTED', 'RELEASED', 'EXPIRED')),
        CONSTRAINT CK_seat_holds_price CHECK (price_snapshot >= 0),
        CONSTRAINT CK_seat_holds_expiry CHECK (expires_at > created_at),
        CONSTRAINT CK_seat_holds_terminal_time CHECK
        (
            (status = 'ACTIVE' AND converted_at IS NULL AND released_at IS NULL)
            OR (status = 'CONVERTED' AND converted_at IS NOT NULL AND released_at IS NOT NULL)
            OR (status IN ('RELEASED', 'EXPIRED') AND converted_at IS NULL AND released_at IS NOT NULL)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.seat_holds') AND name = N'UX_seat_holds_active_seat'
)
BEGIN
    CREATE UNIQUE INDEX UX_seat_holds_active_seat
        ON dbo.seat_holds(showtime_id, seat_id)
        WHERE status = 'ACTIVE';
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.seat_holds') AND name = N'IX_seat_holds_token'
)
BEGIN
    CREATE INDEX IX_seat_holds_token
        ON dbo.seat_holds(hold_token, status)
        INCLUDE (showtime_id, seat_id, user_id, session_key, expires_at, price_snapshot);
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.seat_holds') AND name = N'IX_seat_holds_active_expiry'
)
BEGIN
    CREATE INDEX IX_seat_holds_active_expiry
        ON dbo.seat_holds(expires_at)
        INCLUDE (hold_token, showtime_id, seat_id)
        WHERE status = 'ACTIVE';
END;
GO

IF OBJECT_ID(N'dbo.bookings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bookings
    (
        booking_id       BIGINT IDENTITY(1,1) NOT NULL,
        booking_code     VARCHAR(24) NOT NULL,
        user_id          BIGINT NOT NULL,
        showtime_id      BIGINT NOT NULL,
        hold_token       UNIQUEIDENTIFIER NULL,
        promotion_id     BIGINT NULL,
        status           VARCHAR(20) NOT NULL CONSTRAINT DF_bookings_status DEFAULT ('PENDING'),
        ticket_subtotal  DECIMAL(19,2) NOT NULL,
        combo_subtotal   DECIMAL(19,2) NOT NULL,
        discount_amount  DECIMAL(19,2) NOT NULL CONSTRAINT DF_bookings_discount DEFAULT (0),
        tax_rate         DECIMAL(7,4) NOT NULL,
        tax_amount       DECIMAL(19,2) NOT NULL,
        service_fee      DECIMAL(19,2) NOT NULL,
        total_amount     DECIMAL(19,2) NOT NULL,
        currency         CHAR(3) NOT NULL CONSTRAINT DF_bookings_currency DEFAULT ('VND'),
        paid_at          DATETIME2(3) NULL,
        cancelled_at     DATETIME2(3) NULL,
        used_at          DATETIME2(3) NULL,
        created_at       DATETIME2(3) NOT NULL CONSTRAINT DF_bookings_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at       DATETIME2(3) NOT NULL CONSTRAINT DF_bookings_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version      ROWVERSION NOT NULL,
        CONSTRAINT PK_bookings PRIMARY KEY CLUSTERED (booking_id),
        CONSTRAINT UQ_bookings_code UNIQUE (booking_code),
        CONSTRAINT FK_bookings_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_bookings_showtime FOREIGN KEY (showtime_id) REFERENCES dbo.showtimes(showtime_id),
        CONSTRAINT FK_bookings_promotion FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(promotion_id),
        CONSTRAINT CK_bookings_status CHECK (status IN ('PENDING', 'PAID', 'CANCELLED', 'USED', 'REFUNDED', 'EXPIRED')),
        CONSTRAINT CK_bookings_amounts CHECK
        (
            ticket_subtotal >= 0 AND combo_subtotal >= 0 AND discount_amount >= 0
            AND tax_rate >= 0 AND tax_amount >= 0 AND service_fee >= 0 AND total_amount >= 0
            AND discount_amount <= ticket_subtotal + combo_subtotal
        ),
        CONSTRAINT CK_bookings_currency CHECK (currency = 'VND'),
        CONSTRAINT CK_bookings_status_times CHECK
        (
            (status = 'PENDING' AND paid_at IS NULL AND cancelled_at IS NULL AND used_at IS NULL)
            OR (status = 'PAID' AND paid_at IS NOT NULL AND cancelled_at IS NULL AND used_at IS NULL)
            OR (status = 'USED' AND paid_at IS NOT NULL AND cancelled_at IS NULL AND used_at IS NOT NULL)
            OR (status IN ('CANCELLED', 'REFUNDED', 'EXPIRED') AND cancelled_at IS NOT NULL AND used_at IS NULL)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.bookings') AND name = N'UX_bookings_hold_token'
)
BEGIN
    CREATE UNIQUE INDEX UX_bookings_hold_token
        ON dbo.bookings(hold_token)
        WHERE hold_token IS NOT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.bookings') AND name = N'IX_bookings_user_created_at'
)
BEGIN
    CREATE INDEX IX_bookings_user_created_at
        ON dbo.bookings(user_id, created_at DESC)
        INCLUDE (booking_code, showtime_id, status, total_amount);
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.bookings') AND name = N'IX_bookings_showtime_status'
)
BEGIN
    CREATE INDEX IX_bookings_showtime_status
        ON dbo.bookings(showtime_id, status)
        INCLUDE (booking_code, total_amount, paid_at);
END;
GO

IF OBJECT_ID(N'dbo.booking_seats', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.booking_seats
    (
        booking_seat_id     BIGINT IDENTITY(1,1) NOT NULL,
        booking_id          BIGINT NOT NULL,
        showtime_id         BIGINT NOT NULL,
        seat_id             BIGINT NOT NULL,
        seat_label_snapshot VARCHAR(12) NOT NULL,
        seat_type_snapshot  VARCHAR(20) NOT NULL,
        unit_price          DECIMAL(19,2) NOT NULL,
        status              VARCHAR(20) NOT NULL CONSTRAINT DF_booking_seats_status DEFAULT ('BOOKED'),
        created_at          DATETIME2(3) NOT NULL CONSTRAINT DF_booking_seats_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at          DATETIME2(3) NOT NULL CONSTRAINT DF_booking_seats_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_booking_seats PRIMARY KEY CLUSTERED (booking_seat_id),
        CONSTRAINT UQ_booking_seats_booking_seat UNIQUE (booking_id, seat_id),
        CONSTRAINT FK_booking_seats_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id) ON DELETE CASCADE,
        CONSTRAINT FK_booking_seats_showtime FOREIGN KEY (showtime_id) REFERENCES dbo.showtimes(showtime_id),
        CONSTRAINT FK_booking_seats_seat FOREIGN KEY (seat_id) REFERENCES dbo.seats(seat_id),
        CONSTRAINT CK_booking_seats_type CHECK (seat_type_snapshot IN ('STANDARD', 'VIP', 'COUPLE')),
        CONSTRAINT CK_booking_seats_price CHECK (unit_price >= 0),
        CONSTRAINT CK_booking_seats_status CHECK (status IN ('BOOKED', 'CANCELLED'))
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.booking_seats') AND name = N'UX_booking_seats_sold_seat'
)
BEGIN
    CREATE UNIQUE INDEX UX_booking_seats_sold_seat
        ON dbo.booking_seats(showtime_id, seat_id)
        WHERE status = 'BOOKED';
END;
GO

IF OBJECT_ID(N'dbo.booking_combos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.booking_combos
    (
        booking_combo_id   BIGINT IDENTITY(1,1) NOT NULL,
        booking_id         BIGINT NOT NULL,
        combo_id           BIGINT NOT NULL,
        combo_name_snapshot NVARCHAR(150) NOT NULL,
        unit_price         DECIMAL(19,2) NOT NULL,
        quantity           SMALLINT NOT NULL,
        line_total         AS (CONVERT(DECIMAL(19,2), unit_price * quantity)) PERSISTED,
        created_at         DATETIME2(3) NOT NULL CONSTRAINT DF_booking_combos_created_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_booking_combos PRIMARY KEY CLUSTERED (booking_combo_id),
        CONSTRAINT UQ_booking_combos_booking_combo UNIQUE (booking_id, combo_id),
        CONSTRAINT FK_booking_combos_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id) ON DELETE CASCADE,
        CONSTRAINT FK_booking_combos_combo FOREIGN KEY (combo_id) REFERENCES dbo.combos(combo_id),
        CONSTRAINT CK_booking_combos_price CHECK (unit_price >= 0),
        CONSTRAINT CK_booking_combos_quantity CHECK (quantity BETWEEN 1 AND 99)
    );
END;
GO

IF OBJECT_ID(N'dbo.payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.payments
    (
        payment_id         BIGINT IDENTITY(1,1) NOT NULL,
        booking_id         BIGINT NOT NULL,
        provider           VARCHAR(40) NOT NULL,
        provider_reference VARCHAR(100) NULL,
        idempotency_key    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_payments_idempotency DEFAULT (NEWID()),
        status             VARCHAR(20) NOT NULL,
        amount             DECIMAL(19,2) NOT NULL,
        currency           CHAR(3) NOT NULL CONSTRAINT DF_payments_currency DEFAULT ('VND'),
        failure_reason     NVARCHAR(500) NULL,
        processed_at       DATETIME2(3) NULL,
        created_at         DATETIME2(3) NOT NULL CONSTRAINT DF_payments_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at         DATETIME2(3) NOT NULL CONSTRAINT DF_payments_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version        ROWVERSION NOT NULL,
        CONSTRAINT PK_payments PRIMARY KEY CLUSTERED (payment_id),
        CONSTRAINT UQ_payments_idempotency UNIQUE (idempotency_key),
        CONSTRAINT FK_payments_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT CK_payments_status CHECK (status IN ('PENDING', 'SUCCEEDED', 'FAILED', 'CANCELLED', 'REFUNDED')),
        CONSTRAINT CK_payments_amount CHECK (amount >= 0),
        CONSTRAINT CK_payments_currency CHECK (currency = 'VND'),
        CONSTRAINT CK_payments_processed CHECK
        (
            (status = 'PENDING' AND processed_at IS NULL)
            OR (status <> 'PENDING' AND processed_at IS NOT NULL)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.payments') AND name = N'UX_payments_provider_reference'
)
BEGIN
    CREATE UNIQUE INDEX UX_payments_provider_reference
        ON dbo.payments(provider, provider_reference)
        WHERE provider_reference IS NOT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.payments') AND name = N'IX_payments_booking_created_at'
)
BEGIN
    CREATE INDEX IX_payments_booking_created_at
        ON dbo.payments(booking_id, created_at DESC)
        INCLUDE (status, amount, provider_reference);
END;
GO

IF OBJECT_ID(N'dbo.reviews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.reviews
    (
        review_id          BIGINT IDENTITY(1,1) NOT NULL,
        user_id            BIGINT NOT NULL,
        movie_id           BIGINT NOT NULL,
        booking_id         BIGINT NULL,
        rating             TINYINT NOT NULL,
        title              NVARCHAR(150) NULL,
        content            NVARCHAR(2000) NOT NULL,
        contains_spoiler   BIT NOT NULL CONSTRAINT DF_reviews_contains_spoiler DEFAULT (0),
        status             VARCHAR(20) NOT NULL CONSTRAINT DF_reviews_status DEFAULT ('VISIBLE'),
        moderated_by       BIGINT NULL,
        moderated_at       DATETIME2(3) NULL,
        moderation_note    NVARCHAR(500) NULL,
        created_at         DATETIME2(3) NOT NULL CONSTRAINT DF_reviews_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at         DATETIME2(3) NOT NULL CONSTRAINT DF_reviews_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version        ROWVERSION NOT NULL,
        CONSTRAINT PK_reviews PRIMARY KEY CLUSTERED (review_id),
        CONSTRAINT UQ_reviews_user_movie UNIQUE (user_id, movie_id),
        CONSTRAINT FK_reviews_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_reviews_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies(movie_id),
        CONSTRAINT FK_reviews_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_reviews_moderator FOREIGN KEY (moderated_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_reviews_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT CK_reviews_status CHECK (status IN ('VISIBLE', 'HIDDEN', 'DELETED')),
        CONSTRAINT CK_reviews_moderation CHECK
        (
            (status = 'VISIBLE' AND moderated_by IS NULL AND moderated_at IS NULL)
            OR (status IN ('HIDDEN', 'DELETED') AND moderated_by IS NOT NULL AND moderated_at IS NOT NULL)
        )
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.reviews') AND name = N'IX_reviews_movie_visible'
)
BEGIN
    CREATE INDEX IX_reviews_movie_visible
        ON dbo.reviews(movie_id, created_at DESC)
        INCLUDE (user_id, rating, title, contains_spoiler)
        WHERE status = 'VISIBLE';
END;
GO

IF OBJECT_ID(N'dbo.watchlists', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.watchlists
    (
        user_id    BIGINT NOT NULL,
        movie_id   BIGINT NOT NULL,
        created_at DATETIME2(3) NOT NULL CONSTRAINT DF_watchlists_created_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_watchlists PRIMARY KEY CLUSTERED (user_id, movie_id),
        CONSTRAINT FK_watchlists_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE,
        CONSTRAINT FK_watchlists_movie FOREIGN KEY (movie_id) REFERENCES dbo.movies(movie_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID(N'dbo.banners', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.banners
    (
        banner_id     BIGINT IDENTITY(1,1) NOT NULL,
        title         NVARCHAR(200) NOT NULL,
        subtitle      NVARCHAR(500) NULL,
        image_url     NVARCHAR(1000) NOT NULL,
        target_url    NVARCHAR(1000) NULL,
        placement     VARCHAR(30) NOT NULL CONSTRAINT DF_banners_placement DEFAULT ('HOME_HERO'),
        display_order INT NOT NULL CONSTRAINT DF_banners_display_order DEFAULT (0),
        starts_at     DATETIME2(3) NOT NULL,
        ends_at       DATETIME2(3) NOT NULL,
        is_active     BIT NOT NULL CONSTRAINT DF_banners_is_active DEFAULT (1),
        created_by    BIGINT NULL,
        created_at    DATETIME2(3) NOT NULL CONSTRAINT DF_banners_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at    DATETIME2(3) NOT NULL CONSTRAINT DF_banners_updated_at DEFAULT (SYSUTCDATETIME()),
        row_version   ROWVERSION NOT NULL,
        CONSTRAINT PK_banners PRIMARY KEY CLUSTERED (banner_id),
        CONSTRAINT FK_banners_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_banners_placement CHECK (placement IN ('HOME_HERO', 'HOME_PROMO', 'MOVIE_DETAIL')),
        CONSTRAINT CK_banners_window CHECK (ends_at > starts_at)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.banners') AND name = N'IX_banners_active_placement'
)
BEGIN
    CREATE INDEX IX_banners_active_placement
        ON dbo.banners(placement, is_active, starts_at, ends_at)
        INCLUDE (display_order, title, image_url, target_url);
END;
GO

IF TYPE_ID(N'dbo.SeatIdList') IS NULL
BEGIN
    EXEC(N'CREATE TYPE dbo.SeatIdList AS TABLE
    (
        seat_id BIGINT NOT NULL PRIMARY KEY
    );');
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_expire_seat_holds
    @as_of DATETIME2(3) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now DATETIME2(3) = COALESCE(@as_of, SYSUTCDATETIME());

    UPDATE dbo.seat_holds WITH (UPDLOCK, ROWLOCK)
       SET status = 'EXPIRED',
           released_at = @now,
           updated_at = @now
     WHERE status = 'ACTIVE'
       AND expires_at <= @now;

    SELECT @@ROWCOUNT AS expired_seat_count;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_acquire_seat_hold
    @showtime_id BIGINT,
    @seat_ids dbo.SeatIdList READONLY,
    @user_id BIGINT = NULL,
    @session_key VARCHAR(128) = NULL,
    @hold_token UNIQUEIDENTIFIER = NULL OUTPUT,
    @hold_minutes TINYINT = 7,
    @expires_at DATETIME2(3) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM @seat_ids)
        THROW 51001, 'At least one seat must be selected.', 1;

    IF @user_id IS NULL AND NULLIF(LTRIM(RTRIM(@session_key)), '') IS NULL
        THROW 51002, 'A user_id or session_key is required.', 1;

    IF @hold_minutes NOT BETWEEN 1 AND 15
        THROW 51003, 'Hold duration must be between 1 and 15 minutes.', 1;

    DECLARE @now DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @auditorium_id BIGINT;
    DECLARE @existing_token BIT = 0;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @auditorium_id = auditorium_id
          FROM dbo.showtimes WITH (UPDLOCK, HOLDLOCK)
         WHERE showtime_id = @showtime_id
           AND status = 'SCHEDULED'
           AND sales_open_at <= @now
           AND starts_at > @now;

        IF @auditorium_id IS NULL
            THROW 51004, 'Showtime is missing, closed, cancelled, or already started.', 1;

        UPDATE dbo.seat_holds WITH (UPDLOCK, ROWLOCK)
           SET status = 'EXPIRED',
               released_at = @now,
               updated_at = @now
         WHERE status = 'ACTIVE'
           AND expires_at <= @now;

        IF (SELECT COUNT_BIG(*) FROM @seat_ids) <>
           (
               SELECT COUNT_BIG(*)
                 FROM dbo.seats s WITH (HOLDLOCK)
                 JOIN @seat_ids requested ON requested.seat_id = s.seat_id
                WHERE s.auditorium_id = @auditorium_id
                  AND s.is_active = 1
           )
            THROW 51005, 'One or more seats are invalid or inactive for this auditorium.', 1;

        IF EXISTS
        (
            SELECT 1
              FROM dbo.seats s
              JOIN @seat_ids requested ON requested.seat_id = s.seat_id
             WHERE s.seat_type = 'COUPLE'
               AND NOT EXISTS
                   (SELECT 1 FROM @seat_ids partner WHERE partner.seat_id = s.pair_seat_id)
        )
            THROW 51006, 'Couple seats must be selected as a complete pair.', 1;

        IF @hold_token IS NULL
        BEGIN
            SET @hold_token = NEWID();
            SET @expires_at = DATEADD(MINUTE, @hold_minutes, @now);
        END
        ELSE
        BEGIN
            SELECT TOP (1)
                   @expires_at = expires_at,
                   @existing_token = 1
              FROM dbo.seat_holds WITH (UPDLOCK, HOLDLOCK)
             WHERE hold_token = @hold_token
               AND showtime_id = @showtime_id
               AND status = 'ACTIVE'
               AND expires_at > @now
               AND
               (
                   (@user_id IS NOT NULL AND (user_id = @user_id OR (user_id IS NULL AND session_key = @session_key)))
                   OR
                   (@user_id IS NULL AND session_key = @session_key)
               );

            IF @existing_token = 0
                THROW 51007, 'The hold token is invalid, expired, released, or owned by another customer.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
              FROM dbo.booking_seats bs WITH (UPDLOCK, HOLDLOCK)
              JOIN @seat_ids requested ON requested.seat_id = bs.seat_id
             WHERE bs.showtime_id = @showtime_id
               AND bs.status = 'BOOKED'
        )
            THROW 51008, 'One or more selected seats have already been sold.', 1;

        IF EXISTS
        (
            SELECT 1
              FROM dbo.seat_holds h WITH (UPDLOCK, HOLDLOCK)
              JOIN @seat_ids requested ON requested.seat_id = h.seat_id
             WHERE h.showtime_id = @showtime_id
               AND h.status = 'ACTIVE'
               AND h.hold_token <> @hold_token
        )
            THROW 51009, 'One or more selected seats are held by another customer.', 1;

        UPDATE h
           SET h.status = 'RELEASED',
               h.released_at = @now,
               h.updated_at = @now
          FROM dbo.seat_holds h
         WHERE h.hold_token = @hold_token
           AND h.status = 'ACTIVE'
           AND NOT EXISTS
               (SELECT 1 FROM @seat_ids requested WHERE requested.seat_id = h.seat_id);

        UPDATE h
           SET h.user_id = COALESCE(@user_id, h.user_id),
               h.session_key = COALESCE(@session_key, h.session_key),
               h.status = 'ACTIVE',
               h.price_snapshot =
                   CASE
                       WHEN s.seat_type = 'COUPLE' AND s.seat_id > s.pair_seat_id THEN 0
                       ELSE COALESCE(p.price, st.base_price)
                   END,
               h.released_at = NULL,
               h.converted_at = NULL,
               h.updated_at = @now
          FROM dbo.seat_holds h
          JOIN @seat_ids requested ON requested.seat_id = h.seat_id
          JOIN dbo.seats s ON s.seat_id = h.seat_id
          JOIN dbo.showtimes st ON st.showtime_id = h.showtime_id
         LEFT JOIN dbo.seat_prices p
            ON p.showtime_id = h.showtime_id
           AND p.seat_type = s.seat_type
         WHERE h.hold_token = @hold_token
           AND h.status IN ('ACTIVE', 'RELEASED');

        INSERT dbo.seat_holds
        (
            hold_token, showtime_id, seat_id, user_id, session_key, status,
            price_snapshot, expires_at, created_at, updated_at
        )
        SELECT @hold_token,
               @showtime_id,
               s.seat_id,
               @user_id,
               @session_key,
               'ACTIVE',
               CASE
                   WHEN s.seat_type = 'COUPLE' AND s.seat_id > s.pair_seat_id THEN 0
                   ELSE COALESCE(p.price, st.base_price)
               END,
               @expires_at,
               @now,
               @now
          FROM @seat_ids requested
          JOIN dbo.seats s ON s.seat_id = requested.seat_id
          JOIN dbo.showtimes st ON st.showtime_id = @showtime_id
          LEFT JOIN dbo.seat_prices p
            ON p.showtime_id = @showtime_id
           AND p.seat_type = s.seat_type
         WHERE NOT EXISTS
               (
                   SELECT 1
                     FROM dbo.seat_holds existing
                    WHERE existing.hold_token = @hold_token
                      AND existing.seat_id = s.seat_id
               );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 51010, 'A selected seat was acquired concurrently. Refresh availability and try again.', 1;
        THROW;
    END CATCH;

    SELECT h.hold_token,
           h.showtime_id,
           h.expires_at,
           h.seat_id,
           s.seat_label,
           s.seat_type,
           h.price_snapshot AS price,
           SUM(h.price_snapshot) OVER () AS ticket_subtotal
      FROM dbo.seat_holds h
      JOIN dbo.seats s ON s.seat_id = h.seat_id
     WHERE h.hold_token = @hold_token
       AND h.status = 'ACTIVE'
     ORDER BY s.row_label, s.seat_number;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_release_seat_hold
    @hold_token UNIQUEIDENTIFIER,
    @user_id BIGINT = NULL,
    @session_key VARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now DATETIME2(3) = SYSUTCDATETIME();

    BEGIN TRANSACTION;

    UPDATE dbo.seat_holds WITH (UPDLOCK, HOLDLOCK)
       SET status = 'RELEASED',
           released_at = @now,
           updated_at = @now
     WHERE hold_token = @hold_token
       AND status = 'ACTIVE'
       AND
       (
           (@user_id IS NOT NULL AND (user_id = @user_id OR (user_id IS NULL AND session_key = @session_key)))
           OR (@user_id IS NULL AND session_key = @session_key)
       );

    IF @@ROWCOUNT = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51011, 'Active hold was not found or belongs to another customer.', 1;
    END;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER VIEW dbo.vw_seat_availability
AS
    SELECT st.showtime_id,
           s.seat_id,
           s.auditorium_id,
           s.seat_label,
           s.row_label,
           s.seat_number,
           s.seat_type,
           s.pair_seat_id,
           COALESCE(p.price, st.base_price) AS price,
           COALESCE(p.price_mode, CASE WHEN s.seat_type = 'COUPLE' THEN 'PER_PAIR' ELSE 'PER_SEAT' END) AS price_mode,
           CASE
               WHEN EXISTS
                    (
                        SELECT 1 FROM dbo.booking_seats bs
                         WHERE bs.showtime_id = st.showtime_id
                           AND bs.seat_id = s.seat_id
                           AND bs.status = 'BOOKED'
                    ) THEN 'SOLD'
               WHEN EXISTS
                    (
                        SELECT 1 FROM dbo.seat_holds h
                         WHERE h.showtime_id = st.showtime_id
                           AND h.seat_id = s.seat_id
                           AND h.status = 'ACTIVE'
                           AND h.expires_at > SYSUTCDATETIME()
                    ) THEN 'HELD'
               ELSE 'AVAILABLE'
           END AS availability_status
      FROM dbo.showtimes st
      JOIN dbo.seats s
        ON s.auditorium_id = st.auditorium_id
       AND s.is_active = 1
      LEFT JOIN dbo.seat_prices p
        ON p.showtime_id = st.showtime_id
       AND p.seat_type = s.seat_type;
GO
/*
 * CineBook - development seed data
 *
 * Prerequisite: run schema.sql first.
 * The script uses stable natural keys and inserts missing rows only. It is safe
 * to rerun against a development database without deleting application data.
 */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.users', N'U') IS NULL
    THROW 52000, 'CineBook schema is missing. Run schema.sql before seed.sql.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @now DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @local_today DATE = CONVERT(DATE, DATEADD(HOUR, 7, @now));
    DECLARE @next_local_midnight_utc DATETIME2(3) =
        DATEADD(HOUR, -7, CONVERT(DATETIME2(3), DATEADD(DAY, 1, @local_today)));

    /* Demo users. All seed accounts use the BCrypt (cost 12) hash for plaintext: password */
    IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'admin@cinebook.vn')
    BEGIN
        INSERT dbo.users
            (email, password_hash, full_name, phone, role, is_active, is_locked, email_verified)
        VALUES
            (N'admin@cinebook.vn',
             N'$2a$12$c1Ge/lbFwhwBHWP4JDVhH.7kNRaHCKRkIJ6xDKj9dtO4pzQStjEvK',
             N'Minh Nguyen', N'+84 90 100 2001', 'ADMIN', 1, 0, 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'customer@cinebook.vn')
    BEGIN
        INSERT dbo.users
            (email, password_hash, full_name, phone, role, is_active, is_locked, email_verified)
        VALUES
            (N'customer@cinebook.vn',
             N'$2a$12$c1Ge/lbFwhwBHWP4JDVhH.7kNRaHCKRkIJ6xDKj9dtO4pzQStjEvK',
             N'Lan Tran', N'+84 91 234 5678', 'CUSTOMER', 1, 0, 1);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'reviewer@cinebook.vn')
    BEGIN
        INSERT dbo.users
            (email, password_hash, full_name, phone, role, is_active, is_locked,
             email_verified, locked_at)
        VALUES
            (N'reviewer@cinebook.vn',
             N'$2a$12$c1Ge/lbFwhwBHWP4JDVhH.7kNRaHCKRkIJ6xDKj9dtO4pzQStjEvK',
             N'Quang Le', N'+84 93 555 0199', 'CUSTOMER', 1, 1, 1, DATEADD(DAY, -2, @now));
    END;

    /* Genres */
    INSERT dbo.genres (name, slug)
    SELECT source.name, source.slug
      FROM
      (
          VALUES
              (N'Action', 'action'),
              (N'Adventure', 'adventure'),
              (N'Animation', 'animation'),
              (N'Comedy', 'comedy'),
              (N'Drama', 'drama'),
              (N'Family', 'family'),
              (N'Romance', 'romance'),
              (N'Science Fiction', 'science-fiction'),
              (N'Thriller', 'thriller')
      ) source(name, slug)
     WHERE NOT EXISTS (SELECT 1 FROM dbo.genres g WHERE g.slug = source.slug);

    /* Fictional catalog */
    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'saigon-after-rain')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'Saigon After Rain', 'saigon-after-rain',
            N'A young photojournalist follows a trail of forgotten letters through modern Ho Chi Minh City and discovers a family story that changes her future.',
            N'Mai Hoang', N'Linh Pham, Anh Tu, Bao Nguyen', 116,
            'T13', DATEADD(DAY, -21, @local_today), DATEADD(DAY, 45, @local_today),
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/172554/FFFFFF?text=Saigon+After+Rain',
            N'https://placehold.co/1600x900/172554/FFFFFF?text=Saigon+After+Rain',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'NOW_SHOWING'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'orbit-zero')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'Orbit Zero', 'orbit-zero',
            N'When a research station loses contact with Earth, its Vietnamese flight engineer must choose between completing the mission and bringing the crew home.',
            N'Daniel Kwan', N'Vy Nguyen, Marcus Reed, Hana Sato', 128,
            'T16', DATEADD(DAY, -14, @local_today), DATEADD(DAY, 55, @local_today),
            N'English', N'Vietnam / United States',
            N'https://placehold.co/600x900/111827/67E8F9?text=Orbit+Zero',
            N'https://placehold.co/1600x900/111827/67E8F9?text=Orbit+Zero',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'NOW_SHOWING'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'laughing-in-district-one')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'Laughing in District One', 'laughing-in-district-one',
            N'Two rival street-food vendors accidentally become internet celebrities and have one chaotic weekend to save their market from redevelopment.',
            N'Thuy Dao', N'Khoa Vo, Nhi Lam, Tam Bui', 104,
            'P', DATEADD(DAY, -7, @local_today), DATEADD(DAY, 50, @local_today),
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/7C2D12/FDE68A?text=Laughing+in+District+One',
            N'https://placehold.co/1600x900/7C2D12/FDE68A?text=Laughing+in+District+One',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'NOW_SHOWING'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'river-of-dragons')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'River of Dragons', 'river-of-dragons',
            N'A brother and sister race along the Mekong to return a legendary jade seal before a private collector can erase its history.',
            N'An Phan', N'Minh Chau, Son Le, Isabelle Tran', 121,
            'T13', DATEADD(DAY, -28, @local_today), DATEADD(DAY, 35, @local_today),
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/14532D/F0FDF4?text=River+of+Dragons',
            N'https://placehold.co/1600x900/14532D/F0FDF4?text=River+of+Dragons',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'NOW_SHOWING'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'echoes-of-hoi-an')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'Echoes of Hoi An', 'echoes-of-hoi-an',
            N'An architect restoring an old assembly hall begins hearing music tied to a romance separated by half a century.',
            N'Ha Le', N'Thu Ha, Duc Anh, Chiaki Mori', 112,
            'T13', DATEADD(DAY, 12, @local_today), NULL,
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/78350F/FEF3C7?text=Echoes+of+Hoi+An',
            N'https://placehold.co/1600x900/78350F/FEF3C7?text=Echoes+of+Hoi+An',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'COMING_SOON'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'neon-monsoon')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'Neon Monsoon', 'neon-monsoon',
            N'A reluctant detective and a delivery rider cross paths while investigating a disappearance during one stormy night in Hanoi.',
            N'Jonas Vu', N'Trang Do, Alex Pham, My Linh', 119,
            'T16', DATEADD(DAY, 20, @local_today), NULL,
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/3B0764/F5D0FE?text=Neon+Monsoon',
            N'https://placehold.co/1600x900/3B0764/F5D0FE?text=Neon+Monsoon',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'COMING_SOON'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'the-paper-moon')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'The Paper Moon', 'the-paper-moon',
            N'A shy child folds an impossible paper moon and follows it into an animated world built from family memories.',
            N'Yen Bui', N'Mai Anh, Huy Tran, The Lantern Studio', 97,
            'P', DATEADD(DAY, 30, @local_today), NULL,
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/1E3A8A/DBEAFE?text=The+Paper+Moon',
            N'https://placehold.co/1600x900/1E3A8A/DBEAFE?text=The+Paper+Moon',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'COMING_SOON'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.movies WHERE slug = 'the-last-lantern')
    BEGIN
        INSERT dbo.movies
        (
            title, slug, synopsis, director, cast_text, duration_minutes,
            age_rating, release_date, end_date, original_language, country,
            poster_url, backdrop_url, trailer_url, status
        )
        VALUES
        (
            N'The Last Lantern', 'the-last-lantern',
            N'A retired artisan has one final week to teach his granddaughter the craft behind the lantern that made their village famous.',
            N'Phuong Nguyen', N'Bao Chau, Ngoc Lan, Tien Dat', 108,
            'P', DATEADD(DAY, -120, @local_today), DATEADD(DAY, -45, @local_today),
            N'Vietnamese', N'Vietnam',
            N'https://placehold.co/600x900/9A3412/FFEDD5?text=The+Last+Lantern',
            N'https://placehold.co/1600x900/9A3412/FFEDD5?text=The+Last+Lantern',
            N'https://www.youtube.com/embed/aqz-KE-bpKQ', 'ARCHIVED'
        );
    END;

    /* Movie genre and supported-format links */
    INSERT dbo.movie_genres (movie_id, genre_id)
    SELECT m.movie_id, g.genre_id
      FROM
      (
          VALUES
              ('saigon-after-rain', 'drama'),
              ('saigon-after-rain', 'romance'),
              ('orbit-zero', 'science-fiction'),
              ('orbit-zero', 'thriller'),
              ('laughing-in-district-one', 'comedy'),
              ('laughing-in-district-one', 'family'),
              ('river-of-dragons', 'action'),
              ('river-of-dragons', 'adventure'),
              ('echoes-of-hoi-an', 'drama'),
              ('echoes-of-hoi-an', 'romance'),
              ('neon-monsoon', 'thriller'),
              ('neon-monsoon', 'action'),
              ('the-paper-moon', 'animation'),
              ('the-paper-moon', 'family'),
              ('the-last-lantern', 'drama'),
              ('the-last-lantern', 'family')
      ) source(movie_slug, genre_slug)
      JOIN dbo.movies m ON m.slug = source.movie_slug
      JOIN dbo.genres g ON g.slug = source.genre_slug
     WHERE NOT EXISTS
           (
               SELECT 1 FROM dbo.movie_genres mg
                WHERE mg.movie_id = m.movie_id AND mg.genre_id = g.genre_id
           );

    INSERT dbo.movie_formats (movie_id, format)
    SELECT m.movie_id, source.format
      FROM
      (
          VALUES
              ('saigon-after-rain', '2D'),
              ('orbit-zero', '2D'),
              ('orbit-zero', '3D'),
              ('orbit-zero', 'IMAX'),
              ('laughing-in-district-one', '2D'),
              ('river-of-dragons', '2D'),
              ('river-of-dragons', 'IMAX'),
              ('echoes-of-hoi-an', '2D'),
              ('neon-monsoon', '2D'),
              ('neon-monsoon', 'IMAX'),
              ('the-paper-moon', '2D'),
              ('the-paper-moon', '3D'),
              ('the-last-lantern', '2D')
      ) source(movie_slug, format)
      JOIN dbo.movies m ON m.slug = source.movie_slug
     WHERE NOT EXISTS
           (
               SELECT 1 FROM dbo.movie_formats mf
                WHERE mf.movie_id = m.movie_id AND mf.format = source.format
           );

    /* Vietnamese cinema locations */
    IF NOT EXISTS (SELECT 1 FROM dbo.cinemas WHERE slug = 'cinebook-landmark-81')
    BEGIN
        INSERT dbo.cinemas
            (name, slug, city, district, address, phone, latitude, longitude)
        VALUES
            (N'CineBook Landmark 81', 'cinebook-landmark-81', N'Ho Chi Minh City',
             N'Binh Thanh', N'208 Nguyen Huu Canh Street, Ward 22',
             N'+84 28 7300 8101', 10.794952, 106.721864);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.cinemas WHERE slug = 'cinebook-metropolis-hanoi')
    BEGIN
        INSERT dbo.cinemas
            (name, slug, city, district, address, phone, latitude, longitude)
        VALUES
            (N'CineBook Metropolis Hanoi', 'cinebook-metropolis-hanoi', N'Hanoi',
             N'Ba Dinh', N'29 Lieu Giai Street, Ngoc Khanh Ward',
             N'+84 24 7300 2901', 21.031778, 105.812155);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.cinemas WHERE slug = 'cinebook-han-river')
    BEGIN
        INSERT dbo.cinemas
            (name, slug, city, district, address, phone, latitude, longitude)
        VALUES
            (N'CineBook Han River', 'cinebook-han-river', N'Da Nang',
             N'Hai Chau', N'2 September Street, Hoa Cuong Bac Ward',
             N'+84 236 7300 0209', 16.048475, 108.226764);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.cinemas WHERE slug = 'cinebook-ninh-kieu')
    BEGIN
        INSERT dbo.cinemas
            (name, slug, city, district, address, phone, latitude, longitude)
        VALUES
            (N'CineBook Ninh Kieu', 'cinebook-ninh-kieu', N'Can Tho',
             N'Ninh Kieu', N'2 Hai Ba Trung Street, Tan An Ward',
             N'+84 292 7300 2202', 10.034063, 105.787174);
    END;

    /* Auditoriums share a compact 66-seat development layout. */
    INSERT dbo.auditoriums (cinema_id, name, auditorium_type, capacity)
    SELECT c.cinema_id, source.name, source.auditorium_type, 66
      FROM
      (
          VALUES
              ('cinebook-landmark-81', N'Hall 1', 'STANDARD'),
              ('cinebook-landmark-81', N'IMAX 1', 'IMAX'),
              ('cinebook-metropolis-hanoi', N'Hall 1', 'STANDARD'),
              ('cinebook-metropolis-hanoi', N'Premium 2', 'PREMIUM'),
              ('cinebook-han-river', N'Hall 1', 'STANDARD'),
              ('cinebook-ninh-kieu', N'Hall 1', 'STANDARD')
      ) source(cinema_slug, name, auditorium_type)
      JOIN dbo.cinemas c ON c.slug = source.cinema_slug
     WHERE NOT EXISTS
           (
               SELECT 1 FROM dbo.auditoriums a
                WHERE a.cinema_id = c.cinema_id AND a.name = source.name
           );

    /* Rows A-C: STANDARD; rows D-F: VIP; row G: three COUPLE pairs. */
    ;WITH row_types AS
    (
        SELECT row_label, seat_type
          FROM (VALUES
              ('A', 'STANDARD'), ('B', 'STANDARD'), ('C', 'STANDARD'),
              ('D', 'VIP'), ('E', 'VIP'), ('F', 'VIP')
          ) rows(row_label, seat_type)
    ),
    numbers AS
    (
        SELECT seat_number
          FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) n(seat_number)
    )
    INSERT dbo.seats
        (auditorium_id, row_label, seat_number, seat_label, seat_type, is_accessible)
    SELECT a.auditorium_id,
           r.row_label,
           n.seat_number,
           CONCAT(r.row_label, n.seat_number),
           r.seat_type,
           CASE WHEN r.row_label = 'A' AND n.seat_number IN (1, 2) THEN 1 ELSE 0 END
      FROM dbo.auditoriums a
      JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
      CROSS JOIN row_types r
      CROSS JOIN numbers n
     WHERE c.slug IN
           ('cinebook-landmark-81', 'cinebook-metropolis-hanoi', 'cinebook-han-river', 'cinebook-ninh-kieu')
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.seats s
                WHERE s.auditorium_id = a.auditorium_id
                  AND s.row_label = r.row_label
                  AND s.seat_number = n.seat_number
           );

    ;WITH couple_numbers AS
    (
        SELECT seat_number FROM (VALUES (1),(2),(3),(4),(5),(6)) n(seat_number)
    )
    INSERT dbo.seats
        (auditorium_id, row_label, seat_number, seat_label, seat_type, pair_seat_id)
    SELECT a.auditorium_id,
           'G',
           n.seat_number,
           CONCAT('G', n.seat_number),
           'COUPLE',
           NULL
      FROM dbo.auditoriums a
      JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
      CROSS JOIN couple_numbers n
     WHERE c.slug IN
           ('cinebook-landmark-81', 'cinebook-metropolis-hanoi', 'cinebook-han-river', 'cinebook-ninh-kieu')
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.seats s
                WHERE s.auditorium_id = a.auditorium_id
                  AND s.row_label = 'G'
                  AND s.seat_number = n.seat_number
           );

    UPDATE left_seat
       SET left_seat.pair_seat_id = right_seat.seat_id,
           left_seat.updated_at = @now
      FROM dbo.seats left_seat
      JOIN dbo.seats right_seat
        ON right_seat.auditorium_id = left_seat.auditorium_id
       AND right_seat.row_label = left_seat.row_label
       AND right_seat.seat_number = left_seat.seat_number + 1
     WHERE left_seat.seat_type = 'COUPLE'
       AND left_seat.seat_number IN (1, 3, 5)
       AND left_seat.pair_seat_id IS NULL;

    UPDATE right_seat
       SET right_seat.pair_seat_id = left_seat.seat_id,
           right_seat.updated_at = @now
      FROM dbo.seats right_seat
      JOIN dbo.seats left_seat
        ON left_seat.auditorium_id = right_seat.auditorium_id
       AND left_seat.row_label = right_seat.row_label
       AND left_seat.seat_number = right_seat.seat_number - 1
     WHERE right_seat.seat_type = 'COUPLE'
       AND right_seat.seat_number IN (2, 4, 6)
       AND right_seat.pair_seat_id IS NULL;

    /* Future showtimes are anchored when the seed is first run. Times are UTC. */
    DECLARE @landmark_hall BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-landmark-81' AND a.name = N'Hall 1'
    );
    DECLARE @landmark_imax BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-landmark-81' AND a.name = N'IMAX 1'
    );
    DECLARE @hanoi_hall BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-metropolis-hanoi' AND a.name = N'Hall 1'
    );
    DECLARE @hanoi_premium BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-metropolis-hanoi' AND a.name = N'Premium 2'
    );
    DECLARE @danang_hall BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-han-river' AND a.name = N'Hall 1'
    );
    DECLARE @cantho_hall BIGINT =
    (
        SELECT a.auditorium_id FROM dbo.auditoriums a
        JOIN dbo.cinemas c ON c.cinema_id = a.cinema_id
        WHERE c.slug = 'cinebook-ninh-kieu' AND a.name = N'Hall 1'
    );

    DECLARE @showtime_seed TABLE
    (
        source_ref VARCHAR(80) NOT NULL,
        movie_slug VARCHAR(220) NOT NULL,
        auditorium_id BIGINT NOT NULL,
        day_offset INT NOT NULL,
        local_hour INT NOT NULL,
        local_minute INT NOT NULL,
        format VARCHAR(10) NOT NULL,
        base_price DECIMAL(19,2) NOT NULL,
        audio_language NVARCHAR(80) NOT NULL,
        subtitle_language NVARCHAR(80) NULL,
        status VARCHAR(20) NOT NULL
    );

    INSERT @showtime_seed
    VALUES
        ('SEED-LM-H1-001', 'saigon-after-rain', @landmark_hall, 0, 10, 0, '2D', 120000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-LM-H1-002', 'laughing-in-district-one', @landmark_hall, 0, 13, 30, '2D', 120000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-LM-H1-003', 'river-of-dragons', @landmark_hall, 0, 17, 0, '2D', 140000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-LM-IMAX-001', 'orbit-zero', @landmark_imax, 0, 11, 0, 'IMAX', 190000, N'English', N'Vietnamese', 'SCHEDULED'),
        ('SEED-LM-IMAX-002', 'river-of-dragons', @landmark_imax, 0, 15, 0, 'IMAX', 190000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-HN-H1-001', 'saigon-after-rain', @hanoi_hall, 0, 9, 30, '2D', 110000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-HN-H1-002', 'laughing-in-district-one', @hanoi_hall, 0, 13, 0, '2D', 110000, N'Vietnamese', NULL, 'SCHEDULED'),
        ('SEED-HN-P2-001', 'orbit-zero', @hanoi_premium, 0, 18, 30, '3D', 170000, N'English', N'Vietnamese', 'SCHEDULED'),
        ('SEED-DN-H1-001', 'river-of-dragons', @danang_hall, 0, 10, 30, '2D', 100000, N'Vietnamese', N'English', 'SCHEDULED'),
        ('SEED-DN-H1-002', 'orbit-zero', @danang_hall, 0, 15, 0, '2D', 110000, N'English', N'Vietnamese', 'SCHEDULED'),
        ('SEED-CT-H1-001', 'laughing-in-district-one', @cantho_hall, 0, 11, 0, '2D', 90000, N'Vietnamese', NULL, 'SCHEDULED'),
        ('SEED-CT-H1-002', 'saigon-after-rain', @cantho_hall, 1, 18, 0, '2D', 100000, N'Vietnamese', N'English', 'SCHEDULED');

    INSERT dbo.showtimes
    (
        movie_id, auditorium_id, starts_at, ends_at, sales_open_at,
        format, base_price, audio_language, subtitle_language, status, source_ref
    )
    SELECT m.movie_id,
           source.auditorium_id,
           DATEADD(MINUTE, source.local_minute,
               DATEADD(HOUR, source.local_hour,
                   DATEADD(DAY, source.day_offset, @next_local_midnight_utc))),
           DATEADD(MINUTE, m.duration_minutes,
               DATEADD(MINUTE, source.local_minute,
                   DATEADD(HOUR, source.local_hour,
                       DATEADD(DAY, source.day_offset, @next_local_midnight_utc)))),
           DATEADD(DAY, -30,
               DATEADD(MINUTE, source.local_minute,
                   DATEADD(HOUR, source.local_hour,
                       DATEADD(DAY, source.day_offset, @next_local_midnight_utc)))),
           source.format,
           source.base_price,
           source.audio_language,
           source.subtitle_language,
           source.status,
           source.source_ref
      FROM @showtime_seed source
      JOIN dbo.movies m ON m.slug = source.movie_slug
     WHERE NOT EXISTS
           (SELECT 1 FROM dbo.showtimes st WHERE st.source_ref = source.source_ref);

    /* One historical showtime supports demo booking/review/history screens. */
    DECLARE @history_start DATETIME2(3) =
        DATEADD
        (
            HOUR, 19,
            DATEADD
            (
                DAY, -14,
                DATEADD(HOUR, -7, CONVERT(DATETIME2(3), @local_today))
            )
        );

    IF NOT EXISTS (SELECT 1 FROM dbo.showtimes WHERE source_ref = 'SEED-HISTORY-001')
    BEGIN
        INSERT dbo.showtimes
        (
            movie_id, auditorium_id, starts_at, ends_at, sales_open_at,
            format, base_price, audio_language, subtitle_language, status, source_ref
        )
        SELECT m.movie_id, @landmark_hall, @history_start,
               DATEADD(MINUTE, m.duration_minutes, @history_start),
               DATEADD(DAY, -30, @history_start),
               '2D', 110000, N'Vietnamese', N'English', 'COMPLETED', 'SEED-HISTORY-001'
          FROM dbo.movies m
         WHERE m.slug = 'the-last-lantern';
    END;

    /* Per-showtime VND prices. COUPLE is one price for the pair. */
    INSERT dbo.seat_prices (showtime_id, seat_type, price, price_mode)
    SELECT st.showtime_id,
           source.seat_type,
           CASE source.seat_type
               WHEN 'STANDARD' THEN st.base_price
               WHEN 'VIP' THEN st.base_price + 40000
               WHEN 'COUPLE' THEN (st.base_price * 2) + 50000
           END,
           CASE WHEN source.seat_type = 'COUPLE' THEN 'PER_PAIR' ELSE 'PER_SEAT' END
      FROM dbo.showtimes st
      CROSS JOIN (VALUES ('STANDARD'), ('VIP'), ('COUPLE')) source(seat_type)
     WHERE st.source_ref LIKE 'SEED-%'
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.seat_prices p
                WHERE p.showtime_id = st.showtime_id
                  AND p.seat_type = source.seat_type
           );

    /* Food and beverage combos */
    INSERT dbo.combos (sku, name, description, price, image_url, display_order)
    SELECT source.sku, source.name, source.description, source.price, source.image_url, source.display_order
      FROM
      (
          VALUES
              ('SINGLE-01', N'Solo Crunch',
               N'One medium caramel popcorn and one medium soft drink.',
               CONVERT(DECIMAL(19,2), 69000),
               N'https://placehold.co/600x400/7C2D12/FFFFFF?text=Solo+Crunch', 10),
              ('DUO-01', N'Classic Duo',
               N'One large mixed popcorn and two medium soft drinks.',
               CONVERT(DECIMAL(19,2), 99000),
               N'https://placehold.co/600x400/9A3412/FFFFFF?text=Classic+Duo', 20),
              ('FAMILY-01', N'Family Movie Night',
               N'Two large popcorns, four medium soft drinks, and two bottled waters.',
               CONVERT(DECIMAL(19,2), 199000),
               N'https://placehold.co/600x400/14532D/FFFFFF?text=Family+Movie+Night', 30),
              ('PREMIUM-01', N'Premium Date Combo',
               N'One gourmet cheese popcorn, two large drinks, and one chocolate snack.',
               CONVERT(DECIMAL(19,2), 149000),
               N'https://placehold.co/600x400/581C87/FFFFFF?text=Premium+Date+Combo', 40)
      ) source(sku, name, description, price, image_url, display_order)
     WHERE NOT EXISTS (SELECT 1 FROM dbo.combos c WHERE c.sku = source.sku);

    /* Promotions have moving windows only on first insertion. */
    IF NOT EXISTS (SELECT 1 FROM dbo.promotions WHERE code = 'WELCOME10')
    BEGIN
        INSERT dbo.promotions
        (
            code, name, description, discount_type, discount_value,
            minimum_order, maximum_discount, starts_at, ends_at,
            usage_limit, per_user_limit
        )
        VALUES
        (
            'WELCOME10', N'Welcome to CineBook',
            N'10% off a first demo booking, capped at 50,000 VND.',
            'PERCENT', 10, 150000, 50000,
            DATEADD(DAY, -30, @now), DATEADD(DAY, 365, @now), 5000, 1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.promotions WHERE code = 'STUDENT50')
    BEGIN
        INSERT dbo.promotions
        (
            code, name, description, discount_type, discount_value,
            minimum_order, maximum_discount, starts_at, ends_at,
            usage_limit, per_user_limit
        )
        VALUES
        (
            'STUDENT50', N'Student Movie Night',
            N'50,000 VND off orders from 300,000 VND.',
            'FIXED', 50000, 300000, NULL,
            DATEADD(DAY, -7, @now), DATEADD(DAY, 120, @now), 1000, 3
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.promotions WHERE code = 'WEEKDAY15')
    BEGIN
        INSERT dbo.promotions
        (
            code, name, description, discount_type, discount_value,
            minimum_order, maximum_discount, starts_at, ends_at,
            usage_limit, per_user_limit
        )
        VALUES
        (
            'WEEKDAY15', N'Weekday Escape',
            N'15% off qualifying weekday demo orders, capped at 75,000 VND.',
            'PERCENT', 15, 250000, 75000,
            DATEADD(DAY, -7, @now), DATEADD(DAY, 90, @now), 2000, 5
        );
    END;

    /* Historical paid/used booking with immutable snapshots. */
    DECLARE @customer_id BIGINT =
        (SELECT user_id FROM dbo.users WHERE email = N'customer@cinebook.vn');
    DECLARE @admin_id BIGINT =
        (SELECT user_id FROM dbo.users WHERE email = N'admin@cinebook.vn');
    DECLARE @reviewer_id BIGINT =
        (SELECT user_id FROM dbo.users WHERE email = N'reviewer@cinebook.vn');
    DECLARE @history_showtime_id BIGINT =
        (SELECT showtime_id FROM dbo.showtimes WHERE source_ref = 'SEED-HISTORY-001');
    DECLARE @history_movie_id BIGINT =
        (SELECT movie_id FROM dbo.movies WHERE slug = 'the-last-lantern');
    DECLARE @classic_duo_id BIGINT =
        (SELECT combo_id FROM dbo.combos WHERE sku = 'DUO-01');

    IF NOT EXISTS (SELECT 1 FROM dbo.bookings WHERE booking_code = 'CBDEMO001')
    BEGIN
        INSERT dbo.bookings
        (
            booking_code, user_id, showtime_id, status,
            ticket_subtotal, combo_subtotal, discount_amount,
            tax_rate, tax_amount, service_fee, total_amount,
            paid_at, used_at, created_at, updated_at
        )
        VALUES
        (
            'CBDEMO001', @customer_id, @history_showtime_id, 'USED',
            220000, 99000, 0,
            0.0800, 25520, 10000, 354520,
            DATEADD(DAY, -1, @history_start), DATEADD(MINUTE, 150, @history_start),
            DATEADD(DAY, -1, @history_start), DATEADD(MINUTE, 150, @history_start)
        );
    END;

    DECLARE @history_booking_id BIGINT =
        (SELECT booking_id FROM dbo.bookings WHERE booking_code = 'CBDEMO001');

    INSERT dbo.booking_seats
        (booking_id, showtime_id, seat_id, seat_label_snapshot, seat_type_snapshot, unit_price)
    SELECT @history_booking_id, @history_showtime_id, s.seat_id, s.seat_label, s.seat_type, 110000
      FROM dbo.seats s
     WHERE s.auditorium_id = @landmark_hall
       AND s.seat_label IN ('A1', 'A2')
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.booking_seats bs
                WHERE bs.booking_id = @history_booking_id AND bs.seat_id = s.seat_id
           );

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.booking_combos
         WHERE booking_id = @history_booking_id AND combo_id = @classic_duo_id
    )
    BEGIN
        INSERT dbo.booking_combos
            (booking_id, combo_id, combo_name_snapshot, unit_price, quantity)
        VALUES
            (@history_booking_id, @classic_duo_id, N'Classic Duo', 99000, 1);
    END;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.payments
         WHERE provider = 'SIMULATED' AND provider_reference = 'SIM-CBDEMO001'
    )
    BEGIN
        INSERT dbo.payments
        (
            booking_id, provider, provider_reference, idempotency_key,
            status, amount, processed_at, created_at, updated_at
        )
        VALUES
        (
            @history_booking_id, 'SIMULATED', 'SIM-CBDEMO001',
            '11111111-1111-4111-8111-111111111111',
            'SUCCEEDED', 354520,
            DATEADD(DAY, -1, @history_start), DATEADD(DAY, -1, @history_start),
            DATEADD(DAY, -1, @history_start)
        );
    END;

    /* Reviews, watchlists, and moderation examples */
    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.reviews
         WHERE user_id = @customer_id AND movie_id = @history_movie_id
    )
    BEGIN
        INSERT dbo.reviews
        (
            user_id, movie_id, booking_id, rating, title, content,
            contains_spoiler, status, created_at, updated_at
        )
        VALUES
        (
            @customer_id, @history_movie_id, @history_booking_id, 5,
            N'Warm, patient, and beautifully photographed',
            N'The family performances felt honest, and the final lantern sequence was worth seeing on a big screen.',
            0, 'VISIBLE', DATEADD(DAY, 1, @history_start), DATEADD(DAY, 1, @history_start)
        );
    END;

    DECLARE @orbit_id BIGINT = (SELECT movie_id FROM dbo.movies WHERE slug = 'orbit-zero');
    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.reviews WHERE user_id = @reviewer_id AND movie_id = @orbit_id
    )
    BEGIN
        INSERT dbo.reviews
        (
            user_id, movie_id, rating, title, content, contains_spoiler,
            status, moderated_by, moderated_at, moderation_note
        )
        VALUES
        (
            @reviewer_id, @orbit_id, 2, N'This revealed the ending',
            N'This placeholder review is hidden because it contains a major ending spoiler.',
            1, 'HIDDEN', @admin_id, DATEADD(DAY, -2, @now),
            N'Hidden by the demo administrator for unmarked spoilers.'
        );
    END;

    INSERT dbo.watchlists (user_id, movie_id)
    SELECT @customer_id, m.movie_id
      FROM dbo.movies m
     WHERE m.slug IN ('echoes-of-hoi-an', 'neon-monsoon', 'the-paper-moon')
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.watchlists w
                WHERE w.user_id = @customer_id AND w.movie_id = m.movie_id
           );

    /* Homepage and promotion banners */
    IF NOT EXISTS (SELECT 1 FROM dbo.banners WHERE title = N'Experience Orbit Zero in IMAX')
    BEGIN
        INSERT dbo.banners
        (
            title, subtitle, image_url, target_url, placement,
            display_order, starts_at, ends_at, created_by
        )
        VALUES
        (
            N'Experience Orbit Zero in IMAX',
            N'Immersive sound. Giant screen. One mission home.',
            N'https://placehold.co/1600x600/111827/67E8F9?text=Orbit+Zero+IMAX',
            N'/movies/orbit-zero', 'HOME_HERO', 10,
            DATEADD(DAY, -7, @now), DATEADD(DAY, 45, @now), @admin_id
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.banners WHERE title = N'Welcome Offer: 10% Off')
    BEGIN
        INSERT dbo.banners
        (
            title, subtitle, image_url, target_url, placement,
            display_order, starts_at, ends_at, created_by
        )
        VALUES
        (
            N'Welcome Offer: 10% Off',
            N'Use WELCOME10 on your first CineBook demo order.',
            N'https://placehold.co/1200x400/7C2D12/FDE68A?text=WELCOME10',
            N'/movies', 'HOME_PROMO', 20,
            DATEADD(DAY, -7, @now), DATEADD(DAY, 90, @now), @admin_id
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
