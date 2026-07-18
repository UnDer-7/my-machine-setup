package br.com.gorillaroxo.model.os;

import java.util.LinkedHashMap;
import java.util.Map;

public final class OsReleaseParser {

    private OsReleaseParser() {
    }

    public static Map<String, String> parse(final String content) {
        final Map<String, String> fields = new LinkedHashMap<>();

        for (final String line : content.split("\n")) {
            final String trimmed = line.trim();
            if (trimmed.isEmpty() || trimmed.startsWith("#")) {
                continue;
            }

            final int separatorIndex = trimmed.indexOf('=');
            if (separatorIndex < 0) {
                continue;
            }

            final String key = trimmed.substring(0, separatorIndex).trim();
            final String value = unquote(trimmed.substring(separatorIndex + 1).trim());
            fields.put(key, value);
        }

        return fields;
    }

    private static String unquote(final String value) {
        if (value.length() >= 2 && value.startsWith("\"") && value.endsWith("\"")) {
            return value.substring(1, value.length() - 1);
        }
        return value;
    }
}
