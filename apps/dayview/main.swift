import SwiftUI
import AppKit
import EventKit

// MARK: - Models & Store

class CalendarManager: ObservableObject {
    @Published var allDayEvents: [EKEvent] = []
    @Published var timedEvents: [EKEvent] = []
    @Published var currentTime: Date = Date()
    
    private let eventStore = EKEventStore()
    private var timer: Timer?
    
    init() {
        requestAccess()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
        
        // Update current time indicator every minute; re-query events only when crossing midnight
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let prevDay = Calendar.current.startOfDay(for: self.currentTime)
                let now = Date()
                self.currentTime = now
                if Calendar.current.startOfDay(for: now) != prevDay {
                    self.refresh()
                }
            }
        }
    }
    
    func requestAccess() {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, _ in
                if granted {
                    DispatchQueue.main.async { self?.refresh() }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                if granted {
                    DispatchQueue.main.async { self?.refresh() }
                }
            }
        }
    }
    
    @objc private func storeChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.refresh()
        }
    }
    
    func refresh() {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let todayEnd = cal.date(byAdding: .day, value: 1, to: todayStart) else { return }
        
        let pred = eventStore.predicateForEvents(withStart: todayStart, end: todayEnd, calendars: nil)
        let rawEvents = eventStore.events(matching: pred)
        
        var allDay: [EKEvent] = []
        var timed: [EKEvent] = []
        
        for event in rawEvents {
            if event.isAllDay {
                allDay.append(event)
            } else {
                // If it spans or starts/ends today
                timed.append(event)
            }
        }
        
        allDay.sort { ($0.title ?? "") < ($1.title ?? "") }
        timed.sort { $0.startDate < $1.startDate }
        
        self.allDayEvents = allDay
        self.timedEvents = timed
    }
}

// MARK: - Layout Constants

let START_HOUR: Int = 5
let END_HOUR: Int = 23
let TOTAL_HOURS: Int = 18 // 23 - 5

// MARK: - Views

struct DayCalendarView: View {
    @ObservedObject var manager: CalendarManager
    
    var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: manager.currentTime).uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("Today")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)
            
            // All-day section (vertically stacked, tight height)
            if !manager.allDayEvents.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ALL-DAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    ForEach(manager.allDayEvents, id: \.eventIdentifier) { event in
                        HStack(alignment: .center, spacing: 6) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color(nsColor: event.calendar.color))
                                .frame(width: 3)
                            
                            Text(event.title ?? "Untitled")
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(Color(nsColor: event.calendar.color).opacity(0.12))
                        .cornerRadius(4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                Divider()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
            
            // Timeline 05:00 - 23:00
            GeometryReader { geo in
                let hourHeight = geo.size.height / CGFloat(TOTAL_HOURS)
                
                ZStack(alignment: .topLeading) {
                    // Hour grid lines & labels
                    VStack(spacing: 0) {
                        ForEach(START_HOUR..<END_HOUR, id: \.self) { hour in
                            HStack(alignment: .top, spacing: 8) {
                                Text(String(format: "%02d:00", hour))
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 42, alignment: .trailing)
                                
                                Rectangle()
                                    .fill(Color.primary.opacity(0.08))
                                    .frame(height: 1)
                            }
                            .frame(height: hourHeight, alignment: .top)
                        }
                    }
                    
                    // Current time red line
                    let currentOffset = timeToOffset(date: manager.currentTime, totalHeight: geo.size.height)
                    if let offset = currentOffset {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 1.5)
                        }
                        .offset(x: 42, y: offset - 3)
                    }
                    
                    // Events
                    ForEach(manager.timedEvents, id: \.eventIdentifier) { event in
                        if let rect = computeEventRect(event: event, width: geo.size.width - 56, totalHeight: geo.size.height) {
                            EventBlock(event: event)
                                .frame(width: rect.width, height: rect.height)
                                .offset(x: 54, y: rect.origin.y)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            VisualEffectBackground()
        )
    }
    
    private func timeToOffset(date: Date, totalHeight: CGFloat) -> CGFloat? {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: date)
        guard let hour = comps.hour, let min = comps.minute else { return nil }
        let currentHourFloat = CGFloat(hour) + CGFloat(min) / 60.0
        
        guard currentHourFloat >= CGFloat(START_HOUR) && currentHourFloat <= CGFloat(END_HOUR) else {
            return nil
        }
        let progress = (currentHourFloat - CGFloat(START_HOUR)) / CGFloat(TOTAL_HOURS)
        return progress * totalHeight
    }
    
    private func computeEventRect(event: EKEvent, width: CGFloat, totalHeight: CGFloat) -> CGRect? {
        let cal = Calendar.current
        let startComp = cal.dateComponents([.hour, .minute], from: event.startDate)
        let endComp = cal.dateComponents([.hour, .minute], from: event.endDate)
        
        guard let sH = startComp.hour, let sM = startComp.minute,
              let eH = endComp.hour, let eM = endComp.minute else { return nil }
        
        let startFloat = max(CGFloat(START_HOUR), CGFloat(sH) + CGFloat(sM) / 60.0)
        let endFloat = min(CGFloat(END_HOUR), CGFloat(eH) + CGFloat(eM) / 60.0)
        
        guard endFloat > startFloat else { return nil }
        
        let topProgress = (startFloat - CGFloat(START_HOUR)) / CGFloat(TOTAL_HOURS)
        let bottomProgress = (endFloat - CGFloat(START_HOUR)) / CGFloat(TOTAL_HOURS)
        
        let y = topProgress * totalHeight
        let height = max(18, (bottomProgress - topProgress) * totalHeight - 2)
        
        return CGRect(x: 0, y: y, width: width, height: height)
    }
}

struct EventBlock: View {
    let event: EKEvent
    
    var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: event.startDate)) - \(f.string(from: event.endDate))"
    }
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(nsColor: event.calendar.color))
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title ?? "Untitled")
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(timeString)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(nsColor: event.calendar.color).opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: event.calendar.color).opacity(0.4), lineWidth: 0.5)
        )
    }
}

// Vibrancy / blur background
struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - App & Window Management

enum WindowMode {
    case desktopWidget
    case normalWindow
    case floating
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let manager = CalendarManager()
    var currentMode: WindowMode = .desktopWidget
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        
        let width = visibleFrame.width / 4.0
        let height = visibleFrame.height
        let x = visibleFrame.maxX - width // docked to right edge
        let y = visibleFrame.minY
        
        let initialFrame = NSRect(x: x, y: y, width: width, height: height)
        
        window = NSWindow(
            contentRect: initialFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.contentView = NSHostingView(rootView: DayCalendarView(manager: manager))
        
        applyMode(.desktopWidget)
        window.makeKeyAndOrderFront(nil)
    }
    
    func applyMode(_ mode: WindowMode) {
        currentMode = mode
        switch mode {
        case .desktopWidget:
            // Sits on desktop level (behind windows, visible on desktop / show desktop)
            window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.ignoresMouseEvents = false
        case .normalWindow:
            window.level = .normal
            window.collectionBehavior = []
            window.ignoresMouseEvents = false
        case .floating:
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces]
            window.ignoresMouseEvents = false
        }
    }
}

@main
struct DayViewApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
