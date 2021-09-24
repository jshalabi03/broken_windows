package mech.mania.competitor.model.decisions;

public class UseItemDecision extends ActionDecision {

    @Override
    public String toString() {
        return "UseItem()";
    }

    public String getEngineReadableString() {
        return "use_item ";
    }
}
