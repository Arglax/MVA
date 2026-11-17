package mva
{
   import flash.external.ExternalInterface;
   import mva.ui.Modules;

   public class PageLink
   {

      public function PageLink()
      {
         super();
      }

      public function init(main:Main) : void
      {
         if(!ExternalInterface.available)
         {
            return;
         }
         ExternalInterface.addCallback("loadClient",Main.loadGame);
         ExternalInterface.addCallback("isNull",Main.isNull);
         ExternalInterface.addCallback("getGameObject",Main.getGameObject);
         ExternalInterface.addCallback("setGameObject",Main.setGameObject);
         ExternalInterface.addCallback("callGameFunction",Main.callGameFunction);
         ExternalInterface.addCallback("availableMonsters",Main.availableMonsters);
         ExternalInterface.addCallback("mvaClassRatings",Modules.setRatings);
         ExternalInterface.addCallback("mvaRatingFocus",Modules.setFocus);
         ExternalInterface.addCallback("mvaMenuClick",Modules.menuClick);
         ExternalInterface.addCallback("mvaMenuClose",Modules.menuClose);
         ExternalInterface.addCallback("mvaGameButton",Modules.gameButton);
         ExternalInterface.addCallback("mvaDropsOn",Modules.dropsOn);
         ExternalInterface.addCallback("mvaDropAccept",Modules.dropAccept);
         ExternalInterface.addCallback("mvaDropDecline",Modules.dropDecline);
         ExternalInterface.addCallback("mvaDropPreview",Modules.dropPreview);
         ExternalInterface.addCallback("mvaTouchUi",Modules.setTouchUi);
         ExternalInterface.addCallback("mvaAuraIcon",Modules.mhAuraIcon);
         ExternalInterface.addCallback("mvaMobileActive",Modules.mhMobileActive);
         ExternalInterface.addCallback("mvaOptions",Modules.optionsJson);
         ExternalInterface.addCallback("mvaSetOption",Modules.setOption);
         ExternalInterface.addCallback("mvaAuraCasters",AuraWatch.auraCasters);
         ExternalInterface.addCallback("mvaGameOptions",Modules.gameOptions);
         ExternalInterface.addCallback("mvaGameOption",Modules.gameOption);
         ExternalInterface.addCallback("mvaQuick",Quick.run);
         ExternalInterface.addCallback("mvaTravel",Quick.travel);
         ExternalInterface.addCallback("mvaQuickState",Quick.state);
         this.call("requestLoadGame");
      }

      public function call(name:String, ... rest) : *
      {
         if(!ExternalInterface.available)
         {
            return null;
         }
         return ExternalInterface.call(name,rest);
      }
   }
}
