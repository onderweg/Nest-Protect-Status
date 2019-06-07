import Foundation
import Cocoa

class Alerts {
    
    static func error(title: String, text: String) -> Void {
        // Prevent _NSAlertWarnUnsafeBackgroundThreadUsage:
        // display in main thread   
        DispatchQueue.main.async {
            let alert: NSAlert = NSAlert()
            alert.messageText = title
            alert.informativeText = text
            alert.alertStyle = NSAlert.Style.critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
}
