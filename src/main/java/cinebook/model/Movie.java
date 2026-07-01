package cinebook.model;

import java.time.LocalDate;
import java.util.List;

public class Movie {
    private final long id;
    private final String title;
    private final String slug;
    private final String synopsis;
    private final String director;
    private final String cast;
    private final Integer durationMinutes;
    private final String ageRating;
    private final LocalDate releaseDate;
    private final String posterUrl;
    private final String backdropUrl;
    private final String trailerUrl;
    private final MovieStatus status;
    private final List<String> genres;
    private final List<MovieFormat> formats;

    public Movie(long id, String title, String slug, String synopsis, String director, String cast,
                 Integer durationMinutes, String ageRating, LocalDate releaseDate, String posterUrl,
                 String backdropUrl, String trailerUrl, MovieStatus status,
                 List<String> genres, List<MovieFormat> formats) {
        this.id = id;
        this.title = title;
        this.slug = slug;
        this.synopsis = synopsis;
        this.director = director;
        this.cast = cast;
        this.durationMinutes = durationMinutes;
        this.ageRating = ageRating;
        this.releaseDate = releaseDate;
        this.posterUrl = posterUrl;
        this.backdropUrl = backdropUrl;
        this.trailerUrl = trailerUrl;
        this.status = status;
        this.genres = genres == null ? List.of() : List.copyOf(genres);
        this.formats = formats == null ? List.of() : List.copyOf(formats);
    }

    public long id() { return id; }
    public String title() { return title; }
    public String slug() { return slug; }
    public String synopsis() { return synopsis; }
    public String director() { return director; }
    public String cast() { return cast; }
    public Integer durationMinutes() { return durationMinutes; }
    public String ageRating() { return ageRating; }
    public LocalDate releaseDate() { return releaseDate; }
    public String posterUrl() { return posterUrl; }
    public String backdropUrl() { return backdropUrl; }
    public String trailerUrl() { return trailerUrl; }
    public MovieStatus status() { return status; }
    public List<String> genres() { return genres; }
    public List<MovieFormat> formats() { return formats; }

    public long getId() { return id; }
    public String getTitle() { return title; }
    public String getSlug() { return slug; }
    public String getSynopsis() { return synopsis; }
    public String getSummary() { return synopsis; }
    public String getDirector() { return director; }
    public String getCast() { return cast; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public String getAgeRating() { return ageRating; }
    public LocalDate getReleaseDate() { return releaseDate; }
    public String getPosterUrl() { return posterUrl; }
    public String getBackdropUrl() { return backdropUrl; }
    public String getTrailerUrl() { return trailerUrl; }
    public MovieStatus getStatus() { return status; }
    public List<String> getGenres() { return genres; }
    public String getGenreNames() { return genres == null ? "" : String.join(", ", genres); }
    public String genreNames() { return getGenreNames(); }
    public String getCastNames() { return cast == null ? "" : cast; }
    public String castNames() { return getCastNames(); }
    public String getLanguage() { return ""; }
    public String language() { return getLanguage(); }
    public List<MovieFormat> getFormats() { return formats; }
}
