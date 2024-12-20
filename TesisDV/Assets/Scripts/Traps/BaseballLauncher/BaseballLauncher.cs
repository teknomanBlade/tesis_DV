using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BaseballLauncher : Trap, IMovable, IInteractable
{
    #region Events
    public delegate void OnReloadDelegate();
    public event OnReloadDelegate OnReload;
    public delegate void OnSwitchLargeContainerDelegate();
    public event OnSwitchLargeContainerDelegate OnSwitchLargeContainer;
    #endregion
    private float _maxLife = 100f;
    [SerializeField] private float _currentLife;
    private float _valueToChange;
    private bool _isDestroyed;
    private bool _isDisabledSFX;
    [SerializeField] private Inventory _inventory;
    private GameObject _craftingScreen;
    public ParticleSystem HitTurret;
    public ParticleSystem ShootEffect;
    private AudioSource _as;
    public Animator UIAnim;
    public float currentTimeAnimUI;
    public GameObject projectilePrefab;
    public GameObject blueprintPrefab;
    public GameObject exitPoint;
    //public GameObject ballsState1, ballsState2, ballsState3;
    public GameObject ballsContainerSmall, ballsContainerLarge;
    public GameObject ballsContainerUpgradeSmall, ballsContainerUpgradeLarge;
    [SerializeField] private GameObject trapDestroyPrefab;
    public int shots;
    public int shotsLeft;
    public int shotsRemaining;
    [SerializeField] private float _damageAmount;
    [SerializeField] private float _coefMelee;
    [SerializeField] private float _coefTank;
    public bool IsEmpty
    {
        get
        {
            return shotsLeft == 0;
        }
    }
    public bool HasTennisBallContainerSmall;
    public bool HasTennisBallContainerLarge;
    public bool IsContainerLarge;
    public bool IsContainerSmall;
    public bool IsMoving;
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
    [SerializeField] private float _damageBoostCoef;
    [SerializeField] private float _staticChargeSlowAmount;
    [SerializeField] private GameObject _staticBallsBlueprint;
    [SerializeField] private GameObject _staticBallsUpgrade;
    [SerializeField] private GameObject _damageBoostBlueprint;
    [SerializeField] private GameObject _damageBoostUpgrade;
    [SerializeField] private GameObject _doubleLoaderSmallBlueprint;
    [SerializeField] private GameObject _doubleLoaderSmallUpgrade;
    [SerializeField] private GameObject _doubleLoaderLargeBlueprint;
    [SerializeField] private GameObject _doubleLoaderLargeUpgrade;
    public bool StaticBallsUpgradeEnabled;
    public bool DoubleLoaderSmallUpgradeEnabled;
    public bool DoubleLoaderLargeUpgradeEnabled;
    public bool _canActivate1aUpgrade {get; private set;}
    public bool _canActivate2aUpgrade {get; private set;}
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    private void Start()
    {
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        
    }
    public void Awake()
    {
        //active = false; Ahora las trampas empiezan encendidas.
        _craftingScreen = GameObject.Find("CraftingContainer");
        _inventory = _craftingScreen.GetComponentInChildren<Inventory>();
        _coefMelee = 3f;
        _coefTank = 5f;
        _damageBoostCoef = 1.5f;
        _staticChargeSlowAmount = 1.2f;
        GameVars.Values.IsAllSlotsDisabled();
        _animator = GetComponent<Animator>();
        UIAnim = GetComponentsInChildren<Animator>().Where(x => x.name.Contains("BulletIndicatorUI")).FirstOrDefault();
        _currentLife = _maxLife;
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        isFirstTime = true;
        IsContainerSmall = true;
        IsContainerLarge = false;
        myCannonSupport = transform.GetChild(2);
        myCannon = transform.GetChild(2).GetChild(0);
        _as = GetComponent<AudioSource>();
        laser.gameObject.SetActive(false);
        Baseball = Resources.Load<Baseball>("tennisBallaux");
        InitialStock = 20;
        BaseballPool = new PoolObject<Baseball>(BaseballFactory, ActivateBaseball, DeactivateBaseball, InitialStock, true);
        StartTrap();
        SetUIIndicator("UI_BaseballLauncher_Indicator");
    }

    void Update()
    {
        if (active)
        {
            //Debug.Log("ENTRA EN ACTIVA?");
            FieldOfView();
        }
    }
    #region Initialization Logic
    public void SetShots(int s)
    {
        shotsLeft = shots = s;
    }
    public BaseballLauncher SetShotsRemainingZero()
    {
        if (!IsMoving)
            shotsRemaining = 0;

        return this;
    }
    public BaseballLauncher InitializeTrap()
    {
        StartTrap();
        return this;
    }
    public BaseballLauncher SetInitPos(Vector3 pos)
    {
        this.transform.position = pos;
        return this;
    }
    public BaseballLauncher SetInitRot(Quaternion rot)
    {
        this.transform.rotation = rot;
        return this;
    }
    public BaseballLauncher SetParent(Transform parent)
    {
        this.transform.parent = parent;
        return this;
    }
    public int GetShotsByContainer()
    {
        int shots = 0;

        if (ballsContainerSmall.activeSelf)
        {
            shots = 5;
        }
        else if (ballsContainerLarge.activeSelf)
        {
            shots = 10;
        }
        else if (ballsContainerUpgradeSmall.activeSelf)
        {
            shots = 10;
        }
        else if (ballsContainerUpgradeLarge.activeSelf)
        {
            shots = 20;
        }

        return shots;
    }
    private void StartTrap()
    {
        active = true;
        currentTimeAnimUI = (float)shotsLeft / shots;
        UIAnim.SetFloat("BallStates", currentTimeAnimUI);
        _staticBallsUpgrade.SetActive(StaticBallsUpgradeEnabled);
        if (DoubleLoaderSmallUpgradeEnabled || DoubleLoaderLargeUpgradeEnabled)
        {
            ActiveDeactivateBallStates(false, false);
        }
        else
        {
            if (IsContainerLarge)
            {
                ActiveDeactivateBallStates(false, true);
            }
            else 
            {
                ActiveDeactivateBallStates(true, false);
            }
        }

        ballsContainerUpgradeSmall.SetActive(DoubleLoaderSmallUpgradeEnabled);
        ballsContainerUpgradeLarge.SetActive(DoubleLoaderLargeUpgradeEnabled);
        if (IsMoving)
        {
            SetShots(shotsRemaining);
        }
        else
        {
            SetShots(GetShotsByContainer());
        }
        SearchingForObjectives();
        _animator.SetBool("HasNoBalls", false);
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
        ShootCoroutine = StartCoroutine("ActiveCoroutine");
        IsMoving = false;
    }
    #endregion

    #region Trap Actions
    public void Interact()
    {
        if ((HasTennisBallContainerSmall || HasTennisBallContainerLarge) && IsEmpty)
        {
            if (ReloadCoroutine != null) StopCoroutine(ReloadCoroutine);
            ReloadCoroutine = StartCoroutine(ReloadTurret());
            return;
        }

        if (!active && !IsEmpty)
        {
            Debug.Log("Active la torreta");

            StartTrap();
        }
    }

    public void SwitchLargeContainer() 
    {
        ActiveDeactivateBallStates(false, true);
        SetShots(GetShotsByContainer());
        IsContainerLarge = true;
        IsContainerSmall = false;
        OnSwitchLargeContainer?.Invoke();
    }

    public void Reload()
    {
        SetShots(GetShotsByContainer());
        active = true;
        StartCoroutine("ActiveCoroutine");
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        _isDisabledSFX = false;
        _animator.enabled = true;
        _animator.SetBool("HasNoBalls", false);
        ActivateTennisBallsByReload();
        OnReload?.Invoke();
        currentTimeAnimUI = (float)shotsLeft / shots;
        UIAnim.SetFloat("BallStates", currentTimeAnimUI);
        GameVars.Values.ShowNotification("The Turret has been reloaded.");
    }
    IEnumerator ReloadTurret()
    {
        GameVars.Values.ShowNotification("Reloading turret...");
        GameVars.Values.soundManager.PlaySoundOnce(_as, "ReloadingTurret1", 0.8f, false);
        yield return new WaitForSeconds(2.5f);
        Debug.Log("LLEGA A RELOAD?");
        Reload();
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
        currentTimeAnimUI = (float) 1 / shotsLeft;
        UIAnim.SetFloat("BallStates", currentTimeAnimUI);
        if (ballsContainerSmall.activeSelf) 
        {
            RemoveLastVisualTennisBall();
        }
        else if(ballsContainerLarge.activeSelf) 
        {
            RemoveLastVisualTennisBallLarge();
        }
        
        FireBaseball();
        GameVars.Values.soundManager.PlaySoundAtPoint("BallLaunched", transform.position, 0.7f);
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
        GameVars.Values.soundManager.PlaySound(_as, "SFX_TurretDetection", 0.35f, true,1f);
    }

    private void EndSearchingForObjective()
    {
        _animator.enabled = false;
        _animator.SetBool("IsDetectingTarget", false);
    }

    public void BecomeMovable()
    {
        IsMoving = true;
        shotsRemaining = shotsLeft;
        GameVars.Values.BaseballLauncherPool.ReturnObject(this);
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false).CanBeCancelled(false);

        transform.parent = null;
        _myTrapBase.ResetBase();
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
        o.transform.parent = transform;
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
    }
    private void FireBaseball()
    {
        if (_currentObjective != null && _canShoot)
        {
            BaseballPool.GetObject().SetInitialPos(exitPoint.transform.position).SetOwnerForward(exitPoint.transform.forward).SetOwner(this);
            var enemy = _currentObjective.GetComponent<Enemy>();
            EnemyDamageDifferential(enemy);
        }
    }

    public void EnemyDamageDifferential(Enemy enemy)
    {
        if (enemy == null)
            return;

        if (_canActivate1bUpgrade)
        {
            Debug.Log("ACTIVO SLOW STATIC CHARGE...");
            enemy.SlowDebuff(_staticChargeSlowAmount);
            enemy.ElectricDebuffHit();
        }

        if (enemy.enemyType == EnemyType.Common)
        {
            Debug.Log("DAÑO GRAY: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
        else if (enemy.enemyType == EnemyType.Melee)
        {
            _damageAmount /= _coefMelee;
            Debug.Log("DAÑO MELEE: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
        else if (enemy.enemyType == EnemyType.Tank)
        {
            _damageAmount /= _coefTank;
            Debug.Log("DAÑO TANK: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
        }
    }
    #endregion

    #region Visual Behaviour

    public void ActiveDeactivateBallStates(bool ballContainerSmall, bool ballContainerLarge)
    {
        ballsContainerSmall.SetActive(ballContainerSmall);
        ballsContainerLarge.SetActive(ballContainerLarge);
    }
    public void ActivateTennisBallsByReload() 
    {
        if (ballsContainerSmall.activeSelf)
        {
            var tennisBalls = ballsContainerSmall.transform.GetComponentsInChildren<Transform>(true).Where(x => x.name.Contains("tennisBall"));
            if (tennisBalls.Count() <= 0) return;

            tennisBalls.ToList().ForEach(x => x.gameObject.SetActive(true));
        }
        else if (ballsContainerLarge.activeSelf) 
        {
            var tennisBallsLarge = ballsContainerLarge.transform.GetComponentsInChildren<Transform>(true).Where(x => x.name.Contains("tennisBall"));
            if (tennisBallsLarge.Count() <= 0) return;

            tennisBallsLarge.ToList().ForEach(x => x.gameObject.SetActive(true));
        }
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
        //Debug.Log("Tennis Balls: " + tennisBalls.Count());
        if (tennisBalls.Count() <= 0) return;

        tennisBalls.LastOrDefault().gameObject.SetActive(false);
    }

    public void RemoveLastVisualTennisBallLarge()
    {
        var tennisBalls = ballsContainerLarge.transform.GetComponentsInChildren<Transform>().Where(x => x.name.Contains("tennisBall"));
        //Debug.Log("Tennis Balls: " + tennisBalls.Count());
        if (tennisBalls.Count() <= 0) return;

        tennisBalls.LastOrDefault().gameObject.SetActive(false);
    }
    #endregion

    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if(_skillTree.isBL1aActivated)
        {
            Activate1aUpgrade();
        }
        if (_skillTree.isBL1bActivated)
        {
            Activate1bUpgrade();
        }
        if (_skillTree.isBL2aActivated)
        {
            Activate2aUpgrade();
        }
        if (_skillTree.isBL2bActivated)
        {
            Activate2bUpgrade();
        }
    }

    public void Activate1aUpgrade()
    {
        _canActivate1aUpgrade = true;
        //Aplicar beneficio del Upgrade
        _damageAmount *= _damageBoostCoef;
    }
    public void Activate1bUpgrade()
    {
        _canActivate1bUpgrade = true;
        _canActivate1aUpgrade = false;
        StaticBallsUpgradeEnabled = _canActivate1bUpgrade;
        //Aplicar beneficio del Upgrade
        _damageBoostCoef = 2.5f;
        _damageAmount = _damageBoostCoef;
    }

    public void Activate2aUpgrade()
    {
        _canActivate2aUpgrade = true;
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        DoubleLoaderSmallUpgradeEnabled = _canActivate2aUpgrade;
        SetShots(10);
    }
    public void Activate2bUpgrade()
    {
        _canActivate2bUpgrade = true;
        _canActivate2aUpgrade = false;
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        DoubleLoaderLargeUpgradeEnabled = _canActivate2bUpgrade;
        DoubleLoaderSmallUpgradeEnabled = _canActivate2aUpgrade;
        SetShots(20);
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
