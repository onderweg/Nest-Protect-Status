import Cocoa

// 'ui_color_state' colors
enum NestColorState: String {
    case Red = "red"
    case Yellow = "yellow"
    case Green = "green"
    case Gray = "gray"
}

@IBDesignable
class NestStatusView: NSView {
    
    public var colorState:NestColorState = .Green {
        didSet {
            // Color was set, so tell the system a redraw is needed.
            needsDisplay = true
        }
    }
    
    @IBInspectable var deviceName = "Device 1"
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.wantsLayer = true
        self.shadow = NSShadow()
        self.layer?.shadowOffset = CGSize(width: 2, height: 2)
        self.layer?.shadowRadius = 5
        self.layer?.masksToBounds = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)       
        let context = NSGraphicsContext.current?.cgContext
        let viewRect = CGRect(x: bounds.minX , y: bounds.minY, width: bounds.size.width, height: bounds.size.height)
        drawCircle(context: context!, rect: viewRect)
    }
    
    func getStateColor() -> CGColor {
        switch (colorState) {
        case .Red:
            return CGColor(
                red: 210/255,
                green: 80/255,
                blue: 58/255,
                alpha: 1)
        case .Yellow:
            return CGColor(
                red: 248/255,
                green: 204/255,
                blue: 70/255,
                alpha: 1)
        case .Green:
            return CGColor(
                red: 128/255,
                green: 238/255,
                blue: 111/255,
                alpha: 1)
        case .Gray:
            return NSColor.gray.cgColor
        }
    }
    
    func drawCircle(context: CGContext, rect: NSRect) {
        let strokeColor = getStateColor();
        let fillColor = NSColor.clear.cgColor;
        let strokeWidth: CGFloat = 15.0
        let shortestSide = min(rect.size.width, rect.size.height)
        let circleRect = CGRect(x: rect.minX + (strokeWidth/2),
                                y: rect.minY + (strokeWidth/2),
                                width: shortestSide - strokeWidth,
                                height: shortestSide - strokeWidth)
        
        context.setLineWidth(strokeWidth);
        context.setFillColor(fillColor)
        context.setStrokeColor(strokeColor)
        context.addEllipse(in: circleRect)
        context.drawPath(using: .fillStroke)
        
        let textRect = circleRect
        drawTitle(text: self.deviceName, rect: textRect, context: context);
    }
    
    func drawTitle(text: String, rect: CGRect, context: CGContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        
        let nameTextAttributes = [
            NSAttributedString.Key.font: NSFont(name: "Helvetica", size: 0.08 * rect.height),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
        ]
        drawVerticallyCentered(str: text, in: rect, withAttributes: nameTextAttributes as [NSAttributedString.Key : Any])
    }
    
    func drawVerticallyCentered(str: String, in rect: CGRect, withAttributes attributes: [NSAttributedString.Key : Any]? = nil) {
        let size = str.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.size.height-size.height)/2.0, width: rect.size.width, height: size.height)
        str.draw(in: centeredRect, withAttributes: attributes)
    }
    
    override func prepareForInterfaceBuilder() {
    }    
}
