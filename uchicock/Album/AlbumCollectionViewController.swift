//
//  AlbumCollectionViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var recipeNameBarButton: UIBarButtonItem!
    @IBOutlet weak var albumFilterBarButton: UIBarButtonItem!
    
    var recipeBasicList = Array<RecipeBasic>()
    var filteredRecipeBasicList = Array<RecipeBasic>()
    
    let leastWaitTime = 0.15
    var showNameFlag = false
    var animationFlag = false
    var gradationFrame = CGRect(x: 0, y: 0, width: 0, height: 85)
    var noItemText = ""
    
    var albumFilterStar0 = true
    var albumFilterStar1 = true
    var albumFilterStar2 = true
    var albumFilterStar3 = true
    var albumFilterLong = true
    var albumFilterShort = true
    var albumFilterHot = true
    var albumFilterStyleNone = true
    var albumFilterBuild = true
    var albumFilterStir = true
    var albumFilterShake = true
    var albumFilterBlend = true
    var albumFilterOthers = true
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setFilterUserDefaults()
        self.reloadRecipeList()

        collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")

        recipeNameBarButton.image = UIImage(named: "album-name-off")
        albumFilterBarButton.image = UIImage(named: "album-filter-off")
    }
    
    private func setFilterUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "album-filter-star0")
        defaults.set(true, forKey: "album-filter-star1")
        defaults.set(true, forKey: "album-filter-star2")
        defaults.set(true, forKey: "album-filter-star3")
        defaults.set(true, forKey: "album-filter-long")
        defaults.set(true, forKey: "album-filter-short")
        defaults.set(true, forKey: "album-filter-hot")
        defaults.set(true, forKey: "album-filter-stylenone")
        defaults.set(true, forKey: "album-filter-build")
        defaults.set(true, forKey: "album-filter-stir")
        defaults.set(true, forKey: "album-filter-shake")
        defaults.set(true, forKey: "album-filter-blend")
        defaults.set(true, forKey: "album-filter-others")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noItemText = ""
        setCollectionBackgroundView()

        let realm = try! Realm()
        for i in (0..<self.recipeBasicList.count).reversed() {
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: self.recipeBasicList[i].id)
            if let r = recipe{
                if r.imageFileName == nil{
                    self.recipeBasicList.remove(at: i)
                }
            }else{
                self.recipeBasicList.remove(at: i)
            }
        }
        
        let recipeList = realm.objects(Recipe.self).filter("imageFileName != nil")
        for recipe in recipeList{
            var newPhotoFlag = true
            for i in (0..<self.recipeBasicList.count).reversed() {
                if recipe.id == self.recipeBasicList[i].id{
                    newPhotoFlag = false
                    self.recipeBasicList.remove(at: i)
                    self.recipeBasicList.insert(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, imageFileName: recipe.imageFileName), at: i)
                    break
                }
            }
            if newPhotoFlag{
                self.recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, imageFileName: recipe.imageFileName))
            }
        }

        setupVC()
    }
    
    private func setupVC(){
        self.collectionView.backgroundColor = Style.basicBackgroundColor
        self.collectionView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.collectionView.refreshHeader.removeRefreshHeader()
        self.collectionView.refreshHeader.addPullToRefresh {
            [unowned self] in
            self.refresh()
            self.collectionView.refreshHeader.stopPullToRefresh()
        }

        self.loadFilterUserDefaults()
        self.setFilterImageState()
        self.filterRecipeBasicList()
        self.collectionView.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.filteredRecipeBasicList.count) + "/" + String(self.recipeBasicList.count) + ")"
        if self.recipeBasicList.count == 0{
            self.noItemText = "写真が登録されたレシピはありません"
        }else{
            self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
        }
        self.setCollectionBackgroundView()
    }
    
    private func loadFilterUserDefaults(){
        let defaults = UserDefaults.standard
        albumFilterStar0 = defaults.bool(forKey: "album-filter-star0")
        albumFilterStar1 = defaults.bool(forKey: "album-filter-star1")
        albumFilterStar2 = defaults.bool(forKey: "album-filter-star2")
        albumFilterStar3 = defaults.bool(forKey: "album-filter-star3")
        albumFilterLong = defaults.bool(forKey: "album-filter-long")
        albumFilterShort = defaults.bool(forKey: "album-filter-short")
        albumFilterHot = defaults.bool(forKey: "album-filter-hot")
        albumFilterStyleNone = defaults.bool(forKey: "album-filter-stylenone")
        albumFilterBuild = defaults.bool(forKey: "album-filter-build")
        albumFilterStir = defaults.bool(forKey: "album-filter-stir")
        albumFilterShake = defaults.bool(forKey: "album-filter-shake")
        albumFilterBlend = defaults.bool(forKey: "album-filter-blend")
        albumFilterOthers = defaults.bool(forKey: "album-filter-others")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.flashScrollIndicators()
    }
    
    func reloadRecipeList(){
        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).filter("imageFileName != nil")
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, imageFileName: recipe.imageFileName))
        }
        recipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    func setCollectionBackgroundView(){
        if self.filteredRecipeBasicList.count == 0{
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width, height: self.collectionView.bounds.size.height))
            noDataLabel.text = noItemText
            noDataLabel.numberOfLines = 0
            noDataLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
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
    
    private func setFilterImageState(){
        if albumFilterStar0 && albumFilterStar1 && albumFilterStar2 && albumFilterStar3 &&
            albumFilterLong && albumFilterShort && albumFilterHot && albumFilterStyleNone &&
            albumFilterBuild && albumFilterStir && albumFilterShake && albumFilterBlend && albumFilterOthers {
            albumFilterBarButton.image = UIImage(named: "album-filter-off")
        }else{
            albumFilterBarButton.image = UIImage(named: "album-filter-on")
        }
    }
    
    private func filterRecipeBasicList(){
        filteredRecipeBasicList = recipeBasicList
        
        if albumFilterStar0 == false{
            filteredRecipeBasicList.removeAll{ $0.favorites == 0 }
        }
        if albumFilterStar1 == false{
            filteredRecipeBasicList.removeAll{ $0.favorites == 1 }
        }
        if albumFilterStar2 == false{
            filteredRecipeBasicList.removeAll{ $0.favorites == 2 }
        }
        if albumFilterStar3 == false{
            filteredRecipeBasicList.removeAll{ $0.favorites == 3 }
        }
        if albumFilterLong == false{
            filteredRecipeBasicList.removeAll{ $0.style == 0 }
        }
        if albumFilterShort == false{
            filteredRecipeBasicList.removeAll{ $0.style == 1 }
        }
        if albumFilterHot == false{
            filteredRecipeBasicList.removeAll{ $0.style == 2 }
        }
        if albumFilterStyleNone == false{
            filteredRecipeBasicList.removeAll{ $0.style == 3 }
        }
        if albumFilterBuild == false{
            filteredRecipeBasicList.removeAll{ $0.method == 0 }
        }
        if albumFilterStir == false{
            filteredRecipeBasicList.removeAll{ $0.method == 1 }
        }
        if albumFilterShake == false{
            filteredRecipeBasicList.removeAll{ $0.method == 2 }
        }
        if albumFilterBlend == false{
            filteredRecipeBasicList.removeAll{ $0.method == 3 }
        }
        if albumFilterOthers == false{
            filteredRecipeBasicList.removeAll{ $0.method == 4 }
        }
    }
    
    private func refresh(){
        recipeBasicList.shuffle()
        filterRecipeBasicList()
        self.collectionView.reloadData()
        self.navigationItem.title = "アルバム(" + String(self.filteredRecipeBasicList.count) + "/" + String(self.recipeBasicList.count) + ")"
        if self.recipeBasicList.count == 0{
            self.noItemText = "写真が登録されたレシピはありません"
        }else{
            self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
        }
        self.setCollectionBackgroundView()
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
        return filteredRecipeBasicList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let realm = try! Realm()
        if indexPath.row < filteredRecipeBasicList.count{
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: filteredRecipeBasicList[indexPath.row].id)
            if let r = recipe {
                performSegue(withIdentifier: "RecipeTapped", sender: r.id)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath as IndexPath) as! AlbumCollectionViewCell

        if let image = ImageUtil.load(imageFileName: filteredRecipeBasicList[indexPath.row].imageFileName, useCache: true) {
            cell.photo.image = image
            cell.recipeName.text = filteredRecipeBasicList[indexPath.row].name
            cell.recipeName.textColor = FlatColor.white
            cell.recipeName.backgroundColor = UIColor.clear
            
            // 重複して何重もグラデーションを付けないように、既存のグラデーションを取り除く
            cell.recipeNameBackgroundView.layer.sublayers?.forEach {
                if $0.isKind(of: CustomCAGradientLayer.self){
                    $0.removeFromSuperlayer()
                }
            }
            
            // 新規にアルバム画面を開き、すぐに名前を表示した状態で下にスクロールするとグラデーションがずれている問題への対応
            // CAGradientLayerのframeはAutolayout後でないと正確に決まらないため
            if cell.recipeNameBackgroundView.bounds.width > gradationFrame.width{
                gradationFrame = CGRect(x: 0, y: 0, width: cell.recipeNameBackgroundView.bounds.width, height: gradationFrame.height)
            }
            if cell.recipeNameBackgroundView.bounds.height > gradationFrame.height{
                gradationFrame = CGRect(x: 0, y: 0, width: gradationFrame.width, height: cell.recipeNameBackgroundView.bounds.height)
            }
            
            let gradient = CustomCAGradientLayer()
            gradient.frame = gradationFrame
            gradient.colors = [UIColor(white: 0.0, alpha: 0.0).cgColor, UIColor(white: 0.0, alpha: 0.8).cgColor]
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
        }else{
            if Style.isDark{
                cell.photo.image = UIImage(named: "no-photo-dark")
            }else{
                cell.photo.image = UIImage(named: "no-photo")
            }
            cell.recipeName.alpha = 0.0
            cell.recipeNameBackgroundView.alpha = 0.0
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - IBAction
    @IBAction func nameButtonTapped(_ sender: UIBarButtonItem) {
        if showNameFlag {
            recipeNameBarButton.image = UIImage(named: "album-name-off")
            showNameFlag = false
            animationFlag = true
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            animationFlag = false
        }else{
            recipeNameBarButton.image = UIImage(named: "album-name-on")
            showNameFlag = true
            animationFlag = true
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            animationFlag = false
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AlbumFilter", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "AlbumFilterModalNavigationController") as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        let vc = nvc.visibleViewController as! AlbumFilterViewController
        vc.onDoneBlock = {
            self.setupVC()
        }
        vc.interactor = interactor
        vc.userDefaultsPrefix = "album-"
        present(nvc, animated: true)
    }
    
    @IBAction func orderButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "レシピを名前順に並べ替える", style: .default, handler: {action in
            self.reloadRecipeList()
            self.filterRecipeBasicList()
            self.collectionView.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.filteredRecipeBasicList.count) + "/" + String(self.recipeBasicList.count) + ")"
            if self.recipeBasicList.count == 0{
                self.noItemText = "写真が登録されたレシピはありません"
            }else{
                self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
            }
            self.setCollectionBackgroundView()
        }))
        alertView.addAction(UIAlertAction(title: "表示順をシャッフルする", style: .default, handler: {action in
            self.recipeBasicList.shuffle()
            self.filterRecipeBasicList()
            self.collectionView.reloadData()
            self.navigationItem.title = "アルバム(" + String(self.filteredRecipeBasicList.count) + "/" + String(self.recipeBasicList.count) + ")"
            if self.recipeBasicList.count == 0{
                self.noItemText = "写真が登録されたレシピはありません"
            }else{
                self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
            }
            self.setCollectionBackgroundView()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissModalAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
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
