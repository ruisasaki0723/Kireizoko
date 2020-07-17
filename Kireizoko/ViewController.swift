//
//  ViewController.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/25.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // カメラボタンを押したらカメラ画面に移動
    @IBAction func cameraButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toCamera", sender: nil)
    }
    
    // カテゴリー検索
    @IBAction func categorySearchButton(_ sender: Any) {
        // ピッカーの設定
        pickerView.frame = CGRect(x:0,y:700, width:view.frame.width,height: 200)
        pickerView.backgroundColor = UIColor.green
        pickerView.delegate = self
        pickerView.dataSource = self
        self.view.addSubview(pickerView)
        
        // ツールバーの設定
        let toolBar = UIToolbar(frame: CGRect(x:0,y:680, width:view.frame.width,height: 200))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // 検索ボタン(右)
        let searchButton = UIBarButtonItem(title: "検索する", style: UIBarButtonItem.Style.done, target: self, action: #selector(ViewController.searchPicker))
        // 閉じるボタン(左)
        let cancelButton = UIBarButtonItem(title: "閉じる", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.cancelPicker))
        // 検索ボタンと閉じるボタンの間のスペース用
        let spaceButton  = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        // ツールバーにボタンを追加し表示する([閉じる]　(スペース)　[検索])
        toolBar.items = [cancelButton,spaceButton,searchButton]
        self.view.addSubview(toolBar)
    }
    
    // 並び替え
    @IBAction func sortButton(_ sender: Any) {
        
    }
    
    let pickerView = UIPickerView()
    var delegate: UIPickerViewDelegate!
    let category = ["全表示","野菜","肉","魚","乳製品","飲料","果物","デザート","調味料","その他"]
    // Realmインスタンスを取得する
    let realm = try! Realm()
    var task: Task!
    
    // 賞味期限の近い順でソートする
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "shomikigen", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    // セルの高さの設定
    private func initTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.estimatedRowHeight = 150 //追加
        tableView.rowHeight = UITableView.automaticDimension //追加
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        cell.setTaskData(taskArray[indexPath.row], vc: self , tableView:tableView)
        
        return cell
    }
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "cellSegue",sender: nil)
        
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                // 未通知のローカル通知一覧をログ出力
                center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "cellSegue" {
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let inputViewController = self.storyboard?.instantiateViewController(withIdentifier: "Input") as! InputViewController
        }
    }
    // ピッカーの設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    // 検索ボタンを押したらRealmのカテゴリーと合致したセルのみ表示する
    @objc func searchPicker(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        
        // 全表示
        if component == 0 {
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 野菜
        } else if component == 1 {
            let predicate = NSPredicate(format:"task.category == %@", "0")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 肉
        } else if component == 2 {
            let predicate = NSPredicate(format:"task.category == %@", "1")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 魚
        } else if component == 3 {
            let predicate = NSPredicate(format:"task.category == %@", "2")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 乳製品
        } else if component == 4 {
            let predicate = NSPredicate(format:"task.category == %@", "3")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 飲料
        } else if component == 5 {
            let predicate = NSPredicate(format:"task.category == %@", "4")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 果物
        } else if component == 6 {
            let predicate = NSPredicate(format:"task.category == %@", "5")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // デザート
        } else if component == 7 {
            let predicate = NSPredicate(format:"task.category == %@", "6")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // 調味料
        } else if component == 8 {
            let predicate = NSPredicate(format:"task.category == %@", "7")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        // その他
        } else {
            let predicate = NSPredicate(format:"task.category == %@", "8")
            taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "shomikigen", ascending: true)
            tableView.reloadData()
        }
    }
    // キャンセルボタンを押したら閉じる
    @objc func cancelPicker() {
        //delegate.pickerView
    }
}
