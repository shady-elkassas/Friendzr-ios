//
//  ChatTitleView.swift
//  Friendzr
//
//  Created by Shady Elkassas on 05/12/2021.
//

import UIKit

protocol ChatTitleViewProtocol: class {
    func titleViewChannelButtonPressed()
}

class ChatTitleView: UIView {
    
    @IBOutlet weak var viewtitle: UIView! {
        didSet {
            viewtitle.backgroundColor = .gray
        }
    }
    
    weak var delegate: ChatTitleViewProtocol?

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.backgroundColor = .clear
            viewStatus.layer.cornerRadius = 4.5
        }
    }

    @IBOutlet weak var titleScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var showInfoImage: UIImageView!
    
    @IBOutlet weak var typingLabel: UILabel! {
        didSet {
            typingLabel.text = ""
        }
    }

    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var labelLoading: UILabel!

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    
    // MARK: IBAction
    @IBAction func recognizeTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.titleViewChannelButtonPressed()
        }
    }
}

extension UIView {

    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }

    static func instantiateFromNib() -> Self? {
        func instanceFromNib<T: UIView>() -> T? {
            return nib.instantiate() as? T
        }

        return instanceFromNib()
    }

}

extension UINib {

    func instantiate() -> Any? {
        return self.instantiate(withOwner: nil, options: nil).first
    }

}
