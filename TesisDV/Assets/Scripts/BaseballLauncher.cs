using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncher : Item
{
    public GameObject projectilePrefab;
    public GameObject exitPoint;
    public int shots = 15;
    public int shotsLeft;
    public float interval;
    public bool active = false;

    public void Awake()
    {
        shotsLeft = shots;
    }

    public override void Interact()
    {
        if (!active)
        {
            active = true;
            StartCoroutine("ActiveCoroutine");
        }
    }

    IEnumerator ActiveCoroutine()
    {
        GameObject aux = Instantiate(projectilePrefab, exitPoint.transform.position, Quaternion.identity);
        aux.GetComponent<Rigidbody>().AddForce(10f * -exitPoint.transform.right, ForceMode.Impulse);
        shotsLeft = Mathf.Clamp(shotsLeft--, 0, shots);
        yield return new WaitForSeconds(interval);
        if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
        else active = false;
    }
}
