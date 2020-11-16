import UIKit

extension UIButton {

    func YDButtonStyle(ydColor:UIColor) {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.black, for: .selected)
        self.backgroundColor = ydColor
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 230),
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
            ])
    }
}
