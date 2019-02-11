import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = SamplesViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        navController.navigationBar.tintColor = .white
        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
