using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatController : IController
{
    Cat _m;

    public CatController(Cat m, CatView v)
    {
        _m = m;

        _m.onIdle       +=  v.IdleAnim;
        _m.onWalk       +=  v.WalkAnim;
        _m.onTaken      +=  v.TakenAnim;
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
