using System.Runtime.Versioning;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
public class BaseballLauncher : Item, IMovable
{
    private float _maxLife = 100f;
    [SerializeField]
    private float _currentLife;
    public GameObject projectilePrefab;
    public GameObject blueprintPrefab;
    public GameObject exitPoint;
    public GameObject ballsState1, ballsState2, ballsState3;
    [SerializeField]
    private GameObject trapDestroyPrefab;
    public int shots = 15;
    public float viewRadius;
    public float viewAngle;
    public int shotsLeft;
    private TestQuery _myQuery;
    public bool IsEmpty
    {
        get
        {
            if (shotsLeft == 0)
                GameVars.Values.ShowNotification("You need a Tennis Ball Box to reload!");

            return shotsLeft == 0;
        }
    }
    public bool HasPlayerTennisBallBox { get; set; }
    public float interval;
    public LayerMask targetMask;
    public LayerMask obstacleMask;
    public bool active = false;
    Vector3 auxVector;
    Transform myCannon;
    Transform myCannonSupport;
    private float _futureTime = 0f; //30f
    private float _shootSpeed = 5f;
    private float _inactiveSpeed = 0.3f;
    private Collider _currentObjective = null;
    private float _currentObjectiveDistance = 1000;
    [SerializeField]
    private List<GameObject> _myItems;
    private Animator _animator; //El destroy después se va a hacer con un prefab nuevo, exactamente igual que el prefab que se usa para la animación de construcción.

    public void Awake()
    {
        _animator = GetComponent<Animator>();
        _currentLife = _maxLife;

        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);

        //Debug.Log(transform.GetChild(2));
        shotsLeft = shots;
        ActiveBallsState1();
        //_myQuery = GetComponent<TestQuery>();
        _myQuery = GameObject.Find("TestQuery").GetComponent<TestQuery>();
    }

    public override void Interact()
    {
        if (HasPlayerTennisBallBox)
            Reload();

        if (!active)
        {
            active = true;
            StartCoroutine("ActiveCoroutine");
        }
    }

    void Update()
    {
        if (active)
        {
            FieldOfView();
        }
        else
        {
            Inactive();
        }
    }
    public void Reload()
    {
        shotsLeft = shots;
        ActiveDeactivateBallStates(true, false, false);
    }
    IEnumerator ActiveCoroutine()
    {
        if (active)
        {
            shotsLeft--;
            shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
            ChangeBallsState(shotsLeft);
            yield return new WaitForSeconds(interval);
            if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
            else active = false;
        }
        else
        {
            yield return new WaitForSeconds(0.01f);
        }

    }

    public void InstantiateBall()
    {
        GameObject aux = Instantiate(projectilePrefab, exitPoint.transform.position, Quaternion.identity);
        aux.GetComponent<Rigidbody>().AddForce(35f * exitPoint.transform.forward, ForceMode.Impulse); //era 20f
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
    }

    public void ActiveBallsState1()
    {
        ballsState1.SetActive(true);
    }

    public void TakeDamage(float dmgAmount)
    {
        _currentLife = -dmgAmount;

        if (_currentLife <= 0)
        {
            //Hacer animacion de destrucción, instanciar sus objetos de construcción y destruirse.
            DestroyThisTrap();
        }
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

        if (allTargets.Length == 0)
        {
            Inactive();
            active = false;
        }

        //Si no tenemos objetivo actual buscamos el más cercano y lo hacemos objetivo.
        if (_currentObjective == null || _currentObjective.GetComponent<EnemyHealth>().dead || _currentObjectiveDistance > viewRadius)
        {



            //foreach (var item in allTargets)
            //{
            //    if (Vector3.Distance(transform.position, item.transform.position) < _currentObjectiveDistance)
            //    {
            //var item = GetNearestTarget(allTargets);
            var item = _myQuery.GetClosestEnemy(transform.position);

            if (item == null)
                return;
            _currentObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
            _currentObjective = item.GetComponent<Collider>();
            //}
            //    }
            //}
        }


        //foreach (var item in allTargets)
        //{
        if (_currentObjectiveDistance < viewRadius && _currentObjective != null)
        {
            // Vector3 futurePos = _currentObjective.transform.position + (_currentObjective.GetComponent<EnemyHealth>().GetVelocity() * _futureTime * Time.deltaTime);
            //Vector3 dir = item.transform.position - transform.position;

            Vector3 dir = _currentObjective.transform.position - transform.position;
            _currentObjectiveDistance = Vector3.Distance(transform.position, _currentObjective.transform.position);

            //if (Vector3.Angle(transform.forward, dir.normalized) < viewAngle / 2)
            //{
            if (Physics.Raycast(transform.position, dir, out RaycastHit hit, dir.magnitude, obstacleMask) == false)
            {
                //auxVector = new Vector3(item.tra)
                //myCannon.transform.LookAt(item.transform.position);

                Quaternion lookRotation = Quaternion.LookRotation(dir);
                Vector3 rotation = lookRotation.eulerAngles;
                //myCannonSupport.rotation = Quaternion.Euler(0f, rotation.y + 90f, 0f);

                //myCannon.rotation = Quaternion.Euler(0f, rotation.y + 90f, rotation.z - 5f);
                myCannonSupport.rotation = Quaternion.Lerp(myCannonSupport.rotation, Quaternion.Euler(0f, rotation.y, 0f), _shootSpeed * Time.deltaTime);
                myCannon.rotation = Quaternion.Lerp(myCannon.rotation, Quaternion.Euler(0f, rotation.y, rotation.z), _shootSpeed * Time.deltaTime);
                Debug.DrawLine(transform.position, _currentObjective.transform.position, Color.red);
            }
        }
        //}
        //}
    }

    //IA2 -P1
    //IATP2 -P1
    //IA-TP2 -P1
    private Collider GetNearestTarget(Collider[] allTargets)
    {
        var target = allTargets.Where(x => x.gameObject.GetComponent<Gray>() != null && Vector3.Distance(x.gameObject.transform.position, this.gameObject.transform.position) < _currentObjectiveDistance).OrderBy(x => Vector3.Distance(x.gameObject.transform.position, this.gameObject.transform.position)).FirstOrDefault();


        if (target == null)
            Debug.Log(target is null);
        else
            Debug.Log("GetNearestTarget " + target.name);

        return target;

    }
    private void Inactive()
    {
        //myCannon.rotation = Quaternion.Slerp(myCannon.rotation, Quaternion.Euler(myCannon.rotation.x, myCannon.rotation.y, 35f), speed * Time.deltaTime);
        myCannon.rotation = Quaternion.Lerp(myCannon.rotation, Quaternion.Euler(35f, myCannon.rotation.y, myCannon.rotation.z), _inactiveSpeed * Time.deltaTime);
        myCannonSupport.rotation = Quaternion.Lerp(myCannonSupport.rotation, Quaternion.Euler(0f, myCannonSupport.rotation.y, myCannonSupport.rotation.z), _inactiveSpeed * Time.deltaTime);
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

    public void DestroyThisTrap()
    {
        Quaternion finalRotation = transform.rotation;
        Vector3 aux = new Vector3(0, 0.4f, 0);
        for (int i = 0; i < _myItems.Count; i++)
        {
            Vector3 itemPos = new Vector3(Random.Range(0.3f, 1.3f), 0, Random.Range(0.3f, 1.3f));
            Instantiate(_myItems[i], transform.position + aux + itemPos, Quaternion.identity);
        }
        Instantiate(trapDestroyPrefab, transform.position, finalRotation);
        Destroy(this.gameObject);
    }

    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, viewRadius);
        Vector3 lineA = GetVectorFromAngle(viewAngle / 2 + transform.eulerAngles.y);
        Vector3 lineB = GetVectorFromAngle(-viewAngle / 2 + transform.eulerAngles.y);

        Gizmos.DrawLine(transform.position, transform.position + lineA * viewRadius);
        Gizmos.DrawLine(transform.position, transform.position + lineB * viewRadius);
    }

    Vector3 GetVectorFromAngle(float angle)
    {
        return new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));
    }



}
