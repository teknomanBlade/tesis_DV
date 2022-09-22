using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncher : Trap, IMovable, IInteractable
{
    private float _maxLife = 100f;
    [SerializeField] private float _currentLife;
    private float _valueToChange;
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
    [SerializeField] private GameObject trapDestroyPrefab;
    public int shots = 15;
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
    Vector3 auxVector;
    private float _searchSpeed = 2.5f;
    private bool isWorking = true;
    private float _inactiveSpeed = 0.3f;
    private Coroutine ReloadCoroutine;
    private Coroutine ShootCoroutine;
    private Coroutine SFXDetectionCoroutine;
    [SerializeField]
    private List<GameObject> _myItems;
    private bool isFirstTime;
    public Laser laser;
    private Coroutine searchingForTargetCoroutine;

    public PoolObject<Baseball> BaseballPool { get; set; }
    public Baseball Baseball { get; private set; }
    public int InitialStock { get; private set; }

    public void Awake()
    {
        active = false;
        _animator = GetComponent<Animator>();
        _currentLife = _maxLife;
        _animator.SetBool("HasNoBalls", true);
        GameVars.Values.ShowNotification("The Turret is inactive. Get near until you see the Active Button Icon.");
        isFirstTime = true;
        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);
        _as = GetComponent<AudioSource>();
        //Debug.Log(transform.GetChild(2));
        shotsLeft = shots;
        laser.gameObject.SetActive(false);
        Baseball = Resources.Load<Baseball>("tennisBallaux");
        InitialStock = 20;
        BaseballPool = new PoolObject<Baseball>(BaseballFactory, ActivateBaseball, DeactivateBaseball, InitialStock, true);
        ActiveBallsState1();
    }

    public void Interact()
    {
        if (HasPlayerTennisBallBox && IsEmpty)
        {
            if (ReloadCoroutine != null) StopCoroutine(ReloadCoroutine);
            ReloadCoroutine = StartCoroutine(ReloadTurret());
            return;
        }

        if (!active)
        {
            Debug.Log("Active la torreta");

            if (isFirstTime) { isFirstTime = false; _animator.SetBool("HasNoBalls", false); }

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
        {
            //Debug.Log("ENTRA EN ACTIVA?");
            FieldOfView();
        }
        
        /* 
        if (shotsLeft == 0) Se chequea al instanciar una pelota.
        {
            Inactive();
        } */
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
        if  (_canShoot == false || _currentObjective.GetComponent<Enemy>().isDead)
            return;
        
        if (shotsLeft == 0)
        {
            Inactive();
        }

        laser.gameObject.SetActive(true);
        ShootEffect.Play();
        shotsLeft--;
        shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
        ChangeBallsState(shotsLeft);
        FireBaseball();
        //GameObject aux = Instantiate(projectilePrefab, exitPoint.transform.position, Quaternion.identity);
        //aux.GetComponent<Rigidbody>().AddForce(35f * exitPoint.transform.forward, ForceMode.Impulse);     Usamos Pool :D
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
    }

    public void ActiveBallsState1()
    {
        ballsState1.SetActive(true);
    }

    public void TakeDamage(float dmgAmount)
    {
        _currentLife -= dmgAmount;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretHitDamage", 0.25f, false);
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

    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        _animator.enabled = true;
        _animator.SetBool("HasNoBalls", true);
        _animator.SetBool("IsDetectingTarget", false);
        laser.gameObject.SetActive(false);
        active = false;
    }

    IEnumerator PlayShutdownSound()
    {
        _isDisabledSFX = false;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretShutDown", 0.16f, false);
        yield return new WaitForSeconds(1f);
        GameVars.Values.soundManager.StopSound();
        _isDisabledSFX = true;
    }

    IEnumerator RoutineSearchingForObjectives()
    {
        SearchingForObjectives();
        yield return new WaitForSeconds(0.9f);
    }

    IEnumerator RoutineEndSearchingForObjectives()
    {

        EndSearchingForObjective();
        yield return new WaitForSeconds(0.9f);
    }
    private void SearchingForObjectives()
    {
        _animator.enabled = true;
        _animator.SetBool("IsDetectingTarget", true);

    }

    private void EndSearchingForObjective()
    {
        _animator.enabled = false;
        _animator.SetBool("IsDetectingTarget", false);
    }

    public void ActiveDeactivateBallStates(bool state1, bool state2, bool state3)
    {
        ballsState1.SetActive(state1);
        ballsState2.SetActive(state2);
        ballsState3.SetActive(state3);
    }

    public void BecomeMovable()
    {
        GameVars.Values.currentShotsTrap1 = shotsLeft;
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

    private Baseball BaseballFactory()
    {
        return Instantiate(Baseball);
    }

    private void DeactivateBaseball(Baseball o)
    {
        o.gameObject.SetActive(false);
        o.transform.localPosition = new Vector3(0f, 0f, 0f);
    }

    private void ActivateBaseball(Baseball o)
    {
        o.gameObject.SetActive(true);
    }

    private void FireBaseball()
    {
        if(_canShoot)
        {
            BaseballPool.GetObject().SetInitialPos(exitPoint.transform.position).SetOwner(this);
        }
        
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
