//
//  MessageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/05/2022.
//

import UIKit

protocol MessageTableViewCellDelegate: class {
  func messageTableViewCellUpdate()
}

class MessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profilePic: UIImageView?
    @IBOutlet weak var messageTextView: UITextView?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class MessageAttachmentTableViewCell: MessageTableViewCell {
    
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!
    weak var delegate: MessageTableViewCellDelegate?

    override func prepareForReuse() {
      super.prepareForReuse()
//      attachmentImageView.cancelDownload()
      attachmentImageView.image = nil
      attachmentImageViewHeightConstraint.constant = 250 / 1.3
      attachmentImageViewWidthConstraint.constant = 250
    }
    
}
