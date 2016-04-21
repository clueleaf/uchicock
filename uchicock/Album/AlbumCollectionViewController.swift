//
//  AlbumCollectionViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var recipeIdList = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.collectionView!.backgroundColor = FlatWhite()

        recipeIdList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe).sorted("recipeName")
        for recipe in recipeList{
            if recipe.imageData != nil{
                //レシピ削除のバグに対するワークアラウンド
                if UIImage(data: recipe.imageData!) != nil{
                    recipeIdList.append(recipe.id)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        for var i = recipeIdList.count - 1; i >= 0; --i {
            let recipeList = realm.objects(Recipe).filter("id == %@",recipeIdList[i])
            if recipeList.count == 0 {
                recipeIdList.removeAtIndex(i)
            }else if recipeList.first!.imageData == nil{
                //レシピ削除のバグに対するワークアラウンド
                recipeIdList.removeAtIndex(i)
            }else if UIImage(data: recipeList.first!.imageData!) == nil{
                recipeIdList.removeAtIndex(i)
            }
        }
        self.collectionView!.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shuffle<T>(inout array: [T]) {
        for index in 0..<array.count {
            let newIndex = Int(arc4random_uniform(UInt32(array.count - index))) + index
            if index != newIndex {
                swap(&array[index], &array[newIndex])
            }
        }
    }

    // MARK: UICollectionView
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.view.frame.size.width / 2 - 2
        return CGSize(width: size, height: size)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeIdList.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("RecipeTapped", sender: indexPath)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AlbumItem", forIndexPath: indexPath) as! AlbumCollectionViewCell

        let realm = try! Realm()
        let recipe = realm.objects(Recipe).filter("id == %@",recipeIdList[indexPath.row]).first!

        if recipe.imageData != nil{
            cell.photo.image = UIImage(data: recipe.imageData!)
            //レシピ削除のバグに対するワークアラウンド
            if cell.photo.image == nil{
                cell.photo.image = UIImage(named: "no-photo")
            }
        }else{
            cell.photo.image = UIImage(named: "no-photo")
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - IBAction
    @IBAction func reloadButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "リロード＆シャッフル", message: "写真をリロードし、シャッフル表示します", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            self.recipeIdList.removeAll()
            let realm = try! Realm()
            let recipeList = realm.objects(Recipe).sorted("recipeName")
            for recipe in recipeList{
                if recipe.imageData != nil{
                    //レシピ削除のバグに対するワークアラウンド
                    if UIImage(data: recipe.imageData!) != nil{
                        self.recipeIdList.append(recipe.id)
                    }
                }
            }
            self.shuffle(&self.recipeIdList)
            self.collectionView!.reloadData()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecipeTapped" {
            let vc = segue.destinationViewController as! RecipeDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = recipeIdList[indexPath.row]
            }
        }
    }
    
}
