package mech.mania.competitor.model.decisions;

import mech.mania.competitor.model.Position;

import java.util.List;

public class PlantDecision extends ActionDecision {
    protected List<String> cropTypes;
    protected List<Position> coords;

    public PlantDecision(List<String> cropTypes, List<Position> coords) {
        this.cropTypes = cropTypes;
        this.coords = coords;
        assert(cropTypes.size() == coords.size());
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("PlantDecision(");
        for (int i = 0; i < cropTypes.size(); i++) {
            builder.append(cropTypes.get(i));
            builder.append(":");
            builder.append(coords.get(i));
            if (i < cropTypes.size() - 1) {
                builder.append(",");
            }
        }
        builder.append(")");

        return builder.toString();
    }

    public String getEngineReadableString() {
        StringBuilder builder = new StringBuilder();
        builder.append("plant ");
        for (int i = 0; i < cropTypes.size(); i++) {
            builder.append(cropTypes.get(i));
            builder.append(" ");
            builder.append(coords.get(i).getEngineReadableString());
        }

        return builder.toString();
    }
}
