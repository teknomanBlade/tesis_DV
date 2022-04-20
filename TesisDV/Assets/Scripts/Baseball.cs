using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baseball : Projectile
{
    protected override void Start()
    {
        dieOnImpact = false;
        base.Start();
    }
}
