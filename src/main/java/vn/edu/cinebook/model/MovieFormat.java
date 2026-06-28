package vn.edu.cinebook.model;

public enum MovieFormat {
    TWO_D("2D"),
    THREE_D("3D"),
    IMAX("IMAX");

    private final String label;

    MovieFormat(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
