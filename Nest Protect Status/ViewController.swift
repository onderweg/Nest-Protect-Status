//
//  ViewController.swift
//  Nest Protect Status

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    var messageLabel: NSTextField = NSTextField(wrappingLabelWithString: "Loading...")
    var bgView: NSView = NSView()
    var timer: Timer!
    
    var devices: [NestDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dotenv()
        configureCollectionView()
        setupMessage()
        setTimer()
        getDevices()
    }
    
    private func dotenv() {
        let env_file =  NSString("~/.nest-protect-status.env").expandingTildeInPath;
        let env_file_c = UnsafeMutablePointer<Int8>(mutating: (env_file as NSString).utf8String)
        env_load(env_file_c, false)
    }
    
    private func setTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
            self.getDevices()
        }
    }
    
    private func getDevices() {
        guard let accessKey = ProcessInfo.processInfo.environment["NEST_ACCESS_KEY"] else {
            self.showMessage("No value for environment variable 'NEST_ACCESS_KEY'")
            return;
        }
        let client = NestApiClient(accessKey: accessKey);
        
        client.getProtectDevices() { (result: Result<NestDevices, RESTError>) in
            switch result {
            case .success(let devices):
                print(devices)
                self.devices = Array(devices.values)
                break;
            case .failure(let error):
                Alerts.error(title: "Nest API Request failed", text: error.description)
                self.showMessage(error.description)
                return;
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 200.00, height: 200.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
    }
    
    private func setupMessage() {
        messageLabel.frame = CGRect(origin: .zero, size: .zero)
        messageLabel.backgroundColor = .clear
        messageLabel.textColor = NSColor.disabledControlTextColor
        messageLabel.font = NSFont.systemFont(ofSize: 30.0)
        messageLabel.isBezeled = false
        messageLabel.isEditable = false
        messageLabel.sizeToFit()
        bgView.addSubview(messageLabel)
        
        // Label can't be wider than its parent
        messageLabel.widthAnchor.constraint(lessThanOrEqualTo: bgView.widthAnchor, multiplier: 1.0).isActive = true
        
        // Center label hor. en vert.
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        
        // The view you assign to this property is positioned
        // underneath all other content and sized automatically to
        // match the enclosing clip view’s frame
        self.collectionView.backgroundView = bgView
    }
    
    func showMessage(_ text: String) {
        messageLabel.stringValue = text
        messageLabel.sizeToFit()
    }
    
    func hideMessage() {
        self.collectionView.backgroundView = nil
    }
}

extension ViewController : NSCollectionViewDataSource {
 
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
         return (devices.count)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        collectionView.backgroundView = nil
        let cell = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NestStatusViewItem"),
            for: indexPath
        ) as! NestStatusViewItem
        cell.configure(with: devices[indexPath.item])
        return cell
    }        
}
