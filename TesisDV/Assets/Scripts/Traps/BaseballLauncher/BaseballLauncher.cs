using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static UnityEditor.FilePathAttribute;

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
    //public GameObject ballsState1, ballsState2, ballsState3;
    public GameObject ballsContainerSmall, ballsContainerLarge;
    [SerializeField] private GameObject trapDestroyPrefab;
    public int shots;
    public int shotsLeft;
    public bool IsEmpty
    {
        get
        {
            return shotsLeft == 0;
        }
    }
    public bool HasTennisBallContainerSmall { get; set; }
    public bool HasTennisBallContainerLarge { get; set; }
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

    #region Upgrades
    [Header("Upgrades")]
    [SerializeField] private GameObject _staticBallsBlueprint;
    [SerializeField] private GameObject _staticBallsUpgrade;
    [SerializeField] private float _damageAmount;
    [SerializeField] private GameObject _fireRateBlueprint;
    [SerializeField] private GameObject _fireRateUpgrade;
    public bool _canActivate1Upgrade {get; private set;}
    public bool _canActivate2Upgrade {get; private set;}
    private SkillTree _skillTree;

    #endregion
    public void Awake()
    {
        //active = false; Ahora las trampas empiezan encendidas.
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        GameVars.Values.IsAllSlotsDisabled();
        _animator = GetComponent<Animator>();
        _currentLife = _maxLife;
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        isFirstTime = true;
        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);
        _as = GetComponent<AudioSource>();
        laser.gameObject.SetActive(false);
        Baseball = Resources.Load<Baseball>("tennisBallaux");
        InitialStock = 20;
        BaseballPool = new PoolObject<Baseball>(BaseballFactory, ActivateBaseball, DeactivateBaseball, InitialStock, true);
        ActiveDeactivateBallStates(true, false);
        StartTrap();
        SetUIIndicator("UI_BaseballLauncher_Indicator");
    }

    public void SetShots(int shots) 
    {
        shotsLeft = this.shots = shots;
    }

    private void StartTrap()
    {
        active = true;
        SearchingForObjectives();
        _animator.SetBool("HasNoBalls", false);
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
        ShootCoroutine = StartCoroutine("ActiveCoroutine");
    }

    public void Interact()
    {
        if ((HasTennisBallContainerSmall || HasTennisBallContainerLarge) && IsEmpty)
        {
            if (ReloadCoroutine != null) StopCoroutine(ReloadCoroutine);
            ReloadCoroutine = StartCoroutine(ReloadTurret());
            return;
        }

        if (!active)
        {
            Debug.Log("Active la torreta");

            //if (isFirstTime) { isFirstTime = false; _animator.SetBool("HasNoBalls", false); }

            StartTrap();
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
        shotsLeft = shots;
        active = true;
        StartCoroutine("ActiveCoroutine");
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        _isDisabledSFX = false;
        _animator.enabled = true;
        _animator.SetBool("HasNoBalls", false);
        ActivateTennisBallsByReload();
        OnReload?.Invoke();
        GameVars.Values.ShowNotification("The Turret has been reloaded.");
    }
    IEnumerator ActiveCoroutine()
    {
        if (active && shotsLeft > 0)
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
        if  (_canShoot == false || (_currentObjective != null && _currentObjective.GetComponent<Enemy>().isDead))
            return;
        
        if (shotsLeft == 0)
        {
            Inactive();
        }

        ShootEffect.Play();
        shotsLeft--;
        shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
        
        if (ballsContainerSmall.activeSelf) 
        {
            RemoveLastVisualTennisBall();
        }
        else if(ballsContainerLarge.activeSelf) 
        {
            RemoveLastVisualTennisBall();
        }
        
        FireBaseball();
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
    }

    public void ActivateTennisBallsByReload() 
    {
        var tennisBalls = ballsContainerSmall.transform.GetComponentsInChildren<Transform>(true).Where(x => x.name.Contains("tennisBall"));
        if (tennisBalls.Count() <= 0) return;
        
        tennisBalls.ToList().ForEach(x => x.gameObject.SetActive(true));
    }

    public void RemoveVisualTennisBallsByShotsLeft() 
    {
        var tennisBalls = ballsContainerSmall.transform.GetComponentsInChildren<Transform>().Where(x => x.name.Contains("tennisBall"));
        if (tennisBalls.Count() <= 0) return;

        var amountToDeactivate = shots - shotsLeft;
        tennisBalls.Reverse().Take(amountToDeactivate).ToList().ForEach(x => x.gameObject.SetActive(false));
    }

    public void RemoveLastVisualTennisBall()
    {
        var tennisBalls = ballsContainerSmall.transform.GetComponentsInChildren<Transform>().Where(x => x.name.Contains("tennisBall"));
        Debug.Log("Tennis Balls: " + tennisBalls.Count());
        if (tennisBalls.Count() <= 0) return;

        tennisBalls.LastOrDefault().gameObject.SetActive(false);
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
            //ActiveDeactivateBallStates(false, false, false);
            return;
        }

        if (shotsLeft == 15)
        {
            //ActiveDeactivateBallStates(true, false, false);
        }
        else if (shotsLeft == 11)
        {
            //ActiveDeactivateBallStates(false, !ballsState2.activeSelf, false);
        }
        else if (shotsLeft == 6)
        {
            //ActiveDeactivateBallStates(false, false, !ballsState3.activeSelf);
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

    public void ActiveDeactivateBallStates(bool ballContainerSmall, bool ballContainerLarge)
    {
        ballsContainerSmall.SetActive(ballContainerSmall);
        ballsContainerLarge.SetActive(ballContainerLarge);
    }

    public void BecomeMovable()
    {
        GameVars.Values.currentShotsTrap1 = shotsLeft;
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
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
    public override void ShootAnimation(Vector3 rotation)
    {
        //Debug.Log("ENTRA EN SHOOT ANIMATION?");
        myCannon.rotation = Quaternion.Lerp(myCannon.rotation, Quaternion.Euler(0f, rotation.y, rotation.z), _shootSpeed * Time.deltaTime);
        //_animator.enabled = true;
        //_animator.SetBool("IsFiring", true);
    }
    private void FireBaseball()
    {
        if(_currentObjective != null && _canShoot)
        {
            //BaseballPool.GetObject().SetInitialPos(exitPoint.transform.position).SetOwnerForward(exitPoint.transform.forward).SetAdditionalDamage(_additionalDamage).SetOwner(this);
            var enemy = _currentObjective.GetComponent<Enemy>();
            EnemyDamageDifferential(enemy);
            
        }
    }

    public void EnemyDamageDifferential(Enemy enemy)
    {
        if(enemy == null)
            return;

        if (enemy.name.Contains("GrayMVC"))
        {
            _damageAmount = 1f;
            Debug.Log("DAÑO GRAY: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
        else if (enemy.name.Contains("Melee"))
        {
            _damageAmount = 0.25f;
            Debug.Log("DAÑO MELEE: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
        else if (enemy.name.Contains("Tank"))
        {
            _damageAmount = 0.1f;
            Debug.Log("DAÑO TANK: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
    }

    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if(_skillTree.isBL1aActivated)
        {
            _staticBallsBlueprint.SetActive(true);
            _canActivate1Upgrade = true;
        }
        else if (_skillTree.isBL21bActivated)
        {
            _fireRateBlueprint.SetActive(true);
            _canActivate2Upgrade = true;
        }
    }

    public void ActivateFirstUpgrade()
    {
        _staticBallsBlueprint.SetActive(false);
        _staticBallsUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
        _damageAmount = 3;
    }

    public void ActivateSecondUpgrade()
    {
        _fireRateBlueprint.SetActive(false);
        _fireRateUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    #endregion

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
