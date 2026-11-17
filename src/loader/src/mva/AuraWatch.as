package mva
{
   import flash.utils.getTimer;

   public class AuraWatch
   {
      public function AuraWatch()
      {
         super();
      }

      private static var _watchSfc:* = null;
      private static var _watchCasters:Object = {};
      private static var _watchLog:Array = [];

      public static function watch():void {
          watchAuras();
      }

      private static function watchAuras():void {
          try {
              var sfc:* = Main.instance.game != null ? Main.instance.game.sfc : null;
              if (sfc == null || sfc == _watchSfc) {
                  return;
              }
              if (_watchSfc != null) {
                  _watchSfc.removeEventListener("onExtensionResponse", onAuraPacket);
              }
              _watchSfc = sfc;
              sfc.addEventListener("onExtensionResponse", onAuraPacket);
          } catch (e:Error) {
          }
      }

      private static function onAuraPacket(evt:*):void {
          try {
              var o:* = evt.params.dataObj;
              if (o == null || typeof o != "object" || o.cmd == null) {
                  return;
              }

              if (o.cmd == "moveToArea") {
                  _watchCasters = {};
                  Quick.visited(o);
                  return;
              }
              var list:Array = null;
              if (o.cmd == "ct" && o.a is Array) {
                  list = o.a;
              } else if (String(o.cmd).indexOf("aura") == 0) {
                  list = [o];
              }
              if (list == null) {
                  return;
              }
              var byAnim:Object = {};
              if (o.anims is Array) {
                  for each (var an:* in o.anims) {
                      if (an != null && an.cInf != null && an.tInf != null) {
                          for each (var ti:String in String(an.tInf).split(",")) {
                              byAnim[ti] = String(an.cInf);
                          }
                      }
                  }
              }
              var now:int = getTimer();
              for each (var e:* in list) {
                  if (e == null || e.tInf == null || !(e.auras is Array)) {
                      continue;
                  }
                  var cmd:String = String(e.cmd);
                  var tinf:String = String(e.tInf);
                  var c:String = e.cInf != null ? String(e.cInf) : (byAnim[tinf] != null ? String(byAnim[tinf]) : "");
                  var src:String = e.cInf != null ? "packet" : (c != "" ? "skill" : "none");
                  var names:Array = [];
                  for each (var a:* in e.auras) {
                      if (a == null || a.nam == null) {
                          continue;
                      }
                      names.push(String(a.nam));

                      if (cmd.indexOf("aura+") == 0 && c != "") {
                          _watchCasters[tinf + "|" + String(a.nam)] = {c: c, s: src, t: now};
                      } else if (cmd.indexOf("aura+") == 0 || cmd.indexOf("aura-") == 0) {
                          delete _watchCasters[tinf + "|" + String(a.nam)];
                      }
                  }
                  _watchLog.push({t: now, cmd: cmd, c: c, tg: tinf, s: src, n: names.join(",")});
                  if (_watchLog.length > 60) {
                      _watchLog.shift();
                  }
              }
          } catch (err:Error) {
          }
      }

      public static function auraCasters():String {
          watchAuras();
          return JSON.stringify({now: getTimer(), casters: _watchCasters, log: _watchLog.slice(-30)});
      }

   }
}
