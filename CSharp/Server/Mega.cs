using System;
using System.Reflection;
using Barotrauma;
using HarmonyLib;
using Microsoft.Xna.Framework;

using System.Collections.Generic;
using System.Linq;
using System;
using Barotrauma.Extensions;
using System.Threading;

using Barotrauma.Networking;

namespace Megamod
{
    class MegamodServer : IAssemblyPlugin
    {
        public Harmony harmony;
        public void Initialize()
        {
            harmony = new Harmony("mega.mod2");

            harmony.Patch(
              original: typeof(Barotrauma.Networking.GameServer).GetMethod("UpdateVoteStatus"),
              prefix: new HarmonyMethod(typeof(MegamodServer).GetMethod("UpdateVoteStatus"))
            );
        }
        public void OnLoadCompleted() { }
        public void PreInitPatching() { }

        public void Dispose()
        {
            harmony.UnpatchSelf();
            harmony = null;
        }

        //lua uses this
        public static bool endGame;

        public static bool UpdateVoteStatus(Barotrauma.Networking.GameServer __instance, bool checkActiveVote = true)
        {
            Barotrauma.Networking.GameServer _ = __instance;
            Barotrauma.Voting Voting = _.Voting;

            if (_.connectedClients.Count == 0) { return false; }

            if (checkActiveVote && Voting.ActiveVote != null)
            {
                var inGameClients = GameMain.Server.ConnectedClients.Where(c => c.InGame);
                if (inGameClients.Count() == 1 && inGameClients.First() == Voting.ActiveVote.VoteStarter)
                {
                    Voting.ActiveVote.Finish(Voting, passed: true);
                }
                else if (inGameClients.Any())
                {
                    var eligibleClients = inGameClients.Where(c => c != Voting.ActiveVote.VoteStarter);
                    int yes = eligibleClients.Count(c => c.GetVote<int>(Voting.ActiveVote.VoteType) == 2);
                    int no = eligibleClients.Count(c => c.GetVote<int>(Voting.ActiveVote.VoteType) == 1);
                    int max = eligibleClients.Count();
                    // Required ratio cannot be met
                    if (no / (float)max > 1f - _.ServerSettings.VoteRequiredRatio)
                    {
                        Voting.ActiveVote.Finish(Voting, passed: false);
                    }
                    else if (yes / (float)max >= _.ServerSettings.VoteRequiredRatio)
                    {
                        Voting.ActiveVote.Finish(Voting, passed: true);
                    }
                }
            }

            Client.UpdateKickVotes(_.connectedClients);

            var kickVoteEligibleClients = _.connectedClients.Where(c => (DateTime.Now - c.JoinTime).TotalSeconds > _.ServerSettings.DisallowKickVoteTime);
            float minimumKickVotes = Math.Max(2.0f, kickVoteEligibleClients.Count() * _.ServerSettings.KickVoteRequiredRatio);
            var clientsToKick = _.connectedClients.FindAll(c =>
                c.Connection != _.OwnerConnection &&
                !c.HasPermission(ClientPermissions.Kick) &&
                !c.HasPermission(ClientPermissions.Ban) &&
                !c.HasPermission(ClientPermissions.Unban) &&
                c.KickVoteCount >= minimumKickVotes);
            foreach (Client c in clientsToKick)
            {
                //reset the client's kick votes (they can rejoin after their ban expires)
                c.ResetVotes(resetKickVotes: true);
                _.previousPlayers.Where(p => p.MatchesClient(c)).ForEach(p => p.KickVoters.Clear());
                _.BanClient(c, "ServerMessage.KickedByVoteAutoBan", duration: TimeSpan.FromSeconds(_.ServerSettings.AutoBanTime));
            }

            //GameMain.NetLobbyScreen.LastUpdateID++;

            _.SendVoteStatus(_.connectedClients);


            var endVoteEligibleClients = _.connectedClients.Where(c => Voting.CanVoteToEndRound(c));
            int endVoteCount = endVoteEligibleClients.Count(c => c.GetVote<bool>(VoteType.EndRound));
            int endVoteMax = endVoteEligibleClients.Count();
            if (_.ServerSettings.AllowEndVoting && endVoteMax > 0 &&
                (endVoteCount / (float)endVoteMax) >= _.ServerSettings.EndVoteRequiredRatio)
            {
                endGame = true;
            }
            return false;
        }
    }
}