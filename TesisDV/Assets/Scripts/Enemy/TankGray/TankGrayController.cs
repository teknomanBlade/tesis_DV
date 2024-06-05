using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TankGrayController : IController
{
    TankGrayModel _m;

    public TankGrayController(TankGrayModel m, TankGrayView v)
    {
        _m = m;

        _m.onWalk       +=  v.WalkAnimation;
        _m.onHit        +=  v.HitAnimation;
        _m.onPepperHit += v.PepperHitEffect;
        //_m.onHit        +=  v.InnerEffectAnimation;
        _m.onDeath      +=  v.DeathAnimation;
        _m.onAttack     +=  v.AttackAnimation;
        _m.onAttackSpecial  +=  v.AttackAnimation;
        _m.onCatGrab    +=  v.CatGrabAnimation;
        _m.onDisolve    +=  v.DissolveAnimation;
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
