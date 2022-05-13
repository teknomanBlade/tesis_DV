using System.Runtime.Versioning;
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
    public float viewRadius;
    public float viewAngle;
    public int shotsLeft;
    public bool IsEmpty
    {
        get { return shotsLeft == 0; }
    }
    public bool HasPlayerTennisBallBox { get; set; }

    public float interval;
    public LayerMask targetMask;
    public LayerMask obstacleMask;
    public bool active = false;
    Vector3 auxVector;
    Transform myCannon;
    Transform myCannonSupport;

    public void Awake()
    {
        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);

        //Debug.Log(transform.GetChild(2));
        shotsLeft = shots;
        ActiveBallsState1();
    }

    public override void Interact()
    {
        if (IsEmpty && HasPlayerTennisBallBox)
        {
            Reload();
        }
        else
        {
            GameVars.Values.ShowNotification("We need a Tennis Ball Box to reload!");
        }

        if (!active)
        {
            active = true;
            StartCoroutine("ActiveCoroutine");
        }
    }

    void Update()
    {
        FieldOfView();

        
    }
    public void Reload()
    {
        shotsLeft = shots;
        ActiveDeactivateBallStates(true, false, false);
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
        aux.GetComponent<Rigidbody>().AddForce(35f * -exitPoint.transform.right, ForceMode.Impulse); //era 20f
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
    }

    public void ActiveBallsState1()
    {
        ballsState1.SetActive(true);
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
            ActiveDeactivateBallStates(true, false, false);
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

    void FieldOfView()
    {
       Collider[] allTargets = Physics.OverlapSphere(transform.position, viewRadius, targetMask);

        foreach (var item in allTargets)
        {
            Vector3 dir = item.transform.position - transform.position;

            //if (Vector3.Angle(transform.forward, dir.normalized) < viewAngle / 2)
            //{
                if(Physics.Raycast(transform.position, dir, out RaycastHit hit, dir.magnitude, obstacleMask) == false)
                {
                    //auxVector = new Vector3(item.tra)
                    //myCannon.transform.LookAt(item.transform.position);
                    
                    Quaternion lookRotation = Quaternion.LookRotation(dir);
                    Vector3 rotation = lookRotation.eulerAngles;
                    myCannonSupport.rotation = Quaternion.Euler(0f, rotation.y +90f, 0f);
                    myCannon.rotation = Quaternion.Euler(0f, rotation.y + 90f, rotation.z - 5f);

                    Debug.DrawLine(transform.position, item.transform.position, Color.red);
                }
                else
                {
                    Debug.DrawLine(transform.position, hit.point, Color.red);
                }
            //}
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
        
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        Destroy(gameObject);
    }

    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, viewRadius);
        Vector3 lineA = GetVectorFromAngle(viewAngle /2 + transform.eulerAngles.y);
        Vector3 lineB = GetVectorFromAngle(-viewAngle /2 + transform.eulerAngles.y);

        Gizmos.DrawLine(transform.position, transform.position + lineA * viewRadius);
        Gizmos.DrawLine(transform.position, transform.position + lineB * viewRadius);
    }

    Vector3 GetVectorFromAngle(float angle)
    {
        return new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));
    }
}
