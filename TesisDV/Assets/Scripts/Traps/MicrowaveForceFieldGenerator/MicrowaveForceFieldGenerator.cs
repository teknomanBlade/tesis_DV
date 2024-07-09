using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MicrowaveForceFieldGenerator : Trap, IMovable, IInteractable
{
    public delegate void OnMicrowaveBatteryReplacedDelegate();
    public event OnMicrowaveBatteryReplacedDelegate OnMicrowaveBatteryReplaced;
    public delegate void OnForceFieldReturnDamageDelegate();
    public event OnForceFieldReturnDamageDelegate OnForceFieldReturnDamage;
    public delegate void OnForceFieldShieldPointsDelegate(float shieldPoints);
    public event OnForceFieldShieldPointsDelegate OnForceFieldShieldPoints;
    public delegate void OnSecondaryForceFieldShieldPointsDelegate(float shieldPoints);
    public event OnSecondaryForceFieldShieldPointsDelegate OnSecondaryForceFieldShieldPoints;
    public GameObject blueprintPrefab;
    public GameObject particleRipples;
    public GameObject EMPFriedEffect;
    public GameObject ForceField;
    public GameObject SecondaryForceField;
    private AudioSource _as;
    private bool _isDisabledSFX;
    public bool IsBatteryFried;
    #region Upgrades
    [Header("Upgrades")]
    
    [SerializeField] private GameObject _plus20SPBlueprint;
    [SerializeField] private GameObject _plus20SPUpgrade;
    [SerializeField] private GameObject _plus40SPBlueprint;
    [SerializeField] private GameObject _plus40SPUpgrade;
    [SerializeField] private GameObject _secondaryShieldsBlueprint;
    [SerializeField] private GameObject _secondaryShieldsUpgrade;
    [SerializeField] private GameObject _returnDamageBlueprint;
    [SerializeField] private GameObject _returnDamageUpgrade;
    public bool ReturnDamageActive;
    public bool _canActivate1aUpgrade { get; private set; }
    public bool _canActivate2aUpgrade { get; private set; }
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    // Start is called before the first frame update
    void Awake()
    {
        active = true;
        OnForceFieldReturnDamage += ForceField.GetComponent<ForceField>().DamageReturned;
        OnForceFieldShieldPoints += ForceField.GetComponent<ForceField>().SetShieldPoints;
        OnForceFieldReturnDamage += SecondaryForceField.GetComponent<ForceField>().DamageReturned;
        OnSecondaryForceFieldShieldPoints += SecondaryForceField.GetComponent<ForceField>().SetShieldPoints;
        OnForceFieldShieldPoints?.Invoke(20f);
        OnSecondaryForceFieldShieldPoints?.Invoke(20f);
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        IsBatteryFried = false;
        _as = GetComponent<AudioSource>();
        //_animForceField.SetBool("IsForceFieldOn", true);
        GameVars.Values.IsAllSlotsDisabled();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.15f, true);
        SetUIIndicator("UI_MicrowaveForceFieldGenerator_Indicator");
    }

    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if (_skillTree.isMT1aActivated)
        {
            Activate1aUpgrade();
        }
        if (_skillTree.isMT1bActivated)
        {
            Activate1bUpgrade();
        }
        if (_skillTree.isMT2aActivated)
        {
            Activate2aUpgrade();
        }
        if (_skillTree.isMT2bActivated)
        {
            Activate2bUpgrade();
        }
    }

    public void Activate1aUpgrade()
    {
        _canActivate1aUpgrade = true;
        _canActivate1bUpgrade = false;
        OnForceFieldShieldPoints?.Invoke(40f);
        OnSecondaryForceFieldShieldPoints?.Invoke(40f);
        //Aplicar beneficio del Upgrade
    }
    public void Activate1bUpgrade()
    {
        _canActivate1aUpgrade = false;
        _canActivate1bUpgrade = true;
        OnForceFieldShieldPoints?.Invoke(60f);
        OnSecondaryForceFieldShieldPoints?.Invoke(60f);
        //Aplicar beneficio del Upgrade
    }

    public void Activate2aUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = true;
        SecondaryForceField.SetActive(_canActivate2aUpgrade);
        //Aplicar beneficio del Upgrade
    }
    public void Activate2bUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = false;
        _canActivate2bUpgrade = true;
        ReturnDamageActive = _canActivate2bUpgrade;
        OnForceFieldReturnDamage?.Invoke();
        //Aplicar beneficio del Upgrade
    }

    #endregion

    // Update is called once per frame
    void Update()
    {

    }

    public void BecomeMovable()
    {
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        Destroy(gameObject);
    }

    public void Interact()
    {
        if (!active)
        {
            Debug.Log("Active el Campo de fuerza");
        }
    }

    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        EMPFriedEffect.SetActive(true);
        particleRipples.SetActive(false);
        IsBatteryFried = true;
        active = false;
    }

    public void BatteryReplaced()
    {
        EMPFriedEffect.SetActive(false);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.15f, true);
        ForceField.SetActive(true);
        OnForceFieldShieldPoints?.Invoke(20f);
        OnSecondaryForceFieldShieldPoints?.Invoke(20f);
        particleRipples.SetActive(true);
        IsBatteryFried = false;
        OnMicrowaveBatteryReplaced?.Invoke();
        active = true;
    }
    IEnumerator PlayShutdownSound()
    {
        _isDisabledSFX = false;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretShutDown", 0.16f, false);
        yield return new WaitForSeconds(1f);
        GameVars.Values.soundManager.StopSound();
        _isDisabledSFX = true;
    }
}
