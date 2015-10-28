package
{
	import com.maclema.mysql.Connection;
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	import com.maclema.mysql.MySqlToken;
	import com.maclema.mysql.Statement;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.LabelButton;
	import fl.controls.ScrollBar;
	import fl.controls.TextArea;
	import fl.controls.TextInput;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author shumake
	 */
	public class Main extends Sprite 
	{
		
		private const DB_SERVER:String = "localhost";
		private const DB_PORT:int = 3306;
		private const DB_USER:String = "root";
		private const DB_PASSWORD:String = "12345";
		private const DB_DATABASE:String = "test";
		private const DB_TABLE:String = "myTable";
		
		private var txtSqlInput:TextInput;
		private var txtSqlResult:TextArea;
		private var txtSqlUpdateId:TextInput;
		
		private var btnInsert:Button;
		private var btnQuery:Button;
		private var btnDelete:Button;
		private var btnUpdate:Button;
		
		
		private var iTimeElasp:int;
		
		
		
		// the sql connection is the core of our sql connectoin
		// it will be used to make all of our queries
		private var m_sqlConnection:Connection;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Security.loadPolicyFile("xmlsocket://localhost:843");
			
			//初始化畫面佈局
			initLayOut();
			// entry point
			m_sqlConnection = new Connection(DB_SERVER, DB_PORT, DB_USER, DB_PASSWORD, DB_DATABASE);
			m_sqlConnection.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			m_sqlConnection.addEventListener(Event.CONNECT, onConnected);
			m_sqlConnection.connect();
		}
		
		/**
		 * 初始畫面佈置
		 */
		private function initLayOut():void
		{
			//輸入內容
			txtSqlInput = new TextInput();
			txtSqlInput.x = 20;
			txtSqlInput.y = 20;
			txtSqlInput.text = "請輸入內容";
			txtSqlInput.addEventListener(Event.CHANGE, onTextInput);
			this.addChild(txtSqlInput);
			
			
			//id
			var txtIdLabel:Label = new Label();
			txtIdLabel.autoSize = "left";
			txtIdLabel.text = "更新Id";
			txtIdLabel.x = 20;
			txtIdLabel.y = txtSqlInput.height + txtSqlInput.y + 5;
			addChild(txtIdLabel);
			txtSqlUpdateId = new TextInput();
			txtSqlUpdateId.x = txtIdLabel.x + txtIdLabel.textField.textWidth+5;
			txtSqlUpdateId.y = txtIdLabel.y;
			txtSqlUpdateId.restrict = '0-9';
			txtSqlUpdateId.text = "請輸入更新id";
			addChild(txtSqlUpdateId);
			txtSqlUpdateId.addEventListener(FocusEvent.FOCUS_IN, onIdFocusInOutHandler);
			
			
			//查詢結果
			txtSqlResult = new TextArea();
			txtSqlResult.x = 20;
			txtSqlResult.y = txtIdLabel.height + txtIdLabel.y + 10;
			txtSqlResult.width = 300;
			txtSqlResult.height = 300;
			txtSqlResult.editable = false;
			txtSqlResult.wordWrap = false;
			txtSqlResult.horizontalScrollPolicy = "off";
			addChild(txtSqlResult);
			txtSqlResult.text = "SQL結果";
			
		
			
			//插入按鈕
			btnInsert = new Button();
			btnInsert.label = "插入";
			btnInsert.x = txtSqlInput.width + txtSqlInput.x+5;
			btnInsert.y = txtSqlInput.y;
			addChild(btnInsert);
			btnInsert.addEventListener(MouseEvent.CLICK, onInsertClick);
			
			//查詢按鈕
			btnQuery = new Button();
			btnQuery.label = "查詢";
			btnQuery.x = btnInsert.width + btnInsert.x+5;
			btnQuery.y = btnInsert.y;
			addChild(btnQuery);
			btnQuery.addEventListener(MouseEvent.CLICK, onQueryClick);
			
			
			//刪除按鈕
			btnDelete = new Button();
			btnDelete.label = "刪除";
			btnDelete.x = btnQuery.width + btnQuery.x+5;
			btnDelete.y = btnQuery.y;
			addChild(btnDelete);
			btnDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
			
			
			//更新按鈕
			btnUpdate = new Button();
			btnUpdate.label = "更新";
			btnUpdate.x = txtSqlUpdateId.x + txtSqlUpdateId.width;
			btnUpdate.y = txtSqlUpdateId.y;
			addChild(btnUpdate);
			btnUpdate.addEventListener(MouseEvent.CLICK, onUpdateClick);
			
		}
		
		
		/**
		 * 更新點擊
		 * @param	e
		 */
		private function onUpdateClick(e:MouseEvent):void 
		{
			updateRow();
		}
		
		/**
		 * Id Focus 事件
		 * @param	e
		 */
		private function onIdFocusInOutHandler(e:FocusEvent):void 
		{
			trace(e);
			switch(e.type)
			{
				case FocusEvent.FOCUS_IN:
					if (txtSqlUpdateId.text == "請輸入更新id")
					{
						txtSqlUpdateId.text = "";
					}
					break;
				
			}
		}
		
		
		/**
		 * 刪除點擊
		 * @param	e
		 */
		private function onDeleteClick(e:MouseEvent):void 
		{
			deleteRow();
		}
		
		/**
		 * 查詢點擊
		 * @param	e
		 */
		private function onQueryClick(e:MouseEvent):void 
		{
			queryTable();
		}
		
		/**
		 * 插入點擊
		 * @param	e
		 */
		private function onInsertClick(e:MouseEvent):void 
		{
			if (txtSqlInput.text.length >= 0)
			{
				insertRow(txtSqlInput.text);
			}
		}
		
		/**
		 * 偵測文字輸入
		 * @param	e
		 */
		private function onTextInput(e:Event):void 
		{
			trace(txtSqlInput.text);
		}
		
		// if the connection is successful this gets called
		// here i am just adding some data to a table
		private function onConnected(e:Event):void 
		{
			createTable(DB_TABLE);
		}
		
		// int the onConnected function, i registered onSqlResponse
		// if my previous insert was successful, this will get called
		// here I am just running a query for the data i inserted earlier
		private function onSqlResponse(e:MySqlEvent):void 
		{
			trace("Spend-----", getTimer() - iTimeElasp, " milisecs");
			trace(e.toString());
		}
		
		
		// in the onSqlResponse function, i registered onSqlResult
		// if my previous query was successful, this will get called
		// here I am displaying the results from the previous query
		private function onSqlResult(e:MySqlEvent):void 
		{
			trace(getTimer() - iTimeElasp," miliseconds");
			txtSqlResult.text = "";
			while (e.resultSet.next()) {
				//取的第一欄及第二欄的問題
				txtSqlResult.appendText(e.resultSet.getInt(1) +"  "+ e.resultSet.getString(2) + "\n");
				trace(e.resultSet.getInt(1), e.resultSet.getString(2));
			}
		}
		
		// hopefully we wont see any errors, but each function above also
		// is listening for errors. if any are caught, they're displayed here
		private function onSqlError(e:MySqlErrorEvent):void 
		{
			trace("type:",e.type);
			trace("SqlError:", e.msg, e.id);
			txtSqlResult.text = e.msg + e.id;
		}
		
		
		/**
		 * 創建資料表
		 * @param	_sTableName
		 */
		private function createTable(_sTableName:String):void
		{
			var statement:Statement = m_sqlConnection.createStatement();
			var sSql:String = "CREATE TABLE IF NOT EXISTS "+DB_TABLE+" (intColumn int(11) NOT NULL auto_increment,stringColumn char(255) COLLATE utf8_bin NOT NULL,PRIMARY KEY(intColumn))";
			var token:MySqlToken = statement.executeQuery(sSql);
			token.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			token.addEventListener(MySqlEvent.RESPONSE, onCreateTableSuccess);
		}
		
		/**
		 * 查詢資料表
		 */
		private function queryTable():void
		{
			iTimeElasp = getTimer();
			var statement:Statement = m_sqlConnection.createStatement();
			var token:MySqlToken = statement.executeQuery("SELECT * FROM "+DB_TABLE);
			token.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			token.addEventListener(MySqlEvent.RESULT, onSqlResult);
		}
		
		/**
		 * 新增資料列
		 */
		private function insertRow(_sSqlString:String):void
		{
			trace("Insert Data");
			iTimeElasp = getTimer();
			var statement:Statement = m_sqlConnection.createStatement();
			statement.sql = "INSERT INTO "+DB_TABLE+" (stringColumn) VALUES (?)";
			statement.setString(1, _sSqlString);
			
			var token:MySqlToken = statement.executeQuery();
			token.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			token.addEventListener(MySqlEvent.RESPONSE, onSqlResponse);
		}
		
		/**
		 * 刪除資料列
		 */
		private function deleteRow():void
		{
			trace("Delete Data");
			var statement:Statement = m_sqlConnection.createStatement();
			statement.sql = "DELETE FROM "+DB_TABLE+" ORDER BY intColumn DESC limit 1";
			
			var token:MySqlToken = statement.executeQuery();
			token.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			token.addEventListener(MySqlEvent.RESPONSE, onSqlResponse);
		}
		
		/**
		 * 更新資料列
		 */
		private function updateRow():void
		{
			trace("Update Data");
			iTimeElasp = getTimer();
			var statement:Statement = m_sqlConnection.createStatement();
			statement.sql = "UPDATE " + DB_TABLE+" SET stringColumn='" + txtSqlInput.text + "' WHERE intColumn=" + txtSqlUpdateId.text;
			var token:MySqlToken = statement.executeQuery();
			token.addEventListener(MySqlErrorEvent.SQL_ERROR, onSqlError);
			token.addEventListener(MySqlEvent.RESPONSE, onSqlResponse);
		}
		
		
		private function onCreateTableSuccess(e:MySqlEvent):void 
		{
			trace(e.toString());
		}
		
		
	}
	
}