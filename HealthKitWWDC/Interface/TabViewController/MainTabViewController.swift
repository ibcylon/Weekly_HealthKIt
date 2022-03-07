
import UIKit

final class MainTabViewController: UITabBarController {

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        setUpTabViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setUpTabViewController() {
        let viewControllers = [
            createReadViewController(),
            createWeeklyQuantitySampleTableViewController()
        ]

        self.viewControllers = viewControllers.map {
            UINavigationController(rootViewController: $0)
        }

        delegate = self
        selectedIndex = getLastViewedViewControllerIndex()
    }

    private func createReadViewController() -> UIViewController {
        let viewController = ReadViewController()

        viewController.tabBarItem = UITabBarItem(title: "Step List",
                                                 image: UIImage(systemName: "circle"),
                                                 selectedImage: UIImage(systemName: "circle.fill"))
        return viewController
    }

    private func createWeeklyQuantitySampleTableViewController() -> UIViewController {

        let viewController = ChartViewController()

        viewController.tabBarItem = UITabBarItem(title: "Chart",
                                                 image: UIImage(systemName: "triangle"),
                                                 selectedImage: UIImage(systemName: "triangle.fill"))
        return viewController
    }

    // MARK: - View Persistence


    private func getLastViewedViewControllerIndex() -> Int {
        return UserManager.lastSelectedTab // Default to first view controller.
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabViewController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }

        setLastViewedViewControllerIndex(index)
    }

    private func setLastViewedViewControllerIndex(_ index: Int) {
        UserManager.lastSelectedTab = index
    }

}
