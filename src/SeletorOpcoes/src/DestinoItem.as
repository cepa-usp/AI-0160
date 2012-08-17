package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class DestinoItem extends Sprite 
	{
		private var _opcao:Opcao;		
		private var tx:TextField = new TextField();
		private var btFechar:Sprite = new Sprite();
		
		public function DestinoItem(opcao:Opcao) 
		{
			fazBtFechar()
			this.opcao = opcao;
			this.addChild(tx);
			tx.text = opcao.texto;
			tx.x = 20;			
			btFechar.x = 5;
			
		}
		
		private function fazBtFechar():void 
		{
			btFechar.graphics.beginFill(0xFF0000, 1);
			btFechar.graphics.drawCircle(0, 0, 5);			
			addChild(btFechar);
		}
		
		public function get opcao():Opcao 
		{
			return _opcao;
		}
		
		public function set opcao(value:Opcao):void 
		{
			_opcao = value;
		}
		
	}

}