-- CineBook - Lotte Cinema VN real catalog seed
-- Generated from src/main/resources/data JSON files and data/details JSON files.
-- Run after schema.sql and seed.sql. Rerunnable for development databases.
-- Real movie catalog is imported; cinema/showtime/seat inventory remains demo-generated.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.movies', N'U') IS NULL
    THROW 53000, 'CineBook schema is missing. Run schema.sql before real-catalog-seed.sql.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @now DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @local_today DATE = CONVERT(DATE, DATEADD(HOUR, 7, @now));
    DECLARE @next_local_midnight_utc DATETIME2(3) =
        DATEADD(HOUR, -7, CONVERT(DATETIME2(3), DATEADD(DAY, 1, @local_today)));

    DECLARE @real_movies TABLE
    (
        source_ref VARCHAR(80) NOT NULL PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        slug VARCHAR(220) NOT NULL,
        synopsis NVARCHAR(MAX) NOT NULL,
        director NVARCHAR(200) NOT NULL,
        cast_text NVARCHAR(1000) NULL,
        duration_minutes SMALLINT NULL,
        age_rating VARCHAR(20) NOT NULL,
        release_date DATE NOT NULL,
        original_language NVARCHAR(80) NOT NULL,
        country NVARCHAR(100) NOT NULL,
        poster_url NVARCHAR(1000) NULL,
        backdrop_url NVARCHAR(1000) NULL,
        trailer_url NVARCHAR(1000) NULL,
        status VARCHAR(20) NOT NULL
    );

    INSERT @real_movies
        (source_ref, title, slug, synopsis, director, cast_text, duration_minutes,
         age_rating, release_date, original_language, country, poster_url, backdrop_url, trailer_url, status)
    VALUES
        ('LOTTE-12238', N'BẦY XÁC SỐNG', 'bay-xac-song-12238', N'Siêu phẩm zombie từ Đạo diễn đã tạo nên huyền thoại Train to Busan. Khi một dịch bệnh bí ẩn bùng phát tại tòa cao ốc giữa trung tâm Seoul, những người sống sót bị mắc kẹt và buộc phải chiến đấu để thoát thân. Những người đã nhiễm bệnh không chỉ là những xác sống mất não thông thường - chúng đang tiến hóa và săn mồi theo bầy đàn có tổ chức. Hy vọng duy nhất của những người sống sót phụ thuộc vào một gã đàn ông tự nhận đang mang trong mình loại vắc-xin có thể chấm dứt đại dịch. Trong cuộc chạy trốn nghẹt thở lên sân thượng, ranh giới giữa con người và quái vật dần sụp đổ.', N'To be announced', N'To be announced', 117, 'T16', CONVERT(DATE, '2026-06-12', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12238_103_100003.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12238_103_100003.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12243', N'[LIVE] FPT vs KOG - LIÊN QUÂN MOBILE APL 2026 - SWISS STAGE', 'live-fpt-vs-kog-lien-quan-mobile-apl-2026-swiss-stage-12243', N'🔥 CHUỖI PHÁT SÓNG TRỰC TIẾP GIẢI ĐẤU TẠI LOTTE CINEMA CHÍNH THỨC QUAY TRỞ LẠI CÙNG APL 2026!!! 🔥
💥 Sau một mùa giải ĐTDV Mùa Xuân cực kỳ sôi động, Lotte Cinema tiếp tục đồng hành cùng cộng đồng Liên Quân Mobile, hứa hẹn mang đến trải nghiệm xem giải đấu quốc tế đỉnh cao, cực "đã mắt" trên màn ảnh rộng!
⚔️ Vòng Swiss Stage của APL 2026 sẽ được phát sóng trực tiếp tại các cụm rạp Lotte Cinema. Đây chính là cơ hội tuyệt vời để anh em cùng tụ hội, hòa mình vào không khí Esports cuồng nhiệt và "cháy" hết mình để tiếp lửa cho các Đại diện Việt Nam!!!
――――――――――――――――
📺 TRỰC TIẾP LIÊN QUÂN MOBILE: VÒNG SWISS STAGE - APL 2026
🎟️ Giá vé: Chỉ 109.000 VNĐ (Tặng kèm ngay 1 phần nước)
⏰ Lịch chiếu & Trận đấu: Cập nhật chi tiết trên fanpage Lotte Cinema.
📍 Sẵn sàng bùng nổ tại 5 cụm rạp Lotte Cinema:
👉 Hà Nội: Lotte Cinema West Lake, Lotte Cinema Kosmo, Lotte Cinema Hà Đông.
👉 Đà Nẵng: Lotte Cinema Đà Nẵng.
👉 Cần Thơ: Lotte Cinema Cái Răng.', N'To be announced', N'To be announced', 120, 'T16', CONVERT(DATE, '2026-06-25', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12243_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12243_103_100002.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12246', N'ÁM ẢNH', 'am-anh-12246', N'Bear, một chàng trai si tình, đã bẻ gãy món đồ chơi bí ẩn mang tên "Liễu Ước Nguyện" để đổi lấy tình yêu của cô gái mình thầm thương. Điều ước nhanh chóng trở thành hiện thực, nhưng hạnh phúc mà anh hằng mong đợi lại dần biến thành cơn ác mộng. Bear dần nhận ra một sự thật rùng rợn: cái giá phải trả cho món quà kỳ diệu đó kinh hoàng và đen tối hơn bất cứ điều gì anh có thể tưởng tượng.', N'To be announced', N'To be announced', 108, 'T18', CONVERT(DATE, '2026-06-19', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12246_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12246_103_100002.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12183', N'LẦU CHÚ HỎA', 'lau-chu-hoa-12183', N'Lầu Chú Hỏa theo chân một nhóm streamer trẻ đột nhập vào căn biệt thự bỏ hoang gắn với truyền thuyết “con ma nhà họ Hứa”. Sự xâm phạm vào “vùng đất cấm” của họ đã vô tình đánh thức ác linh bị trấn yểm suốt hơn 100 năm. Với phong cách found footage tạo cảm giác như đang xem lại đoạn băng cuối cùng của nạn nhân, bộ phim hứa hẹn biến mỗi góc tối trong căn nhà cổ thành chuỗi bi kịch kinh hoàng và đẫm máu nhất mùa hè năm nay.', N'To be announced', N'To be announced', 94, 'T18', CONVERT(DATE, '2026-06-12', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12183_103_100003.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12183_103_100003.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12230', N'CÂU CHUYỆN ĐỒ CHƠI 5', 'cau-chuyen-o-choi-5-12230', N'Các món đồ chơi đã trở lại trong Toy Story 5 của Disney và Pixar, và lần này sẽ là cuộc đối đầu giữa đồ chơi và công nghệ. Buzz, Woody, Jessie cùng cả nhóm sẽ phải đối mặt với thử thách khó khăn hơn gấp bội khi chạm trán một mối đe dọa hoàn toàn mới đối với niềm vui vui chơi. Bộ phim được đạo diễn bởi Andrew Stanton, đồng đạo diễn bởi Kenna Harris và sản xuất bởi Lindsey Collins. Toy Story 5 sẽ khởi chiếu tại rạp vào ngày 19 tháng 6 năm 2026.', N'To be announced', N'To be announced', 102, 'P', CONVERT(DATE, '2026-06-19', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12230_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12230_103_100002.jpg', N'https://media.lottecinemavn.com/homepage/movie/video-preview/12230/0.7/TOY_STORY_5_3_MB_cde2a5766a.mp4', 'NOW_SHOWING'),
        ('LOTTE-12075', N'MESDAMES THANH SẮC', 'mesdames-thanh-sac-12075', N'Mesdames Thanh Sắc xoay quanh cuộc đời của đại mỹ nhân Cầm Thanh (Thanh Hằng) và Madame Sắc (Hồng Ánh) - bà chủ vũ trường Kim Đô vô cùng giàu có và sở hữu nhiều kim cương. Dù ở dưới trướng của bà Sắc và từng bước trở thành vũ nữ đình đám nhất Sài Gòn những năm 1960, nhưng Cầm Thanh luôn muốn nổi loạn. Từ đó, hai người phụ nữ bắt đầu cuộc giằng co căng thẳng dẫn đến những sự kiện gây rúng động.', N'To be announced', N'To be announced', 125, 'T18', CONVERT(DATE, '2026-06-19', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12075_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12075_103_100002.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12138', N'PHIM ĐIỆN ẢNH DORAEMON: NOBITA VÀ LÂU ĐÀI DƯỚI ĐÁY BIỂN PHIÊN BẢN MỚI', 'phim-ien-anh-doraemon-nobita-va-lau-ai-duoi-ay-bien-phien-ban-moi-12138', N'Bước vào kì nghỉ hè, Nobita và các bạn tranh cãi chí chóe về địa điểm cắm trại. Theo đề xuất của Doraemon, cả nhóm quyết định cắm trại giữa lòng đại dương! Sử dụng bảo bối thần kì “xe Buggy chạy dưới nước” và “đèn pin thích nghi”, 5 bạn nhỏ tận hưởng chuyến cắm trại dưới đáy biển, gặp gỡ vô vàn sinh vật lí thú trên đường đi. Sau khi phát hiện một chiếc tàu đắm, nhóm bạn đã gặp chàng thanh niên bí ẩn El. Thật bất ngờ, anh ta lại là cư dân đáy biển, sống tại “liên bang Mu”, một vùng biển rộng lớn! Vốn căm ghét người mặt đất, cư dân đáy biển không thể nào tin tưởng Nobita và các bạn. Đúng lúc đó, lời thông báo “lâu đài quỷ... đã bắt đầu phục sinh!!” được truyền tới. “Lâu đài quỷ” khiến cư dân đáy biển khiếp sợ, rốt cuộc là gì? Đặt trọn niềm tin vào bè bạn trong lồng ngực, chuyến phiêu lưu vĩ đại quyết định số phận của trái đất, bắt đầu!', N'To be announced', N'To be announced', 100, 'P', CONVERT(DATE, '2026-05-22', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12138_103_100006.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12138_103_100006.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12239', N'MA LU', 'ma-lu-12239', N'Rusmiati, một cô gái quê giản dị, kết hôn với Badri, một người đàn ông đáng kính, mặc cho lời tiên tri rằng mối quan hệ của họ sẽ mang đến tai họa.', N'To be announced', N'To be announced', 98, 'T16', CONVERT(DATE, '2026-06-19', 23), N'Vietnamese', N'Indonesia', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12239_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12239_103_100001.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12237', N'CƠN THỊNH NỘ', 'con-thinh-no-12237', N'Phim xoay quanh Wang Wei (Xie Miao), một người bán hàng bị câm, đang sinh sống ở Hồng Kông cùng con gái Rainy (Yang Enyou). Một ngày nọ, Rainy bị một đường dây buôn bán trẻ em bắt cóc. Wei tìm đến cảnh sát giúp đỡ nhưng bị từ chối vì cảnh sát ở đây đều đã bị tha hóa. Vì vậy, Wei bắt đầu một cuộc trả thù không ngừng nghỉ để giải cứu con gái. Anh liên minh với Navin (Joe Taslim), một nhà báo có vợ mất tích khi đang điều tra cùng một đường dây buôn người.', N'To be announced', N'To be announced', 110, 'T18', CONVERT(DATE, '2026-06-12', 23), N'Vietnamese', N'Hongkong', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12237_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12237_103_100001.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12242', N'BẠCH XÀ: MỘT KIẾP NHÂN GIAN', 'bach-xa-mot-kiep-nhan-gian-12242', N'Bạch Tố Trinh, một xà yêu đã tu luyện hàng nghìn năm, bước vào thế giới loài người với mục đích duy nhất: báo đáp ân tình trong quá khứ. Nàng gặp Hứa Tiên, người phàm mang linh hồn tái sinh của ân nhân năm xưa nhưng không hề hay biết về mối liên kết định mệnh giữa họ. Bị cuốn vào nhau bởi sợi dây vô hình của số phận, tình cảm giữa hai người nhanh chóng nảy nở thành tình yêu sâu sắc. Nhưng hạnh phúc ấy chỉ thoáng qua khi Pháp Hải, một nhà sư tuyệt đối tin vào trật tự tự nhiên phát hiện thân phận thật của nàng. Liệu Bạch Tố Trinh có sẵn sàng đánh đổi ngàn năm tu luyện tinh lực để được sống như một người phàm trần và bảo vệ người mình yêu?', N'To be announced', N'To be announced', 133, 'K', CONVERT(DATE, '2026-06-19', 23), N'Vietnamese', N'China', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12242_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12242_103_100001.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12204', N'TÊN CẬU LÀ GÌ', 'ten-cau-la-gi-12204', N'Người ta có thể quên tên nhau, nhưng không thể quên cảm giác khi trái tim từng lỗi nhịp vì một người chưa từng gặp mặt.

Từ Shinkai Makoto - đạo diễn của Đứa Con Của Thời Tiết và Suzume, siêu phẩm anime huyền thoại YOUR NAME. (TÊN CẬU LÀ GÌ.) quay trở lại màn ảnh rộng nhân cột mốc 10 năm lay động cả thế giới. Không chỉ là một câu chuyện tình yêu cách biệt không gian, mà còn là một bức tranh rực rỡ về định mệnh, nơi những sợi dây Musubi kết nối mỗi chúng ta.', N'To be announced', N'To be announced', 107, 'T13', CONVERT(DATE, '2026-06-05', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12204_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12204_103_100002.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12232', N'PHIM ĐIỆN ẢNH LỚP HỌC ÁM SÁT: GIỜ CỦA CHÚNG TA', 'phim-ien-anh-lop-hoc-am-sat-gio-cua-chung-ta-12232', N'Phim điện ảnh phiên bản hoàn toàn mới của “Lớp Học Ám Sát” nhân dịp kỷ niệm 10 năm ra mắt! Một sinh vật mang vận tốc Mach 20 đe dọa hủy diệt Trái Đất nhưng lại trở thành một thầy giáo? Một lớp học bị coi là "phế thải" bỗng chốc trở thành hy vọng cuối cùng của nhân loại? Những câu chuyện mới toanh chưa từng được kể trên màn ảnh sẽ mang đến cho fan hâm mộ những thước phim bùng nổ cùng ký ức rực rỡ nhất về thầy Koro và tập thể lớp 3-E. Bạn đã sẵn sàng cho buổi tốt nghiệp đặc biệt này chưa?', N'To be announced', N'To be announced', 85, 'T16', CONVERT(DATE, '2026-06-05', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12232_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12232_103_100001.jpg', NULL, 'NOW_SHOWING'),
        ('LOTTE-12256', N'BANG DREAM- ITS MYGO PHẦN 1: MÈO HOANG GIỮA ÁNH NẮNG XUÂN', 'bang-dream-its-mygo-phan-1-meo-hoang-giua-anh-nang-xuan-12256', N'Sau sự tan rã của ban nhạc CRYCHIC, những cảm xúc còn dang dở vẫn đeo bám các thành viên cũ. Khi nữ sinh chuyển trường Anon gặp Tomori - cô gái luôn gặp khó khăn trong việc bày tỏ bản thân - một hành trình mới dần bắt đầu. Từ những con người mang theo tổn thương, hiểu lầm và cảm giác lạc lõng, câu chuyện về ban nhạc MyGO!!!!! từng bước được viết nên.', N'To be announced', N'To be announced', 120, 'P', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12256_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12256_103_100002.jpg', N'https://media.lottecinemavn.com/homepage/movie/video-preview/12256/0.7/BANG_DREAM_MY_GO_1_3_MB_081f5bec99.mp4', 'COMING_SOON'),
        ('LOTTE-12259', N'LIÊU TRAI LAN NHƯỢC TỰ', 'lieu-trai-lan-nhuoc-tu-12259', N'Siêu phẩm thứ 10 với kỹ xảo tuyệt đỉnh từ nhà sản xuất Light Chaser làm sống dậy tuyển tập truyện kỳ ảo Liêu Trai Chí Dị của tác giả Bồ Tùng Linh. Những câu chuyện siêu thực đầy cảm động về chữ “Tình” cách biệt cõi âm dương, mối duyên người và yêu đầy day dứt sẽ được thể hiện sống động qua nét vẽ uyển chuyển và sống động. 3 câu chuyện được làm mới hoàn toàn: Họa Bì, Nhiếp Tiểu Thiến, Cô Nương Họ Lỗ sẽ khiến khán giả ngây ngất trong thế giới huyền ảo của Liêu Trai: Lan Nhược Tự.', N'To be announced', N'To be announced', 112, 'T13', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'China', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12259_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12259_103_100001.jpg', N'https://media.lottecinemavn.com/homepage/movie/video-preview/12259/0.7/Poster_dong_ba11d85155.mp4', 'COMING_SOON'),
        ('LOTTE-12245', N'THỰC THỂ QUỶ QUYỆT', 'thuc-the-quy-quyet-12245', N'Phim điện ảnh Backrooms (2026) (do hãng A24 sản xuất) theo chân Clark (Chiwetel Ejiofor), một chủ cửa hàng nội thất, vô tình phát hiện cánh cửa bí ẩn dưới tầng hầm. Bước qua đó, anh bị cuốn vào một chiều không gian vô tận với những căn phòng màu vàng méo mó, liên tục lặp lại. Khi Clark ngày càng lún sâu và ám ảnh, nhà trị liệu tâm lý của anh là Mary (Renate Reinsve) quyết định bước vào không gian đó để tìm và giải cứu anh', N'To be announced', N'To be announced', 105, 'T16', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12245_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12245_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12252', N'MINH HÔN', 'minh-hon-12252', N'Biệt thự nhà họ Lục, hay còn gọi là Điệp phủ, từ lâu nổi tiếng là một căn nhà ma ám đầy bí ẩn. Sau khi Lý Hàm – một nữ chuyên viên vật lý trị liệu – cùng gã đàn ông tham lam A Vỹ chuyển đến đây, hàng loạt hiện tượng kinh hoàng liên tiếp xảy ra, kéo theo những bí mật đen tối của gia tộc họ Lục dần bị phơi bày.', N'To be announced', N'To be announced', 91, 'T16', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'China', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12252_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12252_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12166', N'SUPERGIRL', 'supergirl-12166', N'“Supergirl” – bom tấn mới nhất từ DC Studios – sẽ chính thức đổ bộ các rạp chiếu toàn cầu vào mùa hè này, với Milly Alcock đảm nhận vai kép Supergirl/Kara Zor-El. Khi một kẻ thù bất ngờ và tàn nhẫn giáng đòn ngay tại nơi cô gọi là nhà, Kara Zor-El – hay còn được biết đến với cái tên Supergirl – buộc phải bắt tay với một đồng minh không ai ngờ tới, bắt đầu chuyến hành trình xuyên dải ngân hà đầy sử thi, nơi vừa là cuộc trả thù, vừa là hành trình đi tìm công lý.', N'To be announced', N'To be announced', 108, 'T13', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12166_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12166_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12255', N'LINH MIÊU BÁO THÙ', 'linh-mieu-bao-thu-12255', N'Sarah đến một ngôi làng bị ám bởi truyền thuyết về Quỷ Mèo Đen. Khi các vụ chết người bí ẩn xảy ra, cô khám phá ra nghi lễ hiến tế cổ xưa và những bí mật đen tối của dân làng. Càng điều tra, Sarah càng nhận ra mối đe dọa thực sự đang ở rất gần, và để sống sót cô phải đối mặt với những sự thật đáng sợ cùng sự phản bội từ những người xung quanh.', N'To be announced', N'To be announced', 87, 'T16', CONVERT(DATE, '2026-06-26', 23), N'Vietnamese', N'Thailand', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12255_103_100002.png', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12255_103_100002.png', NULL, 'COMING_SOON'),
        ('LOTTE-12103', N'MINIONS & QUÁI VẬT', 'minions-quai-vat-12103', N'Minions & Quái Vật là câu chuyện vừa náo loạn, vừa ngớ ngẩn nhưng “hoàn toàn có thật” về cách Minions chinh phục Hollywood, trở thành ngôi sao điện ảnh, rồi mất tất cả, vô tình thả quái vật ra khắp thế giới và sau đó phải cùng nhau hợp sức để cứu lấy hành tinh khỏi chính mớ hỗn loạn mà mình tạo ra.', N'To be announced', N'To be announced', 90, 'P', CONVERT(DATE, '2026-07-01', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12103_103_100003.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12103_103_100003.jpg', N'https://media.lottecinemavn.com/homepage/movie/video-preview/12103/0.7/MINION_Sneak_1_86a442e16b.mp4', 'COMING_SOON'),
        ('LOTTE-12244', N'ĐỒNG DAO MA QUÁI', 'ong-dao-ma-quai-12244', N'Mỗi lần gieo xúc xắc là mỗi lần quỷ xuất hiện. Trong lúc dọn dẹp một ngôi đền bỏ hoang, một nhóm trẻ vô tình tìm thấy bàn cờ cổ bị phong ấn từ lâu. Sau khi gieo viên xúc xắc bí ẩn và đọc lên những câu đồng dao kỳ lạ, chúng nhận ra mình đã bắt đầu một trò chơi chết chóc. Mỗi lượt chơi đều kéo theo sự xuất hiện của những linh hồn đáng sợ, buộc cả nhóm phải tìm cách phá giải lời nguyền trước khi trời sáng.', N'To be announced', N'To be announced', 123, 'T18', CONVERT(DATE, '2026-07-03', 23), N'Vietnamese', N'Indonesia', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12244_103_100001.png', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12244_103_100001.png', NULL, 'COMING_SOON'),
        ('LOTTE-12265', N'ĐỀN LA SÁT', 'en-la-sat-12265', N'Official synopsis coming soon.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-03', 23), N'Vietnamese', N'Korea', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12265_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12265_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12139', N'MOANA (Live Action)', 'moana-live-action-12139', N'Nữ anh hùng biển cả quay trở lại. Moana từ Disney sẽ khơi dậy một làn sóng mới, để sự dũng cảm, lòng vị tha và âm nhạc hòa chung một nhịp chảy.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-10', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202603/12139_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202603/12139_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12263', N'MẸ ƠI VỀ NHÀ', 'me-oi-ve-nha-12263', N'Không còn là những mảnh ghép riêng lẻ, sự xuất hiện của mỗi người đều ẩn chứa một bí mật. Huy Hoàng tìm kiếm gì ở nơi mình chưa từng thuộc về? Và vì sao sự xuất hiện của hai cô gái Việt Nam lại khiến cuộc đời của Huy Hoàng thay đổi toàn bộ.



Liệu sự đồng hành của bộ tứ Lee Yi-Kyung, Hoàng Yến Chibi, Choi Daniel và Minh Hà có thể tháo gỡ được "nút thắt" của định mệnh? Mọi câu trả lời sẽ sớm được giải mã tại rạp.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-10', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12263_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12263_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12264', N'MA NỮ OÁN TÌNH', 'ma-nu-oan-tinh-12264', N'Mang theo những ám ảnh từ quá khứ, Malee - do Engfa thủ vai, trở về khu căn hộ gắn liền với tuổi thơ và tìm thấy tình yêu bên Pran – một nhà thực vật học đam mê nghệ thuật pha trà. Thế nhưng, sự xuất hiện của những mối quan hệ xung quanh Pran cùng những bí mật tưởng đã bị chôn vùi từ lâu dần làm xáo trộn mọi thứ. Khi một cái chết bất ngờ xảy ra, những sự thật đen tối dần dần được phơi bày.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-10', 23), N'Vietnamese', N'Thailand', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12264_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12264_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12206', N'QUỶ BẮT HỒN', 'quy-bat-hon-12206', N'Lớp kem trắng bị nhuộm đỏ. Những bông hoa úa, như thứ gì đó đã chết từ trước. Đôi bàn tay đen đặc, giữ chặt chiếc bánh như một nghi lễ… hơn là một buổi tiệc. Một sinh nhật, hay một ngày được định sẵn để bị lấy đi? Và phía sau, thứ đó đã từng là con người. Hay vốn đó chưa từng là người? Đúng tháng đúng ngày, hồn về theo quỷ.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-10', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12206_103_100003.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12206_103_100003.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12209', N'EVIL DEAD BURN - MA CÂY: LỬA ĐỊA NGỤC', 'evil-dead-burn-ma-cay-lua-ia-nguc-12209', N'Quỷ dữ luôn rình rập trong mỗi gia đình. Chúng nó rất thích chứng kiến cảnh hỗn loạn, tàn khốc của từng người luôn nói yêu thương nhau. Cơn nổi loạn độc ác nhất của địa ngục sắp đến. Ra rạp tháng 7 này với thương hiệu kinh dị Ma Cây được đón đợi nhiều nhất!', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-10', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12209_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12209_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-11918', N'THE ODYSSEY', 'the-odyssey-11918', N'The Odyssey lấy cảm hứng từ trường ca của Homer, ghi hình hoàn toàn bằng máy quay phim Imax, có kinh phí ước tính 250 triệu USD. Tác phẩm lấy cảm hứng từ thần thoại Hy Lạp, trong đó Matt Damon vào vai Odysseus, người anh hùng mất 10 năm trở về quê nhà sau cuộc chiến thành Troy. Nhân vật chạm trán với các vị thần, quái vật, trải qua nhiều thử thách để đoàn tụ vợ và giành lại vương quốc.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-17', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202601/11918_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202601/11918_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12253', N'PHIM ĐIỆN ẢNH THÁM TỬ LỪNG DANH CONAN: THIÊN THẦN SA NGÃ TRÊN XA LỘ', 'phim-ien-anh-tham-tu-lung-danh-conan-thien-than-sa-nga-tren-xa-lo-12253', N'Thám tử nhí Conan, gia đình Ran, Sonoko, đội thám tử nhí cùng Sera Masumi đến khu vực Minatomirai, Yokohama để tham dự “Lễ hội Moto Kanagawa”. Thế nhưng, sự kiện náo nhiệt này nhanh chóng bị khuấy động khi một tay lái bí ẩn mang biệt danh “Quái Xế Đen” bất ngờ xuất hiện. Hắn phóng xe với tốc độ kinh hoàng, lao vọt lên nóc chiếc xe chở nhóm Conan rồi biến mất trong chớp mắt, khiến ngay cả nữ cảnh sát giao thông nổi tiếng với danh xưng “Nữ Thần Gió” của Sở Cảnh sát Kanagawa - Hagiwara Chihaya - cũng không thể truy đuổi kịp.



Trong khi cuộc săn lùng vẫn rơi vào bế tắc, tại hội trường lễ hội lại diễn ra màn ra mắt mẫu moto công nghệ cao màu trắng mang tên “Angel”. Điều đáng ngờ là chiếc xe của “Quái Xế Đen” lại sở hữu thiết kế gần như giống hệt mẫu xe này. Bỗng dưng, nữ cảnh sát Chihaya chợt nhớ về những ký ức tưởng chừng đã ngủ yên về người em trai quá cố Hagiwara Kenji và người bạn thân cùng khóa của anh, Matsuda Jinpei. Danh tính thực sự của kẻ cầm lái và mục đích đằng sau những cuộc rượt đuổi đầy nguy hiểm ấy kéo Conan và nữ cảnh sát Chihaya vào một cuộc đấu trí, khơi dậy một vụ án của nhiều năm trước.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-24', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12253_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12253_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12181', N'NGƯỜI NHỆN: KHỞI ĐẦU MỚI', 'nguoi-nhen-khoi-au-moi-12181', N'Sống cô độc và chống tội phạm ở một thành phố New York mà người ta không còn nhớ đến tên anh, Peter Parker đã cống hiến hết mình cho vai trò Người Nhện toàn thời gian. Nhưng khi áp lực đè nặng lên Người Nhện ngày càng lớn, Peter trải qua một sự biến đổi thể chất đáng ngạc nhiên, đe dọa đến sự tồn tại của anh.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-07-31', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12181_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12181_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12198', N'SỢI CHỈ ĐỎ', 'soi-chi-o-12198', N'Một kẻ cuồng tín sau cơn đau đầu dữ dội phát hiện ra mình có một con mắt dọc trên trán. Những vụ sát nhân hàng loạt. Những hồn ma bóng quỷ lẩn khuất trong đời sống. Những nỗi sợ rình rập từ ám ảnh quá khứ. Sợi Chỉ Đỏ là gì, và sẽ kết nối tất cả như thế nào?', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-14', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12198_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12198_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12207', N'PAW PATROL: PHIM KHỦNG LONG', 'paw-patrol-phim-khung-long-12207', N'Khi con tàu của PAW Patrol bị cuốn vào một cơn bão bí ẩn, đội cún cứu hộ vô tình lưu lạc đến một hòn đảo nhiệt đới vô danh, nơi sinh sống của nhiều loài khủng long cổ xưa. Họ gặp Rex, một chuyên gia về khủng long, đã mắc kẹt trên hòn đảo này trong nhiều năm. Mọi chuyện trở nên tệ hơn khi Thị trưởng Humdinger, đối thủ không đội trời chung của PAW Patrol rắp tâm khai thác nguồn tài nguyên thiên nhiên tại đây, và vô tình gây ra trận phun trào của một ngọn núi lửa khổng lồ. Đứng trước nguy cơ hòn đảo bị xóa sổ, đội cún cứu hộ phải thực hiện những nhiệm vụ quy mô ""khủng"" hơn bao giờ hết để ngăn chặn Humdinger và cứu các loài khủng long khỏi nạn tuyệt chủng.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-14', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12207_103_100002.png', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12207_103_100002.png', NULL, 'COMING_SOON'),
        ('LOTTE-12258', N'PHIM SHIN – CẬU BÉ BÚT CHÌ: KỲ KỲ QUÁI QUÁI! KỲ NGHỈ YÊU QUÁI CỦA TỚ', 'phim-shin-cau-be-but-chi-ky-ky-quai-quai-ky-nghi-yeu-quai-cua-to-12258', N'Lấy bối cảnh mùa hè tại Akita, bộ phim theo chân Shin và gia đình Nohara trong chuyến về quê đầy háo hức. Tuy nhiên, một sự kiện kỳ lạ đã đưa cả gia đình lạc vào Xứ sở Yêu quái bí ẩn – nơi con người không được phép đặt chân tới.

Tại đây, Shin và gia đình phải đối mặt với những thử thách chưa từng có, đồng thời gặp gỡ hàng loạt yêu quái độc đáo, hài hước và đáng yêu. Với sự kết hợp giữa yếu tố phiêu lưu, kỳ ảo, hài hước đặc trưng của Shin-chan cùng những thông điệp gia đình ấm áp, bộ phim hứa hẹn mang đến một hành trình giải trí hấp dẫn cho khán giả ở mọi lứa tuổi trong mùa hè này.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-21', 23), N'Vietnamese', N'Japan', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12258_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12258_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12203', N'NGHỈ HÈ SỢ NGHỈ HƯU', 'nghi-he-so-nghi-huu-12203', N'Phim Nghỉ Hè Sợ Nghỉ Hưu xoay quanh người cháu trai thuộc thế hệ Z và người ông là cựu chiến binh, từng tham gia chiến đấu bảo vệ Tổ quốc. Huỳnh Lập tạo nên sự đối lập giữa hai ông cháu khi xây dựng một bên là vẻ hiện đại, thời thượng đặc trưng của người trẻ và một bên là nét truyền thống, nghiêm nghị của người đi trước. Bộ phim hứa hẹn mở ra cuộc đối thoại sâu sắc giữa hai thế hệ, cũng như các tình tiết hài hước và tâm linh đặc trưng của Huỳnh Lập.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-21', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12203_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12203_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12182', N'QUỶ QUYỆT: RANH GIỚI VÔ ĐỊNH', 'quy-quyet-ranh-gioi-vo-inh-12182', N'Official synopsis coming soon.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-21', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12182_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12182_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12197', N'CHÒM SAO BẤT DIỆT', 'chom-sao-bat-diet-12197', N'Tận thế chưa phải là kết thúc. Những người sống sót sau một đại dịch chết chóc đang cố níu kéo những thứ xưa cũ của thế giới.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-28', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12197_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12197_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12187', N'HỘ LINH TRÁNG SĨ: BÍ ẨN MỘ VUA ĐINH', 'ho-linh-trang-si-bi-an-mo-vua-inh-12187', N'Phim huyền sử Hộ linh tráng sĩ: Bí ẩn mộ vua Đinh mở đầu bằng trận chiến 12 sứ quân oanh liệt của Đinh Tiên Hoàng đế và về hành trình của 7 hộ linh tráng sĩ trong nhiệm vụ cuối cùng Tiên Đế giao. Họ phải chạy đua với thời gian, đối đầu với các thế lực thù địch, đưa 99 quan tài của vua đi theo 7 hướng khác nhau, đánh lừa kẻ thù âm mưu phá hoại lăng mộ - nơi được tin là cội nguồn vượng khí của dân tộc.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-31', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12187_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12187_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12161', N'NGÀY TÀN CỦA PHỐ OAK', 'ngay-tan-cua-pho-oak-12161', N'Ngày tàn của phố Oak lấy bối cảnh sau khi một thảm họa thiên nhiên xé toạc phố Oak khỏi khu ngoại ô và đưa cả con phố đến một nơi xa lạ. Gia đình Platt nhanh chóng nhận ra rằng chỉ bằng cách luôn đứng bên nhau, họ mới có thể vượt qua vận mệnh nghiệt ngã này.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-08-31', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12161_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12161_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12266', N'BÍ KÍP LUYỆN CƯỚP', 'bi-kip-luyen-cuop-12266', N'Một nhóm cướp ngân hàng am hiểu mạng xã hội phát sóng những vụ cướp táo bạo của chúng, mà không hề hay biết rằng sự nổi tiếng lan truyền nhanh chóng đã đưa chúng vào tầm ngắm của một đặc vụ FBI kỳ cựu và một kỹ sư phần mềm tài ba. Mặc dù bộ đôi bất đắc dĩ này đang tiến gần, băng nhóm tội phạm vẫn vượt qua giới hạn của mình, đặt mọi thứ vào rủi ro vì niềm tin của chúng - và vụ cướp tham vọng nhất từ ​​trước đến nay.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-09-04', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12266_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12266_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12251', N'QUÝ TỬ VƯỢT GIÀU', 'quy-tu-vuot-giau-12251', N'Quý Tử Vượt Giàu xoay quanh cặp vợ chồng Diệp - Phát và hành trình “dở khóc dở cười” khi cả hai cùng nuôi dạy cậu con trai tên Phú Quý. Với những tình tiết vui vẻ nhằm đẩy mạnh tính giải trí, bộ phim từ từ mở ra góc nhìn đa chiều về tình thân, sự trưởng thành và khát khao được lắng nghe của cả cha mẹ lẫn con cái.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-09-11', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12251_103_100002.png', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12251_103_100002.png', NULL, 'COMING_SOON'),
        ('LOTTE-12185', N'HÒN ĐẢO QUÊN LÃNG', 'hon-ao-quen-lang-12185', N'Official synopsis coming soon.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-09-25', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12185_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12185_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12082', N'DIGGER', 'digger-12082', N'DIGGER. Trò cười rung chuyển cả thế giới.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-10-02', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202601/12082_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202601/12082_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12202', N'PHIM STREET FIGHTER', 'phim-street-fighter-12202', N'Lấy bối cảnh năm 1993, Ryu và Ken, hai đấu sĩ từng xa cách bị kéo trở lại chiến đấu khi Chun-Li chiêu mộ họ tham gia giải Chiến Binh Thế Giới đầy khốc liệt. Nhưng đằng sau đó là một âm mưu chết chóc, buộc họ phải đối đầu với nhau và quá khứ của chính mình, nếu không tất cả sẽ CHẤM HẾT!', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-10-16', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12202_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12202_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12224', N'TRẤN YỂM', 'tran-yem-12224', N'Sau cái chết bí ẩn của cha trong ngôi nhà mới xây, Ân quyết định ghi lại những hiện tượng tâm linh kỳ quái liên tục xảy ra quanh mình. Nhưng càng đào sâu sự thật, anh vô tình phát hiện một nghi lễ cấm kỵ ghê rợn đang ẩn náu bên trong ngôi nhà - thứ đã liên kết nơi đây với hàng loạt hiện tượng siêu nhiên bí ẩn mà người đời gọi là Bùa Lỗ Ban.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-10-30', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12224_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12224_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12250', N'CÁ VOI NUỐT CHỬNG', 'ca-voi-nuot-chung-12250', N'Câu chuyện kể về một thợ lặn, trong khi tìm kiếm hài cốt cha mình, đã bị một con cá voi nhà táng khổng lồ dài 24 mét, nặng 27 tấn nuốt chửng và chỉ có một giờ để thoát ra trước khi hết oxy.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-10-31', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12250_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12250_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12200', N'CLAYFACE', 'clayface-12200', N'Bộ phim kinh dị đầu tiên của DC Studios, “Clayface” do đạo diễn James Watkins thực hiện, với sự tham gia của Tom Rhys Harries trong vai chính, một nhân vật phản diện của thành phố Gotham. “Clayface” hé lộ sự sa ngã kinh hoàng của một người đàn ông từ ngôi sao Hollywood đang lên trở thành một con quái vật đầy thù hận, trong một câu chuyện khám phá sự mất mát bản sắc và nhân tính, tình yêu độc hại, và mặt tối của tham vọng khoa học.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-10-31', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12200_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12200_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12216', N'BÒ SỮA BAY', 'bo-sua-bay-12216', N'Lấy bối cảnh thập niên 70–80, phim xoay quanh một trang trại đang nghiên cứu công thức sữa “bí mật” có khả năng chữa lành và trẻ hóa.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-11-06', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12216_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12216_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-11915', N'CHÀNG MÈO MANG MŨ', 'chang-meo-mang-mu-11915', N'Trong phim,Chàng Mèo Mang Mũ của chúng ta nhận nhiệm vụ khó khăn nhất từ trước đến nay từ tổ chức I.I.I.I. (Viện Sáng Tạo và Cảm Hứng, LLC): cổ vũ tinh thần cho Gabby và Sebastian, hai anh em đang vật lộn với việc thích nghi sau khi chuyển đến một thị trấn mới. Với "thành tích" thường xuyên làm quá mọi chuyện, lần này có thể sẽ là cơ hội cuối cùng để anh chàng chuyên gây rối này chứng minh bản thân nếu không muốn mất đi chiếc mũ thần kỳ!', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-11-30', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/11915_103_100002.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/11915_103_100002.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12184', N'DUNE: HÀNH TINH CÁT - PHẦN BA', 'dune-hanh-tinh-cat-phan-ba-12184', N'Được chỉ đạo bởi đạo diễn Denis Villeneuve với kịch bản do Villeneuve và Brian K. Vaughan chấp bút, Dune: Hành Tinh Cát - Phần Ba dựa trên cuốn tiểu thuyết Cứu Tinh Xứ Cát của tác giả Frank Herbert, mang đến màn ảnh chương cuối vĩ đại trong bộ ba phim Dune: Hành Tinh Cát của Villeneuve.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-12-18', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12184_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202604/12184_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12247', N'NGƯỜI MẸ XẤU', 'nguoi-me-xau-12247', N'Một cuộc chạy trốn trong mưa. Một người mẹ không hoàn hảo. Một người con không thể quay đầu. Sau thành công của Thiên Đường Máu, đạo diễn Hoàng Tuấn Cường chính thức trở lại với NGƯỜI MẸ XẤU, bộ phim hành động - tình cảm mang đậm màu sắc Việt Nam.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2026-12-31', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12247_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12247_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12223', N'LOẠN THẾ', 'loan-the-12223', N'Một thời đại nghĩa hiệp sắp mở ra.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2027-02-06', 23), N'Vietnamese', N'Vietnam', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12223_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202605/12223_103_100001.jpg', NULL, 'COMING_SOON'),
        ('LOTTE-12248', N'GATTO', 'gatto-12248', N'Vì mang ơn một ông trùm mafia mèo, chú mèo đen Nero buộc phải tạo dựng một tình bạn bất ngờ, điều có thể dẫn cậu đến mục đích sống của mình.', N'To be announced', N'To be announced', NULL, 'P', CONVERT(DATE, '2027-03-31', 23), N'Vietnamese', N'USA', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12248_103_100001.jpg', N'https://media.lottecinemavn.com/Media/MovieFile/MovieImg/202606/12248_103_100001.jpg', NULL, 'COMING_SOON');

    INSERT dbo.genres (name, slug)
    SELECT source.name, source.slug
      FROM
      (
          VALUES
          (N'Action', 'action'),
          (N'Adventure', 'adventure'),
          (N'Animation', 'animation'),
          (N'Comedy', 'comedy'),
          (N'Criminal', 'criminal'),
          (N'Drama', 'drama'),
          (N'Hành động', 'hanh-ong'),
          (N'Historical Drama', 'historical-drama'),
          (N'Horror', 'horror'),
          (N'Kinh dị', 'kinh-di'),
          (N'Phát sóng trực tiếp', 'phat-song-truc-tiep'),
          (N'Science Fiction', 'science-fiction'),
          (N'Thriller', 'thriller'),
          (N'Tình cảm', 'tinh-cam')
      ) source(name, slug)
     WHERE NOT EXISTS (SELECT 1 FROM dbo.genres g WHERE g.slug = source.slug);

    MERGE dbo.movies AS target
    USING @real_movies AS source
       ON target.source_ref = source.source_ref
    WHEN MATCHED THEN
        UPDATE SET
            title = source.title, slug = source.slug, synopsis = source.synopsis,
            director = source.director, cast_text = source.cast_text,
            duration_minutes = source.duration_minutes, age_rating = source.age_rating,
            release_date = source.release_date, original_language = source.original_language,
            country = source.country, poster_url = source.poster_url,
            backdrop_url = source.backdrop_url, trailer_url = source.trailer_url,
            status = source.status, is_active = 1, updated_at = @now
    WHEN NOT MATCHED THEN
        INSERT
            (source_ref, title, slug, synopsis, director, cast_text, duration_minutes,
             age_rating, release_date, original_language, country, poster_url,
             backdrop_url, trailer_url, status, is_active)
        VALUES
            (source.source_ref, source.title, source.slug, source.synopsis, source.director,
             source.cast_text, source.duration_minutes, source.age_rating, source.release_date,
             source.original_language, source.country, source.poster_url, source.backdrop_url,
             source.trailer_url, source.status, 1);

    UPDATE dbo.movies
       SET is_active = 0, updated_at = @now
     WHERE source_ref IS NULL
       AND slug IN ('saigon-after-rain', 'orbit-zero', 'laughing-in-district-one',
                    'river-of-dragons', 'echoes-of-hoi-an', 'neon-monsoon',
                    'the-paper-moon', 'the-last-lantern');

    DELETE mg
      FROM dbo.movie_genres mg
      JOIN dbo.movies m ON m.movie_id = mg.movie_id
     WHERE m.source_ref LIKE 'LOTTE-%';

    INSERT dbo.movie_genres (movie_id, genre_id)
    SELECT m.movie_id, g.genre_id
      FROM
      (
          VALUES
          ('LOTTE-12238', 'action'),
          ('LOTTE-12238', 'adventure'),
          ('LOTTE-12238', 'science-fiction'),
          ('LOTTE-12243', 'phat-song-truc-tiep'),
          ('LOTTE-12246', 'thriller'),
          ('LOTTE-12246', 'criminal'),
          ('LOTTE-12246', 'horror'),
          ('LOTTE-12183', 'kinh-di'),
          ('LOTTE-12230', 'animation'),
          ('LOTTE-12075', 'drama'),
          ('LOTTE-12138', 'animation'),
          ('LOTTE-12239', 'kinh-di'),
          ('LOTTE-12237', 'hanh-ong'),
          ('LOTTE-12242', 'animation'),
          ('LOTTE-12204', 'animation'),
          ('LOTTE-12232', 'animation'),
          ('LOTTE-12256', 'animation'),
          ('LOTTE-12259', 'animation'),
          ('LOTTE-12245', 'thriller'),
          ('LOTTE-12245', 'criminal'),
          ('LOTTE-12245', 'horror'),
          ('LOTTE-12252', 'kinh-di'),
          ('LOTTE-12166', 'hanh-ong'),
          ('LOTTE-12255', 'kinh-di'),
          ('LOTTE-12103', 'animation'),
          ('LOTTE-12244', 'kinh-di'),
          ('LOTTE-12265', 'kinh-di'),
          ('LOTTE-12139', 'action'),
          ('LOTTE-12139', 'adventure'),
          ('LOTTE-12139', 'science-fiction'),
          ('LOTTE-12263', 'tinh-cam'),
          ('LOTTE-12264', 'kinh-di'),
          ('LOTTE-12206', 'kinh-di'),
          ('LOTTE-12209', 'kinh-di'),
          ('LOTTE-11918', 'action'),
          ('LOTTE-11918', 'adventure'),
          ('LOTTE-11918', 'science-fiction'),
          ('LOTTE-12253', 'animation'),
          ('LOTTE-12181', 'hanh-ong'),
          ('LOTTE-12198', 'kinh-di'),
          ('LOTTE-12207', 'animation'),
          ('LOTTE-12258', 'animation'),
          ('LOTTE-12203', 'comedy'),
          ('LOTTE-12182', 'kinh-di'),
          ('LOTTE-12197', 'hanh-ong'),
          ('LOTTE-12187', 'hanh-ong'),
          ('LOTTE-12161', 'hanh-ong'),
          ('LOTTE-12266', 'hanh-ong'),
          ('LOTTE-12251', 'comedy'),
          ('LOTTE-12185', 'action'),
          ('LOTTE-12185', 'adventure'),
          ('LOTTE-12185', 'science-fiction'),
          ('LOTTE-12082', 'drama'),
          ('LOTTE-12202', 'hanh-ong'),
          ('LOTTE-12224', 'kinh-di'),
          ('LOTTE-12250', 'hanh-ong'),
          ('LOTTE-12200', 'kinh-di'),
          ('LOTTE-12216', 'drama'),
          ('LOTTE-11915', 'animation'),
          ('LOTTE-12184', 'hanh-ong'),
          ('LOTTE-12247', 'drama'),
          ('LOTTE-12223', 'historical-drama'),
          ('LOTTE-12248', 'animation')
      ) source(source_ref, genre_slug)
      JOIN dbo.movies m ON m.source_ref = source.source_ref
      JOIN dbo.genres g ON g.slug = source.genre_slug
     WHERE NOT EXISTS
           (
               SELECT 1 FROM dbo.movie_genres existing
                WHERE existing.movie_id = m.movie_id AND existing.genre_id = g.genre_id
           );

    DELETE mf
      FROM dbo.movie_formats mf
      JOIN dbo.movies m ON m.movie_id = mf.movie_id
     WHERE m.source_ref LIKE 'LOTTE-%';

    INSERT dbo.movie_formats (movie_id, format)
    SELECT m.movie_id, source.format
      FROM @real_movies source_movies
      JOIN dbo.movies m ON m.source_ref = source_movies.source_ref
      CROSS JOIN (VALUES ('2D')) source(format)
     WHERE NOT EXISTS
           (
               SELECT 1 FROM dbo.movie_formats existing
                WHERE existing.movie_id = m.movie_id AND existing.format = source.format
           );

    DECLARE @showtime_seed TABLE
    (
        source_ref VARCHAR(80) NOT NULL PRIMARY KEY,
        movie_source_ref VARCHAR(80) NOT NULL,
        cinema_slug VARCHAR(220) NOT NULL,
        auditorium_name NVARCHAR(100) NOT NULL,
        day_offset INT NOT NULL,
        local_hour INT NOT NULL,
        local_minute INT NOT NULL,
        format VARCHAR(10) NOT NULL,
        base_price DECIMAL(19,2) NOT NULL,
        audio_language NVARCHAR(80) NOT NULL,
        subtitle_language NVARCHAR(80) NULL
    );

    INSERT @showtime_seed
        (source_ref, movie_source_ref, cinema_slug, auditorium_name, day_offset, local_hour, local_minute, format, base_price, audio_language, subtitle_language)
    VALUES
        ('LOTTE-DEMO-12238', 'LOTTE-12238', 'cinebook-landmark-81', N'Hall 1', 2, 10, 0, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12243', 'LOTTE-12243', 'cinebook-landmark-81', N'IMAX 1', 2, 13, 30, 'IMAX', CONVERT(DECIMAL(19,2), 190000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12246', 'LOTTE-12246', 'cinebook-metropolis-hanoi', N'Hall 1', 2, 17, 0, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12183', 'LOTTE-12183', 'cinebook-metropolis-hanoi', N'Premium 2', 2, 20, 15, '2D', CONVERT(DECIMAL(19,2), 140000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12230', 'LOTTE-12230', 'cinebook-han-river', N'Hall 1', 3, 10, 30, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12075', 'LOTTE-12075', 'cinebook-ninh-kieu', N'Hall 1', 3, 14, 0, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12138', 'LOTTE-12138', 'cinebook-landmark-81', N'Hall 1', 3, 18, 30, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12239', 'LOTTE-12239', 'cinebook-landmark-81', N'IMAX 1', 3, 21, 0, 'IMAX', CONVERT(DECIMAL(19,2), 190000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12237', 'LOTTE-12237', 'cinebook-metropolis-hanoi', N'Hall 1', 4, 11, 0, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12242', 'LOTTE-12242', 'cinebook-metropolis-hanoi', N'Premium 2', 4, 15, 15, '2D', CONVERT(DECIMAL(19,2), 140000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12204', 'LOTTE-12204', 'cinebook-han-river', N'Hall 1', 4, 19, 0, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English'),
        ('LOTTE-DEMO-12232', 'LOTTE-12232', 'cinebook-ninh-kieu', N'Hall 1', 4, 21, 30, '2D', CONVERT(DECIMAL(19,2), 120000), N'Vietnamese', N'English');

    INSERT dbo.showtimes
    (
        movie_id, auditorium_id, starts_at, ends_at, sales_open_at,
        format, base_price, audio_language, subtitle_language, status, source_ref
    )
    SELECT m.movie_id,
           a.auditorium_id,
           DATEADD(MINUTE, source.local_minute,
               DATEADD(HOUR, source.local_hour,
                   DATEADD(DAY, source.day_offset, @next_local_midnight_utc))),
           DATEADD(MINUTE, COALESCE(m.duration_minutes, 100),
               DATEADD(MINUTE, source.local_minute,
                   DATEADD(HOUR, source.local_hour,
                       DATEADD(DAY, source.day_offset, @next_local_midnight_utc)))),
           DATEADD(DAY, -30,
               DATEADD(MINUTE, source.local_minute,
                   DATEADD(HOUR, source.local_hour,
                       DATEADD(DAY, source.day_offset, @next_local_midnight_utc)))),
           source.format, source.base_price, source.audio_language, source.subtitle_language,
           'SCHEDULED', source.source_ref
      FROM @showtime_seed source
      JOIN dbo.movies m ON m.source_ref = source.movie_source_ref
      JOIN dbo.cinemas c ON c.slug = source.cinema_slug
      JOIN dbo.auditoriums a ON a.cinema_id = c.cinema_id AND a.name = source.auditorium_name
     WHERE NOT EXISTS (SELECT 1 FROM dbo.showtimes st WHERE st.source_ref = source.source_ref)
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.showtimes conflict
                WHERE conflict.auditorium_id = a.auditorium_id
                  AND conflict.starts_at = DATEADD(MINUTE, source.local_minute,
                      DATEADD(HOUR, source.local_hour,
                          DATEADD(DAY, source.day_offset, @next_local_midnight_utc)))
           );

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
     WHERE st.source_ref LIKE 'LOTTE-DEMO-%'
       AND NOT EXISTS
           (
               SELECT 1 FROM dbo.seat_prices p
                WHERE p.showtime_id = st.showtime_id AND p.seat_type = source.seat_type
           );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
