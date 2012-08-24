package  
{
	import fl.video.FLVPlayback;
	/**
	 * ...
	 * @author Arthur
	 */
	public class TutorialPlayer 
	{
		
		private var _player:FLVPlayback = new FLVPlayback();
		public function TutorialPlayer() 
		{
			player.source = "http://midia.atp.usp.br/atividades-interativas/AI-0160/video/videotutorial.flv";
			player.playWhenEnoughDownloaded();
			player.name = "player"
			//player.addEventListener(MetadataEvent.CUE_POINT, cuePointListener);
			//player.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, onPlay);
		}
		
		public function get player():FLVPlayback 
		{
			return _player;
		}
		
		public function set player(value:FLVPlayback):void 
		{
			_player = value;
		}
		
	}

}