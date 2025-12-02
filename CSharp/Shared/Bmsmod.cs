using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime.CompilerServices;
using Microsoft.Xna.Framework;
using HarmonyLib;
using FarseerPhysics;
using Barotrauma;
using Barotrauma.Extensions;
using Barotrauma.Items.Components;
using static Barotrauma.AIObjectiveFindSafety;

// Ammo Penetrate Corpse https://steamcommunity.com/sharedfiles/filedetails/?id=3543916066
// This is creative commons licensed. (Copyright (c) 2025 Diemoe)

namespace NFF_Harmony
{
    partial class NFFHarmony : IAssemblyPlugin
    {
        private const bool debug = false;
        private const string harmony_id = "com.NFF.Harmony";
        private readonly Harmony harmony;

        public NFFHarmony()
        {
            harmony = new Harmony(harmony_id);
            harmony.PatchAll(Assembly.GetExecutingAssembly());

            if (debug)
            {
                Barotrauma.DebugConsole.AddWarning("Loaded NFFHarmony");
            }
        }

        public void Dispose()
        {
            harmony.UnpatchSelf();
        }

        public void OnLoadCompleted() { }
        public void PreInitPatching() { }
        public void Initialize() { }

        [HarmonyPatch(typeof(Barotrauma.Items.Components.Projectile))]
        [HarmonyPatch(nameof(Barotrauma.Items.Components.Projectile.ShouldIgnoreCharacterCollision))]
        public static class Patch_ShouldIgnoreCharacterCollision
        {
            static void Postfix(ref bool __result, Projectile __instance, Character character)
            {
                if (__result || __instance?.User == null || character == null) return;

                // Skip dead monsters (projectiles fly through their corpses)
                if (character.IsDead && character.TeamID == CharacterTeamType.None)
                {
                    __result = true; // set to false to disable corpse penetration
                    return;
                }

                // CODE REMOVED BY MUNKEE -->
                // Ignore live characters on the same team (e.g. friendly fire prevention)
                /*if (!character.IsDead && __instance.User.TeamID == character.TeamID)
                {
                    __result = true; // set to false to enable friendly fire
                }

                // Ignore defence bot as if it's a your crew
                if (character.SpeciesName.Value.Equals("defensebot", StringComparison.OrdinalIgnoreCase))
                {
                    __result = true; // set to false to shot defence bot
                }*/
            }
        }

        [HarmonyPatch(typeof(AIObjectiveCombat), nameof(AIObjectiveCombat.Attack))]
        public static class Patch_Attack
        {
            static bool Prefix(AIObjectiveCombat __instance, float deltaTime)
            {
                var t = Traverse.Create(__instance);
                Character character = t.Field("character").GetValue<Character>();
                Character Enemy = __instance.Enemy;
                float sqrDistance = t.Field("sqrDistance").GetValue<float>();

                Item Weapon = __instance.Weapon;
                ItemComponent WeaponComponent = t.Property("WeaponComponent").GetValue<ItemComponent>();

                var HumanAIController = character?.AIController as HumanAIController;

                float AimAccuracy = 1.0f;
                float AimSpeed = 1.0f;

                if (HumanAIController != null)
                {
                    var hc = Traverse.Create(HumanAIController);
                    AimAccuracy = hc.Property("AimAccuracy").GetValue<float>();
                    AimSpeed = hc.Property("AimSpeed").GetValue<float>();
                }

                float spreadTimer = t.Field("spreadTimer").GetValue<float>();
                float visibilityCheckTimer = t.Field("visibilityCheckTimer").GetValue<float>();
                float aimTimer = t.Field("aimTimer").GetValue<float>();
                float reloadTimer = t.Field("reloadTimer").GetValue<float>();
                float holdFireTimer = t.Field("holdFireTimer").GetValue<float>();
                bool canSeeTarget = t.Field("canSeeTarget").GetValue<bool>();
                bool AllowHoldFire = __instance.AllowHoldFire;

                Func<bool> holdFireCondition = __instance.holdFireCondition;

                character.CursorPosition = Enemy.WorldPosition;

                if (AimAccuracy < 1)
                {
                    spreadTimer += deltaTime * Rand.Range(0.01f, 1f);
                    float shake = Rand.Range(0.95f, 1.05f);
                    float offsetAmount = (1 - AimAccuracy) * Rand.Range(300f, 500f);
                    float distanceFactor = MathUtils.InverseLerp(0, 1000 * 1000, sqrDistance);
                    float offset = (float)Math.Sin(spreadTimer * shake) * offsetAmount * distanceFactor;
                    character.CursorPosition += new Vector2(0, offset);
                    t.Field("spreadTimer").SetValue(spreadTimer);
                }

                if (character.Submarine != null)
                {
                    character.CursorPosition -= character.Submarine.Position;
                }

                visibilityCheckTimer -= deltaTime;
                if (visibilityCheckTimer <= 0.0f)
                {
                    canSeeTarget = character.CanSeeTarget(Enemy);
                    visibilityCheckTimer = 0.2f;
                }
                t.Field("visibilityCheckTimer").SetValue(visibilityCheckTimer);
                t.Field("canSeeTarget").SetValue(canSeeTarget);

                if (!canSeeTarget)
                {
                    __instance.SetAimTimer(Rand.Range(0.2f, 0.4f) / AimSpeed);
                    return false;
                }

                if (Weapon.RequireAimToUse)
                {
                    character.SetInput(InputType.Aim, hit: false, held: true);
                }

                t.Field("hasAimed").SetValue(true);

                if (AllowHoldFire && holdFireTimer > 0)
                {
                    holdFireTimer -= deltaTime;
                    t.Field("holdFireTimer").SetValue(holdFireTimer);
                    return false;
                }

                if (aimTimer > 0)
                {
                    aimTimer -= deltaTime;
                    t.Field("aimTimer").SetValue(aimTimer);
                    return false;
                }

                sqrDistance = Vector2.DistanceSquared(character.WorldPosition, Enemy.WorldPosition);
                t.Field("sqrDistance").SetValue(sqrDistance);
                t.Field("distanceTimer").SetValue(0.2f);

                if (WeaponComponent is MeleeWeapon meleeWeapon)
                {
                    bool closeEnough = true;
                    float sqrRange = meleeWeapon.Range * meleeWeapon.Range;

                    if (character.AnimController.InWater)
                    {
                        if (sqrDistance > sqrRange) closeEnough = false;
                    }
                    else
                    {
                        float xDiff = Math.Abs(Enemy.WorldPosition.X - character.WorldPosition.X);
                        float yDiff = Math.Abs(Enemy.WorldPosition.Y - character.WorldPosition.Y);

                        if (xDiff > meleeWeapon.Range || yDiff > Math.Max(meleeWeapon.Range, 100))
                        {
                            closeEnough = false;
                        }

                        if (closeEnough && Enemy.WorldPosition.Y < character.WorldPosition.Y && yDiff > 25)
                        {
                            HumanAIController?.AnimController?.Crouch();
                        }
                    }

                    if (reloadTimer > 0) return false;
                    if (holdFireCondition != null && holdFireCondition()) return false;

                    if (closeEnough)
                    {
                        __instance.UseWeapon(deltaTime);
                        character.AIController.SteeringManager.Reset();
                    }
                    else if (!character.IsFacing(Enemy.WorldPosition))
                    {
                        __instance.SetAimTimer(Rand.Range(1f, 1.5f) / AimSpeed);
                    }
                }
                else
                {
                    if (WeaponComponent is RepairTool repairTool)
                    {
                        float reach = AIObjectiveFixLeak.CalculateReach(repairTool, character);
                        if (sqrDistance > reach * reach) return false;
                    }

                    float aimFactor = MathHelper.PiOver2 * (1 - AimAccuracy);
                    if (VectorExtensions.Angle(VectorExtensions.Forward(Weapon.body.TransformedRotation), Enemy.WorldPosition - Weapon.WorldPosition) < MathHelper.PiOver4 + aimFactor)
                    {
                        __instance.UseWeapon(deltaTime);
                    }
                }

                return false;
            }
        }
    }
}
