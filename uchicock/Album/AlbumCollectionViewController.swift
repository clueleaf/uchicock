//
//  AlbumCollectionViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import MJRefresh

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var recipeNameBarButton: UIBarButtonItem!
    
    var recipeBasicList = Array<RecipeBasic>()
    let header = MJRefreshNormalHeader()
    
    let queue = DispatchQueue(label: "queue")
    var emptyDataSetStr = ""
    let leastWaitTime = 0.15
    var showNameFlag = false
    var animationFlag = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue.async {
            self.reloadRecipeList()
        }
        
        recipeNameBarButton.image = UIImage(named: "album-name-off")
        
        header.setRefreshingTarget(self, refreshingAction: #selector(AlbumCollectionViewController.refresh))
        header.lastUpdatedTimeLabel.isHidden = true
        header.setTitle("引っ張ってシャッフル", for: MJRefreshState.idle)
        header.setTitle("離すとシャッフル", for: MJRefreshState.pulling)
        header.setTitle("シャッフル中...", for: MJRefreshState.refreshing)
        collectionView!.mj_header = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView!.backgroundColor = Style.basicBackgroundColor
        header.stateLabel.textColor = Style.labelTextColor
        self.collectionView!.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        setCollectionBackgroundView()
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
            
            let recipeList = realm.objects(Recipe.self).filter("imageData != nil")
            for recipe in recipeList{
                var newPhotoFlag = true
                for rb in self.recipeBasicList{
                    if recipe.id == rb.id{
                        newPhotoFlag = false
                        break
                    }
                }
                if newPhotoFlag{
                    self.recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
                }
            }
            self.emptyDataSetStr = "写真が登録されたレシピはありません"
            DispatchQueue.main.async{
                self.collectionView!.reloadData()
                self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
                self.setCollectionBackgroundView()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // CAGradientLayerのframeはAutolayout後でないと正確に決まらないので、ここでもう一度ロードする（特に新しく写真を追加したときに必要）
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        self.setCollectionBackgroundView()
    }
    
    func reloadRecipeList(){
        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).filter("imageData != nil")
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
        }
        recipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    func setCollectionBackgroundView(){
        if self.recipeBasicList.count == 0{
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width, height: self.collectionView.bounds.size.height))
            noDataLabel.text          = "写真が登録されたレシピはありません"
            noDataLabel.textColor     = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center
            self.collectionView.backgroundView  = UIView()
            self.collectionView.backgroundView?.addSubview(noDataLabel)
            self.collectionView.isScrollEnabled = false
        }else{
            self.collectionView.backgroundView = nil
            self.collectionView.isScrollEnabled = true
        }
    }
    
    @objc func refresh(){
        self.collectionView!.mj_header.beginRefreshing()
        recipeBasicList.shuffle()
        self.collectionView!.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
        self.setCollectionBackgroundView()
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
            if let r = recipe {
                performSegue(withIdentifier: "RecipeTapped", sender: r.id)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumItem", for: indexPath as IndexPath) as! AlbumCollectionViewCell

        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)
        if let r = recipe{
            if let image = r.imageData {
                cell.photo.image = UIImage(data: image as Data)
                cell.recipeName.text = r.recipeName
                cell.recipeName.textColor = Style.labelTextColor
                cell.recipeName.backgroundColor = UIColor.clear
                
                // 重複して何重もグラデーションを付けないように、既存のグラデーションを取り除く
                cell.recipeNameBackgroundView.layer.sublayers?.forEach {
                    if $0.isKind(of: CustomCAGradientLayer.self){
                        $0.removeFromSuperlayer()
                    }
                }
                let gradient = CustomCAGradientLayer()
                gradient.frame = cell.recipeNameBackgroundView.bounds
                gradient.colors = [Style.albumRecipeNameBackgroundClearColor, Style.albumRecipeNameBackgroundColor]
                cell.recipeNameBackgroundView.layer.insertSublayer(gradient, at: 0)

                if showNameFlag{
                    if animationFlag{
                        UIView.animate(withDuration: 0.2, animations: {
                            cell.recipeName.alpha = 1.0
                            cell.recipeNameBackgroundView.alpha = 1.0
                        }, completion: nil)
                    }else{
                        cell.recipeName.alpha = 1.0
                        cell.recipeNameBackgroundView.alpha = 1.0
                    }
                }else{
                    if animationFlag{
                        UIView.animate(withDuration: 0.2, animations: {
                            cell.recipeName.alpha = 0.0
                            cell.recipeNameBackgroundView.alpha = 0.0
                        }, completion: nil)
                    }else{
                        cell.recipeName.alpha = 0.0
                        cell.recipeNameBackgroundView.alpha = 0.0
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
        }else{
            cell.photo.image = nil
            cell.recipeName.text = nil
            cell.recipeName.alpha = 0.0
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - IBAction
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = CustomAlertController(title: "シャッフル", message: "表示順をシャッフルします", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.recipeBasicList.shuffle()
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
            self.setCollectionBackgroundView()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(alertView, animated: true, completion: nil)
    }

    @IBAction func orderButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = CustomAlertController(title: "名前順", message: "レシピを名前順に並べ替えます", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.reloadRecipeList()
            self.collectionView!.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.recipeBasicList.count) + ")"
            self.setCollectionBackgroundView()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func nameButtonTapped(_ sender: UIBarButtonItem) {
        if showNameFlag {
            recipeNameBarButton.image = UIImage(named: "album-name-off")
            showNameFlag = false
            animationFlag = true
            self.collectionView!.reloadData()
            self.collectionView!.layoutIfNeeded()
            animationFlag = false
        }else{
            recipeNameBarButton.image = UIImage(named: "album-name-on")
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
            if let id = sender as? String{
                vc.recipeId = id
            }
        }
    }
    
}

class CustomCAGradientLayer: CAGradientLayer{
}
