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
    
    //入力用のTextField
    var titleTextField: UITextField?
    var deadlineTextField: UITextField?
    
    //UIDatePickerの用意
    let datePicker = UIDatePicker()
    var pickerToolBar = UIToolbar()
    
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
        
        /*//datePickerの設置
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        
        // キーボードに表示するツールバーの表示
        pickerToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        pickerToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        pickerToolBar.barStyle = .BlackTranslucent
        pickerToolBar.tintColor = UIColor.whiteColor()
        pickerToolBar.backgroundColor = UIColor.blackColor()
        
        //ボタンの設定
        //完了ボタンを設定
        let okBarBtn = UIBarButtonItem(title: "OK", style: .Done, target: self, action: Selector("okBarBtnPush"))
        //ツールバーにボタンを表示
        pickerToolBar.items = [okBarBtn]*/

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
        alertController.addTextFieldWithConfigurationHandler( { (title: UITextField!) -> Void in
            self.titleTextField = title
            title.placeholder = "Title"
        })
        alertController.addTextFieldWithConfigurationHandler( { (deadline: UITextField!) -> Void in
            self.deadlineTextField = deadline
            deadline.placeholder = "Deadline"
            //self.datePicker.addTarget(self, action: Selector("changedDatePicker"), forControlEvents: UIControlEvents.ValueChanged)
            //deadline.inputView = self.datePicker
        })
        
        //OKボタンが押された時の処理
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action:UIAlertAction) -> Void in
            
            //アラートのUITextFieldsを全部配列として取得
            let textFields:Array<UITextField>? = alertController.textFields as Array<UITextField>?
            
            //入力されたTodoをtodoListに追加
            if textFields != nil {
                let myTodo = MyTodo()
                //textFieldsの１個目がTitle
                myTodo.todoTitle = alertController.textFields![0].text!
                //textFieldsの2個目がDeadline
                myTodo.deadline = alertController.textFields![1].text!
                //todoListに追加
                self.todoList.insert(myTodo, atIndex: 0)
            }
            
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
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        //アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*/*
    datePickerのOKボタンを押した時の処理
    */
    func okBarBtnPush(sender: AnyObject?){
        let dateFormatter = NSDateFormatter()
        let pickerDate = datePicker.date
        deadlineTextField!.text = dateFormatter.stringFromDate(pickerDate)
        self.view.endEditing(true)
    }*/

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
            
            //todoListから削除
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
    
    //Todoの締め切り
    var deadline :String?
    
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

