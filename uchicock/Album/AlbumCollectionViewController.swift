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
    
    let queue = DispatchQueue(label: "queue")
    var emptyDataSetStr = ""
    let leastWaitTime = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show(withStatus: "ロード中...")
        queue.async {
            self.reloadRecipeList()
        }
        
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
        
        header.setRefreshingTarget(self, refreshingAction: #selector(AlbumCollectionViewController.refresh))
        header.lastUpdatedTimeLabel.isHidden = true
        header.setTitle("引っ張ってシャッフル", for: MJRefreshState.idle)
        header.setTitle("離すとシャッフル", for: MJRefreshState.pulling)
        header.setTitle("シャッフル中...", for: MJRefreshState.refreshing)
        self.collectionView!.mj_header = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView!.backgroundColor = Style.basicBackgroundColor
        header.stateLabel.textColor = Style.labelTextColor

        SVProgressHUD.show(withStatus: "ロード中...")
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        emptyDataSetStr = ""

        queue.async {
            self.waitAtLeast(self.leastWaitTime) {
                let realm = try! Realm()
                for i in (0..<self.tempRecipeBasicList.count).reversed() {
                    let recipeList = realm.objects(Recipe.self).filter("id == %@",self.tempRecipeBasicList[i].id)
                    if recipeList.count == 0 {
                        self.tempRecipeBasicList.remove(at: i)
                    }else if recipeList.first!.imageData == nil{
                        self.tempRecipeBasicList.remove(at: i)
                    }
                }
                
                let recipeList = realm.objects(Recipe.self).sorted(byKeyPath: "recipeName")
                for recipe in recipeList{
                    var newPhotoFlag = true
                    for rb in self.tempRecipeBasicList{
                        if recipe.id == rb.id{
                            newPhotoFlag = false
                            break
                        }
                    }
                    if newPhotoFlag && recipe.imageData != nil{
                        self.tempRecipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
                    }
                }
                self.recipeBasicList = self.tempRecipeBasicList
                self.emptyDataSetStr = "写真が登録されたレシピはありません"
            }
            DispatchQueue.main.async{
                self.collectionView!.reloadData()
                self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView!.setContentOffset(collectionView!.contentOffset, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shuffle<T>( array: inout [T]) {
        for index in 0..<array.count {
            let newIndex = Int(arc4random_uniform(UInt32(array.count - index))) + index
            if index != newIndex {
                swap(&array[index], &array[newIndex])
            }
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: emptyDataSetStr, attributes: attrs)
    }
    
    func reloadRecipeList(){
        tempRecipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for recipe in recipeList{
            if recipe.imageData != nil{
                tempRecipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
            }
        }
        tempRecipeBasicList.sort(by: { $0.japaneseDictionaryOrder < $1.japaneseDictionaryOrder })
    }
    
    func refresh(){
        self.collectionView!.mj_header.beginRefreshing()
        self.reloadRecipeList()
        self.shuffle(array: &self.tempRecipeBasicList)
        recipeBasicList = tempRecipeBasicList
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        self.collectionView!.mj_header.endRefreshing()
    }
    
    func waitAtLeast(_ time: TimeInterval, _ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        let wait = max(0.0, time - (end - start))
        if wait > 0.0 {
            Thread.sleep(forTimeInterval: wait)
        }
    }

    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.view.frame.size.width / 2 - 2
        return CGSize(width: size, height: size)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeBasicList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let realm = try! Realm()
        let recipeCount = realm.objects(Recipe.self).filter("id == %@",recipeBasicList[indexPath.row].id).count
        if recipeCount > 0 {
            performSegue(withIdentifier: "RecipeTapped", sender: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumItem", for: indexPath as IndexPath) as! AlbumCollectionViewCell

        let realm = try! Realm()
        let recipe = realm.objects(Recipe.self).filter("id == %@",recipeBasicList[indexPath.row].id).first!

        if let image = recipe.imageData {
            cell.photo.image = UIImage(data: image as Data)
            //レシピ削除のバグに対するワークアラウンド
            if cell.photo.image == nil{
                if Style.isDark{
                    cell.photo.image = UIImage(named: "no-photo-dark")
                }else{
                    cell.photo.image = UIImage(named: "no-photo")
                }
            }
        }else{
            if Style.isDark{
                cell.photo.image = UIImage(named: "no-photo-dark")
            }else{
                cell.photo.image = UIImage(named: "no-photo")
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - IBAction
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "シャッフル", message: "表示順をシャッフルします", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            SVProgressHUD.show(withStatus: "シャッフル中...")
            self.queue.async {
                self.waitAtLeast(self.leastWaitTime) {
                    self.reloadRecipeList()
                    self.shuffle(array: &self.tempRecipeBasicList)
                    self.recipeBasicList = self.tempRecipeBasicList
                }
                DispatchQueue.main.async{
                    self.collectionView!.reloadData()
                    self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                    SVProgressHUD.dismiss()
                }
            }
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        self.present(alertView, animated: true, completion: nil)
    }

    @IBAction func orderButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "名前順", message: "レシピを名前順に並べ替えます", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            SVProgressHUD.show(withStatus: "並べ替え中...")
            self.queue.async {
                self.waitAtLeast(self.leastWaitTime) {
                    self.reloadRecipeList()
                    self.recipeBasicList = self.tempRecipeBasicList
                }
                DispatchQueue.main.async{
                    self.collectionView!.reloadData()
                    self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                    SVProgressHUD.dismiss()
                }
            }
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeTapped" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                let realm = try! Realm()
                let recipe = realm.objects(Recipe.self).filter("id == %@",recipeBasicList[indexPath.row].id).first!
                vc.recipeId = recipe.id
            }
        }
    }
    
}
