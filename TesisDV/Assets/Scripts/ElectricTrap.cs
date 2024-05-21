using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTrap : Trap, IMovable, IInteractable
{
    [SerializeField] private float _damage;
    [SerializeField] private float _damageBoostCoef;
    [SerializeField] private float _damagePerSecond;
    [SerializeField] private float _dpsBoostCoef;
    [SerializeField] private GameObject midPositionDamage;
    [SerializeField] private GameObject endPositionDamage;
    //[SerializeField] private float _trapDuration;
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
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        GameVars.Values.IsAllSlotsDisabled();
        active = true; // Ahora las trampas empiezan encendidas.   
        _as = GetComponent<AudioSource>();
        ElectricityLineRenderer = GetComponent<ElectricityLineRenderer>();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "ElectricTrapSFX", 0.25f, true);
        SetUIIndicator("UI_ElectricTrap_Indicator");
    }

    private void Update()
    {
        /* _trapDuration -= Time.deltaTime; La trampa ya no se apaga sola

        if (_trapDuration <=0)
        {
            active = false;
            ParticleLightning.SetActive(false);
            ElectricRadius.SetActive(false);
        } */
    }

    public void Interact()
    {
        if (!active)
        {
            active = true;
            GameVars.Values.soundManager.PlaySoundOnce(_as, "ElectricTrapSFX", 0.25f, true);
            ParticleLightning.SetActive(true);
            ElectricityLineRenderer.DisableEnableLightAndLineRenderer(true);
        }
        /* if(_trapDuration <= 0) La trampa ya no se apaga sola
        {
            _trapDuration =10f;
        } */
    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log("ENTRA EN COLLIDER...");
        var enemyGray = other.GetComponent<Enemy>();

        if (enemyGray && other.GetComponent<GrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 0.5f; 
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }
        if (enemyGray && other.GetComponent<TallGrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 1.5f;
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }
        if (enemyGray && other.GetComponent<TankGrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 4f;
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }

    }

    private void OnTriggerStay(Collider other)
    {
        var enemyGray = other.GetComponent<Enemy>();

        if(enemyGray && active)
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
            _doubleDamageBlueprint.SetActive(true);
            _canActivate1aUpgrade = true;
        }
        else if (_skillTree.isET1bActivated)
        {
            _dpsIncreaseBlueprint.SetActive(true);
            _canActivate1bUpgrade = true;
        }
        else if (_skillTree.isET2aActivated)
        {
            _doubleRangeBlueprint.SetActive(true);
            _canActivate2aUpgrade = true;
        }
        else if (_skillTree.isET2bActivated)
        {
            _areaOfEffectBlueprint.SetActive(true);
            _canActivate2bUpgrade = true;
        }
    }

    public void Activate1aUpgrade()
    {
        _doubleDamageBlueprint.SetActive(false);
        _doubleDamageUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
        //_damageAmount *= _damageBoostCoef;
    }
    public void Activate1bUpgrade()
    {
        _dpsIncreaseBlueprint.SetActive(false);
        _dpsIncreaseUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
        //_damageAmount *= _damageBoostCoef;
    }

    public void Activate2aUpgrade()
    {
        _doubleRangeBlueprint.SetActive(false);
        _doubleRangeUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }
    public void Activate2bUpgrade()
    {
        _areaOfEffectBlueprint.SetActive(false);
        _areaOfEffectUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    #endregion
}
