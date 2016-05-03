//
//  MemeDetailViewController.swift
//  PKKMeme2
//
//  Created by KNOX KEY on 4/29/16.
//  Copyright © 2016 Wingwood. All rights reserved.
//

import UIKit

class MemeDetailViewController : UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var meme: Meme!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.label.text = self.villain.name

        self.tabBarController?.tabBar.hidden = true

        self.imageView!.image = meme.memedImage
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
}
