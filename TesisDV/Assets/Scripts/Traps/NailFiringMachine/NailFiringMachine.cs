using System.Runtime.Versioning;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;


public class NailFiringMachine : Item, IMovable
{
    [SerializeField] private float _currentLife;
    [SerializeField] private GameObject blueprintPrefab;
    [SerializeField] private List<GameObject> _myItems;
    public PoolObject<Nail> NailsPool { get; set; }
    public Nail Nail { get; private set; }
    public int InitialStock { get; private set; }
    public float interval;
    public GameObject spawnPoint;
    public int shots = 30;
    public int shotsLeft;
    public bool active = false;
    private Coroutine ShootCoroutine; 
    Transform myCannon;

    public float viewRadius;
    public float viewAngle;
    public LayerMask targetMask;
    public LayerMask obstacleMask;

    private float _futureTime = 1f;
    private float _shootSpeed = 5f;

    public float _currentObjectiveDistance = 1000;
    public Collider _currentObjective = null;
    public Collider[] collidersObjectives;
    public Collider[] collidersObjectivesDisabled;
    public const float MAX_CURRENT_OBJETIVE_DISTANCE = 1000;
    // Start is called before the first frame update
    void Awake()
    {
        shotsLeft = shots;
        InitialStock = 30;
        Nail = Resources.Load<Nail>("Nail");
        NailsPool = new PoolObject<Nail>(NailFactory, ActivateNail, DeactivateNail, InitialStock, true);
        myCannon = transform.GetChild(1);
    }

    void Update()
    {
        if (active)
        {
            FieldOfView();
        }
    }

    public override void Interact()
    {
        if (!active)
        {
            Debug.Log("Active la torreta");

            active = true;
            if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
            ShootCoroutine = StartCoroutine("ActiveCoroutine");
        }
    }
    IEnumerator ActiveCoroutine()
    {
        if (active)
        {
            FireNail();
            yield return new WaitForSeconds(interval);
            if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
            else active = false;
        }
        else
        {
            yield return new WaitForSeconds(0.01f);
        }

    }

    public void TakeDamage(float dmgAmount)
    {
        _currentLife -= dmgAmount;
        //GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretHitDamage", 0.25f, false);
        //HitTurret.gameObject.SetActive(true);
        //HitTurret.Play();
        if (_currentLife <= 0)
        {
            //Hacer animacion de destrucción, instanciar sus objetos de construcción y destruirse.
            DestroyThisTrap();
        }
    }

    void FieldOfView()
    {
        Collider[] allTargets = Physics.OverlapSphere(transform.position, viewRadius, targetMask);

        collidersObjectives = allTargets.Where(x => x.GetComponent<Enemy>().isActiveAndEnabled == true).ToArray();

        collidersObjectivesDisabled = allTargets.Where(x => x.GetComponent<Enemy>().isActiveAndEnabled == false).ToArray();

        if (allTargets.Length == 0 || _currentObjective == null)
        {
            _currentObjective = null;
            _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        }

        if (_currentObjective == null || _currentObjective.GetComponent<Enemy>().isDead || _currentObjectiveDistance > viewRadius)
        {
            foreach (var item in allTargets)
            {
                if (Vector3.Distance(transform.position, item.transform.position) < _currentObjectiveDistance)
                {
                    if (!item.GetComponent<Enemy>().isDead)
                    {
                        _currentObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
                        _currentObjective = item;

                        //_animator.enabled = false; Por ahora no usamos esto al no tener anims.
                    }
                }
            }
        }

        if (_currentObjectiveDistance < viewRadius && _currentObjective != null)
        {


            Vector3 futurePos = _currentObjective.transform.position + (_currentObjective.GetComponent<Enemy>().GetVelocity() * _futureTime * Time.deltaTime);

            Vector3 dir = futurePos - transform.position;
            _currentObjectiveDistance = Vector3.Distance(transform.position, _currentObjective.transform.position);
            if (Physics.Raycast(transform.position, dir, out RaycastHit hit, dir.magnitude, obstacleMask) == false)
            {

                Quaternion lookRotation = Quaternion.LookRotation(dir);
                Vector3 rotation = lookRotation.eulerAngles;

                //myCannonSupport.rotation = Quaternion.Lerp(myCannonSupport.rotation, Quaternion.Euler(0f, rotation.y, 0f), _shootSpeed * Time.deltaTime);
                //Por ahora no usamos cannon support por ser un modelo basico.

                myCannon.rotation = Quaternion.Lerp(myCannon.rotation, Quaternion.Euler(0f, rotation.y, rotation.z), _shootSpeed * Time.deltaTime);
                Debug.DrawLine(transform.position, _currentObjective.transform.position, Color.red);
                return;
            }
        }


        /* if (allTargets.Length == 0 && _currentObjective == null) Por ahora no usamos esto al no tener animaciones.
        {
            if (searchingForTargetCoroutine != null) StopCoroutine(searchingForTargetCoroutine);
            
            searchingForTargetCoroutine = StartCoroutine("RoutineSearchingForObjectives");
            laser.gameObject.SetActive(false);
        } */
    }

    private void FireNail()
    {
        NailsPool.GetObject().SetInitialPos(spawnPoint.transform.position).SetOwner(this);
    }

    private void DeactivateNail(Nail o)
    {
        o.gameObject.SetActive(false);
        o.transform.localPosition = new Vector3(0f, 0f, 0f);
    }

    private void ActivateNail(Nail o)
    {
        o.gameObject.SetActive(true);
    }

    private Nail NailFactory()
    {
        return Instantiate(Nail);
    }

    public void BecomeMovable()
    {
        GameVars.Values.currentShotsTrap2 = shotsLeft;
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        Destroy(gameObject);
    }

    public void Inactive()
    {
        active = false;
    }

    public void DestroyThisTrap()
    {
        Vector3 aux = new Vector3(0, 0.4f, 0);
        for (int i = 0; i < _myItems.Count; i++)
        {
            Vector3 itemPos = new Vector3(UnityEngine.Random.Range(0.1f, 2.3f), 0, UnityEngine.Random.Range(0.1f, 2.3f));
            Instantiate(_myItems[i], transform.position + aux + itemPos, Quaternion.Euler(-90f, 0f, 0f));
        }
        Destroy(gameObject);
    }
}
