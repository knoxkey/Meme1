//
//  MemeCollectionVC.swift
//  PKKMeme2
//
//  Created by KNOX KEY on 4/28/16.
//  Copyright © 2016 Wingwood. All rights reserved.
//

import UIKit

class MemeCollectionVC: UICollectionViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)

        //let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        //memes = applicationDelegate.memes
    }

    override func viewWillAppear(animated: Bool) {
        print("collection reload")
        collectionView?.reloadData()
    }

    //MARK: Collection View Data Soure
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("trying to load")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let meme = memes[indexPath.row]

        cell.memeImageView?.image = meme.memedImage
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {

        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)

    }


}