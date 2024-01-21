import UIKit

final class StatisticViewController: BaseUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.text = "Тут скоро будет статистика"
        lable.font = UIFont.boldSystemFont(ofSize: 19)
        lable.textAlignment = .center
        
        view.addSubview(lable)
        
        NSLayoutConstraint.activate([
            lable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lable.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])

        
    }
}

