using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HardcodeController : IController
{
    GrayModelHardcodeado _m;

    public HardcodeController(GrayModelHardcodeado m, GrayView v)
    {
        _m = m;

        _m.onWalk       +=  v.WalkAnimation;
        _m.onForceFieldRejection += v.ForceFieldRejectionAnimation;
        _m.onStun       +=  v.StunAnimation;
        _m.onHit        +=  v.HitAnimation;
        _m.onPepperHit  += v.PepperHitEffect;
        _m.onElectricHit += v.ElectricDebuffAnimation;
        _m.onHit        +=  v.InnerEffectAnimation;
        _m.onDeath      +=  v.DeathAnimation;
        v.onWitGainEffect += _m.SendWitts;
        _m.onAttack     +=  v.AttackAnimation;
        _m.onAttackSpecial  +=  v.EMPSkillAnimation;
        _m.onCatGrab    +=  v.CatGrabAnimation;
        //_m.onDisolve    +=  v.DissolveAnimation;
        _m.onEndSpawn   +=  v.EndSpawnAnim;
    }

    public void OnUpdate()
    {
        _m._fsm.OnUpdate();
    }

    public void OnFixedUpdate()
    {
        //_m.Movement();
    }
}
