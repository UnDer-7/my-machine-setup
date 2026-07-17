package br.com.gorillaroxo;

import br.com.gorillaroxo.model.os.Os;
import br.com.gorillaroxo.model.os.OsReleaseParser;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

public class Main {

    static void main(final String[] args) {
        final var b = new Bootstrap();
        System.out.println(b.os);
    }

    public static class Bootstrap {

        private final Os os;

        public Bootstrap() {
            this.os = initOs();
        }

        private static Os initOs() {
            try {
                final String content = Files.readString(Path.of("/etc/os-release"));
                final Map<String, String> osRelease = OsReleaseParser.parse(content);
                return Os.fromOsRelease(osRelease);
            } catch (final IOException e) {
                // todo logar:
                throw new RuntimeException(e);
            }
        }
    }
}
