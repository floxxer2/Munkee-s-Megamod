using Barotrauma;
using System;

namespace TalentManagerMod
{
    class TalentManager : ACsMod
    {
        public LuaCsSetup.LuaCsModStore.CsModStore ModStore { get; private set; }

        public TalentManager()
        {
            ModStore = GameMain.LuaCs.ModStore.Register(this);
            ModStore.Mod = this;
            ModStore.Set("Instance", this);
        }

        public static void ClearTalents(Character character)
        {
            if (character == null)
            {
                LuaCsLogger.Log("Character is null");
                return;
            }

            var characterInfo = character.Info;

            if (characterInfo != null && characterInfo.UnlockedTalents != null)
            {
                characterInfo.UnlockedTalents.Clear();
            }
            else
            {
                LuaCsLogger.Log("UnlockedTalents is null");
            }
        }

        public override void Stop()
        {
            
        }
    }
}
