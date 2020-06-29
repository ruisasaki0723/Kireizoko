//
//  ViewController.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/25.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // カメラボタンを押したらカメラ画面に移動
    @IBAction func cameraButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toCamera", sender: nil)
    }
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
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
        
        cell.setTaskData(taskArray[indexPath.row])
        
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
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //let inputViewController:InputViewController = segue.destination as! InputViewController
        let inputViewController = self.storyboard?.instantiateViewController(withIdentifier: "Input") as! InputViewController
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]

        }
    }
}
