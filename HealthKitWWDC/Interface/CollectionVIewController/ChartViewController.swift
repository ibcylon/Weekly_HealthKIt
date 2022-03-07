
import UIKit
import Then

class ChartViewController: UIViewController {
    static let cellIdentifier = "DataTypeCollectionViewCell"

    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
        $0.dataSource = self
        $0.register(DataTypeCollectionViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        $0.alwaysBounceVertical = true
    }

    var data: [(dataTypeIdentifier: String, values: [Double])] = []

    // MARK: View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationController()
        setUpView()

        title = tabBarItem.title
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
    }

    func reloadData() {
        collectionView.reloadData()
    }

    private func setUpNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setUpView() {
        view.addSubview(collectionView)

        setUpConstraints()
    }

    private func setUpConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        let verticalMargin: CGFloat = 8
        let horizontalMargin: CGFloat = 20
        let interGroupSpacing: CGFloat = horizontalMargin

        let cellHeight = calculateCellHeight(horizontalMargin: horizontalMargin, verticalMargin: verticalMargin)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(cellHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = itemSize

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpacing
        section.contentInsets = .init(top: verticalMargin, leading: horizontalMargin, bottom: verticalMargin, trailing: horizontalMargin)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

    private func calculateCellHeight(horizontalMargin: CGFloat, verticalMargin: CGFloat) -> CGFloat {
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let isLandscape = window?.interfaceOrientation.isLandscape ?? false
        let widthInset = (horizontalMargin * 2) + view.safeAreaInsets.left + view.safeAreaInsets.right
        var heightInset = (verticalMargin * 2)

        heightInset += navigationController?.navigationBar.bounds.height ?? 0
        heightInset += tabBarController?.tabBar.bounds.height ?? 0

        let cellHeight = isLandscape ? view.bounds.height - heightInset : view.bounds.width - widthInset

        return cellHeight
    }
}

extension ChartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content = data[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath) as? DataTypeCollectionViewCell
        else {
            return DataTypeCollectionViewCell()
        }

        cell.updateChartView(with: content.dataTypeIdentifier, values: content.values)
        return cell
    }


}
