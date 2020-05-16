//
//  AlbumCollectionViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class AlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UICollectionViewDataSourcePrefetching, ScrollableToTop {

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
    
    var selectedRecipeId: String? = nil
    var highlightIndexPath : IndexPath? = nil
    var gradationFrame = CGRect(x: 0, y: 0, width: 0, height: 85)
    var itemMoveDistination = Array<Int>()

    let leastWaitTime = 0.15
    var showNameFlag = false
    var animationFlag = false
    var isItemsMoving = false
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
    var albumFilterNonAlcohol = true
    var albumFilterWeak = true
    var albumFilterMedium = true
    var albumFilterStrong = true
    var albumFilterStrengthNone = true

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delaysContentTouches = false

        setFilterUserDefaults()
        reloadRecipeBasicList()

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
        defaults.set(true, forKey: GlobalConstants.AlbumFilterNonAlcoholKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterWeakKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterMediumKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStrongKey)
        defaults.set(true, forKey: GlobalConstants.AlbumFilterStrengthNoneKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                    self.recipeBasicList.insert(RecipeBasic(id: recipe.id, name: recipe.recipeName, nameYomi: recipe.recipeNameYomi, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName), at: i)
                    break
                }
            }
            if newPhotoFlag{
                self.recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, nameYomi: recipe.recipeNameYomi, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName))
            }
        }

        collectionView.backgroundColor = UchicockStyle.basicBackgroundColor
        collectionView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        collectionView.refreshHeader.removeRefreshHeader()
        collectionView.refreshHeader.addPullToRefresh {
            [unowned self] in
            self.refresh(shouldShuffle: true)
            self.collectionView.refreshHeader.stopPullToRefresh()
        }

        setupVC()
        needsLayout = true
    }
    
    private func setupVC(){
        loadSearchUserDefaults()
        setFilterImageState()
        filterRecipeBasicList()
        collectionView.reloadData()
        updateButton()
        setCollectionBackgroundView()
    }
    
    private func updateButton(){
        self.navigationItem.title = "アルバム(" + String(self.filteredRecipeBasicList.count) + "/" + String(self.recipeBasicList.count) + ")"
        if self.recipeBasicList.count == 0{
            self.recipeNameBarButton.isEnabled = false
            self.albumFilterBarButton.isEnabled = false
            self.orderBarButton.isEnabled = false
        }else{
            self.recipeNameBarButton.isEnabled = true
            self.albumFilterBarButton.isEnabled = true
            self.orderBarButton.isEnabled = true
        }
    }
    
    private func loadSearchUserDefaults(){
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
        albumFilterNonAlcohol = defaults.bool(forKey: GlobalConstants.AlbumFilterNonAlcoholKey)
        albumFilterWeak = defaults.bool(forKey: GlobalConstants.AlbumFilterWeakKey)
        albumFilterMedium = defaults.bool(forKey: GlobalConstants.AlbumFilterMediumKey)
        albumFilterStrong = defaults.bool(forKey: GlobalConstants.AlbumFilterStrongKey)
        albumFilterStrengthNone = defaults.bool(forKey: GlobalConstants.AlbumFilterStrengthNoneKey)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        needsLayout = true
        gradationFrame = CGRect(x: 0, y: 0, width: albumCellWidth(of: size.width), height: 85)
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionBackgroundView() // 画面サイズ変更時に位置を再計算
        
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
        
        if highlightIndexPath != nil{
            if let cell = self.collectionView.cellForItem(at: self.highlightIndexPath!) as? AlbumCollectionViewCell {
                UIView.animate(withDuration: 0.4, animations: {
                    cell.highlightView.backgroundColor = UIColor.clear
                }, completion: nil)
            }
        }
        highlightIndexPath = nil
        selectedRecipeId = nil
    }
    
    func scrollToTop() {
        collectionView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).filter("imageFileName != nil")
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, nameYomi: recipe.recipeNameYomi, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName))
        }
        recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
    }
    
    private func setCollectionBackgroundView(){
        if self.filteredRecipeBasicList.count == 0{
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width, height: self.collectionView.bounds.size.height))
            if recipeBasicList.count == 0{
                noDataLabel.text = "写真が登録されたレシピはありません\n\nカクテルを作ったら、\nレシピ画面の「編集」から\n写真を登録してみよう！"
            }else{
                noDataLabel.text = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
            }
            noDataLabel.numberOfLines = 0
            noDataLabel.textColor = UchicockStyle.labelTextColorLight
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
            albumFilterBuild && albumFilterStir && albumFilterShake && albumFilterBlend && albumFilterOthers &&
            albumFilterNonAlcohol && albumFilterWeak && albumFilterMedium && albumFilterStrong && albumFilterStrengthNone{
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
        if albumFilterNonAlcohol == false{
            filteredRecipeBasicList.removeAll{ $0.strength == 0 }
        }
        if albumFilterWeak == false{
            filteredRecipeBasicList.removeAll{ $0.strength == 1 }
        }
        if albumFilterMedium == false{
            filteredRecipeBasicList.removeAll{ $0.strength == 2 }
        }
        if albumFilterStrong == false{
            filteredRecipeBasicList.removeAll{ $0.strength == 3 }
        }
        if albumFilterStrengthNone == false{
            filteredRecipeBasicList.removeAll{ $0.strength == 4 }
        }
    }
    
    private func refresh(shouldShuffle: Bool){
        var recipeIdList = Array<String>()
        for frb in filteredRecipeBasicList{
            recipeIdList.append(frb.id)
        }
        
        if shouldShuffle{
            recipeBasicList.shuffle()
        }else{
            recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        }
        filterRecipeBasicList()
        
        itemMoveDistination.removeAll()
        for rid in recipeIdList{
            for i in 0 ..< filteredRecipeBasicList.count{
                if rid == filteredRecipeBasicList[i].id{
                    itemMoveDistination.append(i)
                    break
                }
            }
        }
        isItemsMoving = true
        collectionView.performBatchUpdates({
            for i in 0 ..< itemMoveDistination.count{
                collectionView.moveItem(at: IndexPath(row: i, section: 0), to: IndexPath(row: itemMoveDistination[i], section: 0))
            }
        }, completion: { _ in
            self.isItemsMoving = false
        })
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
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            }
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
            cell.highlightView.backgroundColor = UIColor.clear
        }
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
            
            if selectedRecipeId != nil && filteredRecipeBasicList[indexPath.row].id == selectedRecipeId!{
                if UchicockStyle.isBackgroundDark{
                    cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
                }else{
                    cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                }
                highlightIndexPath = indexPath
            }else{
                cell.highlightView.backgroundColor = UIColor.clear
            }
            
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
            cell.photo.tintColor = UchicockStyle.noPhotoColor
            cell.recipeName.alpha = 0.0
            cell.recipeNameBackgroundView.alpha = 0.0
        }
        return cell
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            let imageFileName = self.filteredRecipeBasicList[indexPath.row].imageFileName
            DispatchQueue.global(qos: .userInteractive).async{
                ImageUtil.saveToCache(imageFileName: imageFileName)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func nameButtonTapped(_ sender: UIBarButtonItem) {
        if isItemsMoving == false{
            if showNameFlag {
                recipeNameBarButton.image = UIImage(named: "navigation-album-name-off")
                showNameFlag = false
                animationFlag = true
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
                animationFlag = false
            }else{
                recipeNameBarButton.image = UIImage(named: "navigation-album-name-on")
                showNameFlag = true
                animationFlag = true
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
                animationFlag = false
            }
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AlbumFilter", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "AlbumFilterModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! AlbumFilterViewController
        vc.onDoneBlock = {
            self.setupVC()
        }
        vc.userDefaultsPrefix = "album-"
        vc.recipeBasicListForFilterModal = self.recipeBasicList

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
            self.refresh(shouldShuffle: false)
        }))
        
        alertView.addAction(UIAlertAction(title: "表示順をシャッフルする", style: .default, handler: {action in
            self.refresh(shouldShuffle: true)
        }))
        
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
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
                selectedRecipeId = id
                vc.recipeId = id
            }
        }
    }
}
