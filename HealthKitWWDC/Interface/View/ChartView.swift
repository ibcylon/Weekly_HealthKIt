import UIKit
import CareKitUI

extension OCKCartesianChartView {

    func applyDefaultConfiguration() {
        applyDefaultStyle()

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none

        graphView.numberFormatter = numberFormatter
        graphView.yMinimum = 0
    }

    func applyDefaultStyle() {
        headerView.detailLabel.textColor = .secondaryLabel
    }

    func applyHeaderStyle() {
        applyDefaultStyle()

        customStyle = ChartHeaderStyle()
    }
}

struct ChartHeaderStyle: OCKStyler {
    var appearance: OCKAppearanceStyler {
        NoShadowAppearenceStyle()
    }
}

struct NoShadowAppearenceStyle: OCKAppearanceStyler {
    var shadowOpacity1: Float = 0
    var shadowRadius1: CGFloat = 0
    var shadowOffset1: CGSize = .zero
}
