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
import DZNEmptyDataSet

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var recipeBasicList = Array<RecipeBasic>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.collectionView!.backgroundColor = FlatWhite()

        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe)
        for recipe in recipeList{
            if recipe.imageData != nil{
                //レシピ削除のバグに対するワークアラウンド
                if UIImage(data: recipe.imageData!) != nil{
                    let rb = RecipeBasic()
                    rb.id = recipe.id
                    rb.name = recipe.recipeName
                    rb.kanaName = recipe.recipeName.katakana().lowercaseString
                    recipeBasicList.append(rb)
                }
            }
        }
        recipeBasicList.sortInPlace({ $0.kanaName < $1.kanaName })
        
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let realm = try! Realm()
        for i in (0..<recipeBasicList.count).reverse() {
            let recipeList = realm.objects(Recipe).filter("id == %@",recipeBasicList[i].id)
            if recipeList.count == 0 {
                recipeBasicList.removeAtIndex(i)
            }else if recipeList.first!.imageData == nil{
                //レシピ削除のバグに対するワークアラウンド
                recipeBasicList.removeAtIndex(i)
            }else if UIImage(data: recipeList.first!.imageData!) == nil{
                recipeBasicList.removeAtIndex(i)
            }
        }

        let recipeList = realm.objects(Recipe).sorted("recipeName")
        for recipe in recipeList{
            if recipe.imageData != nil{
                //レシピ削除のバグに対するワークアラウンド
                if UIImage(data: recipe.imageData!) != nil{
                    var newPhotoFlag = true
                    for id in recipeBasicList{
                        if recipe.id == id{
                            newPhotoFlag = false
                            break
                        }
                    }
                    if newPhotoFlag{
                        let rb = RecipeBasic()
                        rb.id = recipe.id
                        rb.name = recipe.recipeName
                        rb.kanaName = recipe.recipeName.katakana().lowercaseString
                        recipeBasicList.append(rb)
                    }
                }
            }
        }
        
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(recipeBasicList.count) + ")"
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
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "写真が登録されたレシピはありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
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
        return recipeBasicList.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("RecipeTapped", sender: indexPath)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AlbumItem", forIndexPath: indexPath) as! AlbumCollectionViewCell

        let realm = try! Realm()
        let recipe = realm.objects(Recipe).filter("id == %@",recipeBasicList[indexPath.row].id).first!

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
        let alertView = UIAlertController(title: "シャッフル", message: "表示順をシャッフルします", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            self.shuffle(&self.recipeBasicList)
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    @IBAction func orderButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "名前順", message: "レシピを名前順に並べ替えます", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            self.recipeBasicList.sortInPlace({ $0.kanaName < $1.kanaName })
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecipeTapped" {
            let vc = segue.destinationViewController as! RecipeDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                let realm = try! Realm()
                let recipe = realm.objects(Recipe).filter("id == %@",recipeBasicList[indexPath.row].id).first!
                vc.recipeId = recipe.id
            }
        }
    }
    
}
