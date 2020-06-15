//
//  IngredientRecommendTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientRecommendTableViewController: UITableViewController {

    @IBOutlet weak var descriptionLabel: CustomLabel!
    
    var ingredientList: Results<Ingredient>?
    var stockingIngredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    let selectedCellBackgroundView = UIView()
    var selectedRecommendIngredientId: String? = nil
    var isContributionMode = true
    
    var interactor: Interactor?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock: ((String?) -> Void) = {ingredientId in}
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }
        
        tableView.register(UINib(nibName: "IngredientRecommendTableViewCell", bundle: nil), forCellReuseIdentifier: "IngredientRecommendCell")
        
        createIngredientBasicList()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        if isContributionMode {
            descriptionLabel.text = "以下の材料を入手すると、より多くのレシピを作れるようになるのでおすすめです！"
        }else{
            if ingredientBasicList.count == 0{
                descriptionLabel.text = "おすすめできる材料はありません..."
            }else{
                if stockingIngredientList != nil {
                    if stockingIngredientList!.count <= 10 {
                        descriptionLabel.text = "まだあまり材料を持っていないようですね。\n\nまずは多くのレシピに使われている以下の材料から始めるのはいかがでしょう？"
                    }else{
                        descriptionLabel.text = "以下の材料は多くのレシピで使われているのでおすすめです！"
                    }
                }else{
                    descriptionLabel.text = "以下の材料は多くのレシピで使われているのでおすすめです！"
                }
            }
        }
    }
    
    private func createIngredientBasicList(){
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self).filter("stockFlag == false")
        try! realm.write {
            for ingredient in ingredientList!{
                ingredient.calcContribution()
            }
        }
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(
                id: ingredient.id, name:
                ingredient.ingredientName,
                nameYomi: ingredient.ingredientNameYomi,
                katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch,
                stockFlag: ingredient.stockFlag,
                category: ingredient.category,
                contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability,
                usedRecipeNum: ingredient.recipeIngredients.count
            ))
        }
        
        ingredientBasicList.removeAll{
            $0.contributionToRecipeAvailability < 2
        }
        ingredientBasicList.sort(by: { $0.contributionToRecipeAvailability > $1.contributionToRecipeAvailability })

        if ingredientBasicList.count == 0{
            isContributionMode = false
            for ingredient in ingredientList!{
                ingredientBasicList.append(IngredientBasic(
                    id: ingredient.id,
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch,
                    stockFlag: ingredient.stockFlag,
                    category: ingredient.category,
                    contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability,
                    usedRecipeNum: ingredient.recipeIngredients.count
                ))
            }
            
            stockingIngredientList = realm.objects(Ingredient.self).filter("stockFlag == true")
            if stockingIngredientList!.count <= 10{
                // 持っている材料数が少ない場合、その他カテゴリの材料を取り除く
                ingredientBasicList.removeAll{ $0.category == 2 }
            }
            ingredientBasicList.sort(by: { $0.usedRecipeNum > $1.usedRecipeNum })
        }
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock(selectedRecommendIngredientId)
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let int = interactor, int.hasStarted {
            scrollView.contentOffset.y = 0.0
        }
    }

    // MARK: - TableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : 75
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  ingredientBasicList.count <= 5 ? ingredientBasicList.count + 1 : 6
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0{
            selectedRecommendIngredientId = self.ingredientBasicList[indexPath.row - 1].id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientRecommendCell") as! IngredientRecommendTableViewCell
            
            let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cell.accessoryView = accesoryImageView

            cell.ingredientName = ingredientBasicList[indexPath.row - 1].name
            cell.category = ingredientBasicList[indexPath.row - 1].category
            if isContributionMode{
                cell.ingredientDescription = "入手すると新たに\(String(ingredientBasicList[indexPath.row - 1].contributionToRecipeAvailability))レシピ作れる！"
            }else{
                cell.ingredientDescription = "\(String(ingredientBasicList[indexPath.row - 1].usedRecipeNum))個のレシピで使われています！"
            }
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            return cell
        }
    }
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        guard let interactor = interactor else { return }
        let percentThreshold: CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        if tableView.contentOffset.y <= 0 || interactor.hasStarted{
            switch sender.state {
            case .began:
                interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            case .changed:
                interactor.shouldFinish = progress > percentThreshold
                interactor.update(progress)
                break
            case .cancelled:
                interactor.hasStarted = false
                interactor.cancel()
            case .ended:
                interactor.hasStarted = false
                interactor.shouldFinish ? interactor.finish() : interactor.cancel()
            default:
                break
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
