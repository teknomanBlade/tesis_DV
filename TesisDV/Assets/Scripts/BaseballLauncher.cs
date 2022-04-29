using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncher : Item, IMovable
{
    public GameObject projectilePrefab;
    public GameObject blueprintPrefab;
    public GameObject exitPoint;
    public GameObject ballsState1, ballsState2, ballsState3;
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
        shotsLeft--;
        shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
        ChangeBallsState(shotsLeft);
        yield return new WaitForSeconds(interval);
        if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
        else active = false;
    }

    public void InstantiateBall()
    {
        GameObject aux = Instantiate(projectilePrefab, exitPoint.transform.position, Quaternion.identity);
        aux.GetComponent<Rigidbody>().AddForce(20f * -exitPoint.transform.right, ForceMode.Impulse);
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
    }

    public void ChangeBallsState(int shotsLeft)
    {
        if (shotsLeft <= 0)
        {
            ActiveDeactivateBallStates(false, false, false);
            return;
        }
        InstantiateBall();

        if (shotsLeft == 15)
        {
            ActiveDeactivateBallStates(!ballsState1.activeSelf, false, false);
        }
        else if (shotsLeft == 11)
        {
            ActiveDeactivateBallStates(false, !ballsState2.activeSelf, false);
        }
        else if (shotsLeft == 6)
        {
            ActiveDeactivateBallStates(false, false, !ballsState3.activeSelf);
        }
    }

    public void ActiveDeactivateBallStates(bool state1, bool state2, bool state3)
    {
        ballsState1.SetActive(state1);
        ballsState2.SetActive(state2);
        ballsState3.SetActive(state3);
    }

    public void BecomeMovable()
    {
        
        Destroy(gameObject);
    }
}
