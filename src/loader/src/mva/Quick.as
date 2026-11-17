package mva
{

   public class Quick
   {
      private static const ACTIONS:Object = {
         "Area List":1, "Player HP Bar":1, "Hide Players":1, "Hide Monsters":1, "Hide UI":1,
         "Stats Overview":1, "Battle Analyzer":1, "Battle Analyzer Toggle":1,
         "Friends List":1, "Friendships UI":1, "Character Panel":1, "Outfits":1, "Options":1,
         "Quest Log":1, "Inventory":1, "Bank":1,
         "Target Random Monster":1, "Cancel Target":1, "Rest":1, "Jump":1, "Decline All Drops":1,
         "World Camera":1
      };

      private static const MAX_LOG:int = 40;

      private static var _log:Array = [];

      public function Quick()
      {
         super();
      }

      public static function run(name:String):Boolean {
          try {
              var game:* = Main.instance.game;
              if (game == null || game.world == null || game.world.myAvatar == null) {
                  return false;
              }
              AuraWatch.watch();
              if (name == "Chat") {
                  game.chatF.openMsgEntry();
                  return true;
              }
              if (ACTIONS[name] == null) {
                  return false;
              }
              game.runBind(name);
              return true;
          } catch (e:Error) {
          }
          return false;
      }

      private static function cleanMap(map:String):String {
          var m:String = map == null ? "" : String(map).toLowerCase().replace(/^\s+|\s+$/g, "");
          return /^[a-z0-9_]{2,40}(-[0-9]{1,6})?$/.test(m) ? m : "";
      }

      public static function travel(map:String):String {
          try {
              var m:String = cleanMap(map);
              if (m == "") {
                  return "bad";
              }
              var game:* = Main.instance.game;
              if (game == null || game.world == null || game.world.myAvatar == null) {
                  return "nogame";
              }
              AuraWatch.watch();
              game.world.gotoTown(m, "Enter", "Spawn");
              return "ok";
          } catch (e:Error) {
          }
          return "nogame";
      }

      public static function visited(o:*):void {
          try {
              var m:String = o.strMapName != null ? String(o.strMapName) : (o.areaName != null ? String(o.areaName) : "");
              m = m.toLowerCase().replace(/-[0-9]+$/, "");
              if (cleanMap(m) == "") {
                  return;
              }
              var i:int = _log.indexOf(m);
              if (i >= 0) {
                  _log.splice(i, 1);
              }
              _log.unshift(m);
              if (_log.length > MAX_LOG) {
                  _log.length = MAX_LOG;
              }
          } catch (e:Error) {
          }
      }

      public static function state():String {
          var map:String = "";
          try {
              AuraWatch.watch();
              var game:* = Main.instance.game;
              if (game != null && game.world != null && game.world.myAvatar != null && game.world.strMapName != null) {
                  map = String(game.world.strMapName).toLowerCase();
              }
          } catch (e:Error) {
          }
          return JSON.stringify({map: map, log: _log});
      }
   }
}
