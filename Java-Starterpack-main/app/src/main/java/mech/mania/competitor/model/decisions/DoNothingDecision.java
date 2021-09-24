package mech.mania.competitor.model.decisions;

public class DoNothingDecision extends ActionDecision {
    @Override
    public String toString() {
        return "DoNothingDecision()";
    }

    public String getEngineReadableString() {
        return "do_nothing ";
    }
}
