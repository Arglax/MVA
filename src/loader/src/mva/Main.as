package mva
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Security;
   import flash.text.TextField;
   import mva.ui.Modules;

   public class Main extends MovieClip
   {

      public static var instance:Main;

      public var game:*;

      public var external:PageLink;

      private var sURL:String = "https://game.aq.com/game/";

      private var versionUrl:String;

      private var loginURL:String;

      private var sFile:String;

      private var sBG:String = "hideme.swf";

      private var isEU:Boolean;

      private var urlLoader:URLLoader;

      private var vars:Object;

      private var loader:Loader;

      private var sTitle:String = "<font color=\"#FDAF2D\">MobileVibeAQW</font>";

      private var stg:Stage;

      private var gameDomain:ApplicationDomain;

      private var started:Boolean = false;

      public function Main()
      {
         this.versionUrl = this.sURL + "api/data/gameversion";
         this.loginURL = this.sURL + "api/login/now";
         super();
         String.prototype.trim = function():String
         {
            var s:String = String(this);
            return s.replace(/^\s+|\s+$/g,"");
         };
         Main.instance = this;
         if(stage)
         {
            this.init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.init);
         }
      }

      public static function loadGame() : void
      {
         if(Main.instance.started)
         {
            return;
         }
         Main.instance.started = true;
         Main.instance.fetchVersion();
         Main.instance.external.call("pre-load");
      }

      public static function getGameObject(path:String) : String
      {
         try
         {
            return JSON.stringify(_getObjectS(instance.game,path));
         }
         catch(e:Error)
         {
         }
         return "null";
      }

      public static function setGameObject(path:String, value:*) : void
      {
         var parts:Array = path.split(".");
         var last:String = parts.pop();
         var target:* = _getObjectA(instance.game,parts);
         if(target != null)
         {
            target[last] = value;
         }
      }

      public static function callGameFunction(path:String, ... args) : String
      {
         var parts:Array = path.split(".");
         var last:String = parts.pop();
         var target:* = _getObjectA(instance.game,parts);
         var fn:Function = target != null ? target[last] as Function : null;
         if(fn == null)
         {
            return "null";
         }
         try
         {
            return JSON.stringify(fn.apply(target,args));
         }
         catch(e:Error)
         {
         }
         return "null";
      }

      public static function _getObjectS(root:*, path:String) : *
      {
         return _getObjectA(root,path.split("."));
      }

      public static function _getObjectA(root:*, parts:Array) : *
      {
         var cur:* = root;
         var i:int = 0;
         while(i < parts.length)
         {
            if(cur == null)
            {
               return null;
            }
            cur = cur[parts[i]];
            i++;
         }
         return cur;
      }

      public static function isNull(path:String) : String
      {
         try
         {
            return (_getObjectS(instance.game,path) == null).toString();
         }
         catch(ex:Error)
         {
         }
         return "true";
      }

      public static function availableMonsters() : String
      {
         var out:Array = [];
         try
         {
            var world:* = instance.game.world;
            for each(var mon:* in world.getMonstersByCell(world.strFrame))
            {
               if(mon != null && mon.objData != null)
               {
                  out.push({
                     "MonMapID":mon.objData.MonMapID,
                     "MonID":mon.objData.MonID,
                     "strMonName":mon.objData.strMonName
                  });
               }
            }
         }
         catch(e:Error)
         {
         }
         return JSON.stringify(out);
      }

      private function init(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.external = new PageLink();
         this.external.init(this);
      }

      private function fetchVersion() : void
      {
         Security.allowDomain("*");
         this.urlLoader = new URLLoader();
         this.urlLoader.addEventListener(Event.COMPLETE,this.onVersion);
         this.urlLoader.load(new URLRequest(this.versionUrl));
      }

      private function onVersion(e:Event) : void
      {
         this.urlLoader.removeEventListener(Event.COMPLETE,this.onVersion);
         this.vars = JSON.parse(e.target.data);
         this.sFile = this.vars.sFile + "?ver=" + Math.random();
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this.loader.load(new URLRequest(this.sURL + "gamefiles/" + this.sFile));
      }

      private function onComplete(e:Event) : void
      {
         var key:String = null;
         this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
         this.stg = stage;
         this.stg.removeChildAt(0);
         this.game = this.stg.addChild(this.loader.content);
         this.stg.scaleMode = StageScaleMode.SHOW_ALL;
         this.stg.align = StageAlign.TOP;
         for(key in root.loaderInfo.parameters)
         {
            this.game.params[key] = root.loaderInfo.parameters[key];
         }
         this.game.params.vars = this.vars;
         this.game.params.sURL = this.sURL;
         this.game.params.sBG = this.sBG;
         this.game.params.sTitle = this.sTitle;
         this.game.params.isEU = this.isEU;
         this.game.params.loginURL = this.loginURL;
         this.gameDomain = LoaderInfo(e.target).applicationDomain;
         Modules.init();
         AuraWatch.watch();
         this.stg.addEventListener(Event.ENTER_FRAME,Modules.handleFrame);
         this.game.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         this.external.call("loaded");
      }

      private function onKey(e:KeyboardEvent) : void
      {
         if(e.target is TextField || e.currentTarget is TextField)
         {
            return;
         }
         try
         {
            if(e.keyCode == this.game.litePreference.data.keys["Bank"])
            {
               if(this.game.stage.focus == null || !("text" in this.game.stage.focus))
               {
                  this.game.world.toggleBank();
               }
            }
         }
         catch(err:Error)
         {
         }
      }

      public function getGame() : *
      {
         return this.game;
      }
   }
}
