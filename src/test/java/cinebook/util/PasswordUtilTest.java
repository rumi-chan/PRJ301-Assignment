package cinebook.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordUtilTest {
    @Test
    void hashesWithSaltAndVerifies() {
        String first = PasswordUtil.hash("cinema123");
        String second = PasswordUtil.hash("cinema123");

        assertNotEquals(first, second);
        assertTrue(PasswordUtil.matches("cinema123", first));
        assertFalse(PasswordUtil.matches("different", first));
    }
}
