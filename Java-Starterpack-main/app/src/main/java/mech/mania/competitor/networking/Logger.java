package mech.mania.competitor.networking;

public class Logger {
    // TODO: refactor into static functions?

    public Logger() { }

    public void info(String log) {
        EngineCommunicator.sendErr("info: " + log);
    }

    public void debug(String log) {
        EngineCommunicator.sendErr("debug: " + log);
    }
}
