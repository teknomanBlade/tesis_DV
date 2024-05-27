using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static UnityEditor.FilePathAttribute;

public class FERNPaintballMinigun : Trap, IMovable, IInteractable
{
    private float _maxLife = 10f;
    [SerializeField] private float _currentLife;
    private AudioSource _as;
    private bool _isDestroyed;
    public int shots;
    public int shotsLeft;
    public float interval;
    public bool IsEmpty
    {
        get
        {
            return shotsLeft == 0;
        }
    }
    public bool HasPaintballPelletMagazine { get; set; }
    public GameObject blueprintPrefab;
    public GameObject exitPoint;
    [SerializeField] private float _damageAmount;
    [SerializeField] private GameObject trapDestroyPrefab;
    [SerializeField] private GameObject _magazine;
    public delegate void OnReloadDelegate();
    public event OnReloadDelegate OnReload;
    
    public PoolObject<PaintballPellet> PaintballPelletsPool { get; set; }
    public PaintballPellet PaintballPellet;
    public int InitialStock { get; private set; }
    private Coroutine ReloadCoroutine;
    private Coroutine ShootCoroutine;
    #region Upgrades
    [Header("Upgrades")]
    [SerializeField] private GameObject _plus100SPBlueprint;
    [SerializeField] private GameObject _plus100SPUpgrade;
    [SerializeField] private GameObject _plus200SPBlueprint;
    [SerializeField] private GameObject _plus200SPUpgrade;
    [SerializeField] private GameObject _secondaryShieldsBlueprint;
    [SerializeField] private GameObject _secondaryShieldsUpgrade;
    [SerializeField] private GameObject _returnDamageBlueprint;
    [SerializeField] private GameObject _returnDamageUpgrade;
    public bool _canActivate1aUpgrade { get; private set; }
    public bool _canActivate2aUpgrade { get; private set; }
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    // Start is called before the first frame update
    void Awake()
    {
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        _magazine = transform.GetComponentsInChildren<Transform>(true).Where(x => x.name.Equals("FERNMinigunPelletsMagazine")).FirstOrDefault().gameObject;
        _currentLife = _maxLife;
        InitialStock = shotsLeft = shots = 150;
        _as = GetComponent<AudioSource>();
        _animator = GetComponent<Animator>();
        PaintballPellet = Resources.Load<PaintballPellet>("PaintballPellet");
        exitPoint = transform.GetComponentsInChildren<Transform>().FirstOrDefault(x => x.name.Equals("BulletSpawnPoint")).gameObject;
        PaintballPelletsPool = new PoolObject<PaintballPellet>(PaintballPelletFactory, PaintballPelletActivate, PaintballPelletDeactivate, InitialStock, true);
        StartTrap();
        SetUIIndicator("UI_FERNPaintballMinigun_Indicator");
    }

    private void PaintballPelletDeactivate(PaintballPellet pp)
    {
        pp.gameObject.SetActive(false);
        pp.transform.localPosition = new Vector3(0f, 0f, 0f);
        //pp.transform.SetParent(transform);
    }

    private void PaintballPelletActivate(PaintballPellet pp)
    {
        pp.gameObject.SetActive(true);
    }

    private PaintballPellet PaintballPelletFactory()
    {
        return Instantiate(PaintballPellet);
    }

    // Update is called once per frame
    void Update()
    {
        if (active)
        {
            //Debug.Log("ENTRA EN ACTIVA?");
            FieldOfView();
        }
    }
    public override void ShootAnimation(Vector3 rotation)
    {
        //Debug.Log("ENTRA EN SHOOT ANIMATION?");
        var minigunSpeedRotation = 500f;
        var speedMultiplier = 2.5f;
        myCannon.transform.Rotate(Vector3.right, minigunSpeedRotation * speedMultiplier * Time.deltaTime);
    }
   
    private void StartTrap()
    {
        active = true;
        _magazine.SetActive(true);
        SearchingForObjectives();
        _animator.SetBool("HasNoPellets", false);
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
        ShootCoroutine = StartCoroutine(ActiveCoroutine());
    }
    private void SearchingForObjectives()
    {
        _animator.enabled = true;
    }

    public void BecomeMovable()
    {
        //GameVars.Values.currentShotsTrap1 = shotsLeft;
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
        Destroy(gameObject);
    }
    public void HasPaintballMagazine(bool magOnInventory)
    {
        HasPaintballPelletMagazine = magOnInventory;
    }
    public void Interact()
    {
        if (HasPaintballPelletMagazine && IsEmpty)
        {
            if (ReloadCoroutine != null) StopCoroutine(ReloadCoroutine);
            ReloadCoroutine = StartCoroutine(ReloadTurret());
            return;
        }

        if (!active)
        {
            Debug.Log("Active la Torreta de Paintball");

            StartTrap();
        }
    }
    IEnumerator ReloadTurret()
    {
        GameVars.Values.ShowNotification("Reloading turret...");
        GameVars.Values.soundManager.PlaySoundOnce(_as,"PaintballMagazineReload", 0.7f, false);
        yield return new WaitForSeconds(1.2f);
        Debug.Log("LLEGA A RELOAD?");
        Reload();
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
            //isWorking = false;
            //DestroyThisTrap();
        }
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
            /*for (int i = 0; i < _myItems.Count; i++)
            {
                Vector3 itemPos = new Vector3(UnityEngine.Random.Range(0.1f, 2.3f), 0, UnityEngine.Random.Range(0.1f, 2.3f));
                Instantiate(_myItems[i], transform.position + aux + itemPos, Quaternion.Euler(-90f, 0f, 0f));
            }*/
        }
        Destroy(this.gameObject);
    }
    public void Reload()
    {
        shotsLeft = shots;
        active = true;
        StartCoroutine("ActiveCoroutine");
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        //_isDisabledSFX = false;
        _animator.enabled = true;
        _animator.SetBool("HasNoPellets", false);
        OnReload?.Invoke();
        GameVars.Values.ShowNotification("The Paintball Minigun has been reloaded.");
    }
    IEnumerator ActiveCoroutine()
    {
        if (active && shotsLeft > 0)
        {
            GetPaintballPellet();
            yield return new WaitForSeconds(interval);
            if (shotsLeft != 0) StartCoroutine(ActiveCoroutine());
            else active = false;
        }
        else
        {
            yield return new WaitForSeconds(0.01f);
        }

    }
    //PaintballMinigunFire
    //PaintballMagazineReload
    public void GetPaintballPellet()
    {
        if (!_canShoot || (_currentObjective != null && _currentObjective.GetComponent<Enemy>().isDead))
            return;

        if (shotsLeft == 0)
        {
            Inactive();
        }
        GameVars.Values.soundManager.PlaySoundOnce("PelletFire", 0.7f, false);
        //ShootEffect.Play();
        shotsLeft--;
        shotsLeft = Mathf.Clamp(shotsLeft, 0, shots);
        FirePaintballPellet();
    }

    private void FirePaintballPellet()
    {
        if (_currentObjective != null && _canShoot)
        {
            PaintballPelletsPool.GetObject().SetInitialPos(exitPoint.transform.position).SetOwnerForward(exitPoint.transform.right).SetOwner(this)/*.SetAdditionalDamage(_additionalDamage)*/;
            EnemyDamageDifferential(_currentObjective.GetComponent<Enemy>());
            
        }
    }
    public void EnemyDamageDifferential(Enemy enemy)
    {
        if (enemy == null)
            return;

        if (enemy.name.Contains("GrayMVC"))
        {
            _damageAmount = 0.05f;
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
            _damageAmount = 0.35f;
            Debug.Log("DAÑO TANK: " + _damageAmount);
            enemy.TakeDamage(_damageAmount);
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
        return new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0 , Mathf.Cos(angle * Mathf.Deg2Rad));
    }
    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if (_skillTree.isFPM1aActivated)
        {
            _plus100SPBlueprint.SetActive(true);
            _canActivate1aUpgrade = true;
        }
        else if (_skillTree.isFPM1bActivated)
        {
            _plus200SPBlueprint.SetActive(true);
            _canActivate1bUpgrade = true;
        }
        else if (_skillTree.isFPM2aActivated)
        {
            _secondaryShieldsBlueprint.SetActive(true);
            _canActivate2aUpgrade = true;
        }
        else if (_skillTree.isFPM2bActivated)
        {
            _returnDamageBlueprint.SetActive(true);
            _canActivate2bUpgrade = true;
        }
    }

    public void Activate1aUpgrade()
    {
        _plus100SPBlueprint.SetActive(false);
        _plus100SPUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }
    public void Activate1bUpgrade()
    {
        _plus200SPBlueprint.SetActive(false);
        _plus200SPUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    public void Activate2aUpgrade()
    {
        _secondaryShieldsBlueprint.SetActive(false);
        _secondaryShieldsUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }
    public void Activate2bUpgrade()
    {
        _returnDamageBlueprint.SetActive(false);
        _returnDamageUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    #endregion
}
