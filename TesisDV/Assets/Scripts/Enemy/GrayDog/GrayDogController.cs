using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogController : IController
{
    GrayDogModel _m;
    public GrayDogController(GrayDogModel m, GrayDogView v)
    {
        _m = m;

        _m.onHit += v.HitAnimation;
        _m.onPepperHit += v.PepperHitEffect;
        _m.onPaintballHit += v.PaintballHit;
        _m.onPoisonHit += v.PoisonHit;
        v.onWitGainEffect += _m.SendWitts;
        _m.onPoisonHitStop += v.PoisonHitStop;
        _m.onElectricHit += v.ElectricDebuffAnimation;
        _m.onDeath += v.DeathAnimation;
        _m.onCatGrab += v.CatGrabAnimation;
        _m.onRunning += v.RunningAnimation;
        _m.onEndSpawn += v.EndSpawnAnim;
    }

    public void OnFixedUpdate()
    {

    }

    public void OnUpdate()
    {
        _m._fsm.OnUpdate();
    }
}
