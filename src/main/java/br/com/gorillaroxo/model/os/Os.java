package br.com.gorillaroxo.model.os;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.ToString;

import java.util.Map;
import java.util.Objects;
import java.util.Optional;

@Getter
@ToString
public class Os {

    private final String id;
    private final String prettyName;
    private final OsFamily family;

    @Getter(AccessLevel.NONE)
    private final String codename;

    private Os(final String id, final String prettyName, final OsFamily family, final String codename) {
        this.id = Objects.requireNonNull(id, "Os id cannot be null");
        this.prettyName = Objects.requireNonNull(prettyName, "Os pretty name cannot be null");
        this.family = Objects.requireNonNull(family, "Os family cannot be null");
        this.codename = codename;

        if (id.isBlank()) {
            throw new IllegalArgumentException("Os id cannot be blank");
        }
        if (prettyName.isBlank()) {
            throw new IllegalArgumentException("Os pretty name cannot be blank");
        }
    }


    public static Os archLinux(final String id, final String prettyName) {
        return new Os(id, prettyName, OsFamily.ARCH, null);
    }

    public static Os debian(final String id, final String prettyName, final String codename) {
        return new Os(id, prettyName, OsFamily.DEBIAN, codename);
    }

    public static Os fromOsRelease(final Map<String, String> osRelease) {
        final String id = osRelease.get("ID");
        final String prettyName = osRelease.getOrDefault("PRETTY_NAME", id);
        final String idLike = osRelease.getOrDefault("ID_LIKE", "");

        if (matchesFamily(id, idLike, "arch")) {
            return archLinux(id, prettyName);
        }
        if (matchesFamily(id, idLike, "debian")) {
            final String codename = osRelease.getOrDefault("UBUNTU_CODENAME", osRelease.get("VERSION_CODENAME"));
            return debian(id, prettyName, codename);
        }

        throw new IllegalArgumentException("Unsupported distro, ID=" + id + " ID_LIKE=" + idLike);
    }

    private static boolean matchesFamily(final String id, final String idLike, final String family) {
        return family.equals(id) || idLike.toLowerCase().contains(family);
    }

    public Optional<String> getCodename() {
        return Optional.ofNullable(codename);
    }

}
