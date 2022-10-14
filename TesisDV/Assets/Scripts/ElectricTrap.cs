using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTrap : Trap, IInteractable
{
    [SerializeField] private float _damagePerSecond;
    [SerializeField] private float _trapDuration;
    [SerializeField] private float _currentLife;
    public GameObject ParticleLightning;
    public GameObject ElectricRadius;
    private bool _isDisabledSFX;
    private AudioSource _as;
    private void Start()
    {
        active = true; // Ahora las trampas empiezan encendidas.        
    }

    private void Update()
    {
        _trapDuration -= Time.deltaTime;

        if (_trapDuration <=0)
        {
            active = false;
            ParticleLightning.SetActive(false);
            ElectricRadius.SetActive(false);
        }
    }

    public void Interact()
    {
        if (!active)
        {
            active = true;
            ParticleLightning.SetActive(true);
            ElectricRadius.SetActive(true);
        }
        if(_trapDuration <= 0)
        {
            _trapDuration =10f;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        var enemyGray = other.GetComponent<Enemy>();

        if(enemyGray && !other.GetComponent<GrayModel>() && active)
        {
            other.GetComponent<Enemy>().TakeDamage(_damagePerSecond);
        }
    }
    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        ParticleLightning.SetActive(false);
        ElectricRadius.SetActive(false);
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
