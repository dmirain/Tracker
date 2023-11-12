import UIKit

final class TabBarController: UITabBarController {
    private let trackerViewController: TrackerViewController
    private let statisticViewController: StatisticViewController

    init(
        trackerViewController: TrackerViewController,
        statisticViewController: StatisticViewController
    ) {
        self.trackerViewController = trackerViewController
        self.statisticViewController = statisticViewController

        super.init(nibName: nil, bundle: nil)

        viewControllers = [self.trackerViewController, self.statisticViewController]

        self.trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage.trackerTab, selectedImage: nil)
        self.statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage.statTab, selectedImage: nil)

        tabBar.tintColor = UIColor.ypWhiteNight
        tabBar.barTintColor = UIColor.ypBlackNight
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
