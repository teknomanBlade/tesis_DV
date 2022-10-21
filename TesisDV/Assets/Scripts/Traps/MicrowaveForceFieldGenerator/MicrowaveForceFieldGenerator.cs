using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MicrowaveForceFieldGenerator : Trap, IMovable, IInteractable
{
    public GameObject cat;
    public GameObject blueprintPrefab;
    public GameObject particleRipples;
    private AudioSource _as;
    private bool _isDisabledSFX;
    // Start is called before the first frame update
    void Awake()
    {
        active = true;
        _as = GetComponent<AudioSource>();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMRingWavesSFX", 0.25f, true);
    }

    // Update is called once per frame
    void Update()
    {
        if (active)
        {
            DetectObjectiveToProtect();
        }
    }

    public void DetectObjectiveToProtect()
    {
        Collider[] allTargets = Physics.OverlapSphere(transform.position, viewRadius, targetMask);
        cat = allTargets.Where(x => x.GetComponent<Cat>()).FirstOrDefault().gameObject;
        var forceField = cat.GetComponent<Cat>().ForceField;
        forceField.SetActive(true);
        var dir = cat.transform.position - particleRipples.transform.position;
        transform.forward = dir;
        particleRipples.transform.forward = dir;
        return;
    }

    public void BecomeMovable()
    {
        /*GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        Destroy(gameObject);*/
    }

    public void Interact()
    {
        if (!active)
        {
            Debug.Log("Active la torreta");
            particleRipples.SetActive(true);
        }
    }

    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        particleRipples.SetActive(false);
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
}
