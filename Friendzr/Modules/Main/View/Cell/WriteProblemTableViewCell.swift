//
//  WriteProblemTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit

class WriteProblemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 12)
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension WriteProblemTableViewCell : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLbl.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 250
    }
}
