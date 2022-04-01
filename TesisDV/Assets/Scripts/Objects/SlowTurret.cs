using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTurret : Object
{
    private void OnTriggerEnter(Collider other)
    {
        if (isHeld) return;
        if (other.gameObject.layer == 12)
        {
            other.gameObject.GetComponent<EnemyBase>().SetSlowEffect(true);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (isHeld) return;
        if (other.gameObject.layer == 12)
        {
            other.gameObject.GetComponent<EnemyBase>().SetSlowEffect(false);
        }
    }
}
