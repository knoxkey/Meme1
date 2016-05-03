//
//  MemeTableVC.swift
//  PKKMeme2
//
//  Created by KNOX KEY on 4/28/16.
//  Copyright © 2016 Wingwood. All rights reserved.
//

import UIKit

class MemeTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //var memes: [Meme]!

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    @IBOutlet var tableView: UITableView!

    override func viewWillAppear(animated: Bool) {
        print("reload")
        tableView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        //memes = applicationDelegate.memes
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(memes.count)
        return memes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell")!
        let meme = memes[indexPath.row]

        //set image and text
        cell.imageView?.image = meme.imageView
        //cell.textLabel?.text = meme.topLine
        cell.textLabel?.text = String(meme.topLine.characters.prefix(10)) + "..." + String(meme.bottomLine.characters.prefix(10))
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Get the DetailVC from Storyboard
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
         as! MemeDetailViewController
        //Populate view controller with data from selected item
        detailController.meme = memes[indexPath.row]
        //Present the view controller using navigation
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @IBAction func addAnImage(sender: AnyObject) {
        let VC = storyboard!.instantiateViewControllerWithIdentifier("EditorVC") as! EditorVC
        navigationController?.pushViewController(VC, animated: true)
    }
    
}