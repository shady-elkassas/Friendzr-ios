//
//  CustomClickableView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/03/2023.
//

import Foundation
import UIKit

class CustomClickableView: UIView {
    
  @IBOutlet weak var bigButton: UIView!
    
    var delegate:ViewDidclicked!
    
  override func awakeFromNib() {
    
    super.awakeFromNib()
    
  }

    @objc func Tapped() {
        delegate.viewTapped()
  }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = UIColor.FriendzrColors.fourthly
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Tapped()
        self.backgroundColor = UIColor.FriendzrColors.primary
    }
}

protocol ViewDidclicked {
    func viewTapped()
}
