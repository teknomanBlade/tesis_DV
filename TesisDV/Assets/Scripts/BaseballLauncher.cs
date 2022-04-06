using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncher : Trap
{
    public GameObject projectilePrefab;
    public int shots = 5;
    public int shotsLeft;
    public float interval;

    public bool test = false;

    private void Update()
    {
        if (test)
        {
            test = false;
            Activate();
        }
    }

    public override void Activate()
    {
        if (!active)
        {
            active = true;
            shotsLeft = shots;
            StartCoroutine("ActiveCoroutine");
        }
    }

    IEnumerator ActiveCoroutine()
    {
        //Shoot projectile
        Debug.Log("Shoot");
        shotsLeft--;
        yield return new WaitForSeconds(interval);
        if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
    }
}
