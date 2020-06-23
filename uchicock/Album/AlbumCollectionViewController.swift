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
    
    var recipeBasicList = Array<RecipeBasic>()
    var filteredRecipeBasicList = Array<RecipeBasic>()
    
    var selectedRecipeId: String? = nil
    var highlightingIndexPath : IndexPath? = nil
    var gradationFrame = CGRect(x: 0, y: 0, width: 0, height: 85)

    var shouldShowRecipeName = false
    var shouldAnimate = false
    var areItemsMoving = false

    var albumFilterStar: [Int] = []
    var albumFilterStyle: [Int] = []
    var albumFilterMethod: [Int] = []
    var albumFilterStrength: [Int] = []

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delaysContentTouches = false
        collectionView.contentInsetAdjustmentBehavior = .always
        
        setFilterUserDefaults()
        initiateRecipeBasicList()
        makeFilterFromSearchUserDefaults()

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
        for i in (0..<recipeBasicList.count).reversed() {
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[i].id)
            if recipe?.imageFileName == nil{
                recipeBasicList.remove(at: i)
            }
        }
        
        let recipeList = realm.objects(Recipe.self).filter("imageFileName != nil")
        for recipe in recipeList{
            var isNewPhoto = true
            for i in (0..<recipeBasicList.count).reversed() where recipe.id == recipeBasicList[i].id{
                isNewPhoto = false
                recipeBasicList[i] = RecipeBasic(
                    id: recipe.id,
                    name: recipe.recipeName,
                    nameYomi: recipe.recipeNameYomi,
                    katakanaLowercasedNameForSearch: "",
                    shortageNum: -1,
                    lastViewDate: nil,
                    favorites: recipe.favorites,
                    style: recipe.style,
                    method: recipe.method,
                    strength: recipe.strength,
                    madeNum: -1,
                    imageFileName: recipe.imageFileName
                )
                break
            }
            if isNewPhoto{
                recipeBasicList.append(RecipeBasic(
                    id: recipe.id,
                    name: recipe.recipeName,
                    nameYomi: recipe.recipeNameYomi,
                    katakanaLowercasedNameForSearch: "",
                    shortageNum: -1,
                    lastViewDate: nil,
                    favorites: recipe.favorites,
                    style: recipe.style,
                    method: recipe.method,
                    strength: recipe.strength,
                    madeNum: -1,
                    imageFileName: recipe.imageFileName
                ))
            }
        }

        filterRecipeBasicList()
        collectionView.reloadData()
        updateNavigationBar()
        setCollectionBackgroundView()

        collectionView.backgroundColor = UchicockStyle.basicBackgroundColor
        collectionView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gradationFrame = CGRect(x: 0, y: 0, width: albumCellWidth(of: size.width), height: gradationFrame.height)
        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.flashScrollIndicators()
        
        collectionView.refreshHeader.removeRefreshHeader()
        collectionView.refreshHeader.addPullToRefresh {
            [unowned self] in
            self.refresh(shouldShuffle: true)
            self.collectionView.refreshHeader.stopPullToRefresh()
        }

        if highlightingIndexPath != nil{
            if let cell = self.collectionView.cellForItem(at: self.highlightingIndexPath!) as? AlbumCollectionViewCell {
                UIView.animate(withDuration: 0.4, animations: {
                    cell.highlightView.backgroundColor = UIColor.clear
                }, completion: nil)
            }
        }
        highlightingIndexPath = nil
        selectedRecipeId = nil
    }
    
    // MARK: - Logic functions
    private func initiateRecipeBasicList(){
        recipeBasicList.removeAll()
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).filter("imageFileName != nil")
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(
                id: recipe.id,
                name: recipe.recipeName,
                nameYomi: recipe.recipeNameYomi,
                katakanaLowercasedNameForSearch: "",
                shortageNum: -1,
                lastViewDate: nil,
                favorites: recipe.favorites,
                style: recipe.style,
                method: recipe.method,
                strength: recipe.strength,
                madeNum: -1,
                imageFileName: recipe.imageFileName
            ))
        }
        recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
    }
    
    private func makeFilterFromSearchUserDefaults(){
        albumFilterStar.removeAll()
        albumFilterStyle.removeAll()
        albumFilterMethod.removeAll()
        albumFilterStrength.removeAll()

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStar0Key) { albumFilterStar.append(0) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStar1Key) { albumFilterStar.append(1) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStar2Key) { albumFilterStar.append(2) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStar3Key) { albumFilterStar.append(3) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterLongKey) { albumFilterStyle.append(0) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterShortKey) { albumFilterStyle.append(1) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterHotKey) { albumFilterStyle.append(2) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStyleNoneKey) { albumFilterStyle.append(3) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterBuildKey) { albumFilterMethod.append(0) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStirKey) { albumFilterMethod.append(1) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterShakeKey) { albumFilterMethod.append(2) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterBlendKey) { albumFilterMethod.append(3) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterOthersKey) { albumFilterMethod.append(4) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterNonAlcoholKey) { albumFilterStrength.append(0) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterWeakKey) { albumFilterStrength.append(1) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterMediumKey) { albumFilterStrength.append(2) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStrongKey) { albumFilterStrength.append(3) }
        if defaults.bool(forKey: GlobalConstants.AlbumFilterStrengthNoneKey) { albumFilterStrength.append(4) }
        
        if ([0,1,2,3].allSatisfy(albumFilterStar.contains) && [0,1,2,3].allSatisfy(albumFilterStyle.contains) &&
            [0,1,2,3,4].allSatisfy(albumFilterMethod.contains) && [0,1,2,3,4].allSatisfy(albumFilterStrength.contains)) {
            albumFilterBarButton.image = UIImage(named: "navigation-album-filter-off")
        }else{
            albumFilterBarButton.image = UIImage(named: "navigation-album-filter-on")
        }
    }
    
    private func filterRecipeBasicList(){
        filteredRecipeBasicList.removeAll()
        for recipeBasic in recipeBasicList {
            if albumFilterStar.contains(recipeBasic.favorites) && albumFilterStyle.contains(recipeBasic.style) &&
                albumFilterMethod.contains(recipeBasic.method) && albumFilterStrength.contains(recipeBasic.strength){
                filteredRecipeBasicList.append(recipeBasic)
            }
        }
    }
    
    private func updateNavigationBar(){
        self.navigationItem.title = "アルバム(" + String(filteredRecipeBasicList.count) + "/" + String(recipeBasicList.count) + ")"
        if recipeBasicList.count == 0{
            self.recipeNameBarButton.isEnabled = false
            self.albumFilterBarButton.isEnabled = false
            self.orderBarButton.isEnabled = false
        }else{
            self.recipeNameBarButton.isEnabled = true
            self.albumFilterBarButton.isEnabled = true
            self.orderBarButton.isEnabled = true
        }
    }
    
    private func setCollectionBackgroundView(){
        guard filteredRecipeBasicList.count == 0 else {
            collectionView.backgroundView = nil
            collectionView.isScrollEnabled = true
            return
        }

        collectionView.backgroundView = UIView()
        collectionView.isScrollEnabled = false

        let noDataLabel = UILabel()
        if recipeBasicList.count == 0{
            noDataLabel.text = "写真が登録されたレシピはありません\n\nカクテルを作ったら、\nレシピ画面の「編集」から\n写真を登録してみよう！"
        }else{
            noDataLabel.text = "条件にあてはまるレシピはありません\n左上の絞り込みボタンで条件変更してください"
        }
        noDataLabel.numberOfLines = 0
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
        collectionView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: collectionView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: collectionView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
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
        
        var itemMoveDistination = Array<Int>()
        for rid in recipeIdList{
            for i in 0 ..< filteredRecipeBasicList.count where rid == filteredRecipeBasicList[i].id{
                itemMoveDistination.append(i)
                break
            }
        }
        areItemsMoving = true
        collectionView.performBatchUpdates({
            for i in 0 ..< itemMoveDistination.count{
                collectionView.moveItem(at: IndexPath(row: i, section: 0), to: IndexPath(row: itemMoveDistination[i], section: 0))
            }
        }, completion: { _ in
            self.areItemsMoving = false
        })
    }
    
    // MARK: - ScrollableToTop
    func scrollToTop() {
        collectionView?.setContentOffset(CGPoint.zero, animated: true)
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
                cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
            }
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
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
    override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let recipeId = configuration.identifier as? String else { return nil }
        var row: Int? = nil
        for i in 0 ..< filteredRecipeBasicList.count where filteredRecipeBasicList[i].id == recipeId {
            row = i
            break
        }
        guard row != nil else { return nil }
        let cell = collectionView.cellForItem(at: IndexPath(row: row!, section: 0)) as! AlbumCollectionViewCell
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let recipeId = configuration.identifier as? String else { return nil }
        var row: Int? = nil
        for i in 0 ..< filteredRecipeBasicList.count where filteredRecipeBasicList[i].id == recipeId {
            row = i
            break
        }
        guard row != nil else { return nil }
        let cell = collectionView.cellForItem(at: IndexPath(row: row!, section: 0)) as! AlbumCollectionViewCell
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
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

        guard let image = ImageUtil.loadImageOf(recipeId: filteredRecipeBasicList[indexPath.row].id, imageFileName: filteredRecipeBasicList[indexPath.row].imageFileName, forList: true) else{
            let margin = -albumCellWidth(of: (UIApplication.shared.keyWindow?.bounds.width)!) * 0.2
            cell.photo.image = UIImage(named: "tabbar-recipe")?.withAlignmentRectInsets(UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
            cell.photo.tintColor = UchicockStyle.noPhotoColor
            cell.recipeName.alpha = 0.0
            cell.recipeNameBackgroundView.alpha = 0.0
            return cell
        }

        cell.photo.image = image
        cell.recipeName.text = filteredRecipeBasicList[indexPath.row].name
        cell.recipeName.textColor = FlatColor.white
        cell.recipeName.backgroundColor = UIColor.clear
            
        if selectedRecipeId != nil && filteredRecipeBasicList[indexPath.row].id == selectedRecipeId!{
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
            }
            highlightingIndexPath = indexPath
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
            
        let gradient = CustomCAGradientLayer()
        gradient.frame = gradationFrame
        gradient.colors = [UIColor(white: 0.0, alpha: 0.0).cgColor, UIColor(white: 0.0, alpha: 0.8).cgColor]
        cell.recipeNameBackgroundView.layer.insertSublayer(gradient, at: 0)
            
        let alpha: CGFloat = shouldShowRecipeName ? 1.0 : 0.0
        if shouldAnimate{
            UIView.animate(withDuration: 0.2, animations: {
                cell.recipeName.alpha = alpha
                cell.recipeNameBackgroundView.alpha = alpha
            }, completion: nil)
        }else{
            cell.recipeName.alpha = alpha
            cell.recipeNameBackgroundView.alpha = alpha
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
        guard areItemsMoving == false else { return }

        shouldShowRecipeName.toggle()
        if shouldShowRecipeName {
            recipeNameBarButton.image = UIImage(named: "navigation-album-name-on")
        }else{
            recipeNameBarButton.image = UIImage(named: "navigation-album-name-off")
        }
        shouldAnimate = true
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        shouldAnimate = false
    }
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AlbumFilter", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "AlbumFilterModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! AlbumFilterViewController
        vc.onDoneBlock = {
            self.makeFilterFromSearchUserDefaults()
            self.filterRecipeBasicList()
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.updateNavigationBar()
            self.setCollectionBackgroundView()
        }
        vc.udPrefix = "album-"
        vc.recipeBasicList = recipeBasicList

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
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let nameOrderAction = UIAlertAction(title: "レシピを名前順に並べ替える", style: .default){action in
            self.refresh(shouldShuffle: false)
        }
        if #available(iOS 13.0, *){ nameOrderAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(nameOrderAction)
        
        let shuffleAction = UIAlertAction(title: "表示順をシャッフルする", style: .default){action in
            self.refresh(shouldShuffle: true)
        }
        if #available(iOS 13.0, *){ shuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(shuffleAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        alertView.popoverPresentationController?.barButtonItem = sender
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
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
