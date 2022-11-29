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
    private AudioSource _as;
    private bool _isDisabledSFX;
    public bool IsBatteryFried;
    // Start is called before the first frame update
    void Awake()
    {
        active = true;
        _as = GetComponent<AudioSource>();
        GameVars.Values.IsAllSlotsDisabled();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.15f, true);
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void BecomeMovable()
    {
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
        Destroy(gameObject);
    }

    public void Interact()
    {
        if (!active)
        {
            Debug.Log("Active el Campo de fuerza");
            particleRipples.SetActive(true);
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
