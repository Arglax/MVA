package mva.ui
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import mva.Main;

   public class Modules
   {

      private static var _modules:* = {};

      private static const FRAME_UPDATE_INTERVAL:int = 100;

      private static var _lastFrameUpdate:int = 0;

      private static var _ratings:Object = {};

      private static var _hasRatings:Boolean = false;

      private static var _focus:String = "A-Z";

      private static const FOCI:Array = ["A-Z","Farm","Solo","Boss","Ultra","PvP"];

      private static const FOCUS_LABELS:Object = {
         "A-Z":"A-Z",
         "Farm":"Farming",
         "Solo":"Solo",
         "Boss":"Bossing",
         "Ultra":"Ultra",
         "PvP":"PvP"
      };

      private static const GOLD:uint = 15253850;

      private static const SCAN_MS:int = 250;

      private static const GRADE_NAME:String = "mvaGrade";

      private static const CHIP_NAME:String = "mvaFocus";

      private static const INFO_NAME:String = "mvaInfo";

      private static const ROW_H:Number = 30;

      private static var _lastScan:int = 0;

      private static var _drawn:Dictionary = new Dictionary(true);

      private static var _lvlCol:Number = 10000;

      private static var _titleMoved:Dictionary = new Dictionary(true);

      private static var _holder:DisplayObjectContainer = null;

      private static var _searchTf:TextField = null;

      private static var _bound:Dictionary = new Dictionary(true);

      private static var _hooked:Dictionary = new Dictionary(true);

      private static var _sel:Object = null;

      private static var _order:Array = null;

      private static var _orderKey:String = null;

      private static var _okKey:String = null;

      private static var _target:Array = null;

      private static var _targetKey:String = null;

      private static var _favStore:* = undefined;

      private static var _menuKey:String = "";

      private static var _dropsOn:Boolean = false;

      private static var _dropsKey:String = "";

      private static var _dropsSig:String = "";

      private static var _auraHudsOff:Dictionary = new Dictionary(true);

      private static var mhTrayScan:int = 0;

      private static const TI_SCALE:Number = 1.4;

      private static const TI_STRIP_X:Number = 6;

      private static const TI_LIST_Y:Number = 100;

      private static const TI_LIST_H:Number = 336;

      private static const TI_STRIP_W:Number = 30;

      private static const TI_NAME:String = "mvaTouchStrip";

      private static const TI_STARS_SCALE:Number = 1.35;

      private static const TI_NAME_X:Number = 38;

      private static var tiOn:Boolean = false;

      private static var tiUiOn:Boolean = true;

      private static var tiFilterOn:Boolean = true;

      private static const TI_SORTS:Array = [["A-Z",null],["All dmg","dmgall"],["Undead","undead"],["Human","human"],["Chaos","chaos"],["Dragonkin","dragonkin"],["Orc","orc"],["Drakath","drakath"],["Elemental","elemental"],["Gold","gold"],["XP","exp"],["Rep","rep"],["Class pts","cp"]];

      private static const TI_TYPE_ORDER:Array = ["Note","Resource","Item","Quest Item","ServerUse","Enhancement","Sword","Axe","Gauntlet","Dagger","HandGun","Rifle","Gun","Whip","Bow","Mace","Polearm","Staff","Wand","Class","Armor","Helm","Cape","Misc","Earring","Amulet","Necklace","Belt","Ring","Pet"];

      private static var tiSortIdx:int = 0;

      private static var tiVisible:Array = [];

      private static var tiBound:Dictionary = new Dictionary(true);

      private static var tiHooked:Dictionary = new Dictionary(true);

      private static var tiSel:* = null;

      private static var tiOrder:Array = null;

      private static var tiOrderKey:String = null;

      private static var tiOkKey:String = null;

      private static var tiTarget:Array = null;

      private static var tiTargetKey:String = null;

      private static const TI_ENH_COLORS:Object = {
         "Valiance":5227511,
         "Ravenous":15684432,
         "Dauntless":16747109,
         "Praxis":12216520,
         "Arcana\'s Concerto":9795021,
         "Elysium":5099745,
         "Acheron":7964363,
         "Lacerate":15037299,
         "Smite":15753874,
         "Spiral Carve":8505220,
         "Awe Blast":6600182,
         "Health Vamp":11457921,
         "Mana Vamp":9489145,
         "Powerword DIE":11583173,
         "Lament":5093036,
         "Vainglory":16740419,
         "Penitence":9479342,
         "Absolution":10275941,
         "Avarice":16027569,
         "Anima":13538264,
         "Pneuma":8445674,
         "Vim":16747136,
         "Examen":10463450,
         "Grimskull":10586239,
         "Forge":11771355
      };

      private static const TI_ENH_PLAIN:uint = 10400712;

      private static const TI_CHIP_BORDER:Object = {
         "dmg":15037299,
         "cp":6600182,
         "gold":10586239,
         "rep":8505220,
         "exp":12216520
      };

      private static const TI_GEAR:Array = ["Weapon","co","he","ba"];

      private static const TI_PROCS:Object = {
         "2":"Spiral Carve",
         "3":"Awe Blast",
         "4":"Health Vamp",
         "5":"Mana Vamp",
         "6":"Powerword DIE",
         "7":"Lacerate",
         "8":"Smite",
         "9":"Valiance",
         "10":"Arcana\'s Concerto",
         "11":"Acheron",
         "12":"Elysium",
         "13":"Praxis",
         "14":"Dauntless",
         "15":"Ravenous"
      };

      private static const TI_DMG:Object = {
         "dmgall":"All",
         "undead":"Undead",
         "human":"Human",
         "chaos":"Chaos",
         "dragonkin":"Dragonkin",
         "orc":"Orc",
         "drakath":"Drakath",
         "elemental":"Elemental"
      };

      private static const TI_BOOST_ART:Object = {
         "dmg":"damageBoost",
         "cp":"classBoost",
         "gold":"goldBoost",
         "rep":"repBoost",
         "exp":"xpBoost"
      };

      private static const TI_BOOST_ORDER:Array = ["dmg","cp","gold","rep","exp"];

      private static const TI_BOOST_LABEL:Object = {
         "cp":"Class",
         "gold":"Gold",
         "rep":"Rep",
         "exp":"XP"
      };

      private static var tiChipsFor:Dictionary = new Dictionary(true);

      private static const MH_POT_SCALE:Number = 1.25;

      private static const MH_POT_GAP:Number = 10;

      private static const MH_ANGLE:Array = [0,125,180,235,290];

      private static const MH_DASH_ANGLE:Number = 50;

      private static const MH_GAP:Number = 12;

      private static const MH_STEPS:Array = [1.5,1.25,1,0];

      private static const MH_STAGE_W:Number = 958;

      private static var mhOn:Boolean = false;

      private static var mhApplied:Boolean = false;

      private static var mhMobileClass:* = null;

      private static var mhBar:* = null;

      private static var mhBarX:Number = 0;

      private static var mhBarY:Number = 0;

      private static var mhSlot:Rectangle = null;

      private static var mhPitch:Number = 45;

      private static var mhSeen:Dictionary = new Dictionary(true);

      private static var mhScaled:Array = [];

      private static var mhHidden:Array = [];

      private static var mhMask:Shape = null;

      private static var mhMenu:* = null;

      private static var mhArea:* = null;

      private static var mhAreaY:Number = 0;

      private static var mhTray:* = null;

      private static var mhCluster:* = null;

      private static var mhClusterPos:Array = null;

      private static var mhClusterAt:int = 0;

      private static var mhPort:* = null;

      private static var mhPortX:Number = 0;

      private static var mhPortY:Number = 0;

      private static var mhTarget:* = null;

      private static var mhTargetX:Number = 0;

      private static var mhTargetY:Number = 0;

      private static var mhTargetW:Number = 0;

      private static var mhBtnP:Sprite = null;

      private static var mhBtnT:Sprite = null;

      private static var mhDrawn:Dictionary = new Dictionary(true);

      private static const MH_OPTS:Array = [["mvaUi","MVA UI","MVA: every MVA change to the game's screens at once. Off gives you the game's own UI everywhere; Improve FPS keeps its own switch.\nEach row below can also be switched on its own."],["mvaSidebar","Sidebar","MVA: big buttons for the game's menus on both sides of the screen, outside the game."],["mvaBigUi","Bigger UI","MVA: taller rows in every list window (inventory, shops, bank, quests) so a finger hits the right one.\nTakes effect the next time the game starts."],["mvaImproveFps","Improve FPS","MVA: smoother, steadier frames: in-between pictures, a frame governor that lowers graphics only when that helps, and removed objects left still.\nOff runs the game the way plain Ruffle does."],["mvaMobileLayout","Mobile Layout","MVA: lays out the game\'s mobile controls for phones while Mobile Controls is on.\nThe skill bar becomes your drops and potion, the skill buttons sit around auto attack, the portraits are larger, and the room\'s player count moves into the bar.\nOff gives the game\'s own layout."],["mvaJoystick","Dynamic Joystick","MVA: the joystick appears wherever your thumb lands on the left 35% of the screen, not only near its corner, so a move never turns into a tap.\nA touch that doesn\'t move is still a tap. Needs Mobile Controls."],["mvaLongDash","Long Dash","MVA: the mobile dash goes 3 times as far, like the classic dash across the screen.\nTakes effect the next time the game starts."],["mvaSwipe","Scrolling"
      ,"MVA: swipe lists, shops, quests and the chat with a finger."],["mvaAuras","Improved Auras","MVA: windows for your and your target\'s auras: stacks, timers, Decay and Enrage warnings, tap one for details."],["mvaInvUI","Inventory","MVA: larger inventory rows and category icons; classes show their rank, gear its enhancement.\nReopen the bag to see the change."],["mvaInvFilter","Inventory Filter","MVA: sort weapons, armor, helms and capes by a damage type or a boost (the Sort chip in the bag).\nReopen the bag to see the change."],["mvaClassRating","Star Rating","MVA: star ratings for classes in the inventory.\nReopen the bag to see the change."],["mvaDrops","Drops","MVA: drops wait in the Drops panel and the bar instead of popping up over the game."]];

      private static const MH_OPT_ONOFF:Object = {
         "mvaUi":["All MVA screen changes, each as set below.","The game's own UI everywhere (Improve FPS stays as set)."],
         "mvaSidebar":["Menu buttons on both sides of the screen.","No side buttons: the game uses the whole screen."],
         "mvaBigUi":["Taller list rows for fingers (from the next game start).","The game's normal row height."],
         "mvaImproveFps":["Smoother, steadier frames: in-between pictures, the frame governor, removed objects left still.","Frames the way plain Ruffle draws them."],
         "mvaMobileLayout":["Skill buttons around auto attack, drops and potion in the bar, bigger portraits.","The game\'s own mobile layout."],
         "mvaJoystick":["Put your thumb down anywhere on the left 35% to steer.","The game\'s normal joystick: only its fixed corner spot works."],
         "mvaLongDash":["The dash goes 3 times as far (from the next game start).","The game\'s normal short mobile dash."],
         "mvaSwipe":["Drag lists, shops, quests and the chat with a finger.","Use the scroll bars and arrows."],
         "mvaAuras":["Aura windows for you and your target, with stacks and timers.","Only the game\'s own aura icons."],
         "mvaInvUI":["Bigger rows and icons; class ranks and enhancements shown.","The game\'s normal inventory."],
         "mvaInvFilter":["A Sort chip in the bag: by damage type or boost.","The game\'s normal sorting."],
         "mvaClassRating":["Star ratings on classes in the inventory and preview.","No stars."],
         "mvaDrops":["Drops collect in the Drops panel and the bar.","Drops pop up over the game as usual."]
      };

      private static var mhOptRowOf:Object = {};

      private static var mhOptTagOf:Dictionary = new Dictionary(true);

      private static var mhGuide:Sprite = null;

      private static var mhGuideKnob:Shape = null;

      private static var mhGuideT:Number = 0;

      private static var mhOptTick:int = 0;

      private static var mhOptRows:Dictionary = new Dictionary(true);

      private static var mhOptSynced:Boolean = false;

      private static var mhOptPlaced:Dictionary = new Dictionary(true);

      private static const MH_JOY_ZONE:Rectangle = new Rectangle(0,0,336,500);

      private static var mhJoyTick:int = 0;

      private static var mhJoy:* = null;

      private static var mhJoyGame:Rectangle = null;

      private static var mhJoyOurs:Rectangle = null;

      private static const MH_B64:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

      public function Modules()
      {
         super();
      }

      public static function getModule(param1:String) : Module
      {
         return _modules[param1];
      }

      public static function registerModule(param1:Module) : void
      {
         _modules[param1.name] = param1;
      }

      public static function enable(param1:String) : void
      {
         var _loc3_:* = false;
         var _loc2_:Module = getModule(param1);
         if(_loc2_ != null)
         {
            _loc3_ = !_loc2_.enabled;
            _loc2_.enabled = true;
            if(_loc3_)
            {
               _loc2_.onToggle(Main.instance.getGame());
            }
         }
      }

      public static function disable(param1:String) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:Module = getModule(param1);
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.enabled;
            _loc2_.enabled = false;
            if(_loc3_)
            {
               _loc2_.onToggle(Main.instance.getGame());
            }
         }
      }

      public static function handleFrame(param1:Event) : void
      {
         var _loc3_:*;
         var _loc2_:int;
         var _loc4_:String = null;
         var _loc5_:Module = null;
         try
         {
            if(Main.instance.getGame() != null)
            {
               mhFrame(Main.instance.getGame());
            }
         }
         catch(uiErr4:Error)
         {
         }
         _loc2_ = int(getTimer());
         if(_loc2_ - _lastFrameUpdate < FRAME_UPDATE_INTERVAL)
         {
            return;
         }
         _lastFrameUpdate = _loc2_;
         _loc3_ = Main.instance.getGame();
         if(_loc3_ == null)
         {
            return;
         }
         try
         {
            mvaFrame(_loc3_);
         }
         catch(uiErr0:Error)
         {
         }
         try
         {
            menuFrame(_loc3_);
         }
         catch(uiErr1:Error)
         {
         }
         try
         {
            dropsFrame(_loc3_);
         }
         catch(uiErr2:Error)
         {
         }
         try
         {
            nativeAurasFrame(_loc3_);
         }
         catch(uiErr5:Error)
         {
         }
         try
         {
            touchInvFrame(_loc3_);
         }
         catch(uiErr3:Error)
         {
         }
         for(_loc4_ in _modules)
         {
            _loc5_ = _modules[_loc4_];
            if(_loc5_.enabled)
            {
               _loc5_.onFrame(_loc3_);
            }
         }
      }

      public static function init() : void
      {
      }

      public static function setRatings(json:String) : void
      {
         try
         {
            _ratings = JSON.parse(json);
            _hasRatings = true;
         }
         catch(e:Error)
         {
         }
      }

      public static function setFocus(focus:String) : void
      {
         if(FOCI.indexOf(focus) >= 0)
         {
            _focus = focus;
         }
      }

      private static function starCount(r:*) : int
      {
         var n:int = int((int(r) + 1) / 2);
         return n < 0 ? 0 : (n > 5 ? 5 : n);
      }

      private static function lookup(name:String) : Array
      {
         if(name == null)
         {
            return null;
         }
         var key:String = name.toLowerCase();
         var r:Array = _ratings[key] as Array;
         if(r == null)
         {
            var paren:int = int(key.indexOf(" ("));
            if(paren > 0)
            {
               r = _ratings[key.substr(0,paren)] as Array;
            }
         }
         return r;
      }

      private static function focusIndex() : int
      {
         switch(_focus)
         {
            case "Farm":
               return 2;
            case "Solo":
               return 3;
            case "Boss":
               return 4;
            case "Ultra":
               return 5;
            case "PvP":
               return 1;
            default:
               return 0;
         }
      }

      private static function drawStars(g:Graphics, x:Number, cy:Number, count:int, radius:Number, gap:Number) : void
      {
         var i:int = 0;
         while(i < 5)
         {
            var cx:Number = x + radius + i * gap;
            if(i < count)
            {
               g.lineStyle();
               g.beginFill(GOLD,1);
            }
            else
            {
               g.lineStyle(1,9071150,0.9);
               g.beginFill(2761500,0.85);
            }
            var k:int = 0;
            while(k <= 10)
            {
               var a:Number = -Math.PI / 2 + k * Math.PI / 5;
               var rr:Number = k % 2 == 0 ? radius : radius * 0.45;
               var px:Number = cx + rr * Math.cos(a);
               var py:Number = cy + rr * Math.sin(a);
               if(k == 0)
               {
                  g.moveTo(px,py);
               }
               else
               {
                  g.lineTo(px,py);
               }
               k++;
            }
            g.endFill();
            i++;
         }
         g.lineStyle();
      }

      private static function nativeAurasFrame(game:*) : void
      {
         var ours:Boolean = mvaOpt(game,"mvaAuras");
         for each(var hud in [game.pAurasUI,game.tAurasUI])
         {
            if(hud == null)
            {
               continue;
            }
            if(ours && hud.parent != null)
            {
               hud.parent.removeChild(hud);
               _auraHudsOff[hud] = true;
            }
            else if(!ours && hud.parent == null && _auraHudsOff[hud] && game.ui != null)
            {
               delete _auraHudsOff[hud];
               game.ui.addChild(hud);
            }
         }
      }

      private static function mvaFrame(game:*) : void
      {
         var now:int;
         var popup:*;
         var inventory:DisplayObjectContainer;
         if(!_hasRatings || !mvaOpt(game,"mvaClassRating"))
         {
            return;
         }
         now = getTimer();
         try
         {
            popup = game.ui.mcPopup;
            if(popup == null || !popup.visible || popup.currentLabel != "Inventory")
            {
               _holder = null;
               _searchTf = null;
               return;
            }
            if(_holder != null)
            {
               sortRows(game);
            }
            if(now - _lastScan < SCAN_MS)
            {
               return;
            }
            _lastScan = now;
            inventory = popup.getChildByName("mcInventory") as DisplayObjectContainer;
            if(inventory != null)
            {
               scan(inventory,0);
            }
         }
         catch(e:Error)
         {
         }
      }

      private static function scan(container:DisplayObjectContainer, depth:int) : void
      {
         var child:DisplayObject;
         var tf:TextField;
         var sub:DisplayObjectContainer;
         var item:*;
         var i:int = 0;
         while(i < container.numChildren)
         {
            child = container.getChildAt(i);
            if(child is TextField)
            {
               tf = child as TextField;
               if(tf.name == "tInfo")
               {
                  decorateInfo(tf);
               }
               else if(tf.name == "tTitle" && tf.text == "Inventory" && tf.parent != null)
               {
                  decorateTitle(tf);
               }
               else if(tf.type == "input")
               {
                  _searchTf = tf;
               }
            }
            else
            {
               sub = child as DisplayObjectContainer;
               if(!(sub == null || sub.name == CHIP_NAME || sub.name == INFO_NAME || sub.name == GRADE_NAME))
               {
                  item = null;
                  try
                  {
                     item = sub["item"];
                  }
                  catch(e:Error)
                  {
                  }
                  if(item != null && item.sType != null)
                  {
                     decorateRow(sub,item);
                     if(sub.parent != null)
                     {
                        _holder = sub.parent;
                     }
                  }
                  else if(depth < 6)
                  {
                     scan(sub,depth + 1);
                  }
               }
            }
            i++;
         }
      }

      private static function makeLabel(size:int, color:uint) : TextField
      {
         var tf:TextField = new TextField();
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.autoSize = TextFieldAutoSize.LEFT;
         tf.defaultTextFormat = new TextFormat("Arial",size,color,true);
         return tf;
      }

      private static function decorateRow(row:DisplayObjectContainer, item:*) : void
      {
         var badge:Sprite = row.getChildByName(GRADE_NAME) as Sprite;
         var r:Array = item.sType == "Class" ? lookup(item.sName) : null;
         if(r == null)
         {
            if(badge != null)
            {
               badge.visible = false;
            }
            return;
         }
         if(badge == null)
         {
            badge = new Sprite();
            badge.name = GRADE_NAME;
            badge.mouseEnabled = false;
            badge.mouseChildren = false;
            row.addChild(badge);
         }
         var stars:int = starCount(r[focusIndex()]);
         var width:Number = 4 * 8 + 7.2;
         if(_drawn[badge] !== stars)
         {
            var g:Graphics = badge.graphics;
            g.clear();
            g.lineStyle(1,5915944,1);
            g.beginFill(1183242,0.9);
            g.drawRoundRect(-5,-7,width + 10,14,12,12);
            g.endFill();
            drawStars(g,0,0,stars,3.6,8);
            _drawn[badge] = stars;
         }
         var nameTf:TextField = null;
         var lvlX:Number = 0;
         var i:int = 0;
         while(i < row.numChildren)
         {
            var tf:TextField = row.getChildAt(i) as TextField;
            if(tf != null)
            {
               var shown:String = tf.text;
               var cut:int = int(shown.indexOf("…"));
               if(cut < 0)
               {
                  cut = int(shown.indexOf("..."));
               }
               if(shown.indexOf(item.sName) == 0 || cut >= 4 && String(item.sName).indexOf(shown.substr(0,cut)) == 0)
               {
                  nameTf = tf;
               }
               else if(tf.text == "Lvl")
               {
                  lvlX = tf.x;
               }
            }
            i++;
         }
         if(nameTf == null)
         {
            badge.visible = false;
            return;
         }
         if(lvlX <= 0)
         {
            lvlX = row.width / (row.scaleX || 1) - 50;
         }
         if(lvlX < _lvlCol)
         {
            _lvlCol = lvlX;
         }
         badge.x = _lvlCol - 12 - width;
         badge.y = nameTf.y + 2 + nameTf.textHeight / 2;
         badge.visible = true;
      }

      private static function decorateInfo(tf:TextField) : void
      {
         var parent:DisplayObjectContainer = tf.parent;
         if(parent == null)
         {
            return;
         }
         var info:Sprite = parent.getChildByName(INFO_NAME) as Sprite;
         var lines:Array = tf.text.split("\r");
         var r:Array = lines.length >= 2 && String(lines[1]).indexOf("Class") == 0 ? lookup(lines[0]) : null;
         if(r == null || !parent.visible)
         {
            if(info != null)
            {
               info.visible = false;
            }
            return;
         }
         if(info == null)
         {
            info = new Sprite();
            info.name = INFO_NAME;
            info.mouseEnabled = false;
            info.mouseChildren = false;
            parent.addChild(info);
         }
         var key:String = _focus + "|" + r.join(",");
         if(_drawn[info] != key)
         {
            drawInfo(info,r);
            _drawn[info] = key;
         }
         info.x = tf.x + 2;
         info.y = tf.y - info.height - 4;
         info.visible = true;
      }

      private static function drawInfo(info:Sprite, r:Array) : void
      {
         while(info.numChildren > 0)
         {
            info.removeChildAt(0);
         }
         var g:Graphics = info.graphics;
         g.clear();
         var cells:Array = [["Farm",2,"Farm"],["Solo",3,"Solo"],["Boss",4,"Boss"],["Ultra",5,"Ultra"],["PvP",1,"PvP"]];
         var role:String = r.length > 6 ? String(r[6]) : "";
         var rowH:Number = 13;
         var height:Number = cells.length * rowH + (role.length > 0 ? rowH : 0) + 6;
         g.lineStyle(1,5915944,0.9);
         g.beginFill(1183242,0.78);
         g.drawRoundRect(-5,-3,92,height,10,10);
         g.endFill();
         var i:int = 0;
         while(i < cells.length)
         {
            var c:Array = cells[i];
            var y:Number = i * rowH;
            var focused:Boolean = c[2] == _focus;
            var label:TextField = makeLabel(10,focused ? 16777215 : GOLD);
            label.text = c[0];
            label.x = 0;
            label.y = y - 1;
            info.addChild(label);
            drawStars(g,38,y + 7,starCount(r[c[1]]),3.6,9);
            i++;
         }
         if(role.length > 0)
         {
            var roleLabel:TextField = makeLabel(9,13154458);
            roleLabel.text = role;
            roleLabel.x = 0;
            roleLabel.y = cells.length * rowH - 1;
            info.addChild(roleLabel);
         }
      }

      private static function decorateTitle(title:TextField) : void
      {
         var frame:DisplayObjectContainer = title.parent;
         if(_titleMoved[title] !== true)
         {
            title.x = title.x - (title.width - title.textWidth) / 2 + 14;
            _titleMoved[title] = true;
         }
         var chip:Sprite = frame.getChildByName(CHIP_NAME) as Sprite;
         if(chip == null)
         {
            chip = new Sprite();
            chip.name = CHIP_NAME;
            chip.buttonMode = true;
            chip.useHandCursor = true;
            chip.mouseChildren = false;
            var label:TextField = makeLabel(11,GOLD);
            label.name = "t";
            label.x = 8;
            label.y = 1;
            chip.addChild(label);
            chip.addEventListener(MouseEvent.CLICK,onChipClick,false,0,true);
            chip.addEventListener(MouseEvent.MOUSE_DOWN,stopEvent,false,0,true);
            chip.addEventListener(MouseEvent.MOUSE_UP,stopEvent,false,0,true);
            frame.addChild(chip);
         }
         var t:TextField = chip.getChildByName("t") as TextField;
         var text:String = "MVA: " + FOCUS_LABELS[_focus] + "  >";
         if(t.text != text)
         {
            t.text = text;
            chip.graphics.clear();
            chip.graphics.lineStyle(1,9071150);
            chip.graphics.beginFill(1840916,0.95);
            chip.graphics.drawRoundRect(0,0,t.width + 16,20,10,10);
            chip.graphics.endFill();
         }
         chip.x = title.x + (title.width - title.textWidth) / 2 + title.textWidth + 14;
         chip.y = title.y + (title.height - 20) / 2;
      }

      private static function favStore(game:*) : *
      {
         if(_favStore === undefined)
         {
            _favStore = null;
            try
            {
               _favStore = game.loaderInfo.applicationDomain.getDefinition("liteAssets.draw.FavStore");
            }
            catch(e:Error)
            {
            }
         }
         return _favStore;
      }

      private static function gameCompare(a:Object, b:Object) : int
      {
         var an:String = String(a.sName);
         var bn:String = String(b.sName);
         if(an != bn)
         {
            return an < bn ? -1 : 1;
         }
         var al:int = int(a.iLvl);
         var bl:int = int(b.iLvl);
         if(al != bl)
         {
            return al > bl ? -1 : 1;
         }
         var ai:int = int(a.ItemID);
         var bi:int = int(b.ItemID);
         if(ai != bi)
         {
            return ai < bi ? -1 : 1;
         }
         return 0;
      }

      private static function starCompare(a:Object, b:Object) : int
      {
         if(a.f != b.f)
         {
            return a.f ? -1 : 1;
         }
         if(a.s != b.s)
         {
            return a.s > b.s ? -1 : 1;
         }
         return a.i - b.i;
      }

      private static function modelOrder(game:*, fav:*) : void
      {
         var items:Array = game.world.myAvatar.items as Array;
         var q:String = _searchTf != null ? _searchTf.text : "";
         var key:String = q + "|" + (items != null ? items.length : 0) + "|" + (fav != null ? fav.version : 0);
         if(key != _orderKey)
         {
            _orderKey = key;
            _targetKey = null;
            var lq:String = q.toLowerCase();
            var list:Array = [];
            for each(var it in items)
            {
               if(!(it == null || it.sType != "Class"))
               {
                  if(!(lq.length > 0 && String(it.sName).toLowerCase().indexOf(lq) < 0))
                  {
                     list.push(it);
                  }
               }
            }
            list.sort(gameCompare);
            if(fav != null && fav.count > 0)
            {
               var favs:Array = [];
               var rest:Array = [];
               for each(it in list)
               {
                  if(fav.has(it.ItemID))
                  {
                     favs.push(it);
                  }
                  else
                  {
                     rest.push(it);
                  }
               }
               list = favs.concat(rest);
            }
            _order = list;
         }
         var tkey:String = key + "|" + _focus;
         if(tkey == _targetKey)
         {
            return;
         }
         _targetKey = tkey;
         if(_focus == "A-Z")
         {
            _target = _order;
            return;
         }
         var fi:int = focusIndex();
         var ranked:Array = [];
         var i:int = 0;
         while(i < _order.length)
         {
            var o:* = _order[i];
            var r:Array = lookup(o.sName);
            ranked.push({
               "it":o,
               "s":(r != null ? starCount(r[fi]) : -1),
               "i":i,
               "f":fav != null && fav.has(o.ItemID)
            });
            i++;
         }
         ranked.sort(starCompare);
         _target = [];
         for each(var e in ranked)
         {
            _target.push(e.it);
         }
      }

      private static function sortRows(game:*) : void
      {
         var rows:Array;
         var row:*;
         var i:int;
         var it:*;
         var fav:*;
         var idx:int;
         var checked:Boolean;
         var want:*;
         var holder:DisplayObjectContainer = _holder;
         if(holder == null || holder.stage == null)
         {
            return;
         }
         rows = [];
         i = 0;
         while(true)
         {
            if(i >= holder.numChildren)
            {
               if(rows.length == 0)
               {
                  return;
               }
               fav = favStore(game);
               modelOrder(game,fav);
               checked = false;
               for each(row in rows)
               {
                  if(!(_bound[row] != null && _bound[row] === row.item))
                  {
                     delete _bound[row];
                     idx = Math.round(row.y / crRowH());
                     if(_order[idx] !== row.item)
                     {
                        _okKey = null;
                        return;
                     }
                     checked = true;
                  }
               }
               if(checked)
               {
                  _okKey = _orderKey;
               }
               else if(_okKey != _orderKey)
               {
                  return;
               }
               for each(row in rows)
               {
                  idx = Math.round(row.y / crRowH());
                  want = _target[idx];
                  if(want != null)
                  {
                     if(_hooked[row] !== true)
                     {
                        row.addEventListener(MouseEvent.CLICK,onRowTap,false,0,true);
                        _hooked[row] = true;
                     }
                     if(row.item !== want)
                     {
                        row.bind(want,game,want === _sel,want.bEquip == 1 || want.bWear == 1);
                        decorateRow(row as DisplayObjectContainer,want);
                     }
                     if(want !== _order[idx])
                     {
                        _bound[row] = want;
                     }
                     else
                     {
                        delete _bound[row];
                     }
                  }
               }
               return;
            }
            row = holder.getChildAt(i);
            it = null;
            try
            {
               it = row["item"];
            }
            catch(e:Error)
            {
            }
            if(!(it == null || !row.visible))
            {
               if(it.sType != "Class")
               {
                  break;
               }
               rows.push(row);
            }
            i++;
         }
      }

      private static function onRowTap(e:MouseEvent) : void
      {
         try
         {
            _sel = e.currentTarget.item;
         }
         catch(err:Error)
         {
         }
      }

      private static function stopEvent(e:MouseEvent) : void
      {
         e.stopPropagation();
      }

      private static function onChipClick(e:MouseEvent) : void
      {
         var chip:DisplayObject;
         e.stopPropagation();
         _focus = FOCI[(FOCI.indexOf(_focus) + 1) % FOCI.length];
         _lastScan = 0;
         try
         {
            chip = e.currentTarget as DisplayObject;
            if(chip != null && chip.stage != null)
            {
               chip.stage.focus = null;
            }
         }
         catch(focusErr:Error)
         {
         }
         try
         {
            Main.instance.external.call("mvaRatingFocus",_focus);
         }
         catch(err:Error)
         {
         }
      }

      private static function cMenuOpen(game:*) : Boolean
      {
         var menu:* = game.ui.cMenu;
         return menu != null && Boolean(menu.visible) && menu.alpha >= 0.5;
      }

      private static function barList(game:*) : DisplayObjectContainer
      {
         var bar:*;
         var list:DisplayObjectContainer;
         try
         {
            bar = game.ui.mcInterface.mcMenu;
            if(bar == null || bar.menu == null)
            {
               return null;
            }
            list = bar.menu.mcMenu as DisplayObjectContainer;
            return list != null && list.stage != null ? list : null;
         }
         catch(e:Error)
         {
         }
         return null;
      }

      private static function barMenuKey(game:*) : String
      {
         var items:Array;
         var title:String;
         var i:int;
         var child:*;
         var label:*;
         var list:DisplayObjectContainer = barList(game);
         if(list == null)
         {
            return "";
         }
         items = [];
         title = "";
         i = 0;
         for(; i < list.numChildren; i++)
         {
            child = list.getChildAt(i);
            label = null;
            try
            {
               label = child.mTxt;
            }
            catch(e:Error)
            {
            }
            if(label != null)
            {
               items.unshift({
                  "i":i,
                  "t":String(label.text),
                  "on":child.hasEventListener(MouseEvent.CLICK)
               });
            }
            else
            {
               try
               {
                  if(child.txt != null)
                  {
                     title = String(child.txt.text);
                  }
               }
               catch(e2:Error)
               {
                  continue;
               }
            }
         }
         if(items.length == 0)
         {
            return "";
         }
         return JSON.stringify({
            "title":title,
            "items":items
         });
      }

      private static function menuItems(game:*) : Array
      {
         var items:Array = [];
         var menu:* = game.ui.cMenu;
         if(!cMenuOpen(game))
         {
            return items;
         }
         var cnt:DisplayObjectContainer = menu.getChildByName("cnt") as DisplayObjectContainer;
         if(cnt == null)
         {
            return items;
         }
         var i:int = 0;
         while(i < 40)
         {
            var item:DisplayObjectContainer = cnt.getChildByName("i" + i) as DisplayObjectContainer;
            if(item == null)
            {
               break;
            }
            if(item.visible)
            {
               var label:String = "";
               var ti:* = item.getChildByName("ti");
               if(ti != null)
               {
                  label = String(ti.text);
               }
               items.push({
                  "i":i,
                  "t":label,
                  "on":item.hasEventListener(MouseEvent.CLICK)
               });
            }
            i++;
         }
         return items;
      }

      private static function menuFrame(game:*) : void
      {
         var items:Array;
         var key:String = "";
         try
         {
            items = menuItems(game);
            if(items.length > 0)
            {
               key = JSON.stringify(items);
            }
            else
            {
               key = barMenuKey(game);
            }
         }
         catch(e:Error)
         {
         }
         if(key == _menuKey)
         {
            return;
         }
         _menuKey = key;
         try
         {
            Main.instance.external.call("mvaMenu",key);
         }
         catch(e2:Error)
         {
         }
      }

      public static function menuClick(index:int) : void
      {
         var game:*;
         var list:DisplayObjectContainer;
         var entry:DisplayObject;
         var cnt:DisplayObjectContainer;
         var item:DisplayObject;
         try
         {
            game = Main.instance.getGame();
            if(!cMenuOpen(game))
            {
               list = barList(game);
               if(list != null && index >= 0 && index < list.numChildren)
               {
                  entry = list.getChildAt(index);
                  if(entry.hasEventListener(MouseEvent.CLICK))
                  {
                     entry.dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false,1,1));
                  }
               }
               return;
            }
            cnt = Main.instance.getGame().ui.cMenu.getChildByName("cnt") as DisplayObjectContainer;
            item = cnt.getChildByName("i" + index);
            if(item != null && item.hasEventListener(MouseEvent.CLICK))
            {
               item.dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false,1,1));
            }
         }
         catch(e:Error)
         {
         }
      }

      public static function gameButton(name:String) : void
      {
         var menu:DisplayObjectContainer;
         var btn:DisplayObject;
         try
         {
            if(name == "temp")
            {
               Main.instance.getGame().ui.mcInterface.mcMenu.toggleTempInventory();
               return;
            }
            menu = Main.instance.getGame().ui.mcInterface.mcMenu as DisplayObjectContainer;
            btn = menu.getChildByName(name);
            if(btn != null && btn.hasEventListener(MouseEvent.CLICK))
            {
               btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false,1,1));
            }
         }
         catch(e:Error)
         {
         }
      }

      public static function menuClose() : void
      {
         var game:*;
         var menu:*;
         try
         {
            game = Main.instance.getGame();
            menu = game.ui.cMenu;
            if(menu != null && menu.visible)
            {
               menu.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT,true,false));
            }
            else if(barList(game) != null)
            {
               game.ui.mcInterface.mcMenu.handleMenu(null);
            }
         }
         catch(e:Error)
         {
         }
      }

      private static function dropStore(game:*) : *
      {
         var cls:Class;
         if(!_dropsOn || game == null || game.litePreference == null)
         {
            return null;
         }
         if(!mvaOpt(game,"mvaDrops"))
         {
            try
            {
               if(game.cDropsUI != null && !game.ui.mcPortrait.iconDrops.visible)
               {
                  game.ui.mcPortrait.iconDrops.visible = true;
               }
            }
            catch(eOpt:Error)
            {
            }
            return null;
         }
         if(!game.litePreference.data.bCustomDrops)
         {
            game.litePreference.data.bCustomDrops = true;
            game.litePreference.flush();
         }
         if(game.cDropsUI == null)
         {
            cls = game.loaderInfo.applicationDomain.getDefinition("liteAssets.draw.customDrops") as Class;
            game.cDropsUI = new cls(game);
         }
         try
         {
            if(game.ui.mcPortrait.iconDrops.visible)
            {
               game.ui.mcPortrait.iconDrops.visible = false;
            }
         }
         catch(e:Error)
         {
         }
         return game.cDropsUI;
      }

      private static function findDrop(store:*, id:int) : *
      {
         for each(var item in store.invTree)
         {
            if(item != null && int(item.ItemID) == id)
            {
               return item;
            }
         }
         return null;
      }

      private static function dropsFrame(game:*) : void
      {
         var list:Array;
         var item:*;
         var qty:*;
         var key:String;
         var store:* = dropStore(game);
         if(store == null)
         {
            return;
         }

         var sig:String = "";
         for each(item in store.invTree)
         {
            if(item != null)
            {
               qty = store.itemCount[item.dID];
               sig += int(item.ItemID) + ":" + (qty == null ? int(item.dQty) : int(qty)) + ",";
            }
         }
         if(sig == _dropsSig)
         {
            return;
         }
         _dropsSig = sig;
         list = [];
         for each(item in store.invTree)
         {
            if(item != null)
            {
               qty = store.itemCount[item.dID];
               list.push({
                  "id":int(item.ItemID),
                  "n":String(item.sName),
                  "q":(qty == null ? int(item.dQty) : int(qty)),
                  "t":String(item.sType),
                  "ac":int(item.bCoins) == 1,
                  "mem":int(item.bUpg) == 1,
                  "r":int(item.iRty),
                  "i":String(item.sIcon)
               });
            }
         }
         key = JSON.stringify(list);
         if(key == _dropsKey)
         {
            return;
         }
         _dropsKey = key;
         try
         {
            Main.instance.external.call("mvaDrops",key);
         }
         catch(e:Error)
         {
         }
      }

      public static function dropsOn(on:Boolean) : void
      {
         var game:*;
         _dropsOn = on;
         _dropsKey = "";
         _dropsSig = "";
         if(on)
         {
            return;
         }
         try
         {
            game = Main.instance.getGame();
            if(game.cDropsUI != null)
            {
               game.ui.mcPortrait.iconDrops.visible = true;
            }
         }
         catch(e:Error)
         {
         }
      }

      public static function dropAccept(id:int) : String
      {
         var store:*;
         var item:*;
         try
         {
            store = dropStore(Main.instance.getGame());
            item = store == null ? null : findDrop(store,id);
            if(item == null)
            {
               return "";
            }
            return store.requestDrop(item,true) ? "ok" : "full";
         }
         catch(e:Error)
         {
         }
         return "";
      }

      public static function dropPreview(id:int) : void
      {
         var store:*;
         var item:*;
         try
         {
            store = dropStore(Main.instance.getGame());
            item = store == null ? null : findDrop(store,id);
            if(item != null)
            {
               store.previewDrop(item);
            }
         }
         catch(e:Error)
         {
         }
      }

      public static function dropDecline(id:int) : void
      {
         var store:*;
         var item:*;
         try
         {
            store = dropStore(Main.instance.getGame());
            item = store == null ? null : findDrop(store,id);
            if(item != null)
            {
               store.onBtNo(item);
            }
         }
         catch(e:Error)
         {
         }
      }

      private static function crRowH() : Number
      {
         var c:*;
         try
         {
            c = Main.instance.getGame().loaderInfo.applicationDomain.getDefinition("LPFFrameInvAQ");
            if(c.ROW_H > 0)
            {
               return c.ROW_H;
            }
         }
         catch(e:Error)
         {
         }
         return ROW_H;
      }

      public static function setTouchUi(on:Boolean) : void
      {
         tiOn = on;
         mhOn = on;
      }

      private static function touchInvFrame(game:*) : void
      {
         if(!tiOn)
         {
            return;
         }
         tiUiOn = mvaOpt(game,"mvaInvUI");
         tiFilterOn = mvaOpt(game,"mvaInvFilter");
         if(!tiUiOn && !tiFilterOn)
         {
            return;
         }
         var popup:DisplayObjectContainer = game.ui.mcPopup as DisplayObjectContainer;
         if(popup == null || popup.numChildren == 0)
         {
            return;
         }
         tiVisit(popup,0);
      }

      private static function tiVisit(c:DisplayObjectContainer, depth:int) : void
      {
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObject = c.getChildAt(i);
            if(d is DisplayObjectContainer)
            {
               if(getQualifiedClassName(d) == "LPFFrameInvAQ")
               {
                  tiPatch(d as DisplayObjectContainer);
               }
               else if(depth < 5)
               {
                  tiVisit(d as DisplayObjectContainer,depth + 1);
               }
            }
            i++;
         }
      }

      private static function tiPatch(frame:DisplayObjectContainer) : void
      {
         var i:int = 0;
         while(i < frame.numChildren)
         {
            var s:Sprite = frame.getChildAt(i) as Sprite;
            if(tiUiOn && s != null && (s.name == TI_NAME || s.x == 14 && s.y == TI_LIST_Y && s.numChildren > 0 && s.getChildAt(0) is Sprite))
            {
               if(s.name != TI_NAME)
               {
                  s.name = TI_NAME;
                  s.x = TI_STRIP_X;
                  s.scaleX = s.scaleY = TI_SCALE;
                  s.scrollRect = new Rectangle(0,0,TI_STRIP_W,TI_LIST_H / TI_SCALE);
                  s.addEventListener(MouseEvent.MOUSE_WHEEL,tiWheel,false,0,true);
               }
               tiScroll(s,0);
            }
            i++;
         }
         tiVisible = [];
         tiRows(frame,0);
         tiSort(frame);
         if(tiUiOn)
         {
            tiPreview(frame.parent,0);
         }
      }

      private static function tiSort(frame:DisplayObjectContainer) : void
      {
         var cat:String;
         var rows:Array;
         var row:*;
         var it:*;
         var game:*;
         var fav:*;
         var rowH:Number;
         var idx:int;
         var checked:Boolean;
         var want:*;
         if(!tiFilterOn && tiSortIdx != 0)
         {
            tiSortIdx = 0;
            tiTargetKey = null;
         }
         cat = null;
         rows = [];
         var _loc3_:int = 0;
         var _loc4_:* = tiVisible;
         while(true)
         {
            for each(row in _loc4_)
            {
               it = null;
               try
               {
                  it = row.item;
               }
               catch(e:Error)
               {
               }
               if(it != null)
               {
                  if(TI_GEAR.indexOf(String(it.sES)) < 0 || cat != null && cat != String(it.sES))
                  {
                     break;
                  }
                  cat = String(it.sES);
                  rows.push(row);
               }
            }
            tiSortChip(frame,cat != null && tiFilterOn);
            if(cat == null)
            {
               return;
            }
            game = Main.instance.getGame();
            fav = null;
            try
            {
               fav = game.loaderInfo.applicationDomain.getDefinition("liteAssets.draw.FavStore");
            }
            catch(e2:Error)
            {
            }
            tiModel(game,cat,frame,fav);
            rowH = tiRowH();
            checked = false;
            for each(row in rows)
            {
               if(!(tiBound[row] != null && tiBound[row] === row.item))
               {
                  delete tiBound[row];
                  idx = Math.round(row.y / rowH);
                  if(tiOrder[idx] !== row.item)
                  {
                     tiOkKey = null;
                     return;
                  }
                  checked = true;
               }
            }
            if(checked)
            {
               tiOkKey = tiOrderKey;
            }
            else if(tiOkKey != tiOrderKey)
            {
               return;
            }
            for each(row in rows)
            {
               idx = Math.round(row.y / rowH);
               want = tiTarget[idx];
               if(want != null)
               {
                  if(tiHooked[row] !== true)
                  {
                     row.addEventListener(MouseEvent.CLICK,tiRowTap,false,0,true);
                     tiHooked[row] = true;
                  }
                  if(row.item !== want)
                  {
                     row.bind(want,game,want === tiSel,want.bEquip == 1 || want.bWear == 1);
                     tiRow(row);
                  }
                  if(want !== tiOrder[idx])
                  {
                     tiBound[row] = want;
                  }
                  else
                  {
                     delete tiBound[row];
                  }
               }
            }
            return;
         }
         tiSortChip(frame,false);
      }

      private static function tiRowTap(e:MouseEvent) : void
      {
         try
         {
            tiSel = e.currentTarget.item;
         }
         catch(err:Error)
         {
         }
      }

      private static function tiModel(game:*, cat:String, frame:DisplayObjectContainer, fav:*) : void
      {
         var items:Array = game.world.myAvatar.items as Array;
         var search:TextField = tiFindSearch(frame,0);
         var q:String = search != null ? search.text.toLowerCase() : "";
         var key:String = cat + "|" + q + "|" + (items != null ? items.length : 0) + "|" + (fav != null ? fav.count : 0);
         if(key != tiOrderKey)
         {
            tiOrderKey = key;
            tiTargetKey = null;
            var list:Array = [];
            for each(var it in items)
            {
               if(it != null && String(it.sES) == cat && it.sType != "Enhancement" && (q.length == 0 || String(it.sName).toLowerCase().indexOf(q) >= 0))
               {
                  list.push(it);
               }
            }
            list.sort(tiGameCompare);
            if(fav != null && fav.count > 0)
            {
               var favs:Array = [];
               var rest:Array = [];
               for each(it in list)
               {
                  if(fav.has(it.ItemID))
                  {
                     favs.push(it);
                  }
                  else
                  {
                     rest.push(it);
                  }
               }
               list = favs.concat(rest);
            }
            tiOrder = list;
         }
         var tkey:String = key + "|" + tiSortIdx;
         if(tkey == tiTargetKey)
         {
            return;
         }
         tiTargetKey = tkey;
         var by:String = TI_SORTS[tiSortIdx][1];
         if(by == null)
         {
            tiTarget = tiOrder;
            return;
         }
         var ranked:Array = [];
         var i:int = 0;
         while(i < tiOrder.length)
         {
            ranked.push({
               "it":tiOrder[i],
               "v":tiBoostValue(tiOrder[i].sMeta,by),
               "i":i
            });
            i++;
         }
         ranked.sort(tiRankCompare);
         tiTarget = [];
         for each(var r in ranked)
         {
            tiTarget.push(r.it);
         }
      }

      private static function tiRankCompare(a:Object, b:Object) : int
      {
         if(a.v != b.v)
         {
            return a.v > b.v ? -1 : 1;
         }
         return a.i - b.i;
      }

      private static function tiGameCompare(a:Object, b:Object) : int
      {
         var ar:int = int(TI_TYPE_ORDER.indexOf(String(a.sType)));
         var br:int = int(TI_TYPE_ORDER.indexOf(String(b.sType)));
         if(ar < 0)
         {
            ar = 10000;
         }
         if(br < 0)
         {
            br = 10000;
         }
         if(ar != br)
         {
            return ar < br ? -1 : 1;
         }
         if(ar == 10000 && String(a.sType) != String(b.sType))
         {
            return String(a.sType) < String(b.sType) ? -1 : 1;
         }
         var an:String = String(a.sName);
         var bn:String = String(b.sName);
         if(an != bn)
         {
            return an < bn ? -1 : 1;
         }
         if(int(a.iLvl) != int(b.iLvl))
         {
            return int(a.iLvl) > int(b.iLvl) ? -1 : 1;
         }
         if(int(a.ItemID) != int(b.ItemID))
         {
            return int(a.ItemID) < int(b.ItemID) ? -1 : 1;
         }
         return 0;
      }

      private static function tiBoostValue(meta:*, by:String) : Number
      {
         if(meta == null || meta is Number)
         {
            return -1;
         }
         for each(var part in String(meta).split(","))
         {
            var kv:Array = part.split(":");
            if(kv.length >= 2 && String(kv[0]).toLowerCase() == by && !isNaN(Number(kv[1])))
            {
               return Math.round((Number(kv[1]) - 1) * 100);
            }
         }
         return -1;
      }

      private static function tiFindSearch(c:DisplayObjectContainer, depth:int) : TextField
      {
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObject = c.getChildAt(i);
            if(d is TextField && TextField(d).type == "input")
            {
               return d as TextField;
            }
            if(d is DisplayObjectContainer && depth < 3 && d.name != "mvaSortMenu")
            {
               var found:TextField = tiFindSearch(d as DisplayObjectContainer,depth + 1);
               if(found != null)
               {
                  return found;
               }
            }
            i++;
         }
         return null;
      }

      private static function tiSortChip(frame:DisplayObjectContainer, show:Boolean) : void
      {
         var panel:DisplayObjectContainer = frame.parent;
         if(panel == null)
         {
            return;
         }
         var anchor:DisplayObject = null;
         var i:int = 0;
         while(i < panel.numChildren && anchor == null)
         {
            var c:DisplayObjectContainer = panel.getChildAt(i) as DisplayObjectContainer;
            if(c != null)
            {
               anchor = c.getChildByName("mvaFocus");
            }
            i++;
         }
         if(anchor == null)
         {
            return;
         }
         var holder:DisplayObjectContainer = anchor.parent;
         var chip:Sprite = holder.getChildByName("mvaSort") as Sprite;
         var menu:Sprite = panel.getChildByName("mvaSortMenu") as Sprite;
         if(!show)
         {
            if(chip != null)
            {
               chip.visible = false;
            }
            if(menu != null)
            {
               menu.visible = false;
            }
            return;
         }
         var label:String = "Sort: " + TI_SORTS[tiSortIdx][0];
         if(chip == null)
         {
            chip = new Sprite();
            chip.name = "mvaSort";
            chip.buttonMode = true;
            chip.mouseChildren = false;
            var tf:TextField = new TextField();
            tf.name = "t";
            tf.selectable = false;
            tf.mouseEnabled = false;
            tf.autoSize = "left";
            tf.defaultTextFormat = new TextFormat("Arial",12,16777215,true);
            tf.x = 8;
            tf.y = 1;
            chip.addChild(tf);
            chip.addEventListener(MouseEvent.CLICK,tiSortChipTap,false,0,true);
            holder.addChild(chip);
         }
         var t:TextField = chip.getChildByName("t") as TextField;
         if(t.text != label)
         {
            t.text = label;
            chip.graphics.clear();
            chip.graphics.lineStyle(1,8164277,1);
            chip.graphics.beginFill(1054239,0.95);
            chip.graphics.drawRoundRect(0,0,t.width + 16,21,10,10);
            chip.graphics.endFill();
         }
         chip.x = anchor.x + anchor.width + 6;
         chip.y = anchor.y;
         chip.visible = true;
         if(menu != null && menu.visible)
         {
            tiPlaceMenu(menu,chip);
         }
      }

      private static function tiPlaceMenu(menu:Sprite, chip:Sprite) : void
      {
         var at:Point = menu.parent.globalToLocal(chip.parent.localToGlobal(new Point(chip.x,chip.y + 25)));
         menu.x = at.x;
         menu.y = at.y;
         menu.parent.setChildIndex(menu,menu.parent.numChildren - 1);
      }

      private static function tiSortChipTap(e:MouseEvent) : void
      {
         var chip:Sprite = e.currentTarget as Sprite;
         var holder:DisplayObjectContainer = chip.parent.parent;
         var menu:Sprite = holder.getChildByName("mvaSortMenu") as Sprite;
         if(menu == null)
         {
            menu = new Sprite();
            menu.name = "mvaSortMenu";
            var w:Number = 110;
            var h:Number = 26;
            menu.graphics.lineStyle(1,8164277,1);
            menu.graphics.beginFill(1054239,0.97);
            menu.graphics.drawRoundRect(0,0,w,TI_SORTS.length * h + 6,10,10);
            menu.graphics.endFill();
            var i:int = 0;
            while(i < TI_SORTS.length)
            {
               var opt:Sprite = new Sprite();
               opt.name = String(i);
               opt.buttonMode = true;
               opt.mouseChildren = false;
               opt.graphics.beginFill(16777215,0.001);
               opt.graphics.drawRect(0,0,w,h);
               opt.graphics.endFill();
               var tf:TextField = new TextField();
               tf.selectable = false;
               tf.mouseEnabled = false;
               tf.autoSize = "left";
               tf.defaultTextFormat = new TextFormat("Arial",13,16777215,true);
               tf.text = TI_SORTS[i][0];
               tf.x = 10;
               tf.y = Math.round((h - tf.height) / 2);
               opt.addChild(tf);
               opt.y = 3 + i * h;
               opt.addEventListener(MouseEvent.CLICK,tiSortPick,false,0,true);
               menu.addChild(opt);
               i++;
            }
            holder.addChild(menu);
            menu.visible = false;
         }
         menu.visible = !menu.visible;
         tiPlaceMenu(menu,chip);
         e.stopPropagation();
      }

      private static function tiSortPick(e:MouseEvent) : void
      {
         var opt:Sprite = e.currentTarget as Sprite;
         tiSortIdx = int(opt.name);
         if(opt.parent != null)
         {
            opt.parent.visible = false;
         }
         tiTargetKey = null;
         e.stopPropagation();
      }

      private static function tiPreview(c:DisplayObjectContainer, depth:int) : void
      {
         if(c == null)
         {
            return;
         }
         var root:DisplayObjectContainer = c;
         while(depth < 3 && root.parent != null && root.name != "mcInventory")
         {
            root = root.parent;
            depth++;
         }
         var tf:TextField = tiFindInfo(root,0);
         if(tf != null)
         {
            tiPreviewCard(tf);
         }
      }

      private static function tiFindInfo(c:DisplayObjectContainer, depth:int) : TextField
      {
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObject = c.getChildAt(i);
            if(d is TextField && d.name == "tInfo")
            {
               return d as TextField;
            }
            if(d is DisplayObjectContainer && depth < 5)
            {
               var found:TextField = tiFindInfo(d as DisplayObjectContainer,depth + 1);
               if(found != null)
               {
                  return found;
               }
            }
            i++;
         }
         return null;
      }

      private static function tiPreviewCard(tf:TextField) : void
      {
         var parent:DisplayObjectContainer = tf.parent;
         var card:Sprite = parent.getChildByName("mvaGearInfo") as Sprite;
         var item:* = parent.visible ? tiItemNamed(String(tf.text.split("\r")[0])) : null;
         var enh:String = item != null && TI_GEAR.indexOf(String(item.sES)) >= 0 ? tiEnhName(item) : null;
         var boosts:Array = item != null && TI_GEAR.indexOf(String(item.sES)) >= 0 ? tiBoosts(item.sMeta) : [];
         if(item == null || enh == null && boosts.length == 0)
         {
            if(card != null)
            {
               card.visible = false;
            }
            return;
         }
         if(card == null)
         {
            card = new Sprite();
            card.name = "mvaGearInfo";
            card.mouseEnabled = false;
            card.mouseChildren = false;
            parent.addChild(card);
         }
         if(tiChipsFor[card] !== item)
         {
            tiChipsFor[card] = item;
            while(card.numChildren > 0)
            {
               card.removeChildAt(0);
            }
            card.graphics.clear();
            var y:Number = 0;
            if(enh != null)
            {
               var label:TextField = new TextField();
               label.selectable = false;
               label.mouseEnabled = false;
               label.autoSize = "left";
               label.defaultTextFormat = new TextFormat(tf.getTextFormat(0).font,13,tiEnhColor(enh),true);
               label.text = enh;
               card.addChild(label);
               y = label.height + 1;
            }
            if(boosts.length > 0)
            {
               var chips:Sprite = tiChips(card,null,item,boosts,tf.getTextFormat(0),true);
               chips.y = y + 10;
            }
         }
         card.x = tf.x + 2;
         card.y = tf.y - card.height - 2;
         card.visible = true;
      }

      private static function tiItemNamed(name:String) : *
      {
         var it:*;
         try
         {
            for each(it in Main.instance.getGame().world.myAvatar.items)
            {
               if(it != null && it.sName == name)
               {
                  return it;
               }
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }

      private static function tiRows(c:DisplayObjectContainer, depth:int) : void
      {
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObjectContainer = c.getChildAt(i) as DisplayObjectContainer;
            if(d != null && d.visible)
            {
               if(getQualifiedClassName(d) == "LPFElementInvAQRow")
               {
                  tiVisible.push(d);
                  if(tiUiOn)
                  {
                     tiRow(d);
                  }
               }
               else if(depth < 3)
               {
                  tiRows(d,depth + 1);
               }
            }
            i++;
         }
      }

      private static function tiRow(row:DisplayObjectContainer) : void
      {
         var name:String;
         var rowH:Number;
         var y1:Number;
         var y2:Number;
         var nameTf:TextField;
         var lvlLabel:TextField;
         var lvlTf:TextField;
         var rankTf:TextField;
         var i:int;
         var tf:TextField;
         var t:String;
         var right:Number;
         var colW:Number;
         var cx:Number;
         var label:String;
         var labelColor:int;
         var boosts:Array;
         var badge:DisplayObject;
         var chips:Sprite;
         var fmt:TextFormat;
         var full:String;
         var ri:int;
         var iconX:Number;
         var lineRight:Number;
         var b:Rectangle;
         var room:Number;
         var b2:Rectangle;
         var item:* = null;
         var rowW:Number = 0;
         try
         {
            item = row["item"];
            rowW = Number(row["rowW"]);
         }
         catch(e:Error)
         {
         }
         if(item == null || item.sName == null || rowW <= 0)
         {
            return;
         }
         name = String(item.sName);
         rowH = tiRowH();
         y1 = Math.round(rowH * 0.3);
         y2 = Math.round(rowH * 0.7);
         nameTf = null;
         lvlLabel = null;
         lvlTf = null;
         rankTf = row.getChildByName("mvaRank") as TextField;
         i = 0;
         while(i < row.numChildren)
         {
            tf = row.getChildAt(i) as TextField;
            if(tf != null && tf.visible && tf != rankTf)
            {
               t = tf.text;
               if(t == "Lvl")
               {
                  lvlLabel = tf;
               }
               else if(t.length > 0 && t.length < 5 && !isNaN(Number(t)) && tf.x > rowW / 2)
               {
                  lvlTf = tf;
               }
               else if(nameTf == null && tiNameStart(t,name))
               {
                  nameTf = tf;
               }
            }
            i++;
         }
         right = rowW - 6;
         if(lvlTf != null)
         {
            colW = Math.max(lvlLabel != null ? lvlLabel.textWidth : 0,lvlTf.textWidth) + 4;
            cx = right - colW / 2;
            lvlTf.x = Math.round(cx - lvlTf.width / 2);
            lvlTf.y = Math.round(y2 - lvlTf.height / 2);
            if(lvlLabel != null)
            {
               lvlLabel.x = Math.round(cx - lvlLabel.width / 2);
               lvlLabel.y = Math.round(y1 - lvlLabel.height / 2);
            }
            right -= colW + 6;
         }
         if(nameTf == null)
         {
            return;
         }
         label = null;
         labelColor = -1;
         boosts = null;
         if(item.sES == "ar" && int(item.EnhID) > 0)
         {
            try
            {
               label = "Rank " + Main.instance.getGame().getRankFromPoints(int(item.iQty));
            }
            catch(e2:Error)
            {
            }
         }
         else if(TI_GEAR.indexOf(String(item.sES)) >= 0)
         {
            boosts = tiBoosts(item.sMeta);
            label = tiEnhName(item);
            labelColor = int(tiEnhColor(label));
            if(label == null && boosts.length > 0)
            {
               label = "";
            }
         }
         badge = row.getChildByName("mvaGrade");
         chips = row.getChildByName("mvaBoosts") as Sprite;
         if(label != null)
         {
            if(rankTf == null)
            {
               rankTf = new TextField();
               rankTf.name = "mvaRank";
               rankTf.selectable = false;
               rankTf.mouseEnabled = false;
               rankTf.autoSize = "left";
               row.addChild(rankTf);
            }
            fmt = nameTf.getTextFormat(0);
            fmt.color = 10066329;
            full = nameTf.text;
            ri = int(full.lastIndexOf(", Rank"));
            if(ri >= 0)
            {
               fmt = nameTf.getTextFormat(ri + 2);
            }
            if(labelColor >= 0)
            {
               fmt.color = labelColor;
            }
            rankTf.defaultTextFormat = fmt;
            if(ri >= 0)
            {
               nameTf.replaceText(0,nameTf.length,name);
            }
            else
            {
               tiFullName(nameTf,name);
            }
            rankTf.text = label;
            rankTf.visible = label.length > 0;
            iconX = tiLiftIcon(row,y1);
            rankTf.x = Math.round(iconX + 4);
            rankTf.y = Math.round(y1 - rankTf.height / 2);
            lineRight = right;
            if(badge != null && badge.visible)
            {
               badge.scaleX = badge.scaleY = TI_STARS_SCALE;
               b = badge.getBounds(badge);
               badge.x = Math.round(right - b.right * TI_STARS_SCALE);
               badge.y = Math.round(rowH / 2);
               lineRight = badge.x + b.left * TI_STARS_SCALE - 6;
            }
            if(boosts != null && boosts.length > 0)
            {
               chips = tiChips(row,chips,item,boosts,nameTf.getTextFormat(0));
               chips.x = Math.round((rankTf.visible ? rankTf.x + rankTf.width : iconX) + 10);
               chips.y = y1;
               chips.scaleX = chips.scaleY = 1;
               room = lineRight - 4 - chips.x;
               if(chips.width > room && room > 20)
               {
                  chips.scaleX = chips.scaleY = room / chips.width;
               }
               chips.visible = true;
            }
            else if(chips != null)
            {
               chips.visible = false;
            }
            nameTf.wordWrap = false;
            nameTf.x = 8;
            nameTf.width = Math.max(40,lineRight - 8);
            nameTf.height = nameTf.textHeight + 4;
            nameTf.y = Math.round(y2 - nameTf.height / 2);
            return;
         }
         if(chips != null)
         {
            chips.visible = false;
         }
         if(rankTf != null)
         {
            rankTf.visible = false;
         }
         tiLiftIcon(row,Math.round(rowH / 2));
         nameTf.x = TI_NAME_X;
         if(badge != null && badge.visible)
         {
            badge.scaleX = badge.scaleY = TI_STARS_SCALE;
            b2 = badge.getBounds(badge);
            badge.x = Math.round(right - b2.right * TI_STARS_SCALE);
            badge.y = Math.round(rowH / 2);
            right = badge.x + b2.left * TI_STARS_SCALE - 6;
         }
         tiFullName(nameTf,name);
         nameTf.wordWrap = true;
         nameTf.multiline = true;
         nameTf.width = Math.max(40,right - nameTf.x);
         nameTf.height = nameTf.textHeight + 4;
         nameTf.y = Math.round((rowH - nameTf.height) / 2);
      }

      private static function tiEnhColor(name:String) : uint
      {
         return name != null && TI_ENH_COLORS[name] != null ? uint(TI_ENH_COLORS[name]) : TI_ENH_PLAIN;
      }

      private static function tiEnhPattern(item:*) : *
      {
         try
         {
            if(item.EnhPatternID != null)
            {
               return Main.instance.getGame().world.enhPatternTree[item.EnhPatternID];
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }

      private static function tiEnhDis(item:*) : Boolean
      {
         var enh:* = tiEnhPattern(item);
         return enh != null && Boolean(enh.hasOwnProperty("DIS"));
      }

      private static function tiEnhName(item:*) : String
      {
         var game:*;
         var shown:String;
         var enh:* = tiEnhPattern(item);
         if(enh == null)
         {
            return null;
         }
         game = Main.instance.getGame();
         try
         {
            if(int(item.ProcID) > 0 && !enh.hasOwnProperty("DIS") && TI_PROCS[int(item.ProcID)] != null)
            {
               return TI_PROCS[int(item.ProcID)];
            }
            shown = game.getDisplayEnhName(enh);
            if(enh.hasOwnProperty("DIS") && shown == "Forge")
            {
               return game.getDisplayEnhTraitName(enh);
            }
            return shown;
         }
         catch(e:Error)
         {
         }
         return enh.sName != null ? String(enh.sName) : null;
      }

      private static function tiBoosts(meta:*) : Array
      {
         var out:Array = [];
         if(meta == null || meta is Number || String(meta).indexOf(":") < 0)
         {
            return out;
         }
         var found:Object = {};
         for each(var part in String(meta).split(","))
         {
            var kv:Array = part.split(":");
            if(!(kv.length < 2 || isNaN(Number(kv[1]))))
            {
               var pct:String = "+" + Math.round((Number(kv[1]) - 1) * 100) + "%";
               var key:String = String(kv[0]).toLowerCase();
               if(TI_DMG[key] != null)
               {
                  if(found.dmg == null)
                  {
                     found.dmg = [];
                  }
                  found.dmg.push(TI_DMG[key] + " " + pct);
               }
               else if(TI_BOOST_ART[key] != null)
               {
                  found[key] = [pct];
               }
            }
         }
         for each(var kind in TI_BOOST_ORDER)
         {
            for each(var text in found[kind])
            {
               out.push([kind,text]);
            }
         }
         return out;
      }

      private static function tiChips(row:DisplayObjectContainer, chips:Sprite, item:*, boosts:Array, fmt:TextFormat, vertical:Boolean = false) : Sprite
      {
         var domain:*;
         var x:Number;
         var f:TextFormat;
         var b:Array;
         var card:Sprite;
         var cx:Number;
         var drawn:Boolean;
         var art:Class;
         var icon:DisplayObject;
         var r:Rectangle;
         var tf:TextField;
         var w:Number;
         if(chips == null)
         {
            chips = new Sprite();
            chips.name = "mvaBoosts";
            chips.mouseEnabled = false;
            chips.mouseChildren = false;
            row.addChild(chips);
         }
         if(tiChipsFor[chips] === item)
         {
            return chips;
         }
         tiChipsFor[chips] = item;
         while(chips.numChildren > 0)
         {
            chips.removeChildAt(0);
         }
         domain = Main.instance.getGame().loaderInfo.applicationDomain;
         x = 0;
         f = new TextFormat(fmt.font,11,15921906,true);
         for each(b in boosts)
         {
            card = new Sprite();
            chips.addChild(card);
            cx = 4;
            drawn = false;
            try
            {
               art = domain.getDefinition(TI_BOOST_ART[b[0]]) as Class;
               icon = new art() as DisplayObject;
               card.addChild(icon);
               icon.width = icon.height = 15;
               r = icon.getBounds(card);
               icon.x += cx - r.left;
               icon.y += -7.5 - r.top;
               cx += 17;
               drawn = true;
            }
            catch(e:Error)
            {
            }
            tf = new TextField();
            tf.selectable = false;
            tf.mouseEnabled = false;
            tf.autoSize = "left";
            tf.defaultTextFormat = f;
            tf.text = drawn || b[0] == "dmg" ? b[1] : TI_BOOST_LABEL[b[0]] + " " + b[1];
            tf.x = cx;
            tf.y = Math.round(-tf.height / 2);
            card.addChild(tf);
            w = cx + tf.width + 3;
            card.graphics.lineStyle(1,uint(TI_CHIP_BORDER[b[0]]),1);
            card.graphics.beginFill(920330,0.88);
            card.graphics.drawRoundRect(0,-10,w,20,10,10);
            card.graphics.endFill();
            if(vertical)
            {
               card.y = chips.numChildren * 22 - 22;
            }
            else
            {
               card.x = x;
               x += w + 5;
            }
         }
         return chips;
      }

      private static function tiLiftIcon(row:DisplayObjectContainer, y1:Number) : Number
      {
         var nameX:Number = TI_NAME_X;
         var right:Number = nameX - 4;
         var i:int = 0;
         while(i < row.numChildren)
         {
            var d:DisplayObject = row.getChildAt(i);
            if(!(d is TextField) && d.visible && d.name != "mvaGrade" && d.name != "mvaRank" && d.name != "mvaBoosts")
            {
               var r:Rectangle = d.getBounds(row);
               if(r.width > 0 && r.right <= nameX + 2 && r.width < nameX + 4)
               {
                  d.y += Math.round(y1 - (r.top + r.height / 2));
                  if(r.right > right)
                  {
                     right = r.right;
                  }
               }
            }
            i++;
         }
         return right;
      }

      private static function tiNameStart(shown:String, name:String) : Boolean
      {
         if(shown.indexOf(name) == 0)
         {
            return true;
         }
         var cut:int = int(shown.indexOf("..."));
         if(cut < 0)
         {
            cut = int(shown.indexOf("…"));
         }
         return cut >= 3 && name.indexOf(shown.substr(0,cut)) == 0;
      }

      private static function tiFullName(tf:TextField, name:String) : void
      {
         var shown:String = tf.text;
         if(shown.indexOf(name) == 0)
         {
            return;
         }
         var cut:int = int(shown.indexOf("..."));
         var len:int = 3;
         if(cut < 0)
         {
            cut = int(shown.indexOf("…"));
            len = 1;
         }
         if(cut >= 3)
         {
            tf.replaceText(0,cut + len,name);
         }
      }

      private static function tiRowH() : Number
      {
         var c:*;
         try
         {
            c = Main.instance.getGame().loaderInfo.applicationDomain.getDefinition("LPFFrameInvAQ");
            if(c.ROW_H > 0)
            {
               return c.ROW_H;
            }
         }
         catch(e:Error)
         {
         }
         return 30;
      }

      private static function tiContentH(s:Sprite) : Number
      {
         var h:Number = 0;
         var i:int = 0;
         while(i < s.numChildren)
         {
            var d:DisplayObject = s.getChildAt(i);
            if(d.visible && d.height > h)
            {
               h = d.height;
            }
            i++;
         }
         return h + 4;
      }

      private static function tiScroll(s:Sprite, by:Number) : void
      {
         var r:Rectangle = s.scrollRect;
         if(r == null)
         {
            return;
         }
         var max:Number = Math.max(0,tiContentH(s) - r.height);
         var y:Number = Math.max(0,Math.min(max,r.y + by));
         if(y != r.y)
         {
            r.y = y;
            s.scrollRect = r;
         }
      }

      private static function tiWheel(e:MouseEvent) : void
      {
         tiScroll(e.currentTarget as Sprite,-e.delta * 10 / TI_SCALE);
      }

      public static function setMobileHud(on:Boolean) : void
      {
         mhOn = on;
      }

      private static function mvaOwn(game:*, key:String) : Boolean
      {
         try
         {
            return game.litePreference.data.dOptions[key] !== false;
         }
         catch(e:Error)
         {
         }
         return true;
      }

      private static function mvaOpt(game:*, key:String) : Boolean
      {
         if(!mvaOwn(game,key))
         {
            return false;
         }
         return key == "mvaUi" || key == "mvaImproveFps" || mvaOwn(game,"mvaUi");
      }

      private static function mhLayoutOn(game:*) : Boolean
      {
         return mvaOpt(game,"mvaMobileLayout");
      }

      private static function mhOptLabel(game:*, o:Array) : String
      {
         return o[1] + ": " + (mvaOwn(game,o[0]) ? "On" : "Off");
      }

      private static function mhOptFor(text:String) : Array
      {
         for each(var o in MH_OPTS)
         {
            if(text == o[1] || text.indexOf(o[1] + ":") == 0)
            {
               return o;
            }
         }
         return null;
      }

      private static function mhOptSync(game:*) : void
      {
         if(mhOptSynced || game == null || game.litePreference == null || game.litePreference.data == null)
         {
            return;
         }
         mhOptSynced = true;
         for each(var o in MH_OPTS)
         {
            mhOptSend(o[0],mvaOpt(game,o[0]));
         }
      }

      private static function mhOptSend(key:String, on:Boolean) : void
      {
         try
         {
            Main.instance.external.call("mvaOption",key + ":" + (on ? "on" : "off"));
         }
         catch(e:Error)
         {
         }
      }

      private static function mhOptions(game:*) : void
      {
         var win:*;
         var searching:Boolean;
         if(++mhOptTick % 10 != 0)
         {
            return;
         }

         win = game.mcO;
         if(win == null || win.stage == null || !win.visible)
         {
            return;
         }
         searching = false;
         try
         {
            searching = String(win.bg2.txtSearch.text).length > 0;
         }
         catch(es:Error)
         {
         }
         if(!searching && mhOptInsert(game))
         {
            win.redraw(game.litePref);
         }
         mhOptionRows(win as DisplayObjectContainer,game,0);
         mhOptPlace(win);
      }

      private static function mhOptPlace(win:*) : void
      {
         var items:Array;
         var i:int;
         var top:Number;
         var mine:Array;
         var rest:Array;
         var d:*;
         var o:Array;
         var kept:Array;
         var rowX:Number;
         var y:Number;
         var e:DisplayObject;
         var list:DisplayObjectContainer = win.optionList as DisplayObjectContainer;
         if(list == null || mhOptPlaced[list] != null || list.numChildren == 0)
         {
            return;
         }
         items = [];
         i = 0;
         while(i < list.numChildren)
         {
            items.push(list.getChildAt(i));
            i++;
         }
         items.sortOn("y",Array.NUMERIC);
         top = DisplayObject(items[0]).y;
         mine = [];
         rest = [];
         for each(d in items)
         {
            o = !mhIsHeader(d) && "txtName" in d && d.txtName != null ? mhOptFor(String(d.txtName.text)) : null;
            if(o != null)
            {
               mine.push({
                  "row":d,
                  "at":MH_OPTS.indexOf(o)
               });
            }
            else
            {
               rest.push(d);
            }
         }
         if(mine.length == 0 || rest.length == 0 || !mhIsHeader(rest[0]))
         {
            return;
         }
         mhOptPlaced[list] = true;
         mine.sortOn("at",Array.NUMERIC);
         kept = [];
         i = 0;
         while(i < rest.length)
         {
            if(i > 0 && mhIsHeader(rest[i]) && (i == rest.length - 1 || mhIsHeader(rest[i + 1])))
            {
               list.removeChild(rest[i]);
            }
            else
            {
               kept.push(rest[i]);
            }
            i++;
         }
         rowX = kept.length > 1 ? DisplayObject(kept[1]).x : DisplayObject(mine[0].row).x;
         i = mine.length - 1;
         while(i >= 0)
         {
            DisplayObject(mine[i].row).x = rowX;
            kept.splice(1,0,mine[i].row);
            i--;
         }
         y = top;
         for each(e in kept)
         {
            e.y = y;
            y += mhIsHeader(e) ? 26 : 35;
         }
         try
         {
            win.dRun = list.height - win.bg2.cntMask.height + 5;
         }
         catch(err:Error)
         {
         }
      }

      private static function mhIsHeader(d:*) : Boolean
      {
         return getQualifiedClassName(d).indexOf("RowHeader") >= 0;
      }

      private static function mhOptInsert(game:*) : Boolean
      {
         var list:Array = game.litePref as Array;
         if(list == null)
         {
            return false;
         }
         var added:Boolean = false;
         for each(var o in MH_OPTS)
         {
            var have:Boolean = false;
            var i:int = 0;
            while(i < list.length)
            {
               if(list[i] != null && mhOptFor(String(list[i].strName)) == o)
               {
                  have = true;
                  break;
               }
               i++;
            }
            if(!have)
            {
               list.push({
                  "strName":mhOptLabel(game,o),
                  "btn":true,
                  "sDesc":o[2]
               });
               added = true;
            }
         }
         return added;
      }

      private static function mhOptionRows(c:DisplayObjectContainer, game:*, depth:int) : void
      {
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObject = c.getChildAt(i);
            if(getQualifiedClassName(d) == "liteAssets.listOptionsItem::listOptionsItemBtn")
            {
               var row:* = d;
               var ro:Array = row.txtName != null ? mhOptFor(String(row.txtName.text)) : null;
               if(ro != null)
               {
                  if(mhOptRows[row] == null)
                  {
                     mhOptRows[row] = true;
                     row.btnActive.addEventListener(MouseEvent.CLICK,mhOptTap,false,0,true);
                     var tag:Sprite = mhTag();
                     tag.x = Math.round(row.txtName.x + row.txtName.textWidth + 8);
                     tag.y = Math.round(row.txtName.y + 3);
                     row.addChild(tag);
                     mhOptTagOf[row] = tag;
                     var q:Sprite = mhHelpButton(ro);
                     q.x = Math.round(tag.x + tag.width + 6);
                     q.y = Math.round(tag.y - 2);
                     row.addChild(q);
                  }
                  mhOptRowOf[ro[0]] = row;
                  mhOptLook(row,mvaOwn(game,ro[0]));
               }
            }
            else if(depth < 7 && d is DisplayObjectContainer)
            {
               mhOptionRows(d as DisplayObjectContainer,game,depth + 1);
            }
            i++;
         }
      }

      private static function mhOptTap(e:MouseEvent) : void
      {
         var game:*;
         var row:*;
         var o:Array;
         try
         {
            game = Main.instance.getGame();
            row = e.currentTarget.parent;
            o = mhOptFor(String(row.txtName.text));
            if(o != null)
            {
               mhOptSet(game,o,!mvaOwn(game,o[0]));
            }
         }
         catch(err:Error)
         {
         }
      }

      private static function mhOptSet(game:*, o:Array, on:Boolean) : void
      {
         game.litePreference.data.dOptions[o[0]] = on;
         game.litePreference.flush();
         for each(var entry in game.litePref)
         {
            if(entry != null && mhOptFor(String(entry.strName)) == o)
            {
               entry.strName = mhOptLabel(game,o);
            }
         }
         var row:* = mhOptRowOf[o[0]];
         if(row != null && row.txtName != null)
         {
            row.txtName.text = mhOptLabel(game,o);
            mhOptLook(row,on);
         }
         if(o[0] == "mvaUi")
         {
            for each(var all in MH_OPTS)
            {
               mhOptSend(all[0],mvaOpt(game,all[0]));
               var other:* = mhOptRowOf[all[0]];
               if(all != o && other != null)
               {
                  mhOptLook(other,mvaOpt(game,all[0]));
               }
            }
         }
         else
         {
            mhOptSend(o[0],mvaOpt(game,o[0]));
         }
      }

      private static function mhOptLook(row:*, on:Boolean) : void
      {
         var tag:Sprite;
         try
         {
            row.btnActive.transform.colorTransform = on ? new ColorTransform() : new ColorTransform(0.4,0.34,0.34,1,20,14,14,0);
            row.txtName.alpha = on ? 1 : 0.6;
            tag = mhOptTagOf[row] as Sprite;
            if(tag != null)
            {
               tag.alpha = on ? 1 : 0.55;
            }
         }
         catch(err:Error)
         {
         }
      }

      private static function mhHelpButton(o:Array) : Sprite
      {
         var g:Graphics;
         var tf:TextField;
         var b:Sprite = new Sprite();
         b.buttonMode = true;
         b.useHandCursor = true;
         g = b.graphics;
         g.beginFill(0,0);
         g.drawRect(-5,-5,25,25);
         g.endFill();
         g.lineStyle(1.5,14266970,1);
         g.beginFill(1840134,1);
         g.drawCircle(7.5,7.5,7.5);
         g.endFill();
         tf = mhText("?",10,16047256,true);
         tf.x = 7.5 - tf.width / 2;
         tf.y = 7.5 - tf.height / 2;
         tf.mouseEnabled = false;
         b.addChild(tf);
         b.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
         {
            e.stopPropagation();
            mhGuideShow(o,b.stage);
         },false,0,true);
         return b;
      }

      private static function mhText(text:String, size:Number, color:uint, bold:Boolean, width:Number = 0, font:String = "Arial") : TextField
      {
         var tf:TextField = new TextField();
         tf.selectable = false;
         tf.defaultTextFormat = new TextFormat(font,size,color,bold);
         if(width > 0)
         {
            tf.wordWrap = true;
            tf.multiline = true;
            tf.width = width;
         }
         tf.autoSize = "left";
         tf.text = text;
         return tf;
      }

      private static function mhPill(label:String, red:Boolean, w:Number) : Sprite
      {
         var p:Sprite = new Sprite();
         p.buttonMode = true;
         var g:Graphics = p.graphics;
         g.lineStyle(2,red ? 15185498 : 8021056,1);
         g.beginFill(red ? 13116955 : 4074540,1);
         g.drawRoundRect(0,0,w,24,8,8);
         g.endFill();
         var tf:TextField = mhText(label,11,red ? 16777215 : 14207690,true);
         tf.x = (w - tf.width) / 2;
         tf.y = (24 - tf.height) / 2;
         tf.mouseEnabled = false;
         p.addChild(tf);
         return p;
      }

      private static function mhGuideClose(e:Event = null) : void
      {
         if(mhGuide != null)
         {
            mhGuide.removeEventListener(Event.ENTER_FRAME,mhGuideFrame);
            if(mhGuide.parent != null)
            {
               mhGuide.parent.removeChild(mhGuide);
            }
         }
         mhGuide = null;
         mhGuideKnob = null;
      }

      private static function mhGuideFrame(e:Event) : void
      {
         if(mhGuideKnob == null)
         {
            return;
         }
         mhGuideT += 0.08;
         mhGuideKnob.x = Math.cos(mhGuideT) * 10;
         mhGuideKnob.y = Math.sin(mhGuideT * 1.3) * 8;
      }

      private static function mhGuideShow(o:Array, st:*) : void
      {
         var game:*;
         var on:Boolean;
         var W:Number;
         var H:Number;
         var root:Sprite;
         var shade:Sprite;
         var pw:Number;
         var panel:Sprite;
         var y:Number;
         var title:TextField;
         var close:Sprite;
         var what:String;
         var body:TextField;
         var dw:Number;
         var demo:Sprite;
         var dg:Graphics;
         var zl:TextField;
         var knobHolder:Sprite;
         var texts:Array;
         var i:int;
         var h:TextField;
         var t:TextField;
         var bw:Number;
         var turn:Sprite;
         var ok:Sprite;
         var pg:Graphics;
         mhGuideClose();
         if(st == null)
         {
            return;
         }
         game = Main.instance.getGame();
         on = mvaOwn(game,o[0]);
         W = Number(st.stageWidth > 0 ? st.stageWidth : 960);
         H = Number(st.stageHeight > 0 ? st.stageHeight : 550);
         root = new Sprite();
         shade = new Sprite();
         shade.graphics.beginFill(0,0.45);
         shade.graphics.drawRect(0,0,W,H);
         shade.graphics.endFill();
         shade.addEventListener(MouseEvent.CLICK,mhGuideClose,false,0,true);
         root.addChild(shade);
         pw = 300;
         panel = new Sprite();
         root.addChild(panel);
         y = 12;
         title = mhText(o[1],16,16048816,false,0,"_serif");
         title.x = 14;
         title.y = y;
         panel.addChild(title);
         close = mhPill("X",true,24);
         close.x = pw - 36;
         close.y = y;
         close.addEventListener(MouseEvent.CLICK,mhGuideClose,false,0,true);
         panel.addChild(close);
         y += 30;
         what = String(o[2]);
         if(what.indexOf("MVA: ") == 0)
         {
            what = what.substr(5);
         }
         body = mhText(what,11,15000804,false,pw - 28);
         body.x = 14;
         body.y = y;
         panel.addChild(body);
         y += body.height + 8;
         if(o[0] == "mvaJoystick")
         {
            dw = pw - 28;
            demo = new Sprite();
            dg = demo.graphics;
            dg.lineStyle(1,4864538,1);
            dg.beginFill(1381660,1);
            dg.drawRoundRect(0,0,dw,92,8,8);
            dg.endFill();
            dg.lineStyle(0,0,0);
            dg.beginFill(15253850,0.16);
            dg.drawRect(1,1,dw * 0.35,90);
            dg.endFill();
            dg.lineStyle(1.5,15253850,0.9);
            dg.moveTo(dw * 0.35,4);
            dg.lineTo(dw * 0.35,88);
            dg.lineStyle(1.5,16777215,0.6);
            dg.drawCircle(46,54,22);
            dg.lineStyle(0,0,0);
            dg.beginFill(8038399,1);
            dg.drawRoundRect(170,36,14,30,6,6);
            dg.endFill();
            zl = mhText("left 35%",9,16047256,false);
            zl.x = 5;
            zl.y = 3;
            demo.addChild(zl);
            knobHolder = new Sprite();
            knobHolder.x = 46;
            knobHolder.y = 54;
            mhGuideKnob = new Shape();
            mhGuideKnob.graphics.beginFill(16777215,1);
            mhGuideKnob.graphics.drawCircle(0,0,9);
            mhGuideKnob.graphics.endFill();
            knobHolder.addChild(mhGuideKnob);
            demo.addChild(knobHolder);
            demo.x = 14;
            demo.y = y;
            panel.addChild(demo);
            y += 100;
         }
         texts = MH_OPT_ONOFF[o[0]] as Array;
         if(texts != null)
         {
            i = 0;
            while(i < 2)
            {
               h = mhText(i == 0 ? "WHEN ON" : "WHEN OFF",10,15253850,true);
               h.x = 14;
               h.y = y;
               panel.addChild(h);
               y += h.height;
               t = mhText(String(texts[i]),11,15000804,false,pw - 28);
               t.x = 14;
               t.y = y;
               panel.addChild(t);
               y += t.height + 6;
               i++;
            }
         }
         y += 4;
         bw = (pw - 38) / 2;
         turn = mhPill(on ? "Turn off" : "Turn on",!on,bw);
         turn.x = 14;
         turn.y = y;
         turn.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
         {
            mhOptSet(game,o,!mvaOwn(game,o[0]));
            mhGuideClose();
         },false,0,true);
         panel.addChild(turn);
         ok = mhPill("Got it",true,bw);
         ok.x = 24 + bw;
         ok.y = y;
         ok.addEventListener(MouseEvent.CLICK,mhGuideClose,false,0,true);
         panel.addChild(ok);
         y += 36;
         pg = panel.graphics;
         pg.lineStyle(3,13212218,1);
         pg.beginFill(657414,0.97);
         pg.drawRoundRect(0,0,pw,y,16,16);
         pg.endFill();
         pg.lineStyle(1,3877646,1);
         pg.drawRoundRect(4,4,pw - 8,y - 8,12,12);
         panel.x = Math.round((W - pw) / 2);
         panel.y = Math.max(6,Math.round((H - y) / 2));
         mhGuide = root;
         root.addEventListener(Event.ENTER_FRAME,mhGuideFrame,false,0,true);
         st.addChild(root);
      }

      private static function mhJoystick(game:*, on:Boolean) : void
      {
         if(++mhJoyTick % 15 != 0)
         {
            return;
         }
         if(mhJoy == null || mhJoy.stage == null)
         {
            mhJoy = mhFind(game.ui as DisplayObjectContainer,"liteAssets.mobile::Joystick",0);
            mhJoyGame = null;
            mhJoyOurs = null;
            if(mhJoy == null)
            {
               return;
            }
         }
         var hit:DisplayObject = mhJoy.numChildren > 0 ? mhJoy.getChildAt(0) : null;
         if(hit == null || mhJoy.pressed)
         {
            return;
         }
         var now:Rectangle = hit.getBounds(mhJoy);
         if(mhJoyOurs == null || !mhRectNear(now,mhJoyOurs))
         {
            mhJoyGame = now;
            mhJoyOurs = null;
         }
         if(!on)
         {
            if(mhJoyOurs != null && mhJoyGame != null)
            {
               mhJoy.setZone(mhJoyGame);
               mhJoyOurs = null;
            }
            return;
         }
         if(mhJoyOurs != null)
         {
            return;
         }
         var tl:Point = mhJoy.globalToLocal(new Point(MH_JOY_ZONE.x,MH_JOY_ZONE.y));
         var br:Point = mhJoy.globalToLocal(new Point(MH_JOY_ZONE.right,MH_JOY_ZONE.bottom));
         mhJoy.setZone(new Rectangle(tl.x,tl.y,br.x - tl.x,br.y - tl.y));
         mhJoyOurs = hit.getBounds(mhJoy);
      }

      private static function mhRectNear(a:Rectangle, b:Rectangle) : Boolean
      {
         return Math.abs(a.x - b.x) < 1 && Math.abs(a.y - b.y) < 1 && Math.abs(a.width - b.width) < 1 && Math.abs(a.height - b.height) < 1;
      }

      private static function mhTag() : Sprite
      {
         var s:Sprite = new Sprite();
         s.mouseEnabled = false;
         s.mouseChildren = false;
         var tf:TextField = new TextField();
         tf.selectable = false;
         tf.autoSize = "left";
         tf.defaultTextFormat = new TextFormat("Arial",8,1709070,true);
         tf.text = "MVA";
         tf.x = 2;
         tf.y = -2;
         var g:Graphics = s.graphics;
         g.lineStyle(1,16771496,1);
         g.beginFill(14265938,1);
         g.drawRoundRect(0,0,tf.width + 4,11,5,5);
         g.endFill();
         s.addChild(tf);
         return s;
      }

      private static function mhFrame(game:*) : void
      {
         if(mhOn)
         {
            try
            {
               mhOptSync(game);
               mhOptions(game);
            }
            catch(eo:Error)
            {
            }
            try
            {
               if(mhMobile(game))
               {
                  mhJoystick(game,mvaOpt(game,"mvaJoystick"));
               }
            }
            catch(ej:Error)
            {
            }
         }

         var layoutWanted:Boolean = mhOn && mhLayoutOn(game);
         if(layoutWanted && !mhTouchSet)
         {
            mhTouchSet = mhForceTouch(game);
         }
         else if(!layoutWanted)
         {
            mhTouchSet = false;
         }
         if(!(mhOn && mhMobile(game) && mhLayoutOn(game)))
         {
            if(mhApplied)
            {
               mhRestore(game);
            }
            return;
         }
         mhApplied = true;
         try
         {
            mhLayoutBar(game);
         }
         catch(e1:Error)
         {
         }
         try
         {
            mhPlaceTray(game);
         }
         catch(e2:Error)
         {
         }
         try
         {
            mhLayoutSkills(game);
         }
         catch(e3:Error)
         {
         }
         try
         {
            mhPortraits(game);
         }
         catch(e4:Error)
         {
         }
      }

      public static function optionsJson() : String
      {
         var out:Object = {"ready":false};
         try
         {
            var game:* = Main.instance.getGame();
            if(game != null && game.litePreference != null && game.litePreference.data != null)
            {
               if(game.litePreference.data.dOptions == null)
               {
                  game.litePreference.data.dOptions = {};
               }
               out.ready = true;
               for each(var o in MH_OPTS)
               {
                  out[o[0]] = mvaOwn(game,o[0]);
               }
            }
         }
         catch(e:Error)
         {
         }
         return JSON.stringify(out);
      }

      public static function setOption(key:String, on:Boolean) : Boolean
      {
         try
         {
            var game:* = Main.instance.getGame();
            if(game == null || game.litePreference == null || game.litePreference.data == null)
            {
               return false;
            }
            if(game.litePreference.data.dOptions == null)
            {
               game.litePreference.data.dOptions = {};
            }
            for each(var o in MH_OPTS)
            {
               if(o[0] == key)
               {
                  mhOptSet(game,o,on);
                  return true;
               }
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }

      public static function gameOptions() : String
      {
         try
         {
            var game:* = Main.instance.getGame();
            if(game == null || game.litePreference == null || game.litePreference.data == null)
            {
               return "null";
            }
            game.initlitePref();
            var out:Array = [];
            gameOptFlatten(game.litePref,out);
            var cyc:Object = {};
            try
            {
               cyc["Crowd Mode"] = String(game.crowdLabel());
               cyc["Max FPS"] = String(game.maxFPSLabel());
               cyc["Mobile UI Size"] = String(gameOptClass(game,"liteAssets.mobile.Mobile").sizeLabel());
               cyc["Mobile Controls"] = String(gameOptClass(game,"liteAssets.mobile.VolumePanel").touchLabel());
            }
            catch(ec:Error)
            {
            }
            return JSON.stringify({"rows":out,"cycles":cyc});
         }
         catch(e:Error)
         {
         }
         return "null";
      }

      private static function gameOptFlatten(list:*, out:Array) : void
      {
         if(!(list is Array))
         {
            return;
         }
         for each(var o in list)
         {
            if(o == null || o.strName == null)
            {
               continue;
            }
            out.push({"n":String(o.strName),"on":o.bEnabled == true,"d":(o.sDesc != null ? String(o.sDesc) : ""),"btn":o.extra == "btn"});
            if(o.extra is Array)
            {
               gameOptFlatten(o.extra,out);
            }
         }
      }

      private static function gameOptClass(game:*, name:String) : *
      {
         return game.loaderInfo.applicationDomain.getDefinition(name);
      }

      public static function gameOption(name:String) : String
      {
         try
         {
            var game:* = Main.instance.getGame();
            if(game == null || game.litePreference == null)
            {
               return "null";
            }
            if(name == "Crowd Mode")
            {
               game.cycleCrowd();
            }
            else if(name == "Max FPS")
            {
               game.cycleMaxFPS();
            }
            else if(name == "Mobile UI Size")
            {
               gameOptClass(game,"liteAssets.mobile.Mobile").cycleSize();
            }
            else if(name == "Mobile Controls")
            {
               gameOptClass(game,"liteAssets.mobile.VolumePanel").cycleTouch();
            }
            else
            {
               gameOptClass(game,"liteAssets.handlers.optionHandler").cmd(game,name);
            }
         }
         catch(e:Error)
         {
         }
         return gameOptions();
      }

      public static function mhMobileActive() : Boolean
      {
         try
         {
            return mhMobile(Main.instance.getGame());
         }
         catch(e:Error)
         {
         }
         return false;
      }

      private static var mhTouchSet:Boolean = false;

      private static function mhForceTouch(game:*) : Boolean
      {
         try
         {
            if(mhMobileClass == null)
            {
               mhMobileClass = game.loaderInfo.applicationDomain.getDefinition("liteAssets.mobile.Mobile");
            }
            if(game.litePreference == null)
            {
               return false;
            }
            if(mhMobileClass.mode != "on")
            {
               mhMobileClass.setMode("on");
            }
            return true;
         }
         catch(e:Error)
         {
         }
         return false;
      }

      private static function mhMobile(game:*) : Boolean
      {
         try
         {
            if(mhMobileClass == null)
            {
               mhMobileClass = game.loaderInfo.applicationDomain.getDefinition("liteAssets.mobile.Mobile");
            }
            return Boolean(mhMobileClass.active) && game.ui != null && game.ui.mcInterface != null;
         }
         catch(e:Error)
         {
         }
         return false;
      }

      private static function mhLayoutBar(game:*) : void
      {
         var mci:DisplayObjectContainer = game.ui.mcInterface as DisplayObjectContainer;
         var bar:DisplayObjectContainer = game.ui.mcInterface.actBar as DisplayObjectContainer;
         if(bar == null)
         {
            return;
         }
         if(bar !== mhBar)
         {
            mhUndoBar();
            var b0:DisplayObject = bar.getChildByName("blank0");
            var b1:DisplayObject = bar.getChildByName("blank1");
            var b5:DisplayObject = bar.getChildByName("blank5");
            if(b0 == null || b5 == null)
            {
               return;
            }
            mhBar = bar;
            mhBarX = bar.x;
            mhBarY = bar.y;
            mhSlot = b5.getBounds(bar);
            mhPitch = b1 != null && b1.x - b0.x > 20 ? b1.x - b0.x : 45;
            mhSeen = new Dictionary(true);
            mhSeen[b5] = true;
            mhHideLabels(mci);
         }
         bar.x = mhBarX + mhPitch + MH_POT_GAP;
         bar.y = mhBarY;
         var cx:Number = mhSlot.x + mhSlot.width / 2;
         var cy:Number = mhSlot.y + mhSlot.height / 2;
         var pot:DisplayObject = bar.getChildByName("i6");
         var i:int = 0;
         while(i < bar.numChildren)
         {
            var c:DisplayObject = bar.getChildAt(i);
            i++;
            if(!mhSeen[c])
            {
               var r:Rectangle = c.getBounds(bar);
               if(r.width > 0)
               {
                  mhSeen[c] = true;
                  var mx:Number = r.x + r.width / 2;
                  if(!(mx < mhSlot.left - 6 || mx > mhSlot.right + 6))
                  {
                     if(!(pot != null && c !== pot && mhSameMatrix(c.transform.matrix,pot.transform.matrix)))
                     {
                        c.scaleX *= MH_POT_SCALE;
                        c.scaleY *= MH_POT_SCALE;
                        c.x = cx + (c.x - cx) * MH_POT_SCALE;
                        c.y = cy + (c.y - cy) * MH_POT_SCALE;
                        mhScaled.push(c);
                     }
                  }
               }
            }
         }
         if(mhMask == null)
         {
            mhMask = new Shape();
         }
         if(mhMask.parent !== mci)
         {
            mci.addChild(mhMask);
         }
         var hw:Number = mhSlot.width * MH_POT_SCALE / 2 + 1;
         var hh:Number = mhSlot.height * MH_POT_SCALE / 2 + 10;
         var g:Graphics = mhMask.graphics;
         g.clear();
         g.beginFill(0);
         g.drawRect(bar.x + cx - hw,bar.y + cy - hh,hw * 2,hh * 2);
         g.endFill();
         if(bar.mask !== mhMask)
         {
            bar.mask = mhMask;
         }
         var s:int = 1;
         while(s <= 5)
         {
            var icon:InteractiveObject = bar.getChildByName("i" + s) as InteractiveObject;
            if(icon != null)
            {
               icon.mouseEnabled = false;
            }
            s++;
         }
         mhMenu = game.ui.mcInterface.mcMenu;
         if(mhMenu != null)
         {
            mhMenu.visible = false;
         }
         var area:DisplayObject = game.ui.mcInterface.areaList as DisplayObject;
         if(area != null)
         {
            if(area !== mhArea)
            {
               mhArea = area;
               mhAreaY = area.y;
            }
            area.y = Math.round(mhBarY + cy + 5);
         }
      }

      private static function mhSameMatrix(a:Matrix, b:Matrix) : Boolean
      {
         return Math.abs(a.a - b.a) < 0.001 && Math.abs(a.d - b.d) < 0.001 && Math.abs(a.tx - b.tx) < 0.5 && Math.abs(a.ty - b.ty) < 0.5;
      }

      private static function mhHideLabels(mci:DisplayObjectContainer) : void
      {
         var left:Number = mhBarX - 4;
         var right:Number = mhBarX + mhSlot.right + 4;
         var i:int = 0;
         while(i < mci.numChildren)
         {
            var c:DisplayObject = mci.getChildAt(i);
            i++;
            if(!(c === mhBar || c === mhMask || !c.visible))
            {
               var r:Rectangle = c.getBounds(mci);
               if(r.width > 0 && r.left >= left && r.right <= right && r.top >= mhBarY - 8 && r.bottom <= mhBarY + 52)
               {
                  c.visible = false;
                  mhHidden.push(c);
               }
            }
         }
      }

      private static function mhUndoBar() : void
      {
         if(mhBar != null)
         {
            mhBar.x = mhBarX;
            mhBar.y = mhBarY;
            if(mhBar.mask === mhMask)
            {
               mhBar.mask = null;
            }
            var s:int = 1;
            while(s <= 5)
            {
               var icon:InteractiveObject = mhBar.getChildByName("i" + s) as InteractiveObject;
               if(icon != null)
               {
                  icon.mouseEnabled = true;
               }
               s++;
            }
            if(mhSlot != null)
            {
               var cx:Number = mhSlot.x + mhSlot.width / 2;
               var cy:Number = mhSlot.y + mhSlot.height / 2;
               for each(var c in mhScaled)
               {
                  if(c.parent === mhBar)
                  {
                     c.scaleX /= MH_POT_SCALE;
                     c.scaleY /= MH_POT_SCALE;
                     c.x = cx + (c.x - cx) / MH_POT_SCALE;
                     c.y = cy + (c.y - cy) / MH_POT_SCALE;
                  }
               }
            }
         }
         mhScaled = [];
         for each(var h in mhHidden)
         {
            h.visible = true;
         }
         mhHidden = [];
         if(mhMask != null && mhMask.parent != null)
         {
            mhMask.parent.removeChild(mhMask);
         }
         mhBar = null;
      }

      private static function mhPlaceTray(game:*) : void
      {
         var i:int;
         var c:DisplayObject;
         var pos:*;
         var row:DisplayObjectContainer;
         var plate:DisplayObject;
         var b0:Rectangle;
         var tx:Number;
         var ty:Number;
         var gold:DisplayObject;
         var k:int;
         var card:DisplayObject;
         var gx:Number;
         var gy:Number;
         var fx:Number;
         var fy:Number;
         var ui:DisplayObjectContainer = game.ui as DisplayObjectContainer;
         if(mhTray != null && mhTray.parent !== ui)
         {
            mhTray = null;
         }
         if(mhTray == null && ++mhTrayScan % 30 == 0)
         {
            i = 0;
            while(i < ui.numChildren)
            {
               c = ui.getChildAt(i);
               if(getQualifiedClassName(c) == "liteAssets.mobile::DropTray")
               {
                  mhTray = c;
                  break;
               }
               i++;
            }
         }
         if(mhTray == null || mhBar == null)
         {
            return;
         }
         pos = null;
         try
         {
            pos = game.litePreference.data.dOptions.posDrops;
         }
         catch(e:Error)
         {
         }
         if(pos != null || mhTray.numChildren == 0)
         {
            mhTray.x = mhTray.y = 0;
            return;
         }
         row = mhTray.getChildAt(0) as DisplayObjectContainer;
         plate = row.numChildren > 0 ? row.getChildAt(0) : row;
         b0 = mhBar.getChildByName("blank0").getBounds(ui);
         tx = b0.x - mhPitch - MH_POT_GAP - 5;
         ty = b0.y - 5;
         gold = game.ui.mcInterface.mcGold as DisplayObject;
         if(gold != null && gold.visible)
         {
            ty = Math.min(ty,gold.getBounds(ui).top + 1 - plate.height);
         }
         mhTray.x = Math.round(tx - row.x);
         mhTray.y = Math.round(ty - row.y);
         k = 0;
         while(k < mhTray.numChildren)
         {
            card = mhTray.getChildAt(k);
            if(getQualifiedClassName(card) == "liteAssets.mobile::DropPopover")
            {
               gx = card.x + mhTray.x;
               gy = card.y + mhTray.y;
               fx = Math.max(6,Math.min(MH_STAGE_W - 6 - card.width,gx));
               fy = Math.max(6,gy);
               if(fx != gx)
               {
                  card.x = Math.round(fx - mhTray.x);
               }
               if(fy != gy)
               {
                  card.y = Math.round(fy - mhTray.y);
               }
            }
            k++;
         }
      }

      private static function mhLayoutSkills(game:*) : void
      {
         if(mhCluster == null || mhCluster.stage == null)
         {
            mhCluster = null;
            mhClusterPos = null;
            if(mhClusterAt-- > 0)
            {
               return;
            }
            mhClusterAt = 30;
            mhCluster = mhFind(game.ui as DisplayObjectContainer,"liteAssets.mobile::SkillCluster",0);
            if(mhCluster == null)
            {
               return;
            }
         }
         var ring:DisplayObjectContainer = mhCluster.numChildren > 1 ? mhCluster.getChildAt(1) as DisplayObjectContainer : null;
         if(ring == null || ring.numChildren < 7)
         {
            return;
         }
         if(mhClusterPos == null)
         {
            mhClusterPos = [];
            var i:int = 0;
            while(i < 7)
            {
               var d:DisplayObject = ring.getChildAt(i);
               mhClusterPos.push([d.x,d.y,d.scaleX,d.scaleY]);
               i++;
            }
         }
         var x0:Number = Number(mhClusterPos[0][0]);
         var y0:Number = Number(mhClusterPos[0][1]);
         var rA:Number = mhHalf(ring.getChildAt(0));
         var rS:Number = mhHalf(ring.getChildAt(1));
         var rD:Number = mhHalf(ring.getChildAt(6)) - 4;
         if(!(rA > 10 && rS > 10))
         {
            return;
         }
         i = 1;
         while(i <= 4)
         {
            var d2:Number = i == 4 ? rA * 2 + MH_GAP : rA + rS + MH_GAP;
            mhPlace(ring.getChildAt(i),x0,y0,MH_ANGLE[i],d2);
            i++;
         }
         var s5:DisplayObject = ring.getChildAt(4);
         s5.scaleX = s5.scaleY = rA / rS;
         ring.getChildAt(5).x = -10000;
         mhPlace(ring.getChildAt(6),x0,y0,MH_DASH_ANGLE,rA + rD + MH_GAP);
         mhLowerSkills(game,ring);
      }

      private static function mhLowerSkills(game:*, ring:DisplayObjectContainer) : void
      {
         if(mhBar == null || mhSlot == null)
         {
            return;
         }
         var ui:DisplayObjectContainer = game.ui as DisplayObjectContainer;
         var handle:DisplayObject = mhHandle(ring);
         ring.y = 0;
         var bottom:Number = -10000;
         for each(var i in [0,1,2,3,4,6])
         {
            bottom = Math.max(bottom,ring.getChildAt(i).getBounds(ui).bottom);
         }
         var want:Number = game.ui.mcInterface.y + mhBarY + mhSlot.y + 12;
         var dy:Number = bottom > -10000 && want > bottom ? Math.round(want - bottom) : 0;
         ring.y = dy;
         if(handle != null)
         {
            handle.y = dy;
         }
      }

      private static function mhHandle(ring:DisplayObjectContainer) : DisplayObject
      {
         var i:int = mhCluster.numChildren - 1;
         while(i >= 0)
         {
            var d:DisplayObject = mhCluster.getChildAt(i);
            if(d === ring)
            {
               return null;
            }
            if(d is Sprite)
            {
               return d;
            }
            i--;
         }
         return null;
      }

      private static function mhHalf(d:DisplayObject) : Number
      {
         var s:Sprite = d as Sprite;
         if(s != null && s.hitArea != null)
         {
            return s.hitArea.width / 2;
         }
         return d.width / d.scaleX / 2;
      }

      private static function mhPlace(d:DisplayObject, x0:Number, y0:Number, deg:Number, dist:Number) : void
      {
         var a:Number = deg * Math.PI / 180;
         d.x = Math.round(x0 + Math.cos(a) * dist);
         d.y = Math.round(y0 + Math.sin(a) * dist);
      }

      private static function mhUndoSkills() : void
      {
         if(mhCluster == null || mhClusterPos == null)
         {
            return;
         }
         var ring:DisplayObjectContainer = mhCluster.getChildAt(1) as DisplayObjectContainer;
         var i:int = 0;
         while(ring != null && i < 7 && i < ring.numChildren)
         {
            var d:DisplayObject = ring.getChildAt(i);
            d.x = mhClusterPos[i][0];
            d.y = mhClusterPos[i][1];
            d.scaleX = mhClusterPos[i][2];
            d.scaleY = mhClusterPos[i][3];
            i++;
         }
         if(ring != null)
         {
            var handle:DisplayObject = mhHandle(ring);
            ring.y = 0;
            if(handle != null)
            {
               handle.y = 0;
            }
         }
         mhCluster = null;
         mhClusterPos = null;
      }

      private static function mhFind(c:DisplayObjectContainer, cls:String, depth:int) : DisplayObjectContainer
      {
         if(c == null)
         {
            return null;
         }
         var i:int = 0;
         while(i < c.numChildren)
         {
            var d:DisplayObject = c.getChildAt(i);
            if(getQualifiedClassName(d) == cls)
            {
               return d as DisplayObjectContainer;
            }
            if(depth < 2 && d is DisplayObjectContainer)
            {
               var f:DisplayObjectContainer = mhFind(d as DisplayObjectContainer,cls,depth + 1);
               if(f != null)
               {
                  return f;
               }
            }
            i++;
         }
         return null;
      }

      private static function mhStep(v:*) : int
      {
         var n:int = int(v);
         return n >= 0 && n < MH_STEPS.length ? n : 0;
      }

      private static function mhPortraits(game:*) : void
      {
         var data:* = game.litePreference.data;
         var p:DisplayObject = game.ui.mcPortrait as DisplayObject;
         var t:DisplayObject = game.ui.mcPortraitTarget as DisplayObject;
         if(p != null)
         {
            if(p !== mhPort)
            {
               mhPort = p;
               mhPortX = p.x;
               mhPortY = p.y;
            }
            var sp:Number = Number(MH_STEPS[mhStep(data.mvaPortP)]);
            if(sp > 0)
            {
               p.scaleX = p.scaleY = sp;
               p.x = mhPortX;
               p.y = mhPortY;
            }
            else
            {
               p.x = -5000;
            }
            mhBtnP = mhButton(game,mhBtnP,"mvaPortBtnP",p,false);
            mhBtnP.x = sp > 0 ? mhPortX + 188 * sp : 16;
            mhBtnP.y = sp > 0 ? mhPortY + 81 * sp + 13 : 16;
            mhGlyph(mhBtnP,mhStep(data.mvaPortP));
         }
         if(t != null)
         {
            if(t !== mhTarget)
            {
               mhTarget = t;
               mhTargetX = t.x;
               mhTargetY = t.y;
               mhTargetW = t.width / t.scaleX;
            }
            var st:Number = Number(MH_STEPS[mhStep(data.mvaPortT)]);
            var tx:Number = mhTargetX;
            if(p != null && p.x > -1000)
            {
               tx = Math.max(tx,Math.round(p.x + p.width + 6));
            }
            if(st > 0)
            {
               t.scaleX = t.scaleY = st;
               t.x = tx;
               t.y = mhTargetY;
            }
            else
            {
               t.x = -5000;
            }
            mhBtnT = mhButton(game,mhBtnT,"mvaPortBtnT",t,true);
            mhBtnT.visible = t.visible;
            mhBtnT.x = st > 0 ? t.x + 26 * st : tx + 16;
            mhBtnT.y = st > 0 ? mhTargetY + 82 * st + 13 : 16;
            mhGlyph(mhBtnT,mhStep(data.mvaPortT));
         }
         mhAuraIcons(game,p,t);
      }

      private static function mhAuraIcons(game:*, p:DisplayObject, t:DisplayObject) : void
      {
         var opts:* = game.litePreference.data.dOptions;
         var pa:DisplayObject = game.pAurasUI as DisplayObject;
         if(pa != null && p != null && (opts == null || opts.posAurasP == null))
         {
            pa.x = 130;
            pa.y = p.x > -1000 ? Math.max(100,Math.round(p.y + 96 * p.scaleY + 4)) : 30;
         }
         var ta:DisplayObject = game.tAurasUI as DisplayObject;
         if(ta != null && t != null && (opts == null || opts.posAurasT == null))
         {
            if(t.x > -1000)
            {
               ta.x = Math.round(t.x + 85 * t.scaleX);
               ta.y = Math.max(104,Math.round(t.y + 82 * t.scaleY + 6));
            }
            else
            {
               ta.x = 320;
               ta.y = 30;
            }
         }
      }

      private static function mhButton(game:*, btn:Sprite, name:String, over:DisplayObject, target:Boolean) : Sprite
      {
         var ui:DisplayObjectContainer = game.ui as DisplayObjectContainer;
         if(btn == null)
         {
            btn = new Sprite();
            btn.name = name;
            btn.buttonMode = true;
            btn.mouseChildren = false;
            var hit:Sprite = new Sprite();
            hit.graphics.beginFill(0,0);
            hit.graphics.drawCircle(0,0,22);
            hit.graphics.endFill();
            hit.mouseEnabled = false;
            btn.addChild(hit);
            btn.hitArea = hit;
            var face:Shape = new Shape();
            face.name = "face";
            btn.addChild(face);
            btn.addEventListener(MouseEvent.CLICK,target ? mhTapTarget : mhTapPlayer,false,0,true);
         }
         var want:int = over.parent === ui ? ui.getChildIndex(over) + 1 : ui.numChildren;
         if(btn.parent !== ui)
         {
            ui.addChildAt(btn,Math.min(want,ui.numChildren));
         }
         else if(ui.getChildIndex(btn) < want - 1)
         {
            ui.setChildIndex(btn,Math.min(want - 1,ui.numChildren - 1));
         }
         return btn;
      }

      private static function mhGlyph(btn:Sprite, step:int) : void
      {
         var face:Shape = btn.getChildByName("face") as Shape;
         if(face == null || mhDrawn[btn] === step)
         {
            return;
         }
         mhDrawn[btn] = step;
         var g:Graphics = face.graphics;
         g.clear();
         g.lineStyle(1.5,13214282,1);
         g.beginFill(1709072,0.9);
         g.drawCircle(0,0,11);
         g.endFill();
         g.lineStyle(2.5,16777215,1);
         if(step == 3)
         {
            g.moveTo(-5,0);
            g.lineTo(5,0);
            g.moveTo(0,-5);
            g.lineTo(0,5);
         }
         else if(step == 2)
         {
            g.moveTo(-4,-4);
            g.lineTo(4,4);
            g.moveTo(4,-4);
            g.lineTo(-4,4);
         }
         else
         {
            g.moveTo(-5,0);
            g.lineTo(5,0);
         }
      }

      private static function mhTapPlayer(e:MouseEvent) : void
      {
         mhCycle("mvaPortP");
      }

      private static function mhTapTarget(e:MouseEvent) : void
      {
         mhCycle("mvaPortT");
      }

      private static function mhCycle(key:String) : void
      {
         var game:*;
         var data:*;
         try
         {
            game = Main.instance.getGame();
            data = game.litePreference.data;
            data[key] = (mhStep(data[key]) + 1) % MH_STEPS.length;
            game.litePreference.flush();
         }
         catch(e:Error)
         {
         }
      }

      private static function mhUndoPortraits() : void
      {
         if(mhPort != null)
         {
            mhPort.scaleX = mhPort.scaleY = 1;
            mhPort.x = mhPortX;
            mhPort.y = mhPortY;
         }
         if(mhTarget != null)
         {
            mhTarget.scaleX = mhTarget.scaleY = 1;
            mhTarget.x = mhTargetX;
            mhTarget.y = mhTargetY;
         }
         for each(var b in [mhBtnP,mhBtnT])
         {
            if(b != null && b.parent != null)
            {
               b.parent.removeChild(b);
            }
         }
         mhPort = mhTarget = null;
      }

      public static function mhAuraIcon(link:String, size:int) : String
      {
         var game:*;
         var parts:Array;
         var c:Class;
         var d:DisplayObject;
         var r:Rectangle;
         var k:Number;
         var m:Matrix;
         var bmd:BitmapData;
         var px:ByteArray;
         try
         {
            game = Main.instance.getGame();
            if(link.indexOf(",") > -1)
            {
               parts = link.split(",");
               link = String(parts[parts.length - 1]);
            }
            size = Math.max(8,Math.min(64,size));
            c = game.world.getClass(link) as Class;
            if(c == null)
            {
               return "";
            }
            d = new c() as DisplayObject;
            if(d is MovieClip)
            {
               MovieClip(d).gotoAndStop(1);
            }
            r = d.getBounds(d);
            if(!(r.width > 0 && r.height > 0))
            {
               return "";
            }
            k = size / Math.max(r.width,r.height);
            m = new Matrix(k,0,0,k,-r.x * k + (size - r.width * k) / 2,-r.y * k + (size - r.height * k) / 2);
            bmd = new BitmapData(size,size,true,0);
            bmd.draw(d,m,null,null,null,true);
            px = bmd.getPixels(bmd.rect);
            bmd.dispose();
            return size + ":" + mhBase64(px);
         }
         catch(e:Error)
         {
         }
         return "";
      }

      private static function mhBase64(b:ByteArray) : String
      {
         var out:Array = [];
         var i:int = 0;
         var n:int = int(b.length);
         while(i < n)
         {
            var b0:int = int(b[i]);
            var b1:int = int(i + 1 < n ? b[i + 1] : 0);
            var b2:int = int(i + 2 < n ? b[i + 2] : 0);
            out.push(MH_B64.charAt(b0 >> 2),MH_B64.charAt((b0 & 3) << 4 | b1 >> 4),i + 1 < n ? MH_B64.charAt((b1 & 0x0F) << 2 | b2 >> 6) : "=",i + 2 < n ? MH_B64.charAt(b2 & 0x3F) : "=");
            i += 3;
         }
         return out.join("");
      }

      private static function mhRestore(game:*) : void
      {
         var opts:*;
         mhApplied = false;
         try
         {
            mhUndoBar();
            if(mhMenu != null)
            {
               mhMenu.visible = true;
            }
            if(mhArea != null)
            {
               mhArea.y = mhAreaY;
            }
            if(mhTray != null)
            {
               mhTray.x = mhTray.y = 0;
            }
            mhUndoSkills();
            mhUndoPortraits();
            opts = game.litePreference.data.dOptions;
            if(game.pAurasUI != null && (opts == null || opts.posAurasP == null))
            {
               game.pAurasUI.x = 130;
               game.pAurasUI.y = 100;
            }
            if(game.tAurasUI != null && (opts == null || opts.posAurasT == null))
            {
               game.tAurasUI.x = 320;
               game.tAurasUI.y = 104;
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}
