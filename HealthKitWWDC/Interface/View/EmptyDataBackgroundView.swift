//
//  EmptyDataBackgroundView.swift
//  HealthKitWWDC
//
//  Created by Kanghos on 2022/02/28.
//

import UIKit

import SnapKit
import Then

class EmptyDataBackgroundView: UIView {

    var labelText: String!
    var label = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 22, weight: .regular)
    }

    init(message: String) {
        self.labelText = message

        super.init(frame: .zero)

        labelText = message

        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpViews() {
        addSubview(label)
        addConstraints()
    }

    func addConstraints() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(60)
        }
    }
}
