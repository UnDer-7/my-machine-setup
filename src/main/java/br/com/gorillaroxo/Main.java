package br.com.gorillaroxo;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class Main {

    static void main() throws IOException {
        System.out.println(new String(Files.readAllBytes(Path.of("/etc/os-release"))));
    }


}
