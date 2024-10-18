using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTrap : Trap, IMovable, IInteractable
{
    private const float meleeDmg = 1.5f;
    private const float tankDmg = 4f;
    [SerializeField] private float _damage;
    private float _initDamage;
    private float _damageBoostCoef;
    [SerializeField] private float _damagePerSecond;
    private float _initDPS;
    private float _dpsBoostCoef;
    [SerializeField] private GameObject midPositionDamage;
    [SerializeField] private GameObject endPositionDamage;
    [SerializeField] private float _currentLife;
    public ElectricityLineRenderer ElectricityLineRenderer;
    public GameObject blueprintPrefab;
    public GameObject ParticleLightning;
    private bool _isDisabledSFX;
    private AudioSource _as;

    #region Upgrades
    [Header("Upgrades")]
    [SerializeField] private GameObject _doubleDamageBlueprint;
    [SerializeField] private GameObject _doubleDamageUpgrade;
    [SerializeField] private GameObject _dpsIncreaseBlueprint;
    [SerializeField] private GameObject _dpsIncreaseUpgrade;
    [SerializeField] private GameObject _doubleRangeBlueprint;
    [SerializeField] private GameObject _doubleRangeUpgrade;
    [SerializeField] private GameObject _areaOfEffectBlueprint;
    [SerializeField] private GameObject _areaOfEffectUpgrade;
    public bool DoubleDamageActive;
    public bool DPSIncreaseActive;
    public bool DoubleRangeActive;
    public bool AreaOfEffectActive;
    public bool _canActivate1aUpgrade { get; private set; }
    public bool _canActivate2aUpgrade { get; private set; }
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    private void Start()
    {
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        _initDamage = 0.5f;
        _initDPS = 0.05f;
        _damageBoostCoef = 2;
        _dpsBoostCoef = 1.45f;
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        GameVars.Values.IsAllSlotsDisabled();
        active = true; // Ahora las trampas empiezan encendidas.   
        _as = GetComponent<AudioSource>();
        ElectricityLineRenderer = GetComponent<ElectricityLineRenderer>();
        GameVars.Values.soundManager.PlaySound(_as, "ElectricTrapSFX", 0.25f, true, 1f);
        SetUIIndicator("UI_ElectricTrap_Indicator");
    }

    private void Update()
    {
        
    }

    public void Interact()
    {
        if (!active)
        {
            active = true;
            GameVars.Values.soundManager.PlaySound(_as, "ElectricTrapSFX", 0.25f, true, 1f);
            ParticleLightning.SetActive(true);
            ElectricityLineRenderer.DisableEnableLightAndLineRenderer(true);
        }
       
    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log("ENTRA EN COLLIDER ENTER...");
        var enemyGray = other.GetComponent<Enemy>();

        if (enemyGray == null) return;

        if ((other.GetComponent<GrayModel>() || other.GetComponent<GrayModelHardcodeado>()) && active)
        {
            //Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = (DoubleDamageActive) ? _initDamage * _damageBoostCoef : _initDamage; 
        }
        if (other.GetComponent<TallGrayModel>() && active)
        {
            //Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = (DoubleDamageActive) ? meleeDmg * _damageBoostCoef : meleeDmg;
        }
        if (other.GetComponent<TankGrayModel>() && active)
        {
            //Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = (DoubleDamageActive) ? tankDmg : tankDmg * _damageBoostCoef;
        }
        //Debug.Log("DAMAGE COLLIDER ENTER: " + _damage);
        enemyGray.TakeDamage(_damage);
    }

    private void OnTriggerStay(Collider other)
    {
        //Debug.Log("ENTRA EN COLLIDER STAY...");
        var enemyGray = other.GetComponent<Enemy>();
        _damagePerSecond = (DPSIncreaseActive) ? _initDPS * _dpsBoostCoef : _initDPS;
        if (enemyGray && active)
        {
            other.GetComponent<Enemy>().TakeDamage(_damagePerSecond);
        }
    }
    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        ParticleLightning.SetActive(false);
        ElectricityLineRenderer.DisableEnableLightAndLineRenderer(false);
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

    public void BecomeMovable()
    {
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
        Destroy(gameObject);
    }
    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if (_skillTree.isET1aActivated)
        {
           Activate1aUpgrade();
        }
        if (_skillTree.isET1bActivated)
        {
            Activate1bUpgrade();
        }
        if (_skillTree.isET2aActivated)
        {
            Activate2aUpgrade();
        }
        if (_skillTree.isET2bActivated)
        {
            Activate2bUpgrade();
        }
    }

    public void Activate1aUpgrade()
    {
        //Aplicar beneficio del Upgrade
        _canActivate1aUpgrade = true;
        _canActivate1bUpgrade = false;
        DoubleDamageActive = _canActivate1aUpgrade;
    }
    public void Activate1bUpgrade()
    {
        //Aplicar beneficio del Upgrade
        _canActivate1aUpgrade = false;
        _canActivate1bUpgrade = true;
        DPSIncreaseActive = _canActivate1bUpgrade;
    }

    public void Activate2aUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = true;
        DoubleRangeActive = _canActivate2aUpgrade;
        midPositionDamage.transform.localScale = new Vector3(2f, 1f, 1f);
        endPositionDamage.transform.localScale = new Vector3(2f, 1f, 1f);
        endPositionDamage.transform.localPosition = new Vector3(endPositionDamage.transform.localPosition.x - 2.1f, endPositionDamage.transform.localPosition.y, endPositionDamage.transform.localPosition.z);
        //Aplicar beneficio del Upgrade
    }
    public void Activate2bUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = false;
        _canActivate2bUpgrade = true;
        AreaOfEffectActive = _canActivate2bUpgrade;
        GetComponent<SphereCollider>().enabled = true;
        midPositionDamage.SetActive(false);
        endPositionDamage.SetActive(false);
        //Aplicar beneficio del Upgrade
    }

    #endregion
}
