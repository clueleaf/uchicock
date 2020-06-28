//
//  RecoverPreviewTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverPreviewTableViewController: UITableViewController {

    @IBOutlet weak var recipeNameTextView: CustomTextView!
    @IBOutlet weak var recipeNameYomiLabel: UILabel!
    @IBOutlet weak var styleLabel: CustomLabel!
    @IBOutlet weak var methodLabel: CustomLabel!
    @IBOutlet weak var strengthLabel: CustomLabel!
    
    var recipe = Recipe()
    var ingredientList = Array<RecipeIngredientBasic>()

    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock = {}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }
        
        recipeNameTextView.isScrollEnabled = false
        recipeNameTextView.textContainerInset = .zero
        recipeNameTextView.textContainer.lineFragmentPadding = 0
        recipeNameTextView.font = UIFont.systemFont(ofSize: 25.0)
        recipeNameTextView.text = recipe.recipeName
        
        recipeNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        if recipe.recipeName.katakanaLowercasedForSearch() == recipe.recipeNameYomi.katakanaLowercasedForSearch(){
            recipeNameYomiLabel.isHidden = true
            recipeNameYomiLabel.text = " "
        }else{
            recipeNameYomiLabel.isHidden = false
            recipeNameYomiLabel.text = recipe.recipeNameYomi
        }

        styleLabel.text = RecipeStyleType.fromInt(number: recipe.style).rawValue
        methodLabel.text = RecipeMethodType.fromInt(number: recipe.method).rawValue
        strengthLabel.text = RecipeStrengthType.fromInt(number: recipe.strength).rawValue

        for ri in recipe.recipeIngredients {
            ingredientList.append(RecipeIngredientBasic(
                ingredientId: "",
                ingredientName: ri.ingredient.ingredientName,
                ingredientNameYomi: "",
                katakanaLowercasedNameForSearch: "",
                amount: ri.amount,
                mustFlag: ri.mustFlag,
                category: ri.ingredient.category,
                displayOrder: ri.displayOrder,
                stockFlag: false
            ))
        }
        ingredientList.sort { $0.displayOrder < $1.displayOrder }

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let int = interactor, int.hasStarted {
            scrollView.contentOffset.y = 0.0
        }
    }

    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "材料(\(String(ingredientList.count)))" : ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return UITableView.automaticDimension
            }else{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }else if indexPath.section == 1{
            return 70
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else if section == 1{
            return ingredientList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
            cell.isDuplicated = false
            cell.shouldDisplayStock = false
            cell.isNameTextViewSelectable = true
            cell.recipeIngredient = RecipeIngredientBasic(
                ingredientId: "",
                ingredientName: ingredientList[indexPath.row].ingredientName,
                ingredientNameYomi: "",
                katakanaLowercasedNameForSearch: "",
                amount: ingredientList[indexPath.row].amount,
                mustFlag: ingredientList[indexPath.row].mustFlag,
                category: ingredientList[indexPath.row].category,
                displayOrder: -1,
                stockFlag: false
            )
            cell.selectionStyle = .none
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            return cell
        default:
            return UITableViewCell()
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
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
