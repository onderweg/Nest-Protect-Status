import Cocoa

class NestStatusViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var statusView: NestStatusView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        fadeAnimation()
    }
    
    private func fadeAnimation() {
        statusView.layer!.removeAllAnimations()
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.duration = 1.2
        statusView.layer!.add(fadeAnimation, forKey: nil)
    }
    
    public func configure(with device: NestDevice) {
        statusView.deviceName = device.name
        statusView.colorState = NestColorState(rawValue: device.ui_color_state) ?? NestColorState.Green;
        statusView.toolTip = [
            "Battery: \(device.battery_health)",
            "CO Alarm: \(device.co_alarm_state)",
            "Smoke Alarm: \(device.smoke_alarm_state)",
            "Online: \(device.is_online ? "yes" : "no")",
            "Last connection: \(device.last_connection.friendlyFormat())"
            ].joined(separator: "\n")
    }
    
}
