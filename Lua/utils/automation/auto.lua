if CLIENT then return end
Auto = {}
---@type string
Auto.Path = ...

local version = "1.0.0.0"

--[[
1: Rewrite auto.bat to download mods
2: Change %ModDir%'s, rewrite filelist, rewrite auto.bat to copy lua files, apply xml/lua overrides
]]
Auto.Step = 0

-- Setting an override to an empty string deletes the original
Auto.XMLChanges = {
  -- ****************
  -- Pure Empty Level
  -- ****************
  -- 1. Change height to 200 000, change background / ambient light to purple-ish
  -- 2. Add background effects
  ["pureemptylevel"] = {
    mod = "Pure Empty Level",
    xml = XElement.Parse([[
      <Empty identifier="pureemptylevel" type="LocationConnection" biomes="any" commonness="100"
        forcebeaconstation="%ModDir%/PEL/Map/BeaconStations/PEL_BeaconStation_Dummy.sub"
        minleveldifficulty="0" maxleveldifficulty="100" startposition="0.5,0.5" endposition="0.9,0.1"
        createholenexttoend="false" createholetoabyss="false" nolevelgeometry="true"
        levelobjectamount="0" backgroundcreatureamount="80" minwidth="200000" maxwidth="200000"
        height="200000" InitialDepthMin="100000" InitialDepthMax="200000" mintunnelradius="20000"
        sidetunnelcount="0,0" voronoisiteinterval="20000,20000" voronoisitevariance="0,0"
        cellroundingamount="0.0" cellirregularity="0.0" mainpathvariance="0.0" cavecount="0"
        itemcount="0" floatingicechunkcount="0" islandcount="0" icespirecount="0" abyssislandcount="0"
        SeaFloorDepth="-200000" seafloorvariance="0" mountaincountmin="0" mountaincountmax="0"
        ruincount="0" minwreckcount="0" maxwreckcount="0" mincorpsecount="0" maxcorpsecount="0"
        thalamusprobability="0.0" bottomholeprobability="1.0" AmbientLightColor="5,0,5,255"
        BackgroundTextureColor="15,0,15,255" BackgroundColor="5,0,5,255" walltexturesize="512"
        walledgetexturewidth="1024" walledgeexpandoutwardsamount="128" walledgeexpandinwardsamount="128">
        <Background texture="Content/Map/Background.png" />
        <BackgroundTop texture="Content/Map/Background2.png" premultiplyalpha="false" />
        <WaterParticles texture="Content/Map/Biomes/ColdCaverns/BackgroundParticles.png" />
        <Wall texture="Content/Map/Biomes/TheGreatSea/LevelWall.png" premultiplyalpha="false" />
        <WallEdge texture="Content/Map/Biomes/TheGreatSea/LevelWallEdge.png" />
        <DestructibleWall texture="Content/Map/Biomes/DestructibleWall.png" />
        <DestructibleWallEdge texture="Content/Map/Biomes/DestructibleWallEdge.png" />
        <WallDestroyed texture="Content/Map/Biomes/DestroyedWall.png" premultiplyalpha="false" />
      </Empty>]])
  },

  -- ***********
  -- Pile Bunker
  -- ***********
  -- #TODO#:
  -- Tweak recipe, change fabricator to weapon fabricator
  ["pilebunker"] = {
    mod = "Pile Bunker v2.0",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="60" requiresrecipe="false">
            <RequiredSkill identifier="mechanical" level="90" />
            <RequiredSkill identifier="weapons" level="80" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="4" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
            <RequiredItem identifier="fpgacircuit" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Tweak recipe, change fabricator to ammo fabricator
  ["pilecharge"] = {
    mod = "Pile Bunker v2.0",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="60" />
            <RequiredSkill identifier="mechanical" level="50" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="flashpowder" amount="2" />
            <RequiredItem identifier="c4block" />
          </Fabricate>]])
      },
    },
  },

  -- *************
  -- BaroTraumatic
  -- *************
  -- Prioritize BT's overrides
  ["headset"] = {
    mod = "BaroTraumatic",
  },
  ["BTCpressureinjectorheadset"] = {
    mod = "BaroTraumatic",
  },
  ["autoinjectorheadset"] = {
    mod = "BaroTraumatic",
  },
  ["ekutility_advancedheadset"] = {
    mod = "BaroTraumatic",
  },
  -- Change fabricator to weapon fabricator
  ["ek_security_radio"] = {
    mod = "BaroTraumatic",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="15">
            <RequiredSkill identifier="electrical" level="35" />
            <RequiredItem identifier="rubber" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="wificomponent" />
          </Fabricate>]])
      }
    }
  },

  -- ***************************
  -- Barotraumatic Creature Pack
  -- ***************************
  -- Remove fabrication recipe
  ["largefleshstinger"] = {
    mod = "Barotraumatic Creature Pack",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["banditoxygentankbomb"] = {
    mod = "Barotraumatic Creature Pack",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["banditweldingbomb"] = {
    mod = "Barotraumatic Creature Pack",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },

  -- *********************************
  -- Husk Church Cathedral Visual Pack
  -- *********************************
  -- Remove fabrication recipe
  ["Cultist hood"] = {
    mod = "Husk Church Cathedral Visual Pack",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["Cultist robe"] = {
    mod = "Husk Church Cathedral Visual Pack",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },

  -- ***************
  -- Stun Gun Revamp
  -- ***************
  -- Change fabricator to weapon fabricator
  ["stungunnew"] = {
    mod = "Stun Gun Revamp",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to weapon fabricator
  ["stungundartnew"] = {
    mod = "Stun Gun Revamp",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" amount="2">
            <RequiredSkill identifier="weapons" level="30" />
            <Item identifier="steel" />
            <Item tag="wire" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to weapon fabricator
  ["stungundartfulgurium"] = {
    mod = "Stun Gun Revamp",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="25" amount="2" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="40" />
            <Item identifier="fulgurium" />
            <Item tag="wire" />
          </Fabricate>]])
      }
    }
  },

  -- *******************
  -- Immersive Handcuffs
  -- *******************
  -- Remove
  ["handcuffsspawned"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  -- Fix: Replace "handcuffsspawned" with "handcuffs"
  ["handcuffsequipped"] = {
    mod = "Immersive Handcuffs",
    xml = XElement.Parse([[
      <Item nameidentifier="handcuffs" descriptionidentifier="handcuffs" identifier="handcuffsequipped" category="Equipment" maxstacksize="1" cargocontaineridentifier="metalcrate" tags="smallitem,handcuffs,handlocker,regularcuffs" scale="0.5" impactsoundtag="impact_metal_light" noninteractable="true" hideinmenus="true">
        <Deconstruct time="1" />
        <InventoryIcon texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" sourcerect="57,0,52,40" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" sourcerect="57,0,52,40" depth="0.6" origin="0.5,0.5" />
        <Body width="50" height="34" density="30" />
        <Wearable slots="RightHand" msg="ItemMsgPickUpSelect" autoequipwhenfull="true">
          <sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" limb="RightForearm" sourcerect="117,1,25,16" origin="0.53,-1.3" depth="0.09" inheritlimbdepth="true" inherittexturescale="true" />
          <sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" limb="LeftForearm" sourcerect="142,1,25,16" origin="0.53,-1.3" depth="0.09" inheritlimbdepth="true" inherittexturescale="true" />
          <!-- Constantly reduce the timeframe value at different intervals to make it harder to break free -->
          <StatusEffect type="OnWearing" target="This" timeframe="-1.5" interval="0.5" disabledeltatime="true" />
          <StatusEffect type="OnWearing" target="This" timeframe="-5" interval="4" disabledeltatime="true" />
          <!-- Lock the hands of the character wearing the item | disabled since it's done via "handcuffed" affliction
          <StatusEffect type="OnWearing" target="Character" lockhands="true" setvalue="true" />-->
          <StatusEffect type="OnWearing" target="Character" statuseffecttags="cuffed" duration="0.1" interval="0.1" />
          <!-- Remove the item, if the character has the temporary tag "unlocked" gained from the "retrievehandcuffs" affliction -->
          <StatusEffect type="OnWearing" target="This" condition="0" setvalue="true">
            <Conditional HasStatusTag="eq unlocked" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This" oneshot="true" disabledeltatime="true">
            <Conditional isdead="true" targetcontainer="true" />
            <SpawnItem identifier="handcuffs" spawnposition="SameInventory" spawnifcantbecontained="true" SpawnIfInventoryFull="true" />
            <Remove />
          </StatusEffect>
          <!-- Had to break the item instead of removing directly as the sound would otherwise refuse to play. I really hate this game sometimes... -->
          <StatusEffect type="OnBroken" target="This">
            <Sound file="%ModDir%/Content/Sounds/uncuffing1.ogg" volume="2.5" range="350" loop="false" />
            <Remove />
          </StatusEffect>
          <!-- Remove the item if it was somehow spawned into a container other than the character's inventory -->
          <StatusEffect type="OnContained" target="This">
            <Conditional HasTag="eq container" />
            <Remove />
          </StatusEffect>
          <!-- Remove the item if it was somehow spawned outside an inventory -->
          <StatusEffect type="OnNotContained" target="This">
            <Remove />
          </StatusEffect>
        </Wearable>
        <!-- GreaterComponent is used for its timeframe value to keep track of progress breaking free -->
        <!-- By pressing the GUI button, the timeframe value increases and if it reaches a value of 25 or higher, the player will be freed -->
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0" />
        <CustomInterface canbeselected="false" drawhudwhenequipped="true">
          <GuiFrame style="ItemUI" absoluteoffset="0,0" anchor="BottomCenter" relativesize="0.12,0.08" />
          <Button text="interaction.struggletofree">
            <!-- Increase the timeframe value per button press and create an invisible explosion to jiggle the character a little -->
            <StatusEffect type="OnUse" target="This" timeframe="1" disabledeltatime="true">
              <Explosion range="50" force="0.2" itemdamage="0.0" structuredamage="0.0" ignorecover="true" ballastfloradamage="0.0" camerashake="1" camerashakerange="100" explosiondamage="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" playtinnitus="false" />
            </StatusEffect>
            <!-- Play a rattling sound loop if you spam the button -->
            <StatusEffect type="OnUse" target="This" duration="0.3">
              <Sound file="%ModDir%/Content/Sounds/cuffrattleloop.ogg" range="400" volume="1" frequencymultiplier="1.5" loop="true" />
            </StatusEffect>
            <!-- Apply random amounts of bluntrauma and bleeding to the hands on each button press -->
            <StatusEffect type="OnUse" target="Character" targetlimbs="LeftHand" disabledeltatime="true">
              <Affliction identifier="blunttrauma" amount="3" probability="0.1" />
              <Affliction identifier="blunttrauma" amount="2" probability="0.15" />
              <Affliction identifier="blunttrauma" amount="1" probability="0.2" />
              <Affliction identifier="bleeding" amount="1" probability="0.1" />
            </StatusEffect>
            <StatusEffect type="OnUse" target="Character" targetlimbs="RightHand" disabledeltatime="true">
              <Affliction identifier="blunttrauma" amount="3" probability="0.1" />
              <Affliction identifier="blunttrauma" amount="2" probability="0.15" />
              <Affliction identifier="blunttrauma" amount="1" probability="0.2" />
              <Affliction identifier="bleeding" amount="1" probability="0.1" />
            </StatusEffect>
            <!-- On button pressed, if the timeframe is at or above 25, remove the handcuffed affliction from the character and play an uncuffing sound -->
            <StatusEffect type="OnUse" target="This,Character" disabledeltatime="true">
              <Conditional timeframe="gte 25" />
              <ReduceAffliction identifier="handcuffed" amount="1000" />
              <Sound file="%ModDir%/Content/Sounds/uncuffing1.ogg" volume="2.5" range="350" loop="false" />
            </StatusEffect>
            <!-- On button pressed, if the timeframe is at or above 25, create a stronger invisible explosion to make the character jiggle harder, play a breaking sound, remove the handcuffs and spawn the broken version at their position -->
            <StatusEffect type="OnUse" target="This" disabledeltatime="true" forceplaysounds="true">
              <Conditional timeframe="gte 25" />
              <Sound file="Content/Sounds/Damage/HitMetal1.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal2.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal3.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal4.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal5.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal6.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Explosion range="100" force="1.5" itemdamage="0.0" structuredamage="0.0" ignorecover="true" ballastfloradamage="0.0" camerashake="1" camerashakerange="100" explosiondamage="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" playtinnitus="false" />
              <Remove />
              <SpawnItem identifier="brokenhandcuffs" spawnposition="This" />
            </StatusEffect>
          </Button>
        </CustomInterface>
      </Item>]])
  },
  -- Fix: Replace "handcuffsspawned" with "handcuffs"
  ["handcuffsequipped2"] = {
    mod = "Immersive Handcuffs",
    xml = XElement.Parse([[
      <Item nameidentifier="handcuffs" descriptionidentifier="handcuffs" identifier="handcuffsequipped2" category="Equipment" maxstacksize="1" cargocontaineridentifier="metalcrate" tags="smallitem,handcuffs,handlocker,regularcuffs" scale="0.5" impactsoundtag="impact_metal_light" noninteractable="true" hideinmenus="true">
        <Deconstruct time="1" />
        <InventoryIcon texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" sourcerect="57,0,52,40" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" sourcerect="57,0,52,40" depth="0.6" origin="0.5,0.5" />
        <Body width="50" height="34" density="30" />
        <Wearable slots="LeftHand" msg="ItemMsgPickUpSelect" autoequipwhenfull="true">
          <sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" limb="RightForearm" sourcerect="117,1,25,16" origin="0.53,-1.3" depth="0.09" inheritlimbdepth="true" inherittexturescale="true" />
          <sprite texture="%ModDir%/Content/Items/IH-ItemsAtlas.png" limb="LeftForearm" sourcerect="142,1,25,16" origin="0.53,-1.3" depth="0.09" inheritlimbdepth="true" inherittexturescale="true" />
          <!-- Constantly reduce the timeframe value at different intervals to make it harder to break free -->
          <StatusEffect type="OnWearing" target="This" timeframe="-1.5" interval="0.5" disabledeltatime="true" />
          <StatusEffect type="OnWearing" target="This" timeframe="-5" interval="4" disabledeltatime="true" />
          <!-- Lock the hands of the character wearing the item | disabled since it's done via "handcuffed" affliction
          <StatusEffect type="OnWearing" target="Character" lockhands="true" setvalue="true" />-->
          <StatusEffect type="OnWearing" target="Character" statuseffecttags="cuffed" duration="0.1" interval="0.1" />
          <!-- Remove the item, if the character has the temporary tag "unlocked" gained from the "retrievehandcuffs" affliction -->
          <StatusEffect type="OnWearing" target="This" condition="0" setvalue="true">
            <Conditional HasStatusTag="eq unlocked" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This" oneshot="true" disabledeltatime="true">
            <Conditional isdead="true" targetcontainer="true" />
            <SpawnItem identifier="handcuffs" spawnposition="SameInventory" spawnifcantbecontained="true" SpawnIfInventoryFull="true" />
            <Remove />
          </StatusEffect>
          <!-- Had to break the item instead of removing directly as the sound would otherwise refuse to play. I really hate this game sometimes... -->
          <StatusEffect type="OnBroken" target="This">
            <Sound file="%ModDir%/Content/Sounds/uncuffing1.ogg" volume="2.5" range="350" loop="false" />
            <Remove />
          </StatusEffect>
          <!-- Remove the item if it was somehow spawned into a container other than the character's inventory -->
          <StatusEffect type="OnContained" target="This">
            <Conditional HasTag="eq container" />
            <Remove />
          </StatusEffect>
          <!-- Remove the item if it was somehow spawned outside an inventory -->
          <StatusEffect type="OnNotContained" target="This">
            <Remove />
          </StatusEffect>
        </Wearable>
        <!-- GreaterComponent is used for its timeframe value to keep track of progress breaking free -->
        <!-- By pressing the GUI button, the timeframe value increases and if it reaches a value of 25 or higher, the player will be freed -->
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0" />
        <CustomInterface canbeselected="false" drawhudwhenequipped="true">
          <GuiFrame style="ItemUI" absoluteoffset="0,0" anchor="BottomCenter" relativesize="0.12,0.08" />
          <Button text="interaction.struggletofree">
            <!-- Increase the timeframe value per button press and create an invisible explosion to jiggle the character a little -->
            <StatusEffect type="OnUse" target="This" timeframe="1" disabledeltatime="true">
              <Explosion range="50" force="0.2" itemdamage="0.0" structuredamage="0.0" ignorecover="true" ballastfloradamage="0.0" camerashake="1" camerashakerange="100" explosiondamage="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" playtinnitus="false" />
            </StatusEffect>
            <!-- Play a rattling sound loop if you spam the button -->
            <StatusEffect type="OnUse" target="This" duration="0.3">
              <Sound file="%ModDir%/Content/Sounds/cuffrattleloop.ogg" range="400" volume="1" frequencymultiplier="1.5" loop="true" />
            </StatusEffect>
            <!-- Apply random amounts of bluntrauma and bleeding to the hands on each button press -->
            <StatusEffect type="OnUse" target="Character" targetlimbs="LeftHand" disabledeltatime="true">
              <Affliction identifier="blunttrauma" amount="3" probability="0.1" />
              <Affliction identifier="blunttrauma" amount="2" probability="0.15" />
              <Affliction identifier="blunttrauma" amount="1" probability="0.2" />
              <Affliction identifier="bleeding" amount="1" probability="0.1" />
            </StatusEffect>
            <StatusEffect type="OnUse" target="Character" targetlimbs="RightHand" disabledeltatime="true">
              <Affliction identifier="blunttrauma" amount="3" probability="0.1" />
              <Affliction identifier="blunttrauma" amount="2" probability="0.15" />
              <Affliction identifier="blunttrauma" amount="1" probability="0.2" />
              <Affliction identifier="bleeding" amount="1" probability="0.1" />
            </StatusEffect>
            <!-- On button pressed, if the timeframe is at or above 25, remove the handcuffed affliction from the character and play an uncuffing sound -->
            <StatusEffect type="OnUse" target="This,Character" disabledeltatime="true">
              <Conditional timeframe="gte 25" />
              <ReduceAffliction identifier="handcuffed" amount="1000" />
              <Sound file="%ModDir%/Content/Sounds/uncuffing1.ogg" volume="2.5" range="350" loop="false" />
            </StatusEffect>
            <!-- On button pressed, if the timeframe is at or above 25, create a stronger invisible explosion to make the character jiggle harder, play a breaking sound, remove the handcuffs and spawn the broken version at their position -->
            <StatusEffect type="OnUse" target="This" disabledeltatime="true" forceplaysounds="true">
              <Conditional timeframe="gte 25" />
              <Sound file="Content/Sounds/Damage/HitMetal1.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal2.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal3.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal4.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal5.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Sound file="Content/Sounds/Damage/HitMetal6.ogg" volume="1.0" loop="false" range="500" selectionmode="Random" />
              <Explosion range="100" force="1.5" itemdamage="0.0" structuredamage="0.0" ignorecover="true" ballastfloradamage="0.0" camerashake="1" camerashakerange="100" explosiondamage="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" playtinnitus="false" />
              <Remove />
              <SpawnItem identifier="brokenhandcuffs" spawnposition="This" />
            </StatusEffect>
          </Button>
        </CustomInterface>
      </Item>]])
  },
  -- Replace the "handcuff set" item with the actual cuffs, this makes security spawn with the correct cuffs
  -- Also integrate the stun required patch
  ["handcuffs"] = {
    mod = "Immersive Handcuffs",
    -- Holdable component is 90% of the item, so just do a full override
    xml = XElement.Parse([[
      <Item nameidentifier="handcuffs" descriptionidentifier="handcuffs" identifier="handcuffs" category="Equipment" maxstacksize="8" cargocontaineridentifier="metalcrate" tags="smallitem" scale="0.5" impactsoundtag="impact_metal_light" requireaimtouse="false" isshootable="false" useinhealthinterface="true" hideconditionbar="true" noninteractable="false">
        <Upgrade gameversion="0.10.0.0" scale="0.5" />
        <PreferredContainer primary="armcab" secondary="secarmcab" />
        <Price baseprice="30" sold="false" canbespecial="false">
          <Price storeidentifier="merchantoutpost" minavailable="1" />
          <Price storeidentifier="merchantcity" multiplier="0.9" minavailable="2" sold="false" />
          <Price storeidentifier="merchantresearch" sold="false" />
          <Price storeidentifier="merchantmilitary" multiplier="0.9" minavailable="3" />
          <Price storeidentifier="merchantmine" sold="false" />
          <Price storeidentifier="merchantarmory" multiplier="0.9" minavailable="3" />
        </Price>
        <Deconstruct time="5" />
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" amount="2">
          <RequiredSkill identifier="weapons" level="20" />
          <RequiredItem identifier="steel" />
        </Fabricate>
        <Sprite texture="%ModDir:3321850228%/Content/Items/IH-ItemsAtlas.png" sourcerect="57,0,52,40" depth="0.6" origin="0.5,0.5" />
        <Body width="48" height="34" density="30" />
        <!-- original values for meleeweapon: aimable="true" aimpos="0,-50" aimangle="270" -->
        <Holdable characterusable="false" canBeCombined="false" slots="Any,RightHand+LeftHand" aimable="false" handle1="-7,-3" handle2="7,-3" holdpos="30,-20" holdangle="0" reload="1.0" msg="ItemMsgPickUpSelect" HitOnlyCharacters="true">
          <!-- DISABLED DUE TO ITEM NO LONGER SPAWNING IN THE INVENTORY AFTER UNCUFFING | Make the item interactable as it spawns noninteractable to simulate a cooldown to prevent instantly recuffing a person over and over again to stunlock them. Only executes once per round per handcuff to prevent any performance impact -->
          <!-- <StatusEffect type="Always" target="This" noninteractable="false" delay="5" setvalue="true" stackable="false" oneshot="true" /> -->
          <!-- When used via Health Menu on a human without the "handcuffed" affliction, apply an affliction that spawns the equipped version of the handcuffs on the character and apply the "handcuffed" affliction -->
          <StatusEffect type="OnSuccess" target="This,UseTarget" multiplyafflictionsbymaxvitality="true" comparison="And" delay="0.1" stackable="false" disabledeltatime="true">
            <Conditional handcuffed="lte 0" />
            <Conditional IsHuman="eq true" />
            <Conditional stun="gte 0.5" />
            <Affliction identifier="stun" amount="0.25" />
            <Affliction identifier="applyhandcuffs" amount="1" />
            <Affliction identifier="handcuffed" amount="100" />
          </StatusEffect>
          <!-- Play a handcuffing sound | Had to be its own effect as the sounds would otherwise refuse to play... -->
          <StatusEffect type="OnUse" target="This">
            <Sound file="%ModDir:3321850228%/Content/Sounds/cuffing1.ogg" volume="2" range="300" loop="false" selectionmode="random" />
            <Sound file="%ModDir:3321850228%/Content/Sounds/cuffing2.ogg" volume="2" range="300" loop="false" selectionmode="random" />
            <Sound file="%ModDir:3321850228%/Content/Sounds/cuffing3.ogg" volume="2" range="300" loop="false" selectionmode="random" />
          </StatusEffect>
          <!-- DISABLED FOR CONSISTENCY WITH THE HANDCUFF KEY | When used as a melee weapon on a human without the "handcuffed" affliction, apply an affliction that spawns the equipped version of the handcuffs on the character and apply the "handcuffed" affliction
          <Attack targetimpulse="2" severlimbsprobability="0.0" itemdamage="0" structuredamage="0" structuresoundtype="StructureSlash">
            <StatusEffect type="OnUse" target="UseTarget" multiplyafflictionsbymaxvitality="true" comparison="And" delay="0.1" stackable="false">
              <Conditional handcuffed="lte 0" />
              <Conditional IsHuman="eq true" />
              <Affliction identifier="applyhandcuffs" amount="1" />
              <Affliction identifier="handcuffed" amount="100" />
            </StatusEffect>
          </Attack> -->
          <!-- Remove the item when it was used on a valid target -->
          <StatusEffect type="OnUse" target="This,UseTarget" comparison="And">
            <Conditional handcuffed="lte 0" />
            <Conditional IsHuman="eq true" />
            <Conditional stun="gte 0.5" />
            <Remove />
          </StatusEffect>
        </Holdable>
      </Item>]])
  },
  -- 1. Change fabricator to weapon fabricator
  -- 2. Reduce amount fabricated to 1
  ["handcuffkey"] = {
    mod = "Immersive Handcuffs",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="5">
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="steel" />
          </Fabricate>]])
      },
    },
  },
  -- Fix: Replace "handcuffsspawned" with "handcuffs"
  ["retrievehandcuffs"] = {
    mod = "Immersive Handcuffs",
    -- Holdable component is 90% of the item, so just do a full override
    xml = XElement.Parse([[
      <Affliction name="" identifier="retrievehandcuffs" type="none" limbspecific="false" indicatorlimb="Torso" activationthreshold="0" showiconthreshold="1000" showicontoothersthreshold="1000" showinhealthscannerthreshold="1000" karmachangeonapplied="0" maxstrength="1" affectmachines="false" healableinmedicalclinic="false">
      <Effect minstrength="0" maxstrength="1" strengthchange="-1.0">
        <!-- DISABLED DUE TO ITEM DUPLICATING | Check if the character is the one uncuffing the other by checking if the character has the "handcuffed" affliction. If the affliction wasn't found, spawn the regular handcuffs item in the character's inventory -->
        <!-- <StatusEffect type="OnActive" target="Character" disabledeltatime="true" multiplyafflictionsbymaxvitality="true" stackable="false" interval="0.1">
          <Conditional handcuffed="lte 0" />
          <ReduceAffliction identifier="retrievehandcuffs" amount="1000" />
          <SpawnItem identifier="handcuffsspawned" spawnposition="ThisInventory" SpawnIfInventoryFull="true" spawnifcantbecontained="true" SpawnIfNotInInventory="true" />
        </StatusEffect> -->
        <StatusEffect type="OnActive" target="Character" triggeredEventTargetTag="released" triggeredEventEntityTag="released" eventTargetTags="released" disabledeltatime="true">
          <Conditional handcuffed="gt 0" />
          <TriggerEvent identifier="change_team_on_released" />
        </StatusEffect>
        <!-- Check if the character is the one being uncuffed by checking if the character has the "handcuffed" affliction. If the affliction was found, tag the character with the temporary tag "unlocked" and remove the "handcuffed" affliction while playing an uncuffing sound -->
        <StatusEffect type="OnActive" target="Character" tags="unlocked" duration="0.5" stackable="false" comparison="And">
          <Conditional handcuffed="gt 0" />
          <!-- Disabled sound played via affliction because the game is stupid and doesn't play these sounds for other characters in range in MP, but it works in SP... -->
          <!-- <Sound file="%ModDir:3321850228%/Content/Sounds/uncuffing1.ogg" volume="2" range="300" loop="false" selectionmode="random" /> -->
          <ReduceAffliction identifier="handcuffed" amount="1000" />
          <ReduceAffliction identifier="retrievehandcuffs" amount="1000" />
          <!-- Handcuffs need to be spawned at the position of the cuffed character as the original approach of spawning in the uncuffer's inventory allowed for duplicating -->
          <SpawnItem identifier="handcuffs" spawnposition="This" SpawnIfInventoryFull="true" spawnifcantbecontained="true" SpawnIfNotInInventory="true" />
        </StatusEffect>
        <!-- Check if the character is the one being uncuffed by checking if the character has the "handcuffed" affliction. If the affliction was found, apply 4 seconds of stun to the character, but only if the character isn't suffering from a higher stun value already -->
        <StatusEffect type="OnActive" target="Character" setvalue="true" disabledeltatime="true" multiplyafflictionsbymaxvitality="true" comparison="And">
          <Conditional handcuffed="gt 0" />
          <Conditional stun="lte 4" />
          <Affliction identifier="stun" amount="4" />
        </StatusEffect>
      </Effect>
      <icon texture="%ModDir:3321850228%/Content/UI/Icon_Handcuffed.png" sourcerect="0,0,128,128" color="150,26,26,255" origin="0,0" />
    </Affliction>]])
  },
  -- Stuff to remove
  ["securitywhistle"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["reinforcedhandcuffsspawned"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["reinforcedhandcuffsequipped"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["reinforcedhandcuffsequipped2"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["applyreinforcedhandcuffs"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  -- Script automatically removes this in favor of the traitor blindfold
  --[[["blindfold"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },]]
  ["handcuffedreinforced"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["arrestedteam1"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["arrestedteam2"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["arrestednone"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["arrestedfriendly"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["arrestedprisoner"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["sendtojail"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["sendtobrig"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["imprisonedbrig"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["imprisonedjail"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["jailtime"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["bannedtime"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["blackscreen"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["playsound_openjail"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["playsound_handcuff"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["playsound_uncuff"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["playsound_lockjail"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },
  ["blindfolded"] = {
    mod = "Immersive Handcuffs",
    xml = ""
  },

  -- ******************
  -- Enhanced Immersion
  -- ******************
  -- Change fabricator to weapon fabricator
  ["flamer"] = {
    mod = "Enhanced Immersion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" requiresrecipe="true">
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="rubber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Add NT Bio Printer tags
  ["medicalfabricator"] = {
    mod = "Enhanced Immersion",
    xml = XElement.Parse([[
      <Item name="" identifier="medicalfabricator" tags="medicalfabricator,donttakeitems,dontsellitems,stemcellprocessor,bioprinter" category="Machine" linkable="true" allowedlinks="deconstructor,medcabinet,locker,toxcontainer" scale="0.5" description="" damagedbyexplosions="true" explosiondamagemultiplier="0.2">
        <Upgrade gameversion="0.10.0.0" scale="*0.5" />
        <Upgrade gameversion="0.10.4.0">
          <Repairable Msg="ItemMsgRepairWrench" />
        </Upgrade>
        <UpgradePreviewSprite scale="2.5" texture="Content/UI/WeaponUI.png" sourcerect="256,960,64,64" origin="0.5,0.45" />
        <Sprite texture="Content/Items/Fabricators/FabricatorsAndDeconstructors.png" depth="0.8" sourcerect="0,0,336,288" origin="0.5,0.5" />
        <BrokenSprite texture="Content/Items/Fabricators/FabricatorsAndDeconstructors.png" sourcerect="336,0,336,288" origin="0.5,0.5" depth="0.8" maxcondition="80" fadein="true" />
        <BrokenSprite texture="Content/Items/Fabricators/FabricatorsAndDeconstructors.png" sourcerect="672,0,336,288" origin="0.5,0.5" depth="0.8" maxcondition="0" />
        <LightComponent range="10.0" lightcolor="255,255,255,0" powerconsumption="5" IsOn="true" castshadows="false" alphablend="false" allowingameediting="false">
          <sprite texture="Content/Items/Command/navigatorLights.png" depth="0.025" sourcerect="688,339,336,288" alpha="1.0" />
        </LightComponent>
        <Fabricator canbeselected="true" powerconsumption="500.0" msg="ItemMsgInteractSelect">
          <GuiFrame relativesize="0.4,0.45" style="ItemUI" anchor="Center" />
          <poweronsound file="Content/Items/PowerOnLight2.ogg" range="600" loop="false" />
          <StatusEffect type="OnActive" target="This">
            <sound file="Content/Items/Fabricators/Fabricator.ogg" type="OnActive" range="1000.0" volumeproperty="RelativeVoltage" loop="true" />
          </StatusEffect>
          <StatusEffect type="InWater" target="This" condition="-0.5" />
        </Fabricator>
        <ConnectionPanel selectkey="Action" canbeselected="true" hudpriority="10" msg="ItemMsgRewireScrewdriver">
          <GuiFrame relativesize="0.2,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
          <RequiredSkill identifier="electrical" level="55" />
          <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
            <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
            <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
            <Affliction identifier="stun" strength="4" />
            <Affliction identifier="burn" strength="5" />
          </StatusEffect>
          <StatusEffect type="OnPicked" target="this">
            <Sound file="%ModDir%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
          </StatusEffect>
          <RequiredItem items="screwdriver" type="Equipped" />
          <input name="power_in" displayname="connection.powerin" />
          <output name="condition_out" displayname="connection.conditionout" />
        </ConnectionPanel>
        <Repairable selectkey="Action" header="mechanicalrepairsheader" deteriorationspeed="0.50" mindeteriorationdelay="60" maxdeteriorationdelay="120" RepairThreshold="80" fixDurationHighSkill="5" fixDurationLowSkill="25" msg="ItemMsgRepairWrench" hudpriority="10">
          <GuiFrame relativesize="0.2,0.16" minsize="400,180" maxsize="480,280" anchor="Center" relativeoffset="0.0,0.27" style="ItemUI" />
          <RequiredSkill identifier="mechanical" level="55" />
          <RequiredItem items="wrench" type="equipped" />
          <ParticleEmitter particle="damagebubbles" particleburstamount="2" particleburstinterval="2.0" particlespersecond="2" scalemin="0.5" scalemax="1.5" anglemin="0" anglemax="359" velocitymin="-10" velocitymax="10" mincondition="0.0" maxcondition="50.0" />
          <ParticleEmitter particle="smoke" particleburstamount="3" particleburstinterval="0.5" particlespersecond="2" scalemin="1" scalemax="2.5" anglemin="0" anglemax="359" velocitymin="-50" velocitymax="50" mincondition="15.0" maxcondition="50.0" />
          <ParticleEmitter particle="heavysmoke" particleburstinterval="0.25" particlespersecond="2" scalemin="2.5" scalemax="5.0" mincondition="0.0" maxcondition="15.0" />
          <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
            <Sound file="Content/Items/MechanicalRepairFail.ogg" range="1000" />
            <Affliction identifier="lacerations" strength="5" />
            <Affliction identifier="stun" strength="4" />
          </StatusEffect>
        </Repairable>
        <ItemContainer capacity="5" canbeselected="true" hideitems="true" slotsperrow="5" uilabel="" allowuioverlap="true" />
        <ItemContainer capacity="1" canbeselected="true" hideitems="true" slotsperrow="1" uilabel="" allowuioverlap="true" />
      </Item>]])
  },

  -- *********************
  -- Normalized Flashlight
  -- *********************
  -- Prioritize NF's override
  ["flashlight"] = {
    mod = "Normalized Flashlight"
  },
  -- Remove this in favor of IR's industrial flashlight
  ["heavylamp"] = {
    mod = "Normalized Flashlight",
    xml = "",
  },

  -- *********************
  -- Immersive Diving Gear
  -- *********************
  -- Prioritize IDG's overrides
  ["divingsuit"] = {
    mod = "Immersive Diving Gear",
  },
  ["abyssdivingsuit"] = {
    mod = "Immersive Diving Gear",
  },
  ["combatdivingsuit"] = {
    mod = "Immersive Diving Gear",
  },
  ["respawndivingsuit"] = {
    mod = "Immersive Diving Gear",
  },
  ["slipsuit"] = {
    mod = "Immersive Diving Gear",
  },
  -- Integrate Enhanced Reactor's radiation resistance
  ["pucs"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable>
            <sprite name="pucs Torso" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="Torso" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Hand" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Hand" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Upper Arm" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightArm" depthlimb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Upper Arm" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Lower Arm" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightForearm" depthlimb="RightArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Lower Arm" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Waist" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="Waist" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Thigh" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Thigh" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Leg" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Leg" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Left Shoe" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="LeftFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="pucs Right Shoe" texture="Content/Items/Jobgear/Engineer/pucs.png" limb="RightFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
            <StatValue stattype="SwimmingSpeed" value="-0.1" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma,gunshotwound,bitewounds,lacerations,bleeding,explosiondamage" damagemultiplier="0.8" damagesound="LimbArmor" deflectprojectiles="true" />
            <damagemodifier armorsector="0.0,360.0" afflictiontypes="burn" damagemultiplier="0.1" damagesound="" deflectprojectiles="true" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="overheating" damagemultiplier="0.2" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness" damagemultiplier="0.1" damagesound="LimbArmor" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="contaminated" damagemultiplier="0.1" damagesound="LimbArmor" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="huskinfection" probabilitymultiplier="0.5" damagesound="LimbArmor" />
          </Wearable>]])
      },
    }
  },
  -- Remove fabrication recipe
  -- [Override Conflict] - with EI and Robotrauma
  ["clownexosuit"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["clowndivingsuit1"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["clowndivingsuit2"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["clowndivingsuit3"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["clowndivingsuithelmet"] = {
    mod = "Immersive Diving Gear",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },

  -- *****************
  -- Immersive Repairs
  -- *****************
  -- Prioritize IR's overrides
  ["weldingtool"] = {
    mod = "Immersive Repairs",
  },
  ["plasmacutter"] = {
    mod = "Immersive Repairs",
  },
  ["weldingstinger"] = {
    mod = "Immersive Repairs",
  },
  ["fixfoamgrenade"] = {
    mod = "Immersive Repairs",
  },
  -- Replace welder's eye with eye damage
  -- #TODO# - finicky
  ["welderseye"] = {
    mod = "Immersive Repairs",
    xml = XElement.Parse([[
      <Affliction name="Welder's Eye" description="" identifier="welderseye" limbspecific="false" indicatorlimb="Head" showiconthreshold="1000" showicontoothersthreshold="1000" showinhealthscannerthreshold="1000" maxstrength="1">
        <Effect minstrength="0" maxstrength="1">
          <!-- Replace welder's eye with eye damage -->
          <StatusEffect type="OnActive" targettype="Character" targetlimb="Head">
            <ReduceAffliction identifier="welderseye" amount="3" />
          </StatusEffect>
          <StatusEffect type="OnActive" targettype="Character" targetlimb="Head">
            <Conditional vi_human="gt 0" />
            <Affliction identifier="dm_human" amount="16" />
          </StatusEffect>
        </Effect>
        <icon texture="%ModDir%/Content/UI/IR-IconsAtlas.png" sourcerect="0,128,128,128" origin="0,0" />
      </Affliction>]])
  },
  -- Remove fabrication recipe
  ["clownweldingmask"] = {
    mod = "Immersive Repairs",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },
  -- Remove fabrication recipe
  ["safecracker"] = {
    mod = "Immersive Repairs",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },
  -- Remove
  ["welderseyedrops"] = {
    mod = "Immersive Repairs",
    xml = ""
  },
  -- Remove fabrication recipe
  ["fuelrefillstation"] = {
    mod = "Immersive Repairs",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },
  -- Remove fabrication recipe
  ["firefightercabinet"] = {
    mod = "Immersive Repairs",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },
  -- Nerf damage
  ["halligantool"] = {
    mod = "Immersive Repairs",
    componentOverrides = {
      {
        targetComponent = "meleeweapon",
        override = XElement.Parse([[
        <MeleeWeapon slots="RightHand+LeftHand,Any" controlpose="true" aimpos="45,10" handle1="-10,0" handle2="0,5" holdangle="60" reload="0.9" range="100" combatpriority="20" msg="ItemMsgPickUpSelect">
          <Attack structuredamage="8" itemdamage="16" targetimpulse="10">
            <Affliction identifier="blunttrauma" strength="10" />
            <Affliction identifier="stun" strength="0.5" />
            <StatusEffect type="OnUse" target="UseTarget">
              <Conditional entitytype="eq Character" />
              <Sound file="Content/Items/Weapons/Smack1.ogg" selectionmode="random" range="500" />
              <Sound file="Content/Items/Weapons/Smack2.ogg" range="500" />
            </StatusEffect>
          </Attack>
        </MeleeWeapon>]])
      }
    }
  },

  -- ****************
  -- Immersive Crates
  -- ****************
  -- Prioritize IC's overrides
  ["metalcrate"] = {
    mod = "Immersive Crates",
  },
  ["securemetalcrate"] = {
    mod = "Immersive Crates",
  },
  ["explosivecrate"] = {
    mod = "Immersive Crates",
  },
  ["chemicalcrate"] = {
    mod = "Immersive Crates",
  },
  -- Remove fabrication recipe (it's a variant, so just set it to a nonexistant fabricator)
  ["chemicalcratedamaged"] = {
    mod = "Immersive Crates",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate time="15" suitablefabricators="stupidfabricator"/>]])
      }
    }
  },
  ["mediccrate"] = {
    mod = "Immersive Crates",
  },
  ["sealedsupplycrate"] = {
    mod = "Immersive Crates",
  },
  ["magneticsuspensioncrate"] = {
    mod = "Immersive Crates",
  },
  -- Remove fabrication recipe
  ["clowncrate"] = {
    mod = "Immersive Crates",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },

  -- **********
  -- Real Sonar
  -- **********
  -- Integrate IDG, also change description to match new pressure protection
  ["anechoicdivingsuit"] = {
    mod = "Real Sonar",
    xml = XElement.Parse([[
      <Item name="" identifier="anechoicsuit" category="Diving,Equipment" tags="diving,deepdiving,human" scale="0.5" fireproof="true" description="" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy" botpriority="1" hideinmenus="true">
        <InventoryIcon texture="%ModDir%/Icons/anechoic_diving_suit_icon.png" sourcerect="0,0,128,128" origin="0.5,0.5" />
        <Sprite name="Diving Suit Item" texture="%ModDir%/Icons/Anechoic_DivingSuit_Items.png" sourcerect="0,0,152,122" depth="0.55" origin="0.5,0.5" />
        <Body radius="45" width="34" density="15" />
        <!-- GreaterComponent stores suit specific effects to prevent them from getting deleted if only adjusting wearable sprites in a variant item and easily target them specifically if adjustments are needed -->
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0">
          <!-- SUIT SPECIFIC EFFECTS | Copy these into your suit item and adjust the values of condition draining, low pass multipliers, speed multipliers, oxygen refilling and damage modifiers to your liking or remove/add some -->
          <!-- block hull oxygen usage -->
          <StatusEffect type="OnWearing" target="This,Character" interval="0.2" duration="0.2" OxygenAvailable="-100.0" UseHullOxygen="false" comparison="And">
            <Conditional HasStatusTag="eq sealed" />
          </StatusEffect>
          <!-- reduce walking speed -->
          <StatusEffect type="OnWearing" target="Character" SpeedMultiplier="0.6" setvalue="true" interval="0.2" duration="0.2" disabledeltatime="true" />
          <!-- make the character stumble randomly every 2.1s when running with the diving suit 
          <StatusEffect type="OnWearing" target="This,Character" interval="2.1" comparison="And" disabledeltatime="true">
            <Conditional speed="gt 2.8" />
            <Conditional InWater="false" />
            <Affliction identifier="stun" amount="1.5" probability="0.35" />
          </StatusEffect>-->
          <!-- Refill oxygen when the suit is contained. -->
          <StatusEffect type="OnContained" target="Contained" targetslot="0" Condition="1.0" interval="1" disabledeltatime="true">
            <Conditional Voltage="gt 0.01" targetcontainer="true" targetgrandparent="true" targetitemcomponent="Powered" />
            <RequiredItem items="refillableoxygensource" type="Contained" excludebroken="false" excludefullcondition="true" />
          </StatusEffect>
          <!-- supply oxygen to the character and drain the oxygen tank if the valve is closed | also works for oxygenite tanks -->
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" OxygenAvailable="1000.0" Condition="-0.3" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="oxygensource" type="Contained" />
          </StatusEffect>
          <!-- supply welding fuel to the character and drain the welding fuel tank if the valve is closed -->
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="weldingfueltank" type="Contained" />
          </StatusEffect>
          <!-- supply incendium fuel to the character and drain the incendium fuel tank if the valve is closed -->
          <StatusEffect type="OnWearing" target="Contained,Character" targetlimbs="Torso" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="incendiumfueltank" type="Contained" />
            <Affliction identifier="burn" amount="3.0" />
          </StatusEffect>
        </GreaterComponent>
        <Wearable slots="InnerClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select">
          <!-- TAGS -->
          <!-- tag the character with "hassuit" if it's a player and wearing a diving suit + diving helmet and apply the corresponding pressure protection affliction -->
          <StatusEffect type="OnWearing" target="Character" tags="hassuit" interval="0.1" duration="0.2">
            <Conditional HasStatusTag="eq hashelmet" />
            <Affliction identifier="pressure5750" amount="1" />
          </StatusEffect>
          <!-- EFFECTS FOR ALL SUITS USING THIS PRESET -->
          <!-- play a water ambient sound when moving in water -->
          <StatusEffect type="OnWearing" target="Character" comparison="And">
            <Conditional IsLocalPlayer="true" />
            <Conditional InWater="true" />
            <Sound file="%ModDir:3074045632%/Content/Items/Diving/SuitWaterAmbience.ogg" type="OnWearing" range="250" loop="true" volumeproperty="Speed" volume="0.8" frequencymultiplier="0.5" />
          </StatusEffect>
          <!-- BOT COMPATIBILITY -->
          <!-- spawn helmet and close valve -->
          <StatusEffect type="OnWearing" target="This" setvalue="true" interval="0.9" comparison="And">
            <Conditional IsBot="true" targetcontainer="true" />
            <Conditional HasStatusTag="neq hashelmet" targetcontainer="true" />
            <SpawnItem identifier="botdivingsuithelmet" spawnposition="SameInventory" spawnifinventoryfull="false" spawnifcantbecontained="false" />
          </StatusEffect>
          <!-- give pressure protection -->
          <StatusEffect type="OnWearing" target="Character" ObstructVision="true" tags="botsuit,sealed,hassuit" PressureProtection="5750.0" interval="0.1" duration="0.2" setvalue="true" disabledeltatime="true">
            <Conditional HasTag="bothelmet" targetcontaineditem="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" setvalue="true">
            <TriggerAnimation Type="Walk" FileName="HumanWalkDivingSuit" priority="1" ExpectedSpecies="Human" />
            <TriggerAnimation Type="Run" FileName="HumanRunDivingSuit" priority="1" ExpectedSpecies="Human" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" tags="sonarprotection" duration="0.1" />
          <sprite name="Anechoic Diving Suit Torso" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="Torso" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Hand" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Hand" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Lower Arm" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Lower Arm" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Upper Arm" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Upper Arm" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Waist" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="Waist" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Thigh" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Thigh" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Leg" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Leg" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Left Shoe" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="LeftFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Anechoic Diving Suit Right Shoe" texture="%ModDir%/Icons/anechoic_DivingSuit.png" limb="RightFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <damagemodifier armorsector="0.0,360.0" afflictiontypes="activesonar" damagemultiplier="0.6" damagesound="LimbArmor" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="acoustictrauma" damagemultiplier="0.15" damagesound="LimbArmor" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="vibrationdamage" damagemultiplier="0.5" damagesound="LimbArmor" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma,lacerations,bleeding" damagemultiplier="0.75" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="gunshotwound,bitewounds" damagemultiplier="0.90" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictiontypes="burn" damagemultiplier="0.90" damagesound="" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness" damagemultiplier="0.75" damagesound="LimbArmor" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="huskinfection" damagemultiplier="0.5" probabilitymultiplier="0.5" damagesound="LimbArmor" />
        </Wearable>
        <Holdable slots="RightHand,LeftHand" controlpose="true" holdpos="0,-40" handle1="-10,-20" handle2="10,-20" holdangle="0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use">
          <Upgrade gameversion="0.1401.0.0" msg="ItemMsgPickUpUse" />
        </Holdable>
        <!-- SUIT INVENTORY -->
        <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
          <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="64,448,64,64" origin="0.5,0.5" />
          <Containable items="weldingtoolfuel" excludeditems="oxygenitetank" />
          <Containable items="oxygensource" excludeditems="oxygenitetank">
            <StatusEffect type="OnWearing" target="Contained">
              <RequiredItem items="oxygensource" type="Contained" />
              <Conditional condition="lt 5.0" />
              <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
            </StatusEffect>
          </Containable>
          <Containable items="oxygenitetank">
            <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="1.3" setvalue="true" targetslot="0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
            </StatusEffect>
          </Containable>
          <StatusEffect type="OnWearing" target="Contained" playsoundonrequireditemfailure="true">
            <RequiredItem items="oxygensource,weldingtoolfuel" type="Contained" matchonempty="true" />
            <Conditional condition="lte 0.0" />
            <Sound file="Content/Items/WarningBeep.ogg" range="250" loop="true" />
          </StatusEffect>
        </ItemContainer>
        <aitarget maxsightrange="1500" />
      </Item>]])
  },
  -- Remove
  ["navremote"] = {
    mod = "Real Sonar",
    xml = ""
  },

  -- ****************
  -- Real Sonar Patch
  -- ****************
  -- Prioritize overrides
  -- Change "allblood" tag to "bloodbag" tag
  ["smartgraft"] = {
    mod = "Real Sonar Medical Item Recipes Patch for Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="25" amount="2">
            <RequiredSkill identifier="medical" level="25" />
            <RequiredItem identifier="antibleeding2" amount="2" />
            <RequiredItem tag="bloodbag" />
          </Fabricate>]])
      }
    }
  },
  ["manna"] = {
    mod = "Real Sonar Medical Item Recipes Patch for Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="25" amount="2">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredItem tag="bloodbag" amount="2" />
            <RequiredItem identifier="alienblood" amount="2" />
            <RequiredItem identifier="stabilozine" amount="1" />
            <RequiredItem identifier="pomegrenadeextract" amount="1" />
          </Fabricate>]])
      }
    }
  },
  -- Blood pack overrides are set in Neurotrauma

  -- *******************
  -- IC Mod Compat Patch
  -- *******************
  -- Prioritize overrides
  -- Remove (unused)
  ["constructionmaterialcrate"] = {
    mod = "Immersive Crates - Mod Crates Compatibility Patch",
    xml = ""
  },
  ["organcrate"] = {
    mod = "Immersive Crates - Mod Crates Compatibility Patch",
  },
  -- Remove (stupid)
  ["medstartercrate"] = {
    mod = "Immersive Crates - Mod Crates Compatibility Patch",
    xml = ""
  },
  -- Remove (unusued)
  ["fuelcrate"] = {
    mod = "Immersive Crates - Mod Crates Compatibility Patch",
    xml = ""
  },
  ["radioactivematcrate"] = {
    mod = "Immersive Crates - Mod Crates Compatibility Patch",
  },

  -- ***********************
  -- NT Cybernetics Enhanced
  -- ***********************
  -- Change fabricator to medical fabricator
  ["cyberarm"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="60">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="20" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="fpgacircuit" amount="4" />
            <RequiredItem identifier="fulgurium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["cyberleg"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="60">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="20" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="fpgacircuit" amount="4" />
            <RequiredItem identifier="fulgurium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["waterproofcyberarm"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="35" />
            <RequiredItem identifier="cyberarm" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="plastic" amount="3" />
            <RequiredItem identifier="rubber" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["waterproofcyberleg"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="35" />
            <RequiredItem identifier="cyberleg" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="plastic" amount="3" />
            <RequiredItem identifier="rubber" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabrication recipes for all augmented organs,
  -- as they were broken
  ["augmentedliver"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="60" />
            <RequiredItem identifier="livertransplant" mincondition="0.50" usecondition="false" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="fpgacircuit" amount="1" />
            <RequiredItem identifier="stabilozine" amount="1" />
          </Fabricate>]])
      },
    },
  },
  ["augmentedkidney"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="60" />
            <RequiredItem identifier="kidneytransplant" mincondition="0.30" usecondition="false" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="fpgacircuit" amount="1" />
            <RequiredItem identifier="stabilozine" amount="1" />
          </Fabricate>]])
      },
    },
  },
  ["augmentedlung"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="60" />
            <RequiredItem identifier="lungtransplant" mincondition="0.50" usecondition="false" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="fpgacircuit" amount="1" />
            <RequiredItem identifier="stabilozine" amount="1" />
          </Fabricate>]])
      },
    },
  },
  ["augmentedheart"] = {
    mod = "NT Cybernetics Enhanced",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="70" />
            <RequiredSkill identifier="medical" level="60" />
            <RequiredItem identifier="hearttransplant" mincondition="0.50" usecondition="false" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="fpgacircuit" amount="1" />
            <RequiredItem identifier="stabilozine" amount="1" />
          </Fabricate>]])
      },
    },
  },

  -- ***************
  -- NT Surgery Plus
  -- ***************
  -- Change fabricator back to medical fabricator (Surgery Plus changes it to normal fabricator for some reason)
  ["osteosynthesisimplants"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="35" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="liquidoxygenite" />
            <RequiredItem identifier="calcium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator back to medical fabricator (Surgery Plus changes it to normal fabricator for some reason)
  ["spinalimplant"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="70" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="liquidoxygenite" />
            <RequiredItem identifier="calcium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["aed"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="60" requiresrecipe="true">
            <RequiredSkill identifier="electrical" level="80" />
            <RequiredSkill identifier="medical" level="70" />
            <RequiredItem identifier="plastic" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="batterycell" />
            <RequiredItem identifier="oxygeniteshard" />
          </Fabricate>]])
      },
    },
  },
  -- Buff inventory to be the same as the combat medic uniform
  ["surgeonclothes"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "itemcontainer",
        override = XElement.Parse([[
          <ItemContainer capacity="6">
            <Containable items="smallitem" excludeditems="clothing,toolbox,mobilecontainer,rucksack,backpack,waistbelt,vest,backpack1,medicalbackpack,power-backpack,duffelbag,heavybackpack,oxy-gen. backpack,xeno-backpack,techno-backpack" />
          </ItemContainer>]])
      },
    },
  },
  -- Add rift engine fabrication recipe
  ["skillbooksurgery"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="5">
            <RequiredItem identifier="riftmat" amount="32" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["organscalpel_liver"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="35" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["organscalpel_kidneys"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="35" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["organscalpel_lungs"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="35" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["organscalpel_heart"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="35" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["organscalpel_brain"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="60" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="oxygeniteshard" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- 1. Add (tweaked) fabrication recipes from NT Bio Printer
  -- 2. Add "bio_core" and "stem_core" tag
  ["livertransplant"] = {
    mod = "NT Surgery Plus",
    xml = XElement.Parse([[
      <Item name="" identifier="livertransplant" description="" category="Medical" scale="0.4" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="organcrate" impacttolerance="5.5" Tags="smallitem,organ,petfood1,petfood2,petfood3,bio_core,stem_core">
        <Price baseprice="1000" soldbydefault="false">
          <Price storeidentifier="merchantmedical" sold="true" multiplier="0.9" minavailable="1" />
        </Price>
        <Sprite texture="%ModDir:3190189044%/Images/InGameItemIconAtlas.png" sourcerect="5,479,79,52" depth="0.6" origin="0.5,0.5" />
        <Body width="39" height="18" density="10" />
        <Fabricate suitablefabricators="bioprinter" requiredtime="60">
          <RequiredSkill identifier="medical" level="55" />
          <RequiredItem identifier="biological_material" amount="4" />
        </Fabricate>
        <Deconstruct />
        <Throwable characterusable="true" slots="Any,RightHand,LeftHand" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnImpact" target="This" Condition="0.0" setvalue="true">
            <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="fruitsplatter1" decalsize="1.0" />
            <ParticleEmitter particle="whitegoosplash" anglemin="0" anglemax="360" particleamount="2" velocitymin="0" velocitymax="0" scalemin="1.5" scalemax="2" />
            <ParticleEmitter particle="fruitchunks" anglemin="0" anglemax="360" particleamount="10" velocitymin="200" velocitymax="300" scalemin="0.4" scalemax="0.8" />
            <Remove />
          </StatusEffect>
          <!-- making the organ go kaputt if left outside of refrigeration -->
          <StatusEffect type="Always" target="This" condition="-0.5">
            <Conditional hastag="neq refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="0.1" comparison="and">
            <Conditional condition="gte 90" />
            <Conditional hastag="refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnFire" target="This" Condition="-25.0" />
          <!-- yuck! organs on the floor! -->
          <StatusEffect type="OnNotContained" target="NearbyCharacters" range="300">
            <Affliction identifier="nausea" amount="0.2" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <LuaHook name="NT.RotOrgan" />
          </StatusEffect>
        </Throwable>
        <SkillRequirementHint identifier="surgery" level="40" />
      </Item>]])
  },
  ["lungtransplant"] = {
    mod = "NT Surgery Plus",
    xml = XElement.Parse([[
      <Item name="" identifier="lungtransplant" description="" category="Medical" scale="0.4" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="organcrate" impacttolerance="5.5" Tags="smallitem,organ,petfood1,petfood2,petfood3,bio_core,stem_core">
        <Price baseprice="2000" soldbydefault="false">
          <Price locationtype="research" multiplier="1" sold="true" minavailable="2" />
        </Price>
        <Sprite texture="%ModDir:3190189044%/Images/InGameItemIconAtlas.png" sourcerect="91,480,84,84" depth="0.6" origin="0.5,0.5" />
        <Body width="30" height="30" density="10" />
        <Fabricate suitablefabricators="bioprinter" requiredtime="65">
          <RequiredSkill identifier="medical" level="60" />
          <RequiredItem identifier="biological_material" amount="4" />
        </Fabricate>
        <Deconstruct />
        <Throwable characterusable="true" slots="Any,RightHand,LeftHand" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnImpact" target="This" Condition="0.0" setvalue="true">
            <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="fruitsplatter1" decalsize="1.0" />
            <ParticleEmitter particle="whitegoosplash" anglemin="0" anglemax="360" particleamount="2" velocitymin="0" velocitymax="0" scalemin="1.5" scalemax="2" />
            <ParticleEmitter particle="fruitchunks" anglemin="0" anglemax="360" particleamount="10" velocitymin="200" velocitymax="300" scalemin="0.4" scalemax="0.8" />
            <Remove />
          </StatusEffect>
          <!-- making the organ go kaputt if left outside of refrigeration -->
          <StatusEffect type="Always" target="This" condition="-0.5">
            <Conditional hastag="neq refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="0.1" comparison="and">
            <Conditional condition="gte 90" />
            <Conditional hastag="refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnFire" target="This" Condition="-25.0" />
          <!-- yuck! organs on the floor! -->
          <StatusEffect type="OnNotContained" target="NearbyCharacters" range="300">
            <Affliction identifier="nausea" amount="0.2" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <LuaHook name="NT.RotOrgan" />
          </StatusEffect>
        </Throwable>
        <SkillRequirementHint identifier="surgery" level="40" />
      </Item>]])
  },
  ["kidneytransplant"] = {
    mod = "NT Surgery Plus",
    xml = XElement.Parse([[
      <Item name="" identifier="kidneytransplant" description="" category="Medical" scale="0.4" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="organcrate" impacttolerance="5.5" Tags="smallitem,organ,petfood1,petfood2,petfood3,bio_core,stem_core">
        <Price baseprice="400" soldbydefault="false">
          <Price storeidentifier="merchantmedical" sold="true" multiplier="0.9" minavailable="2" />
        </Price>
        <Sprite texture="%ModDir:3190189044%/Images/InGameItemIconAtlas.png" sourcerect="193,481,32,47" depth="0.6" origin="0.5,0.5" />
        <Body width="14" height="20" density="10" />
        <Fabricate suitablefabricators="bioprinter" requiredtime="50">
          <RequiredSkill identifier="medical" level="50" />
          <RequiredItem identifier="biological_material" amount="2" />
        </Fabricate>
        <Deconstruct />
        <Throwable characterusable="true" slots="Any,RightHand,LeftHand" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnImpact" target="This" Condition="0.0" setvalue="true">
            <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="fruitsplatter1" decalsize="1.0" />
            <ParticleEmitter particle="whitegoosplash" anglemin="0" anglemax="360" particleamount="2" velocitymin="0" velocitymax="0" scalemin="1.5" scalemax="2" />
            <ParticleEmitter particle="fruitchunks" anglemin="0" anglemax="360" particleamount="10" velocitymin="200" velocitymax="300" scalemin="0.4" scalemax="0.8" />
            <Remove />
          </StatusEffect>
          <!-- making the organ go kaputt if left outside of refrigeration -->
          <StatusEffect type="Always" target="This" condition="-0.5">
            <Conditional hastag="neq refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="0.1" comparison="and">
            <Conditional condition="gte 90" />
            <Conditional hastag="refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnFire" target="This" Condition="-25.0" />
          <!-- yuck! organs on the floor! -->
          <StatusEffect type="OnNotContained" target="NearbyCharacters" range="300">
            <Affliction identifier="nausea" amount="0.1" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <LuaHook name="NT.RotOrgan" />
          </StatusEffect>
        </Throwable>
        <SkillRequirementHint identifier="surgery" level="40" />
      </Item>]])
  },
  ["hearttransplant"] = {
    mod = "NT Surgery Plus",
    xml = XElement.Parse([[
      <Item name="" identifier="hearttransplant" description="" category="Medical" scale="0.4" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="organcrate" impacttolerance="5.5" Tags="smallitem,organ,petfood1,petfood2,petfood3,bio_core,stem_core">
        <Price baseprice="4000" soldbydefault="false">
          <Price locationtype="research" multiplier="1" sold="true" minavailable="2" />
        </Price>
        <Sprite texture="%ModDir:3190189044%/Images/InGameItemIconAtlas.png" sourcerect="238,479,28,54" depth="0.6" origin="0.5,0.5" />
        <Body width="14" height="22" density="10" />
        <Fabricate suitablefabricators="bioprinter" requiredtime="75">
          <RequiredSkill identifier="medical" level="70" />
          <RequiredItem identifier="biological_material" amount="5" />
        </Fabricate>
        <Deconstruct />
        <Throwable characterusable="true" slots="Any,RightHand,LeftHand" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnImpact" target="This" Condition="0.0" setvalue="true">
            <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="fruitsplatter1" decalsize="1.0" />
            <ParticleEmitter particle="whitegoosplash" anglemin="0" anglemax="360" particleamount="2" velocitymin="0" velocitymax="0" scalemin="1.5" scalemax="2" />
            <ParticleEmitter particle="fruitchunks" anglemin="0" anglemax="360" particleamount="10" velocitymin="200" velocitymax="300" scalemin="0.4" scalemax="0.8" />
            <Remove />
          </StatusEffect>
          <!-- making the organ go kaputt if left outside of refrigeration -->
          <StatusEffect type="Always" target="This" condition="-0.5">
            <Conditional hastag="neq refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="0.1" comparison="and">
            <Conditional condition="gte 90" />
            <Conditional hastag="refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnFire" target="This" Condition="-25.0" />
          <!-- yuck! organs on the floor! -->
          <StatusEffect type="OnNotContained" target="NearbyCharacters" range="300">
            <Affliction identifier="nausea" amount="0.2" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <LuaHook name="NT.RotOrgan" />
          </StatusEffect>
        </Throwable>
        <SkillRequirementHint identifier="surgery" level="40" />
      </Item>]])
  },
  -- Brain fabrication recipe is intentionally omitted
  ["braintransplant"] = {
    mod = "NT Surgery Plus",
    xml = XElement.Parse([[
      <Item name="" identifier="braintransplant" description="" category="Medical" scale="0.3" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="organcrate" impacttolerance="1.5" Tags="smallitem,organ,petfood1,petfood2,petfood3,braintransplant,bio_core,stem_core">
        <Price baseprice="0" soldbydefault="false">
          <Price storeidentifier="merchantmedical" sold="false" />
        </Price>
        <Sprite texture="%ModDir:3190189044%/Images/InGameItemIconAtlas.png" sourcerect="272,480,78,60" depth="0.6" origin="0.5,0.5" />
        <Body width="39" height="25" density="10" />
        <Deconstruct />
        <Throwable characterusable="true" slots="Any,RightHand,LeftHand" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnImpact" target="This" Condition="0.0" setvalue="true">
            <Conditional hastag="neq braincontainer" targetcontainer="true" />
            <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="fruitsplatter1" decalsize="1.0" />
            <ParticleEmitter particle="whitegoosplash" anglemin="0" anglemax="360" particleamount="2" velocitymin="0" velocitymax="0" scalemin="1.5" scalemax="2" />
            <ParticleEmitter particle="fruitchunks" anglemin="0" anglemax="360" particleamount="10" velocitymin="200" velocitymax="300" scalemin="0.4" scalemax="0.8" />
            <Remove />
          </StatusEffect>
          <!-- making the organ go kaputt if left outside of refrigeration -->
          <StatusEffect type="Always" target="This" condition="-2" comparison="and">
            <Conditional hastag="neq refrigerated" targetcontainer="true" />
            <Conditional hastag="neq braincontainer" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="-0.2" comparison="and">
            <Conditional hastag="refrigerated" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" condition="0.1" comparison="and">
            <Conditional hastag="braincontainer" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnFire" target="This" Condition="-50.0" />
          <!-- yuck! organs on the floor! -->
          <StatusEffect type="OnNotContained" target="NearbyCharacters" range="300">
            <Affliction identifier="nausea" amount="0.2" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <LuaHook name="NT.RotOrgan" />
          </StatusEffect>
        </Throwable>
        <SkillRequirementHint identifier="surgery" level="100" />
      </Item>]])
  },
  -- Since these are variants of the main organs, we must add a <Fabricate> to override the original
  -- and prevent having two identical recipes in the fabricator
  ["livertransplant_q1"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="dumbfabricator" requiredtime="75" />]])
      }
    }
  },
  ["lungtransplant_q1"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="dumbfabricator" requiredtime="75" />]])
      }
    }
  },
  ["kidneytransplant_q1"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="dumbfabricator" requiredtime="75" />]])
      }
    }
  },
  ["hearttransplant_q1"] = {
    mod = "NT Surgery Plus",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="dumbfabricator" requiredtime="75" />]])
      }
    }
  },

  -- *************
  -- NT Infections
  -- *************
  -- Remove fabrication recipe
  ["cultureanalyzingterminal"] = {
    mod = "NT Infections",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["incubatorterminal"] = {
    mod = "NT Infections",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["incubatorcrate"] = {
    mod = "NT Infections",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="20" />
            <Item identifier="steel" />
            <Item identifier="copper" />
            <Item identifier="fpgacircuit" />
          </Fabricate>]])
      },
    },
  },

  -- ***********
  -- NT Symbiote
  -- ***********
  -- Change stack size in containers to 32
  ["calyxanide"] = {
    mod = "NT Symbiote",
    xml = XElement.Parse([[
    <Calyxanide name="" identifier="calyxanide" category="Medical" maxstacksize="32" maxstacksizecharacterinventory="8" cargocontaineridentifier="mediccrate" Tags="smallitem,chem,medical,syringe" description="" useinhealthinterface="true" scale="0.5" impactsoundtag="impact_metal_light" RequireAimToUse="True">
      <Upgrade gameversion="0.10.0.0" scale="0.5" />
      <PreferredContainer secondary="wreckmedcab,abandonedmedcab" amount="1" spawnprobability="0.2" />
      <PreferredContainer secondary="outpostmedcab" amount="1" spawnprobability="0.1" />
      <PreferredContainer secondary="outpostmedcompartment" amount="1" spawnprobability="0.03" />
      <PreferredContainer primary="medcab" secondary="medcontainer" />
      <Price baseprice="510">
        <Price storeidentifier="merchantoutpost" minavailable="5" />
        <Price storeidentifier="merchantcity" minavailable="5" />
        <Price storeidentifier="merchantresearch" minavailable="7" />
        <Price storeidentifier="merchantmilitary" multiplier="1.1" minavailable="5" />
        <Price storeidentifier="merchantmine" multiplier="1.1" minavailable="5" />
        <Price storeidentifier="merchantmedical" multiplier="0.9" minavailable="7" />
        <Price storeidentifier="merchanthusk" minavailable="3" maxavailable="5">
          <Reputation faction="huskcult" min="30" />
        </Price>
      </Price>
      <Fabricate suitablefabricators="medicalfabricator" requiredtime="30">
        <RequiredSkill identifier="medical" level="22" />
        <RequiredItem identifier="huskeggs" />
        <RequiredItem identifier="antibiotics" />
        <RequiredItem identifier="stabilozine" />
      </Fabricate>
      <Deconstruct time="20">
        <Item identifier="antibiotics" />
        <Item identifier="stabilozine" />
      </Deconstruct>
      <SuitableTreatment identifier="huskinfection" suitability="100" />
      <InventoryIcon texture="Content/Items/InventoryIconAtlas.png" sourcerect="897,449,63,63" origin="0.5,0.5" />
      <Sprite texture="Content/Items/Medical/Medicines.png" sourcerect="223,69,38,70" depth="0.6" origin="0.5,0.5" />
      <Body width="35" height="65" density="10.2" waterdragcoefficient="1" />
      <MeleeWeapon canBeCombined="true" removeOnCombined="true" slots="Any,RightHand,LeftHand" aimpos="40,5" handle1="0,0" holdangle="220" reload="1.0" msg="ItemMsgPickUpSelect" HitOnlyCharacters="true">
        <RequiredSkill identifier="medical" level="38" />
        <StatusEffect type="OnSuccess" target="This" Condition="-100.0" setvalue="true" />
        <StatusEffect type="OnFailure" target="This" Condition="-100.0" setvalue="true" />
        <StatusEffect tags="medical" type="OnSuccess" target="UseTarget" duration="1">
          <Conditional huskinfection="lt 100.0" />
          <Affliction identifier="af_calyxanide" amount="100" />
        </StatusEffect>
        <StatusEffect tags="medical" type="OnFailure" target="UseTarget" duration="1">
          <Conditional huskinfection="lt 100.0" />
          <Affliction identifier="af_calyxanide" amount="100" />
        </StatusEffect>
        <!-- Injecting a still-conscious Husk will only piss it off and kill the "conscious" faster -->
        <StatusEffect tags="medical,calyxanide" type="OnSuccess" target="UseTarget" duration="10.0">
          <Conditional huskinfection="eq 100.0" />
          <Affliction identifier="organdamage" amount="3" />
        </StatusEffect>
        <StatusEffect tags="medical,calyxanide" type="OnSuccess" target="UseTarget" duration="10.0" comparison="or">
          <Conditional IsHusk="true" />
          <Affliction identifier="organdamage" amount="4" />
        </StatusEffect>
        <!-- vfx & sfx -->
        <StatusEffect type="OnSuccess" target="UseTarget">
          <Conditional entitytype="eq Character" />
          <Sound file="Content/Items/Medical/Syringe.ogg" range="500" />
        </StatusEffect>
        <StatusEffect type="OnFailure" target="UseTarget">
          <Conditional entitytype="eq Character" />
          <Sound file="Content/Items/Medical/Syringe.ogg" range="500" />
        </StatusEffect>
        <StatusEffect type="OnImpact" target="UseTarget" multiplyafflictionsbymaxvitality="true" AllowWhenBroken="true">
          <Affliction identifier="stun" amount="0.1" />
        </StatusEffect>
        <!-- Remove the item when fully used -->
        <StatusEffect type="OnBroken" target="This">
          <Remove />
        </StatusEffect>
      </MeleeWeapon>
      <Projectile characterusable="false" launchimpulse="18.0" sticktocharacters="true" launchrotation="-90" inheritstatuseffectsfrom="MeleeWeapon" inheritrequiredskillsfrom="MeleeWeapon" />
      <SkillRequirementHint identifier="medical" level="38" />
    </Calyxanide>]])
  },

  -- ***********
  -- NT lobotomy
  -- ***********
  -- Change fabricator to medical fabricator
  ["orbitoclast"] = {
    mod = "NT Lobotomy",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="15" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["surgicalhammer"] = {
    mod = "NT Lobotomy",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="15" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },

  -- *******
  -- NT Eyes
  -- *******
  -- Add "medical" tag so it can be put in medical containers
  ["it_organiclens"] = {
    mod = "NT Eyes",
    xml = XElement.Parse([[
      <Item identifier="it_organiclens" aliases="eyelens" category="Medical" maxstacksize="32" maxstacksizecharacterinventory="8" scale="0.1" useinhealthinterface="True" impactsoundtag="impact_soft" cargocontaineridentifier="mediccrate" impacttolerance="5.5" Tags="smallitem,petfood1,petfood2,petfood3,eyesurgery,surgery,surgerytool,medical">
        <PreferredContainer secondary="wreckmedcab,abandonedmedcab,piratemedcab" amount="1" spawnprobability="0.05" />
        <Sprite texture="%ModDir%/Textures/ItemIcons.png" sourcerect="256,896,128,128" depth="0.6" origin="0.5,0.5" />
        <Body width="14" height="22" density="10" />
        <Price baseprice="45" soldbydefault="false">
          <Price storeidentifier="merchantmedical" sold="true" />
        </Price>
        <Fabricate suitablefabricators="medicalfabricator" requiredtime="3">
          <RequiredSkill identifier="medical" level="40" />
          <RequiredItem identifier="carbon" />
        </Fabricate>
        <Deconstruct time="3" />
        <MeleeWeapon slots="Any,RightHand,LeftHand" aimpos="5,0" handle1="-5,0" holdangle="10" reload="1.0">
          <RequiredSkill identifier="medical" level="30" />
          <StatusEffect type="OnUse" target="This">
            <!-- add custom SFX for this <Sound file="Content/Items/Medical/Syringe.ogg" range="500" /> -->
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This">
            <Remove />
          </StatusEffect>
        </MeleeWeapon>
      </Item>]])
  },
  -- Remove fabrication recipe
  ["it_spoon"] = {
    mod = "NT Eyes",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["it_glasses"] = {
    mod = "NT Eyes",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="25">
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredSkill identifier="medical" level="40" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="steel" amount="1" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["it_lasersurgerytool"] = {
    mod = "NT Eyes",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="31">
            <RequiredSkill identifier="medical" level="80" />
            <RequiredSkill identifier="mechanical" level="45" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="incendium" />
            <RequiredItem identifier="aluminium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["it_nvg"] = {
    mod = "NT Eyes",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="fabricator" requiredtime="80">
            <RequiredSkill identifier="electrical" level="35" />
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="phosphorus" />
          </Fabricate>]])
      },
    },
  },

  -- **************
  -- NT Bio Printer
  -- **************
  -- Remove
  ["bioprinter"] = {
    mod = "NT Bio Printer",
    xml = ""
  },
  -- Remove
  ["stemcellprocessor"] = {
    mod = "NT Bio Printer",
    xml = ""
  },
  -- Name override
  ["empty_syringe_bone"] = {
    mod = "NT Bio Printer",
    xml = XElement.Parse([[
      <Item nameidentifier="mm_emptysyringe" name="" description="" identifier="empty_syringe_bone" category="Medical" maxstacksize="4" cargocontaineridentifier="mediccrate" Tags="smallitem,chem,medical,syringe" useinhealthinterface="true" scale="0.5" impactsoundtag="impact_metal_light" RequireAimToUse="True">
        <Price baseprice="40" minavailable="1">
          <Price storeidentifier="merchantresearch" />
          <Price storeidentifier="merchantmedical" multiplier="0.9" />
        </Price>
        <PreferredContainer primary="medcab" secondary="medcontainer" />
        <PreferredContainer secondary="wreckmedcab,abandonedmedcab" amount="1" spawnprobability="0.002" />
        <PreferredContainer secondary="outpostmedcab" amount="1" spawnprobability="0.001" />
        <PreferredContainer secondary="outpostmedcompartment" amount="1" spawnprobability="0.002" />
        <Fabricate suitablefabricators="medicalfabricator" requiredtime="15">
          <RequiredSkill identifier="medical" level="35" />
          <RequiredItem identifier="silicon" amount="2" />
        </Fabricate>
        <Deconstruct time="20">
          <Item identifier="silicon" />
        </Deconstruct>
        <InventoryIcon texture="%ModDir%/Xml/Items/EmptySyringe.png" sourcerect="51,6,64,64" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Xml/Items/EmptySyringe.png" sourcerect="11,-2,40,70" depth="0.6" origin="0.5,0.5" />
        <Body width="35" height="65" density="10.2" waterdragcoefficient="1" />
        <MeleeWeapon canBeCombined="true" removeOnCombined="true" slots="Any,RightHand,LeftHand" aimpos="40,5" handle1="0,0" holdangle="220" reload="1.0" msg="ItemMsgPickUpSelect" HitOnlyCharacters="true">
          <RequiredSkill identifier="medical" level="0" />
          <StatusEffect type="OnSuccess" target="UseTarget, Limb">
            <LuaHook name="empty_syringe_bone.onUse" />
          </StatusEffect>
          <StatusEffect type="OnSuccess" target="UseTarget">
            <Conditional entitytype="eq Character" />
            <Sound file="Content/Items/Medical/Syringe.ogg" range="500" />
          </StatusEffect>
          <StatusEffect type="OnImpact" target="UseTarget" multiplyafflictionsbymaxvitality="true" AllowWhenBroken="true">
            <Affliction identifier="stun" amount="0.1" />
          </StatusEffect>
        </MeleeWeapon>
        <Projectile characterusable="false" launchimpulse="18.0" sticktocharacters="true" launchrotation="-90" inheritstatuseffectsfrom="MeleeWeapon" inheritrequiredskillsfrom="MeleeWeapon" />
        <SkillRequirementHint identifier="medical" level="50" />
      </Item>]])
  },
  -- Replace o- blood pack with any blood pack
  ["stem_cells"] = {
    mod = "NT Bio Printer",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="stemcellprocessor" requiredtime="35">
            <RequiredSkill identifier="medical" level="55" />
            <RequiredItem identifier="bone_marrow" amount="2" />
            <RequiredItem tag="bloodbag" amount="2" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="stemcellprocessor" requiredtime="55">
            <RequiredSkill identifier="medical" level="55" />
            <RequiredItem identifier="bone_marrow" amount="2" />
            <RequiredItem identifier="alienblood" amount="5" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="stemcellprocessor" requiredtime="75" amount="5">
            <RequiredSkill identifier="medical" level="100" />
            <RequiredItem identifier="bone_marrow" amount="2" />
            <RequiredItem tag="stem_core" amount="1" />
          </Fabricate>]])
      }
    }
  },
  -- Prioritize limb overrides
  ["rarm"] = { mod = "NT Bio Printer", },
  ["larm"] = { mod = "NT Bio Printer", },
  ["rleg"] = { mod = "NT Bio Printer", },
  ["lleg"] = { mod = "NT Bio Printer", },
  -- Organ overrides are removed, but their fabrication recipes remain

  -- ***********
  -- Neurotrauma
  -- ***********
  -- Stop reducing husk infection
  ["afantibiotics"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="afantibiotics" description="" healableinmedicalclinic="false" targets="human" type="resistance" isbuff="true" limbspecific="false" showiconthreshold="200" showinhealthscannerthreshold="200" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="-0.5">
        <StatusEffect target="Character" comparison="and">
          <Conditional ishuman="true" />
          <Affliction identifier="organdamage" amount="0.2" />
          <Affliction identifier="kidneydamage" amount="0.175" />
          <Affliction identifier="liverdamage" amount="0.175" />
          <Affliction identifier="heartdamage" amount="0.1" />
          <Affliction identifier="lungdamage" amount="0.1" />
        </StatusEffect>
      </Effect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  -- Change fabricator to weapon fabricator
  ["divingknife"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="iron" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["bvm"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="10">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["antisepticspray"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="10">
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["autocpr"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
      <Item name="" identifier="autocpr" category="Equipment" useinhealthinterface="false" tags="smallitem,clothing,medical" scale="0.40" cargocontaineridentifier="metalcrate" description="" impactsoundtag="impact_soft">
        <Upgrade gameversion="0.9.3.0" scale="0.40" />
        <PreferredContainer primary="medcab" minamount="1" maxamount="1" spawnprobability="1" />
        <PreferredContainer primary="wreckmedcab,abandonedmedcab" minamount="1" maxamount="1" spawnprobability="0.25" />
        <Price baseprice="300" soldbydefault="false">
          <Price storeidentifier="merchantmedical" sold="true" multiplier="0.9" />
        </Price>
        <Deconstruct time="10">
          <Item identifier="steel" />
        </Deconstruct>
        <!-- TODO: remove all of this when defibs get better -->
        <Fabricate suitablefabricators="medicalfabricator" requiredtime="30">
          <RequiredSkill identifier="medical" level="40" />
          <RequiredItem identifier="plastic" mincondition="0.5" usecondition="true" />
          <RequiredItem identifier="fpgacircuit" />
          <RequiredItem identifier="steel" mincondition="0.5" usecondition="true" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/Images/InventoryItemIconAtlas.png" sourcerect="320,64,64,64" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Images/InGameItemIconAtlas.png" sourcerect="640,0,128,128" depth="0.55" origin="0.5,0.5" />
        <Body radius="45" height="50" density="40" />
        <Wearable slots="Any,OuterClothes" msg="ItemMsgPickUpSelect">
          <StatusEffect type="OnWearing" target="This" Condition="-100" disabledeltatime="true" delay="0.3" stackable="false">
            <Condition Condition="gte 99" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This" Condition="100" disabledeltatime="true" delay="3" stackable="false" />
          <StatusEffect type="OnWearing" target="Contained,Character,This" Condition="-0.2" comparison="And">
            <RequiredItem items="mobilebattery" type="Contained" />
            <Conditional IsDead="false" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character,This" comparison="Or" disabledeltatime="true">
            <RequiredItem items="mobilebattery" type="Contained" />
            <Conditional IsDead="false" />
            <Affliction identifier="cpr_buff_auto" amount="10" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character,This" comparison="And">
            <RequiredItem items="mobilebattery" type="Contained" />
            <Conditional IsDead="false" Condition="gte 99" />
            <Sound file="%ModDir%/Sound/pump.ogg" range="500" />
          </StatusEffect>
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="cpr_buff" damagemultiplier="0.0" damagesound="LimbArmor" />
          <sprite name="AutoPulse" texture="%ModDir%/Images/InGameItemIconAtlas.png" limb="Torso" scale="0.8" hidelimb="false" inherittexturescale="true" sourcerect="640,0,128,128" origin="0.5,0.6" />
        </Wearable>
        <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="battery">
          <Containable items="mobilebattery" />
        </ItemContainer>
      </Item>]])
  },
  -- Change fabricator to medical fabricator
  ["bloodcollector"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="5">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredItem identifier="plastic" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Remove fabrication recipe
  ["blahaj"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      }
    }
  },
  -- Change fabricator to fabricator / medical fabricator
  ["bodybag"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator,fabricator" requiredtime="15">
            <RequiredSkill identifier="medical" level="5" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  -- NOTE: The brain jar was removed for whatever reason
  --[=[["brainjar"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="30" requiresrecipe="true">
            <Item identifier="silicon" />
            <Item identifier="steel" />
          </Fabricate>]])
      }
    }
  },]=]
  -- Change fabricator to medical fabricator
  ["healthscanner"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="10">
            <RequiredSkill identifier="medical" level="40" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="aluminium" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["bloodanalyzer"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="medical" level="50" />
            <RequiredItem identifier="plastic" />
            <RequiredItem identifier="silicon" />
            <RequiredItem identifier="fpgacircuit" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["advhemostat"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="15" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- (The craftable verison of the surgery table) Remove fabrication recipe
  ["operatingtable"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to medical fabricator
  ["defibrillator"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="10">
            <RequiredSkill identifier="electrical" level="40" />
            <RequiredSkill identifier="medical" level="30" />
            <RequiredItem identifier="plastic" mincondition="0.5" usecondition="true" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="aluminium" mincondition="0.5" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["medtoolbox"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="20" />
            <Item identifier="steel" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["multiscalpel"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="60" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="plastic" />
            <RequiredItem identifier="zinc" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["advscalpel"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="15" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["advretractors"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="15" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["stasisbag"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="50">
            <RequiredSkill identifier="medical" level="50" />
            <RequiredItem identifier="plastic" />
            <RequiredItem identifier="stabilozine" />
            <RequiredItem identifier="mannitol" />
            <RequiredItem identifier="potassium" />
          </Fabricate>]])
      }
    }
  },
  -- Change fabricator to medical fabricator
  ["surgerytoolbox"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="20" />
            <Item identifier="steel" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["surgicaldrill"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredItem identifier="steel" mincondition="0.5" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.5" usecondition="true" />
            <RequiredItem identifier="fpgacircuit" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["surgerysaw"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredItem identifier="titaniumaluminiumalloy" mincondition="0.5" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["traumashears"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="10" />
            <RequiredSkill identifier="mechanical" level="10" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="plastic" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- Add fabrication recipe in medical fabricator
  ["tweezers"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator">
            <RequiredSkill identifier="medical" level="30" />
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredItem identifier="steel" mincondition="0.25" usecondition="true" />
            <RequiredItem identifier="zinc" mincondition="0.25" usecondition="true" />
          </Fabricate>]])
      }
    }
  },
  -- 1. Change fabricator to medical fabricator
  -- 2. Fix broken sprite
  ["wheelchair"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="medicalfabricator" requiredtime="20">
            <RequiredSkill identifier="medical" level="20" />
            <RequiredSkill identifier="mechanical" level="30" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
          </Fabricate>]])
      },
      {
        targetComponent = "sprite",
        override = XElement.Parse([[
          <Sprite texture="%ModDir%/Images/InGameItemIconAtlas.png" sourcerect="0,780,256,243" depth="0.55" origin="0.5,0.5" />]])
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable slots="Any,OuterClothes" msg="ItemMsgEquipSelect" autoequipwhenfull="true">
            <sprite texture="%ModDir%/Images/InGameItemIconAtlas.png" limb="Waist" hidelimb="false" inherittexturescale="true" hideotherwearables="false" inheritorigin="false" sourcerect="0,780,256,243" inheritlimbdepth="false" depth="0.10003" />
            <!-- depth="0.11504" -->
          </Wearable>]])
      },
    }
  },
  -- 3x healing rate
  ["suturedw"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
      <Affliction name="" identifier="suturedw" description="" healableinmedicalclinic="false" limbspecific="true" maxstrength="100" showinhealthscannerthreshold="700" showiconthreshold="0.1" type="damage" isbuff="false" iconcolors="127,127,127,255;127,127,127,255">
        <Effect minstrength="0" maxstrength="100" strengthchange="-0.6" multiplybymaxvitality="true" minvitalitydecrease="0" maxvitalitydecrease="0.8" />
        <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="5,3" sheetelementsize="128,128" origin="0,0" />
      </Affliction>]])
  },
  -- Add rift engine fabrication recipe
  ["opium"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- Add rift engine fabrication recipe
  ["adrenaline"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" />
          </Fabricate>]])
      }
    }
  },
  -- Add rift engine fabrication recipe
  ["antibiotics"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="2" />
          </Fabricate>]])
      }
    }
  },
  -- 1. Add rift engine fabrication recipe
  -- 2. Integrate Extract It
  ["alienblood"] = {
    mod = "Neurotrauma",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="5" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Deconstruct time="5" chooserandom="true" requireddeconstructor="geneticresearchstation" amount="1">
            <Item identifier="geneticmaterial_unresearched" commonness="0.45" requiredotheritem="stabilozine" activatebuttontext="researchstation.research" infotext="researchstation.research.infotext" infotextonotheritemmissing="researchstation.combine.missingitem" />
            <Item identifier="alienblood" outcondition="0.0" commonness="0.55" requiredotheritem="stabilozine" activatebuttontext="researchstation.research" infotext="researchstation.research.infotext" infotextonotheritemmissing="researchstation.combine.missingitem" />
          </Deconstruct>]])
      }
    }
  },
  -- Prevent arterial cuts from causing bloodloss if you're in stasis
  ["ll_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="ll_arterialcut" description="" healableinmedicalclinic="true" basehealcost="210" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="LeftLeg" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="1">
        <StatusEffect target="Character" targetlimb="LeftLeg" comparison="and">
          <Conditional arteriesclamp="lte 1" />
          <Conditional stasis="lte 1" />
          <Conditional bloodloss="lte 99.5" />
          <ParticleEmitter particle="bloodsplash" particlespersecond="50" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <ParticleEmitter particle="waterblood" particlespersecond="20" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <Affliction identifier="bloodloss" strength="1.5" />
        </StatusEffect>
        <StatusEffect target="Character" conditional="or">
          <Conditional ishuman="False" />
          <ReduceAffliction identifier="arterialcut" amount="999" />
        </StatusEffect>
      </Effect>
      <PeriodicEffect mininterval="6" maxinterval="6">
        <StatusEffect target="Character" targetlimb="LeftLeg" comparison="and">
          <Conditional arteriesclamp="eq 0" />
          <Conditional stasis="lte 1" />
          <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="blood" decalsize="0.85" shockwave="false" underwaterbubble="false" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  ["rl_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="rl_arterialcut" description="" healableinmedicalclinic="true" basehealcost="210" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="RightLeg" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="1">
        <StatusEffect target="Character" multiplyafflictionsbymaxvitality="true" targetlimb="RightLeg" comparison="and">
          <Conditional arteriesclamp="lte 1" />
          <Conditional stasis="lte 1" />
          <Conditional bloodloss="lte 99.5" />
          <ParticleEmitter particle="bloodsplash" particlespersecond="50" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <ParticleEmitter particle="waterblood" particlespersecond="20" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <Affliction identifier="bloodloss" strength="1.5" />
        </StatusEffect>
        <StatusEffect target="Character" conditional="or">
          <Conditional ishuman="False" />
          <ReduceAffliction identifier="arterialcut" amount="999" />
        </StatusEffect>
      </Effect>
      <PeriodicEffect mininterval="6" maxinterval="6">
        <StatusEffect target="Character" targetlimb="RightLeg" comparison="and">
          <Conditional arteriesclamp="eq 0" />
          <Conditional stasis="lte 1" />
          <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="blood" decalsize="0.85" shockwave="false" underwaterbubble="false" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  ["la_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="la_arterialcut" description="" healableinmedicalclinic="true" basehealcost="210" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="LeftArm" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="1">
        <StatusEffect target="Character" targetlimb="LeftArm" comparison="and">
          <Conditional arteriesclamp="lte 1" />
          <Conditional stasis="lte 1" />
          <Conditional bloodloss="lte 99.5" />
          <ParticleEmitter particle="bloodsplash" particlespersecond="50" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <ParticleEmitter particle="waterblood" particlespersecond="20" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <Affliction identifier="bloodloss" strength="1.5" />
        </StatusEffect>
        <StatusEffect target="Character" conditional="or">
          <Conditional ishuman="False" />
          <ReduceAffliction identifier="arterialcut" amount="999" />
        </StatusEffect>
      </Effect>
      <PeriodicEffect mininterval="6" maxinterval="6">
        <StatusEffect target="Character" targetlimb="LeftArm" comparison="and">
          <Conditional arteriesclamp="eq 0" />
          <Conditional stasis="lte 1" />
          <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="blood" decalsize="0.85" shockwave="false" underwaterbubble="false" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  ["ra_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="ra_arterialcut" description="" healableinmedicalclinic="true" basehealcost="210" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="RightArm" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="1">
        <StatusEffect target="Character" targetlimb="RightArm" comparison="and">
          <Conditional arteriesclamp="lte 1" />
          <Conditional stasis="lte 1" />
          <Conditional bloodloss="lte 99.5" />
          <ParticleEmitter particle="bloodsplash" particlespersecond="50" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <ParticleEmitter particle="waterblood" particlespersecond="20" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <Affliction identifier="bloodloss" strength="1.5" />
        </StatusEffect>
        <StatusEffect target="Character" conditional="or">
          <Conditional ishuman="False" />
          <ReduceAffliction identifier="arterialcut" amount="999" />
        </StatusEffect>
      </Effect>
      <PeriodicEffect mininterval="6" maxinterval="6">
        <StatusEffect target="Character" targetlimb="RightArm" comparison="and">
          <Conditional arteriesclamp="eq 0" />
          <Conditional stasis="lte 1" />
          <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="blood" decalsize="0.85" shockwave="false" underwaterbubble="false" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  ["t_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="t_arterialcut" description="" healableinmedicalclinic="false" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="Torso" showiconthreshold="200" showinhealthscannerthreshold="1" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="1" />
      <PeriodicEffect mininterval="1" maxinterval="3">
        <StatusEffect target="Character" disabledeltatime="true" stackable="false" delay="1" checkconditionalalways="false">
          <Conditional ishuman="false" />
          <ReduceAffliction identifier="t_arterialcut" amount="1000" />
        </StatusEffect>
        <StatusEffect target="Character" multiplyafflictionsbymaxvitality="true" disabledeltatime="true" stackable="false" delay="1" checkconditionalalways="false">
          <Conditional balloonedaorta="lte 1" />
          <Conditional stasis="lte 1" />
          <Affliction identifier="internalbleeding" strength="8" />
          <Affliction identifier="bloodloss" strength="4" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  ["h_arterialcut"] = {
    mod = "Neurotrauma",
    xml = XElement.Parse([[
    <Affliction name="" identifier="h_arterialcut" description="" healableinmedicalclinic="false" targets="human" type="arterialcut" limbspecific="false" indicatorlimb="Head" maxstrength="100">
      <Effect minstrength="0" maxstrength="100" strengthchange="100">
        <StatusEffect target="Character" multiplyafflictionsbymaxvitality="true" targetlimb="Head" comparison="and">
          <Conditional bloodloss="lte 99.5" />
          <Conditional stasis="lte 1" />
          <ParticleEmitter particle="bloodsplash" particlespersecond="50" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <ParticleEmitter particle="waterblood" particlespersecond="20" scalemin="0.5" scalemax="0.45" velocitymin="0" velocitymax="40" anglemin="0" anglemax="360" />
          <Affliction identifier="bloodloss" strength="1.5" />
        </StatusEffect>
        <StatusEffect target="Character" conditional="or">
          <Conditional ishuman="False" />
          <ReduceAffliction identifier="arterialcut" amount="999" />
        </StatusEffect>
      </Effect>
      <PeriodicEffect mininterval="6" maxinterval="6">
        <StatusEffect target="Character" targetlimb="Head" comparison="and">
          <Conditional stasis="lte 1" />
          <Explosion range="0.0" structuredamage="0" itemdamage="0" force="0.0" severlimbsprobability="0.0" decal="blood" decalsize="0.85" shockwave="false" underwaterbubble="false" />
        </StatusEffect>
      </PeriodicEffect>
      <icon texture="%ModDir%/Images/AfflictionIcons.png" sheetindex="3,3" sheetelementsize="128,128" origin="0,0" />
    </Affliction>]])
  },
  -- Prioritize blood bags
  ["antibloodloss2"] = { mod = "Neurotrauma"},
  ["bloodpackoplus"] = { mod = "Neurotrauma"},
  ["bloodpackaminus"] = { mod = "Neurotrauma"},
  ["bloodpackaplus"] = { mod = "Neurotrauma"},
  ["bloodpackbminus"] = { mod = "Neurotrauma"},
  ["bloodpackbplus"] = { mod = "Neurotrauma"},
  ["bloodpackabminus"] = { mod = "Neurotrauma"},
  ["bloodpackabplus"] = { mod = "Neurotrauma"},

  -- ***********
  -- Rift Engine
  -- ***********
  -- Remove fabrication recipe
  ["riftengine"] = {
    mod = "Rift Engine",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["riftengine2"] = {
    mod = "Rift Engine",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove all capsules, as vanilla materials are overriden
  ["re_sulphuricacid"] = { mod = "Rift Engine", xml = "" },
  ["re_ethanol"] = { mod = "Rift Engine", xml = "" },
  ["re_opium"] = { mod = "Rift Engine", xml = "" },
  ["re_elastin"] = { mod = "Rift Engine", xml = "" },
  ["re_adrenaline"] = { mod = "Rift Engine", xml = "" },
  ["re_alienblood"] = { mod = "Rift Engine", xml = "" },
  ["re_antibiotics"] = { mod = "Rift Engine", xml = "" },
  ["re_stabilozine"] = { mod = "Rift Engine", xml = "" },
  ["re_huskeggsbasic"] = { mod = "Rift Engine", xml = "" },
  ["re_carbon"] = { mod = "Rift Engine", xml = "" },
  ["re_iron"] = { mod = "Rift Engine", xml = "" },
  ["re_tin"] = { mod = "Rift Engine", xml = "" },
  ["re_lead"] = { mod = "Rift Engine", xml = "" },
  ["re_phosphorus"] = { mod = "Rift Engine", xml = "" },
  ["re_copper"] = { mod = "Rift Engine", xml = "" },
  ["re_zinc"] = { mod = "Rift Engine", xml = "" },
  ["re_sodium"] = { mod = "Rift Engine", xml = "" },
  ["re_silicon"] = { mod = "Rift Engine", xml = "" },
  ["re_calcium"] = { mod = "Rift Engine", xml = "" },
  ["re_aluminium"] = { mod = "Rift Engine", xml = "" },
  ["re_uranium"] = { mod = "Rift Engine", xml = "" },
  ["re_potassium"] = { mod = "Rift Engine", xml = "" },
  ["re_titanium"] = { mod = "Rift Engine", xml = "" },
  ["re_magnesium"] = { mod = "Rift Engine", xml = "" },
  ["re_lithium"] = { mod = "Rift Engine", xml = "" },
  ["re_chlorine"] = { mod = "Rift Engine", xml = "" },
  ["re_thorium"] = { mod = "Rift Engine", xml = "" },
  ["re_organicfiber"] = { mod = "Rift Engine", xml = "" },
  ["re_rubber"] = { mod = "Rift Engine", xml = "" },
  ["re_depletedfuel"] = { mod = "Rift Engine", xml = "" },
  ["re_nitroglycerin"] = { mod = "Rift Engine", xml = "" },
  ["re_titanite"] = { mod = "Rift Engine", xml = "" },
  ["re_brockite"] = { mod = "Rift Engine", xml = "" },
  ["re_thorianite"] = { mod = "Rift Engine", xml = "" },
  ["re_amblygonite"] = { mod = "Rift Engine", xml = "" },
  ["re_sphalerite"] = { mod = "Rift Engine", xml = "" },
  ["re_pyromorphite"] = { mod = "Rift Engine", xml = "" },
  ["re_quartz"] = { mod = "Rift Engine", xml = "" },
  ["re_diamond"] = { mod = "Rift Engine", xml = "" },
  ["re_hydroxyapatite"] = { mod = "Rift Engine", xml = "" },
  ["re_uraniumore"] = { mod = "Rift Engine", xml = "" },
  ["re_ilmenite"] = { mod = "Rift Engine", xml = "" },
  ["re_stannite"] = { mod = "Rift Engine", xml = "" },
  ["re_chalcopyrite"] = { mod = "Rift Engine", xml = "" },
  ["re_esperite"] = { mod = "Rift Engine", xml = "" },
  ["re_galena"] = { mod = "Rift Engine", xml = "" },
  ["re_triphylite"] = { mod = "Rift Engine", xml = "" },
  ["re_langbeinite"] = { mod = "Rift Engine", xml = "" },
  ["re_chamosite"] = { mod = "Rift Engine", xml = "" },
  ["re_ironore"] = { mod = "Rift Engine", xml = "" },
  ["re_polyhalite"] = { mod = "Rift Engine", xml = "" },
  ["re_graphite"] = { mod = "Rift Engine", xml = "" },
  ["re_sylvite"] = { mod = "Rift Engine", xml = "" },
  ["re_lazulite"] = { mod = "Rift Engine", xml = "" },
  ["re_bornite"] = { mod = "Rift Engine", xml = "" },
  ["re_cassiterite"] = { mod = "Rift Engine", xml = "" },
  ["re_cryolite"] = { mod = "Rift Engine", xml = "" },
  ["re_aragonite"] = { mod = "Rift Engine", xml = "" },
  ["re_chrysoprase"] = { mod = "Rift Engine", xml = "" },
  ["re_fiberplant"] = { mod = "Rift Engine", xml = "" },
  ["re_elastinplant"] = { mod = "Rift Engine", xml = "" },
  ["re_aquaticpoppy"] = { mod = "Rift Engine", xml = "" },
  ["re_yeastshroom"] = { mod = "Rift Engine", xml = "" },
  ["re_slimebacteria"] = { mod = "Rift Engine", xml = "" },
  ["re_creepingorangevineseed"] = { mod = "Rift Engine", xml = "" },
  ["re_tobaccovineseed"] = { mod = "Rift Engine", xml = "" },
  ["re_saltvineseed"] = { mod = "Rift Engine", xml = "" },
  ["re_raptorbaneseed"] = { mod = "Rift Engine", xml = "" },
  ["re_paralyxis"] = { mod = "Rift Engine", xml = "" },
  ["re_incendium"] = { mod = "Rift Engine", xml = "" },
  ["re_fulgurium"] = { mod = "Rift Engine", xml = "" },
  ["re_physicorium"] = { mod = "Rift Engine", xml = "" },
  ["re_dementonite"] = { mod = "Rift Engine", xml = "" },
  ["re_oxygeniteshard"] = { mod = "Rift Engine", xml = "" },
  ["re_sulphuriteshard"] = { mod = "Rift Engine", xml = "" },
  ["re_skillbookhandyseaman"] = { mod = "Rift Engine", xml = "" },
  ["re_skillbooksubmarinewarfare"] = { mod = "Rift Engine", xml = "" },
  ["re_skillbookeuropanmedicine"] = { mod = "Rift Engine", xml = "" },

  -- *****************
  -- Enhanced Reactors
  -- *****************
  -- Prioritize ER's overrides; integrate EI's sfx
  -- Enhanced Reactors already integrates Immersive Repairs' fixfoam
  -- Enhanced Immersion also overrides the sprayer, but its changes are minimal
  ["sprayer"] = {
    mod = "Enhanced Reactors",
  },
  ["ekdockyard_reactor_mini"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "connectionpanel",
        override = XElement.Parse([[
          <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
            <GuiFrame relativesize="0.3,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
            <RequiredSkill identifier="electrical" level="55" />
            <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
              <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
              <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
              <Affliction identifier="stun" strength="4" />
              <Affliction identifier="burn" strength="5" />
            </StatusEffect>
            <!-- Enhanced Immersion's OnPicked SFX -->
            <StatusEffect type="OnPicked" target="this">
              <Sound file="%ModDir:2968896556%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
            </StatusEffect>
            <RequiredItem items="screwdriver" type="Equipped" />
            <output name="power_out" displayname="connection.powerout" maxwires="1" />
            <output name="temperature_out" displayname="connection.temperatureout" />
            <input name="shutdown" displayname="connection.shutdown" />
            <output name="meltdown_warning" displayname="connection.meltdownwarning" />
            <input name="set_fissionrate" displayname="connection.setfissionrate" />
            <input name="set_turbineoutput" displayname="connection.setturbineoutput" />
            <output name="power_value_out" displayname="connection.powervalueout" />
            <output name="load_value_out" displayname="connection.loadvalueout" />
            <output name="fuel_out" displayname="connection.availablefuelout" />
            <output name="condition_out" displayname="connection.conditionout" />
            <output name="fuel_percentage_left" displayname="connection.fuelpercentageout" />
            <!-- Additional Input: Turn On -->
            <input name="poweron" displayname="connection.activate">
              <StatusEffect type="OnUse" target="This" poweron="true" setvalue="true" />
            </input>
            <!-- Additional Input: Activate Automatic Control -->
            <input name="autotemp" displayname="pumpautocontrol">
              <StatusEffect type="OnUse" target="This" autotemp="true" setvalue="true" />
            </input>
          </ConnectionPanel>]])
      }
    }
  },
  ["ekdockyard_reactor_small"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "connectionpanel",
        override = XElement.Parse([[
          <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
            <GuiFrame relativesize="0.3,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
            <RequiredSkill identifier="electrical" level="55" />
            <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
              <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
              <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
              <Affliction identifier="stun" strength="4" />
              <Affliction identifier="burn" strength="5" />
            </StatusEffect>
            <!-- Enhanced Immersion's OnPicked SFX -->
            <StatusEffect type="OnPicked" target="this">
              <Sound file="%ModDir:2968896556%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
            </StatusEffect>
            <RequiredItem items="screwdriver" type="Equipped" />
            <output name="power_out" displayname="connection.powerout" maxwires="1" />
            <output name="temperature_out" displayname="connection.temperatureout" />
            <input name="shutdown" displayname="connection.shutdown" />
            <output name="meltdown_warning" displayname="connection.meltdownwarning" />
            <input name="set_fissionrate" displayname="connection.setfissionrate" />
            <input name="set_turbineoutput" displayname="connection.setturbineoutput" />
            <output name="power_value_out" displayname="connection.powervalueout" />
            <output name="load_value_out" displayname="connection.loadvalueout" />
            <output name="fuel_out" displayname="connection.availablefuelout" />
            <output name="condition_out" displayname="connection.conditionout" />
            <output name="fuel_percentage_left" displayname="connection.fuelpercentageout" />
            <!-- Additional Input: Turn On -->
            <input name="poweron" displayname="connection.activate">
              <StatusEffect type="OnUse" target="This" poweron="true" setvalue="true" />
            </input>
            <!-- Additional Input: Activate Automatic Control -->
            <input name="autotemp" displayname="pumpautocontrol">
              <StatusEffect type="OnUse" target="This" autotemp="true" setvalue="true" />
            </input>
          </ConnectionPanel>]])
      }
    }
  },
  ["ekdockyard_reactorslow_small"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "connectionpanel",
        override = XElement.Parse([[
          <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
            <GuiFrame relativesize="0.3,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
            <RequiredSkill identifier="electrical" level="55" />
            <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
              <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
              <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
              <Affliction identifier="stun" strength="4" />
              <Affliction identifier="burn" strength="5" />
            </StatusEffect>
            <!-- Enhanced Immersion's OnPicked SFX -->
            <StatusEffect type="OnPicked" target="this">
              <Sound file="%ModDir:2968896556%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
            </StatusEffect>
            <RequiredItem items="screwdriver" type="Equipped" />
            <output name="power_out" displayname="connection.powerout" maxwires="1" />
            <output name="temperature_out" displayname="connection.temperatureout" />
            <input name="shutdown" displayname="connection.shutdown" />
            <output name="meltdown_warning" displayname="connection.meltdownwarning" />
            <input name="set_fissionrate" displayname="connection.setfissionrate" />
            <input name="set_turbineoutput" displayname="connection.setturbineoutput" />
            <output name="power_value_out" displayname="connection.powervalueout" />
            <output name="load_value_out" displayname="connection.loadvalueout" />
            <output name="fuel_out" displayname="connection.availablefuelout" />
            <output name="condition_out" displayname="connection.conditionout" />
            <output name="fuel_percentage_left" displayname="connection.fuelpercentageout" />
            <!-- Additional Input: Turn On -->
            <input name="poweron" displayname="connection.activate">
              <StatusEffect type="OnUse" target="This" poweron="true" setvalue="true" />
            </input>
            <!-- Additional Input: Activate Automatic Control -->
            <input name="autotemp" displayname="pumpautocontrol">
              <StatusEffect type="OnUse" target="This" autotemp="true" setvalue="true" />
            </input>
          </ConnectionPanel>]])
      }
    }
  },
  ["reactor1wrecked"] = {
    mod = "Enhanced Reactors",
  },
  ["reactor1"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "connectionpanel",
        override = XElement.Parse([[
          <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
            <GuiFrame relativesize="0.3,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
            <RequiredSkill identifier="electrical" level="55" />
            <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
              <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
              <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
              <Affliction identifier="stun" strength="4" />
              <Affliction identifier="burn" strength="5" />
            </StatusEffect>
            <!-- Enhanced Immersion's OnPicked SFX -->
            <StatusEffect type="OnPicked" target="this">
              <Sound file="%ModDir:2968896556%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
            </StatusEffect>
            <RequiredItem items="screwdriver" type="Equipped" />
            <output name="power_out" displayname="connection.powerout" maxwires="1" />
            <output name="temperature_out" displayname="connection.temperatureout" />
            <input name="shutdown" displayname="connection.shutdown" />
            <output name="meltdown_warning" displayname="connection.meltdownwarning" />
            <input name="set_fissionrate" displayname="connection.setfissionrate" />
            <input name="set_turbineoutput" displayname="connection.setturbineoutput" />
            <output name="power_value_out" displayname="connection.powervalueout" />
            <output name="load_value_out" displayname="connection.loadvalueout" />
            <output name="fuel_out" displayname="connection.availablefuelout" />
            <output name="condition_out" displayname="connection.conditionout" />
            <output name="fuel_percentage_left" displayname="connection.fuelpercentageout" />
            <!-- Additional Input: Turn On -->
            <input name="poweron" displayname="connection.activate">
              <StatusEffect type="OnUse" target="This" poweron="true" setvalue="true" />
            </input>
            <!-- Additional Input: Activate Automatic Control -->
            <input name="autotemp" displayname="pumpautocontrol">
              <StatusEffect type="OnUse" target="This" autotemp="true" setvalue="true" />
            </input>
          </ConnectionPanel>]])
      }
    }
  },
  ["outpostreactor"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "connectionpanel",
        override = XElement.Parse([[
          <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
            <GuiFrame relativesize="0.3,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
            <RequiredSkill identifier="electrical" level="55" />
            <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand" AllowWhenBroken="true">
              <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
              <Explosion range="100.0" force="1.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
              <Affliction identifier="stun" strength="4" />
              <Affliction identifier="burn" strength="5" />
            </StatusEffect>
            <!-- Enhanced Immersion's OnPicked SFX -->
            <StatusEffect type="OnPicked" target="this">
              <Sound file="%ModDir:2968896556%/Content/Items/Electricity/junctionbox_interact.ogg" volume="1" range="300" />
            </StatusEffect>
            <RequiredItem items="screwdriver" type="Equipped" />
            <output name="power_out" displayname="connection.powerout" maxwires="1" />
            <output name="temperature_out" displayname="connection.temperatureout" />
            <input name="shutdown" displayname="connection.shutdown" />
            <output name="meltdown_warning" displayname="connection.meltdownwarning" />
            <input name="set_fissionrate" displayname="connection.setfissionrate" />
            <input name="set_turbineoutput" displayname="connection.setturbineoutput" />
            <output name="power_value_out" displayname="connection.powervalueout" />
            <output name="load_value_out" displayname="connection.loadvalueout" />
            <output name="fuel_out" displayname="connection.availablefuelout" />
            <output name="condition_out" displayname="connection.conditionout" />
            <output name="fuel_percentage_left" displayname="connection.fuelpercentageout" />
            <!-- Additional Input: Turn On -->
            <input name="poweron" displayname="connection.activate">
              <StatusEffect type="OnUse" target="This" poweron="true" setvalue="true" />
            </input>
            <!-- Additional Input: Activate Automatic Control -->
            <input name="autotemp" displayname="pumpautocontrol">
              <StatusEffect type="OnUse" target="This" autotemp="true" setvalue="true" />
            </input>
          </ConnectionPanel>]])
      }
    }
  },
  ["fuelrod"] = {
    mod = "Enhanced Reactors",
  },
  -- Change fabricator to normal fabricator
  ["deconsoltank"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
        <Fabricate suitablefabricators="fabricator" requiredtime="15">
          <RequiredSkill identifier="mechanical" level="20" />
          <RequiredSkill identifier="electrical" level="20" />
          <RequiredItem identifier="aluminium" amount="2" />
          <RequiredItem identifier="ethanol" amount="1" />
          <RequiredItem identifier="stabilozine" amount="1" />
          <RequiredItem identifier="potassium" amount="1" />
          <RequiredItem identifier="sodium" amount="1" />
        </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
        <Fabricate suitablefabricators="fabricator" displayname="recycleitem" requiredtime="8">
          <RequiredSkill identifier="mechanical" level="20" />
          <RequiredSkill identifier="electrical" level="20" />
          <RequiredItem identifier="deconsoltank" mincondition="0.0" maxcondition="0.1" usecondition="false" />
          <RequiredItem identifier="ethanol" amount="1" />
          <RequiredItem identifier="stabilozine" amount="1" />
          <RequiredItem identifier="potassium" amount="1" />
          <RequiredItem identifier="sodium" amount="1" />
        </Fabricate>]])
      }
    }
  },
  -- Remove fabrication recipe / pick-up-able-ness
  ["deconshower"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        targetComponent = "holdable",
        override = ""
      }
    }
  },
  -- Remove fabrication recipe / pick-up-able-ness
  ["fuelrodcrateshelf"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        targetComponent = "holdable",
        override = ""
      }
    }
  },
  -- Change fabricator to weapon fabricator
  ["nuclearcartridge"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      -- Remove original recipes
      {
        targetComponent = "fabricate",
        override = ""
      },
      -- Add override recipes
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" displayname="uraniumbased" requiresrecipe="false">
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="uraniumfuelrod_er" mincondition="0.90" usecondition="true" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" displayname="thoriumbased" requiresrecipe="true">
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="thoriumfuelrod_er" mincondition="0.5" usecondition="true" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" displayname="fulguriumbased" requiresrecipe="true">
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="fulguriumfuelrod_er" mincondition="0.3" usecondition="true" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" displayname="volatilefulguriumbased" requiresrecipe="true">
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="fulguriumfuelrodvolatile_er" mincondition="0.15" usecondition="true" />
          </Fabricate>]])
      },
    }
  },
  -- [OVERRIDE CONFLICT] - with EHA and ER
  -- 1. Change fabricator to weapon fabricator
  -- 2. Change ammo to nuclear cartridges
  ["nucleargun"] = {
    mod = "Enhanced Reactors",
    xml = XElement.Parse([[
      <Item name="" identifier="nucleargun" category="Weapon" cargocontaineridentifier="metalcrate" allowasextracargo="true" tags="mediumitem,weapon,gun,mountableweapon" Scale="0.5" impactsoundtag="impact_metal_heavy">
        <PreferredContainer primary="secarmcab" secondary="weaponholder,armcab" />
        <Price baseprice="1250" sold="false" />
        <Deconstruct time="10">
          <Item identifier="copper" />
          <Item identifier="plastic" />
          <Item identifier="lead" />
          <Item identifier="dementonite" />
          <Item identifier="fulgurium" />
        </Deconstruct>
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="70" requiresrecipe="true">
          <RequiredSkill identifier="electrical" level="65" />
          <RequiredItem identifier="fpgacircuit" amount="3" />
          <RequiredItem identifier="lead" amount="2" />
          <RequiredItem identifier="dementonite" amount="2" />
          <RequiredItem identifier="fulgurium" amount="2" />
        </Fabricate>
        <Sprite texture="%ModDir:2764968387%/Weapons/vanillaweaponchanges.png" sourcerect="0,548,293,63" depth="0.55" origin="0.5,0.5" />
        <InventoryIcon texture="%ModDir:2764968387%/Weapons/vanillaweaponchanges.png" sourcerect="282,157,65,74" depth="0.55" origin="0.5,0.5" />
        <Body width="238" height="63" density="25" />
        <Holdable slots="RightHand+LeftHand" controlpose="true" holdpos="60,-15" aimpos="74,4" handle1="-53,-10" handle2="10,-3" holdangle="-25" />
        <Wearable slots="Bag" msg="ItemMsgEquipSelect" canbeselected="false" canbepicked="true" pickkey="Select">
          <sprite name="Nuclear Gun Worn" texture="%ModDir:2764968387%/Weapons/vanillaweaponchanges.png" canbehiddenbyotherwearables="false" rotation="90" depth="0.6" sourcerect="0,548,293,63" limb="Torso" depthlimb="LeftArm" scale="0.5" origin="0.5,0.8" />
        </Wearable>
        <RangedWeapon reload="0.5" reloadnoskill="1.5" holdtrigger="true" barrelpos="125,16" spread="0" unskilledspread="10" combatPriority="80" drawhudwhenequipped="true" crosshairscale="0.2" maxchargetime="0.75">
          <Crosshair texture="Content/Items/Weapons/Crosshairs.png" sourcerect="0,256,256,256" />
          <CrosshairPointer texture="Content/Items/Weapons/Crosshairs.png" sourcerect="256,256,256,256" />
          <ParticleEmitter particle="FlareBubbles" scalemin="1.4" scalemax="1.8" particleamount="14" anglemin="0" anglemax="360" velocitymin="0" velocitymax="50" />
          <ParticleEmitter particle="GlowDot" scalemin="4.0" scalemax="4.0" particleamount="20" anglemin="0" anglemax="360" velocitymin="0" velocitymax="0" colormultiplier="10,235,195,255" />
          <ParticleEmitterCharge particle="chargenucleargun" particlespersecond="60" scalemultiplier="0.75,0.75" scalemin="1.0" scalemax="1.0" anglemax="360" />
          <Sound file="Content/Items/JobGear/Engineer/WEAPONS_rapidFissileAccelerator.ogg" type="OnUse" range="3000" selectionmode="Random" />
          <Sound file="Content/Items/JobGear/Engineer/WEAPONS_rapidFissileAccelerator2.ogg" type="OnUse" range="3000" />
          <Sound file="Content/Items/JobGear/Engineer/WEAPONS_rapidFissileAccelerator3.ogg" type="OnUse" range="3000" />
          <Sound file="Content/Items/JobGear/Engineer/WEAPONS_rapidFissileAccelerator4.ogg" type="OnUse" range="3000" />
          <ChargeSound file="Content/Items/JobGear/Engineer/WEAPONS_rapidFissileAcceleratorStartLoop.ogg" range="1000" />
          <StatusEffect type="OnUse" target="This">
            <Explosion range="150.0" force="3" shockwave="false" smoke="false" flash="true" sparks="false" flames="false" underwaterbubble="false" camerashake="25.0" />
          </StatusEffect>
          <StatusEffect type="OnUse" target="Contained">
            <Use />
          </StatusEffect>
          <RequiredItems excludeditems="sgt_gaugeset" items="nuclearcartridge" type="Contained" msg="ItemMsgAmmoRequired">
            <Upgrade modversion="1.1.0" excludeditems="sgt_gaugeset" />
          </RequiredItems>
          <RequiredSkill identifier="weapons" level="45" />
          <RequiredSkill identifier="electrical" level="85" />
        </RangedWeapon>
        <ItemContainer capacity="1" maxstacksize="1" hideitems="false" itempos="10,-5" containedspritedepths="0.562,0.561" containedstateindicatorstyle="default" containedstateindicatorslot="0">
          <Containable items="nuclearcartridge" rotation="90">
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="1.9" condition="100" stackable="false" />
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" condition="-100" stackable="false" />
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="0.1" stackable="false" comparison="or">
              <Conditional EntityType="eq character" TargetContainer="True" />
              <Conditional EntityType="eq null" TargetContainer="True" />
              <sound file="%ModDir:2764968387%/Sounds/energyreload1.ogg" type="OnUse" forceplay="true" range="900.0" loop="false" frequencymultiplier="0.9" volume="1" />
            </StatusEffect>
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="1.5" stackable="false" comparison="or">
              <Conditional EntityType="eq character" TargetContainer="True" />
              <Conditional EntityType="eq null" TargetContainer="True" />
              <sound file="%ModDir:2764968387%/Sounds/energyreload2.ogg" type="OnUse" forceplay="true" range="900.0" loop="false" frequencymultiplier="0.9" volume="1" />
            </StatusEffect>
          </Containable>
          <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="192,448,64,64" origin="0.5,0.5" />
          <SlotIcon slotindex="1" texture="Content/UI/StatusMonitorUI.png" sourcerect="320,448,64,64" origin="0.5,0.5" />
          <SubContainer capacity="1" maxstacksize="1">
            <Containable items="flashlight" hide="false" itempos="25,0" setactive="true" />
          </SubContainer>
        </ItemContainer>
        <aitarget sightrange="3000" soundrange="5000" fadeouttime="5" />
        <SkillRequirementHint identifier="weapons" level="45" />
        <SkillRequirementHint identifier="electrical" level="85" />
        <Quality>
          <QualityStat stattype="FirepowerMultiplier" value="0.05" />
        </Quality>
      </Item>]])
  },
  -- Remove fabrication recipe
  ["nucleardepthchargecheap"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["uranium"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="2" />
            <RequiredItem identifier="riftmat" mincondition="0.5" />
          </Fabricate>]])
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["thorium"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="6" />
            <RequiredItem identifier="riftmat" mincondition="0.25" />
          </Fabricate>]])
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["brockite"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="7" />
            <RequiredItem identifier="riftmat" mincondition="0.5" />
          </Fabricate>]])
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["thorianite"] = {
    mod = "Enhanced Reactors",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="15" />
          </Fabricate>]])
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["uraniumore"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="10" />
          </Fabricate>]])
      },
    }
  },
  -- Add rift engine fabrication recipe
  ["fulgurium"] = {
    mod = "Enhanced Reactors",
    -- Multiple recipes
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="riftfabricator" requiredtime="1">
            <RequiredItem identifier="riftmat" amount="10" />
          </Fabricate>]])
      },
    }
  },
  -- Integrate with IDG
  ["hazmatsuit2"] = {
    mod = "Enhanced Reactors",
    xml = XElement.Parse([[
      <Item name="Hazmat Suit (Pressure Resistant)" identifier="hazmatsuit2" category="Diving,Equipment" tags="diving,deepdiving,human" scale="0.5" fireproof="true" description="" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy" botpriority="1">
        <Deconstruct time="20">
          <Item identifier="hazmatsuit1" />
          <Item identifier="rubber" />
        </Deconstruct>
        <Fabricate suitablefabricators="fabricator" requiredtime="45">
          <RequiredSkill identifier="mechanical" level="60" />
          <Item identifier="hazmatsuit1" amount="1" />
          <Item identifier="titaniumaluminiumalloy" amount="1" />
          <Item identifier="rubber" amount="2" />
        </Fabricate>
        <InventoryIcon name="Engineer Hazmat Icon" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuitItem2.png" sourcerect="0,0,190,116" origin="0.5,0.5" />
        <Sprite name="Engineer Hazmat" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuitItem.png" sourcerect="0,0,190,116" depth="0.6" origin="0.5,0.5" />
        <ContainedSprite name="Respawn Diving Suit In Vertical Locker" allowedcontainertags="divingsuitcontainervertical" texture="Content/Items/Diving/RespawnSuit_Items.png" sourcerect="181,0,70,192" depth="0.55" origin="0.5,0.5" />
        <ContainedSprite name="Respawn Diving Suit Behind Window" allowedcontainertags="divingsuitcontainerwindow" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" sourcerect="523,21,77,214" depth="0.55" origin="-0.12,-0.13" />
        <ContainedSprite name="Respawn Diving Suit In Horizontal Locker" allowedcontainertags="divingsuitcontainerhorizontal" texture="Content/Items/Diving/RespawnSuit_Items.png" sourcerect="0,193,230,63" depth="0.55" origin="0.6,0.5" />
        <Body radius="45" width="34" density="20" />
          <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0">
            <StatusEffect type="OnWearing" target="This,Character" interval="0.2" duration="0.2" OxygenAvailable="-100.0" UseHullOxygen="false" comparison="And">
              <Conditional HasStatusTag="eq sealed" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" SpeedMultiplier="0.6" setvalue="true" interval="0.2" duration="0.2" disabledeltatime="true" />
            <StatusEffect type="OnContained" target="Contained" targetslot="0" Condition="1.0" interval="1" disabledeltatime="true">
              <Conditional Voltage="gt 0.01" targetcontainer="true" targetgrandparent="true" targetitemcomponent="Powered" />
              <RequiredItem items="refillableoxygensource" type="Contained" excludebroken="false" excludefullcondition="true" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" OxygenAvailable="1000.0" Condition="-0.3" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
              <RequiredItem items="oxygensource" type="Contained" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
              <RequiredItem items="weldingfueltank" type="Contained" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Contained,Character" targetlimbs="Torso" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
              <RequiredItem items="incendiumfueltank" type="Contained" />
              <Affliction identifier="burn" amount="3.0" />
            </StatusEffect>
          </GreaterComponent>
          <Wearable slots="InnerClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select">
            <StatusEffect type="OnWearing" target="Character" tags="hassuit" interval="0.1" duration="0.2">
              <Conditional HasStatusTag="eq hashelmet" />
              <Affliction identifier="pressure6650" amount="1" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" comparison="And">
              <Conditional IsLocalPlayer="true" />
              <Conditional InWater="true" />
              <Sound file="%ModDir:3074045632%/Content/Items/Diving/SuitWaterAmbience.ogg" type="OnWearing" range="250" loop="true" volumeproperty="Speed" volume="0.8" frequencymultiplier="0.5" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="This" setvalue="true" interval="0.9" comparison="And">
              <Conditional IsBot="true" targetcontainer="true" />
              <Conditional HasStatusTag="neq hashelmet" targetcontainer="true" />
              <SpawnItem identifier="botdivingsuithelmet" spawnposition="SameInventory" spawnifinventoryfull="false" spawnifcantbecontained="false" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" ObstructVision="true" tags="botsuit,sealed,hassuit" PressureProtection="5750.0" interval="0.1" duration="0.2" setvalue="true" disabledeltatime="true">
              <Conditional HasTag="bothelmet" targetcontaineditem="true" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" setvalue="true">
              <TriggerAnimation Type="Walk" FileName="HumanWalkDivingSuit" priority="1" ExpectedSpecies="Human" />
              <TriggerAnimation Type="Run" FileName="HumanRunDivingSuit" priority="1" ExpectedSpecies="Human" />
            </StatusEffect>
            <sprite name="Engineer's Hazmat Torso" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="Torso" hidelimb="false" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Hand" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightHand" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Hand" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftHand" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Lower Arm" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightArm" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Lower Arm" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftArm" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Upper Arm" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightForearm" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Upper Arm" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftForearm" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Waist" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="Waist" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Thigh" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightThigh" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Thigh" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftThigh" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Leg" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightLeg" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Leg" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftLeg" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Left Shoe" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="LeftFoot" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <sprite name="Engineer's Hazmat Right Shoe" texture="%ModDir:3045796581%/Content/Items/Jobgear/Engineer/HazmatSuit.png" limb="RightFoot" hidelimb="true" hideotherwearables="true" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="overheating" damagemultiplier="0.0" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="contaminated" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictiontypes="burn" damagemultiplier="0.3" />
            <damagemodifier armorsector="0.0,360.0" afflictiontypes="paralysis" damagemultiplier="0.3" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="cyanidepoisoning" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="deliriuminepoisoning" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="morbusinepoisoning" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="sufforinpoisoning" damagemultiplier="0.5" />
            <damagemodifier armorsector="0.0,360.0" afflictiontypes="damage" damagemultiplier="0.7" />
            </Wearable>
          <Holdable slots="RightHand,LeftHand" controlpose="true" holdpos="0,-40" handle1="-10,-20" handle2="10,-20" holdangle="0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use">
            <Upgrade gameversion="0.1401.0.0" msg="ItemMsgPickUpUse" />
          </Holdable>
          <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
            <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="64,448,64,64" origin="0.5,0.5" />
            <Containable items="weldingtoolfuel" excludeditems="oxygenitetank" />
            <Containable items="oxygensource" excludeditems="oxygenitetank">
              <StatusEffect type="OnWearing" target="Contained">
                <RequiredItem items="oxygensource" type="Contained" />
                <Conditional condition="lt 5.0" />
                <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
              </StatusEffect>
            </Containable>
            <Containable items="oxygenitetank">
              <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="1.3" setvalue="true" targetslot="0" comparison="And">
                <Conditional IsDead="false" />
                <Conditional HasStatusTag="eq sealed" />
              </StatusEffect>
            </Containable>
            <StatusEffect type="OnWearing" target="Contained" playsoundonrequireditemfailure="true">
              <RequiredItem items="oxygensource,weldingtoolfuel" type="Contained" matchonempty="true" />
              <Conditional condition="lte 0.0" />
              <Sound file="Content/Items/WarningBeep.ogg" range="250" loop="true" />
            </StatusEffect>
          </ItemContainer>
          <aitarget maxsightrange="1500" />
        </Item>]])
  },

  -- ****************
  -- Tweaked Glowlers
  -- ****************
  -- Prioritize TG's overrides
  -- Add "huntimmune" tag
  ["flare"] = {
    mod = "Tweaked Glowlers",
    xml = XElement.Parse([[
      <Item name="" identifier="flare" category="Equipment" maxstacksize="32" maxstacksizecharacterinventory="8" cargocontaineridentifier="metalcrate" Scale="0.5" tags="smallitem,light,provocative,huntimmune" impactsoundtag="impact_soft" isshootable="true" damagedbymonsters="true" health="100">
        <PreferredContainer primary="divingcab" minamount="2" maxamount="5" spawnprobability="1" notcampaign="true" notpvp="true" />
        <PreferredContainer secondary="abandonedstoragecab,piratestoragecab,wreckstoragecab" amount="1" spawnprobability="0.05" />
        <PreferredContainer secondary="outpostcrewcabinet" amount="1" spawnprobability="0.1" />
        <Price baseprice="30" minavailable="6">
          <Price storeidentifier="merchantoutpost" />
          <Price storeidentifier="merchantcity" multiplier="0.9" minavailable="10" />
          <Price storeidentifier="merchantresearch" multiplier="1.25" />
          <Price storeidentifier="merchantmilitary" multiplier="1.25" minavailable="8" />
          <Price storeidentifier="merchantmine" minavailable="10" />
          <Price storeidentifier="merchantarmory" multiplier="1.25" minavailable="8" />
        </Price>
        <Deconstruct time="5" />
        <Fabricate suitablefabricators="fabricator" requiredtime="10" amount="12">
          <RequiredItem identifier="flashpowder" amount="2" />
          <RequiredItem identifier="plastic" />
        </Fabricate>
        <InventoryIcon texture="Content/Items/InventoryIconAtlas.png" sourcerect="640,0,64,64" origin="0.5,0.5" />
        <Sprite texture="Content/Items/Tools/tools.png" sourcerect="227,204,54,18" depth="0.55" origin="0.5,0.5" />
        <!--Flare now sinks-->
        <Body width="50" height="15" density="10.1" />
        <Throwable slots="Any,RightHand,LeftHand" holdangle="70" holdpos="0,0" aimpos="50,-20" handle1="-10,3" throwforce="2.0" msg="ItemMsgPickUpSelect" />
        <LightComponent LightColor="255,0.0,0.0,255" Flicker="0.5" range="600" IsOn="false">
          <StatusEffect type="OnUse" targettype="This" IsOn="true" DontCleanUp="True">
            <Conditional IsOn="eq False" targetitemcomponent="LightComponent" />
            <sound file="Content/Items/Tools/FlareIgnite.ogg" range="800.0" />
          </StatusEffect>
          <!--hp decreeses faster-->
          <StatusEffect type="OnActive" targettype="This" Condition="-0.7" />
          <StatusEffect type="OnActive" targettype="This">
            <Conditional PhysicsBodyActive="eq true" />
            <ParticleEmitter particle="flare" emitinterval="2.1" particleamount="10" particlespersecond="60" anglemin="70" anglemax="100" velocitymin="100" velocitymax="200" />
            <ParticleEmitter particle="FlareBubbles" particlespersecond="40" anglemin="70" anglemax="100" velocitymin="100" velocitymax="200" scalemin="0.8" scalemax="1.2" />
          </StatusEffect>
          <!--Flare destroys on broken-->
          <StatusEffect type="OnBroken" targettype="This" IsOn="false">
            <Remove />
          </StatusEffect>
          <sound file="Content/Items/Tools/FlareLoop.ogg" type="OnActive" range="800.0" loop="true" />
        </LightComponent>
        <!--Better AI targeting-->
        <AiTarget sightrange="3000" priority="30" />
        <!--Flare ia ammo for the gun-->
        <Projectile characterusable="false" launchimpulse="08.0" hitscan="false" sticktocharacters="false" launchrotation="-90" inheritStatusEffectsFrom="LightComponent">
          <StatusEffect type="OnUse" target="This" canbeselected="false" canbepicked="false" setvalue="true" />
          <Attack structuredamage="0" targetforce="10" itemdamage="0" severlimbsprobability="0">
            <StatusEffect type="OnUse" target="UseTarget">
              <Affliction identifier="burn" amount="0.25" />
              <Affliction identifier="burning" amount="2" dividebylimbcount="true" />
            </StatusEffect>
          </Attack>
        </Projectile>
        <Upgrade gameversion="0.10.0.0" scale="0.5" />
      </Item>]])
  },
  ["alienflare"] = {
    mod = "Tweaked Glowlers",
  },
  ["glowstick"] = {
    mod = "Tweaked Glowlers",
  },
  -- The colored glowsticks are new items, not overrides

  -- *******************
  -- Traitor Alike Items
  -- *******************
  -- Remove poisoned rounds
  ["rrmorbusine"] = { mod = "Traitor Alike Items", xml = "" },
  ["rrcyanide"] = { mod = "Traitor Alike Items", xml = "" },
  ["rrdeliriumine"] = { mod = "Traitor Alike Items", xml = "" },
  ["shotgunshellmorbusine"] = { mod = "Traitor Alike Items", xml = "" },
  ["shotgunshellcyanide"] = { mod = "Traitor Alike Items", xml = "" },
  ["shotgunshelldeliriumine"] = { mod = "Traitor Alike Items", xml = "" },
  -- (Improvised Grenade) Removed, as EHA adds a pipe bomb with basically the same effect
  ["diybomb"] = { mod = "Traitor Alike Items", xml = "" },
  -- (Zip Ties) Remove fabrication recipe
  ["stasky"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["plasticbag"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- (Suicide Belt) Remove fabrication recipe
  ["shahidka"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- (Suicide Vest) Remove fabrication recipe
  ["shahidkatimer"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, also integrate Enhanced Immersion's flashlight changes
  -- Don't know how to get this functional, so it's removed for now
  -- (the battery drain statuseffect also drains contained syringes)
  ["flashlightsyringe"] = {
    mod = "Traitor Alike Items",
    xml = "" --[=[XElement.Parse([[
    <Item name="" identifier="flashlightsyringe" category="Equipment" Tags="smallitem,tool,provocative,flashlight" cargocontaineridentifier="metalcrate" Scale="0.5" impactsoundtag="impact_plastic">
      <Price baseprice="200" minavailable="2">
        <Price storeidentifier="merchantoutpost" />
        <Price storeidentifier="merchantcity" multiplier="0.9" minavailable="3" />
        <Price storeidentifier="merchantresearch" multiplier="1.25" />
        <Price storeidentifier="merchantmilitary" multiplier="1.25" />
        <Price storeidentifier="merchantmine" />
      </Price>
      <!--<Fabricate suitablefabricators="fabricator" requiredtime="10">
        <RequiredSkill identifier="mechanical" level="25" />
        <RequiredItem identifier="aluminium" amount="2" />
        <RequiredItem tag="lightcomponent" />
      </Fabricate>-->
      <Deconstruct time="15">
        <Item identifier="aluminium" />
        <Item identifier="lightcomponent" />
      </Deconstruct>
      <InventoryIcon texture="Content/Items/InventoryIconAtlas.png" sourcerect="704,320,64,64" origin="0.5,0.5" />
      <Sprite texture="Content/Items/Tools/tools.png" sourcerect="293,185,49,18" depth="0.55" origin="0.5,0.5" />
      <Body width="48" height="15" density="15" />
      <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0" drawhudwhenequipped="false" MaxOutputLength="1" />
      <Holdable slots="Any,RightHand,LeftHand,Head" holdpos="30,-50" aimpos="60,0" handle1="-20,0" msg="ItemMsgPickUpSelect">
        <StatusEffect type="OnContained" target="This" targetitemcomponent="LightComponent" IsOn="true" setvalue="true" interval="1" comparison="And">
          <Conditional HasTag="weapon" targetcontainer="true" />
          <Conditional IsOn="false" />
        </StatusEffect>
        <StatusEffect type="OnContained" target="This" targetitemcomponent="LightComponent" IsOn="true" setvalue="true" interval="1" comparison="And">
          <Conditional HasTag="gun" targetcontainer="true" />
          <Conditional IsOn="false" />
        </StatusEffect>
        <StatusEffect type="OnContained" target="This" tags="flashlighton" duration="0.1">
          <Conditional HasTag="gun" targetcontainer="true" />
          <Conditional HasTag="weapon" targetcontainer="true" />
        </StatusEffect>
        <!-- play an opening sound when starting to interact with the flashlight -->
        <StatusEffect type="OnSecondaryUse" target="this" forceplaysounds="true">
          <Conditional HasStatusTag="neq flashlighton" />
          <Sound file="%ModDir:2968896556%/Content/Items/Tools/FlashlightOn.ogg" voluem="1.0" frequencymultiplier="1.2" range="350" loop="false" />
        </StatusEffect>
        <!-- tag the flashlight with "flashlighton" while it's being aimed -->
        <StatusEffect type="OnSecondaryUse" target="This" tags="flashlighton" duration="0.1" />
        <!-- turn the ItemComponent on so we can play a sound when the user stops aiming the flashlight. Would otherwise require an "Always" check which would always run and thus impact performance. -->
        <StatusEffect type="OnSecondaryUse" target="This" targetitemcomponent="ItemComponent" IsActive="true" setvalue="true" />
        <!-- turn on the LightComponent when the flashlight is being aimed -->
        <StatusEffect type="OnSecondaryUse" target="This" targetitemcomponent="LightComponent" IsOn="true" setvalue="true" />
      </Holdable>
      <RangedWeapon barrelpos="71,30" spread="0" unskilledspread="10" drawhudwhenequipped="true" crosshairscale="0.2">
        <Crosshair texture="Content/Items/Weapons/Crosshairs.png" sourcerect="0,256,256,256" />
        <CrosshairPointer texture="Content/Items/Weapons/Crosshairs.png" sourcerect="256,256,256,256" />
        <RequiredItems items="syringe" type="Contained" msg="ItemMsgSyringeRequired" />
        <RequiredSkill identifier="weapons" level="20" />
        <RequiredSkill identifier="medical" level="30" />
      </RangedWeapon>
      <!-- ItemComponent used as a workaround to play a sound if someone stopped interacting with the container since that can't really be done otherwise other than with "Always" StatusEffects which drain performance nonstop instead of only when interaction is happening. -->
      <ItemComponent canbeselected="false" canbepicked="false" allowingameediting="false" IsActive="false">
        <!-- turn off the LightComponent when the flashlight is no longer aimed and thus does not have the "flahslighton" tag -->
        <StatusEffect type="OnActive" target="This" targetitemcomponent="LightComponent" IsOn="false" setvalue="true" forceplaysounds="true">
          <Conditional HasStatusTag="neq flashlighton" />
        </StatusEffect>
        <!-- play a sound and disable the ItemComponent, stopping to execute the check for the "flashlighton" tag which gets applied while someone is aiming with the flashlight -->
        <StatusEffect type="OnActive" target="This" targetitemcomponent="ItemComponent" IsActive="false" setvalue="true" forceplaysounds="true">
          <Conditional HasStatusTag="neq flashlighton" />
          <Sound file="%ModDir:2968896556%/Content/Items/Tools/FlashlightOff.ogg" voluem="1.0" range="350" loop="false" />
        </StatusEffect>
      </ItemComponent>
      <LightComponent LightColor="0.5,0.5,0.5,1.0" Flicker="0.02" range="1000" powerconsumption="10" IsOn="false">
        <LightTexture texture="Content/Lights/lightcone.png" origin="0.0, 0.5" size="1.0,1.0" />
        <StatusEffect type="OnActive" targettype="This" flicker="0.02" flickerspeed="1.0" pulsefrequency="0.1" pulseamount="0.0" setvalue="true">
          <Conditional targetcontaineditem="true" condition="gt 1.0" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="This" flicker="0.8" flickerspeed="1.0" pulsefrequency="0.1" pulseamount="0.5" setvalue="true">
          <Conditional targetcontaineditem="true" condition="lte 1.0" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="Contained" Condition="-0.05">
          <Conditional PhysicsBodyActive="true" targetcontainer="true" />
          <RequiredItem items="mobilebattery" type="Contained" />
        </StatusEffect>
        <!-- disable the LightComponent if it doesn't have the tag "flashlighton" which gets applied while someone is aiming with the flashlight or while it's mounted -->
        <StatusEffect type="OnActive" target="This" targetitemcomponent="LightComponent" IsOn="false" setvalue="true" forceplaysounds="true">
          <Conditional HasStatusTag="neq flashlighton" />
        </StatusEffect>
      </LightComponent>
      <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorslot="0" containedstateindicatorstyle="battery">
        <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="128,448,64,64" origin="0.5,0.5" />
        <SlotIcon slotindex="1" texture="Content/UI/StatusMonitorUI.png" sourcerect="384,448,64,64" origin="0.5,0.5" />
        <Containable items="mobilebattery">
          <StatusEffect type="OnContaining" targettype="This" Voltage="1.0" setvalue="true" />
        </Containable>
        <SubContainer capacity="1" maxstacksize="1">
          <Containable items="syringe" hide="true" />
        </SubContainer>
      </ItemContainer>
      <AiTarget sightrange="3000" />
      <Upgrade gameversion="0.10.0.0" scale="0.5" />
    </Item>]])]=]
  },
  -- Remove fabrication recipe
  ["blindfold"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, make it worn in the headset slot
  ["muzzle"] = {
    mod = "Traitor Alike Items",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable limbtype="Head" slots="Any,Headset" msg="ItemMsgPickUpSelect" autoequipwhenfull="false">
            <sprite name="Muzzle Wearable" texture="%ModDir%/Content/Items/Weapons/kakapups.png" limb="Head" inheritlimbdepth="true" inherittexturescale="false" hidelimb="false" hideotherwearables="false" sourcerect="230,326,69,68" origin="0.4,0.3" scale="0.4" hidewearablesoftype="moustache,beard" />
            <!-- No more speaking for you -->
            <StatusEffect tags="gagged" type="OnWearing" target="Character" setvalue="true" stackable="false" speechImpediment="100.0" />
            <StatusEffect type="OnBroken" target="This">
              <Sound file="Content/Sounds/Impact/SoftImpact1.ogg" type="OnActive" range="1000" />
              <Remove />
            </StatusEffect>
          </Wearable>]])
      },
    },
  },
  -- (ALCD) Remove fabrication recipe, make it work with "Munkee-approved stations"
  ["emag"] = {
    mod = "Traitor Alike Items",
    xml = XElement.Parse([[
    <Item name="" description="" identifier="emag" category="Equipment" tags="idcard,smallitem" scale="0.5">
      <!--<Fabricate requiredtime="20" suitablefabricators="fabricator">
        <Item identifier="fpgacircuit" />
        <Item identifier="plastic" />
        <RequiredSkill identifier="electrical" level="40" />
      </Fabricate>-->
      <Deconstruct requiredtime="5">
        <Item identifier="fpgacircuit" />
        <Item identifier="plastic" />
      </Deconstruct>
      <Sprite name="Emag" texture="%ModDir%/Content/Items/Tools/emag_new.png" sourcerect="0,0,40,27" />
      <Body width="40" radius="10" density="15" />
      <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorslot="0" showcontainedstateindicator="false">
        <SlotIcon slotindex="0" texture="Content/UI/MainIconsAtlas.png" sourcerect="642,130,124,124" origin="0.5,0.5" />
        <Containable items="idcard" excludeditems="emag" />
      </ItemContainer>
      <IdCard slots="Card,Any" msg="ItemMsgPickUpSelect">
        <StatusEffect type="Always" target="This" tags="cap">
          <RequiredItem items="cap" type="Contained" />
        </StatusEffect>
        <StatusEffect type="Always" target="This" tags="sec">
          <RequiredItem items="sec" type="Contained" />
        </StatusEffect>
        <StatusEffect type="Always" target="This" tags="med">
          <RequiredItem items="med" type="Contained" />
        </StatusEffect>
        <StatusEffect type="Always" target="This" tags="eng">
          <RequiredItem items="eng" type="Contained" />
        </StatusEffect>
      </IdCard>
    </Item>]])
  },
  -- (Molotov) Remove fabrication recipe, make the fire less powerful
  ["lqmolotov"] = {
    mod = "Traitor Alike Items",
    xml = XElement.Parse([[
    <Item name="" description="" identifier="lqmolotov" category="Weapon" scale="0.5" impacttolerance="5" maxstacksize="12" stackable="True" impactsoundtag="impact_metal_light" isshootable="true" tags="smallitem,light" cargocontaineridentifier="abandonedsecarmcab,abandonedstoragecab">
      <!--<Fabricate suitablefabricators="fabricator" requiredtime="5">
        <RequiredItem identifier="ethanol" />
        <RequiredItem identifier="antibleeding1" />
      </Fabricate>-->
      <Deconstruct>
        <Item identifier="ethanol" condition="50" />
      </Deconstruct>
      <InventoryIcon texture="%ModDir%/Content/Items/Weapons/weapons.png" sourcerect="198,7,48,72" origin="0.5,0.5" />
      <Sprite texture="%ModDir%/Content/Items/Weapons/weapons.png" sourcerect="116,269,30,70" depth="0.6" origin="0.5,0.5" />
      <Body width="30" height="60" density="20" />
      <Throwable slots="Any,RightHand,LeftHand" holdpos="0,0" handle1="0,0" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect" />
      <LightComponent LightColor="255,100,50,255" Flicker="0.5" range="600" IsOn="false">
        <StatusEffect type="OnUse" targettype="This" IsOn="true">
          <Conditional IsOn="eq False" targetitemcomponent="LightComponent" />
          <sound file="Content/Items/Tools/FlareIgnite.ogg" range="800.0" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="This" Condition="-0.25">
          <Conditional Condition="gt 1" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="This" conditionalcomparison="And">
          <Conditional PhysicsBodyActive="eq true" />
          <Conditional Condition="gt 1" />
          <ParticleEmitter particle="flame" particlespersecond="15" velocitymin="0" scalemin="0.2" scalemax="0.3" anglemin="0" anglemax="360" lifetimemultiplier="0.5" />
        </StatusEffect>
        <StatusEffect type="InWater" targettype="This" IsOn="false" />
        <StatusEffect type="OnBroken" targettype="This" IsOn="false" />
        <StatusEffect type="OnImpact" target="This">
          <sound file="Content/Sounds/Damage/GlassImpact2.ogg" selectionmode="All" range="2000" />
          <ParticleEmitter particle="iceshards" anglemin="0" anglemax="360" particleamount="30" velocitymin="0" velocitymax="500" scalemin="0.5" scalemax="1" />
          <Remove />
        </StatusEffect>
        <StatusEffect type="OnImpact" target="This" Condition="-100.0" conditionalcomparison="And">
          <Conditional IsOn="eq True" />
          <Conditional Condition="gt 1" />
          <sound file="Content/Sounds/Damage/GlassImpact2.ogg" selectionmode="All" range="2000" />
          <sound file="Content/Items/Weapons/ExplosionDebris3.ogg" selectionmode="All" range="2000" />
          <ParticleEmitter particle="iceshards" anglemin="0" anglemax="360" particleamount="20" velocitymin="500" velocitymax="800" scalemin="0.5" scalemax="0.5" />
          <Explosion range="250.0" ballastfloradamage="75" structuredamage="0" itemdamage="100" force="2.0" severlimbsprobability="0" debris="true" underwaterbubble="false">
            <Affliction identifier="burn" strength="20" />
            <Affliction identifier="stun" strength="0.5" />
          </Explosion>
          <!-- Reduced to 50 from 150 -->
          <Fire size="50" />
          <Remove />
        </StatusEffect>
      </LightComponent>
    </Item>]])
  },
  -- (Vanilla Molotov) Remove fabrication recipe and auto-spawn rules, integrate EHA override, make fire more powerful
  ["molotovcoctail"] = {
    mod = "Traitor Alike Items",
    xml = XElement.Parse([[
    <Item name="" identifier="molotovcoctail" category="Equipment" maxstacksize="12" cargocontaineridentifier="metalcrate" impacttolerance="5" Scale="0.5" tags="smallitem,light,provocative,separatists" impactsoundtag="impact_metal_light" isshootable="true">
      <Price baseprice="90" minavailable="6" sold="false">
        <Price storeidentifier="merchantoutpost" minavailable="2" maxavailable="4" sold="true">
          <Reputation faction="separatists" min="25" />
        </Price>
        <Price storeidentifier="merchantcity" minavailable="3" maxavailable="6" sold="true">
          <Reputation faction="separatists" min="25" />
        </Price>
        <Price storeidentifier="merchantmilitary" minavailable="5" maxavailable="10" sold="true">
          <Reputation faction="separatists" min="25" />
        </Price>
      </Price>
      <sprite texture="%ModDir:2764968387%/Weapons/Grenades.png" sourcerect="120,124,27,60" depth="0.55" origin="0.5,0.5" />
      <Body width="40" height="60" density="12" />
      <Deconstruct time="10">
        <Item identifier="ethanol" />
        <Item identifier="organicfiber" />
      </Deconstruct>
      <!--<Fabricate suitablefabricators="fabricator" requiredtime="15">
        <RequiredSkill identifier="weapons" level="15" />
        <RequiredSkill identifier="mechanical" level="15" />
        <RequiredItem identifier="ethanol" />
        <RequiredItem identifier="weldingfueltank" />
        <RequiredItem identifier="organicfiber" />
      </Fabricate>-->
      <Throwable slots="Any,RightHand,LeftHand" holdpos="0,0" handle1="0,0" throwforce="4.0" aimpos="35,-10" msg="ItemMsgPickUpSelect" />
      <LightComponent LightColor="255,100,50,255" Flicker="0.5" range="600" IsOn="false">
        <StatusEffect type="OnUse" targettype="This" IsOn="true">
          <Conditional IsOn="eq False" targetitemcomponent="LightComponent" />
          <sound file="Content/Items/Tools/FlareIgnite.ogg" range="800.0" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="This" Condition="-0.25">
          <Conditional Condition="gt 1" />
        </StatusEffect>
        <StatusEffect type="OnActive" targettype="This" conditionalcomparison="And">
          <Conditional PhysicsBodyActive="eq true" />
          <Conditional Condition="gt 1" />
          <ParticleEmitter particle="flame" particlespersecond="15" velocitymin="0" scalemin="0.2" scalemax="0.3" anglemin="0" anglemax="360" lifetimemultiplier="0.5" />
        </StatusEffect>
        <StatusEffect type="InWater" targettype="This" IsOn="false" />
        <StatusEffect type="OnBroken" targettype="This" IsOn="false" />
        <StatusEffect type="OnImpact" target="This">
          <sound file="%ModDir:2764968387%/Sounds/molotov.ogg" selectionmode="All" range="2000" />
          <ParticleEmitter particle="iceshards" anglemin="0" anglemax="360" particleamount="30" velocitymin="0" velocitymax="500" scalemin="0.5" scalemax="1" />
          <Remove />
        </StatusEffect>
        <StatusEffect type="OnImpact" target="This" Condition="-100.0" conditionalcomparison="And">
          <Conditional IsOn="eq True" />
          <Conditional Condition="gt 1" />
          <sound file="Content/Sounds/Damage/GlassImpact2.ogg" selectionmode="All" range="2000" />
          <sound file="Content/Items/Weapons/ExplosionDebris3.ogg" selectionmode="All" range="2000" />
          <ParticleEmitter particle="iceshards" anglemin="0" anglemax="360" particleamount="20" velocitymin="500" velocitymax="800" scalemin="0.5" scalemax="0.5" />
          <Explosion range="500.0" ballastfloradamage="200" structuredamage="0" itemdamage="100" force="2.0" severlimbsprobability="0" debris="true" underwaterbubble="false">
            <Affliction identifier="burn" strength="50" />
            <Affliction identifier="stun" strength="0.5" />
          </Explosion>
          <!-- Big fire -->
          <Fire size="400" />
          <Remove />
        </StatusEffect>
      </LightComponent>
    </Item>]])
  },
  -- Total override
  ["reversebeartrap"] = {
    mod = "Traitor Alike Items",
    xml = XElement.Parse([[
      <Item nameidentifier="mm_reversebeartrap" descriptionidentifier="mm_reversebeartrap" name="" description="" identifier="reversebeartrap" category="Weapon" cargocontaineridentifier="abandonedsecarmcab,abandonedstoragecab" tags="weapon,smallitem" scale="0.4" impactsoundtag="impact_metal_light">
        <sprite name="Reverse Nab" texture="%ModDir%/Content/Items/Weapons/saw.png" sourcerect="22,25,128,127" origin="0.5,0.5" scale="0.4" />
        <Body width="40" radius="30" density="15" />
        <Deconstruct time="10">
          <Item identifier="fpgacircuit" />
          <Item identifier="steel" />
        </Deconstruct>
        <Wearable limbtype="Head" slots="Any,Head" msg="ItemMsgPickUpSelect" autoequipwhenfull="false">
          <sprite name="Reverse Trap" texture="%ModDir%/Content/Items/Weapons/saw.png" limb="Head" inheritlimbdepth="true" inherittexturescale="true" depth="0.6" scale="1.3" sourcerect="232,32,91,103" origin="0.5,0.56" />
          <StatusEffect type="OnWearing" target="Character" setvalue="true" comparison="And" stackable="false" speechImpediment="25.0" noninteractable="True" />
          <StatusEffect type="OnWearing" target="This" noninteractable="True" />
          <StatusEffect type="OnWearing" target="This" delay="10.0" condition="-100" comparison="And" disabledeltatime="true"></StatusEffect>
          <StatusEffect type="OnBroken" target="This" noninteractable="False">
            <Sound file="%ModDir%/Content/Items/Weapons/trapclose.ogg" range="400" volume="1.0" loop="false" delay="10.0" type="OnWearing" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This" noninteractable="False">
            <Sound file="%ModDir%/Content/Items/Weapons/trapclose.ogg" range="400" volume="1.0" loop="false" delay="10.0" type="OnWearing" />
          </StatusEffect>
          <StatusEffect type="OnBroken" target="This" delay="0.15">
            <Remove />
          </StatusEffect>
          <StatusEffect type="Always" target="Character" targetlimbs="Head" delay="0.01" disabledeltatime="true">
            <Conditional IsDead="true" />
            <ParticleEmitter particle="blood" copyentityangle="true" anglemin="0" anglemax="0" particlespersecond="45" velocitymin="65" velocitymax="220" scalemin="1.5" scalemax="2.8" />
            <Explosion range="1" decal="blood" decalsize="2" flashrange="0" stun="0" force="2" flames="false" smoke="false" shockwave="false" sparks="false" underwaterbubble="false" ignorecover="true" camerashake="30" camerashakerange="50"></Explosion>
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" targetlimbs="Head" delay="10" disabledeltatime="true">
            <Affliction identifier="lacerations" amount="250" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character">
            <Sound file="%ModDir%/Content/Items/Weapons/tickingnab.ogg" range="200" loop="true" volume="0.5" />
            <Conditional IsDead="False" />
          </StatusEffect>
        </Wearable>
      </Item>]])
  },
  -- Remove
  ["reversebeartrapbroken"] = {
    mod = "Traitor Alike Items",
    xml = ""
  },

  -- *********************
  -- EHA Fuel For The Fire
  -- *********************
  -- Change fabricator to weapon fabricator
  ["sgt_syringeshotgun"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredSkill identifier="medical" level="40" />
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="syringegun" amount="1" />
            <RequiredItem identifier="oxygentank" amount="1" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="aluminium" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["40mmbreach"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="12">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="steel" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem identifier="c4block" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo / reload
  ["sgt_10mmmagacid"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="2">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" mincondition="2" />
            <RequiredItem identifier="sulphuricacidsyringe" amount="2" />
            <RequiredItem identifier="silicon" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="3" amount="2">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" mincondition="2" />
            <RequiredItem identifier="sulphuricacidsyringe" amount="2" />
            <RequiredItem identifier="silicon" />
            <RequiredItem tag="10mmpistolmag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" usecondition="false" amount="2" />
          </Fabricate>]])
      }
    },
  },
  -- Change fabricator to ammo / reload
  ["sgt_10mmmag"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="2">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" mincondition="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" mincondition="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="3" amount="2">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" mincondition="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" mincondition="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
            <RequiredItem tag="10mmpistolmag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" usecondition="false" amount="2" />
          </Fabricate>]])
      }
    },
  },
  -- Remove fabrication recipe
  ["sgt_wraps"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["sgt_hbcell"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="40" amount="3">
            <RequiredSkill identifier="electrical" level="25" />
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="aluminium" amount="3" />
            <RequiredItem identifier="zinc" />
            <RequiredItem identifier="lithium" />
            <RequiredItem identifier="alienblood" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["sgt_hbcell2"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="40" amount="3">
            <RequiredSkill identifier="electrical" level="25" />
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="aluminium" amount="3" />
            <RequiredItem identifier="zinc" />
            <RequiredItem identifier="fulgurium" />
            <RequiredItem identifier="alienblood" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["sgt_hbcellovercharge"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="40" amount="3">
            <RequiredSkill identifier="electrical" level="60" />
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="aluminium" amount="3" />
            <RequiredItem tag="smallalienartifact" />
            <RequiredItem identifier="alienpowercell" />
            <RequiredItem identifier="aliencircuitry" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_blaster"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="120">
            <RequiredSkill identifier="electrical" level="40" />
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="titanium" amount="3" />
            <RequiredItem identifier="fulgurium" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_bracers"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="80">
            <RequiredSkill identifier="weapons" level="60" />
            <RequiredSkill identifier="mechanical" level="40" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
            <RequiredItem identifier="rubber" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_fraggrenadebouquet"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_gravgrenade"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50" amount="2">
            <RequiredSkill identifier="weapons" level="60" />
            <RequiredItem identifier="dementonite" />
            <RequiredItem identifier="fraggrenade" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_luregrenade"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="12" amount="2">
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="magnesium" amount="2" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="iron" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_hbracers"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="mechanical" level="60" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["sgt_hpp"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove "fabrication" recipe
  ["sgt_bobag"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe for consistency
  ["sgt_coalitioncaptainuniform"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe for consistency
  ["sgt_coalitioncaptainhat"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_lightuniform"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="2">
            <RequiredItem identifier="scp_lightuniform" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_medhelm"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="medical" level="60" />
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="scp_combathelmet" />
            <RequiredItem identifier="healthscanner" />
            <RequiredItem identifier="aluminium" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_combatmedicuniform"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="2">
            <Item identifier="scp_combatmedicuniform" />
          </Fabricate>]])
      },
    },
  },
  -- 1. Tweak fabrication/deconstruction
  -- 2. Reduce damage resistance
  ["sgt_fieldcap"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="5" />
            <!--<RequiredItem identifier="ballisticfiber" />-->
            <RequiredItem identifier="organicfiber" />
          </Fabricate>]])
      },
      {
        targetComponent = "deconstruct",
        override = XElement.Parse([[
          <Deconstruct time="6">
            <Item identifier="organicfiber" outcondition="0.5" />
          </Deconstruct>]])
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable limbtype="Head" slots="Any,Head" msg="ItemMsgPickUpSelect">
            <sprite name="patrolcap" texture="%ModDir%/Jobgear/helmets.png" limb="Head" hidewearablesoftype="Hair" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.7" hidelimb="false" sourcerect="24,21,83,48" origin="0.49703875,0.80091476" />
            <SkillModifier skillidentifier="weapons" skillvalue="5" />
            <damagemodifier afflictionidentifiers="lacerations,gunshotwound" armorsector="0.0,360.0" damagemultiplier="0.9" />
          </Wearable>]])
      },
    },
  },
  -- 1. Remove fabrication recipe (separatist)
  -- 2. Tweak desconstruction
  -- 3. Reduce damage resistance
  ["sgt_fieldcap2"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        targetComponent = "deconstruct",
        override = XElement.Parse([[
          <Deconstruct time="6">
            <Item identifier="organicfiber" outcondition="0.5" />
          </Deconstruct>]])
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable limbtype="Head" slots="Any,Head" msg="ItemMsgPickUpSelect">
            <sprite name="patrolcap2" texture="%ModDir%/Jobgear/helmets.png" limb="Head" hidewearablesoftype="Hair" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.7" hidelimb="false" sourcerect="227,21,83,48" origin="0.49703875,0.80091476" />
            <SkillModifier skillidentifier="weapons" skillvalue="5" />
            <damagemodifier afflictionidentifiers="lacerations,gunshotwound" armorsector="0.0,360.0" damagemultiplier="0.9" />
          </Wearable>]])
      },
    },
  },
  -- 1. Tweak fabrication/deconstruction
  -- 2. Reduce damage resistance
  ["sgt_fieldcapb"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="5" />
            <RequiredItem identifier="organicfiber" />
          </Fabricate>]])
      },
      {
        targetComponent = "deconstruct",
        override = XElement.Parse([[
          <Deconstruct time="6">
            <Item identifier="organicfiber" outcondition="0.5" />
          </Deconstruct>]])
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable limbtype="Head" slots="Any,Head" msg="ItemMsgPickUpSelect">
            <sprite name="patrolcap" texture="%ModDir%/Jobgear/helmets.png" limb="Head" hidewearablesoftype="Hair" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.7" hidelimb="false" sourcerect="24,21,83,48" origin="0.49703875,0.80091476" />
            <sprite texture="Content/Items/Jobgear/headgears.png" limb="Head" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.8" sourcerect="313,407,100,95" origin="0.55,0.6" />
            <SkillModifier skillidentifier="weapons" skillvalue="5" />
            <damagemodifier afflictionidentifiers="lacerations,gunshotwound" armorsector="0.0,360.0" damagemultiplier="0.9" />
            <!--<damagemodifier afflictionidentifiers="blunttrauma,bitewounds" armorsector="0.0,360.0" damagemultiplier="0.9" />-->
            <StatusEffect type="OnWearing" target="Character" HideFace="true" duration="0.1" stackable="false" />
          </Wearable>]])
      },
    },
  },
  -- 1. Remove fabrication recipe (separatist)
  -- 2. Tweak desconstruction
  -- 3. Reduce damage resistance
  ["sgt_fieldcap2b"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        targetComponent = "deconstruct",
        override = XElement.Parse([[
          <Deconstruct time="6">
            <Item identifier="organicfiber" outcondition="0.5" />
          </Deconstruct>]])
      },
      {
        targetComponent = "wearable",
        override = XElement.Parse([[
          <Wearable limbtype="Head" slots="Any,Head" msg="ItemMsgPickUpSelect">
            <sprite name="patrolcap2" texture="%ModDir%/Jobgear/helmets.png" limb="Head" hidewearablesoftype="Hair" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.7" hidelimb="false" sourcerect="227,21,83,48" origin="0.49703875,0.80091476" />
            <sprite texture="Content/Items/Jobgear/headgears.png" limb="Head" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.8" sourcerect="313,407,100,95" origin="0.55,0.6" />
            <SkillModifier skillidentifier="weapons" skillvalue="5" />
            <damagemodifier afflictionidentifiers="lacerations,gunshotwound" armorsector="0.0,360.0" damagemultiplier="0.9" />
            <!--<damagemodifier afflictionidentifiers="blunttrauma,bitewounds" armorsector="0.0,360.0" damagemultiplier="0.9" />-->
            <StatusEffect type="OnWearing" target="Character" HideFace="true" duration="0.1" stackable="false" />
          </Wearable>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_pipebombbundle"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- 1. Change fabricator to weapon fabricator
  -- 2. Tweak fabrication / deconstruction recipe
  -- 3. Remove stun resistance
  -- 4. Make it work with Enhanced Reactors
  -- 5. Remove light when powered
  ["sgt_exogear"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    xml = XElement.Parse([[
      <Item name="" identifier="sgt_exogear" category="Equipment" subcategory="Coalition" tags="mediumitem,deepdivinglarge,mobilecontainer,containradiation" scale="0.5" fireproof="true" description="" isshootable="true" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy">
        <Price baseprice="800" canbespecial="false" sold="false" />
        <Deconstruct time="30">
          <Item identifier="safetyharness" />
          <Item identifier="titaniumaluminiumalloy" />
          <Item identifier="rubber" />
        </Deconstruct>
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="60">
          <RequiredSkill identifier="mechanical" level="60" />
          <RequiredItem identifier="safetyharness" />
          <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
          <RequiredItem identifier="rubber" amount="3" />
          <RequiredItem identifier="lead" amount="2" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/Jobgear/coalexogear.png" sourcerect="411,0,101,146" origin="0.5,0.5" />
        <Sprite name="Exosuit Item" texture="%ModDir%/Jobgear/coalexogear.png" sourcerect="411,0,101,146" depth="0.55" origin="0.5,0.5" />
        <Body width="80" height="160" density="30" />
        <Wearable slots="Bag" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select" allowusewhenworn="true">
          <sprite name="Exogear Torso" texture="coalexogear.png" limb="Torso" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Right Hand" texture="coalexogear.png" limb="RightHand" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Left Hand" texture="coalexogear.png" limb="LeftHand" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Right Lower Arm" texture="coalexogear.png" limb="RightArm" hidelimb="false" depthlimb="RightForearm" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Left Lower Arm" texture="coalexogear.png" limb="LeftArm" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Right Upper Arm" texture="coalexogear.png" limb="RightForearm" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Left Upper Arm" texture="coalexogear.png" limb="LeftForearm" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Waist" texture="coalexogear.png" limb="Waist" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Right Thigh" texture="coalexogear.png" limb="RightThigh" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Left Thigh" texture="coalexogear.png" limb="LeftThigh" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Right Leg" texture="coalexogear.png" limb="RightLeg" hidelimb="false" depthlimb="RightArm" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <sprite name="Exogear Left Leg" texture="coalexogear.png" limb="LeftLeg" hidelimb="false" inherittexturescale="true" inheritorigin="true" inheritsourcerect="true" canbehiddenbyotherwearables="false" sourcerect="0,0,683,264" origin="0.5,0.5" />
          <StatusEffect type="OnWearing" target="Character" HideFace="false" SpeedMultiplier="0.9" PropulsionSpeedMultiplier="0.8" setvalue="true" disabledeltatime="true">
            <TriggerAnimation Type="Walk" FileName="HumanWalkExosuit" priority="1" ExpectedSpecies="Human" />
            <!-- high prio for run animation so e.g. affliction-based run animations won't make the character run faster -->
            <TriggerAnimation Type="Run" FileName="HumanRunExosuit" priority="10" ExpectedSpecies="Human" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" interval="0.9" disabledeltatime="true">
            <Affliction identifier="recoilstabilized" amount="1" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" Condition="-0.1" interval="1" disabledeltatime="true" targetslot="1" comparison="Or">
            <Conditional IsDead="false" />
            <RequiredItem items="divingsuitfuel" targetslot="1" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="0.6" setvalue="true" disabledeltatime="true">
            <Conditional Voltage="lte 0.5" />
          </StatusEffect>
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma" damagemultiplier="0.7" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="lacerations" damagemultiplier="0.85" damagesound="LimbArmor" deflectprojectiles="true" />
          <sound file="%ModDir%/Sounds/exogear.ogg" type="OnWearing" range="500.0" volumeproperty="Speed" volume="0.2" loop="true" frequencymultiplier="0.8" />
          <StatValue stattype="FlowResistance" value="0.9" />
        </Wearable>
        <Holdable slots="RightHand+LeftHand" controlpose="true" holdpos="20,-80" handle1="-10,0" handle2="10,0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use" />
        <ItemContainer capacity="0" hideitems="true" containedstateindicatorslot="1">
          <SlotIcon slotindex="1" texture="Content/UI/StatusMonitorUI.png" sourcerect="192,448,64,64" origin="0.5,0.5" />
          <SlotIcon slotindex="0" texture="Content/UI/MainIconsAtlas.png" sourcerect="660,390,224,105" origin="0.5,0.5" />
          <StatusEffect type="OnWearing" target="Contained" targetslot="1" playsoundonrequireditemfailure="true">
            <RequiredItem items="reactorfuel" type="Contained" targetslot="1" matchonempty="true" />
            <Conditional condition="lte 0.0" />
            <Sound file="Content/Items/WarningBeep.ogg" frequencymultiplier="0.6" range="200" loop="true" />
          </StatusEffect>
          <SubContainer capacity="1" maxstacksize="1">
            <Containable items="largeitem,mediumitem,crate,railgunammo,ammobox,deepdiving,operatingtable" />
          </SubContainer>
          <SubContainer capacity="1" maxstacksize="1">
            <Containable items="reactorfuel" excludeditems="oxygensource,oxygentank,weldingfueltank,turbineoxygentank,generatorfuel">
              <StatusEffect type="OnContaining" target="This,Character" Voltage="1.0" setvalue="true">
                <Conditional IsDead="false" />
              </StatusEffect>
            </Containable>
          </SubContainer>
          <SubContainer capacity="2">
            <Containable items="smallitem" />
          </SubContainer>
        </ItemContainer>
        <aitarget maxsightrange="1500" />
      </Item>]])
  },
  -- Tweak fabrication recipe
  -- Deconstruct is left at '1 steel'
  ["sgt_toolbox"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="fabricator" requiredtime="40">
            <RequiredSkill identifier="mechanical" level="80" />
            <RequiredSkill identifier="electrical" level="80" />
            <Item identifier="iron" amount="4" />
            <Item identifier="steel" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_renegadeuniform"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_renegadecombatmedicuniform"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_securityvest"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="scp_riotvest" />
            <RequiredItem identifier="ballisticfiber" />
            <RequiredItem identifier="organicfiber" amount="4" />
            <RequiredItem identifier="plastic" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_tachelm"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="90">
            <RequiredSkill identifier="weapons" level="80" />
            <RequiredItem identifier="scp_combathelmet" />
            <RequiredItem identifier="thermalgoggles" />
            <RequiredItem identifier="steel" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["sgt_shield"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="steel" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_hpc"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_chemthrowerspitter"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Tweak fabrication recipe
  ["sgt_chemthrower"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" requiresrecipe="false">
            <RequiredSkill identifier="mechanical" level="40" />
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="6" />
            <RequiredItem identifier="scp_durasteel" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_gunslinger"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_rifle"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Make it give you eye damage like a welding tool
  ["sgt_sealingtool"] = {
    mod = "Enhanced Armaments Fuel for the Fire Expansion",
    componentOverrides = {
      {
        targetComponent = "repairtool",
        override = XElement.Parse([[
        <RepairTool firedamage="20.0" structurefixamount="1.0" range="40" barrelpos="27,4" particles="weld" repairmultiple="true" repairthroughwalls="false" combatpriority="3" levelwallfixamount="-0.425" targetforce="10">
          <RequiredItems items="weldingtoolfuel,oxygensource" type="Contained" msg="ItemMsgWeldingFuelRequired" />
          <RequiredSkill identifier="mechanical" level="50" />
          <ParticleEmitter particle="weld" scalemin="0.3" scalemax="0.3" particlespersecond="50" copyentityangle="true" />
          <ParticleEmitterHitStructure particle="weldspark" particlespersecond="200" scalemin="1.2" scalemax="1.4" anglemin="-65" anglemax="65" velocitymin="200" velocitymax="800" />
          <ParticleEmitterHitStructure particle="GlowDot" particlespersecond="60" emitinterval="0.7" particleamount="10" scalemin="1.2" scalemax="1.5" anglemin="0" anglemax="360" velocitymin="10" velocitymax="50" />
          <ParticleEmitterHitStructure particle="MistSmoke" particlespersecond="20" anglemin="-10" anglemax="10" velocitymin="0" velocitymax="50" />
          <ParticleEmitterHitItem identifiers="door,hatch,ductblock" particle="weldspark" particlespersecond="200" scalemin="1.2" scalemax="1.4" anglemin="-65" anglemax="65" velocitymin="200" velocitymax="800" />
          <ParticleEmitterHitItem identifiers="door,hatch,ductblock" particle="GlowDot" particlespersecond="60" emitinterval="0.7" particleamount="10" scalemin="1.2" scalemax="1.5" anglemin="0" anglemax="360" velocitymin="10" velocitymax="50" />
          <ParticleEmitterHitItem identifiers="door,hatch,ductblock" particle="MistSmoke" particlespersecond="20" anglemin="-10" anglemax="10" velocitymin="10" velocitymax="100" />
          <ParticleEmitterHitCharacter particle="fleshsmoke" particlespersecond="3" anglemin="-5" anglemax="5" velocitymin="0" velocitymax="50" />
          <sound file="Content/Items/Tools/WeldingLoop.ogg" type="OnUse" range="500.0" loop="true" frequencymultiplier="1.2" />
          <StatusEffect type="OnUse" target="UseTarget" comparison="or">
            <Conditional entitytype="eq structure" />
            <Conditional hastag="eq weldable" />
            <sound file="Content/Items/Tools/Extinguisher.ogg" type="OnUse" range="500.0" volume="0.35" loop="true" frequencymultiplier="0.7" />
          </StatusEffect>
          <StatusEffect type="OnUse" targettype="Contained" targets="weldingfueltank" Condition="-2.5" />
          <StatusEffect type="OnUse" targettype="Contained" targets="incendiumfueltank" Condition="-1.5" />
          <StatusEffect type="OnSuccess" targettype="UseTarget" targets="weldable" Stuck="40.0" />
          <StatusEffect type="OnSuccess" targettype="UseTarget" targets="item" Condition="-3.0">
            <Conditional HasTag="neq weldable" />
          </StatusEffect>
          <StatusEffect type="OnSuccess" targettype="Limb">
            <Affliction identifier="burn" amount="7.5" />
          </StatusEffect>

          <!-- Welder's Eye -->
          <StatusEffect type="OnSuccess" targettype="Limb" targetlimb="Head">
            <Affliction identifier="welderseye" amount="10.0" />
          </StatusEffect>
          <StatusEffect type="OnUse" target="Character" targetlimb="Head" comparison="And">
            <Conditional HasStatusTag="neq hasweldingmask" />
            <Conditional IsPlayer="true" />
            <Affliction identifier="burn" amount="10" probability="0.1" />
            <Affliction identifier="welderseye" amount="10" />
          </StatusEffect>

          <!-- Fixfoam -->
          <StatusEffect type="OnUse" target="NearbyItems" targettags="fixfoam" range="85">
            <Sound file="Content/Sounds/Damage/Gore1.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore2.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore3.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore4.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore5.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore6.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore7.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore8.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore9.ogg" range="300" selectionmode="random" />
            <Sound file="Content/Sounds/Damage/Gore10.ogg" range="300" selectionmode="random" />
            <Remove />
          </StatusEffect>

          <StatusEffect type="OnUse" targettype="Contained" targets="oxygentank" delay="1.0" stackable="false" Condition="0" setvalue="true">
            <sound file="Content/Items/Weapons/ExplosionSmall1.ogg" range="2000" />
            <sound file="Content/Items/Weapons/ExplosionSmall2.ogg" range="2000" />
            <sound file="Content/Items/Weapons/ExplosionSmall3.ogg" range="2000" />
            <Explosion range="150.0" force="3" applyfireeffects="false">
              <Affliction identifier="burn" strength="25" />
              <Affliction identifier="stun" strength="5" />
            </Explosion>
          </StatusEffect>
          <StatusEffect type="OnUse" targettype="Contained" targets="oxygenitetank" delay="1.0" stackable="false" Condition="0" setvalue="true">
            <sound file="Content/Items/Weapons/ExplosionSmall1.ogg" range="2000" />
            <sound file="Content/Items/Weapons/ExplosionSmall2.ogg" range="2000" />
            <sound file="Content/Items/Weapons/ExplosionSmall3.ogg" range="2000" />
            <Explosion range="150.0" force="6" applyfireeffects="false">
              <Affliction identifier="burn" strength="50" />
              <Affliction identifier="stun" strength="10" />
            </Explosion>
          </StatusEffect>
          <Fixable identifier="structure" />
          <NonFixable identifier="thalamus,ice" />
          <LightComponent LightColor="255,229,178,100" Range="150" Flicker="0.5">
            <sprite texture="Content/Items/Electricity/lightsprite.png" origin="0.5,0.5" />
          </LightComponent>
        </RepairTool>]])
      },
    },
  },

  -- ******************
  -- Enhanced Armaments
  -- ******************
  -- 1. Add tags to become every EHA fabricator
  -- 2. Change fabrication speed to normal
  ["scp_weaponfabricator"] = {
    mod = "Enhanced Armaments",
    xml = XElement.Parse([[
      <Item name="" identifier="scp_weaponfabricator" tags="weaponfabricator,ammofabricator,reloadfabricator,advweaponfabricator,chemstation,radiationshielding,donttakeitems" category="Machine" linkable="true" allowedlinks="deconstructor,locker" description="" scale="0.5" damagedbyexplosions="true" explosiondamagemultiplier="0.2">
        <Upgrade gameversion="0.10.4.0">
          <Repairable Msg="ItemMsgRepairWrench" />
        </Upgrade>
        <UpgradePreviewSprite scale="2.5" texture="Content/UI/WeaponUI.png" sourcerect="256,960,64,64" origin="0.5,0.45" />
        <Sprite name="wepfabnormal" texture="%ModDir%/Misc/fabricators.png" sourcerect="4,423,336,361" depth="0.8" origin="0.5,0.5" />
        <BrokenSprite name="wepfabdamage1" texture="%ModDir%/Misc/fabricators.png" sourcerect="340,422,336,361" depth="0.8" maxcondition="80" fadein="true" origin="0.5,0.5" />
        <BrokenSprite name="wepfabdamage2" texture="%ModDir%/Misc/fabricators.png" sourcerect="676,422,335,361" depth="0.8" maxcondition="0" origin="0.5,0.5" />
        <LightComponent range="10.0" lightcolor="255,255,255,0" powerconsumption="5" IsOn="true" castshadows="false" allowingameediting="false">
          <sprite texture="Content/Items/Command/navigatorLights.png" depth="0.025" sourcerect="351,624,336,400" alpha="1.0" />
        </LightComponent>
        <LightComponent range="10.0" lightcolor="255,255,255,0" powerconsumption="5" IsOn="true" castshadows="false" blinkfrequency="1" allowingameediting="false">
          <sprite texture="Content/Items/Command/navigatorLights.png" depth="0.025" sourcerect="688,624,336,400" alpha="1.0" />
        </LightComponent>
        <Fabricator canbeselected="true" powerconsumption="500.0" msg="ItemMsgInteractSelect" fabricationspeed="1">
          <GuiFrame relativesize="0.4,0.45" style="ItemUI" anchor="Center" />
          <sound file="Content/Items/Fabricators/Fabricator.ogg" type="OnActive" range="1000.0" loop="true" />
          <poweronsound file="Content/Items/PowerOnLight1.ogg" range="600" loop="false" />
          <StatusEffect type="InWater" target="This" condition="-0.5" />
        </Fabricator>
        <ConnectionPanel selectkey="Action" canbeselected="true" hudpriority="10" msg="ItemMsgRewireScrewdriver">
          <GuiFrame relativesize="0.2,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
          <RequiredSkill identifier="electrical" level="55" />
          <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand">
            <Sound file="Content/Sounds/Damage/Electrocution1.ogg" range="1000" />
            <Explosion range="100.0" stun="0" force="5.0" flames="false" shockwave="false" sparks="true" underwaterbubble="false" />
            <Affliction identifier="stun" strength="4" />
            <Affliction identifier="burn" strength="5" />
          </StatusEffect>
          <RequiredItem items="screwdriver" type="Equipped" />
          <input name="power_in" displayname="connection.powerin" />
          <output name="condition_out" displayname="connection.conditionout" />
        </ConnectionPanel>
        <Repairable selectkey="Action" header="mechanicalrepairsheader" deteriorationspeed="0.50" mindeteriorationdelay="60" maxdeteriorationdelay="120" RepairThreshold="80" fixDurationHighSkill="5" fixDurationLowSkill="25" msg="ItemMsgRepairWrench" hudpriority="10">
          <GuiFrame relativesize="0.2,0.16" minsize="400,180" maxsize="480,280" anchor="Center" relativeoffset="0.1,0.27" style="ItemUI" />
          <RequiredSkill identifier="mechanical" level="55" />
          <RequiredItem items="wrench" type="Equipped" />
          <ParticleEmitter particle="damagebubbles" particleburstamount="2" particleburstinterval="2.0" particlespersecond="2" scalemin="0.5" scalemax="1.5" anglemin="0" anglemax="359" velocitymin="-10" velocitymax="10" mincondition="0.0" maxcondition="50.0" />
          <ParticleEmitter particle="smoke" particleburstamount="3" particleburstinterval="0.5" particlespersecond="2" scalemin="1" scalemax="2.5" anglemin="0" anglemax="359" velocitymin="-50" velocitymax="50" mincondition="15.0" maxcondition="50.0" />
          <ParticleEmitter particle="heavysmoke" particleburstinterval="0.25" particlespersecond="2" scalemin="2.5" scalemax="5.0" mincondition="0.0" maxcondition="15.0" />
          <StatusEffect type="OnFailure" target="Character" targetlimbs="LeftHand,RightHand">
            <Sound file="Content/Items/MechanicalRepairFail.ogg" range="1000" />
            <Affliction identifier="lacerations" strength="5" />
            <Affliction identifier="stun" strength="4" />
          </StatusEffect>
        </Repairable>
        <ItemContainer capacity="5" canbeselected="true" hideitems="true" slotsperrow="5" uilabel="" allowuioverlap="true" />
        <ItemContainer capacity="1" canbeselected="true" hideitems="true" slotsperrow="1" uilabel="" allowuioverlap="true" />
      </Item>]])
  },
  -- Remove all fabricators besides the weapon fabricator
  ["scp_reloadfabricator"] = { mod = "Enhanced Armaments", xml = "" },
  ["scp_ammofabricator"] = { mod = "Enhanced Armaments", xml = "" },
  ["scp_portableammofabricator"] = { mod = "Enhanced Armaments", xml = "" },
  ["scp_portableweaponfabricator"] = { mod = "Enhanced Armaments", xml = "" },
  ["scp_advportableweaponfabricator"] = { mod = "Enhanced Armaments", xml = "" },
  ["scp_chemistrystation"] = { mod = "Enhanced Armaments", xml = "" },

  ["scp_portablejunctionbox"] = { mod = "Enhanced Armaments", xml = "" },

  -- Integrate IDG
  ["scp_renegadedivingsuit"] = {
    mod = "Enhanced Armaments",
    xml = XElement.Parse([[
      <Item name="Renegade Diving Suit" descriptionidentifier="mm_renegadedivingsuit" identifier="scp_renegadedivingsuit" category="Diving,Equipment" tags="diving,deepdiving,human" scale="0.5" fireproof="true" description="" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy" botpriority="1" hideinmenus="true">
        <Price baseprice="500" soldeverywhere="false" />
        <PreferredContainer primary="divingsuitcontainer" />
        <Deconstruct time="30">
          <Item identifier="ballisticfiber" />
          <Item identifier="steel" />
          <Item identifier="rubber" />
        </Deconstruct>
        <!--<Fabricate suitablefabricators="fabricator" requiredtime="35">
          <RequiredSkill identifier="mechanical" level="50" />
          <RequiredItem identifier="divingsuit" />
          <RequiredItem identifier="ballisticfiber" />
          <RequiredItem identifier="steel" amount="2" />
          <RequiredItem identifier="plastic" />
        </Fabricate>-->
        <InventoryIcon name="renegadesuitinv" texture="%ModDir%/Jobgear/renegadesuititems.png" sourcerect="358,0,94,87" origin="0.5,0.5" />
        <Sprite name="Renegade Diving Suit Item" texture="%ModDir%/Jobgear/renegadesuititems.png" sourcerect="0,0,157,121" depth="0.55" origin="0.5,0.5" />
        <Body radius="45" width="34" density="15" />
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0">
          <StatusEffect type="OnWearing" target="This,Character" interval="0.2" duration="0.2" OxygenAvailable="-100.0" UseHullOxygen="false" comparison="And">
            <Conditional HasStatusTag="eq sealed" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" SpeedMultiplier="0.6" setvalue="true" interval="0.2" duration="0.2" disabledeltatime="true" />
          <StatusEffect type="OnContained" target="Contained" targetslot="0" Condition="1.0" interval="1" disabledeltatime="true">
            <Conditional Voltage="gt 0.01" targetcontainer="true" targetgrandparent="true" targetitemcomponent="Powered" />
            <RequiredItem items="refillableoxygensource" type="Contained" excludebroken="false" excludefullcondition="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" OxygenAvailable="1000.0" Condition="-0.3" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="oxygensource" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="weldingfueltank" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetlimbs="Torso" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="incendiumfueltank" type="Contained" />
            <Affliction identifier="burn" amount="3.0" />
          </StatusEffect>
        </GreaterComponent>
        <Wearable slots="InnerClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select">
          <StatusEffect type="OnWearing" target="Character" tags="hassuit" interval="0.1" duration="0.2">
            <Conditional HasStatusTag="eq hashelmet" />
            <Affliction identifier="pressure5750" amount="1" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" comparison="And">
            <Conditional IsLocalPlayer="true" />
            <Conditional InWater="true" />
            <Sound file="%ModDir:3074045632%/Content/Items/Diving/SuitWaterAmbience.ogg" type="OnWearing" range="250" loop="true" volumeproperty="Speed" volume="0.8" frequencymultiplier="0.5" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This" setvalue="true" interval="0.9" comparison="And">
            <Conditional IsBot="true" targetcontainer="true" />
            <Conditional HasStatusTag="neq hashelmet" targetcontainer="true" />
            <SpawnItem identifier="botdivingsuithelmet" spawnposition="SameInventory" spawnifinventoryfull="false" spawnifcantbecontained="false" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" ObstructVision="true" tags="botsuit,sealed,hassuit" PressureProtection="5750.0" interval="0.1" duration="0.2" setvalue="true" disabledeltatime="true">
            <Conditional HasTag="bothelmet" targetcontaineditem="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" setvalue="true">
            <TriggerAnimation Type="Walk" FileName="HumanWalkDivingSuit" priority="1" ExpectedSpecies="Human" />
            <TriggerAnimation Type="Run" FileName="HumanRunDivingSuit" priority="1" ExpectedSpecies="Human" />
          </StatusEffect>
          <sprite name="Renegade Diving Suit Torso" texture="%ModDir%/Jobgear/renegadesuit.png" limb="Torso" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Hand" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Hand" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Lower Arm" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Lower Arm" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Upper Arm" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Upper Arm" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Waist" texture="%ModDir%/Jobgear/renegadesuit.png" limb="Waist" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Thigh" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Thigh" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Leg" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Leg" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Left Shoe" texture="%ModDir%/Jobgear/renegadesuit.png" limb="LeftFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="Renegade Diving Suit Right Shoe" texture="%ModDir%/Jobgear/renegadesuit.png" limb="RightFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma,bleeding" damagemultiplier="0.75" damagesound="armourmedimpact" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="gunshotwound" damagemultiplier="0.6" damagesound="armourmedimpact" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="explosiondamage" damagemultiplier="0.9" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="bitewounds,lacerations" damagemultiplier="0.85" damagesound="" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness,burn" damagemultiplier="0.8" damagesound="armourmedimpact" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="huskinfection" damagemultiplier="0.5" probabilitymultiplier="0.5" damagesound="armourmedimpact" />
        </Wearable>
        <Holdable slots="RightHand,LeftHand" controlpose="true" holdpos="0,-40" handle1="-10,-20" handle2="10,-20" holdangle="0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use">
          <Upgrade gameversion="0.1401.0.0" msg="ItemMsgPickUpUse" />
        </Holdable>
        <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
          <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="64,448,64,64" origin="0.5,0.5" />
          <Containable items="weldingtoolfuel" excludeditems="oxygenitetank" />
          <Containable items="oxygensource" excludeditems="oxygenitetank">
            <StatusEffect type="OnWearing" target="Contained">
              <RequiredItem items="oxygensource" type="Contained" />
              <Conditional condition="lt 5.0" />
              <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
            </StatusEffect>
          </Containable>
          <Containable items="oxygenitetank">
            <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="1.3" setvalue="true" targetslot="0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
            </StatusEffect>
          </Containable>
          <StatusEffect type="OnWearing" target="Contained" playsoundonrequireditemfailure="true">
            <RequiredItem items="oxygensource,weldingtoolfuel" type="Contained" matchonempty="true" />
            <Conditional condition="lte 0.0" />
            <Sound file="Content/Items/WarningBeep.ogg" range="250" loop="true" />
          </StatusEffect>
        </ItemContainer>
        <aitarget maxsightrange="1500" />
      </Item>]])
  },
  -- Integrate IDG
  ["scp_interceptorsuit"] = {
    mod = "Enhanced Armaments",
    xml = XElement.Parse([[
      <Item name="" identifier="scp_interceptorsuit" category="Diving,Equipment" tags="diving,deepdiving,human" scale="0.5" fireproof="true" description="" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy" botpriority="1" hideinmenus="true">
        <Deconstruct time="30">
          <Item identifier="scp_durasteel" />
          <Item identifier="dementonite" amount="3" />
        </Deconstruct>
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="45">
          <RequiredSkill identifier="mechanical" level="85" />
          <RequiredSkill identifier="weapons" level="75" />
          <RequiredItem identifier="slipsuit" />
          <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
          <RequiredItem identifier="scp_durasteel" amount="2" />
          <RequiredItem identifier="dementonite" amount="8" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/Jobgear/interceptsuit.png" sourcerect="517,2,74,77" origin="0.5,0.5" />
        <Sprite name="intercepsuit Suit Ground" texture="%ModDir%/Jobgear/interceptsuititems.png" sourcerect="0,9,157,121" depth="0.55" origin="0.5,0.5" />
        <ContainedSprite name="intercepsuit Suit In Vertical Locker" allowedcontainertags="divingsuitcontainervertical" texture="%ModDir%/Jobgear/interceptsuititems.png" sourcerect="174,0,70,192" depth="0.55" origin="0.5,0.5" />
        <ContainedSprite name="intercepsuit Suit Behind Window" allowedcontainertags="divingsuitcontainerwindow" texture="%ModDir%/Jobgear/interceptsuit.png" sourcerect="432,0,80,207" depth="0.55" origin="-0.12,-0.14" />
        <ContainedSprite name="intercepsuit Suit In Horizontal Locker" allowedcontainertags="divingsuitcontainerhorizontal" texture="%ModDir%/Jobgear/interceptsuititems.png" sourcerect="0,193,230,63" depth="0.55" origin="0.6,0.5" />
        <Body radius="45" width="34" density="20" />
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0">
          <StatusEffect type="OnWearing" target="This,Character" interval="0.2" duration="0.2" OxygenAvailable="-100.0" UseHullOxygen="false" comparison="And">
            <Conditional HasStatusTag="eq sealed" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" SpeedMultiplier="0.6" setvalue="true" interval="0.2" duration="0.2" disabledeltatime="true" />
          <StatusEffect type="OnContained" target="Contained" targetslot="0" Condition="1.0" interval="1" disabledeltatime="true">
            <Conditional Voltage="gt 0.01" targetcontainer="true" targetgrandparent="true" targetitemcomponent="Powered" />
            <RequiredItem items="refillableoxygensource" type="Contained" excludebroken="false" excludefullcondition="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" OxygenAvailable="1000.0" Condition="-0.3" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="oxygensource" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="weldingfueltank" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetlimbs="Torso" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="incendiumfueltank" type="Contained" />
            <Affliction identifier="burn" amount="3.0" />
          </StatusEffect>
        </GreaterComponent>
        <Wearable slots="InnerClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select">
          <StatusEffect type="OnWearing" target="Character" tags="hassuit" interval="0.1" duration="0.2">
            <Conditional HasStatusTag="eq hashelmet" />
            <Affliction identifier="pressure5750" amount="1" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" comparison="And">
            <Conditional IsLocalPlayer="true" />
            <Conditional InWater="true" />
            <Sound file="%ModDir:3074045632%/Content/Items/Diving/SuitWaterAmbience.ogg" type="OnWearing" range="250" loop="true" volumeproperty="Speed" volume="0.8" frequencymultiplier="0.5" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This" setvalue="true" interval="0.9" comparison="And">
            <Conditional IsBot="true" targetcontainer="true" />
            <Conditional HasStatusTag="neq hashelmet" targetcontainer="true" />
            <SpawnItem identifier="botdivingsuithelmet" spawnposition="SameInventory" spawnifinventoryfull="false" spawnifcantbecontained="false" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" ObstructVision="true" tags="botsuit,sealed,hassuit" PressureProtection="5750.0" interval="0.1" duration="0.2" setvalue="true" disabledeltatime="true">
            <Conditional HasTag="bothelmet" targetcontaineditem="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" setvalue="true">
            <TriggerAnimation Type="Walk" FileName="HumanWalkDivingSuit" priority="1" ExpectedSpecies="Human" />
            <TriggerAnimation Type="Run" FileName="HumanRunDivingSuit" priority="1" ExpectedSpecies="Human" />
          </StatusEffect>
          <sprite name="intercepsuit Suit Torso" texture="%ModDir%/Jobgear/interceptsuit.png" limb="Torso" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,680,256" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Hand" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Hand" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Lower Arm" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Lower Arm" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Upper Arm" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Upper Arm" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Waist" texture="%ModDir%/Jobgear/interceptsuit.png" limb="Waist" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Thigh" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Thigh" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Leg" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Leg" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Left Shoe" texture="%ModDir%/Jobgear/interceptsuit.png" limb="LeftFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <sprite name="intercepsuit Suit Right Shoe" texture="%ModDir%/Jobgear/interceptsuit.png" limb="RightFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" sourcerect="0,0,0,0" origin="0.5,0.5" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="explosiondamage" damagemultiplier="0.75" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma,gunshotwound,bitewounds,lacerations,bleeding" damagemultiplier="0.6" damagesound="LimbArmor" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictiontypes="burn" damagemultiplier="0.5" damagesound="" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness" damagemultiplier="0.6" damagesound="LimbArmor" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="huskinfection" probabilitymultiplier="0.5" damagesound="LimbArmor" />
          <StatValue stattype="SwimmingSpeed" value="0.5" />
          <StatValue stattype="WalkingSpeed" value="-0.1" />
        </Wearable>
        <Holdable slots="RightHand,LeftHand" controlpose="true" holdpos="0,-40" handle1="-10,-20" handle2="10,-20" holdangle="0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use">
          <Upgrade gameversion="0.1401.0.0" msg="ItemMsgPickUpUse" />
        </Holdable>
        <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
          <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="64,448,64,64" origin="0.5,0.5" />
          <Containable items="weldingtoolfuel" excludeditems="oxygenitetank" />
          <Containable items="oxygensource" excludeditems="oxygenitetank">
            <StatusEffect type="OnWearing" target="Contained">
              <RequiredItem items="oxygensource" type="Contained" />
              <Conditional condition="lt 5.0" />
              <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
            </StatusEffect>
          </Containable>
          <Containable items="oxygenitetank">
            <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="1.3" setvalue="true" targetslot="0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
            </StatusEffect>
          </Containable>
          <StatusEffect type="OnWearing" target="Contained" playsoundonrequireditemfailure="true">
            <RequiredItem items="oxygensource,weldingtoolfuel" type="Contained" matchonempty="true" />
            <Conditional condition="lte 0.0" />
            <Sound file="Content/Items/WarningBeep.ogg" range="250" loop="true" />
          </StatusEffect>
        </ItemContainer>
        <aitarget maxsightrange="1500" />
      </Item>]])
  },
  -- #TODO#: can't figure out how to make it use batteries and change the character's speed based on the batteries
  -- 1. Integrate IDG
  -- 2. Override description
  ["scp_combathardsuit"] = {
    mod = "Enhanced Armaments",
    xml = XElement.Parse([[
      <Item name="" descriptionidentifier="mm_combathardsuit" identifier="scp_combathardsuit" description="" category="Diving" subcategory="Coalition" tags="diving,deepdiving,provocative,divingsuit" scale="0.5" fireproof="true" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy">
        <PreferredContainer primary="divingsuitcontainer" />
        <Price baseprice="4000" displaynonempty="true" minleveldifficulty="35">
          <Price storeidentifier="merchantoutpost" sold="false" multiplier="1.5" />
          <Price storeidentifier="merchantcity" multiplier="1.25" sold="false" />
          <Price storeidentifier="merchantresearch" sold="false" multiplier="1.25" />
          <Price storeidentifier="merchantmilitary" multiplier="0.95" minavailable="0" maxavailable="1">
            <Reputation faction="coalition" min="100" />
          </Price>
          <Price storeidentifier="merchantmine" sold="false" multiplier="1.25" />
          <Price storeidentifier="merchantarmory" multiplier="0.95" minavailable="0" maxavailable="1">
            <Reputation faction="coalition" min="100" />
          </Price>
        </Price>
        <PreferredContainer primary="divingsuitcontainer" />
        <Deconstruct time="30">
          <Item identifier="scp_durasteel" amount="2" />
          <Item identifier="titaniumaluminiumalloy" amount="2" />
          <Item identifier="rubber" amount="2" />
        </Deconstruct>
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="60">
          <RequiredSkill identifier="mechanical" level="65" />
          <RequiredSkill identifier="weapons" level="75" />
          <RequiredItem identifier="abyssdivingsuit" />
          <RequiredItem identifier="titaniumaluminiumalloy" amount="4" />
          <RequiredItem identifier="scp_durasteel" amount="8" />
          <RequiredItem identifier="rubber" amount="6" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/jobgear/combathardsuititems.png" sourcerect="312,0,109,107" origin="0.5,0.5" />
        <Sprite name="combathardsuit Item" texture="%ModDir%/jobgear/combathardsuititems.png" sourcerect="0,0,157,121" depth="0.55" origin="0.5,0.5" />
        <ContainedSprite name="combathardsuit In Vertical Locker" allowedcontainertags="divingsuitcontainervertical" texture="%ModDir%/jobgear/combathardsuititems.png" sourcerect="181,0,70,192" depth="0.55" origin="0.5,0.5" />
        <ContainedSprite name="combathardsuit Behind Window" allowedcontainertags="divingsuitcontainerwindow" texture="%ModDir%/jobgear/combathardsuititems.png" sourcerect="553,0,77,214" depth="0.55" origin="-0.12,-0.13" />
        <ContainedSprite name="combathardsuit In Horizontal Locker" allowedcontainertags="divingsuitcontainerhorizontal" texture="%ModDir%/jobgear/combathardsuititems.png" sourcerect="0,193,230,63" depth="0.55" origin="0.6,0.5" />
        <Body radius="45" width="34" density="15" />
        <GreaterComponent canbeselected="false" canbepicked="false" allowingameediting="false" timeframe="0">
          <StatusEffect type="OnWearing" target="This,Character" interval="0.2" duration="0.2" OxygenAvailable="-100.0" UseHullOxygen="false" comparison="And">
            <Conditional HasStatusTag="eq sealed" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="Contained" targetslot="0" Condition="1.0" interval="1" disabledeltatime="true">
            <Conditional Voltage="gt 0.01" targetcontainer="true" targetgrandparent="true" targetitemcomponent="Powered" />
            <RequiredItem items="refillableoxygensource" type="Contained" excludebroken="false" excludefullcondition="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" OxygenAvailable="1000.0" Condition="-0.3" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="oxygensource" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="weldingfueltank" type="Contained" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Contained,Character" targetlimbs="Torso" targetslot="0" Oxygen="-10.0" Condition="-0.5" interval="1" disabledeltatime="true" comparison="And">
            <Conditional IsDead="false" />
            <Conditional HasStatusTag="eq sealed" />
            <RequiredItem items="incendiumfueltank" type="Contained" />
            <Affliction identifier="burn" amount="3.0" />
          </StatusEffect>
        </GreaterComponent>
        <Wearable slots="InnerClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select">
          <sprite name="combathardsuit Torso" texture="combathardsuit.png" limb="Torso" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Hand" texture="combathardsuit.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Hand" texture="combathardsuit.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Lower Arm" texture="combathardsuit.png" limb="RightArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Lower Arm" texture="combathardsuit.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Upper Arm" texture="combathardsuit.png" limb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Upper Arm" texture="combathardsuit.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Waist" texture="combathardsuit.png" limb="Waist" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Thigh" texture="combathardsuit.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Thigh" texture="combathardsuit.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Leg" texture="combathardsuit.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Leg" texture="combathardsuit.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Left Shoe" texture="combathardsuit.png" limb="LeftFoot" sound="heavysuitfootstep" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <sprite name="combathardsuit Right Shoe" texture="combathardsuit.png" limb="RightFoot" sound="heavysuitfootstep" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
          <StatusEffect type="OnWearing" target="Character" tags="hassuit" interval="0.1" duration="0.2">
            <Conditional HasStatusTag="eq hashelmet" />
            <Affliction identifier="pressure6650" amount="1" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" interval="0.9" disabledeltatime="true">
            <Affliction identifier="recoilstabilized" amount="1" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" comparison="And">
            <Conditional IsLocalPlayer="true" />
            <Conditional InWater="true" />
            <Sound file="%ModDir:3074045632%/Content/Items/Diving/SuitWaterAmbience.ogg" type="OnWearing" range="250" loop="true" volumeproperty="Speed" volume="0.8" frequencymultiplier="0.5" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="This" setvalue="true" interval="0.9" comparison="And">
            <Conditional IsBot="true" targetcontainer="true" />
            <Conditional HasStatusTag="neq hashelmet" targetcontainer="true" />
            <SpawnItem identifier="botdivingsuithelmet" spawnposition="SameInventory" spawnifinventoryfull="false" spawnifcantbecontained="false" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" ObstructVision="true" tags="botsuit,sealed,hassuit" PressureProtection="6650.0" interval="0.1" duration="0.2" setvalue="true" disabledeltatime="true">
            <Conditional HasTag="bothelmet" targetcontaineditem="true" />
          </StatusEffect>
          <StatusEffect type="OnWearing" target="Character" setvalue="true">
            <TriggerAnimation Type="Walk" FileName="HumanWalkDivingSuit" priority="1" ExpectedSpecies="Human" />
            <TriggerAnimation Type="Run" FileName="HumanRunDivingSuit" priority="1" ExpectedSpecies="Human" />
          </StatusEffect>
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="lacerations,blunttrauma" damagemultiplier="0.1" damagesound="armourheavyimpact" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="gunshotwound,bleeding,explosiondamage,burn" damagemultiplier="0.25" damagesound="armourheavyimpact" deflectprojectiles="true" />
          <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="radiationsickness,bitewounds,stun" damagemultiplier="0.5" damagesound="armourheavyimpact" />
          <sound file="Content/Items/Weapons/WEAPONS_chargeUp.ogg" type="OnWearing" range="500.0" volumeproperty="Speed" volume="0.15" loop="true" frequencymultiplier="0.75" />
          <SkillModifier skillidentifier="weapons" skillvalue="-10" />
          <SkillModifier skillidentifier="mechanical" skillvalue="-50" />
          <SkillModifier skillidentifier="electrical" skillvalue="-75" />
        </Wearable>
        <Holdable slots="RightHand,LeftHand" controlpose="true" holdpos="0,-40" handle1="-10,-20" handle2="10,-20" holdangle="0" msg="ItemMsgPickUpUse" canbeselected="false" canbepicked="true" pickkey="Use">
          <Upgrade gameversion="0.1401.0.0" msg="ItemMsgPickUpUse" />
        </Holdable>
        <ItemContainer capacity="1" maxstacksize="1" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
          <SlotIcon slotindex="0" texture="Content/UI/ContainerIndicators.png" sourcerect="1,93,120,29" origin="0.5,0.45" />
          <SlotIcon slotindex="1" texture="Content/UI/ContainerIndicators.png" sourcerect="2,184,120,32" origin="0.5,0.5" />
          <Containable items="weldingtoolfuel" excludeditems="oxygenitetank" />
          <Containable items="oxygensource" excludeditems="oxygenitetank">
            <StatusEffect type="OnWearing" target="Contained">
              <RequiredItem items="oxygensource" type="Contained" />
              <Conditional condition="lt 5.0" />
              <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
            </StatusEffect>
          </Containable>
          <Containable items="oxygenitetank">
            <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="1.3" setvalue="true" targetslot="0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional HasStatusTag="eq sealed" />
            </StatusEffect>
          </Containable>
          <StatusEffect type="OnWearing" target="Contained" playsoundonrequireditemfailure="true">
            <RequiredItem items="oxygensource,weldingtoolfuel" type="Contained" matchonempty="true" />
            <Conditional condition="lte 0.0" />
            <Sound file="Content/Items/WarningBeep.ogg" range="250" loop="true" />
          </StatusEffect>
        </ItemContainer>
        <aitarget maxsightrange="1500" />
      </Item>]])
  },
  -- Change fabricator to weapon fabricator
  ["syringegun"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredSkill identifier="medical" level="50" />
            <RequiredItem identifier="aluminium" amount="2" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["shotgunshellblunt"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" amount="6">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="magnesium" />
            <RequiredItem identifier="rubber" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo fabricator
  ["shotgunshell"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="12">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo fabricator
  ["shotgunslugexplosive"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="10" requiresrecipe="true" amount="6">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="plastic" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem identifier="incendium" />
            <RequiredItem identifier="uex" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["40mmgrenade"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="10">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem identifier="uex" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["chemgrenade"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" amount="2" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="iron" amount="2" />
            <RequiredItem identifier="sulphuricacid" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo / reload
  ["scp_556extmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="4" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="4" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="4" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="20">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="scp_556extmag" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="4" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="4" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="4" />
          </Fabricate>]])
      }
    },
  },
  -- Change fabricator to ammo / reload
  ["scp_556mag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30" amount="3">
            <RequiredSkill identifier="weapons" level="45" />
            <RequiredItem identifier="plastic" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="3" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="3" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="5" amount="3">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="55630mag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" amount="3" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="3" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="3" />
          </Fabricate>]])
      }
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_baton"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="rubber" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["rifle"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="60" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only weapon fabricator
  ["scp_p226"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
          <RequiredSkill identifier="weapons" level="15" />
          <RequiredItem identifier="scp_pistolkit" mincondition="0.1" />
          <RequiredItem identifier="steel" />
          <RequiredItem identifier="plastic" amount="2" />
        </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only weapon fabricator
  ["scp_smg9"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="scp_pistolkit" mincondition="0.5" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="steel" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_m9bayonet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="12">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="divingknife" />
            <RequiredItem identifier="titanium" amount="2" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
    },
  },
  -- Tweak fabrication / deconstruction recipe
  ["scp_val"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="scp_sg550" amount="1" />
            <RequiredItem identifier="steel" amount="3" />
            <RequiredItem identifier="rubber" amount="3" />
          </Fabricate>]])
      },
      {
        targetComponent = "deconstruct",
        override = XElement.Parse([[
          <Deconstruct time="15">
            <Item identifier="steel" amount="2" />
            <Item identifier="rubber" />
          </Deconstruct>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["scp_valextmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
        <Fabricate suitablefabricators="ammofabricator" requiredtime="30">
          <RequiredSkill identifier="weapons" level="35" />
          <RequiredItem identifier="plastic" amount="2" />
          <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
          <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
          <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
        </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="12" amount="1">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="scp_valextmag" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo fabricator
  ["scp_duspear"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
        <Fabricate suitablefabricators="ammofabricator" requiredtime="30" amount="3">
          <RequiredSkill identifier="weapons" level="20" />
          <RequiredItem identifier="steel" />
          <RequiredItem identifier="depletedfuel" />
        </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_dementonitemachete"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="60" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="dementonite" amount="2" />
            <RequiredItem identifier="scp_machete" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["autoshotgun"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="65" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredItem identifier="scp_m4s90" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="3" />
            <RequiredItem identifier="steel" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["fraggrenade"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="60" />
            <RequiredItem identifier="iron" amount="2" />
            <RequiredItem identifier="uex" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["spear"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="3">
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="steel" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["harpooncoilrifle"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="harpoongun" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="copper" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["harpoongun"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["scp_45incendmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="24" amount="2">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="scp_45mag" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="scp_firelatex" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="12" amount="2">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="4510mag" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="scp_firelatex" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" mincondition="0.5" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["scp_45mag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" amount="3">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="plastic" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="5" amount="3">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="4510mag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" amount="3" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["scp_umpincendmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30" amount="2">
            <RequiredSkill identifier="weapons" level="45" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="scp_firelatex" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="15" amount="2">
            <RequiredSkill identifier="weapons" level="45" />
            <RequiredItem tag="ump45mag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" usecondition="false" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="scp_firelatex" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["scp_umpmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30" amount="2">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="plastic" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="15" amount="2">
            <RequiredSkill identifier="weapons" level="37" />
            <RequiredItem tag="ump45mag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" amount="2" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["incendiumgrenade"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" amount="2">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="iron" amount="2" />
            <RequiredItem identifier="incendium" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_cobaltstick"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_sledgeclown"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_machete"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="steel" amount="3" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_nuclearbomb"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="electrical" level="45" />
            <RequiredItem identifier="ic4block" />
            <RequiredItem identifier="uranium" amount="2" />
            <RequiredItem identifier="depletedfuel" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["alienspear"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10" amount="6">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="physicorium" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_physicoriumsword"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredItem identifier="physicorium" amount="6" />
            <RequiredItem identifier="dementonite" amount="4" />
            <RequiredItem identifier="scp_dementonitemachete" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo / reload
  ["scp_9mmmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="5">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="steel" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="3" amount="5">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="scp_9mmmag" mincondition="0.0" maxcondition="0.99" amount="5" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_aks74u"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_ak74m"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_ak74apmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_ak74extmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_ak74mag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_kh2020"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  --[[["scp_saiga12"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_saigaextmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_saigamag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },]]
  -- Remove fabrication recipe, for now
  ["sgt_m79"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_sr1"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_sr2"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_tabuk"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_akapmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_akdrummag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_akmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_mp443"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_g36"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe, for now
  ["scp_uzi"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["riflebullet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" requiresrecipe="true" amount="6">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
            <RequiredItem tag="advmunition_tip" description="fabricationdescription.advmunition_tip" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["scp_357round"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="25" amount="12">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_sledge"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="25">
            <RequiredSkill identifier="mechanical" level="45" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="steel" amount="3" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["stungrenade"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="phosphorus" amount="2" />
            <RequiredItem identifier="flashpowder" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only weapon / ammo
  ["scp_9mmsmgdrummag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="3" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="3" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="8" amount="1">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="scp_9mmsmgdrummag" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="3" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="3" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only weapon / ammo
  ["scp_9mmsmgmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem identifier="steel" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="8" amount="1">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="9mmsmgmag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_submissionbaton"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="15">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="stunbaton" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="copper" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["hmg"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="75" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="75" />
            <RequiredItem identifier="scp_mag" />
            <RequiredItem identifier="physicorium" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["hmgmagazine"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="35" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="magnesium" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem tag="advmunition_core" description="fabricationdescription.advmunition_core" amount="2" />
            <RequiredItem tag="advmunition_jacket" description="fabricationdescription.advmunition_jacket" amount="2" />
            <RequiredItem identifier="steel" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" displayname="recycleitem" requiredtime="8" amount="1">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="9mmsmgmag" excludeditems="sgt_gaugeset" mincondition="0.0" maxcondition="0.99" usecondition="false" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["shotgun"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["revolver"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["revolverround"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="12">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["revolverrounddepletedfuel"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" requiresrecipe="true" amount="12">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredSkill identifier="electrical" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" />
            <RequiredItem identifier="depletedfuel" amount="1" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["smgmagazinedepletedfuel"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="30" requiresrecipe="true" amount="2">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="electrical" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="depletedfuel" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
            <RequiredItem identifier="steel" amount="2" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" requiredtime="18" requiresrecipe="true" displayname="recycleitem" amount="2">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="electrical" level="30" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="2" />
            <RequiredItem identifier="depletedfuel" amount="2" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="2" />
            <RequiredItem tag="smgammo" mincondition="0.0" maxcondition="0.99" usecondition="false" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to only ammo / reload
  ["smgmagazine"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="15" amount="2">
            <RequiredSkill identifier="weapons" level="25" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="1" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="1" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="1" />
            <RequiredItem identifier="steel" amount="2" />
          </Fabricate>]])
      },
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="reloadfabricator" requiredtime="15" requiresrecipe="true" displayname="recycleitem" amount="2">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem tag="munition_propulsion" description="fabricationdescription.munition_propulsion" amount="1" />
            <RequiredItem tag="munition_core" description="fabricationdescription.munition_core" amount="1" />
            <RequiredItem tag="munition_jacket" description="fabricationdescription.munition_jacket" amount="1" />
            <RequiredItem tag="smgammo" mincondition="0.0" maxcondition="0.99" usecondition="false" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["smg"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredItem identifier="plastic" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["handcannon"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50" requiresrecipe="true">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="helm" level="100" />
            <RequiredItem identifier="scp_rsh12" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="4" />
            <RequiredItem identifier="dementonite" amount="6" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to ammo fabricator
  ["handcannonround"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="ammofabricator" requiredtime="20" requiresrecipe="true" amount="6">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="helm" level="90" />
            <RequiredItem identifier="flashpowder" amount="4" />
            <RequiredItem identifier="physicorium" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_specialrig"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredItem identifier="scp_heavyrig" />
            <RequiredItem identifier="ballisticfiber" amount="4" />
            <RequiredItem identifier="physicorium" amount="4" />
            <RequiredItem identifier="scp_durasteel" amount="8" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_cbrnhelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="25">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredItem identifier="ballistichelmet1" />
            <RequiredItem identifier="scp_hardeneddivingmask" />
            <RequiredItem identifier="rubber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["ballistichelmet1"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="25">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="plastic" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_cbrnsuit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="scp_lightuniform" />
            <RequiredItem identifier="rubber" amount="4" />
            <RequiredItem identifier="lead" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_lightuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="25" />
            <Item identifier="ballisticfiber" />
            <Item identifier="organicfiber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_heavyuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="40" />
            <Item identifier="scp_lightuniform" />
            <Item identifier="ballisticfiber" amount="3" />
            <Item identifier="titaniumaluminiumalloy" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_heavyrig"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredItem identifier="scp_heavyvest" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
            <RequiredItem identifier="organicfiber" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_heavycombathelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="45">
            <RequiredSkill identifier="weapons" level="70" />
            <RequiredItem identifier="scp_combathelmet" />
            <RequiredItem identifier="ballisticfiber" amount="4" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_heavyvest"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredItem identifier="bodyarmor" />
            <RequiredItem identifier="ballisticfiber" amount="4" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["bodyarmor"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="ballisticfiber" amount="3" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
            <RequiredItem identifier="steel" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_heavypack"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredItem identifier="scp_fieldpack" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="organicfiber" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_combathelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="25">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredItem identifier="ballistichelmet1" />
            <RequiredItem identifier="ballisticfiber" amount="4" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_combatmedicuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredSkill identifier="medical" level="60" />
            <Item identifier="doctorsuniform1" />
            <Item identifier="ballisticfiber" amount="3" />
            <Item identifier="organicfiber" amount="6" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_leadbox"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="mechanical" level="45" />
            <Item identifier="toolbox" />
            <Item identifier="lead" amount="3" />
            <Item identifier="rubber" amount="3" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_batoncontra"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_contrabandcontainer"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_crowbar"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_fuelrodbomb"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_welrod"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_shiv"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_contrawelder"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["ballistichelmet2"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_clownbatmask"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_clownbatuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_simplehelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_liquidatorsuit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35">
            <RequiredSkill identifier="mechanical" level="50" />
            <RequiredSkill identifier="electrical" level="85" />
            <Item identifier="scp_cbrnsuit" />
            <Item identifier="scp_durasteel" amount="2" />
            <Item identifier="lead" amount="8" />
            <Item identifier="dementonite" amount="8" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_pipebomb"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_protopack"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="75" />
            <RequiredItem identifier="scp_prototypeusb" />
            <RequiredItem identifier="scp_heavypack" />
            <RequiredItem identifier="scp_durasteel" amount="3" />
            <RequiredItem identifier="dementonite" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadehelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_heavyhazmatuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadecaptainuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadecombatmedicuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadecaptainhat"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadeuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_heavyrenuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadeheavyhelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadeplatecarrier"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe (Renegade Heavy Plate Carrier)
  ["piratebodyarmor"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadevest"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_renegadespecialrig"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["ballistichelmet3"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="ballisticfiber" />
            <RequiredItem identifier="rubber" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_riotvest"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="15">
            <RequiredSkill identifier="weapons" level="20" />
            <RequiredItem identifier="ballisticfiber" />
            <RequiredItem identifier="rubber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_softvest"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="35" />
            <RequiredItem identifier="ballisticfiber" />
            <RequiredItem identifier="carbon" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_explosiveskit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredSkill identifier="mechanical" level="55" />
            <RequiredItem identifier="scp_riflekit" />
            <RequiredItem identifier="scp_durasteel" />
            <RequiredItem identifier="dementonite" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_machinegunkit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="mechanical" level="50" />
            <RequiredItem identifier="scp_riflekit" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="scp_durasteel" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_pistolkit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20">
            <RequiredSkill identifier="weapons" level="30" />
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="plastic" amount="2" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="ballisticfiber" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_sniperkit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="55" />
            <RequiredSkill identifier="mechanical" level="40" />
            <RequiredItem identifier="scp_riflekit" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="copper" amount="6" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_riflekit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="mechanical" level="35" />
            <RequiredItem identifier="steel" amount="4" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
            <RequiredItem identifier="titaniumaluminiumalloy" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["scp_shotgunkit"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="30">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="mechanical" level="25" />
            <RequiredItem identifier="plastic" amount="3" />
            <RequiredItem identifier="aluminium" amount="3" />
            <RequiredItem identifier="ballisticfiber" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Remove
  ["scp_armykit"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_surgicalkit"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_tourniquet"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_healthpills"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["sgt_sterilebandage"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_diamorphine"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_vodka"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_pomegrenadedrink"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_themedicbag"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_panacea"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_propital"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_adrenaline"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_painkillers"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_smallcivkit"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_largecivkit"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove
  ["scp_largearmykit"] = {
    mod = "Enhanced Armaments",
    xml = ""
  },
  -- Remove fabrication recipe
  ["scp_ak15zlobin"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_osv96"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- 1. Change name/description
  -- 2. Tweak recipe
  ["scp_rpg7"] = {
    mod = "Enhanced Armaments",
    xml = XElement.Parse([[
      <Item nameidentifier="mm_rpg" descriptionidentifier="mm_rpg" name="" identifier="scp_rpg7" description="" category="Weapon" subcategory="Grenades and Explosives" impactsoundtag="impact_metal_heavy" cargocontaineridentifier="explosivecrate" tags="mediumitem,weapon,explosive,demolitionsexpert" scale="0.53">
        <PreferredContainer primary="secarmcab" secondary="weaponholder,armcab" />
        <PreferredContainer primary="wrecksecarmcab" minamount="0" maxamount="1" spawnprobability="0.01" minleveldifficulty="10" />
        <PreferredContainer primary="abandonedsecarmcab" minamount="0" maxamount="1" spawnprobability="0.01" minleveldifficulty="10" />
        <Price baseprice="1200" minleveldifficulty="30">
          <Price storeidentifier="merchantoutpost" multiplier="1.35" sold="false" />
          <Price storeidentifier="merchantcity" multiplier="1.25" sold="false" />
          <Price storeidentifier="merchantresearch" multiplier="1.25" sold="false" />
          <Price storeidentifier="merchantmilitary" multiplier="0.9" minavailable="0" maxavailable="2">
            <Reputation faction="separatists" min="40" />
          </Price>
          <Price storeidentifier="merchantmine" multiplier="1.25" sold="false" />
          <Price storeidentifier="merchantarmory" multiplier="1" minavailable="0" maxavailable="2">
            <Reputation faction="separatists" min="40" />
          </Price>
        </Price>
        <Fabricate suitablefabricators="weaponfabricator" requiredtime="70">
          <RequiredSkill identifier="weapons" level="75" />
          <RequiredItem identifier="steel" amount="6" />
          <RequiredItem identifier="plastic" amount="4" />
        </Fabricate>
        <Deconstruct time="15">
          <Item identifier="steel" amount="3" />
          <Item identifier="plastic" amount="2" />
        </Deconstruct>
        <InventoryIcon name="rpg7inv" texture="%ModDir%/Weapons/explosives.png" sourcerect="0,251,60,60" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Weapons/explosives.png" sourcerect="0,63,292,71" depth="0.55" origin="0.5,0.5" />
        <Body width="292" height="71" density="50" />
        <Holdable slots="RightHand+LeftHand" controlpose="true" holdpos="40,6" aimpos="35,7.2" handle1="15,-22" handle2="-7,-23" holdangle="-35" msg="ItemMsgPickUpSelect" />
        <Wearable slots="Bag" msg="ItemMsgEquipSelect" canbeselected="false" canbepicked="true" pickkey="Select">
          <sprite name="RPG-7 Worn" texture="%ModDir%/Weapons/explosives.png" canbehiddenbyotherwearables="false" sourcerect="0,63,292,71" rotation="90" inheritlimbdepth="false" depth="0.6" limb="Torso" scale="0.5" origin="0.45,0.96" />
        </Wearable>
        <RangedWeapon reload="5" reloadnoskill="7.5" reloadskillrequirement="50" barrelpos="102,9" spread="4" unskilledspread="25" combatPriority="80" drawhudwhenequipped="true" crosshairscale="0.2">
          <Crosshair texture="Content/Items/Weapons/Crosshairs.png" sourcerect="0,256,256,256" />
          <CrosshairPointer texture="Content/Items/Weapons/Crosshairs.png" sourcerect="256,256,256,256" />
          <ParticleEmitter particle="impactfirearm" particleamount="1" velocitymin="0" velocitymax="0" scalemultiplier="13.0,5.0" colormultiplier="255,200,200,200" />
          <ParticleEmitter particle="impactfirearm" particleamount="8" velocitymin="300" velocitymax="900" minsize="1" maxsize="2" anglemin="-15" anglemax="15" copyentityangle="true" colormultiplier="255,200,200,200" />
          <ParticleEmitter particle="weldspark" particleamount="12" velocitymin="900" velocitymax="1500" minsize="2" maxsize="4" anglemin="-25" anglemax="25" copyentityangle="true" colormultiplier="255,200,200,200" />
          <ParticleEmitter particle="explosionsmoke" particleamount="12" velocitymin="900" velocitymax="1500" minsize="2" maxsize="4" anglemin="260" anglemax="280" copyentityangle="true" />
          <Sound file="%ModDir%/Sounds/rpg7.ogg" type="OnUse" volume="1.5" range="3000" />
          <StatusEffect type="OnUse" target="this">
            <Explosion range="150.0" force="0.3" shockwave="true" smoke="false" flames="false" flash="true" sparks="false" underwaterbubble="false" applyfireeffects="false" camerashake="25.0" />
          </StatusEffect>
          <RequiredItems excludeditems="sgt_gaugeset" items="rpgammo" type="Contained" msg="ItemMsgAmmoRequired">
            <Upgrade modversion="1.1.0" excludeditems="sgt_gaugeset" />
          </RequiredItems>
          <RequiredSkill identifier="weapons" level="50" />
          <StatusEffect type="OnSecondaryUse" target="Character" SpeedMultiplier="0" setvalue="true">
            <Conditional recoilstabilized="lte 0" />
          </StatusEffect>
        </RangedWeapon>
        <ItemContainer capacity="1" maxstacksize="1" itempos="62.3,6.85" hideitems="false" containedspritedepth="0.551" containedstateindicatorstyle="bullet">
          <Containable items="rpgammo">
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="2.75" condition="100" stackable="false" />
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" condition="-100" stackable="false" />
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="0.1" stackable="false" comparison="or">
              <Conditional EntityType="eq character" TargetContainer="True" />
              <Conditional EntityType="eq null" TargetContainer="True" />
              <sound file="%ModDir%/Sounds/antisubreload1.ogg" type="OnUse" forceplay="true" range="1200.0" loop="false" frequencymultiplier="0.9" volume="1" />
            </StatusEffect>
            <StatusEffect type="OnInserted" target="This" targetslot="0" disabledeltatime="true" delay="2.25" stackable="false" comparison="or">
              <Conditional EntityType="eq character" TargetContainer="True" />
              <Conditional EntityType="eq null" TargetContainer="True" />
              <sound file="%ModDir%/Sounds/antisubreload2.ogg" type="OnUse" forceplay="true" range="1200.0" loop="false" frequencymultiplier="0.9" volume="1" />
            </StatusEffect>
          </Containable>
        </ItemContainer>
        <aitarget sightrange="500" soundrange="500" fadeouttime="3" />
      </Item>]])
  },
  -- Remove fabrication recipe
  ["scp_ak74dumag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["sgt_dbs"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_g3"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_saigadrummag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_pkp"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_ak103"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_akdumag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_malyuk12"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_rm93"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_basicparts"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_saiga12"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_saigaextmag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["scp_saigamag"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },

  -- Tweak fabrication recipe
  ["scp_railgunthermoshell"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredSkill identifier="electrical" level="50" />
            <RequiredItem identifier="nuclearshell" />
            <RequiredItem identifier="scp_nuclearbomb" />
            <RequiredItem identifier="thoriumfuelrod_er" />
          </Fabricate>]])
      },
    },
  },
  -- Tweak fabrication recipe
  ["scp_taucannonuranium"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="15" requiresrecipe="false">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="uraniumfuelrod_er" />
            <RequiredItem identifier="uranium" amount="3" />
            <RequiredItem identifier="titaniumaluminiumalloy" />
          </Fabricate>]])
      },
    },
  },
  -- Tweak fabrication recipe
  ["scp_railgunerdshell"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="50" />
            <RequiredSkill identifier="electrical" level="75" />
            <RequiredItem identifier="nuclearshell" />
            <RequiredItem identifier="uranium" amount="5" />
            <RequiredItem identifier="thoriumfuelrod_er" amount="1" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_prototypeusb"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="60">
            <RequiredSkill identifier="weapons" level="90" />
            <RequiredItem identifier="fulgurium" amount="1" />
            <RequiredItem identifier="physicorium" amount="1" />
          </Fabricate>]])
      },
    },
  },
  -- Tweak fabrication recipe
  ["scp_aa12"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="35">
            <RequiredSkill identifier="weapons" level="85" />
            <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
            <RequiredItem identifier="scp_m4s90" />
            <RequiredItem identifier="scp_durasteel" amount="6" />
            <RequiredItem identifier="dementonite" amount="6" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_veronuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="70" />
            <RequiredSkill identifier="mechanical" level="25" />
            <RequiredSkill identifier="electrical" level="25" />
            <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
            <RequiredItem identifier="scp_heavyuniform" />
            <RequiredItem identifier="scp_durasteel" amount="4" />
            <RequiredItem identifier="dementonite" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_veronrig"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="80">
            <RequiredSkill identifier="weapons" level="100" />
            <RequiredSkill identifier="mechanical" level="50" />
            <RequiredSkill identifier="electrical" level="50" />
            <RequiredItem identifier="scp_prototypeusb" />
            <RequiredItem identifier="scp_specialrig" />
            <RequiredItem identifier="scp_durasteel" amount="8" />
            <RequiredItem identifier="dementonite" amount="8" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_veronhelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="70" />
            <RequiredSkill identifier="mechanical" level="25" />
            <RequiredSkill identifier="electrical" level="25" />
            <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
            <RequiredItem identifier="scp_heavycombathelmet" />
            <RequiredItem identifier="scp_durasteel" amount="4" />
            <RequiredItem identifier="dementonite" amount="4" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_marauderuniform"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="mechanical" level="17" />
            <RequiredSkill identifier="electrical" level="17" />
            <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
            <RequiredItem identifier="scp_heavyuniform" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
            <RequiredItem identifier="dementonite" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_marauderrig"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="80">
            <RequiredSkill identifier="weapons" level="70" />
            <RequiredSkill identifier="mechanical" level="40" />
            <RequiredSkill identifier="electrical" level="40" />
            <RequiredItem identifier="scp_prototypeusb" />
            <RequiredItem identifier="scp_specialrig" />
            <RequiredItem identifier="scp_durasteel" amount="5" />
            <RequiredItem identifier="dementonite" amount="5" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_marauderhelmet"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="50">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredSkill identifier="mechanical" level="17" />
            <RequiredSkill identifier="electrical" level="17" />
            <RequiredItem identifier="scp_prototypeusb" mincondition="0.5" />
            <RequiredItem identifier="scp_heavycombathelmet" />
            <RequiredItem identifier="scp_durasteel" amount="2" />
            <RequiredItem identifier="dementonite" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["grenadelauncher"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="40">
            <RequiredSkill identifier="weapons" level="40" />
            <RequiredItem identifier="steel" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Add fabrication recipe
  ["scp_taucannonparts"] = {
    mod = "Enhanced Armaments",
    componentOverrides = {
      {
        add = true,
        override = XElement.Parse([[
          <Fabricate suitablefabricators="advweaponfabricator" requiredtime="60">
            <RequiredSkill identifier="electrical" level="95" />
            <RequiredSkill identifier="weapons" level="65" />
            <RequiredItem identifier="scp_prototypeusb" />
            <RequiredItem identifier="fulgurium" amount="2" />
            <RequiredItem identifier="dementonite" amount="2" />
          </Fabricate>]])
      },
    },
  },

  -- *********
  -- EK Forked
  -- *********
  -- Important stuff
  -- Tweak fabrication recipes
  ["ekdockyard_fusionfuel_tritiumdeuterium"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
      <Item name="Fusion Fuel (Tritium Deuterium)" identifier="ekdockyard_fusionfuel_tritiumdeuterium" Tags="smallitem,fusionfuel,reactorfuel,fusionfuellevel2" maxstacksize="6" cargocontaineridentifier="metalcrate" health="100" scale="0.5" description="Conventional fusile material which predates the colonies. However due to the immense colony resource demands, production of viable tritium deuterium fuel on industrial scale is still very costly.">
        <PreferredContainer primary="reactorcab,storagecab" />
        <PreferredContainer primary="wreckreactorcab" minamount="0" maxamount="1" spawnprobability="0.05" />
        <Price baseprice="275" minleveldifficulty="33">
          <Price storeidentifier="merchantmine" multiplier="0.9" sold="false" />
          <Price storeidentifier="merchantoutpost" multiplier="1.1" sold="false" />
          <Price storeidentifier="merchantcity" multiplier="1.15" minavailable="2" />
          <Price storeidentifier="merchantresearch" multiplier="1" minavailable="4" />
          <Price storeidentifier="merchantmilitary" multiplier="1.1" sold="false" />
          <Price storeidentifier="merchantengineering" multiplier="1.25" minavailable="1" />
        </Price>
        <Deconstruct time="10">
          <Item identifier="aluminium" />
        </Deconstruct>
        <Fabricate suitablefabricators="fabricator" requiredtime="60" amount="2">
          <RequiredSkill identifier="medical" level="30" />
          <RequiredSkill identifier="electrical" level="40" />
          <RequiredItem identifier="aluminium" />
          <RequiredItem identifier="aluminium" />
          <RequiredItem identifier="uraniumfuelrod_er" mincondition="0.9" />
          <RequiredItem identifier="lithium" mincondition="0.9" usecondition="false" />
        </Fabricate>
        <Fabricate suitablefabricators="fabricator" requiredtime="60" amount="3">
          <RequiredSkill identifier="medical" level="30" />
          <RequiredSkill identifier="electrical" level="40" />
          <RequiredItem identifier="aluminium" />
          <RequiredItem identifier="aluminium" />
          <RequiredItem identifier="aluminium" />
          <RequiredItem identifier="thoriumfuelrod_er" mincondition="0.9" />
          <RequiredItem identifier="lithium" mincondition="0.9" usecondition="false" />
        </Fabricate>
        <Fabricate suitablefabricators="fabricator" displayname="recycleitem" requiredtime="10">
          <RequiredSkill identifier="electrical" level="40" />
          <RequiredSkill identifier="medical" level="30" />
          <RequiredItem identifier="lithium" mincondition="0.5" usecondition="true" />
          <RequiredItem identifier="uraniumfuelrod_er" mincondition="0.5" usecondition="true" />
          <RequiredItem identifier="ekdockyard_fusionfuel_tritiumdeuterium" mincondition="0.0" maxcondition="0.1" usecondition="false" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/Items/Generator/fuel_items.png" sourcerect="160,0,64,64" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Items/Generator/fuel_items.png" depth="0.55" sourcerect="88,128,88,120" />
        <BrokenSprite texture="%ModDir%/Items/Generator/fuel_items.png" depth="0.55" sourcerect="0,128,88,120" origin="0.5,0.5" maxcondition="0" />
        <Body width="72" height="108" density="15" />
        <Holdable handle1="0,0" slots="Any,RightHand,LeftHand" msg="ItemMsgPickUpSelect" removeOnCombined="true"></Holdable>
        <Quality>
          <QualityStat stattype="Condition" value="0.1" />
        </Quality>
      </Item>]])
  },
  -- Remove
  ["ekutility_metalfoam_tank"] = {
    mod = "EK Forked",
    xml = ""
  },
  -- Remove
  ["ekutility_metalfoam_gun"] = {
    mod = "EK Forked",
    xml = ""
  },
  -- Remove
  ["ekutility_jetscooter"] = {
    mod = "EK Forked",
    xml = ""
  },
  -- Change fabricator to weapon fabricator
  ["ek_ammobandolier"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
            <RequiredItem identifier="organicfiber" />
            <RequiredItem identifier="plastic" mincondition="0.5" usecondition="true" />
            <RequiredItem identifier="copper" mincondition="0.5" usecondition="true" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["ekgunnery_heavyrailgunboardingshell"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove (for now) #TODO#
  ["longrangejammer"] = {
    mod = "EK Forked",
    xml = ""
  },
  -- Make a traitor item
  --[[["ek_dartgun"] = {
    mod = "EK Forked",
    xml = ""
  },]]
  -- Just used as the "dart" for the dartgun,
  --[[["ek_dart_explosive"] = {
    mod = "EK Forked",
    xml = ""
  },]]
  -- Replace sound with Enhanced Immersion's version
  ["ekdockyard_glassdoor"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
    <Item name="Glass Door" identifier="ekdockyard_glassdoor" tags="door,weldable" scale="0.5" description="A sliding door with a huge window. No integrated buttons - has to be wired manually." health="80" damagedbyrepairtools="true" damagedbymonsters="true" damagedbyprojectiles="true" damagedbymeleeweapons="true" damagedbyexplosions="true" explosiondamagemultiplier="0.5" allowrotatingineditor="false" allowedlinks="structure,item" linkable="true">
      <InventoryIcon texture="%ModDir%/Items/Door/door_custom1.png" sourcerect="0,0,48,416" origin="0.5,0.5" />
      <Sprite texture="Content/Items/Door/door.png" sourcerect="0,0,49,416" depth="0.51" origin="0.5,0.5" />
      <DecorativeSprite texture="Content/Items/Door/door.png" sourcerect="49,0,49,416" depth="0.89" origin="0.5,0.5" />
      <Door window="0,-48,48,320" canbepicked="true" canbeselected="true" pickkey="Action" msg="ItemMsgForceOpenCrowbar" PickingTime="10.0" shadowscale="0.7,1">
        <RequiredItem items="crowbar" type="Equipped" />
        <Sprite texture="%ModDir%/Items/Door/door_custom1.png" sourcerect="0,0,48,416" depth="0.05" origin="0.5,0.0" />
        <WeldedSprite texture="Content/Items/Door/door.png" sourcerect="203,0,65,377" depth="0.0" origin="0.5,0.5" />
        <BrokenSprite texture="Content/Items/Door/door.png" sourcerect="392,0,120,416" depth="0.051" origin="0.5,0.0" scale="true" />
        <sound file="%ModDir:2968896556%/Content/Items/Door/door_open1.ogg" type="OnOpen" range="350.0" />
        <sound file="%ModDir:2968896556%/Content/Items/Door/door_close1.ogg" type="OnClose" range="350.0" />
        <sound file="Content/Items/Tools/Crowbar.ogg" type="OnPicked" range="4000.0" />
        <sound file="Content/Items/Door/Duct1.ogg" type="OnFailure" selectionmode="Random" range="300" />
        <sound file="Content/Items/Door/Duct2.ogg" type="OnFailure" range="300" />
        <sound file="Content/Sounds/Damage/GlassBreak1.ogg" type="OnBroken" selectionmode="Random" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak2.ogg" type="OnBroken" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak3.ogg" type="OnBroken" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak4.ogg" type="OnBroken" range="3000" />
        <StatusEffect type="OnDamaged" target="This">
          <sound file="Content/Sounds/Damage/GlassImpact1.ogg" selectionmode="Random" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact2.ogg" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact3.ogg" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact4.ogg" range="800" />
        </StatusEffect>
        <StatusEffect type="OnBroken" target="This" disabledeltatime="true">
          <ParticleEmitter particle="shrapnel" copyentityangle="true" anglemin="-360" anglemax="360" particleamount="4" velocitymin="50" velocitymax="900" scalemin="1" scalemax="2" />
          <ParticleEmitter particle="shrapnel" copyentityangle="false" anglemin="-360" anglemax="360" particleamount="5" velocitymin="50" velocitymax="400" scalemin="1" scalemax="1" />
        </StatusEffect>
      </Door>
      <AiTarget sightrange="3000.0" static="True" />
      <Repairable selectkey="Action" header="mechanicalrepairsheader" fixDurationHighSkill="10" fixDurationLowSkill="25" msg="ItemMsgRepairWrench" hudpriority="10">
        <GuiFrame relativesize="0.2,0.16" minsize="400,180" maxsize="480,216" anchor="Center" relativeoffset="0.0,0.27" style="ItemUI" />
        <RequiredSkill identifier="mechanical" level="40" />
        <RequiredItem items="wrench" type="equipped" />
      </Repairable>
      <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
        <GuiFrame relativesize="0.2,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
        <RequiredItem items="screwdriver" type="Equipped" />
        <input name="toggle" displayname="connection.togglestate" />
        <input name="set_state" displayname="connection.setstate" />
        <output name="state_out" displayname="connection.stateout" fallbackdisplayname="connection.signalout" />
        <output name="condition_out" displayname="connection.conditionout" />
        <output name="activate_out" displayname="connection.activateout" />
      </ConnectionPanel>
    </Item>]])
  },
  -- Replace sound with Enhanced Immersion's version
  ["ekdockyard_glassdoorwbuttons"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
    <Item name="Glass Door with Buttons" identifier="ekdockyard_glassdoorwbuttons" tags="door,weldable" scale="0.5" description="A sliding door with a huge window and two integrated buttons." health="80" requirebodyinsidetrigger="false" damagedbyrepairtools="true" damagedbymonsters="true" damagedbyprojectiles="true" damagedbymeleeweapons="true" damagedbyexplosions="true" explosiondamagemultiplier="0.5" allowrotatingineditor="false" allowedlinks="structure,item" linkable="true">
      <InventoryIcon texture="%ModDir%/Items/Door/door_custom1.png" sourcerect="0,0,48,416" origin="0.5,0.5" />
      <Sprite texture="Content/Items/Door/door.png" sourcerect="0,0,49,416" depth="0.51" origin="0.5,0.5" />
      <DecorativeSprite texture="Content/Items/Button/button.png" sourcerect="28,70,34,51" depth="0.75" origin="1.65,0.76" />
      <DecorativeSprite texture="Content/Items/Button/button.png" sourcerect="28,70,34,51" depth="0.75" origin="-0.65,0.76" />
      <!--<DecorativeSprite texture="Content/Items/Door/door2.png" sourcerect="0,0,170,416" depth="0.89" origin="0.51,0.5" /> -->
      <Door window="0,-48,48,320" canbepicked="true" canbeselected="true" pickkey="Action" msg="ItemMsgForceOpenCrowbar" PickingTime="10.0" shadowscale="0.7,1" hasintegratedbuttons="true">
        <RequiredItem items="crowbar" type="Equipped" optional="true" />
        <Requireditem items="idcard" type="Picked" optional="true" />
        <Sprite texture="%ModDir%/Items/Door/door_custom1.png" sourcerect="0,0,48,416" depth="0.05" origin="0.5,0.0" />
        <WeldedSprite texture="Content/Items/Door/door.png" sourcerect="203,0,65,377" depth="0.0" origin="0.5,0.5" />
        <BrokenSprite texture="Content/Items/Door/door.png" sourcerect="392,0,120,416" depth="0.051" origin="0.5,0.0" scale="true" />
        <sound file="%ModDir:2968896556%/Content/Items/Door/door_open1.ogg" type="OnOpen" range="350.0" />
        <sound file="%ModDir:2968896556%/Content/Items/Door/door_close1.ogg" type="OnClose" range="350.0" />
        <sound file="Content/Items/Tools/Crowbar.ogg" type="OnPicked" range="4000.0" />
        <sound file="Content/Items/Door/Duct1.ogg" type="OnFailure" selectionmode="Random" range="300" />
        <sound file="Content/Items/Door/Duct2.ogg" type="OnFailure" range="300" />
        <sound file="Content/Sounds/Damage/GlassBreak1.ogg" type="OnBroken" selectionmode="Random" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak2.ogg" type="OnBroken" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak3.ogg" type="OnBroken" range="3000" />
        <sound file="Content/Sounds/Damage/GlassBreak4.ogg" type="OnBroken" range="3000" />
        <StatusEffect type="OnDamaged" target="This">
          <sound file="Content/Sounds/Damage/GlassImpact1.ogg" selectionmode="Random" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact2.ogg" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact3.ogg" range="800" />
          <sound file="Content/Sounds/Damage/GlassImpact4.ogg" range="800" />
        </StatusEffect>
        <StatusEffect type="OnBroken" target="This" disabledeltatime="true">
          <ParticleEmitter particle="shrapnel" copyentityangle="true" anglemin="-360" anglemax="360" particleamount="4" velocitymin="50" velocitymax="900" scalemin="1" scalemax="2" />
          <ParticleEmitter particle="shrapnel" copyentityangle="false" anglemin="-360" anglemax="360" particleamount="5" velocitymin="50" velocitymax="400" scalemin="1" scalemax="1" />
        </StatusEffect>
      </Door>
      <trigger x="-60" y="-140" width="170" height="85" />
      <AiTarget sightrange="3000.0" static="True" />
      <Repairable selectkey="Action" header="mechanicalrepairsheader" fixDurationHighSkill="10" fixDurationLowSkill="25" msg="ItemMsgRepairWrench" hudpriority="10">
        <GuiFrame relativesize="0.2,0.16" minsize="400,180" maxsize="480,216" anchor="Center" relativeoffset="0.0,0.27" style="ItemUI" />
        <RequiredSkill identifier="mechanical" level="40" />
        <RequiredItem items="wrench" type="equipped" />
      </Repairable>
      <ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewireScrewdriver" hudpriority="10">
        <GuiFrame relativesize="0.2,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
        <RequiredItem items="screwdriver" type="Equipped" />
        <input name="toggle" displayname="connection.togglestate" />
        <input name="set_state" displayname="connection.setstate" />
        <output name="state_out" displayname="connection.stateout" fallbackdisplayname="connection.signalout" />
        <output name="condition_out" displayname="connection.conditionout" />
        <output name="activate_out" displayname="connection.activateout" />
      </ConnectionPanel>
    </Item>]])
  },
  -- 1. Make it able to hold handcuff keys as well
  -- 2. Change fabricator to weapon fabricator
  ["ek_handcuff_container"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
    <Item name="" identifier="ek_handcuff_container" category="Equipment" aliases="handcuff container" tags="smallitem,ammobox" cargocontaineridentifier="metalcrate" scale="0.4" pickdistance="150" impactsoundtag="impact_metal_light">
      <Price baseprice="25" sold="false" minleveldifficulty="3">
        <Price storeidentifier="merchantoutpost" multiplier="1.5" />
        <Price storeidentifier="merchantcity" multiplier="1.25" />
        <Price storeidentifier="merchantresearch" multiplier="1.25" />
        <Price storeidentifier="merchantmilitary" multiplier="1" sold="true" minavailable="2" />
        <Price storeidentifier="merchantmine" multiplier="1.25" />
        <Price storeidentifier="merchantarmory" multiplier="1.2" sold="true" minavailable="1" />
      </Price>
      <Deconstruct time="10">
        <Item identifier="steel" />
      </Deconstruct>
      <Fabricate suitablefabricators="weaponfabricator" requiredtime="10">
        <RequiredSkill identifier="mechanical" level="20" />
        <RequiredItem identifier="steel" />
      </Fabricate>
      <InventoryIcon texture="%ModDir%/Items/InventoryIcons.png" sourcerect="256,512,64,64" />
      <Sprite texture="containers_ek.png" depth="0.54" sourcerect="512,528,64,80" origin="0.5,0.5" />
      <Body width="48" height="78" density="15" />
      <Holdable slots="Any,RightHand,LeftHand" holdpos="10,-70" handle1="0,-20" aimable="false" msg="ItemMsgPickUpSelect" />
      <ItemContainer autofill="False" capacity="3" slotsperrow="3" maxstacksize="1" canbeselected="true" hideitems="false" itempos="2,23" iteminterval="0,-18" keepopenwhenequipped="true" movableframe="true">
        <Containable identifiers="handcuffs, handcuffkey" />
      </ItemContainer>
    </Item>]])
  },
  -- Increase fabrication cost
  ["ekutility_storagecrate"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="fabricator" requiredtime="30">
            <RequiredSkill identifier="mechanical" level="20" />
            <RequiredItem identifier="steel" amount="2" />
            <RequiredItem identifier="aluminium" amount="2" />
            <RequiredItem identifier="rubber" amount="2" />
            <RequiredItem identifier="plastic" amount="2" />
          </Fabricate>]])
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_crateblocker"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_materiallocker"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Increase fabrication cost, tweak armor values
  ["exosuit"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
    <Item name="" identifier="exosuit" category="Diving,Equipment" tags="diving,deepdiving,deepdivinglarge,human" scale="0.605" fireproof="true" description="" isshootable="true" allowdroppingonswapwith="diving" impactsoundtag="impact_metal_heavy" botpriority="0.01" cargocontaineridentifier="">
      <Price baseprice="80" canbespecial="false" sold="false" />
      <Deconstruct time="30">
        <Item identifier="steel" amount="3" />
        <Item identifier="titaniumaluminiumalloy" amount="3" />
        <Item identifier="rubber" amount="2" />
      </Deconstruct>
      <Fabricate suitablefabricators="weaponfabricator" requiredtime="45" requiresrecipe="true">
        <RequiredSkill identifier="mechanical" level="75" />
        <RequiredItem identifier="steel" amount="6" />
        <RequiredItem identifier="titaniumaluminiumalloy" amount="6" />
        <RequiredItem identifier="rubber" amount="4" />
      </Fabricate>
      <InventoryIcon texture="Content/Items/Jobgear/Mechanic/Exosuit.png" sourcerect="384,384,128,128" origin="0.5,0.5" />
      <Sprite name="Exosuit Item" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" sourcerect="2,266,203,244" depth="0.55" origin="0.5,0.5" />
      <Body width="150" height="230" density="30" />
      <Wearable slots="OuterClothes" msg="ItemMsgEquipSelect" displaycontainedstatus="true" canbeselected="false" canbepicked="true" pickkey="Select" allowusewhenworn="true">
        <sprite name="Exosuit Helmet Wearable" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="Head" hidelimb="true" inheritlimbdepth="true" inheritscale="true" ignorelimbscale="true" scale="0.65" hideotherwearables="true" hidewearablesoftype="" sourcerect="0,0,1,1" origin="0.5,0.5" />
        <sprite name="Exosuit Torso" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="Torso" scale="1.2" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.5,0.8" inheritlimbdepth="true" inheritsourcerect="false" sourcerect="167,1,203,193">
          <LightComponent range="200.0" lightcolor="250,224,165,255" powerconsumption="10" IsOn="true" allowingameediting="false" offset="-50,-50">
            <LightTexture texture="Content/Lights/divinghelmetlight.png" origin="0.05, 0.5" size="1.0,1.0" />
          </LightComponent>
        </sprite>
        <sprite name="Exosuit Right Hand" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" inheritlimbdepth="true" SourceRect="383,160,64,48" />
        <sprite name="Exosuit Left Hand" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftHand" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" SourceRect="447,160,64,48" />
        <sprite name="Exosuit Right Upper Arm" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightArm" depthlimb="Head" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" inheritlimbdepth="true" SourceRect="383,0,64,96" />
        <sprite name="Exosuit Left Upper Arm" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftArm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" SourceRect="447,0,64,96" />
        <sprite name="Exosuit Right Forearm" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" inheritlimbdepth="true" SourceRect="383,96,64,64" />
        <sprite name="Exosuit Left Forearm" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftForearm" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="false" SourceRect="447,96,64,64" />
        <sprite name="Exosuit Waist" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="Waist" hidelimb="true" scale="1.2" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.5,0.5" inheritsourcerect="false" inheritlimbdepth="true" sourcerect="182,196,178,53" />
        <sprite name="Exosuit Right Thigh" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.5,0.5" inheritsourcerect="false" inheritlimbdepth="true" sourcerect="0,0,96,112" />
        <sprite name="Exosuit Left Thigh" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftThigh" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.5,0.5" inheritsourcerect="false" sourcerect="0,0,96,112" />
        <sprite name="Exosuit Right Leg" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritlimbdepth="true" inheritsourcerect="true" />
        <sprite name="Exosuit Left Leg" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftLeg" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="true" inheritsourcerect="true" />
        <sprite name="Exosuit Left Shoe" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="LeftFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.2,0.5" inheritsourcerect="false" sourcerect="371,211,133,37" />
        <sprite name="Exosuit Right Shoe" texture="Content/Items/Jobgear/Mechanic/Exosuit.png" limb="RightFoot" sound="footstep_armor_heavy" hidelimb="true" inherittexturescale="true" hideotherwearables="true" inheritorigin="false" origin="0.2,0.5" inheritsourcerect="false" sourcerect="371,211,133,37" />
        <StatusEffect type="OnWearing" target="Character" OxygenAvailable="-100.0" UseHullOxygen="false" />
        <StatusEffect type="OnWearing" target="Character" LowPassMultiplier="0.2" HideFace="true" ObstructVision="true" PressureProtection="7000.0" PropulsionSpeedMultiplier="0.5" setvalue="true" disabledeltatime="true">
          <Sound file="Content/Items/Diving/DivingSuitLoop1.ogg" range="250" loop="true" />
          <Sound file="Content/Items/Diving/DivingSuitLoop2.ogg" range="250" loop="true" />
          <TriggerAnimation Type="Walk" FileName="HumanWalkExosuit" priority="1" ExpectedSpecies="Human" />
          <TriggerAnimation Type="Run" FileName="HumanRunExosuit" priority="1" ExpectedSpecies="Human" />
        </StatusEffect>
        <!-- no HMG stun -->
        <StatusEffect type="OnWearing" target="Character" interval="0.9" disabledeltatime="true">
          <Affliction identifier="recoilstabilized" amount="1" />
        </StatusEffect>
        <!-- slow movement -->
        <StatusEffect type="OnWearing" target="This,Character" setvalue="true" disabledeltatime="true">
          <Conditional Voltage="gt 0.5" />
        </StatusEffect>
        <StatusEffect type="OnWearing" target="Contained,Character" Condition="-0.1" interval="1" disabledeltatime="true" targetslot="1" comparison="Or">
          <Conditional IsDead="false" />
          <RequiredItem items="reactorfuel" targetslot="1" type="Contained" />
        </StatusEffect>
        <!-- 0 movement speed when out of fuel-->
        <StatusEffect type="OnWearing" target="This,Character" SpeedMultiplier="-10.0" setvalue="true" disabledeltatime="true">
          <Conditional Voltage="lte 0.5" />
        </StatusEffect>
        <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="blunttrauma,gunshotwound,lacerations,explosiondamage" damagemultiplier="0.30" damagesound="LimbArmor" deflectprojectiles="true" />
        <damagemodifier armorsector="0.0,360.0" afflictionidentifiers="bitewounds, bleeding" damagemultiplier="0.25" probabilitymultiplier="0.5" damagesound="LimbArmor" deflectprojectiles="true" />
        <damagemodifier armorsector="0.0,360.0" afflictiontypes="stun" damagemultiplier="0.75" probabilitymultiplier="0.25" damagesound="LimbArmor" deflectprojectiles="true" />
        <damagemodifier armorsector="0.0,360.0" afflictiontypes="burn" damagemultiplier="0.4" damagesound="" deflectprojectiles="true" />
        <sound file="Content/Items/Weapons/WEAPONS_chargeUp.ogg" type="OnWearing" range="500.0" volumeproperty="Speed" volume="0.2" loop="true" frequencymultiplier="0.5" />
        <StatValue stattype="FlowResistance" value="0.9" />
      </Wearable>
      <ItemContainer capacity="0" hideitems="true" containedstateindicatorstyle="tank" containedstateindicatorslot="0">
        <SlotIcon slotindex="0" texture="Content/UI/StatusMonitorUI.png" sourcerect="64,448,64,64" origin="0.5,0.5" />
        <SlotIcon slotindex="1" texture="Content/UI/StatusMonitorUI.png" sourcerect="192,448,64,64" origin="0.5,0.5" />
        <StatusEffect type="OnWearing" target="Contained" targetslot="0" playsoundonrequireditemfailure="true">
          <RequiredItem items="oxygensource" type="Contained" targetslot="0" matchonempty="true" />
          <Conditional condition="lte 0.0" />
          <Sound file="Content/Items/WarningBeep.ogg" range="500" loop="true" />
        </StatusEffect>
        <SubContainer capacity="1" maxstacksize="1">
          <Containable items="oxygensource,weldingtoolfuel" />
          <Containable items="oxygensource">
            <StatusEffect type="OnWearing" target="Character" OxygenAvailable="1000.0" />
            <StatusEffect type="OnWearing" target="Contained" Condition="-0.2" comparison="And">
              <Conditional TargetContainer="true" TargetGrandparent="true" IsDead="false" />
              <Conditional TargetContainer="true" TargetGrandparent="true" DecreasedOxygenConsumption="lt 99" />
              <Conditional TargetContainer="true" TargetGrandparent="true" NeedsAir="true" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Contained">
              <Conditional condition="lt 5.0" />
              <Sound file="Content/Items/WarningBeepSlow.ogg" range="250" loop="true" />
            </StatusEffect>
          </Containable>
          <Containable items="oxygenitetank">
            <StatusEffect type="OnWearing" target="Character" SpeedMultiplier="1.2" setvalue="true" targetslot="0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional DecreasedOxygenConsumption="lt 99" />
              <Conditional NeedsAir="true" />
            </StatusEffect>
          </Containable>
          <Containable items="weldingfueltank">
            <StatusEffect type="OnWearing" target="Contained" Condition="-0.5" comparison="And">
              <Conditional TargetContainer="true" TargetGrandparent="true" IsDead="false" />
              <Conditional TargetContainer="true" TargetGrandparent="true" DecreasedOxygenConsumption="lt 99" />
              <Conditional TargetContainer="true" TargetGrandparent="true" NeedsAir="true" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" OxygenAvailable="-100.0" Oxygen="-5.0" comparison="And">
              <Conditional IsDead="false" />
              <Conditional DecreasedOxygenConsumption="lt 99" />
              <Conditional NeedsAir="true" />
            </StatusEffect>
          </Containable>
          <Containable items="incendiumfueltank">
            <StatusEffect type="OnWearing" target="Contained" Condition="-0.5" comparison="And">
              <Conditional TargetContainer="true" TargetGrandparent="true" IsDead="false" />
              <Conditional TargetContainer="true" TargetGrandparent="true" DecreasedOxygenConsumption="lt 99" />
              <Conditional TargetContainer="true" TargetGrandparent="true" NeedsAir="true" />
            </StatusEffect>
            <StatusEffect type="OnWearing" target="Character" OxygenAvailable="-100.0" comparison="And" targetlimb="Torso">
              <Affliction identifier="burn" amount="20.0" />
              <Conditional IsDead="false" />
              <Conditional DecreasedOxygenConsumption="lt 99" />
              <Conditional NeedsAir="true" />
            </StatusEffect>
          </Containable>
        </SubContainer>
        <SubContainer capacity="1" maxstacksize="1">
          <Containable items="reactorfuel" excludeditems="oxygensource,oxygentank,weldingfueltank,turbineoxygentank,generatorfuel">
            <StatusEffect type="OnContaining" target="This,Character" Voltage="1.0" setvalue="true">
              <Conditional IsDead="false" />
            </StatusEffect>
          </Containable>
        </SubContainer>
        <SubContainer capacity="10" maxstacksize="32">
          <Containable items="smallitem" />
        </SubContainer>
      </ItemContainer>
      <aitarget maxsightrange="1500" />
    </Item>]])
  },
  -- Remove fabrication recipe
  ["ekutility_divingsuitlocker"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_oxygentankshelf"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_portablespinkler"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_securebuttoncaptain"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_securebuttonsecurityofficer"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_securebuttonmedicaldoctor"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_securebuttonmechanic"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_securebuttonengineer"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablejunction"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_heavypowerswitch"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablebattery"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablesmallpump"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablefabricator"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablefabricator_adaptive"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablemedicalfabricator"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeabledeconstructor"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablesonarmonitor"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_placeablestatusmonitor"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_chargingdock1"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekgunnery_heavyrailgunshellrack1"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekgunnery_heavyrailgunshellrack2"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_craterack"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_craterack_tall"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_shellrack_huge"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_shellrack"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_smallshelf"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Remove fabrication recipe
  ["ekutility_mediumshelf"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = ""
      },
    },
  },
  -- Change fabricator to weapon fabricator
  ["ek_breachingcharge"] = {
    mod = "EK Forked",
    componentOverrides = {
      {
        targetComponent = "fabricate",
        override = XElement.Parse([[
          <Fabricate suitablefabricators="weaponfabricator" requiredtime="20" amount="2">
            <RequiredSkill identifier="weapons" level="45" />
            <RequiredItem identifier="fpgacircuit" />
            <RequiredItem identifier="uex" />
            <RequiredItem identifier="copper" />
          </Fabricate>]])
      },
    },
  },
  -- Make "compatible" with Enhanced Reactors
  -- Basically a retextured fulgurium rod, but don't tell
  ["ekutility_incendiumfuelrod"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
      <Item name="" identifier="ekutility_incendiumfuelrod" Category="Fuel" Tags="fulguriumfuelrod,incendiumfuelrod,fuelroditem,mediumitem,reactorfuel,fuelrodincendium,cargoscooter,mountableweapon" maxstacksize="8" cargocontaineridentifier="fuelrodcrate" health="150" scale="0.5" impactsoundtag="impact_fuelrod" requireaimtouse="true">
        <PreferredContainer primary="fuelrodcrate" secondary="reactorcab" />
        <PreferredContainer secondary="fuelrodcontainer" amount="1" spawnprobability="0.1" />
        <PreferredContainer secondary="wreckreactorcab,abandonedreactorcab" amount="1" spawnprobability="0.2" />
        <PreferredContainer secondary="wreckreactor" amount="1" mincondition="0.5" maxcondition="0.99" spawnprobability="0.05" />
        <PreferredContainer secondary="beaconengcab" amount="1" spawnprobability="0.05" />
        <PreferredContainer secondary="abandonedengcab,wreckengcab" amount="1" spawnprobability="0.01" />
        <Price baseprice="250" sold="false" displaynonempty="true">
          <Price storeidentifier="merchantoutpost" />
          <Price storeidentifier="merchantcity" />
          <Price storeidentifier="merchantresearch" multiplier="1.25" />
          <Price storeidentifier="merchantmilitary" multiplier="1.25" />
          <Price storeidentifier="merchantmine" multiplier="1.1" />
          <Price storeidentifier="merchantengineering" multiplier="0.9" minavailable="2" />
        </Price>
        <Deconstruct time="10">
          <Item identifier="steel" outcondition="0.5" />
          <Item identifier="lead" outcondition="0.5" />
          <Item identifier="incendium" copycondition="true" />
        </Deconstruct>
        <Fabricate suitablefabricators="modfabricator,fabricator" requiredtime="10">
          <RequiredSkill identifier="electrical" level="40" />
          <RequiredItem identifier="incendium" />
          <RequiredItem identifier="lead" />
          <RequiredItem identifier="steel" />
        </Fabricate>
        <Fabricate suitablefabricators="fabricator" displayname="recycleitem" requiredtime="10">
          <RequiredSkill identifier="electrical" level="40" />
          <RequiredItem identifier="incendium" />
          <RequiredItem tag="fuelrodincendium" mincondition="0.0" maxcondition="1.0" usecondition="false" />
        </Fabricate>
        <InventoryIcon texture="%ModDir%/Items/Tools/ekutility_tools.png" sourcerect="768,64,64,64" origin="0.5,0.5" />
        <Sprite texture="%ModDir%/Items/Tools/ekutility_tools.png" depth="0.55" sourcerect="711,376,18,66" />
        <Body radius="6" height="55" density="13" />
        <ItemComponent canbeselected="false" canbepicked="false" allowingameediting="false">
          <StatusEffect type="OnContained" target="Parent" tags="containradiation" duration="0.1" setvalue="true" comparison="And">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="deconstructor" />
            <Conditional IsActive="eq true" />
            <Conditional Voltage="gt 0.1" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="Parent" tags="containradiation" duration="0.1" setvalue="true" comparison="And">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="fabricator" />
            <Conditional IsActive="eq true" />
            <Conditional Voltage="gt 0.1" />
          </StatusEffect>
        </ItemComponent>
        <LightComponent range="750.0" lightcolor="255,125,30,175" IsOn="false" flicker="0.2" flickerspeed="0.3" castshadows="true" alphablend="false" allowingameediting="false" powerconsumption="0">
          <!-- Once the fuel rod reaches 0.0%, remove it and spawn an empty fuel rod in its place -->
          <StatusEffect type="OnBroken" target="This">
            <Remove />
            <SpawnItem identifier="emptyfuelrod" spawnposition="SameInventory" spawnifcantbecontained="true" spawnifinventoryfull="true" condition="0" />
          </StatusEffect>
          <!-- slowly drain the fuel rod over time if the fission process was started | disabled inside reactors to allow reactors set to not consume fuel and beacon missions to play out normally unless condition is 0 -->
          <StatusEffect type="OnActive" target="This" interval="1" condition="-0.05" disabledeltatime="true" comparison="And">
            <Conditional HasTag="neq reactor" targetcontainer="true" />
          </StatusEffect>
          <StatusEffect type="OnActive" target="This" interval="1" condition="-0.05" disabledeltatime="true" comparison="And">
            <Conditional HasStatusTag="eq wreckreactor" targetcontainer="true" />
          </StatusEffect>
          <!-- check if near a character and tag the item to allow the StatusEffects to trigger | Prevents performance impact when far away from the item -->
          <StatusEffect type="Always" target="This,NearbyCharacters" range="10000" tags="nearcharacter" interval="1" duration="1.1" comparison="And">
            <!-- <Hook name="EnhancedReactors.Disable" /> -->
            <Conditional isPlayer="true" />
          </StatusEffect>
          <!-- create an invisible explosion to apply variable amount of damage and afflictions to nearby items and characters, if the fission process was started and the item is not contained within a container with the tag "containradiation" -->
          <StatusEffect type="Always" target="This" interval="0.3" comparison="And" AllowWhenBroken="true">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Conditional HasTag="neq deepdivinglarge" targetcontainer="true" />
            <Conditional HasTag="neq containradiation" targetcontainer="true" />
            <Explosion range="2000" itemdamage="0.975" structuredamage="0.0" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false">
              <Affliction identifier="radiationsickness" strength="3.75" />
              <Affliction identifier="contaminated" strength="3.75" />
              <Affliction identifier="radiationsounds" strength="4.5" />
              <Affliction identifier="overheating" strength="1.2" />
            </Explosion>
          </StatusEffect>
          <!-- create an invisible explosion to apply variable amount of afflictions to characters depending on the condition of the reactor -->
          <StatusEffect type="Always" target="This" interval="0.3" comparison="And" AllowWhenBroken="true">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Conditional HasTag="eq reactor" targetcontainer="true" />
            <Conditional conditionpercentage="lt 75" targetcontainer="true" />
            <Conditional conditionpercentage="gte 50" targetcontainer="true" />
            <Explosion range="1000" itemdamage="0.0" structuredamage="0.0" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false">
              <Affliction identifier="radiationsickness" strength="0.225" />
              <Affliction identifier="contaminated" strength="0.225" />
              <Affliction identifier="radiationsounds" strength="1.9" />
              <Affliction identifier="overheating" strength="0.15" />
            </Explosion>
          </StatusEffect>
          <StatusEffect type="Always" target="This" interval="0.3" comparison="And" AllowWhenBroken="true">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Conditional HasTag="eq reactor" targetcontainer="true" />
            <Conditional conditionpercentage="lt 50" targetcontainer="true" />
            <Conditional conditionpercentage="gte 25" targetcontainer="true" />
            <Explosion range="1000" itemdamage="0.0" structuredamage="0.0" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false">
              <Affliction identifier="radiationsickness" strength="0.45" />
              <Affliction identifier="contaminated" strength="0.45" />
              <Affliction identifier="radiationsounds" strength="2.9" />
              <Affliction identifier="overheating" strength="0.3" />
            </Explosion>
          </StatusEffect>
          <StatusEffect type="Always" target="This" interval="0.3" comparison="And" AllowWhenBroken="true">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Conditional HasTag="eq reactor" targetcontainer="true" />
            <Conditional conditionpercentage="lt 25" targetcontainer="true" />
            <Explosion range="1000" itemdamage="0.0" structuredamage="0.0" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false">
              <Affliction identifier="radiationsickness" strength="0.675" />
              <Affliction identifier="contaminated" strength="0.675" />
              <Affliction identifier="radiationsounds" strength="3.9" />
              <Affliction identifier="overheating" strength="0.45" />
            </Explosion>
          </StatusEffect>
          <!-- create smoke particles and an explosion that deals high item and structure damage to anything within 1m, if fission process was started and the fuel rod is not contained and not in water -->
          <StatusEffect type="OnNotContained" target="This" interval="0.2" comparison="And">
            <Conditional InWater="false" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Explosion range="100" itemdamage="3.5" structuredamage="3.5" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" />
            <ParticleEmitter particle="smoke" particlespersecond="75" scalemin="0.2" scalemax="0.5" anglemin="0" anglemax="359" velocitymin="-10" velocitymax="10" />
          </StatusEffect>
          <!-- create underwater bubble particles and an explosion that deals high item and structure damage to anything within 1m, if the fission process was started and the fuel rod is not contained and within water -->
          <StatusEffect type="OnNotContained" target="This" interval="0.2" comparison="And">
            <Conditional InWater="true" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Explosion range="100" itemdamage="3.5" structuredamage="3.5" ballastfloradamage="0" camerashake="0" camerashakerange="0" explosiondamage="0" force="0" flames="false" smoke="false" shockwave="false" sparks="false" flash="false" underwaterbubble="false" />
            <ParticleEmitter particle="damagebubbles" particlespersecond="75" scalemin="0.2" scalemax="0.5" anglemin="0" anglemax="359" velocitymin="-10" velocitymax="10" />
          </StatusEffect>
          <!-- spawn items that delete themselves randomly with a chance of 1/20 each second for an item to spawn that causes a fire to make the fuel rod randomly start fires if it's not contained and the fission process was started -->
          <StatusEffect type="OnNotContained" target="This" interval="1.0" SpawnItemRandomly="True" comparison="And">
            <!-- <Hook name="EnhancedReactors.Disable" /> -->
            <Conditional InWater="false" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_none" spawnposition="This" />
            <SpawnItem identifier="effect_firestarter" spawnposition="This" />
          </StatusEffect>
        </LightComponent>
        <!-- Requires both <Holdable> to apply burn when held as this doesn't work in other components and <Throwable> to make it throwable -->
        <Holdable handle1="0,0" slots="RightHand,LeftHand" msg="ItemMsgPickUpSelect" canBeCombined="false" throwforce="3.5" aimpos="35,-10">
          <!-- apply burn to the hands when holding the fuel rod if the fission process was started -->
          <StatusEffect type="Always" target="This,Character" targetlimbs="LeftHand,RightHand" interval="0.2" disabledeltatime="true" comparison="And">
            <Hook name="EnhancedReactors.Disable" />
            <Conditional HasTag="eq activefuelrod" />
            <Conditional HasStatusTag="eq nearcharacter" />
            <Conditional IsPlayer="eq true" />
            <Conditional HasTag="neq deepdivinglarge" targetcontainer="true" />
            <Conditional HasTag="neq containradiation" targetcontainer="true" />
            <Affliction identifier="burn" amount="5" />
          </StatusEffect>
          <!-- activate the LightComponent to trigger the OnActive StatusEffects and visualize that the fission process has started when the fuel rod was used inside an active reactor -->
          <StatusEffect type="Always" target="This" IsOn="True" tags="activefuelrod,provocative" setvalue="True" comparison="And" interval="1.1">
            <Conditional HasTag="eq reactor" targetcontainer="True" />
            <Conditional fissionrate="gt 1.0" targetcontainer="True" />
          </StatusEffect>
          <!-- activate the LightComponent to trigger the OnActive StatusEffects and visualize that the fission process has started when the fuel rod was spawned inside a wreck reactor -->
          <StatusEffect type="OnContained" target="This" IsOn="True" tags="activefuelrod,provocative" setvalue="True">
            <Conditional HasTag="eq wreckreactor" targetcontainer="True" />
          </StatusEffect>
          <StatusEffect type="OnContained" target="This" IsOn="True" tags="activefuelrod,provocative" setvalue="True" comparison="And">
            <Conditional HasStatusTag="eq wreckreactor" targetcontainer="True" />
          </StatusEffect>
          <!-- activate the LightComponent to trigger the OnActive StatusEffects and visualize that the fission process has started when the fuel rod was used inside an exosuit -->
          <StatusEffect type="OnContained" target="This" IsOn="True" tags="activefuelrod,provocative" setvalue="True">
            <Conditional HasTag="eq deepdivinglarge" targetcontainer="True" />
          </StatusEffect>
          <!-- Eat the fuel rod -->
          <!-- <StatusEffect type="OnUse" target="Character" disabledeltatime="true" setvalue="true" multiplyafflictionsbymaxvitality="true">
            <Conditional HasTag="activefuelrod" targetcontaineditem="True" />
            <Affliction identifier="fuelrodrage" amount="120" />
          </StatusEffect> -->
          <StatusEffect type="OnUse" target="This">
            <Conditional HasTag="activefuelrod" />
            <Sound file="%ModDir:3045796581%/Content/Items/Tools/gulp.ogg" volume="1" loop="false" range="500" />
            <Remove />
          </StatusEffect>
        </Holdable>
        <Throwable handle1="0,0" slots="RightHand,LeftHand" msg="ItemMsgPickUpSelect" canBeCombined="false" throwforce="3.5" aimpos="35,-10" />
        <Projectile characterusable="false" launchimpulse="15" impulsespread="0.01" sticktocharacters="true" sticktoitems="false" sticktostructures="false" sticktodoors="false">
          <Attack targetimpulse="3" severlimbsprobability="0.1" itemdamage="1" structuredamage="0" structuresoundtype="StructureSlash">
            <Affliction identifier="blunttrauma" strength="2" />
            <Affliction identifier="blunttrauma" strength="2" probability="0.25" />
            <Affliction identifier="stun" strength="0.2" />
          </Attack>
          <StatusEffect type="OnImpact" target="UseTarget">
            <Conditional entitytype="Character" />
            <Sound file="Content/Sounds/Damage/LimbSlash1.ogg" selectionmode="random" range="1000" />
            <Sound file="Content/Sounds/Damage/LimbSlash2.ogg" range="1000" />
            <Sound file="Content/Sounds/Damage/LimbSlash3.ogg" range="1000" />
            <Sound file="Content/Sounds/Damage/LimbSlash4.ogg" range="1000" />
            <Sound file="Content/Sounds/Damage/LimbSlash5.ogg" range="1000" />
            <Sound file="Content/Sounds/Damage/LimbSlash6.ogg" range="1000" />
          </StatusEffect>
        </Projectile>
        <Quality>
          <QualityStat stattype="Condition" value="0.1" />
        </Quality>
        <AiTarget sightrange="6000" />
      </Item>]])
  },
  -- Remove entirely (what even is this)
  ["ekutility_modfabricator"] = { mod = "EK Forked", xml = "" },
  -- Remove for now; broken (detonates in water)
  ["ek_impact_mine"] = { mod = "EK Forked", xml = "" },
  -- Remove for now; broken (detonates in water)
  ["ek_proximity_mine"] = { mod = "EK Forked", xml = "" },

  -- Make fusion reactors compatible with Enhanced Reactors
  --[=[["ekdockyard_reactorfusion_small"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
      ]])
  },
  ["ekdockyard_reactorfusion_medium"] = {
    mod = "EK Forked",
    xml = XElement.Parse([[
      ]])
  },]=]

  -- Character removals
  ["Ekdroneattackbeacon"] = { mod = "EK Forked", xml = "" },
  ["Ekdronerallybeacon"] = { mod = "EK Forked", xml = "" },
  ["Gundrone"] = { mod = "EK Forked", xml = "" },
  ["Gundrone_noiff"] = { mod = "EK Forked", xml = "" },
  ["Walkerdrone"] = { mod = "EK Forked", xml = "" },
  ["Walkerdrone_noiff"] = { mod = "EK Forked", xml = "" },

  -- Item removals
  ["ekdockyard_cargocompartment_freezer1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_craterack_freezer"] = { mod = "EK Forked", xml = "" },
  ["ekutility_securelockercaptain"] = { mod = "EK Forked", xml = "" },
  ["ekutility_securelockersecurityofficer"] = { mod = "EK Forked", xml = "" },
  ["ekutility_securelockermedicaldoctor"] = { mod = "EK Forked", xml = "" },
  ["ekutility_securelockermechanic"] = { mod = "EK Forked", xml = "" },
  ["ekutility_securelockerengineer"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_9mm"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_smg"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_rifle"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_shotgun"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_microtorpedo"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ek_ammocrate_rockets"] = { mod = "EK Forked", xml = "" },
  ["ek_weapons_case"] = { mod = "EK Forked", xml = "" },
  ["ekutility_mulecargo"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_beanbag"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_slug"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_hollowpoint"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_flechette"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_grenade"] = { mod = "EK Forked", xml = "" },
  ["ek_ammobox_shotgun_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_magazinestoragesmall"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_magazinestoragemedium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_text"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_iron"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_aluminium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_copper"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_titanium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_carbon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_lead"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_tin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_zinc"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_silicon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_uranium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_thorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_steel"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_titaniumaluminiumalloy"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_plastic"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_rubber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fpgacircuit"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_organicfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_ballisticfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fulgurium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sulphuriteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_oxygeniteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_incendium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_dementonite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_flashpowder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_lithium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sodium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_magnesium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_potassium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_chlorine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_calcium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_phosphorus"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_ethanol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sulphuricacid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_bandage"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_plastiseal"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_antibioticglue"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_tonicliquid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_saline"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_bloodpack"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_adrenaline"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_opium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_elastin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_alienblood"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_adrenalinegland"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_swimbladder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_paralyxis"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_huskeggs"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fiberplant"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_elastinplant"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_aquaticpoppy"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_yeastshroom"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_slimebacteria"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_creepingorange"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_tobaccobud"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_saltbulb"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_raptorbane"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_stabilozine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_morphine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fentanyl"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_deusizine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_naloxone"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_haloperidol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_methamphetamine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_steroids"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_hyperzine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_liquidoxygenite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_antibiotics"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_chloralhydrate"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_calyxanide"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_raptorbaneextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_pomegrenadeextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_cyanide"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_cyanideantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sufforin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sufforinantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_morbusine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_morbusineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_radiotoxin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_antirad"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_deliriumine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_deliriumineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_paralyzant"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_antiparalysis"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_reactorfuel"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_wrench"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_screwdriver"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_crowbar"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_weldingtool"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_plasmacutter"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_flamer"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fireextinguisher"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_flare"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_flashlight"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_oxygentank"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_weldingfueltank"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_batterycell"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_fulguriumbatterycell"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_headset"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_divingmask"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_underwaterscooter"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_handheldsonar"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_sonarbeacon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_miningdrill"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_metalfoam_tank"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_metalfoam_gun"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_pulsecutter"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_laserdrill"] = { mod = "EK Forked", xml = "" },
  ["ekutility_label_arcwelder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_labelprinter"] = { mod = "EK Forked", xml = "" },
  ["ekutility_reinforcedtank_oxygen"] = { mod = "EK Forked", xml = "" },
  ["ekutility_reinforcedtank_oxygenite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_oxygencell1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_oxygencell2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_advancedsonarbeacon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_Utility_hardsuit"] = { mod = "EK Forked", xml = "" },
  ["ekutility_Utility_hardsuit_mk2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_utility_hardsuit_paintmechanic"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit_paintbandit"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit_paintmercenary"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit2"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit2_paintbandit"] = { mod = "EK Forked", xml = "" },
  ["ek_armored_hardsuit2_paintmercenary"] = { mod = "EK Forked", xml = "" },
  ["shearclaw"] = { mod = "EK Forked", xml = "" },
  ["shearclaw_helmet"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_door"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_windoweddoor"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_hatch"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_doorwbuttons"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_windoweddoorwbuttons"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_vanillafix_hatchwbuttons"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1red"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1blue"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1orange"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1green"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1black"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_customwire_pipe1bracket"] = { mod = "EK Forked", xml = "" },
  ["ek_marine_armor"] = { mod = "EK Forked", xml = "" },
  ["ek_marine_armor_uniform"] = { mod = "EK Forked", xml = "" },
  ["ek_marine_helmet"] = { mod = "EK Forked", xml = "" },
  ["ek_renegade_armor"] = { mod = "EK Forked", xml = "" },
  ["ek_renegade_armor_uniform"] = { mod = "EK Forked", xml = "" },
  ["ek_renegade_helmet"] = { mod = "EK Forked", xml = "" },
  ["ek_merc_armor"] = { mod = "EK Forked", xml = "" },
  ["ek_merc_armor_uniform"] = { mod = "EK Forked", xml = "" },
  ["ek_merc_helmet"] = { mod = "EK Forked", xml = "" },
  ["ek_mechanic_armor"] = { mod = "EK Forked", xml = "" },
  ["ek_tacticalbackpack"] = { mod = "EK Forked", xml = "" },
  ["ek_weaponparts"] = { mod = "EK Forked", xml = "" },
  ["ek_loadingkit"] = { mod = "EK Forked", xml = "" },
  ["ek_weapontritium"] = { mod = "EK Forked", xml = "" },
  ["ek_gaussparts"] = { mod = "EK Forked", xml = "" },
  ["ek_laserparts"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_iron"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_aluminium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_copper"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_titanium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_carbon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_lead"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_tin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_zinc"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_silicon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_steel"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_titaniumaluminiumalloy"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_plastic"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_rubber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_fpgacircuit"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_organicfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_ballisticfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_uranium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_thorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_depleteduranium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_flashpowder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_lithium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_sodium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_magnesium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_potassium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_chlorine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_calcium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_phosphorus"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_ethanol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_sulphuricacid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_uex"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_c4block"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_compoundn"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_ic4block"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_fulgurium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_sulphuriteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_oxygeniteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_incendium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_dementonite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibleeding1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibleeding2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibleeding3"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_tonicliquid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibloodloss1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibloodloss2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_adrenaline"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_opium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_elastin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_alienblood"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_paralyxis"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_huskeggs"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_stabilozine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_morphine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_naloxone"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_haloperidol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_meth"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_steroids"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_liquidoxygenite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antibiotics"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_chloralhydrate"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_calyxanide"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_raptorbaneextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_pomegrenadeextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_cyanideantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_sufforinantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_morbusineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antirad"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_deliriumineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_smalldensifiedmaterial_antiparalysis"] = { mod = "EK Forked", xml = "" },
  ["materialsrequisitioncard"] = { mod = "EK Forked", xml = "" },
  ["restrictedrequisitioncard"] = { mod = "EK Forked", xml = "" },
  ["exoticrequisitioncard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_iron"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_aluminium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_copper"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_titanium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_carbon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_lead"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_tin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_zinc"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_silicon"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_steel"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_titaniumaluminiumalloy"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_plastic"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_rubber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_fpgacircuit"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_organicfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_ballisticfiber"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_uranium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_thorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_depleteduranium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_flashpowder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_lithium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_sodium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_magnesium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_potassium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_chlorine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_calcium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_phosphorus"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_ethanol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_sulphuricacid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_uex"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_c4block"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_compoundn"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_ic4block"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_fulgurium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_sulphuriteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_oxygeniteshard"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_incendium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_dementonite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibleeding1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibleeding2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibleeding3"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_tonicliquid"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibloodloss1"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibloodloss2"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_adrenaline"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_opium"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_elastin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_alienblood"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_adrenalinegland"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_swimbladder"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_paralyxis"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_huskeggs"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_stabilozine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_morphine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_fentanyl"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_deusizine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_naloxone"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_haloperidol"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_meth"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_steroids"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_hyperzine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_liquidoxygenite"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antibiotics"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_chloralhydrate"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_calyxanide"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_raptorbaneextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_pomegrenadeextract"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_cyanide"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_cyanideantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_sufforin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_sufforinantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_morbusine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_morbusineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_radiotoxin"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antirad"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_deliriumine"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_deliriumineantidote"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_paralyzant"] = { mod = "EK Forked", xml = "" },
  ["ekutility_densifiedmaterial_antiparalysis"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablepipe1"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablepipe2"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablepipe3"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablepipe4"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablevent1"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablevent2"] = { mod = "EK Forked", xml = "" },
  ["ekdockyard_scalablevent3"] = { mod = "EK Forked", xml = "" },
  ["jovianidentitycard"] = { mod = "EK Forked", xml = "" },
  ["coalitionidcard1"] = { mod = "EK Forked", xml = "" },
  ["shopmachine"] = { mod = "EK Forked", xml = "" },
  ["crateshopmachine"] = { mod = "EK Forked", xml = "" },
  ["renegadeshopradio"] = { mod = "EK Forked", xml = "" },
  ["coalitionshopradio"] = { mod = "EK Forked", xml = "" },
  ["ekutility_reinforcedtank_weldingfuel"] = { mod = "EK Forked", xml = "" },
  ["ekutility_heavytank_incendium"] = { mod = "EK Forked", xml = "" },
  ["ek_hv_battery"] = { mod = "EK Forked", xml = "" },
  ["ekutility_medicalscanner"] = { mod = "EK Forked", xml = "" },
  ["ekutility_guicompass"] = { mod = "EK Forked", xml = "" },
  ["ekutility_longrangeradio"] = { mod = "EK Forked", xml = "" },
  ["ekutility_sledgehammer"] = { mod = "EK Forked", xml = "" },
  ["ekutility_miningbackpack"] = { mod = "EK Forked", xml = "" },
  ["ekutility_medicalbackpack"] = { mod = "EK Forked", xml = "" },
  ["ekutility_surgicalplaceholderitem"] = { mod = "EK Forked", xml = "" },
  ["ekutility_portablepump"] = { mod = "EK Forked", xml = "" },
  ["suppressor"] = { mod = "EK Forked", xml = "" },
  ["notsuppressor"] = { mod = "EK Forked", xml = "" },
  ["taclaser"] = { mod = "EK Forked", xml = "" },
  ["ek_drone_beacon"] = { mod = "EK Forked", xml = "" },
  ["ek_drone_beaconattack"] = { mod = "EK Forked", xml = "" },
  ["ek_gundrone"] = { mod = "EK Forked", xml = "" },
  ["ek_gundrone_wreck"] = { mod = "EK Forked", xml = "" },
  ["ek_walkerdrone"] = { mod = "EK Forked", xml = "" },
  ["ek_walkerdrone_turret"] = { mod = "EK Forked", xml = "" },
  ["ek_walkerdrone_wreck"] = { mod = "EK Forked", xml = "" },
  ["ek_drone_multitool"] = { mod = "EK Forked", xml = "" },
  ["ek_hatchet"] = { mod = "EK Forked", xml = "" },
  ["ek_captains_sabre"] = { mod = "EK Forked", xml = "" },
  ["ek_tonfa"] = { mod = "EK Forked", xml = "" },
  ["ek_throwingknife"] = { mod = "EK Forked", xml = "" },
  ["ek_piperifle"] = { mod = "EK Forked", xml = "" },
  ["ek_piperound"] = { mod = "EK Forked", xml = "" },
  ["ek_piperound_alien"] = { mod = "EK Forked", xml = "" },
  ["ek_revolver_flare"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_magextended"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_round"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_alienmag"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_alienround"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_riot_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_handgun_riot_round"] = { mod = "EK Forked", xml = "" },
  ["ek_smg"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_round"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_alienmag"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_alienround"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_riot_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_smg_riot_round"] = { mod = "EK Forked", xml = "" },
  ["ek_riotshield"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle_round_slug"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle_round"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle_round_shortfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle_round_tazer"] = { mod = "EK Forked", xml = "" },
  ["ek_torpedorifle_round_alien"] = { mod = "EK Forked", xml = "" },
  ["ek_flaregun"] = { mod = "EK Forked", xml = "" },
  ["ek_flare_round"] = { mod = "EK Forked", xml = "" },
  ["ek_flareshell_effect"] = { mod = "EK Forked", xml = "" },
  ["ek_double_shotgun"] = { mod = "EK Forked", xml = "" },
  ["ek_tactical_shotgun"] = { mod = "EK Forked", xml = "" },
  ["ek_tazer"] = { mod = "EK Forked", xml = "" },
  ["ek_tazer_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_tazer_round"] = { mod = "EK Forked", xml = "" },
  ["ek_flamethrower"] = { mod = "EK Forked", xml = "" },
  ["ek_flamer_fuel"] = { mod = "EK Forked", xml = "" },
  ["ek_flamer_incendium"] = { mod = "EK Forked", xml = "" },
  ["ek_hypergolic_fuel"] = { mod = "EK Forked", xml = "" },
  ["ek_alienrifle"] = { mod = "EK Forked", xml = "" },
  ["ek_alienrifle_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_alienrifle_round"] = { mod = "EK Forked", xml = "" },
  ["ek_micro_dartgun"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_hemostat"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_stabilozine"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_morphine"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_fentanyl"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_calyxanide"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_haloperidol"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_oxygenite"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_steroids"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_antiparalysis"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_chloralhydrate"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_deliriumine"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_acid"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_cyanide"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_radiotoxin"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_morbusine"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_sufforin"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_paralyzant"] = { mod = "EK Forked", xml = "" },
  ["ek_dart_raptorbane"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_round"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_alienmag"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_alienround"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_riot_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_mini_smg_riot_round"] = { mod = "EK Forked", xml = "" },
  ["ek_rocketlauncher"] = { mod = "EK Forked", xml = "" },
  ["ek_rocketammo_explosive"] = { mod = "EK Forked", xml = "" },
  ["ek_rocketammo_shortfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_rocketammo_armorpiercing"] = { mod = "EK Forked", xml = "" },
  ["ek_rocketammo_alien"] = { mod = "EK Forked", xml = "" },
  ["ek_gausspistol"] = { mod = "EK Forked", xml = "" },
  ["ek_gausspistol_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_gausspistol_round"] = { mod = "EK Forked", xml = "" },
  ["ek_gaussrifle"] = { mod = "EK Forked", xml = "" },
  ["ek_gaussrifle_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_gaussrifle_round"] = { mod = "EK Forked", xml = "" },
  ["ek_drumlmg"] = { mod = "EK Forked", xml = "" },
  ["ek_drumlmg_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_drumlmg_round"] = { mod = "EK Forked", xml = "" },
  ["ek_drumlmg_alienmag"] = { mod = "EK Forked", xml = "" },
  ["ek_drumlmg_alienround"] = { mod = "EK Forked", xml = "" },
  ["ek_smokegrenade"] = { mod = "EK Forked", xml = "" },
  ["ek_battlerifle"] = { mod = "EK Forked", xml = "" },
  ["ek_battlerifle_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_battlerifle_alien_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_battlerifle_riot_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_beast_ssl"] = { mod = "EK Forked", xml = "" },
  ["ek_ssl_magazine"] = { mod = "EK Forked", xml = "" },
  ["ek_ssl_round"] = { mod = "EK Forked", xml = "" },
  ["ek_ied"] = { mod = "EK Forked", xml = "" },
  ["ek_explosivecharge_uex"] = { mod = "EK Forked", xml = "" },
  ["ek_explosivecharge_nuke"] = { mod = "EK Forked", xml = "" },
  ["ek_laserpistol"] = { mod = "EK Forked", xml = "" },
  ["ek_laserpistol_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_laserpistol_round"] = { mod = "EK Forked", xml = "" },
  ["ek_laserrifle"] = { mod = "EK Forked", xml = "" },
  ["ek_laserrifle_mag"] = { mod = "EK Forked", xml = "" },
  ["ek_laserrifle_round"] = { mod = "EK Forked", xml = "" },
  ["ek_revolver"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverammo"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverspeedloader"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverammo_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverspeedloader_physicorium"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverammo_riot"] = { mod = "EK Forked", xml = "" },
  ["ek_revolverspeedloader_riot"] = { mod = "EK Forked", xml = "" },
  ["ek_spear_rocket"] = { mod = "EK Forked", xml = "" },
  ["ek_40mmsmoke_effect"] = { mod = "EK Forked", xml = "" },
  ["ek_40mmsmoke"] = { mod = "EK Forked", xml = "" },
  ["ek_40mmbeehive"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_smallflare_effect"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_megaflare_effect"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_flechette"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_flechette_pellet"] = { mod = "EK Forked", xml = "" },
  ["halfshellbox"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_halfshells"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_halfshells_piercingslug"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_halfshell_piercingslug"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_halfshells_alien"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_halfshell_alien"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_flak"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_flak_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_piercingslug"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_armorpiercing"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_fusion_effect"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_fusion"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_fusion_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_railgun_flare_effect"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_flare"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_incendiary"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_highvelocity"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_hypervelocity"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_ultravelocity"] = { mod = "EK Forked", xml = "" },
  ["ek_railshell_chaff"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_container"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_radiation"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_cyanide_cloud"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_cyanide"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_paralyzant_cloud"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_paralyzant"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_radiotoxin_cloud"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_radiotoxin"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_flare"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_chaff_cloud"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_chaff_aitarget"] = { mod = "EK Forked", xml = "" },
  ["ek_depthcharge_chaff"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_heavyrailgunflechetteshell"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_heavyrailgunflechettepellet"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_chaingunpiercingexplosiveammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_chaingunpiercingexplosiveround"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunammo_large"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunammophysicorium_large"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunammoexplosive_large"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunboltexplosive"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunammoheavy"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunammoheavy_large"] = { mod = "EK Forked", xml = "" },
  ["ek_chaingunboltheavy"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflechetteammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflechetteround"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflechettepellet"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflakammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflakround"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflakammo_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflakround_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonarmorpiercingammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonarmorpiercinground"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflareammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_autocannonflareround"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_mircosslpiercingexplosiveammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_smallsslarmorpiercingammo"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_smallsslarmorpiercinground"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_mediumsslrocket_flak"] = { mod = "EK Forked", xml = "" },
  ["ekgunnery_mediumsslrocket_flak_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammo_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammoexplosive_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammopiercing_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammophysicorium_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammoboxheavy"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammoheavy_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunboltheavy"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybrid"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybrid_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybrid"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridflak"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridflak_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybridflak"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridflak_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridflak_smartfuse_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybridflak_smartfuse"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridap"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridap_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybridap"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammo_laser"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_laser"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridtoxin"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybridtoxin"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohybridflare"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolt_hybridflare"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohighvelocity"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunammohighvelocity_large"] = { mod = "EK Forked", xml = "" },
  ["ek_coilgunbolthighvelocity"] = { mod = "EK Forked", xml = "" },
  ["1markcoin"] = { mod = "EK Forked", xml = "" },
  ["5markscoin"] = { mod = "EK Forked", xml = "" },
  ["10markbill"] = { mod = "EK Forked", xml = "" },
  ["25markbill"] = { mod = "EK Forked", xml = "" },
  ["50markbill"] = { mod = "EK Forked", xml = "" },
  ["100markbill"] = { mod = "EK Forked", xml = "" },
  ["200markbill"] = { mod = "EK Forked", xml = "" },
}

-- Setting line to an empty string replaces the whole file
-- Use "startLine" and "endLine" if you have a multi-line replacement
Auto.LuaChanges = {
  -- ***********
  -- Neurotrauma
  -- ***********
  -- 1. Patch lockedhands to work with Immersive Handcuffs' system
  -- 2. Make thiamine heal organs much faster
  -- 3. Add luabotomy if it doesn't exist
  ["Neurotrauma/Lua/Scripts/Server/humanupdate.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      {
        startLine = 820,
        endLine = 860,
        replace = [[
    lockedhands = {
		update = function(c, i)
			-- arm locking
			local leftlockitem = c.character.Inventory.FindItemByIdentifier("armlock2", false)
			local rightlockitem = c.character.Inventory.FindItemByIdentifier("armlock1", false)

			-- handcuffs
			local handcuffed = HF.HasAffliction(c.character, "handcuffed")
			local leftHandItem = HF.GetItemInLeftHand(c.character)
			local rightHandItem = HF.GetItemInRightHand(c.character)
			if handcuffed then
				-- drop non-handcuff items
				if leftHandItem ~= nil
				and tostring(leftHandItem.Prefab.Identifier) ~= "handcuffsequipped"
				and tostring(rightHandItem.Prefab.Identifier) ~= "handcuffsequipped2" then
					leftHandItem.Drop(c.character)
				end
				if rightHandItem ~= nil
				and tostring(rightHandItem.Prefab.Identifier) ~= "handcuffsequipped"
				and tostring(rightHandItem.Prefab.Identifier) ~= "handcuffsequipped2" then
					rightHandItem.Drop(c.character)
				end
				if leftHandItem == nil and rightHandItem == nil then
					local prefab = ItemPrefab.GetItemPrefab("handcuffsequipped")
					Entity.Spawner.AddItemToSpawnQueue(prefab, c.character.WorldPosition, nil, nil, function(newitem)
						c.character.Inventory.TryPutItem(newitem, nil, { InvSlotType.RightHand, InvSlotType.LeftHand })
					end)
				end
			else -- FAILSAFE: drop handcuffs if no "handcuffed" affliction
				if leftHandItem ~= nil
				and (tostring(leftHandItem.Prefab.Identifier) == "handcuffsequipped"
				or tostring(leftHandItem.Prefab.Identifier) == "handcuffsequipped2") then
					leftHandItem.Drop(c.character)
				end
				if rightHandItem ~= nil
				and (tostring(rightHandItem.Prefab.Identifier) == "handcuffsequipped"
				or tostring(rightHandItem.Prefab.Identifier) == "handcuffsequipped2") then
					rightHandItem.Drop(c.character)
				end
			end

			local leftarmlocked = leftlockitem ~= nil and not handcuffed
			local rightarmlocked = rightlockitem ~= nil and not handcuffed

			if leftarmlocked and not c.stats.lockleftarm then
				HF.RemoveItem(leftlockitem)
			end
			if rightarmlocked and not c.stats.lockrightarm then
				HF.RemoveItem(rightlockitem)
			end

			if not leftarmlocked and c.stats.lockleftarm and not handcuffed then
				HF.ForceArmLock(c.character, "armlock2")
			end
			if not rightarmlocked and c.stats.lockrightarm and not handcuffed then
				HF.ForceArmLock(c.character, "armlock1")
			end

			c.afflictions[i].strength = HF.BoolToNum((c.stats.lockleftarm and c.stats.lockrightarm) or handcuffed, 100)
		end,
	},
	},]]
      },
      {
        line = 1781,
        replace = [[
				+ HF.Clamp(c.afflictions.afthiamine.strength, 0, 1) * 20]]
      },
      {
        line = 1963,
        replace = [[
      HF.SetAffliction(character, "luabotomy", 0.1)
		  return]]
      },
    }
  },
  -- Patch Neurotrauma's multiscalpels to also accept blood scalpels
  ["Neurotrauma/Lua/Scripts/Server/multiscalpel.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 81, replace = "		if item.Prefab.Identifier.Value == \"multiscalpel\" or item.Prefab.Identifier.Value == \"multiscalpel_blood\" then" },
    }
  },
  -- Remove the annoying modconflict thing
  ["Neurotrauma/Lua/Scripts/Server/modconflict.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      {
        startLine = 10,
        endLine = 27,
        replace = [=[
	--[[NT.modconflict = false
	if NTConfig.Get("NT_ignoreModConflicts", false) then
		return
	end

	local itemsToCheck = { "antidama2", "opdeco_hospitalbed" }

	for prefab in ItemPrefab.Prefabs do
		if HF.TableContains(itemsToCheck, prefab.Identifier.Value) then
			local mod = prefab.ConfigElement.ContentPackage.Name
			if not string.find(string.lower(mod), "neurotrauma") then
				NT.modconflict = true
				print("Found Neurotrauma incompatibility with mod: ", mod)
				print("WARNING! mod conflict detected! Neurotrauma may not function correctly and requires a patch!")
				return
			end
		end
	end]]]=]
      },
    }
  },
  -- Remove testing functions
  ["Neurotrauma/Lua/Scripts/testing.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 1, replace = "do return end" },
    }
  },
  -- Modify require() paths
  ["Neurotrauma/Lua/ConsentRequiredExtended/Util/Barotrauma.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 3, replace = "local Environment = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Environment'" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/Util/Clr.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 3, replace = "local Environment = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Environment'" },
      { line = 6, replace = "local UserData = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.UserData'" }
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/Util/UserData.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 3, replace = "local Environment = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Environment'" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/Api.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 4, replace = "local Environment = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Environment'" },
      { line = 5, replace = "local Barotrauma = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Barotrauma\")" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/Config.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 2, replace = "local Environment = require 'workshop.Neurotrauma.Lua.ConsentRequiredExtended.Util.Environment'" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/init.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 13, replace = "	local requireStr = \"workshop.Neurotrauma.Lua.\" .. SRC_NAMESPACE .. MAIN" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/Main.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 7,  replace = "local Api = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Api\")" },
      { line = 8,  replace = "local OnItemApplied = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.OnItemApplied\")" },
      { line = 9,  replace = "local onMeleeWeaponHandleImpact = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.onMeleeWeaponHandleImpact\")" },
      { line = 10, replace = "local onHandleProjectileCollision = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.onHandleProjectileCollision\")" },
      { line = 11, replace = "local Config = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Config\")" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/onHandleProjectileCollision.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 1,  replace = "local Api = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Api\")" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/OnItemApplied.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 1, replace = "local Api = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Api\")" },
    }
  },
  ["Neurotrauma/Lua/ConsentRequiredExtended/onMeleeWeaponHandleImpact.lua"] = {
    mod = "Neurotrauma",
    replacements = {
      { line = 1, replace = "local Api = require(\"workshop.Neurotrauma.Lua.ConsentRequiredExtended.Api\")" },
    }
  },

  -- **************
  -- Mercy Hospital
  -- **************
  -- Remove testing functions
  ["Mercy Hospital Updated/Lua/Scripts/testing.lua"] = {
    mod = "Mercy Hospital Updated",
    replacements = {
      { line = 1, replace = "do return end" },
    }
  },

  -- *******
  -- NT Eyes
  -- *******
  -- 1. Make monsters have purple night vision
  -- 2. Change ambient light to pitch black if you have regular human eyes
  -- 3. Give spectators slight night vision
  ["NT Eyes/Lua/Scripts/Client/clientUpdate.lua"] = {
    mod = "NT Eyes",
    replacements = {
      {
        startLine = 56,
        endLine = 57,
        replace = [[
		levelColor = Color(0, 0, 0, 0),
		hullColor = Color(0, 0, 0, 0),]]},
      {
        startLine = 166,
        endLine = 200,
        replace = [[
function NTEYE.UpdateLights()
	local ControlledCharacter = Character.Controlled
	local LevelLight = Level.Loaded.LevelData.GenerationParams
	-- Very slight night vision inside the sub for spectators
	if not Megamod_Client.LightMapOverride.IsMonsterAntagonist
	and (not ControlledCharacter or ControlledCharacter.IsDead) then
		LevelLight.AmbientLightColor = Color(0, 0, 0, 0)
		for _, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(29, 29, 29, 9)
		end
		return
	-- Prevent human night vision during Hunts
	elseif Megamod_Client.LightMapOverride.HuntActive
	and ControlledCharacter and ControlledCharacter.IsHuman then
		LevelLight.AmbientLightColor = Color(0, 0, 0, 0)
		for _, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(0, 0, 0, 0)
		end
		return
	-- If we are a monster, give purple night vision
	elseif (ControlledCharacter and not ControlledCharacter.IsHuman)
	or Megamod_Client.LightMapOverride.IsMonsterAntagonist then
		LevelLight.AmbientLightColor = Color(25, 0, 75, 40)
		for _, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(50, 0, 200, 75)
		end
		return
	-- Reset to normal if we aren't a monster and we still have monster vision
	elseif LevelLight.AmbientLightColor == Color(25, 0, 75, 40) then
		LevelLight.AmbientLightColor = Color(0, 0, 0, 0)
		for _, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(0, 0, 0, 0)
		end
		return
	end

	--define color tables
	local levelColors, hullColors = {}, {}
	for _, effect in pairs(NTEYE.ClientEffects) do
		if HF.HasAffliction(ControlledCharacter, effect.affliction) then
			levelColors[#levelColors + 1] = effect.levelColor
			hullColors[#hullColors + 1] = effect.hullColor
		end
	end
	if #levelColors == 0 and #hullColors == 0 then
		return
	end
	local LevelColor = BlendColors(levelColors)
	local HullColor = BlendColors(hullColors)
	LevelLight.AmbientLightColor = LevelColor
	for _, HullLight in pairs(Hull.HullList) do
		HullLight.AmbientLight = HullColor
	end
end]]},
    }
  },
  -- Remove debug print()s
  ["NT Eyes/Lua/Scripts/Server/humanupdate.lua"] = {
    mod = "NT Eyes",
    replacements = {
      { -- Remove debug print()
        line = 145,
        replace = ""
      },
      { -- Remove debug print()
        line = 149,
        replace = ""
      },
    }
  },

  -- **************
  -- NT Bio Printer
  -- **************
  -- Remove debug print()
  ["NT Bio Printer/Lua/Scripts/Server/EmptySyringe.lua"] = {
    mod = "NT Bio Printer",
    replacements = {
      {
        line = 17,
        replace = ""
      }
    }
  },

  -- *************
  -- NT BrainTrans
  -- *************
  -- Don't give all characters AI
  ["NT BrainTrans/Lua/Scripts/hooks.lua"] = {
    mod = "NT BrainTrans (Beta)",
    replacements = {
      {
        startLine = 3,
        endLine = 17,
        replace = ""
      }
    }
  },
  -- Make JobUpdate networking override the character's name if it was a sleeve
  ["NT BrainTrans/Lua/Scripts/helperfunctions.lua"] = {
    mod = "NT BrainTrans (Beta)",
    replacements = {
      {
        line = 48,
        replace = [[
        updateMessage.WriteBoolean(wasSleeve)
        if wasSleeve then
            updateMessage.WriteString(tostring(clientName))
        end
        -- Timer.Wait(function()]]
      },
      {
        line = 101,
        replace = [[
        local wasSleeve = message.ReadBoolean()
        local sleeveInfo = {}
        if wasSleeve then
            sleeveInfo.Name = message.ReadString()
        end]]
      },
      {
        line = 116,
        replace = [[
                if wasSleeve then
                    character.Info.Name = tostring(sleeveInfo.Name)
                end]]
      }
    }
  },

  -- ***********************
  -- NT Cybernetics Enhanced
  -- ***********************
  -- Remove testing functions
  ["NT Cybernetics Enhanced/Lua/Scripts/testing.lua"] = {
    mod = "NT Cybernetics Enhanced",
    replacements = {
      { line = 1, replace = "do return end" },
    }
  },

  -- ***********
  -- NT Symbiote
  -- ***********
  -- Remove testing functions
  ["NT Symbiote/Lua/Scripts/testing.lua"] = {
    mod = "NT Symbiote",
    replacements = {
      { line = 1, replace = "do return end" },
    }
  },

  -- *************
  -- NT Infections
  -- *************
  -- Nothing for now

  -- ******************
  -- Enhanced Immersion
  -- ******************
  -- Modify require() paths
  ["Enhanced Immersion/Lua/Autorun/init.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 2, replace = "EI = require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.init'" },
    }
  },
  ["Enhanced Immersion/Lua/EnhancedImmersion/Config/init.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 8, replace = "config.Default = require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.Config.default'" },
    }
  },
  ["Enhanced Immersion/Lua/EnhancedImmersion/Scripts/Hooks/client.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 4, replace = "local utils = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Utils.utils')" },
      { line = 5, replace = "local menu = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Scripts.menu')" },
    }
  },
  ["Enhanced Immersion/Lua/EnhancedImmersion/Scripts/Hooks/shared.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 6, replace = "local utils = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Utils.utils')" },
    }
  },
  ["Enhanced Immersion/Lua/EnhancedImmersion/Scripts/menu.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 4, replace = "local gui = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Utils.gui')" },
      { line = 5, replace = "local utils = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Utils.utils')" },
      { line = 6, replace = "local config = require('workshop.Enhanced Immersion.Lua.EnhancedImmersion.Config.init')" },
    }
  },
  ["Enhanced Immersion/Lua/EnhancedImmersion/init.lua"] = {
    mod = "Enhanced Immersion",
    replacements = {
      { line = 8,  replace = "   Config = require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.Config.init'," },
      { line = 12, replace = "   Client = CLIENT and require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.Scripts.Hooks.client'," },
      { line = 13, replace = "   Server = (SERVER or Game.IsSingleplayer) and require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.Scripts.Hooks.server'," },
      { line = 14, replace = "   Shared = require 'workshop.Enhanced Immersion.Lua.EnhancedImmersion.Scripts.Hooks.shared'," },
    }
  },

  -- ***************
  -- Pickup Notifier
  -- ***************
  -- Modify require() paths
  ["Pickup Notifier/Lua/Autorun/init.lua"] = {
    mod = "Pickup Notifier",
    replacements = {
      { line = 2, replace = "local _713 = require 'workshop.Pickup Notifier.Lua._713.init'" },
      { line = 3, replace = "_713.mods.pickupnotifier = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.init'" },
    }
  },
  ["Pickup Notifier/Lua/_713/pickupnotifier/hooks/client.lua"] = {
    mod = "Pickup Notifier",
    replacements = {
      { line = 3, replace = "local data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'" },
      { line = 4, replace = "local utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'" },
    }
  },
  --[[["Pickup Notifier/Lua/_713/pickupnotifier/hooks/shared.lua"] = {
    mod = "Pickup Notifier",
    replacements = {
      { line = 3, replace = "local data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'" },
      { line = 4, replace = "local utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'" },
    }
  },]]
  ["Pickup Notifier/Lua/_713/pickupnotifier/init.lua"] = {
    mod = "Pickup Notifier",
    replacements = {
      { line = 5, replace = "mod.data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'" },
      { line = 6, replace = "mod.utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'" },
      --{ line = 9, replace = "   shared = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.hooks.shared'," },
      { line = 9, replace = "   client = CLIENT and require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.hooks.client' or nil" },
    }
  },
  ["Pickup Notifier/Lua/_713/pickupnotifier/utils.lua"] = {
    mod = "Pickup Notifier",
    replacements = {
      { line = 3, replace = "local data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'" },
      { line = 32, replace = "   local subdirectory = \"/Workshop/Pickup Notifier/PickupNotifier/Sounds/\"" },
    }
  },
}

Auto.ModTable = {
  [2518816103] = { name = "Barotraumatic", version = "1.0.230" },
  [3434409381] = { name = "CC's UAPM [building] Fork", version = "1.0.10" },
  [3368559590] = { name = "Chimera Remake", version = "1.7" },
  [2807566753] = { name = "Dont Open Debug Console On Errors", version = "1.0.5" },
  [3434408187] = { name = "EK Forked", version = "1.2.149" },
  [2764968387] = { name = "Enhanced Armaments", version = "1.19" },
  [2976013863] = { name = "Enhanced Armaments Fuel for the Fire Expansion", version = "1.6.8" },
  [2968896556] = { name = "Enhanced Immersion", version = "1.0.24" },
  [3045796581] = { name = "Enhanced Reactors", version = "1.0.35" },
  [2829557108] = { name = "Extract It!", version = "2.0.1" },
  [2914415949] = { name = "Husk Church Cathedral Visual Pack", version = "1.0.8" },
  [3089776991] = { name = "Immersive Ammunition Boxes", version = "1.0.4" },
  [3239164008] = { name = "Immersive Crates", version = "1.0.6" },
  [3337851889] = { name = "Immersive Crates - Mod Crates Compatibility Patch", version = "1.0.1" },
  [3074045632] = { name = "Immersive Diving Gear", version = "1.0.19" },
  [3321850228] = { name = "Immersive Handcuffs", version = "1.0.10" },
  [3217556378] = { name = "Immersive Ignitables", version = "1.0.11" },
  [3231351969] = { name = "Immersive Ignitables Expansion Pack", version = "1.9.7" },
  [3114087512] = { name = "Immersive Repairs", version = "1.0.36" },
  [3172965454] = { name = "Immersive Sonar UI - A Real Sonar Add-On", version = "1.0.4" },
  [3005836987] = { name = "Improved  Stun", version = "5.6" },
  [3355559986] = { name = "Mercy Hospital Updated", version = "1.0.5" },
  [3190189044] = { name = "Neurotrauma", version = "1.0.24" },
  [3339841986] = { name = "Normalized Flashlight", version = "1.0.3" },
  [3429100373] = { name = "NT Bio Printer", version = "1.0.2" },
  [3400663333] = { name = "BrainTrans", version = "1.0.4" },
  [3324062208] = { name = "NT Cybernetics Enhanced", version = "1.1.4" },
  [3294574390] = { name = "NT Eyes", version = "2.1.0h2" },
  [3286567141] = { name = "NT Infections", version = "1.5.5" },
  [3326291860] = { name = "NT Lobotomy", version = "1.0.1h4" },
  [3478084070] = { name = "NT Surgery Plus", version = "1.3.0" },
  [3478666406] = { name = "NT Symbiote", version = "1.0.0" },
  [2701251094] = { name = "Performance Fix", version = "1.0.15" },
  [3277215877] = { name = "Pickup Notifier", version = "0.3.4" },
  [3293221471] = { name = "Pile Bunker v2.0", version = "v2.23" },
  [3033618197] = { name = "Pure Empty Level", version = "1.5" },
  [2936760984] = { name = "Real Sonar", version = "2.1.0" },
  [2965750397] = { name = "Real Sonar Medical Item Recipes Patch for Neurotrauma", version = "1.4.2" },
  [2962899782] = { name = "Rift Engine", version = "1.0.32" },
  [2526456135] = { name = "SOFA'S DECO", version = "1.0.2" },
  [3486903116] = { name = "Stun Gun Revamp", version = "1.0.1" },
  [3304206956] = { name = "Traitor Alike Items", version = "0.4" },
  [3437714291] = { name = "Tweaked Glowlers", version = "1.0" },
  [3018824355] = { name = "Verdant Variety", version = "1.3.6" },
  [2161488150] = { name = "Visual Variety Pack", version = "1.0.8" },
  --[3329396988] = { name = "Network Tweaks", version = "0" } Small enough to just shove it in mega init.lua
  --[3323344505] = { name = "Immersive Handcuffs - Stun Required Patch", version = "0" } Small enough to just have as an XML override in auto.lua
  --[2831987252] = { name = "Barotraumatic Creature Pack", version = "1.0.181" }, No longer needed; part of Barotraumatic
  --[3543916066] = { name = "Ammo Penetrate Corpse", version = "1.0.8" }, Mod is entirely CSharp, so it can't be automated (yet)
}

local declaration = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"

Auto.FileListXML = {}
Auto.PFHighPriorityList = {}
Auto.VariantList = {}

-- Stuff to add to the filelist
Auto.MMFiles = [[
<Submarine file="%ModDir%/Megamod/Subs/Stations/Sierra Station.sub" />
<Submarine file="%ModDir%/Megamod/Subs/Stations/Tsunya Station.sub" />
<Submarine file="%ModDir%/Megamod/Subs/DV 1.sub" />
<Text file="%ModDir%/Megamod/Text/English.xml" />
<Sounds file="%ModDir%/Megamod/Sounds/beastsounds.xml" />
<Particles file="%ModDir%/Megamod/Particles/ParticlePrefabs.xml" />
<Item file="%ModDir%/Megamod/Items/Overrides.xml" />
<Item file="%ModDir%/Megamod/Items/Beast.xml" />
<Item file="%ModDir%/Megamod/Items/Cloning.xml" />
<Item file="%ModDir%/Megamod/Items/Special.xml" />
<Item file="%ModDir%/Megamod/Items/TraitorItems.xml" />
<Item file="%ModDir%/Megamod/Items/BasiliskLightOverride.xml" />
<Item file="%ModDir%/Megamod/Items/Other.xml" />
<Item file="%ModDir%/Megamod/Items/CapsuleOverrides.xml" />
<Character file="%ModDir%/Megamod/Characters/Truebeast/Truebeast.xml" />
<Afflictions file="%ModDir%/Megamod/Afflictions/Afflictions.xml" />
]] .. "\n"

---@return string
function Auto.GetFileName(filePath, isFolder)
  local s = filePath:reverse():gsub("\\", "/"):find("/")
  if not isFolder then
    return filePath:sub(#filePath - s + 2, -5)
  else
    return filePath:sub(#filePath - s + 2)
  end
end

---@return string
function Auto.GetFileType(filePath)
  local s = filePath:reverse():find("%.")
  if not s then return "" end
  return filePath:sub(#filePath - s + 1)
end

function Auto.ChangeFilePaths(str, modName)
  -- Replace %ModDir%
  str = str:gsub("%%[mM][oO][dD][dD][iI][rR]%%", "%%ModDir%%/Workshop/" .. modName)
  -- Replace %ModDir:123456789 ... %
  str = str:gsub("%%[mM][oO][dD][dD][iI][rR]:([%d]+)%%", function(otherModID)
    local otherModTable
    for k, v in pairs(Auto.ModTable) do
      if tonumber(otherModID) == k then
        otherModTable = v
        break
      elseif v.name == otherModID then
        otherModTable = v
        break
      end
    end
    if otherModTable then
      return "%ModDir%/Workshop/" .. otherModTable.name
    else
      return "%ModDir:" .. otherModID .. "%"
    end
  end)
  -- Replace %ModDir:Neurotrauma%
  str = str:gsub("%%[mM][oO][dD][dD][iI][rR]:([^%%]+)%%", function(otherModID)
    local otherModTable
    for k, v in pairs(Auto.ModTable) do
      if v.name == otherModID then
        otherModTable = v
        break
      end
    end
    if otherModTable then
      return "%ModDir%/Workshop/" .. otherModTable.name
    else
      return "%ModDir:" .. otherModID .. "%"
    end
  end)
  return str
end

function Auto.LoadXMLFile(filePath, modName)
  --[[local p = filePath:find(modName, 1, true)
  local debug = false
  if tostring(filePath:sub(p):gsub("\\", "/")) == "Enhanced Armaments/Weapons/overrides.xml" then
    debug = true
  end]]

  -- Can fail to load the xml if the file is unfinished, usually
  -- also meaning it's not in the filelist
  local success, xml = pcall(function() return XDocument.Load(filePath) end)
  if not success then
    print("WARNING! Missing root element for:\n" .. filePath)
    return
  end
  local fullOverrides = {}
  local componentOverrides = {}
  local function load(element, singleDef)
    -- If the file has one def, remove the file from the filelist if we remove the def
    local removeFromFileList = singleDef
    local elementName = tostring(element.Name):lower()
    if elementName == "override" or elementName == "overrides" then
      local elements = element.Elements()
      for element2 in elements do
        load(element2)
      end
      return
    end
    local elementID
    local defType = ""
    local variantOf = ""
    for attribute in element.Attributes() do
      local attributeName = tostring(attribute.Name):lower()
      if attributeName == "speciesname" then
        defType = "character"
        elementID = tostring(attribute.Value)
        removeFromFileList = true
        break
      elseif attributeName == "identifier" then
        defType = "item"
        elementID = tostring(attribute.Value)
        break
      elseif attributeName == "type" then
        elementID = tostring(attribute.Value)
        break
      end
    end
    for attribute in element.Attributes() do
      local attributeName = tostring(attribute.Name):lower()
      if attributeName == "variantof" then
        variantOf = tostring(attribute.Value)
        Auto.VariantList[elementID] = variantOf
        break
      end
    end
    if elementID then
      -- Add the identifier to the high prio list if it's a projectile
      if defType == "item" then
        for childElement in element.Elements() do
          local childElementName = tostring(childElement.Name):lower()
          if childElementName == "projectile" then
            table.insert(Auto.PFHighPriorityList, elementID)
            break
          end
        end
      end
      for overrideID, overrideTbl in pairs(Auto.XMLChanges) do
        if overrideID == elementID then
          -- Full item overrides / removals
          if overrideTbl.xml == "" or overrideTbl.mod ~= modName then
            fullOverrides[element] = { id = elementID, remove = true, removeFromFileList = removeFromFileList, override = nil }
          elseif overrideTbl.xml then
            fullOverrides[element] = {
              id = elementID,
              remove = false,
              removeFromFileList = removeFromFileList,
              override = overrideTbl.xml
            }
          end
          -- Individual component overrides
          if overrideTbl.componentOverrides and overrideTbl.mod == modName then
            componentOverrides[element] = {}
            for componentOverrideTbl in overrideTbl.componentOverrides do
              if not componentOverrideTbl.add then
                componentOverrides[element][componentOverrideTbl.targetComponent] = componentOverrideTbl
              else
                -- Key doesn't matter if we're just adding a component
                table.insert(componentOverrides[element], componentOverrideTbl)
              end
            end
          end
          break
        end
      end
    end
  end

  local rootName = tostring(xml.Root.Name):lower()
  if rootName == "override" or rootName == "overrides" then
    for element in xml.Root.Elements() do
      local elementName = tostring(element.Name):lower()
      if elementName == "character" or elementName == "charactervariant" then
        load(element, false)
      elseif elementName == "items" or elementName == "afflictions" then
        local elements = element.Elements()
        for element2 in elements do
          load(element2, false)
        end
      elseif elementName == "item" or elementName == "affliction" then -- This makes no logical sense, but it exists
        load(element, false)
      end
    end
  else
    -- Single definition files, such as characters
    if rootName == "character" or rootName == "charactervariant"
    or rootName == "item" or rootName == "affliction" then
      load(xml.Root, true)
    else
      local elements = xml.Root.Elements()
      for element in elements do
        -- For some ungodly reason, not waiting here would only load the first element of the list
        Timer.Wait(function() load(element, false) end, 1)
      end
    end
  end

  Timer.Wait(function() -- Have to do all this outside load() and in a timer because otherwise it just doesn't work for some reason
    for element, tbl in pairs(fullOverrides) do
      if tbl.remove then
        element.Remove()
      end
      -- Not doing this would cause an error because the root element is missing
      if tbl.removeFromFileList then
        for k, v in pairs(Auto.FileListXML) do
          v = XElement.Parse(v)
          local name = tostring(v.Name):lower()
          if name == "character" or name == "characters"
          or name == "item" or name == "items"
          or name == "affliction" or name == "afflictions" then
            for attribute in v.Attributes() do
              local s = filePath:find(modName, 1, true)
              local attributeValue = tostring(attribute.Value)
              if attributeValue:sub(19):gsub("\\", "/") == tostring(filePath:sub(s):gsub("\\", "/")) then
                table.remove(Auto.FileListXML, k)
              end
              break
            end
          end
        end
      end
      if tbl.override then
        element.RemoveAll()
        for overrideAttribute in tbl.override.Attributes() do
          element.SetAttributeValue(overrideAttribute.Name, overrideAttribute.Value)
        end
        for overrideElement in tbl.override.Elements() do
          element.Add(overrideElement)
        end
      end
    end
    for element, tbl in pairs(componentOverrides) do
      local components = {}
      for component in element.Elements() do
        table.insert(components, component)
      end
      -- Replace existing components to make the code more readable
      -- (it'll be in the same place in the xml as the original, not at the bottom)
      for componentName, componentOverrideTbl in pairs(tbl) do
        if not componentOverrideTbl.add then
          for component in components do
            if tostring(component.Name):lower() == componentName then
              if componentOverrideTbl.override == "" then
                -- Override is an empty string = remove component
                component.Remove()
              else
                -- Found a component to override, replace it
                component.RemoveAll()
                for overrideAttribute in componentOverrideTbl.override.Attributes() do
                  component.SetAttributeValue(overrideAttribute.Name, overrideAttribute.Value)
                end
                for overrideElement in componentOverrideTbl.override.Elements() do
                  component.Add(overrideElement)
                end
              end
            end
          end
        end
      end
      for _, componentOverrideTbl in pairs(tbl) do
        if componentOverrideTbl.add then
          element.Add(componentOverrideTbl.override)
        end
      end
    end
    xml = Auto.ChangeFilePaths(declaration .. tostring(xml), modName)
    File.Write(filePath, xml)
  end, 5)
end

function Auto.LoadLuaFile(filePath, modName)
  local content = File.Read(filePath)
  local lines = {}
  for line in string.gmatch(content, "([^\n]*)\n?") do
    table.insert(lines, line)
  end
  for overridePath, overrideTbl in pairs(Auto.LuaChanges) do
    if overrideTbl.mod == modName then
      local s = filePath:find(modName, 1, true)
      if tostring(filePath:sub(s):gsub("\\", "/")) == overridePath then
        for replacementTbl in overrideTbl.replacements do
          if replacementTbl.line == "" then
            -- Replace the entire file
            lines = {}
            for line in string.gmatch(replacementTbl.replace, "([^\n]*)\n?") do
              table.insert(lines, line)
            end
          elseif replacementTbl.line then
            lines[replacementTbl.line] = replacementTbl.replace
          else
            lines[replacementTbl.startLine] = replacementTbl.replace
            for i = replacementTbl.startLine + 1, replacementTbl.endLine do
              lines[i] = nil
            end
          end
        end
      end
    end
  end
  local str = ""
  for line in lines do
    str = str .. line .. "\n"
  end
  File.Write(filePath, str)
end

-- Yes we have to add the declaration twice: running
-- tostring() on an XDocument removes it for some reason
function Auto.Finish()
  -- Filelist
  local str = declaration ..
      "<contentpackage name=\"Munkee's Megamod\" modversion=\"" ..
      version .. "\" corepackage=\"False\" steamworkshopid=\"3318261393\">\n" ..
      Auto.MMFiles
  for line in Auto.FileListXML do
    str = str .. line .. "\n"
  end
  str = str .. "</contentpackage>"
  str = XDocument.Parse(str)
  str = declaration .. tostring(str)
  File.Write(Auto.Path .. "/filelist.xml", str)

  -- PF priority list
  local str = "\""
  for _, identifier in pairs(Auto.PFHighPriorityList) do
    str = str .. identifier .. "\",\""
  end
  -- Remove the last ","
  if str ~= "" then
    str = str:sub(1, -2)
    File.Write(Auto.Path .. "/Lua/utils/automation/pf list.txt", str)
  end

  -- Item variants list, whip this out when needed
  --[[local str = ""
  for baseID, variantID in pairs(Auto.VariantList) do
    str = str .. baseID .. " = " .. variantID .. "\n"
  end
  -- Remove the last newline
  if str ~= "" then
    str = str:sub(1, -2)
  end
  File.Write(Auto.Path .. "/Lua/utils/automation/variant list.txt", str)]]
end

-- Do stuff based on the current step
if Auto.Step == 1 then -- Write .bat file to download the modlist
  local str1 =
  ":: THIS FILE IS AUTO-GENERATED BY /auto.lua/. Phase 1 - download modlist via SteamCMD and place them in /temp/.\n:: SteamCMD is installed to download mods, then uninstalled on finish, leaving only the .exe installer for next time.\n@echo off\nmove \"steamcmd\\steamcmd.exe\" \"temp\"\nrd /S /Q \"steamcmd\"\nmkdir \"steamcmd\"\nmove \"temp\\steamcmd.exe\" \"steamcmd\"\nsteamcmd\\steamcmd.exe +login anonymous"
  for k, v in pairs(Auto.ModTable) do
    str1 = str1 .. " +workshop_download_item 602960 " .. k
  end
  str1 = str1 .. " +quit"
  local str2 = ""
  for k, v in pairs(Auto.ModTable) do
    str2 = str2 .. "\nmove \"steamcmd\\steamapps\\workshop\\content\\602960\\" .. k .. "\" \"temp\""
  end
  local str3 = ""
  for k, v in pairs(Auto.ModTable) do
    str3 = str3 .. "\nren \"temp\\" .. k .. "\" \"" .. v.name .. "\""
  end
  File.Write(Auto.Path .. "\\auto.bat",
    str1 ..
    str2 ..
    str3 ..
    "\nmove \"steamcmd\\steamcmd.exe\" \"temp\"\nRD /S /Q \"steamcmd\"\nmkdir \"steamcmd\"\nmove \"temp\\steamcmd.exe\" \"steamcmd\"")
elseif Auto.Step == 2 then -- Notify of mod updates, apply Lua/xml overrides, rewrite xml to correct file paths, rewrite filelist, rewrite .bat to copy Lua directories
  local batStr = ":: THIS FILE IS AUTO-GENERATED BY /auto.lua/. Phase 2 - copy Lua directories to /lua/workshop/.\n@echo off\nrd /S /Q \"Lua/workshop\"\nmkdir \"Lua/workshop\"\n"
  for modDirectory in File.GetDirectories(Auto.Path .. "/Workshop") do
    local modName
    local modVersion
    local modID

    -- Find and load the filelist
    for fileList in File.GetFiles(modDirectory) do
      local fileType = Auto.GetFileType(fileList)
      local fileName = Auto.GetFileName(fileList)
      if fileType == ".xml" and fileName == "filelist" then
        local xml = XElement.Load(fileList)
        for attribute in xml.Attributes() do
          local attributeName = tostring(attribute.Name):lower()
          if attributeName == "name" then
            modName = tostring(attribute.Value)
          elseif attributeName == "modversion" then
            modVersion = tostring(attribute.Value)
          elseif attributeName == "steamworkshopid" then
            modID = tostring(attribute.Value)
          end
        end
        for element in xml.Elements() do
          if tostring(element.Name):lower() ~= "other" then
            table.insert(Auto.FileListXML, Auto.ChangeFilePaths(tostring(element), modName))
          end
        end
        break
      end
    end

    local modTable = Auto.ModTable[tonumber(modID)]
    -- If we couldn't find the mod by its workshop ID,
    -- try to find it by the mod's name
    if not modTable then
      for k, v in pairs(Auto.ModTable) do
        if v.name == modName then
          modTable = v
          -- Also set modID, as it's used elsewhere
          modID = k
          break
        end
      end
    end
    if not modTable then
      error("Could not find mod table for '" .. tostring(modName) .. ".'")
    end
    -- Code doesn't work if the names are mismatched
    if modTable.name ~= modName then
      error("Mod name for " ..
        tostring(modName) ..
        " does not match!\n(Current: '" .. tostring(modName) .. "' Defined: '" .. modTable.name .. "')")
    end
    if modTable.version ~= modVersion then
      print("*****\nWARNING: Mod version for " ..
        tostring(modName) ..
        " does not match!\n(Current: '" .. tostring(modVersion) .. "' Defined: '" .. modTable.version .. "')\n*****")
    end

    -- Need to copy the Lua folder because require() searches the Lua folder and not the main folder for some reason
    for folder in File.GetDirectories(modDirectory) do
      if Auto.GetFileName(folder, true) == "Lua" then
        batStr = batStr ..
            "xcopy /s /i \"Workshop/" .. modName .. "/Lua\" \"Lua/workshop/" .. modName .. "/Lua\"\n"
        if Auto.ModTable[tonumber(modID)].priority then
          batStr = batStr ..
              "echo " ..
              tostring(Auto.ModTable[tonumber(modID)].priority) ..
              " >\"Lua/workshop/" .. modName .. "/Lua/priority.txt\"\n"
        end
        break
      end
    end

    local function search(directory)
      for childDirectory in File.GetDirectories(directory) do
        search(childDirectory)
      end
      for filePath in File.GetFiles(directory) do
        local fileType = Auto.GetFileType(filePath)
        if fileType == ".xml" then
          Auto.LoadXMLFile(filePath, modName)
        elseif fileType == ".lua" then
          Auto.LoadLuaFile(filePath, modName)
        end
      end
    end
    search(modDirectory)
  end
  File.Write(Auto.Path .. "/auto.bat", batStr)
  -- Need to wait because async stuff
  Timer.Wait(function() Auto.Finish() end, 25)
end
