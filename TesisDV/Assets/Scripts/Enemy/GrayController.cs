using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayController : IController
{
    GrayModel _m;

    public GrayController(GrayModel m, GrayView v)
    {
        _m = m;

        
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
