//
//  InterestsProfileTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit

class InterestsProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var tagsListViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsListView: TagListView!
    @IBOutlet weak var tagsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsTopConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tagsListView.delegate = self
        tagsListView.textFont = UIFont(name: "Montserrat-Bold", size: 10)!

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension InterestsProfileTableViewCell : TagListViewDelegate {
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(tagView.tagId)")
        //        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        //        sender.removeTagView(tagView)
    }
    
}
