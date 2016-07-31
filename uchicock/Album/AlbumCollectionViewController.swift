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
import MJRefresh
import SVProgressHUD

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var refreshControl:UIRefreshControl!
    var recipeBasicList = Array<RecipeBasic>()
    var tempRecipeBasicList = Array<RecipeBasic>()
    let header = MJRefreshNormalHeader()
    
    let queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL)
    var emptyDataSetStr = ""
    let leastWaitTime = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        SVProgressHUD.showWithStatus("ロード中...")
        dispatch_async(queue){
            self.reloadRecipeList()
        }
        
        self.collectionView!.backgroundColor = FlatWhite()
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        
        header.setRefreshingTarget(self, refreshingAction: #selector(AlbumCollectionViewController.refresh))
        header.lastUpdatedTimeLabel.hidden = true
        header.setTitle("引っ張ってシャッフル", forState: MJRefreshState.Idle)
        header.setTitle("離すとシャッフル", forState: MJRefreshState.Pulling)
        header.setTitle("シャッフル中...", forState: MJRefreshState.Refreshing)
        self.collectionView!.mj_header = header
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.showWithStatus("ロード中...")
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        emptyDataSetStr = ""

        dispatch_async(queue){
            self.waitAtLeast(self.leastWaitTime) {
                let realm = try! Realm()
                for i in (0..<self.tempRecipeBasicList.count).reverse() {
                    let recipeList = realm.objects(Recipe).filter("id == %@",self.tempRecipeBasicList[i].id)
                    if recipeList.count == 0 {
                        self.tempRecipeBasicList.removeAtIndex(i)
                    }else if recipeList.first!.imageData == nil{
                        self.tempRecipeBasicList.removeAtIndex(i)
                    }
                }
                
                let recipeList = realm.objects(Recipe).sorted("recipeName")
                for recipe in recipeList{
                    var newPhotoFlag = true
                    for rb in self.tempRecipeBasicList{
                        if recipe.id == rb.id{
                            newPhotoFlag = false
                            break
                        }
                    }
                    if newPhotoFlag && recipe.imageData != nil{
                        self.tempRecipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName))
                    }
                }
                self.recipeBasicList = self.tempRecipeBasicList
                self.emptyDataSetStr = "写真が登録されたレシピはありません"
            }
            dispatch_async(dispatch_get_main_queue()){
                self.collectionView!.reloadData()
                self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView!.setContentOffset(collectionView!.contentOffset, animated: false)
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
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: emptyDataSetStr, attributes: attrs)
    }
    
    func reloadRecipeList(){
        tempRecipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe)
        for recipe in recipeList{
            if recipe.imageData != nil{
                tempRecipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName))
            }
        }
        tempRecipeBasicList.sortInPlace({ $0.kanaName < $1.kanaName })
    }
    
    func refresh(){
        self.collectionView!.mj_header.beginRefreshing()
        self.reloadRecipeList()
        self.shuffle(&self.tempRecipeBasicList)
        recipeBasicList = tempRecipeBasicList
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        self.collectionView!.mj_header.endRefreshing()
    }
    
    func waitAtLeast(time : NSTimeInterval, @noescape _ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        let wait = max(0.0, time - (end - start))
        if wait > 0.0 {
            NSThread.sleepForTimeInterval(wait)
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
        return recipeBasicList.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let realm = try! Realm()
        let recipeCount = realm.objects(Recipe).filter("id == %@",recipeBasicList[indexPath.row].id).count
        if recipeCount > 0 {
            performSegueWithIdentifier("RecipeTapped", sender: indexPath)
        }
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
            SVProgressHUD.showWithStatus("シャッフル中...")
            dispatch_async(self.queue){
                self.waitAtLeast(self.leastWaitTime) {
                    self.reloadRecipeList()
                    self.shuffle(&self.tempRecipeBasicList)
                    self.recipeBasicList = self.tempRecipeBasicList
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.collectionView!.reloadData()
                    self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                    SVProgressHUD.dismiss()
                }
            }
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    @IBAction func orderButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "名前順", message: "レシピを名前順に並べ替えます", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            SVProgressHUD.showWithStatus("並べ替え中...")
            dispatch_async(self.queue){
                self.waitAtLeast(self.leastWaitTime) {
                    self.reloadRecipeList()
                    self.recipeBasicList = self.tempRecipeBasicList
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.collectionView!.reloadData()
                    self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                    SVProgressHUD.dismiss()
                }
            }
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
