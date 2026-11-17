package mva.ui
{
   public class Module
   {

      public var name:String = "Module";

      public var enabled:Boolean = false;

      public function Module(param1:String)
      {
         super();
         this.name = param1;
      }

      public function onToggle(param1:*) : void
      {
      }

      public function onFrame(param1:*) : void
      {
      }
   }
}
