//
//  AlbumCollectionViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UICollectionViewDataSourcePrefetching {

    @IBOutlet weak var recipeNameBarButton: UIBarButtonItem!
    @IBOutlet weak var albumFilterBarButton: UIBarButtonItem!
    @IBOutlet weak var orderBarButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!{
        didSet {
            flowLayout.sectionInsetReference = .fromSafeArea
        }
    }
    
    var recipeBasicList = Array<RecipeBasic>()
    var filteredRecipeBasicList = Array<RecipeBasic>()
    
    let leastWaitTime = 0.15
    var showNameFlag = false
    var animationFlag = false
    var gradationFrame = CGRect(x: 0, y: 0, width: 0, height: 85)
    var noItemText = ""
    var needsLayout = false

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
        
        self.collectionView.prefetchDataSource = self

        self.setFilterUserDefaults()
        self.reloadRecipeList()

        collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")

        recipeNameBarButton.image = UIImage(named: "navigation-album-name-off")
        albumFilterBarButton.image = UIImage(named: "navigation-album-filter-off")
    }
    
    private func setFilterUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStar0Key)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStar1Key)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStar2Key)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStar3Key)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterLongKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterShortKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterHotKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStyleNoneKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterBuildKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStirKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterShakeKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterBlendKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterOthersKey)
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
            self.recipeNameBarButton.isEnabled = false
            self.albumFilterBarButton.isEnabled = false
            self.orderBarButton.isEnabled = false
        }else{
            self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
            self.recipeNameBarButton.isEnabled = true
            self.albumFilterBarButton.isEnabled = true
            self.orderBarButton.isEnabled = true
        }
        self.setCollectionBackgroundView()
    }
    
    private func loadFilterUserDefaults(){
        let defaults = UserDefaults.standard
        albumFilterStar0 = defaults.bool(forKey: GlobalConstants.AlbumFilterStar0Key)
        albumFilterStar1 = defaults.bool(forKey: GlobalConstants.AlbumFilterStar1Key)
        albumFilterStar2 = defaults.bool(forKey: GlobalConstants.AlbumFilterStar2Key)
        albumFilterStar3 = defaults.bool(forKey: GlobalConstants.AlbumFilterStar3Key)
        albumFilterLong = defaults.bool(forKey: GlobalConstants.AlbumFilterLongKey)
        albumFilterShort = defaults.bool(forKey: GlobalConstants.AlbumFilterShortKey)
        albumFilterHot = defaults.bool(forKey: GlobalConstants.AlbumFilterHotKey)
        albumFilterStyleNone = defaults.bool(forKey: GlobalConstants.AlbumFilterStyleNoneKey)
        albumFilterBuild = defaults.bool(forKey: GlobalConstants.AlbumFilterBuildKey)
        albumFilterStir = defaults.bool(forKey: GlobalConstants.AlbumFilterStirKey)
        albumFilterShake = defaults.bool(forKey: GlobalConstants.AlbumFilterShakeKey)
        albumFilterBlend = defaults.bool(forKey: GlobalConstants.AlbumFilterBlendKey)
        albumFilterOthers = defaults.bool(forKey: GlobalConstants.AlbumFilterOthersKey)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        needsLayout = true
        gradationFrame = CGRect(x: 0, y: 0, width: albumCellWidth(of: size.width), height: 85)
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setCollectionBackgroundView() // 画面サイズ変更時に位置を再計算
        
        // iPhone X系（横にすると横にSafe Areaがある端末）において、
        // 横向きでアルバムを表示（3列）し、詳細へ遷移 -> 縦向きにする
        // -> アルバムに戻ると2列になるはずが1列になっている問題へのワークアラウンド
        // needsLayoutフラグを利用して無限ループを回避
        if needsLayout{
            guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }
            flowLayout.invalidateLayout()
            collectionView.setNeedsLayout()
            needsLayout = false
        }
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
            albumFilterBarButton.image = UIImage(named: "navigation-album-filter-off")
        }else{
            albumFilterBarButton.image = UIImage(named: "navigation-album-filter-on")
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
            self.recipeNameBarButton.isEnabled = false
            self.albumFilterBarButton.isEnabled = false
            self.orderBarButton.isEnabled = false
        }else{
            self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
            self.recipeNameBarButton.isEnabled = true
            self.albumFilterBarButton.isEnabled = true
            self.orderBarButton.isEnabled = true
        }
        self.setCollectionBackgroundView()
    }
    
    // MARK: - UICollectionView
    private func albumCellWidth(of windowWidth: CGFloat) -> CGFloat {
        let leftPadding = (UIApplication.shared.keyWindow?.safeAreaInsets.left)!
        let rightPadding = (UIApplication.shared.keyWindow?.safeAreaInsets.right)!
        let safeAreaWidth = windowWidth - leftPadding - rightPadding
        
        if safeAreaWidth > 950{
            let size = (safeAreaWidth - 12) / 4
            return CGFloat(size)
        }else if safeAreaWidth > 500{
            let size = (safeAreaWidth - 8) / 3
            return CGFloat(size)
        }else{
            let size = (safeAreaWidth - 4) / 2
            return CGFloat(size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = albumCellWidth(of: (UIApplication.shared.keyWindow?.bounds.width)!)
        return CGSize(width: cellWidth, height: cellWidth)
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
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let previewProvider: () -> RecipeDetailTableViewController? = {
                let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                vc.fromContextualMenu = true
                vc.recipeId = self.filteredRecipeBasicList[indexPath.row].id
                return vc
            }
        return UIContextMenuConfiguration(identifier: self.filteredRecipeBasicList[indexPath.row].id as NSCopying, previewProvider: previewProvider, actionProvider: nil)
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let recipeId = configuration.identifier as? String else { return }

        animator.addCompletion {
            self.performSegue(withIdentifier: "RecipeTapped", sender: recipeId)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath as IndexPath) as! AlbumCollectionViewCell

        if let image = ImageUtil.loadImageOf(recipeId: filteredRecipeBasicList[indexPath.row].id, forList: true) {
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
            let margin = -albumCellWidth(of: (UIApplication.shared.keyWindow?.bounds.width)!) * 0.2
            cell.photo.image = UIImage(named: "tabbar-recipe")?.withAlignmentRectInsets(UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
            if Style.isDark{
                cell.photo.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            }else{
                cell.photo.tintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            }
            cell.recipeName.alpha = 0.0
            cell.recipeNameBackgroundView.alpha = 0.0
        }
        return cell
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            DispatchQueue.global(qos: .userInteractive).async{
                ImageUtil.saveToCache(imageFileName: self.filteredRecipeBasicList[indexPath.row].imageFileName)
            }
        }
        
    }
    
    // MARK: - IBAction
    @IBAction func nameButtonTapped(_ sender: UIBarButtonItem) {
        if showNameFlag {
            recipeNameBarButton.image = UIImage(named: "navigation-album-name-off")
            showNameFlag = false
            animationFlag = true
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            animationFlag = false
        }else{
            recipeNameBarButton.image = UIImage(named: "navigation-album-name-on")
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
        let vc = nvc.visibleViewController as! AlbumFilterViewController
        vc.onDoneBlock = {
            self.setupVC()
        }
        vc.userDefaultsPrefix = "album-"

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
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
                self.recipeNameBarButton.isEnabled = false
                self.albumFilterBarButton.isEnabled = false
                self.orderBarButton.isEnabled = false
            }else{
                self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
                self.recipeNameBarButton.isEnabled = true
                self.albumFilterBarButton.isEnabled = true
                self.orderBarButton.isEnabled = true
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
                self.recipeNameBarButton.isEnabled = false
                self.albumFilterBarButton.isEnabled = false
                self.orderBarButton.isEnabled = false
            }else{
                self.noItemText = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
                self.recipeNameBarButton.isEnabled = true
                self.albumFilterBarButton.isEnabled = true
                self.orderBarButton.isEnabled = true
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
