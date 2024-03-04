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
    // Start is called before the first frame update
    void Awake()
    {
        active = true;
        IsBatteryFried = false;
        _as = GetComponent<AudioSource>();
        _forceFieldScript = ForceField.GetComponent<ForceField>();
        _animForceField = ForceField.GetComponent<Animator>();
        //_animForceField.SetBool("IsForceFieldOn", true);
        GameVars.Values.IsAllSlotsDisabled();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.15f, true);
        SetUIIndicator("UI_MicrowaveForceFieldGenerator_Indicator");
    }

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
