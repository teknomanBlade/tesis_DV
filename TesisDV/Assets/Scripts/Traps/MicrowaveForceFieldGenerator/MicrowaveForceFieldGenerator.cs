using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MicrowaveForceFieldGenerator : Trap, IMovable, IInteractable
{
    public delegate void OnMicrowaveBatteryReplacedDelegate();
    public event OnMicrowaveBatteryReplacedDelegate OnMicrowaveBatteryReplaced;
    public GameObject blueprintPrefab;
    public GameObject particleRipples;
    public GameObject EMPFriedEffect;
    public GameObject ForceField;
    private Animator _animForceField;
    private ForceField _forceFieldScript;
    private AudioSource _as;
    private bool _isDisabledSFX;
    public bool IsBatteryFried;
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
        active = true;
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        IsBatteryFried = false;
        _as = GetComponent<AudioSource>();
        _forceFieldScript = ForceField.GetComponent<ForceField>();
        _animForceField = ForceField.GetComponent<Animator>();
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
            _plus100SPBlueprint.SetActive(true);
            _canActivate1aUpgrade = true;
        }
        else if (_skillTree.isMT1bActivated)
        {
            _plus200SPBlueprint.SetActive(true);
            _canActivate1bUpgrade = true;
        }
        else if (_skillTree.isMT2aActivated)
        {
            _secondaryShieldsBlueprint.SetActive(true);
            _canActivate2aUpgrade = true;
        }
        else if (_skillTree.isMT2bActivated)
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
        //_animForceField.SetBool("IsForceFieldOn", false);
        IsBatteryFried = true;
        active = false;
    }

    public void BatteryReplaced()
    {
        EMPFriedEffect.SetActive(false);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.15f, true);
        ForceField.SetActive(true);
        _forceFieldScript.Health = 20f;
        //_animForceField.SetBool("IsForceFieldOn", true);
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
