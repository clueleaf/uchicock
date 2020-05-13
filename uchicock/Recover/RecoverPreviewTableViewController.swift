//
//  RecoverPreviewTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverPreviewTableViewController: UITableViewController {

    @IBOutlet weak var recipeName: CustomTextView!
    @IBOutlet weak var recipeNameYomiLabel: UILabel!
    @IBOutlet weak var style: CustomLabel!
    @IBOutlet weak var method: CustomLabel!
    @IBOutlet weak var strength: CustomLabel!
    
    var recipe = Recipe()
    var recipeIngredientList = Array<RecipeIngredientBasic>()

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
        
        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(recipeIngredientId: ri.id, ingredientId: ri.ingredient.id, ingredientName: ri.ingredient.ingredientName, ingredientNameYomi: ri.ingredient.ingredientNameYomi, amount: ri.amount, mustFlag: ri.mustFlag, category: ri.ingredient.category, displayOrder: ri.displayOrder, stockFlag: false))
        }
        recipeIngredientList.sort(by: { $0.displayOrder < $1.displayOrder })

        recipeName.isScrollEnabled = false
        recipeName.textContainerInset = .zero
        recipeName.textContainer.lineFragmentPadding = 0
        recipeName.font = UIFont.systemFont(ofSize: 25.0)

        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.tableView.separatorColor = UchicockStyle.labelTextColorLight
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        self.navigationItem.title = "プレビュー"

        recipeName.text = recipe.recipeName
        
        recipeNameYomiLabel.text = recipe.recipeNameYomi
        recipeNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        if recipe.recipeName.katakanaLowercasedForSearch() == recipe.recipeNameYomi{
            recipeNameYomiLabel.isHidden = true
        }else{
            recipeNameYomiLabel.isHidden = false
        }

        switch recipe.style{
        case 0:
            style.text = "ロング"
        case 1:
            style.text = "ショート"
        case 2:
            style.text = "ホット"
        case 3:
            style.text = "未指定"
        default:
            style.text = "未指定"
        }
        switch recipe.method{
        case 0:
            method.text = "ビルド"
        case 1:
            method.text = "ステア"
        case 2:
            method.text = "シェイク"
        case 3:
            method.text = "ブレンド"
        case 4:
            method.text = "その他"
        default:
            method.text = "その他"
        }
        switch recipe.strength{
        case 0:
            strength.text = "ノンアルコール"
        case 1:
            strength.text = "弱い"
        case 2:
            strength.text = "やや強い"
        case 3:
            strength.text = "強い"
        case 4:
            strength.text = "未指定"
        default:
            strength.text = "未指定"
        }

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        if UchicockStyle.isBackgroundDark{
            tableView.indicatorStyle = .white
        }else{
            tableView.indicatorStyle = .black
        }
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }
    
    // MARK: - UITableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if interactor != nil{
            if interactor!.hasStarted {
                tableView.contentOffset.y = 0.0
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.tableViewHeaderBackgroundColor
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "材料(\(String(recipeIngredientList.count)))" : ""
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
            return recipeIngredientList.count
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
            cell.recipeIngredient = RecipeIngredientBasic(recipeIngredientId: "", ingredientId: "", ingredientName: recipeIngredientList[indexPath.row].ingredientName, ingredientNameYomi: recipeIngredientList[indexPath.row].ingredientNameYomi, amount: recipeIngredientList[indexPath.row].amount, mustFlag: recipeIngredientList[indexPath.row].mustFlag, category: recipeIngredientList[indexPath.row].category, displayOrder: -1, stockFlag: false)

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
                interactor.shouldFinish
                    ? interactor.finish()
                    : interactor.cancel()
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
