import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabController = UITabBarController()
        tabController.viewControllers = [
            TestVC(), TestVC()
        ]
        
        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

class TestVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Title"
        self.view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Present", for: .normal)
        self.view.addSubview(button)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        let modalVC = TestModalVC()
        modalVC.tabController = self.tabBarController!
        self.present(modalVC, animated: true, completion: nil)
    }
}

class TestModalVC: UIViewController {
    var tabController: UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Title"
        self.view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Switch tab", for: .normal)
        self.view.addSubview(button)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Dismiss", for: .normal)
        button2.sizeToFit()
        button2.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 20) 
        self.view.addSubview(button2)
        button2.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        if self.tabController.selectedIndex == 0 {
            self.tabController.selectedIndex = 1
        } else {
            self.tabController.selectedIndex = 0
        }
    }
    
    @objc func secondButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

