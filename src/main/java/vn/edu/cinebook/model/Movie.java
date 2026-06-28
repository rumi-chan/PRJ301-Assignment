package vn.edu.cinebook.model;

import java.time.LocalDate;
import java.util.List;

public record Movie(
        long id,
        String title,
        String slug,
        String synopsis,
        String director,
        String cast,
        int durationMinutes,
        String ageRating,
        LocalDate releaseDate,
        String posterUrl,
        String backdropUrl,
        String trailerUrl,
        MovieStatus status,
        List<String> genres,
        List<MovieFormat> formats
) {
    public long getId() { return id; }
    public String getTitle() { return title; }
    public String getSlug() { return slug; }
    public String getSynopsis() { return synopsis; }
    public String getSummary() { return synopsis; }
    public String getDirector() { return director; }
    public String getCast() { return cast; }
    public int getDurationMinutes() { return durationMinutes; }
    public String getAgeRating() { return ageRating; }
    public LocalDate getReleaseDate() { return releaseDate; }
    public String getPosterUrl() { return posterUrl; }
    public String getBackdropUrl() { return backdropUrl; }
    public String getTrailerUrl() { return trailerUrl; }
    public MovieStatus getStatus() { return status; }
    public List<String> getGenres() { return genres; }
    public List<MovieFormat> getFormats() { return formats; }
    public String getGenreNames() { return genres != null ? String.join(", ", genres) : ""; }
    public String getCastNames() { return cast != null ? cast : ""; }
    public String getLanguage() { return "Original language"; }
}
