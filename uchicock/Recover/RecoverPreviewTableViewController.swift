//
//  RecoverPreviewTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverPreviewTableViewController: UITableViewController {

    @IBOutlet weak var recipeName: CustomLabel!
    @IBOutlet weak var style: CustomLabel!
    @IBOutlet weak var method: CustomLabel!
    
    var recipe = Recipe()
    
    var interactor: Interactor!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))

        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.navigationItem.title = "プレビュー"

        recipeName.text = recipe.recipeName
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

        self.tableView.separatorColor = UIColor.gray
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
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
        if interactor.hasStarted {
            tableView.contentOffset.y = 0.0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 1 {
            label.text = "  材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            label.text = nil
        }
        return label
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
            return 3
        }else if section == 1{
            return recipe.recipeIngredients.count
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
            cell.backgroundColor = Style.basicBackgroundColor
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
            cell.ingredientName = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            cell.isOption = !recipe.recipeIngredients[indexPath.row].mustFlag
            cell.amountText = recipe.recipeIngredients[indexPath.row].amount
            cell.stock = nil

            cell.selectionStyle = .none
            cell.backgroundColor = Style.basicBackgroundColor
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
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
