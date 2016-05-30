//
//  ViewController.swift
//  MyTodoList
//
//  Created by Shiozawa Tomo on 2016/05/29.
//  Copyright © 2016年 Shiozawa Tomo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //TODOを格納する配列
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //読み込み処理(ここは勉強不足)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let todoListData = userDefaults.objectForKey("todoList") as? NSData {
            if let storedTodoList = NSKeyedUnarchiver.unarchiveObjectWithData(todoListData) as? [MyTodo] {
                todoList.appendContentsOf(storedTodoList)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    Addボタンをタップした際に呼ばれる処理
    */
    @IBAction func tapAddButton(sender: AnyObject) {
        //アラートダイアログ生成
        let alertController = UIAlertController(title: "TODO追加", message: "TODOを入力してください", preferredStyle: UIAlertControllerStyle.Alert)
        
        //テキストエリアを追加
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        //OKボタンが押された時の処理
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action:UIAlertAction) -> Void in
            
            //Todoタイトル入力用のtextFieldを用意
            if let textField = alertController.textFields?.first {
                
                //todoListタイトルに挿入
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text
                self.todoList.insert(myTodo, atIndex: 0)
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRowsAtIndexPaths(
                    [NSIndexPath(forRow: 0, inSection: 0)],
                    withRowAnimation: UITableViewRowAnimation.Right)
                
                //保存処理
                //NSData型にシリアライズする
                let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
                
                //NSUserDefaultsに保存
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(data, forKey: "todoList")
                userDefaults.synchronize()

            }
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        //アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }

    /*
    テーブルの行数を返す
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODOの配列の長さを返す
        return todoList.count
    }
    
    /*
    テーブルの行ごとのセルを返す
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する(メモリを有効活用するための処理らしい、勉強不足)
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath)
        
        //行番号に合ったTODOのタイトルを取得
        let todo = todoList[indexPath.row]
        
        //セルのラベルにTODOのタイトルをセット
        cell.textLabel!.text = todo.todoTitle
        
        //状態によってチェックマークをつける
        if todo.todoDone {
            //完了していたらチェックマーク
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            //未完だったら何もなし
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    //セルをタップした時の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = todoList[indexPath.row]
        
        //完了にするかどうか
        if todo.todoDone {
            //完了済みの場合は未完に変更
            todo.todoDone = false
        }
        else {
            //未完の場合は完了済みに変更
            todo.todoDone = true
        }
        
        //セルの状態を変更
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        //データ保存
        //NSData型にシリアライズする
        let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
        
        //NSUserDefaultsに保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
    /*
    セルの削除許可(セルが編集可能かどうかを判定する、一応書いておいた)
    */
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    /*
    セルを削除した時の処理
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //削除処理かどうか
        if editingStyle == .Delete {
            
            //TODOリストから削除
            todoList.removeAtIndex(indexPath.row)
            
            //セルを削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //データ保存
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
            
            //NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "todoList")
            userDefaults.synchronize()
        }
    }
}

//Todo用のクラス
class MyTodo: NSObject, NSCoding {

    //Todoのタイトル
    var todoTitle :String?
    
    //Todoを完了したかどうかを表すフラグ
    var todoDone :Bool = false
    
    //コンストラクタ
    override init() {

    }
    
    //デシリアライズ処理(デコード)
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObjectForKey("todoTitle") as? String
        todoDone = aDecoder.decodeBoolForKey("todoDone")
    }
    
    //シリアライズ処理(エンコード)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(todoTitle, forKey: "todoTitle")
        aCoder.encodeBool(todoDone, forKey: "todoDone")
    }
}

