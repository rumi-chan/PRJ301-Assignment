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
