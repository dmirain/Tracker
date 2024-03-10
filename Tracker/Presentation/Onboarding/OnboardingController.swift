import UIKit

protocol OnboardingControllerDelegate: AnyObject {
    func close()
}

final class OnboardingController: UIPageViewController {
    weak var flowDelegate: OnboardingControllerDelegate?

    private let viewModel: OnboardingViewModel
    private var pages: [OnboardingPageController] = []
    private let onboardingManager: OnboardingManager

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfPages = pages.count
        view.currentPage = 0

        view.currentPageIndicatorTintColor = .ypAlwaysBlack
        view.pageIndicatorTintColor = .ypAlwaysGray

        view.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)

        return view
     }()

    init(viewModel: OnboardingViewModel, onboardingManager: OnboardingManager) {
        self.viewModel = viewModel
        self.onboardingManager = onboardingManager
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        pages = viewModel.pages.map { $0.toController(delegate: self) }
        dataSource = self
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let page = pages.first {
            setViewControllers([page], direction: .forward, animated: true, completion: nil)
        }

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func currentPageIndex(page: UIViewController) -> Int? {
        guard let page = page as? OnboardingPageController else { return nil }
        return pages.firstIndex(of: page)
    }

    @objc
    func changePage(_ pageControl: UIPageControl) {
        let page = pages[pageControl.currentPage]
        setViewControllers([page], direction: .forward, animated: true, completion: nil)
    }
}

extension OnboardingPageViewModel {
    func toController(delegate: OnboardingPageControllerDelegate) -> OnboardingPageController {
        OnboardingPageController(
            delegate: delegate,
            viewModel: self
        )
    }
}

extension OnboardingController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let currentIndex = currentPageIndex(page: viewController),
            currentIndex > 0
        else { return nil }
        return pages[currentIndex - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let currentIndex = currentPageIndex(page: viewController),
            currentIndex < pages.count - 1
        else { return nil }
        return pages[currentIndex + 1]
    }
}

extension OnboardingController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = currentPageIndex(page: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingController: OnboardingPageControllerDelegate {
    func close() {
        onboardingManager.showed()
        flowDelegate?.close()
    }
}
