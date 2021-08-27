import CoreData
import SwiftUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let contentView = MainView().environment(\.managedObjectContext, context)

    // https://stackoverflow.com/a/62576641/6101419
    let appearance = UINavigationBarAppearance()
    appearance.shadowColor = .clear
    UINavigationBar.appearance().standardAppearance = appearance

    UITableView.appearance().showsVerticalScrollIndicator = false

    window = UIWindow(frame: UIScreen.main.bounds)
    window!.rootViewController = UIHostingController(rootView: contentView)
    window!.makeKeyAndVisible()

    return true
  }

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Mu")
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
}