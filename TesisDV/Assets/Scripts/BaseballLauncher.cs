using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncher : Trap
{
    public GameObject projectilePrefab;
    public GameObject exitPoint;
    public int shots = 5;
    public int shotsLeft;
    public float interval;

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
        GameObject aux = Instantiate(projectilePrefab, exitPoint.transform.position, Quaternion.identity);
        aux.GetComponent<Rigidbody>().AddForce(10f * exitPoint.transform.forward, ForceMode.Impulse);
        shotsLeft--;
        yield return new WaitForSeconds(interval);
        if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
        else active = false;
    }
}
