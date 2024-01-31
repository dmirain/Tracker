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

        self.trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage.trackerTab,
            selectedImage: nil
        )
        self.trackerViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)

        self.statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage.statTab,
            selectedImage: nil
        )
        self.statisticViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor.ypWhite
        UITabBar.appearance().standardAppearance = tabBarAppearance

        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
