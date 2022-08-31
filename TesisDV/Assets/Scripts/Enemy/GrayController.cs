using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayController : IController
{
    GrayModel _m;

    public GrayController(GrayModel m, GrayView v)
    {
        _m = m;

        _m.onWalk       +=  v.WalkAnimation;
        _m.onHit        +=  v.HitAnimation;
        _m.onDeath      +=  v.DeathAnimation;
        _m.onAttack     +=  v.AttackAnimation;
        _m.onCatGrab    +=  v.CatGrabAnimation;
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
