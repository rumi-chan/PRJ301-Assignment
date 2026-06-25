package vn.edu.cinebook.util;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class DisplayUtil {
    public static final ZoneId DISPLAY_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter DATE_TIME =
            DateTimeFormatter.ofPattern("EEE, dd MMM yyyy · HH:mm", Locale.ENGLISH).withZone(DISPLAY_ZONE);

    private DisplayUtil() {
    }

    public static String money(BigDecimal amount) {
        NumberFormat format = NumberFormat.getIntegerInstance(Locale.US);
        return format.format(amount == null ? BigDecimal.ZERO : amount) + " VND";
    }

    public static String dateTime(Instant instant) {
        return instant == null ? "" : DATE_TIME.format(instant);
    }
}
