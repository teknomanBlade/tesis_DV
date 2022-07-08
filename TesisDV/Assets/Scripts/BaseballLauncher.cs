using System.Runtime.Versioning;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class BaseballLauncher : Item, IMovable
{
    private float _maxLife = 100f;
    [SerializeField]
    private float _currentLife;
    private bool _isDestroyed;
    private bool _isDisabledSFX;
    public ParticleSystem HitTurret;
    public ParticleSystem ShootEffect;
    private AudioSource _as;
    public delegate void OnReloadDelegate();
    public event OnReloadDelegate OnReload;
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
    public bool IsEmpty
    {
        get
        {
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
    private float _futureTime = 1f; //era 30f.
    private float _shootSpeed = 5f;
    private float _searchSpeed = 2.5f;
    private bool isWorking = true;
    private float _inactiveSpeed = 0.3f;
    public Collider _currentObjective = null;
    private Coroutine ReloadCoroutine;
    private Coroutine ShootCoroutine;
    private Coroutine SFXDetectionCoroutine;
    public float _currentObjectiveDistance = 1000;
    [SerializeField]
    private List<GameObject> _myItems;
    private Animator _animator; //El destroy después se va a hacer con un prefab nuevo, exactamente igual que el prefab que se usa para la animación de construcción.
    public Collider[] collidersObjectives;
    public Collider[] collidersObjectivesDisabled;
    public const float MAX_CURRENT_OBJETIVE_DISTANCE = 1000;


    public void Awake()
    {
        _animator = GetComponent<Animator>();
        _currentLife = _maxLife;
        _animator.SetBool("HasNoBalls", false);

        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);
        _as = GetComponent<AudioSource>();
        //Debug.Log(transform.GetChild(2));
        shotsLeft = shots;
        ActiveBallsState1();
    }

    public override void Interact()
    {
        if (HasPlayerTennisBallBox && IsEmpty)
        {
            if (ReloadCoroutine != null) StopCoroutine(ReloadCoroutine);
            ReloadCoroutine = StartCoroutine(ReloadTurret());
        }

        if (!active)
        {
            active = true;
            _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
            if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
            ShootCoroutine = StartCoroutine("ActiveCoroutine");
        }
    }

    IEnumerator ReloadTurret()
    {
        GameVars.Values.ShowNotification("Reloading turret...");
        GameVars.Values.soundManager.PlaySoundOnce(_as, "ReloadingTurret1", 0.8f, false);
        yield return new WaitForSeconds(2.5f);
        Debug.Log("LLEGA A RELOAD?");
        Reload();
    }

    void Update()
    {
        if (active)
            FieldOfView();

        if (shotsLeft == 0)
        {
            Inactive();
        }
    }
    public void Reload()
    {
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        _isDisabledSFX = false;
        shotsLeft = shots;
        _animator.enabled = true;
        _animator.SetBool("HasNoBalls", false);
        ActiveDeactivateBallStates(true, false, false);
        OnReload?.Invoke();
        GameVars.Values.ShowNotification("The Turret has been reloaded.");
    }
    IEnumerator ActiveCoroutine()
    {
        if (active)
        {
            InstantiateBall();
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
        if (shotsLeft == 0 || _currentObjective == null || _currentObjective.GetComponent<Gray>().dead)
            return;
        ShootEffect.Play();
        shotsLeft--;
        shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
        ChangeBallsState(shotsLeft);
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
        _currentLife -= dmgAmount;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretHitDamage", 0.45f, false);
        HitTurret.gameObject.SetActive(true);
        HitTurret.Play();
        if (_currentLife <= 0)
        {
            //Hacer animacion de destrucción, instanciar sus objetos de construcción y destruirse.
            isWorking = false;
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
        collidersObjectives = allTargets.Where(x => x.GetComponent<Gray>().isActiveAndEnabled == true).ToArray();

        collidersObjectivesDisabled = allTargets.Where(x => x.GetComponent<Gray>().isActiveAndEnabled == false).ToArray();


        if (allTargets.Length == 0 || _currentObjective == null)
        {
            _currentObjective = null;
            _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        }
        //Si no tenemos objetivo actual buscamos el más cercano y lo hacemos objetivo.
        if (_currentObjective == null || _currentObjective.GetComponent<Gray>().dead || _currentObjectiveDistance > viewRadius)
        {
            foreach (var item in allTargets)
            {
                if (Vector3.Distance(transform.position, item.transform.position) < _currentObjectiveDistance)
                {
                    if (!item.GetComponent<Gray>().dead)
                    {
                        _currentObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
                        _currentObjective = item;
                        _animator.enabled = false;
                    }
                }
            }
        }

        //foreach (var item in allTargets)
        //{
        if (_currentObjectiveDistance < viewRadius && _currentObjective != null)
        {
            //StartCoroutine("RoutineEndSearchingForObjectives");

            Vector3 futurePos = _currentObjective.transform.position + (_currentObjective.GetComponent<Gray>().GetVelocity() * _futureTime * Time.deltaTime);
            //Vector3 dir = item.transform.position - transform.position;

            Vector3 dir = futurePos - transform.position;

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
        else
        {
            //StartCoroutine("RoutineSearchingForObjectives");
        }
        //}
        //}
    }

    /*IEnumerator PlayDetectionSound()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretScanning", 0.25f, true);
        yield return new WaitForSeconds(0.2f);
        GameVars.Values.soundManager.StopSound();
    }*/
    private void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        _animator.enabled = true;
        _animator.SetBool("HasNoBalls", true);
    }
    IEnumerator PlayShutdownSound()
    {
        _isDisabledSFX = false;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretShutDown", 0.4f, false);
        yield return new WaitForSeconds(1f);
        GameVars.Values.soundManager.StopSound();
        _isDisabledSFX = true;
    }

    IEnumerator RoutineSearchingForObjectives()
    {
        Debug.Log("RoutineSearchingForObjectives");
        SearchingForObjectives();
        yield return new WaitForSeconds(0.9f);
    }

    IEnumerator RoutineEndSearchingForObjectives()
    {
        Debug.Log("RoutineSearchingForObjectives");

        EndSearchingForObjective();
        yield return new WaitForSeconds(0.9f);
    }
    private void SearchingForObjectives()
    {
        _animator.enabled = true;
        _animator.SetBool("IsSearchingForObjectives", true);

    }

    private void EndSearchingForObjective()
    {
        _animator.SetBool("IsSearchingForObjectives", false);
        _animator.enabled = false;


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

        var trapDestroyGO = Instantiate(trapDestroyPrefab, transform.position, finalRotation);
        trapDestroyGO.GetComponent<BaseballLauncherDestroyAnim>().OnDestroyed += OnDestroyed;
    }

    private void OnDestroyed(bool destroyed)
    {
        _isDestroyed = destroyed;
        Vector3 aux = new Vector3(0, 0.4f, 0);
        if (_isDestroyed)
        {
            for (int i = 0; i < _myItems.Count; i++)
            {
                Vector3 itemPos = new Vector3(UnityEngine.Random.Range(0.1f, 2.3f), 0, UnityEngine.Random.Range(0.1f, 2.3f));
                Instantiate(_myItems[i], transform.position + aux + itemPos, Quaternion.Euler(-90f, 0f, 0f));
            }
        }
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
