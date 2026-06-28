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
