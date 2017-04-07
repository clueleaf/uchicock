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

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var recipeBasicList = Array<RecipeBasic>()
    let header = MJRefreshNormalHeader()
    
    let queue = DispatchQueue(label: "queue")
    var emptyDataSetStr = ""
    let leastWaitTime = 0.15
    var showNameFlag = false
    var animationFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        emptyDataSetStr = ""

        queue.async {
            let realm = try! Realm()
            for i in (0..<self.recipeBasicList.count).reversed() {
                let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: self.recipeBasicList[i].id)
                if let r = recipe{
                    if r.imageData == nil{
                        self.recipeBasicList.remove(at: i)
                    }
                }else{
                    self.recipeBasicList.remove(at: i)
                }
            }
            
            let recipeList = realm.objects(Recipe.self).filter("imageData != nil").sorted(byKeyPath: "japaneseDictionaryOrder")
            for recipe in recipeList{
                var newPhotoFlag = true
                for rb in self.recipeBasicList{
                    if recipe.id == rb.id{
                        newPhotoFlag = false
                        break
                    }
                }
                if newPhotoFlag{
                    self.recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
                }
            }
            self.emptyDataSetStr = "写真が登録されたレシピはありません"
            DispatchQueue.main.async{
                self.collectionView!.reloadData()
                self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
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
        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).filter("imageData != nil")
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
        }
        recipeBasicList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
    }
    
    func refresh(){
        self.collectionView!.mj_header.beginRefreshing()
        self.shuffle(array: &self.recipeBasicList)
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        self.collectionView!.mj_header.endRefreshing()
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
        if indexPath.row < recipeBasicList.count{
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)
            if recipe != nil {
                performSegue(withIdentifier: "RecipeTapped", sender: indexPath)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumItem", for: indexPath as IndexPath) as! AlbumCollectionViewCell

        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!

        if let image = recipe.imageData {
            cell.photo.image = UIImage(data: image as Data)
            cell.recipeName.text = recipe.recipeName
            cell.recipeName.textColor = Style.labelTextColor
            cell.recipeName.backgroundColor = Style.albumRecipeNameBackgroundColor
            if showNameFlag{
                if animationFlag{
                    UIView.animate(withDuration: 0.3, animations: {cell.recipeName.alpha = 1.0}, completion: nil)
                }else{
                    cell.recipeName.alpha = 1.0
                }
            }else{
                if animationFlag{
                    UIView.animate(withDuration: 0.3, animations: {cell.recipeName.alpha = 0.0}, completion: nil)
                }else{
                    cell.recipeName.alpha = 0.0
                }
            }
            //レシピ削除のバグに対するワークアラウンド
            if cell.photo.image == nil{
                if Style.isDark{
                    cell.photo.image = UIImage(named: "no-photo-dark")
                    cell.recipeName.alpha = 0.0
                }else{
                    cell.photo.image = UIImage(named: "no-photo")
                    cell.recipeName.alpha = 0.0
                }
            }
        }else{
            if Style.isDark{
                cell.photo.image = UIImage(named: "no-photo-dark")
                cell.recipeName.alpha = 0.0
            }else{
                cell.photo.image = UIImage(named: "no-photo")
                cell.recipeName.alpha = 0.0
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
            self.shuffle(array: &self.recipeBasicList)
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        self.present(alertView, animated: true, completion: nil)
    }

    @IBAction func orderButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "名前順", message: "レシピを名前順に並べ替えます", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.reloadRecipeList()
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func nameButtonTapped(_ sender: UIBarButtonItem) {
        if showNameFlag {
//            sender.setBackgroundImage(UIImage(named: "album-name-off"), for: .normal, barMetrics: .default)
            showNameFlag = false
            animationFlag = true
            self.collectionView!.reloadData()
            self.collectionView!.layoutIfNeeded()
            animationFlag = false
        }else{
//            sender.setBackgroundImage(UIImage(named: "album-name-on"), for: .normal, barMetrics: .default)
            showNameFlag = true
            animationFlag = true
            self.collectionView!.reloadData()
            self.collectionView!.layoutIfNeeded()
            animationFlag = false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeTapped" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                let realm = try! Realm()
                let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
                vc.recipeId = recipe.id
            }
        }
    }
    
}
