import AppKit
import PreferencePanes

@objc(AWDLPane)
final class AWDLPane: NSPreferencePane {
    private let toggle = NSSwitch()
    private let state = NSTextField(labelWithString: "")
    private let error = NSTextField(wrappingLabelWithString: "")
    private var timer: Timer?

    override func loadMainView() -> NSView {
        let title = NSTextField(labelWithString: "AirDrop / Continuity (awdl0)")
        title.font = .boldSystemFont(ofSize: 13)
        let note = NSTextField(wrappingLabelWithString:
            "Off: fewer Wi-Fi latency spikes (screen sharing, remote desktop, games). AirDrop, Sidecar and Universal Control need it on. macOS turns it back on at restart.")
        note.textColor = .secondaryLabelColor
        error.textColor = .systemRed
        toggle.target = self
        toggle.action = #selector(flip)

        let row = NSStackView(views: [toggle, state])
        row.spacing = 8
        let stack = NSStackView(views: [title, row, note, error])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let view = NSView(frame: NSRect(x: 0, y: 0, width: 668, height: 220))
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            note.widthAnchor.constraint(lessThanOrEqualToConstant: 520),
            error.widthAnchor.constraint(lessThanOrEqualToConstant: 520),
        ])
        mainView = view
        return view
    }

    override func didSelect() {
        refresh()
        // macOS can bring awdl0 back on its own (AirDrop, Sidecar), keep the switch in sync
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.refresh() }
    }

    override func didUnselect() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        let up = run("/sbin/ifconfig", ["awdl0"]).out.contains("<UP")
        toggle.state = up ? .on : .off
        state.stringValue = up ? "On" : "Off"
    }

    @objc private func flip() {
        let r = run("/usr/bin/sudo", ["-n", "/sbin/ifconfig", "awdl0", toggle.state == .on ? "up" : "down"])
        error.stringValue = r.code == 0 ? "" : "Failed (\(r.err.trimmingCharacters(in: .whitespacesAndNewlines))). Run install-sudoers.sh once."
        refresh()
    }

    private func run(_ path: String, _ args: [String]) -> (code: Int32, out: String, err: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        let out = Pipe(), err = Pipe()
        p.standardOutput = out
        p.standardError = err
        do { try p.run() } catch { return (-1, "", "\(error)") }
        p.waitUntilExit()
        let o = String(decoding: out.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let e = String(decoding: err.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        return (p.terminationStatus, o, e)
    }
}
