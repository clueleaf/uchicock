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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
